import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/extensions/extensions.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import '../app_style_config.dart';
import '../common/app_localizations.dart';
import '../data/session_management.dart';
import '../data/utils.dart';
import '../routes/route_settings.dart';

class CallKitOutgoingCallController extends GetxController with GetTickerProviderStateMixin {
  /// Observables
  var callStatus = "Trying to connect...".obs;
  var callType = "".obs; // "audio" or "video"
  var muted = false.obs;
  var videoMuted = false.obs;
  var speakerOn = false.obs;
  var isOnGoingCallViewEnable = false.obs;
  var callerUsersId = <String?>[].obs;
  final RxBool cameraSwitch = false.obs;
  final RxBool isIncoming = false.obs;
  RxString cameraPosition = CameraType.front.obs;
  var isRemoteAudioMuted = false.obs;
  var isRemoteVideoMuted = false.obs;
  var remoteUserName = "".obs;
  var localUserName = "".obs;

  ///
  final RxBool isLocalTracksPublished = false.obs;
  final RxBool isRemoteTracksPublished = false.obs;
  var localParticipantId = "".obs;
  var remoteParticipantId = "".obs; // Temp for now as we do only 1-1 calls

  ///
  var mainCallViewUserId = "".obs;
  var secondaryCallViewUserId = "".obs;
  Timer? timer;

  @override
  Future<void> onInit() async {
    print("[MirrorFly] callviewinit");
    if (NavUtils.arguments != null) {
      callerUsersId.value = NavUtils.arguments?["userJid"] as List<String?>;
      callType(NavUtils.arguments?["callType"]);
      isIncoming.value = NavUtils.arguments?["isIncoming"] as bool? ?? false;
      print("[MirrorFly] isIncoming: $isIncoming $callType $callerUsersId");
      if (isIncoming.value) {
        isOnGoingCallView();
        secondaryCallViewUserId.value = SessionManagement.getUserJID().checkNull();
        mainCallViewUserId.value = callerUsersId[0] ?? "";
      } else if (!isIncoming.value && callType.value == "audio") {
        mainCallViewUserId.value = callerUsersId[0] ?? "";
      } else if (!isIncoming.value && callType.value == "video") {
        mainCallViewUserId.value = SessionManagement.getUserJID().checkNull();
        secondaryCallViewUserId.value = callerUsersId[0] ?? "";
      }else{
        print("[MirrorFly] Invalid call parameters");
      }
      getRemoteUserName();
      await setInitialAudioOutput();

      // updateUserId();

    }
    print("[MirrorFly] callview");
    super.onInit();
  }

  void getRemoteUserName() async {
    ProfileDetails profile = await getProfileDetails(callerUsersId[0]!);
    String username = profile.name ?? profile.nickName ?? "Unknown";
    remoteUserName.value = username;
    print("User Name: $username");

  }

  void getUserName()async{
    ProfileDetails profile = await getProfileDetails(SessionManagement.getUserJID()!);
    String username = profile.name ?? profile.nickName ?? "Unknown";
    localUserName.value = username;
    print("User Name: $username");

  }


  void _startTimer({int? time}) {
    if (timer != null) {
      timer?.cancel();
    }
    timer = null;
    const oneSec = Duration(seconds: 1);
    var startTime = time != null
        ? DateTime.fromMillisecondsSinceEpoch(time)
        : DateTime.now();
    timer = Timer.periodic(
      oneSec,
          (Timer timer) {
        final hrDur = DateTime.now().difference(startTime).inHours;
        final minDur = DateTime.now().difference(startTime).inMinutes;
        final secDur = DateTime.now().difference(startTime).inSeconds % 60;
        final hours = hrDur.remainder(24).toStringAsFixed(0).padLeft(2, '0');
        final minutes = minDur.remainder(60).toStringAsFixed(0).padLeft(2, '0');
        final seconds = secDur.remainder(60).toStringAsFixed(0).padLeft(2, '0');
        var time = '${hours != "00" ? '$hours:' : ''}$minutes:$seconds';
        print("[MirrorFly] Timer: $time");
        _updateCallDuration(duration: time);
      },
    );
  }

  void _stopTimer() {
    if (timer == null) {
      print("[MirrorFly] Timer is null");
      return;
    }
    timer?.cancel();
    timer = null;
  }

  ///
  void updateCallStatus({required FlyCallStatus status}) {
    print("[MirrorFly] [Call Outgoing call controller] Call Status Updated: $status");
    switch (status) {
      case FlyCallStatus.ringing:
        callStatus("Ringing...");
      case FlyCallStatus.connecting:
        /// Received only for outgoing call.
      /// For incoming call after the call gets connected the FlyCallStatus is connected
      //   connecting();
      case FlyCallStatus.reconnecting:
        callStatus("Trying to reconnecting...");
      case FlyCallStatus.connected:
        connected();

        secondaryCallViewUserId.value = SessionManagement.getUserJID().checkNull();
        mainCallViewUserId.value = callerUsersId[0] ?? "";

        /// *** Need to check *** ///
        /// Need to get the current routed Audio Device and set the Audio Route value accordingly
        setInitialAudioOutput();
        /// For incoming call after the call gets connected the FlyCallStatus is connected
        // if (isIncoming.value)
          print("[MirrorFly] [Call Outgoing call controller] incoming call connected status updated");
          return;
        // } else {
        //   print("[MirrorFly] [Call Outgoing call controller] not a incoming call");
        // }

      case FlyCallStatus.disconnected:
        disconnectCall();
      case FlyCallStatus.callTimeout:
        callTimeOut();
      case FlyCallStatus.rejected:
        rejected();
      default:
        print("[MirrorFly] Unknown Call Status: $status");
    }
  }

  void onRemoteMuteStatusChanged({
    required FlyCallMuteType muteType,
    required FlyCallMuteStatus muteStatus,
    String? participantId,
  }) {
    switch (muteType) {
      case FlyCallMuteType.audio:
        isRemoteAudioMuted.value = muteStatus == FlyCallMuteStatus.muted;
        break;

      case FlyCallMuteType.video:
        isRemoteVideoMuted.value = muteStatus == FlyCallMuteStatus.muted;
        break;
    }

    print(
        "[Controller] Updated => audioMuted=${isRemoteAudioMuted.value}, videoMuted=${isRemoteVideoMuted.value}");
  }




  ///
   void _updateCallDuration({required String duration}) {
    callStatus(duration);
  }

  ///

  void callTimeOut() async {
    callStatus("Trying to timeout");
    toToast("Call Timeout");
    await handleTimeOutDisconnect();
    _stopTimer();
    NavUtils.back();
  }

  void rejected() {
    toToast("Call Declined");
    NavUtils.back();
  }

  void ringing() {}
  void connecting() {
    // callStatus("Connected");
    isOnGoingCallView();
    // updateUserId();
    // _startTimer();
  }
  void connected(){
    callStatus("Connected");
    isOnGoingCallView();
    updateUserId();
    _startTimer();
  }

  void disconnectCall() {
    _stopTimer();
    closeDialog();
    if (NavUtils.currentRoute == Routes.callKitOutGoingCallView) {
      callStatus("Disconnected");
      toToast("Call Disconnected");
      NavUtils.back();
    }
  }

  void isOnGoingCallView() async {
    isOnGoingCallViewEnable.value = true;
  }


  Future<void> handleTimeOutDisconnect() async {
    await MirrorFlyCallKit.disconnectCall();
  }

  void muteAudio() async {
    print("[MirrorFly] muteAudio start");

    MirrorFlyCallKit.toggleMicrophone(result: (result) async {
      print("[MirrorFly] muteAudio toggleMicrophone result : $result");

      if (result) {
        final bool isMicEnabled =
            await MirrorFlyCallKit.getIsMicrophoneEnabled();
        print(
            "[MirrorFly] muteAudio failure toggleMicrophone isMicEnabled : $isMicEnabled");
        muted.value =
            !isMicEnabled;
      } else {
        print(
            "[MirrorFly] muteAudio failure toggleMicrophone result : $result");
      }
    });
  }

  void videoMute() async {
    print("[MirrorFly] videoMute start");
    MirrorFlyCallKit.toggleCamera(result: (result) async{
      if(result){
        final bool isVideoMute = await MirrorFlyCallKit.getIsCameraEnabled();
        print("[MirrorFly] existing isVideoMute status : $isVideoMute");
        videoMuted.value = !isVideoMute;
      }else{
        print("[MirrorFly]  Error isVideoMute status  result : $result");
      }
    });
  }

  void switchCamera() async {
    print("[MirrorFly] switchCamera start");

    MirrorFlyCallKit.switchCameraPosition(result: (result) async {
      print("[MirrorFly] switchCameraPosition result : $result");

      // After switching, get the updated position
      var pos = await MirrorFlyCallKit.getCurrentCameraPosition();
      if (pos == CameraType.front) {
        cameraPosition.value = pos;
      } else if (pos == CameraType.back) {
        cameraPosition.value = pos;
      }
      print("[MirrorFly] updated pos : $pos");

      // Update state
    });
  }

  Future<void> setInitialAudioOutput() async {
    final isVideo = callType.value.toLowerCase() == "video";
    final targetId = isVideo ? "speaker" : "earpiece";

    print("[Mirrorfly] Get Audio Device at Initial Audio output: $targetId");

    final device = await _getAudioDevice(targetId);

    if (device != null) {
      var result = await MirrorFlyCallKit.changeAudioOutputDevice(
        device: device
      );
      if(result){
        speakerOn.value = isVideo;
        print("[Mirrorfly] Initial audio output set to ${device.label}");
      }else{
        print("[Mirrorfly] Initial audio output  Error");
      }

    }
  }

  Future<FlyMediaDevice?> _getAudioDevice(String deviceId) async {
    final devices = await MirrorFlyCallKit.getAvailableMediaDevices();
    try {
      final d = devices.firstWhere(
            (d) => d.deviceId == deviceId && d.kind == "audiooutput",
      );

      return FlyMediaDevice(d.deviceId, d.label, d.kind, d.groupId);
    } catch (_) {
      return null;
    }
  }




  void changeSpeaker() async{
    final isCurrentlySpeaker = speakerOn.value;
    final targetId = isCurrentlySpeaker ? "earpiece" : "speaker";

    print("Get Audio Device at Change Speaker: $targetId");
    final device = await _getAudioDevice(targetId);

    if (device != null) {
      var result = await MirrorFlyCallKit.changeAudioOutputDevice(
        device: device
      );
      if(result){
        speakerOn.value = (targetId == "speaker");
        print("[Mirrorfly] Change audio output set to ${device.label}");
      }else{
        print("[Mirrorfly] change  audio output  Error");
      }
      print("[Mirrorfly] Switched to ${device.label}");
    }
  }

  void localHangup() async {
    print("[MirrorFly]  disconnectCall invoked...");
    _stopTimer();
    try {
      var result = await MirrorFlyCallKit.localHangup();
      print("[MirrorFly] localHangup() result: $result");

      if (result == true) {
        print(
            "[MirrorFly]  Call disconnected successfully. Navigating back...");
        NavUtils.back();
      } else {
        NavUtils.back();
        print(
            "[MirrorFly]  Call disconnect failed. Retrying or handling failure...");
      }
    } catch (e, stack) {
      print("[MirrorFly]  Exception in disconnectCall: $e");
      print(stack);
    }
  }

  ///
  void onTracksPublished({required bool isSelf, required String participantId}) {
    if (isSelf) {
      if (!isLocalTracksPublished.value) {
        print("[MirrorFly] [MirrorFlyCall] Local tracks published for $participantId");
        isLocalTracksPublished(true);
        localParticipantId(participantId);
      } else {
        print("[MirrorFly] [MirrorFlyCall] Ignoring duplicate local publish for $participantId");
      }
    } else {
      if (!isRemoteTracksPublished.value) {
        print("[MirrorFly] [MirrorFlyCall] Remote tracks published for $participantId");
        isRemoteTracksPublished(true);
        remoteParticipantId(participantId);
      } else {
        print("[MirrorFly] [MirrorFlyCall] Ignoring duplicate remote publish for $participantId");
      }
    }
  }

  void updateUserId() {
    print("[MirrorFly] [MirrorFlyCall] updateUserId called with isIncoming: $isIncoming, callerUsersId: $callerUsersId");
    if (isIncoming.value) {
      mainCallViewUserId(callerUsersId.first);
      if (callerUsersId.length > 1) {
        secondaryCallViewUserId(callerUsersId.last);
      }
    } else {
      mainCallViewUserId(callerUsersId.first);
      if (callerUsersId.isNotEmpty) {
        mainCallViewUserId(callerUsersId.first);
        secondaryCallViewUserId(SessionManagement.getUserJID());
      }
    }
    print("[MirrorFly] [MirrorFlyCall] mainCallViewUserId: $mainCallViewUserId, secondaryCallViewUserId: $secondaryCallViewUserId");
  }

  void requestVideoCallSwitch() async {
    print("[MirrorFly]  makeCallSwitch invoked...");
    await MirrorFlyCallKit.requestVideoCallSwitch();
  }

  void acceptIncomingCallSwitchRequest() async {
    print("[MirrorFly]  acceptIncomingCallSwitchRequest invoked...");
    await MirrorFlyCallKit.acceptIncomingVideoCallSwitchRequest();
  }

  void declineIncomingCallSwitchRequest() async {
    print("[MirrorFly]  declineIncomingCallSwitchRequest invoked...");
    await MirrorFlyCallKit.declineIncomingVideoCallSwitchRequest();
  }

  void callSwitchAction({required CallSwitchAction? switchAction}) {
    print("[MirrorFly] callSwitchAction: $switchAction");
    switch (switchAction) {
      case CallSwitchAction.incomingRequest:
        print("[MirrorFly] CallSwitchAction.incomingRequest");
        showIncomingCallSwitchRequestDialog();
      case CallSwitchAction.decline:
        print("[MirrorFly] CallSwitchAction.decline");
        closeDialog();
        toToast("Video call switch declined");
      default:
        break;
    }
  }

  ///
  void showIncomingCallSwitchRequestDialog() {
    DialogUtils.showAlert(
        dialogStyle: AppStyleConfig.dialogStyle,
        message: getTranslated("videoSwitchRequestedMessage")
            .replaceFirst("%d", "Test"),
        actions: [
          TextButton(
              style: AppStyleConfig.dialogStyle.buttonStyle,
              onPressed: declineIncomingCallSwitchRequest,
              child: Text(
                getTranslated("declineRequest").toUpperCase(),
              )),
          TextButton(
              style: AppStyleConfig.dialogStyle.buttonStyle,
              onPressed: acceptIncomingCallSwitchRequest,
              child: Text(
                getTranslated("acceptRequest"),
              ))
        ],
        barrierDismissible: false);
  }

  void closeDialog() {
    if (DialogUtils.isDialogOpen()) {
      NavUtils.back();
    }
  }
}
