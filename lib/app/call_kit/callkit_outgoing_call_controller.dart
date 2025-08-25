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
    if (NavUtils.arguments != null) {
      users.value = NavUtils.arguments?["userJid"] as List<String?>;
      cameraSwitch(NavUtils.arguments?["cameraSwitch"]);
    }
    super.onInit();
  }

  void handleStatusStream(CallStatusEvent event) {
    callStatus.value = event.callStatus.name; // update observable
    print("📞 CallStatus: ${event.callStatus}, reason: ${event.reason}");

    if (event.callStatus.name.toLowerCase() == "connecting") {
      NavUtils.toNamed(Routes.callKitOnGoingCallView, arguments: {

      });
    }

  }

  void muteAudio() {
    muted.value = !muted.value;
  }

  void videoMute() {
    videoMuted.value = !videoMuted.value;
  }

  void switchCamera() {
  }

  void changeSpeaker() {
    speakerOn.value = !speakerOn.value;
  }

  void disconnectCall() {
  }
}
