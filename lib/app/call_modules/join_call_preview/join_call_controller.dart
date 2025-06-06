import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../common/app_localizations.dart';
import '../../common/constants.dart';
import '../../data/permissions.dart';
import '../../data/session_management.dart';
import '../../data/utils.dart';
import '../../extensions/extensions.dart';
import '../../routes/route_settings.dart';

class JoinCallController extends FullLifeCycleController
    with FullLifeCycleMixin, CallLinkEventListeners {
  final _users = <String>[].obs;
  get users => _users;

  final videoMuted = true.obs;
  // get videoMuted => _videoMuted.value;

  final muted = true.obs;
  // get muted => _muted.value;

  var callLinkId = "";

  var subscribeSuccess = false.obs;

  var audioPermissionGranted = false.obs;
  var videoPermissionGranted = false.obs;
  var meetInitialised = false.obs;

  var displayStatus = getTranslated("connectingPleaseWait");

  @override
  void onInit() {
    super.onInit();
    Mirrorfly.setCallLinkEventListener(this);
    callLinkId = NavUtils.arguments["callLinkId"].toString();
  }

  @override
  void onReady() {
    super.onReady();
    checkPermission().then((v) {
      // Future.delayed(const Duration(milliseconds: 500), (){
      initializeCall();
      // });
    });
  }

  /// check permission and set Mute Status
  Future<bool> checkPermission() async {
    var audioPermission = await AppPermission.askAudioCallPermissions();
    var videoPermission = await AppPermission.checkAndRequestPermissions(
        permissions: [Permission.camera],
        permissionIcon: cameraPermission,
        permissionContent:
            getTranslated("callPermissionContent").replaceAll("%d", "Camera"),
        permissionPermanentlyDeniedContent:
            getTranslated("callPermissionDeniedContent")
                .replaceAll("%d", "Camera"));
    muted(!audioPermission);
    videoMuted(!videoPermission);
    audioPermissionGranted(audioPermission);
    videoPermissionGranted(videoPermission);
    // Mirrorfly.muteAudio(status: muted.value, flyCallBack: (_){});
    // Mirrorfly.muteVideo(status: videoMuted.value, flyCallBack: (_){});

    return audioPermission && videoPermission;
  }

  // initialize the meet or join via link call
  void initializeCall() {
    Mirrorfly.initializeMeet(
        callLinkId: callLinkId,
        userName: SessionManagement.getName().checkNull(),
        flyCallback: (res) {
          LogMessage.d("initializeMeet", res.toString());
          if (!res.isSuccess) {
            subscribeSuccess(false);
            if (res.hasError) {
              showError(res.exception);
            }
          } else {
            meetInitialised(true);
            startVideoCapture();
          }
          // checkPermission().then((v){
          //   startVideoCapture();
          // });
        });
  }

  RxString callEnded = "".obs;
  bool invalidLink = false;
  String callEndedMessage = "";
  // to show error message
  void showError(FlyException? error) {
    disposePreview();
    invalidLink = false;
    switch (error?.code) {
      case "100601":
        //Call link is not valid
        callEnded(getTranslated("invalidLink"));
        invalidLink = true;
        callEndedMessage = getTranslated("invalidLink");
        // toToast(getTranslated("invalidLink"));
        break;
      case "100602":
        //Api returned ended status for call
        callEnded(getTranslated("callEnded"));
        callEndedMessage = getTranslated("noOneHere");
        // toToast(getTranslated("noOneHere"));
        //callEnded
        break;
      case "100603":
        //Maximum participants already in call
        //   callEnded(getTranslated("callEnded"));
        //   callEndedMessage = (getTranslated("callMembersLimit").replaceFirst("%d", "8"));
        toToast(getTranslated("callMembersLimit").replaceFirst("%d", "8"));
        NavUtils.back();
        break;
      case "100605":
        //Server didn't give success response code
        callEnded(getTranslated("callEnded"));
        callEndedMessage = (getTranslated("wentWrong"));
        // toToast(getTranslated("wentWrong"));
        //callEnded
        break;
      case "100620":
        //Couldn't process the link. Please try again.
        callEnded(getTranslated("callEnded"));
        callEndedMessage = (getTranslated("couldNotProcess"));
        // toToast(getTranslated("couldNotProcess"));
        break;
      case "100610":
        //Couldn't process the link.Please try again.
        callEnded(getTranslated("callEnded"));
        callEndedMessage = (getTranslated("couldNotProcess"));
        // toToast(getTranslated("couldNotProcess"));
        break;
      default:
        callEnded(getTranslated("callEnded"));
        callEndedMessage = (error?.message ?? "Error");
        // toToast(error?.message ?? "Error");
        break;
    }
    // NavUtils.back();
  }

  /// start video capture
  var videoCaptureStarted = false;
  Future<void> startVideoCapture() async {
    Mirrorfly.startVideoCapture(flyCallback: (res) async {
      if (res.isSuccess) {
        videoCaptureStarted = true;
      }
    });
  }

  void disposePreview() {
    Mirrorfly.disposePreview();
  }

  Future<void> joinCall() async {
    if (await AppUtils.isNetConnected()) {
      if (await AppPermission.askAudioCallPermissions()) {
        if (await AppPermission.askNotificationPermission()) {
          subscribeSuccess(false);
          Mirrorfly.joinCall(flyCallback: (res) {
            LogMessage.d("joinCall", res.toString());
            if (res.isSuccess) {
              NavUtils.offNamed(Routes.onGoingCallView,
                  arguments: {"userJid": users, "joinViaLink": true});
            } else {
              subscribeSuccess(true);
              showError(res.exception);
            }
          });
        }
      }
    } else {
      toToast(getTranslated("noInternetConnection"));
    }
  }

  muteAudio() async {
    if (!muted.value || await AppPermission.askAudioCallPermissions()) {
      Mirrorfly.muteAudio(
          status: !muted.value,
          flyCallBack: (res) {
            if (res.isSuccess) {
              muted(!muted.value);
            }
          });
    }
  }

  videoMute() async {
    var videoPermission = await AppPermission.checkAndRequestPermissions(
        permissions: [Permission.camera],
        permissionIcon: cameraPermission,
        permissionContent:
            getTranslated("callPermissionContent").replaceAll("%d", "Camera"),
        permissionPermanentlyDeniedContent:
            getTranslated("callPermissionDeniedContent")
                .replaceAll("%d", "Camera"));
    if (!videoMuted.value || videoPermission) {
      debugPrint(
          "Start Video Capture initialization $videoCaptureStarted ${videoMuted.value}");
      if (videoMuted.value && !videoCaptureStarted) {
        startVideoCapture();
      } else {
        debugPrint(
            "Start Video Capture is already initialized, skipping the initialization");
      }
      Mirrorfly.muteVideo(status: !videoMuted.value, flyCallBack: (_) {});
      videoMuted(!videoMuted.value);
    }
  }

  @override
  void onError(FlyException error) {
    showError(error);
  }

  @override
  void onLocalVideoTrackAdded(String userJid) {}

  @override
  void onSubscribeSuccess() {
    subscribeSuccess(true);
  }

  @override
  void onUsersUpdated(List<String> users) {
    _users(users);
  }

  @override
  void onDetached() {}

  @override
  void onHidden() {}

  @override
  void onInactive() {}

  var paused = false;
  @override
  void onPaused() {
    paused = true;
  }

  @override
  Future<void> onResumed() async {
    if (paused) {
      paused = false;
      // if(!connected && !(await AppUtils.isNetConnected())){
      //   displayStatus = getTranslated("noInternetConnection");
      // }
      checkPermission();
    }
  }

  var connected = false;
  void onDisconnected() {
    debugPrint("#MirrorFlyCall Method call OnDisConnected");
    connected = false;
    displayStatus = getTranslated("noInternetConnection");
    subscribeSuccess(false);
    if (meetInitialised.value) {
      disposePreview();
      meetInitialised(false);
    }
  }

  void onConnected() {
    connected = true;
    displayStatus = getTranslated("connectingPleaseWait");
    //if network connected then reinitialize call
    if (audioPermissionGranted.value && videoPermissionGranted.value) {
      initializeCall();
    }
  }
}
