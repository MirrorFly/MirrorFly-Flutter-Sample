import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/model/call_user_list.dart';
import 'package:mirrorfly_chat/flychat.dart';
import 'package:mirrorfly_chat/model/profile_model.dart';

class CallController extends GetxController {

  final RxBool isVisible = false.obs;
  final RxBool muted = false.obs;
  final RxBool speakerOff = true.obs;
  final RxBool cameraSwitch = true.obs;
  final RxBool videoMuted = false.obs;
  final RxBool layoutSwitch = true.obs;

  var callTimer = '00:00'.obs;

  DateTime? startTime;

  var callList = List<CallUserList>.empty(growable: true).obs;

  var callTitle = "";

  var callType = "".obs;

  var calleeName = "".obs;
  var callStatus = "".obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    debugPrint("#Mirrorfly Call Controller onInit");
    await Mirrorfly.getCallDirection().then((value) async {
      debugPrint("#Mirrorfly Call Direction $value");
      if(value == "Incoming"){
        Mirrorfly.getCallUsersList().then((value) {
          // [{"userJid":"919789482015@xmpp-uikit-qa.contus.us","callStatus":"Trying to Connect"},{"userJid":"919894940560@xmpp-uikit-qa.contus.us","callStatus":"Trying to Connect"},{"userJid":"917010279986@xmpp-uikit-qa.contus.us","callStatus":"Connected"}]
          debugPrint("#Mirrorfly call get users --> $value");
          final callUserList = callUserListFromJson(value);
          callList.addAll(callUserList);
          getNames();
        });
      }else{
        debugPrint("#Mirrorfly Call Direction outgoing");
        var userJid = Get.arguments["userJid"];
        debugPrint("#Mirrorfly Call UserJid $userJid");
        var profile = await Mirrorfly.getUserProfile(userJid);
        var data = profileDataFromJson(profile);
        calleeName(data.data?.name);
      }
    });

    await Mirrorfly.getCallType().then((value) => callType(value));

    debugPrint("#Mirrorfly call type ${callType.value}");
    if(callType.value == 'audio'){
      videoMuted(true);
    }else{
      videoMuted(false);
    }

  }

  muteAudio() async {
    debugPrint("#Mirrorfly muteAudio ${muted.value}");
    await Mirrorfly.muteAudio(!muted.value).then((value) => debugPrint("#Mirrorfly Mute Audio Response $value"));
    muted(!muted.value);
  }

  changeSpeaker() {
    speakerOff(!speakerOff.value);
  }

  videoMute(){
    if(callType.value != 'audio') {
      videoMuted(!videoMuted.value);
    }
  }

  switchCamera() async {
    cameraSwitch(!cameraSwitch.value);
    await Mirrorfly.switchCamera();
  }

  void showCallOptions() {
    isVisible(true);
  }

  void changeLayout() {
    layoutSwitch(!layoutSwitch.value);
  }

  Future<void> declineCall() async {
    Mirrorfly.declineCall();
    callList.clear();
    Get.back();
  }

  getNames() async {
    startTimer();
    for (var users in callList) {
      var profile = await Mirrorfly.getUserProfile(users.userJid!);
      var data = profileDataFromJson(profile);
      var userName = data.data?.name;
      callTitle = "$callTitle ${userName!} & ";
    }
  }
  void startTimer() {
    const oneSec = Duration(seconds: 1);
    startTime = DateTime.now();
    Timer.periodic(
      oneSec,
          (Timer timer) {
        final minDur = DateTime.now().difference(startTime!).inMinutes;
        final secDur = DateTime.now().difference(startTime!).inSeconds % 60;
        String min = minDur < 10 ? "0$minDur" : minDur.toString();
        String sec = secDur < 10 ? "0$secDur" : secDur.toString();
        callTimer("$min:$sec");
      },
    );
  }

  String getTimer() {
    return "02:00";
  }

  void callDisconnected(String callMode, String userJid, String callType, String callStatus) {
    var index = callList.indexWhere((user) => user.userJid == userJid);
    debugPrint("#Mirrorfly call disconnected user Index $index");
    if (!index.isNegative) {
      callList.removeAt(index);
    } else {
      debugPrint("#Mirrorflycall participant jid is not in the list");
    }
    if (callList.length == 1) {
      callList.clear();
      Mirrorfly.declineCall();
      Get.back();
    }
  }

  void calling(String callMode, String userJid, String callType, String callStatus) {
    this.callStatus(callStatus);
  }

  void reconnected(String callMode, String userJid, String callType, String callStatus) {
    this.callStatus(callStatus);

  }

  void ringing(String callMode, String userJid, String callType, String callStatus) {

    this.callStatus(callStatus);
  }

  void onHold(String callMode, String userJid, String callType, String callStatus) {

    this.callStatus(callStatus);
  }

  void connected(String callMode, String userJid, String callType, String callStatus) {
    this.callStatus(callStatus);

  }

}