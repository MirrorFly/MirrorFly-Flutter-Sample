import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/call_kit/callkit_logger.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../call_modules/call_widgets.dart';
import '../../common/app_localizations.dart';
import '../../common/constants.dart';
import '../../data/permissions.dart';
import '../../data/session_management.dart';
import '../../data/utils.dart';
import '../../extensions/extensions.dart';


class CallKitJoinCallController extends FullLifeCycleController with FullLifeCycleMixin {

  var callLinkId = "";
  var isInitializeSuccess = false.obs;
  var audioPermissionGranted = false.obs;
  var videoPermissionGranted = false.obs;
  var meetInitialised = false.obs;
  var navigatedFrom = '';
  var displayStatus = getTranslated("connectingPleaseWait");
  var paused = false;

  final _users = <String>[].obs;
  final videoMuted = true.obs;
  final muted = true.obs;

  RxString callEnded = "".obs;
  bool invalidLink = false;
  String callEndedMessage = "";

  get users => _users;

  @override
  void onInit() async {
    super.onInit();
    callLinkId = NavUtils.arguments["callLinkId"].toString();
    navigatedFrom = NavUtils.arguments["navigatedFrom"].toString();

    checkPermission().then((success) async {
      if (!success) {
        callkitLogger.info("Required permissions not granted, cannot initialize join via link");
        isInitializeSuccess(false);
        displayStatus = getTranslated('permissionsNotGranted');
        toToast(getTranslated("permissionsNotGranted"));
        return;
      }

      callkitLogger.info("Initializing from $navigatedFrom via link with callLinkId: $callLinkId");
      final InitializeJoinLinkResponse initializeJoinLinkResponse =
          await MirrorFlyCallKit.initializeJoinViaLink(callLink: callLinkId);

      if (initializeJoinLinkResponse.isSuccess) {
        isInitializeSuccess(true);
        callkitLogger.info("Join via link initialization successful");
      } else {
        callkitLogger.info("Join via link initialization failed with error: ${initializeJoinLinkResponse.errorMessage}");
      }
    });
  }

  @override
  void onReady() {
    super.onReady();
    callkitLogger.info("JoinCallController onReady called, starting call initialization");
  }

  /// Get call members details
  Future<void> getCallDetails() async {

  }

  /// Join call
  Future<void> joinCall() async {
    if (await AppUtils.isNetConnected()) {
      if (await AppPermission.askAudioCallPermissions()) {
        if (await AppPermission.askNotificationPermission()) {}
      }
    } else {
      toToast(getTranslated("noInternetConnection"));
    }
  }

  /// Mute Audio
  Future<void> muteAudio() async {
    callkitLogger.info("Setting microphone mute state in CallKit to: ${muted.value}");
    MirrorFlyCallKit.setMicrophoneMuted(mute: !muted.value, result: ({bool? isMuted, required String message, required bool success}) {
      if (success) {
        callkitLogger.info("Microphone mute state successfully set in CallKit response isMuted $isMuted. Current state: ${muted.value}");
          muted(isMuted);
          callkitLogger.info("Audio mute state changed. New state: ${muted.value}");
      } else {
        callkitLogger.info("Failed to set microphone mute state in CallKit. Error: $message");
      }
    });
  }

  /// Mute Video
  Future<void> videoMute() async {
    callkitLogger.info("Toggling videoMute. Current state: ${videoMuted.value}");
    MirrorFlyCallKit.setCameraEnable(enable: (!videoMuted.value), result: (isSuccess) {
      callkitLogger.info("Camera enable response from CallKit: isSuccess: $isSuccess. Current videoMute state: ${videoMuted.value}");
      if (!isSuccess) {
        callkitLogger.info("Failed to toggle videoMute in CallKit.");
      } else {
        callkitLogger.info("Video mute state successfully toggled in CallKit. Current state: ${videoMuted.value}");
        videoMuted(!videoMuted.value);
      }
    });
  }

  /// Getter of profile image in future builder
  get getProfileImage => FutureBuilder<Widget>(
        future: _buildProfileImage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(color: Colors.white);
          }
          if (snapshot.hasError) {
            return const Icon(Icons.error);
          }
          return snapshot.data ?? const SizedBox.shrink();
        });

  /// Fetches the profile image for the current user and returns a widget to display it.
  Future<Widget> _buildProfileImage() async {
    var jid = SessionManagement.getUserJID().checkNull();
    callkitLogger.info("Fetching profile image for JID: $jid");

    final completer = Completer<Widget>();
    await Mirrorfly.getUserProfile(
      jid: jid,
      fetchFromServer: false,
      flyCallback: (FlyResponse response) {
        LogMessage.d(
          "MyProfileUpdated base controller getUserProfile",
          response.toString(),
        );

        if (response.isSuccess) {
          var data = profileDataFromJson(response.data);

          final profileDetails = ProfileDetails(
            email: data.data?.email,
            image: data.data?.image,
            mobileNumber: data.data?.mobileNumber,
            nickName: data.data?.nickName,
            name: data.data?.name,
            status: data.data?.status,
          );

          callkitLogger.info(
            "Profile image fetched successfully for JID: $jid",
          );

          completer.complete(buildProfileImage(profileDetails));
        } else {
          callkitLogger.info(
            "Profile fetch failed for JID: $jid, returning default",
          );

          completer.complete(const SizedBox.shrink());
        }
      },
    );

    return completer.future;
  }

  /// check permission and set Mute Status
  Future<bool> checkPermission() async {
    var audioPermission = await AppPermission.askAudioCallPermissions();
    var videoPermission = await AppPermission.checkAndRequestPermissions(
        permissions: [Permission.camera],
        permissionIcon: cameraPermission,
        permissionContent: getTranslated("callPermissionContent").replaceAll("%d", "Camera"),
        permissionPermanentlyDeniedContent: getTranslated("callPermissionDeniedContent").replaceAll("%d", "Camera"));
    callkitLogger.info("Audio permission: $audioPermission, Video permission: $videoPermission");
    audioPermissionGranted(audioPermission);
    videoPermissionGranted(videoPermission);
    return audioPermission && videoPermission;
  }

  @override
  void onDetached() {}

  @override
  void onHidden() {}

  @override
  void onInactive() {}

  @override
  void onPaused() {
    paused = true;
  }

  @override
  Future<void> onResumed() async {
    if (paused) {
      paused = false;
      checkPermission();
    }
  }
}
