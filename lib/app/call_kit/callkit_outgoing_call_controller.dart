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
  void updateCallAction({required FlyCallStatus status}) {
    if (status == FlyCallStatus.callTimeout) {
      toToast("Call Timeout");
      NavUtils.back();
    } else if (status == FlyCallStatus.disconnected) {
      toToast("Call Disconnected");
      NavUtils.back();
    }
  }

  void muteAudio() async {
    // muted.value = !muted.value;
    print("[MirrorFly] muteAudio start");
    final bool isMuted = await MirrorflyCallKit.getIsMicrophoneEnabled();
    print("[MirrorFly] existing mute status : $isMuted");
    MirrorflyCallKit.toggleMicrophone(result: (result) {
      print("[MirrorFly] toggleMicrophone result : $result");
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

  void disconnectCall() {
  }
}
