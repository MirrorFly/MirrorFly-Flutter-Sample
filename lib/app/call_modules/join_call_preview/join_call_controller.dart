import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/constants.dart';
import '../../data/permissions.dart';
import '../../data/session_management.dart';
import '../../data/utils.dart';
import '../../extensions/extensions.dart';
import '../../routes/route_settings.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import '../../common/app_localizations.dart';

class JoinCallController extends FullLifeCycleController with FullLifeCycleMixin, CallLinkEventListeners {

  final _users = <String>[].obs;
  get users => _users;

  final videoMuted = true.obs;
  // get videoMuted => _videoMuted.value;

  final muted = true.obs;
  // get muted => _muted.value;

  var callLinkId = "";

  var subscribeSuccess = false.obs;
  var displayStatus = getTranslated("connectingPleaseWait");

  @override
  void onInit(){
    super.onInit();
    Mirrorfly.setCallLinkEventListener(this);
    callLinkId = NavUtils.arguments["callLinkId"].toString();
    checkPermission().then((v){
      initializeCall();
    });

  }

  /// check permission and set Mute Status
  Future<void> checkPermission() async {
    var audioPermission = await AppPermission.askAudioCallPermissions();
    var videoPermission = await AppPermission.askVideoCallPermissions();
    muted(!audioPermission);
    videoMuted(!videoPermission);
    Mirrorfly.muteAudio(status: muted.value, flyCallBack: (_){});
    Mirrorfly.muteVideo(status: videoMuted.value, flyCallBack: (_){});
  }

  // initialize the meet or join via link call
  void initializeCall() {
    Mirrorfly.initializeMeet(callLinkId: callLinkId,userName: SessionManagement.getName().checkNull(),flyCallback: (res){
      LogMessage.d("initializeMeet", res.toString());
      if(!res.isSuccess) {
        subscribeSuccess(false);
        if(res.hasError){
          showError(res.exception);
        }
      }
      checkPermission().then((v){
        startVideoCapture();
      });
    });
  }

  RxString callEnded = "".obs;
  bool invalidLink = false;
  String callEndedMessage = "";
  // to show error message
  void showError(FlyException? error){
    disposePreview();
    invalidLink=false;
    switch(error?.code){
      case "100601":
      //Call link is not valid
        callEnded(getTranslated("invalidLink"));
        invalidLink=true;
        callEndedMessage= getTranslated("invalidLink");
        // toToast(getTranslated("invalidLink"));
        break;
      case "100602":
      //Api returned ended status for call
        callEnded(getTranslated("callEnded"));
        callEndedMessage=getTranslated("noOneHere");
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
  Future<void> startVideoCapture() async {
    Mirrorfly.startVideoCapture(flyCallback: (res) async {
      if(!res.isSuccess){
        // await AppPermission.askVideoCallPermissions();
      }
    });
  }

  void disposePreview() {
    Mirrorfly.disposePreview();
  }

  Future<void> joinCall() async {
    if (await AppUtils.isNetConnected()) {
      if(await AppPermission.askAudioCallPermissions()) {
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
    }else{
      toToast(getTranslated("noInternetConnection"));
    }
  }

  muteAudio() async {
    if(!muted.value || await AppPermission.askAudioCallPermissions()) {
      Mirrorfly.muteAudio(status: !muted.value, flyCallBack: (res) {
        if (res.isSuccess) {
          muted(!muted.value);
        }
      });
    }
  }

  videoMute() async {
    if (!videoMuted.value || await AppPermission.askVideoCallPermissions()) {
      if(!videoMuted.value && !subscribeSuccess.value){
        startVideoCapture();
      }else{
        debugPrint("Start Video Capture is already initialized, skipping the initialization");
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
  void onLocalVideoTrackAdded(String userJid) {

  }

  @override
  void onSubscribeSuccess() {
    subscribeSuccess(true);
  }

  @override
  void onUsersUpdated(List<String> users) {
    _users(users);
  }

  @override
  void onDetached() {

  }

  @override
  void onHidden() {

  }

  @override
  void onInactive() {

  }

  var paused = false;
  @override
  void onPaused() {
    paused = true;
  }

  @override
  void onResumed() {
    if(paused){
      paused = false;
      checkPermission();
    }
  }

  void onDisconnected() {
    displayStatus = getTranslated("noInternetConnection");
    subscribeSuccess(false);
  }

  void onConnected() {
    displayStatus = getTranslated("connectingPleaseWait");
    //if network connected then reinitialize call
    initializeCall();
  }

}