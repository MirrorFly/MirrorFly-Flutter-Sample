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
        final bool isMicEnabled = await MirrorflyCallKit.getIsMicrophoneEnabled();
        print("[MirrorFly] muteAudio failure toggleMicrophone isMicEnabled : $isMicEnabled");
        muted.value = !isMicEnabled; // if mic is enabled -> muted = false, if disabled -> muted = true
      } else {
        print("[MirrorFly] muteAudio failure toggleMicrophone result : $result");
      }
    });
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

  void disconnectCall() async {
    print("[MirrorFly]  disconnectCall invoked...");
    try {
      var result = await MirrorflyCallKit.localHangup();
      print("[MirrorFly] localHangup() result: $result");

      if (result == true) {
        print("[MirrorFly]  Call disconnected successfully. Navigating back...");
        NavUtils.back();
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
