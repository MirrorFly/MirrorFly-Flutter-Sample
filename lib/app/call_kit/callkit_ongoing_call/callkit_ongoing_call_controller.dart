import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/routes/route_settings.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import '../../data/utils.dart';

class CallKitOnGoingCallController extends GetxController with GetTickerProviderStateMixin{
  /// Observables
  var callStatus = "Ongoing Call".obs;
  var callTimer = "00:00".obs;
  var callType = "audio".obs; // "audio" or "video"
  var muted = false.obs;
  var videoMuted = false.obs;
  var speakerOn = false.obs;
  var pinnedUserJid = "".obs;
  var layoutSwitch = false.obs;
  var users = <String?>[].obs;
  final RxBool cameraSwitch = false.obs;




  /// 🔹 Placeholder methods
  void muteAudio() {
    muted.value = !muted.value;
  }

  void videoMute() {
    videoMuted.value = !videoMuted.value;
  }

  void switchCamera() {
    // TODO: switch camera
  }

  void changeSpeaker() {
    speakerOn.value = !speakerOn.value;
  }

  void disconnectCall() {
    NavUtils.back();
    NavUtils.back();
    // TODO: end call
  }

  void goToPIP() {
    // TODO: handle Picture-in-Picture
  }

  void changeLayout() {
    layoutSwitch.value = !layoutSwitch.value;
  }

  void openParticipantScreen() {
    // TODO: show participants
  }
}
