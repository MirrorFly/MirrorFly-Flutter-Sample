import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import '../data/utils.dart';
import '../routes/route_settings.dart';

class CallKitOutgoingCallController extends GetxController with GetTickerProviderStateMixin {
  /// Observables
  var callStatus = "Calling...".obs;
  var callType = "audio".obs; // "audio" or "video"
  var muted = false.obs;
  var videoMuted = false.obs;
  var speakerOn = false.obs;
  var users = <String?>[].obs;
  final RxBool cameraSwitch = false.obs;



  @override
  Future<void> onInit() async{
    // TODO: implement onInit
    if (NavUtils.arguments != null) {
      users.value = NavUtils.arguments?["userJid"] as List<String?>;
      cameraSwitch(NavUtils.arguments?["cameraSwitch"]);
    }
    super.onInit();
  }

  ///
  void updateCallStatus({required FlyCallStatus status}) {
    switch (status) {
      case FlyCallStatus.ringing:
       callStatus("Ringing");
      case FlyCallStatus.connecting:
        callStatus("Trying to connect");
      case FlyCallStatus.reconnecting:
        callStatus("Trying to reconnecting");
      case FlyCallStatus.connected:
      callStatus("Trying to connect");
      case FlyCallStatus.disconnected:
        callStatus("Disconnected");
      case FlyCallStatus.callTimeout:
        callStatus("Trying to timeout");
      default:
        print("[MirrorFly] Unknown Call Status: $status");
    }
  }

  ///
  void updateCallAction({required FlyCallStatus status}) async{
    if (status == FlyCallStatus.callTimeout) {
      toToast("Call Timeout");
      await handleTimeOutDisconnect();
      NavUtils.back();
    } else if (status == FlyCallStatus.disconnected) {
      toToast("Call Disconnected");
      NavUtils.back();
    }
  }

  Future<void> handleTimeOutDisconnect() async{
    await MirrorflyCallKit.liveKitCore.ops.disconnectCall();
  }

  void muteAudio() async {
    print("[MirrorFly] muteAudio start");

    // 1. Get current mic status
    final bool isMicEnabled = await MirrorflyCallKit.getIsMicrophoneEnabled();
    print("[MirrorFly] existing mic enabled : $isMicEnabled");

    // 2. Toggle microphone
    MirrorflyCallKit.toggleMicrophone(result: (result) {
      print("[MirrorFly] toggleMicrophone result : $result");

      // 3. Update observable based on what mic will become
      if (result) {
        muted.value = !result; // if mic is enabled -> muted = false, if disabled -> muted = true
      } else {
        // fallback in case result isn't bool
        muted.value = !isMicEnabled;
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

  void disconnectCall() async {
    print("[MirrorFly]  disconnectCall invoked...");

    try {
      var result = await MirrorflyCallKit.localHangup();
      print("[MirrorFly] localHangup() result: $result");

      if (result == true) {
        print("[MirrorFly]  Call disconnected successfully. Navigating back...");
        NavUtils.back();
      } else {
        print("[MirrorFly]  Call disconnect failed. Retrying or handling failure...");
        // you can show a snackbar or retry logic here
      }
    } catch (e, stack) {
      print("[MirrorFly]  Exception in disconnectCall: $e");
      print(stack);
    }
  }

}
