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

class CallKitOutgoingCallController extends GetxController
    with GetTickerProviderStateMixin {
  /// Observables
  var callStatus = "Trying to connect...".obs;
  var callDuration = "".obs;
  var callTryStatus = "".obs;
  RxBool showControls = true.obs;
  RxString callType = "".obs; // "audio" or "video"
  RxBool muted = false.obs;
  RxBool isVideoEnabled = true.obs;
  RxBool speakerOn = false.obs;
  RxBool isOnGoingCallViewEnable = false.obs;
  RxList<String?> callerUsersId = <String?>[].obs;
  final RxBool cameraSwitch = false.obs;
  var selectedDevice = FlyCallAudioDeviceType.earpiece.obs;
  final RxBool isIncoming = false.obs;
  final RxBool isManualDeviceSelected = false.obs;
  RxString cameraPosition = CameraType.front.obs;
  RxBool isRemoteAudioMuted = false.obs;
  RxBool isRemoteVideoMuted = true.obs;
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

  ///
  // Timer? _outgoingSwitchTimer;
  // bool _isWaitingCanceled = false;

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
        secondaryCallViewUserId.value =
            SessionManagement.getUserJID().checkNull();
        mainCallViewUserId.value = callerUsersId[0] ?? "";
      } else if (!isIncoming.value && callType.value == "audio") {
        mainCallViewUserId.value = callerUsersId[0] ?? "";
      } else if (!isIncoming.value && callType.value == "video") {
        mainCallViewUserId.value = SessionManagement.getUserJID().checkNull();
        secondaryCallViewUserId.value = callerUsersId[0] ?? "";
      } else {
        print("[MirrorFly] Invalid call parameters");
      }
      getRemoteUserName();
      // await initAudioRouting();
      // updateUserId();
    }
    print("[MirrorFly] callview");
    super.onInit();
  }

  void toggleControls() {
    showControls.value = !showControls.value;
  }

  void getRemoteUserName() async {
    ProfileDetails profile = await getProfileDetails(callerUsersId[0]!);
    String username = profile.name ?? profile.nickName ?? "Unknown";
    remoteUserName.value = username;
    print("User Name: $username");
  }

  void getUserName() async {
    ProfileDetails profile =
        await getProfileDetails(SessionManagement.getUserJID()!);
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
        // print("[MirrorFly] Timer: $time");
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

  void ringing() {
    callStatus("Ringing...");
  }

  void tryingToConnect() {
    callStatus("Trying to connect...");
  }

  void reconnecting() {
    // callStatus("Trying to reconnecting...");
    callTryStatus("Reconnecting...");
  }

  void reconnected() {
    callTryStatus("");
  }

  void isAudioMute({required bool isAudioMuted,required String? participantId}) {
    if(isSelfId(id: participantId)){
      muted.value = isAudioMuted;
    }else{
      isRemoteAudioMuted.value = isAudioMuted;
    }

    print("[Controller] Updated => audioMuted=${isRemoteAudioMuted.value}");
  }

  void isVideoMute({required bool isVideoMuted,required String? participantId}) {
    if(isSelfId(id: participantId)){
      isVideoEnabled.value = isVideoMuted;
    }else{
      isRemoteVideoMuted.value = isVideoMuted;
    }
    print("[Controller] Updated =>  videoMuted=${isRemoteVideoMuted.value}");
  }

  void audioCallAfterCallSwitch(){
    print("audioCallAfterCallSwitch change the call type into audio call");
    callType.value = "audio";
  }


  static bool isSelfId({required String? id}) {
    final String? currentUserId = SessionManagement.getUserJID();
    if (currentUserId == null) {
      print("[MirrorFly] isSelfId: is null id=$id");
      return true;
    } else {
      //
      final String participantId = "$id@xmpp-uikit-qa.contus.us";
      print("[Mirrorfly] isSelfId $currentUserId $participantId");
      print("[MirrorFly] isSelfId: ${currentUserId == participantId}");
      return currentUserId == participantId;
    }
  }

  ///
  void _updateCallDuration({required String duration}) {
    callDuration(duration);
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

  void connecting() {
    // callStatus("Connected");
    // isOnGoingCallView();
    // updateUserId();
    // _startTimer();
  }

  void connected() {
    callStatus("Connected");
    isOnGoingCallView();
    updateUserId();

    if (timer == null || !(timer?.isActive ?? false)) {
      _startTimer();
    } else {
      print("[MirrorFly] Timer is already running");
    }
    secondaryCallViewUserId.value = SessionManagement.getUserJID().checkNull();
    mainCallViewUserId.value = callerUsersId[0] ?? "";
  }

  void disconnectCall() {
    _resetValues();
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
      } else {
        print(
            "[MirrorFly] muteAudio failure toggleMicrophone result : $result");
      }
    });
  }

  void setCameraEnable({required bool enable}) async {
    print("[MirrorFly] setCameraEnable start");
    final FlyCallType? flyCallType =
        await MirrorFlyCallKit.getCurrentCallType();

    if (flyCallType == null) {
      print("[MirrorFly] setCameraEnable: Unable to get current call type.");
      return;
    }

    if (flyCallType == FlyCallType.audio) {
      print(
          "[MirrorFly] setCameraEnable: Current call is not a video call, so requesting to switch video call");
      requestVideoCallSwitch();
      return;
    }

    print("[MirrorFly] setCameraEnable: value : $enable");

    isVideoEnabled.value = enable;
    MirrorFlyCallKit.setCameraEnable(
        enable: enable,
        result: (result) async {
          if (result) {
            print("[MirrorFly] setCameraEnable : $result");
          } else {
            print(
                "[MirrorFly]  Error setCameraEnable status  result : $result");
          }
        });
  }



  void onCallSwitchRemoteUserDeclined() {
    print("[MirrorFly] onCallSwitchRemoteUserDeclined");
    toToast("Video call switch declined");
    closeDialog();
  }

  ///
  void onRemoteUserCancelledTheSwitchRequest() {
    print("[MirrorFly] onRemoteUserCancelledTheSwitchRequest");
    toToast("Video call switch canceled");
    closeDialog();
  }

  void remoteUserIsEngaged() async {
    print("[MirrorFly] remoteUserIsEngaged");
    toToast("${remoteUserName.value} in another call");
    await Future.delayed(const Duration(milliseconds: 500));
    if (NavUtils.canPop) {
      NavUtils.back();
    }
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

  Future<void> initAudioRouting(FlyMediaDevice? initialDevice) async {
    print("[MirrorFly] Initializing audio routing...");

    if (initialDevice == null) {
      print("[MirrorFly] No initial device passed!");
      return;
    }

    // Set the selectedDevice.value based on the passed FlyMediaDevice
    switch (initialDevice.deviceId.toLowerCase()) {
      case 'bluetooth':
        selectedDevice.value = FlyCallAudioDeviceType.bluetooth;
        break;
      case 'wired':
        selectedDevice.value = FlyCallAudioDeviceType.wired;
        break;
      case 'speaker':
        selectedDevice.value = FlyCallAudioDeviceType.speaker;
        break;
      case 'earpiece':
      case 'receiver':
        selectedDevice.value = FlyCallAudioDeviceType.earpiece;
        break;
      default:
        selectedDevice.value = FlyCallAudioDeviceType.earpiece;
        break;
    }

    print(
        "[MirrorFly] Routing to device: ${initialDevice.label}, enum: ${selectedDevice.value}");
  }

  Future<void> changeAudioDevice(
    FlyCallAudioDeviceType type,
  ) async {
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
    final result = await MirrorFlyCallKit.changeAudioOutputDevice(
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
    final devices = await MirrorFlyCallKit.getAvailableMediaDevices();
    return devices.firstWhereOrNull(
      (d) =>
          d.deviceId.toLowerCase().contains(type.toLowerCase()) &&
          d.kind == "audiooutput",
    );
  }

  Future<List<FlyCallAudioDeviceType>> getAvailableTypes() async {
    final devices = await MirrorFlyCallKit.getAvailableMediaDevices();
    final audioOutputs = devices.where((d) => d.kind == "audiooutput").toList();

    final types = <FlyCallAudioDeviceType>[];
    if (audioOutputs.any((d) => d.deviceId
        .toLowerCase()
        .contains(FlyCallAudioDeviceType.speaker.value))) {
      types.add(FlyCallAudioDeviceType.speaker);
    }
    if (audioOutputs.any((d) =>
        d.deviceId
            .toLowerCase()
            .contains(FlyCallAudioDeviceType.earpiece.value) ||
        d.deviceId.toLowerCase().contains("receiver"))) {
      types.add(FlyCallAudioDeviceType.earpiece);
    }
    if (audioOutputs.any((d) =>
        d.groupId
            ?.toLowerCase()
            .contains(FlyCallAudioDeviceType.bluetooth.value) ??
        false)) {
      types.add(FlyCallAudioDeviceType.bluetooth);
    }
    if (audioOutputs.any((d) => d.deviceId
        .toLowerCase()
        .contains(FlyCallAudioDeviceType.wired.value))) {
      types.add(FlyCallAudioDeviceType.wired);
    }
    return types;
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
  void onTracksPublished(
      {required bool isSelf, required String participantId}) {
    if (isSelf) {
      if (!isLocalTracksPublished.value) {
        print(
            "[MirrorFly] [MirrorFlyCall] Local tracks published for $participantId");
        isLocalTracksPublished(true);
        localParticipantId(participantId);
      } else {
        print(
            "[MirrorFly] [MirrorFlyCall] Ignoring duplicate local publish for $participantId");
      }
    } else {
      if (!isRemoteTracksPublished.value) {
        print(
            "[MirrorFly] [MirrorFlyCall] Remote tracks published for $participantId");
        isRemoteTracksPublished(true);
        remoteParticipantId(participantId);
      } else {
        print(
            "[MirrorFly] [MirrorFlyCall] Ignoring duplicate remote publish for $participantId");
      }
    }
  }

  void updateUserId() {
    print(
        "[MirrorFly] [MirrorFlyCall] updateUserId called with isIncoming: $isIncoming, callerUsersId: $callerUsersId");
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
    print(
        "[MirrorFly] [MirrorFlyCall] mainCallViewUserId: $mainCallViewUserId, secondaryCallViewUserId: $secondaryCallViewUserId");
  }

  ///
  void requestVideoCallSwitch() async {
    print("[MirrorFly]  makeCallSwitch invoked...");
    _videoCallSwitchRequestConfirmationPopup();
  }

  ///
  void cancelVideoCallSwitchRequest() async {
    print("[MirrorFly]  cancelVideoCallSwitch invoked...");
    await MirrorFlyCallKit.cancelVideoCallSwitchRequest();
    toToast("Video call switch canceled");
    closeDialog();
    // _cancelCallSwitchReqWaiting();
  }

  ///
  void acceptIncomingCallSwitchRequest() async {
    print("[MirrorFly]  acceptIncomingCallSwitchRequest invoked...");
    closeDialog();
    await MirrorFlyCallKit.acceptIncomingVideoCallSwitchRequest();
  }

  ///
  void declineIncomingCallSwitchRequest() async {
    print("[MirrorFly]  declineIncomingCallSwitchRequest invoked...");
    await MirrorFlyCallKit.declineIncomingVideoCallSwitchRequest();
    closeDialog();
  }

  ///

  void onVideoCallSwitchAccept() {
    closeDialog();
    onVideoCallSwitchRequestAccepted();
    processCallSwitchUI();
  }

  void onVideoCallSwitchTimeOut() {
    closeDialog();
    toToast(getTranslated("noResponseFrom")
        .replaceFirst("%d", remoteUserName.value));
  }

  ///
  void processCallSwitchUI() async {
    print("[MirrorFly] Processing call switch UI changes...");
    final FlyCallType? flyCallType =
        await MirrorFlyCallKit.getCurrentCallType();
    if (flyCallType == null && flyCallType == FlyCallType.none) {
      print("[MirrorFly] Unable to get current call type after switch.");
      return;
    }
    flyCallType == FlyCallType.audio ? callType("audio") : callType("video");
  }

  ///
  void onVideoCallSwitchRequestAccepted() {
    print("[MirrorFly] Video call switch request accepted.");
    closeDialog();
  }

  ///
  void _videoCallSwitchRequestConfirmationPopup() {
    DialogUtils.showAlert(
        dialogStyle: AppStyleConfig.dialogStyle,
        message: getTranslated("videoSwitchMessage"),
        actions: [
          TextButton(
              style: AppStyleConfig.dialogStyle.buttonStyle,
              onPressed: closeDialog,
              child: Text(
                getTranslated("cancel").toUpperCase(),
              )),
          TextButton(
              style: AppStyleConfig.dialogStyle.buttonStyle,
              onPressed: () async {
                closeDialog();
                await MirrorFlyCallKit.requestVideoCallSwitch();
              },
              child: Text(
                getTranslated("switchCall"),
              ))
        ],
        barrierDismissible: false);
  }

  ///
  void showIncomingCallSwitchRequestDialog() {
    DialogUtils.showAlert(
        dialogStyle: AppStyleConfig.dialogStyle,
        message: getTranslated("videoSwitchRequestedMessage")
            .replaceFirst("%d", remoteUserName.value),
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

  ///
  void showOutGoingCallSwitchRequestDialog() {
    //
    // _isWaitingCanceled = false;
    // _outgoingSwitchTimer?.cancel();

    //
    DialogUtils.showAlert(
      dialogStyle: AppStyleConfig.dialogStyle,
      message: getTranslated("videoSwitchRequestMessage"),
      actions: [
        TextButton(
          style: AppStyleConfig.dialogStyle.buttonStyle,
          onPressed: cancelVideoCallSwitchRequest,
          child: Text(getTranslated("cancel").toUpperCase()),
        )
      ],
      barrierDismissible: false,
    );

    // _outgoingSwitchTimer = Timer(const Duration(seconds: 20), () async {
    //   print("[MirrorFly][BaseController] 20s wait ended");
    //   if (!_isWaitingCanceled) {
    //     _cancelVideoCallSwitchRequestOnTimerEnd();
    //     toToast(getTranslated("noResponseFrom").replaceFirst("%d", "Test"));
    //     _closeDialog();
    //   } else {
    //     print("[MirrorFly][BaseController] _isWaitingCanceled is true");
    //   }
    // });
  }

  ///
  // void _cancelVideoCallSwitchRequestOnTimerEnd() async {
  //   print("[MirrorFly][BaseController] Canceling video call switch request due to timeout");
  //
  //   _cancelCallSwitchReqWaiting();
  //
  //   print("[MirrorFly] cancelVideoCallSwitchRequestOnTimerEnd invoked...");
  //   await MirrorFlyCallKit.cancelVideoCallSwitchRequest();
  //   _closeDialog();
  // }

  // ///
  // void _cancelCallSwitchReqWaiting() {
  //   _isWaitingCanceled = true;
  //   _outgoingSwitchTimer?.cancel();
  // }

  ///
  void closeDialog() {
    print("[MirrorFly] _closeDialog called");
    if (DialogUtils.isDialogOpen() && NavUtils.canPop) {
      NavUtils.back();
    }
  }

  ///
  void _resetValues() {
    callType("");
    muted(false);
    isVideoEnabled(false);
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
    isManualDeviceSelected(false);
    callTryStatus("");
  }
}
// void updateCallStatus({required FlyCallStatus status}) {
//   print("[MirrorFly] [Call Outgoing call controller] Call Status Updated: $status");
//   switch (status) {
//     case FlyCallStatus.ringing:
//       callStatus("Ringing...");
//     case FlyCallStatus.connecting:
//     /// Received only for outgoing call.
//     /// For incoming call after the call gets connected the FlyCallStatus is connected
//     //   connecting();
//     case FlyCallStatus.tryingToConnect:
//       callStatus("Trying to connect...");
//     case FlyCallStatus.reconnecting:
//       callStatus("Trying to reconnecting...");
//       callTryStatus("Trying to reconnecting...");
//     case FlyCallStatus.reconnected:
//       callTryStatus("");
//     case FlyCallStatus.connected:
//       connected();
//
//       secondaryCallViewUserId.value = SessionManagement.getUserJID().checkNull();
//       mainCallViewUserId.value = callerUsersId[0] ?? "";
//
//       /// *** Need to check *** ///
//       /// Need to get the current routed Audio Device and set the Audio Route value accordingly
//       // setInitialAudioOutput();
//       /// For incoming call after the call gets connected the FlyCallStatus is connected
//       // if (isIncoming.value)
//       print("[MirrorFly] [Call Outgoing call controller] incoming call connected status updated");
//       return;
//   // } else {
//   //   print("[MirrorFly] [Call Outgoing call controller] not a incoming call");
//   // }
//
//     case FlyCallStatus.disconnected:
//       disconnectCall();
//     case FlyCallStatus.callTimeout:
//       callTimeOut();
//     case FlyCallStatus.rejected:
//       rejected();
//     default:
//       print("[MirrorFly] Unknown Call Status: $status");
//   }
// }
// void callSwitchAction({required CallSwitchAction? switchAction}) {
//   print("[MirrorFly] callSwitchAction: $switchAction");
//   switch (switchAction) {
//     case CallSwitchAction.incomingRequest:
//       print("[MirrorFly] CallSwitchAction.incomingRequest");
//       _showIncomingCallSwitchRequestDialog();
//
//     case CallSwitchAction.decline:
//       print("[MirrorFly] CallSwitchAction.decline");
//       toToast("Video call switch declined");
//       closeDialog();
//   // _cancelCallSwitchReqWaiting();
//
//     case CallSwitchAction.outgoingRequest:
//       print("[MirrorFly] CallSwitchAction.outgoingRequest");
//       showOutGoingCallSwitchRequestDialog();
//
//     case CallSwitchAction.cancel:
//       print("[MirrorFly] CallSwitchAction.cancel");
//       _closeDialog();
//       toToast("Video call switch canceled");
//
//     case CallSwitchAction.accept:
//       print("[MirrorFly] CallSwitchAction.accept");
//       _closeDialog();
//       // _cancelCallSwitchReqWaiting();
//       _onVideoCallSwitchRequestAccepted();
//       _processCallSwitchUI();
//
//     case CallSwitchAction.timeout:
//       print("[MirrorFly] CallSwitchAction.timeout");
//       _closeDialog();
//       toToast(getTranslated("noResponseFrom")
//           .replaceFirst("%d", remoteUserName.value));
//       break;
//
//     default:
//       break;
//   }
// }

// void onRemoteMuteStatusChanged({
//   required FlyCallMuteType muteType,
//   required FlyCallMuteStatus muteStatus,
//   String? participantId,
// }) {
//   switch (muteType) {
//     case FlyCallMuteType.audio:
//       isRemoteAudioMuted.value = muteStatus == FlyCallMuteStatus.muted;
//       break;
//
//     case FlyCallMuteType.video:
//       isRemoteVideoMuted.value = muteStatus == FlyCallMuteStatus.muted;
//       break;
//   }
//
//   print(
//       "[Controller] Updated => audioMuted=${isRemoteAudioMuted.value}, videoMuted=${isRemoteVideoMuted.value}");
// }
