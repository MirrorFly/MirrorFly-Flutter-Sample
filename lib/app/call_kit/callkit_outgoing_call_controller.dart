import 'package:get/get.dart';
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
    // if (NavUtils.arguments != null) {
    //   users.value = NavUtils.arguments?["userJid"] as List<String?>;
    //   cameraSwitch(NavUtils.arguments?["cameraSwitch"]);
    // }
    // FlyCallUpdates.instance.statusStream.listen((event) {
    //   callStatus.value = event.callStatus.name; // update observable
    //   print("📞 CallStatus: ${event.callStatus}, reason: ${event.reason}");
    // });
    super.onInit();
  }

  void handleStatusStream(CallStatusEvent event) {
    callStatus.value = event.callStatus.name; // update observable
    print("📞 CallStatus: ${event.callStatus}, reason: ${event.reason}");

    if (event.callStatus.name.toLowerCase() == "connecting") {
      NavUtils.toNamed(Routes.callKitOnGoingCallView, arguments: {

      });
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
