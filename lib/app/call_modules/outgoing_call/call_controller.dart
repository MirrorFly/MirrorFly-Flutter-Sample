import 'package:get/get.dart';

class CallController extends GetxController {

  final RxBool isVisible = false.obs;
  final RxBool muted = false.obs;
  final RxBool speakerOff = true.obs;
  final RxBool cameraSwitch = true.obs;
  final RxBool videoMuted = false.obs;
  final RxBool layoutSwitch = false.obs;

  muteAudio() {
    muted(!muted.value);
  }

  changeSpeaker() {
    speakerOff(!speakerOff.value);
  }

  videoMute(){
    videoMuted(!videoMuted.value);
  }

  switchCamera() {
    cameraSwitch(!cameraSwitch.value);
  }

  void showCallOptions() {
    isVisible(true);
  }

  void changeLayout() {
    layoutSwitch(!layoutSwitch.value);
  }

  void declineCall() {}
}