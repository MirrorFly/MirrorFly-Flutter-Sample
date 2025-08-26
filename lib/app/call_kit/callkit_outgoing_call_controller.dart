import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import '../data/utils.dart';
import '../routes/route_settings.dart';

class CallKitOutgoingCallController extends GetxController
    with GetTickerProviderStateMixin {
  /// Observables
  var callStatus = "Trying to connect...".obs;
  var callType = "".obs; // "audio" or "video"
  var muted = false.obs;
  var videoMuted = false.obs;
  var speakerOn = false.obs;
  var isIconEnable = false.obs;
  var isOnGoingCallViewEnable = false.obs;
  var callerUsersId = <String?>[].obs;
  final RxBool cameraSwitch = false.obs;
  final RxBool isIncoming = false.obs;

  @override
  Future<void> onInit() async {
    // TODO: implement onInit
    print("[MirrorFly] callviewinit");
    if (NavUtils.arguments != null) {
      callerUsersId.value = NavUtils.arguments?["userJid"] as List<String?>;
      callType(NavUtils.arguments?["callType"]);
      isIncoming.value = NavUtils.arguments?["isIncoming"] as bool? ?? false;
      print("[MirrorFly] isIncoming: $isIncoming $callType $callerUsersId");
      if (isIncoming.value) {
        isOnGoingCallView();
        isReadyIconEnable();
      }
    }
    print("[MirrorFly] callview");
    super.onInit();
  }

  ///
  void updateCallStatus({required FlyCallStatus status}) {
    switch (status) {
      case FlyCallStatus.ringing:
        callStatus("Ringing...");
      case FlyCallStatus.connecting:
        connecting();
      case FlyCallStatus.reconnecting:
        callStatus("Trying to reconnecting...");
      case FlyCallStatus.connected:
        callStatus("Connected");
      case FlyCallStatus.disconnected:
        disconnect();
      case FlyCallStatus.callTimeout:
        callTimeOut();
      case FlyCallStatus.rejected:
        callStatus("Call Declined");
      default:
        print("[MirrorFly] Unknown Call Status: $status");
    }
  }

  ///

  void callTimeOut() async {
    callStatus("Trying to timeout");
    toToast("Call Timeout");
    await handleTimeOutDisconnect();
    NavUtils.back();
  }

  void rejected() {
    toToast("Call Declined");
    NavUtils.back();
  }

  void ringing() {}
  void connecting() {
    callStatus("Connected");
    isOnGoingCallView();
  }

  void disconnect() {
    if (NavUtils.currentRoute == Routes.callKitOutGoingCallView) {
      callStatus("Disconnected");
      toToast("Call Disconnected");
      NavUtils.back();
    }
  }

  void isOnGoingCallView() async {
    isOnGoingCallViewEnable.value = true;
  }

  void isReadyIconEnable() async {
    print("[MirrorFly] isReadyIconEnable");
    isIconEnable.value = true;
  }

  Future<void> handleTimeOutDisconnect() async {
    await MirrorflyCallKit.liveKitCore.ops.disconnectCall();
  }

  void muteAudio() async {
    print("[MirrorFly] muteAudio start");

    // 1. Get current mic status
    // final bool isMicEnabled = await MirrorflyCallKit.getIsMicrophoneEnabled();
    // print("[MirrorFly] muteAudio existing mic enabled : $isMicEnabled");

    // 2. Toggle microphone
    MirrorflyCallKit.toggleMicrophone(result: (result) async {
      print("[MirrorFly] muteAudio toggleMicrophone result : $result");

      // 3. Update observable based on what mic will become
      if (result) {
        final bool isMicEnabled =
            await MirrorflyCallKit.getIsMicrophoneEnabled();
        print(
            "[MirrorFly] muteAudio failure toggleMicrophone isMicEnabled : $isMicEnabled");
        muted.value =
            !isMicEnabled; // if mic is enabled -> muted = false, if disabled -> muted = true
      } else {
        print(
            "[MirrorFly] muteAudio failure toggleMicrophone result : $result");
      }
    });
  }

  void videoMute() async {
    // videoMuted.value = !videoMuted.value;
    print("[MirrorFly] videoMute start");
    final bool isVideoMute = await MirrorflyCallKit.getIsCameraEnabled();
    print("[MirrorFly] existing isVideoMute status : $isVideoMute");
    MirrorflyCallKit.toggleMicrophone(result: (result) {
      print("[MirrorFly] toggleMicrophone result : $result");
    });
  }

  void switchCamera() async {
    // NavUtils.toNamed(Routes.callKitOnGoingCallView);
    print("[MirrorFly] switchCamera start");
    var pos = await MirrorflyCallKit.getCurrentCameraPosition();
    print("[MirrorFly] existing pos : $pos");
    MirrorflyCallKit.switchCameraPosition(result: (result) {
      print("[MirrorFly] switchCameraPosition result : $result");
    });
  }

  void changeSpeaker() {
    speakerOn.value = !speakerOn.value;
  }

  void localHangup() async {
    print("[MirrorFly]  disconnectCall invoked...");
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
        // you can show a snackbar or retry logic here
      }
    } catch (e, stack) {
      print("[MirrorFly]  Exception in disconnectCall: $e");
      print(stack);
    }
  }
}
