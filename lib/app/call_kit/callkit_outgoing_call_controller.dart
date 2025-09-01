import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/extensions/extensions.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import '../data/session_management.dart';
import '../data/utils.dart';
import '../routes/route_settings.dart';

class CallKitOutgoingCallController extends GetxController with GetTickerProviderStateMixin {
  /// Observables
  var callStatus = "Trying to connect...".obs;
  RxString callType = "".obs; // "audio" or "video"
  RxBool muted = false.obs;
  RxBool videoMuted = false.obs;
  RxBool speakerOn = false.obs;
  RxBool isOnGoingCallViewEnable = false.obs;
  RxList<String?> callerUsersId = <String?>[].obs;
  final RxBool cameraSwitch = false.obs;
  var selectedDevice = FlyCallAudioDeviceType.earpiece.obs;
  final RxBool isIncoming = false.obs;
  RxString cameraPosition = CameraType.front.obs;
  RxBool isRemoteAudioMuted = false.obs;
  RxBool isRemoteVideoMuted = false.obs;
  RxString remoteUserName = "".obs;
  RxString localUserName = "".obs;

  ///
  final RxBool isLocalTracksPublished = false.obs;
  final RxBool isRemoteTracksPublished = false.obs;
  RxString localParticipantId = "".obs;
  RxString remoteParticipantId = "".obs; // Temp for now as we do only 1-1 calls

  ///
  RxString mainCallViewUserId = "".obs;
  RxString secondaryCallViewUserId = "".obs;
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
      await initAudioRouting();
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
        // setInitialAudioOutput();
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
    _resetValues();
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
    _resetValues();
    _stopTimer();
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
    await MirrorflyCallKit.disconnectCall();
  }

  void muteAudio() async {
    print("[MirrorFly] muteAudio start");

    MirrorflyCallKit.toggleMicrophone(result: (result) async {
      print("[MirrorFly] muteAudio toggleMicrophone result : $result");

      if (result) {
        final bool isMicEnabled =
            await MirrorflyCallKit.getIsMicrophoneEnabled();
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
    MirrorflyCallKit.toggleCamera(result: (result) async{
      if(result){
        final bool isVideoMute = await MirrorflyCallKit.getIsCameraEnabled();
        print("[MirrorFly] existing isVideoMute status : $isVideoMute");
        videoMuted.value = !isVideoMute;
      }else{
        print("[MirrorFly]  Error isVideoMute status  result : $result");
      }
    });
  }

  void switchCamera() async {
    print("[MirrorFly] switchCamera start");

    MirrorflyCallKit.switchCameraPosition(result: (result) async {
      print("[MirrorFly] switchCameraPosition result : $result");

      // After switching, get the updated position
      var pos = await MirrorflyCallKit.getCurrentCameraPosition();
      if (pos == CameraType.front) {
        cameraPosition.value = pos;
      } else if (pos == CameraType.back) {
        cameraPosition.value = pos;
      }
      print("[MirrorFly] updated pos : $pos");

      // Update state
    });
  }

  Future<void> initAudioRouting() async {
    print("[MirrorFly] Initializing audio routing...");

    final isVideo = callType.value.toLowerCase() == "video";
    final devices = await MirrorflyCallKit.getAvailableMediaDevices();
    final audioOutputs = devices.where((d) => d.kind == OutputAudioDeviceKind.audioOutput.value).toList();

    FlyMediaDevice? targetDevice;

    // Priority order
    final bluetooth = audioOutputs.firstWhereOrNull(
          (d) => d.groupId?.toLowerCase().contains(FlyCallAudioDeviceType.bluetooth.value) ?? false,
    );
    final wired = audioOutputs.firstWhereOrNull(
          (d) => d.deviceId.toLowerCase().contains(FlyCallAudioDeviceType.wired.value),
    );

    if (bluetooth != null) {
      targetDevice = bluetooth;
      selectedDevice.value = FlyCallAudioDeviceType.bluetooth;
    } else if (wired != null) {
      targetDevice = wired;
      selectedDevice.value = FlyCallAudioDeviceType.wired;
    } else if (isVideo) {
      targetDevice = audioOutputs.firstWhereOrNull(
            (d) => d.deviceId.toLowerCase().contains(FlyCallAudioDeviceType.speaker.value),
      );
      selectedDevice.value = FlyCallAudioDeviceType.speaker;
    } else {
      targetDevice = audioOutputs.firstWhereOrNull(
            (d) => d.deviceId.toLowerCase().contains(FlyCallAudioDeviceType.earpiece.value) ||
            d.deviceId.toLowerCase().contains("receiver"),
      );
      selectedDevice.value = FlyCallAudioDeviceType.earpiece;
    }

    if (targetDevice != null) {
      await _switchTo(targetDevice);
    } else {
      print("[MirrorFly] No audio output device found!");
    }
  }
  Future<void> changeAudioDevice(FlyCallAudioDeviceType type) async {
    print("[MirrorFly] changeAudioDevice -> ${type.value}");
    final device = await _getAudioDevice(type.value);
    if (device != null) {
      await _switchTo(device);
      selectedDevice.value = type;
    } else {
      print("[MirrorFly] No matching device for ${type.value}");
    }
  }

  Future<void> _switchTo(FlyMediaDevice device) async {
    final result = await MirrorflyCallKit.changeAudioOutputDevice(
      flyMediaDevice: device,
      device: device.deviceId,
    );

    if (result) {
      print("[MirrorFly] Audio switched to: ${device.label}");
    } else {
      print("[MirrorFly] Failed to switch audio: ${device.label}");
    }
  }
  Future<FlyMediaDevice?> _getAudioDevice(String type) async {
    final devices = await MirrorflyCallKit.getAvailableMediaDevices();
    return devices.firstWhereOrNull(
          (d) => d.deviceId.toLowerCase().contains(type.toLowerCase()) &&
          d.kind == OutputAudioDeviceKind.audioOutput.value,
    );
  }
  Future<List<FlyCallAudioDeviceType>> getAvailableTypes() async {
    final devices = await MirrorflyCallKit.getAvailableMediaDevices();
    final audioOutputs = devices.where((d) => d.kind == OutputAudioDeviceKind.audioOutput.value).toList();

    final types = <FlyCallAudioDeviceType>[];
    if (audioOutputs.any((d) => d.deviceId.toLowerCase().contains(FlyCallAudioDeviceType.speaker.value))) {
      types.add(FlyCallAudioDeviceType.speaker);
    }
    if (audioOutputs.any((d) => d.deviceId.toLowerCase().contains(FlyCallAudioDeviceType.earpiece.value) ||
        d.deviceId.toLowerCase().contains("receiver"))) {
      types.add(FlyCallAudioDeviceType.earpiece);
    }
    if (audioOutputs.any((d) => d.groupId?.toLowerCase().contains(FlyCallAudioDeviceType.bluetooth.value) ?? false)) {
      types.add(FlyCallAudioDeviceType.bluetooth);
    }
    if (audioOutputs.any((d) => d.deviceId.toLowerCase().contains(FlyCallAudioDeviceType.wired.value))) {
      types.add(FlyCallAudioDeviceType.wired);
    }
    return types;
  }







  void localHangup() async {
    print("[MirrorFly]  disconnectCall invoked...");
    _stopTimer();
    try {
      var result = await MirrorflyCallKit.localHangup();
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

  void _resetValues() {
    callType("");
    muted(false);
    videoMuted(false);
    speakerOn(false);
    isOnGoingCallViewEnable(false);
    callerUsersId(<String?>[]);
    cameraSwitch(false);
    isIncoming(false);
    cameraPosition(CameraType.front);
    isRemoteAudioMuted(false);
    isRemoteVideoMuted(false);
    remoteUserName("");
    localUserName("");
    isLocalTracksPublished(false);
    isRemoteTracksPublished(false);
    localParticipantId("");
    remoteParticipantId("");
    mainCallViewUserId("");
    secondaryCallViewUserId("");
  }
}
