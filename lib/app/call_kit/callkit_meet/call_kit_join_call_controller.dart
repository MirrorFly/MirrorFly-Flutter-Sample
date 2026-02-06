import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/call_kit/callkit_logger.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../common/app_localizations.dart';
import '../../common/constants.dart';
import '../../data/permissions.dart';
import '../../data/session_management.dart';
import '../../data/utils.dart';
import '../../extensions/extensions.dart';
import '../../routes/route_settings.dart';

class CallKitJoinCallController extends FullLifeCycleController
    with FullLifeCycleMixin {
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
  var navigatedFrom = '';

  var displayStatus = getTranslated("connectingPleaseWait");

  @override
  void onInit() async {
    super.onInit();
    callLinkId = NavUtils.arguments["callLinkId"].toString();
    navigatedFrom = NavUtils.arguments["navigatedFrom"].toString();

    callkitLogger.info("Initializing from $navigatedFrom via link with callLinkId: $callLinkId");
    checkPermission().then((v) async {
      final InitializeJoinLinkResponse initializeJoinLinkResponse =
          await MirrorFlyCallKit.initializeJoinViaLink(callLink: callLinkId);

      if (initializeJoinLinkResponse.isSuccess) {
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

  /// check permission and set Mute Status
  Future<bool> checkPermission() async {
    var audioPermission = await AppPermission.askAudioCallPermissions();
    var videoPermission = await AppPermission.checkAndRequestPermissions(
        permissions: [Permission.camera],
        permissionIcon: cameraPermission,
        permissionContent: getTranslated("callPermissionContent").replaceAll("%d", "Camera"),
        permissionPermanentlyDeniedContent: getTranslated("callPermissionDeniedContent").replaceAll("%d", "Camera"));
    muted(!audioPermission);
    videoMuted(!videoPermission);
    audioPermissionGranted(audioPermission);
    videoPermissionGranted(videoPermission);
    return audioPermission && videoPermission;
  }

  RxString callEnded = "".obs;

  bool invalidLink = false;
  String callEndedMessage = "";

  Future<void> joinCall() async {
    if (await AppUtils.isNetConnected()) {
      if (await AppPermission.askAudioCallPermissions()) {
        if (await AppPermission.askNotificationPermission()) {}
      }
    } else {
      toToast(getTranslated("noInternetConnection"));
    }
  }

  muteAudio() async {
    if (!muted.value || await AppPermission.askAudioCallPermissions()) {}
  }

  videoMute() async {
    var videoPermission = await AppPermission.checkAndRequestPermissions(
        permissions: [Permission.camera],
        permissionIcon: cameraPermission,
        permissionContent: getTranslated("callPermissionContent").replaceAll("%d", "Camera"),
        permissionPermanentlyDeniedContent: getTranslated("callPermissionDeniedContent").replaceAll("%d", "Camera"));
    if (!videoMuted.value || videoPermission) {
      debugPrint("Start Video Capture initialization ${videoMuted.value}");
      videoMuted(!videoMuted.value);
    }
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
      checkPermission();
    }
  }
}
