import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/model/call_user_list.dart';
import 'package:mirrorfly_chat/flychat.dart';

class CallController extends GetxController {

  final RxBool isVisible = false.obs;
  final RxBool muted = false.obs;
  final RxBool speakerOff = true.obs;
  final RxBool cameraSwitch = true.obs;
  final RxBool videoMuted = false.obs;
  final RxBool layoutSwitch = true.obs;

  var callList = List<CallUserList>.empty(growable: true).obs;

  @override
  void onInit(){
    super.onInit();
    Mirrorfly.getCallUsersList().then((value) {
      // [{"userJid":"919789482015@xmpp-uikit-qa.contus.us","callStatus":"Trying to Connect"},{"userJid":"919894940560@xmpp-uikit-qa.contus.us","callStatus":"Trying to Connect"},{"userJid":"917010279986@xmpp-uikit-qa.contus.us","callStatus":"Connected"}]
      debugPrint("#Mirrorfly call get users --> $value");
      final callUserList = callUserListFromJson(value);
      callList.addAll(callUserList);
    });
  }

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