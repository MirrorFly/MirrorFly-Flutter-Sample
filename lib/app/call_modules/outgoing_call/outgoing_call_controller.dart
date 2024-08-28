import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../call_modules/call_utils.dart';
import '../../common/app_localizations.dart';
import '../../common/constants.dart';
import '../../data/helper.dart';
import '../../extensions/extensions.dart';
import '../../model/call_user_list.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import '../../data/permissions.dart';
import '../../data/session_management.dart';
import '../../data/utils.dart';
import '../../routes/route_settings.dart';

class OutgoingCallController extends GetxController with GetTickerProviderStateMixin {
  final RxBool isVisible = true.obs;
  final RxBool muted = false.obs;
  final RxBool speakerOff = true.obs;
  final RxBool cameraSwitch = false.obs;
  final RxBool videoMuted = false.obs;
  final RxBool layoutSwitch = true.obs;
  final RxDouble swapViewHeight = 135.0.obs;

  late RxDouble publisherHeight = 0.0.obs;
  late RxDouble publisherWidth = 0.0.obs;

  RxDouble subscriberHeight = 135.0.obs;
  RxDouble subscriberWidth = 100.0.obs;

  final RxBool isSwapped = false.obs;




  var callTimer = '00:00'.obs;

  DateTime? startTime;

  var callList = List<CallUserList>.empty(growable: true).obs;
  var availableAudioList = List<AudioDevices>.empty(growable: true).obs;

  var callTitle = "".obs;

  var callMode = "".obs;
  get isOneToOneCall => callList.length <= 2;//callMode.value == CallMode.oneToOne;
  get isGroupCall => callList.length > 2;//callMode.value == CallMode.groupCall;

  var callType = "".obs;
  get isAudioCall => callType.value == CallType.audio;
  get isVideoCall => callType.value == CallType.video;

  // Rx<Profile> profile = Profile().obs;
  var calleeName = "".obs;
  var audioOutputType = "receiver".obs;
  var callStatus = CallStatus.calling.obs;

  // var userJID = <String>[].obs;

  bool isCallTimerEnabled = false;

  var users = <String?>[].obs;
  var groupId = ''.obs;

  var getMaxCallUsersCount = 8;

  @override
  Future<void> onInit() async {
    super.onInit();
    enterFullScreen();
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    debugPrint("#Mirrorfly Call outgoing Controller onInit");

    isCallTimerEnabled = true;
    if (NavUtils.arguments != null) {
      users.value = NavUtils.arguments?["userJid"] as List<String?>;
      cameraSwitch(NavUtils.arguments?["cameraSwitch"]);
    }




    WidgetsBinding.instance.addPostFrameCallback((_) async {

      await Mirrorfly.getCallUsersList().then((value) {
        // [{"userJid":"919789482015@xmpp-uikit-qa.contus.us","callStatus":"Trying to Connect"},{"userJid":"919894940560@xmpp-uikit-qa.contus.us","callStatus":"Trying to Connect"},{"userJid":"917010279986@xmpp-uikit-qa.contus.us","callStatus":"Connected"}]
        debugPrint("#Mirrorfly call get users --> $value");
        final callUserList = callUserListFromJson(value);
        callList(callUserList);
        callStatus(callUserList.first.callStatus?.value);
      });
      debugPrint("#Mirrorfly call type ${callType.value}");

      groupId(await Mirrorfly.getCallGroupJid());

      audioDeviceChanged();
      getAudioDevices();

      if (callType.value == CallType.audio) {
        Mirrorfly.isUserAudioMuted().then((value) => muted(value));
        videoMuted(true);
      } else {
        Mirrorfly.isUserAudioMuted().then((value) => muted(value));
        Mirrorfly.isUserVideoMuted().then((value) => videoMuted(value));
        // videoMuted(false);
      }
    });

    Future.delayed(const Duration(milliseconds: 500), () async {
      await Mirrorfly.getCallType().then((value) => callType(value));
    });

  }

  muteAudio() async {
    debugPrint("#Mirrorfly muteAudio ${muted.value}");
    await Mirrorfly.muteAudio(status: !muted.value, flyCallBack: (FlyResponse response) {
      debugPrint("#Mirrorfly Mute Audio Response ${response.isSuccess}.");
    });
    muted(!muted.value);
    var callUserIndex = callList.indexWhere((element) => element.userJid!.value == SessionManagement.getUserJID());
    if(!callUserIndex.isNegative) {
      callList[callUserIndex].isAudioMuted(muted.value);
    }
  }

  changeSpeaker() {
    // speakerOff(!speakerOff.value);
    debugPrint("availableAudioList.length ${availableAudioList.length}");
    //if connected other audio devices
    // if (availableAudioList.length > 2) {
    DialogUtils.createDialog(
      Dialog(
        child: Obx(() {
          return ListView.builder(
              shrinkWrap: true,
              itemCount: availableAudioList.length,
              itemBuilder: (context, index) {
                var audioItem = availableAudioList[index];
                debugPrint("audio item name ${audioItem.name}");
                return Obx(() {
                  return ListTile(
                    contentPadding: const EdgeInsets.only(left: 10),
                    title: Text(audioItem.name ?? "", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
                    trailing: audioItem.type == audioOutputType.value
                        ? const Icon(
                      Icons.check_outlined,
                      color: Colors.green,
                    )
                        : const SizedBox.shrink(),
                    onTap: () {
                      if (audioOutputType.value != audioItem.type) {
                        NavUtils.back();
                        debugPrint("selected audio item ${audioItem.type}");
                        audioOutputType(audioItem.type);
                        Mirrorfly.routeAudioTo(routeType: audioItem.type ?? "");
                      } else {
                        LogMessage.d("routeAudioOption", "clicked on same audio type selected");
                      }
                    },
                  );
                });
              });
        }),
      ),
    );
  }

  videoMute() async {
    debugPrint("isOneToOneCall : $isOneToOneCall");
    if (await AppPermission.askVideoCallPermissions()) {
      if (callType.value != CallType.audio) {
        Mirrorfly.muteVideo(status: !videoMuted.value, flyCallBack: (_) {  });
        videoMuted(!videoMuted.value);
      } else if (callType.value == CallType.audio && isOneToOneCall && NavUtils.currentRoute == Routes.onGoingCallView) {
        // showVideoSwitchPopup();
      } else if (isGroupCall) {
        Mirrorfly.muteVideo(status: !videoMuted.value, flyCallBack: (_) {  },);
        videoMuted(!videoMuted.value);
      }
    }
  }

  switchCamera() async {
    //The below code is commented. The Camera switch not worked in iOS so uncommented and Nested in Platform Check
    if(Platform.isIOS) {
      cameraSwitch(!cameraSwitch.value);
    }
    await Mirrorfly.switchCamera();
  }

  void disconnectCall() {
    // BaseController baseController = ConcreteController();
    // baseController.stopTimer();
    isCallTimerEnabled = false;
    callTimer("Disconnected");
    if (callList.isNotEmpty) {
      callList.clear();
    }
    Mirrorfly.disconnectCall(flyCallBack: (FlyResponse response) {
      debugPrint("#Disconnect call disconnect value ${response.isSuccess}");
      if (response.isSuccess) {
        debugPrint("#Disconnect call disconnect list size ${callList.length}");
        // backCalledFromDisconnect();
      }
    });
  }


  @override
  void dispose() {
    exitFullScreen();
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,overlays: SystemUiOverlay.values);
    LogMessage.d("callController", " callController dispose");
    super.dispose();
  }

  @override
  void onClose() {
    LogMessage.d("callController", " callController onClose");
    super.onClose();
  }

  void userDisconnection(String callMode, String userJid, String callType) {
    this.callMode(callMode);
    this.callType(callType);
    debugPrint("Current Route ${NavUtils.currentRoute}");
    if(NavUtils.currentRoute == Routes.outGoingCallView && callList.length < 2){
      NavUtils.back();
    }
  }

  Future<void> remoteBusy(String callMode, String userJid, String callType, String callAction) async {

    if (callList.length > 2) {
      var data = await getProfileDetails(userJid);
      toToast(getTranslated("usernameIsBusy").replaceFirst("%d", data.getName()));
    } else {
      toToast(getTranslated("userIsBusy"));
    }

    this.callMode(callMode);
    this.callType(callType);
    debugPrint("onCallAction CallList Length ${callList.length}");
    if(callList.length < 2){
      disconnectOutgoingCall();
    }else{
      removeUser(callMode, userJid, callType);
    }

  }

  Future<void> remoteOtherBusy(String callMode, String userJid, String callType, String callAction) async {
    // this.callMode(callMode);
    //remove the user from the list and update ui
    // users.remove(userJid);//out going call view
    remoteBusy(callMode, userJid, callType, callAction);
  }

  void localHangup(String callMode, String userJid, String callType, String callAction) {
    this.callMode(callMode);
    userDisconnection(callMode, userJid, callType);
  }

  Future<void> connected(String callMode, String userJid, String callType, String callStatus) async {
    this.callMode(callMode);
    this.callType(callType);
    // this.callStatus(callStatus);
    // startTimer();
    if(NavUtils.currentRoute != Routes.onGoingCallView && NavUtils.currentRoute != Routes.participants) {
      Future.delayed(const Duration(milliseconds: 500), () {
        NavUtils.offNamed(Routes.onGoingCallView, arguments: {"userJid": [userJid], "cameraSwitch": cameraSwitch.value});
      });
    }
  }

  void timeout(String callMode, String userJid, String callType, String callStatus) {
    this.callMode(callMode);
    this.callType(callType);
    debugPrint("#Mirrorfly Call timeout callMode : $callMode -- userJid : $userJid -- callType $callType -- callStatus $callStatus -- current route ${NavUtils.currentRoute}");
    if(NavUtils.currentRoute==Routes.outGoingCallView) {
      debugPrint("#Mirrorfly Call navigating to Call Timeout");
      NavUtils.offNamed(Routes.callTimeOutView,
          arguments: {"callType": callType, "callMode": callMode, "userJid": users, "calleeName": calleeName.value});
    }
  }

  void disconnectOutgoingCall() {
    isCallTimerEnabled = false;
    Mirrorfly.disconnectCall(flyCallBack: (FlyResponse response) {
      if(response.isSuccess) {
        callList.clear();
        NavUtils.back();
      }
    });
  }

  void statusUpdate(String userJid, String callStatus) {
    debugPrint("statusUpdate $callStatus");
    // var displayStatus = CallStatus.calling;
    var displayStatus = "";
    switch (callStatus) {
      case CallStatus.connected:
        displayStatus = CallStatus.connected;
        break;
      case CallStatus.connecting:
      case CallStatus.ringing:
        displayStatus = CallStatus.ringing;
        break;
      case CallStatus.callTimeout:
        displayStatus = "Unavailable, Try again later";
        break;
      case CallStatus.disconnected:
      case CallStatus.calling:
        displayStatus = callStatus;
        break;
      case CallStatus.onHold:
        displayStatus = CallStatus.onHold;
        break;
      case CallStatus.attended:
        break;
      case CallStatus.inviteCallTimeout:
        displayStatus = CallStatus.callTimeout;
        break;
      case CallStatus.reconnecting:
        displayStatus = "Reconnecting…";
        break;
      case CallStatus.onResume:
        displayStatus = "Call on Resume";
        break;
      case CallStatus.userJoined:
      case CallStatus.userLeft:
      case CallStatus.reconnected:
        displayStatus = '';
        break;
      case CallStatus.calling10s:
      case CallStatus.callingAfter10s:
        displayStatus = callStatus;
        break;
      default:
        displayStatus = '';
        break;
    }
    /*if(pinnedUserJid.value == userJid && isGroupCall) {
      this.callStatus(displayStatus);
    }else */
    if (isOneToOneCall || callStatus == CallStatus.ringing){
      this.callStatus(displayStatus);
    }else{
      debugPrint("isOneToOneCall $isOneToOneCall");
      debugPrint("isGroupCall $isGroupCall");
      debugPrint("Status is not updated");
    }
  }

  void audioDeviceChanged() {
    getAudioDevices();
    Mirrorfly.selectedAudioDevice().then((value) => audioOutputType(value));
  }

  void getAudioDevices() {
    Mirrorfly.getAllAvailableAudioInput().then((value) {
      final availableList = audioDevicesFromJson(value);
      availableAudioList(availableList);
      debugPrint("Mirrorfly flutter getAllAvailableAudioInput $availableList");
    });
  }

  Future<void> remoteEngaged(String userJid, String callMode, String callType) async {

    var data = await getProfileDetails(userJid);
    toToast(getTranslated("remoteEngagedToast").replaceFirst("%d", data.getName()));

    debugPrint("***call list length ${callList.length}");
//The below condition (<= 2) -> (<2) is changed for Group call, to maintain the call to continue if there is a 2 users in call
    if(callList.length < 2){
      disconnectOutgoingCall();
    }else{
      removeUser(callMode, userJid, callType);
    }
  }

  void audioMuteStatusChanged(String muteEvent, String userJid) {
    var callUserIndex = callList.indexWhere((element) => element.userJid!.value == userJid);
    if (!callUserIndex.isNegative) {
      debugPrint("index $callUserIndex");
      callList[callUserIndex].isAudioMuted(muteEvent == MuteStatus.remoteAudioMute);
    } else {
      debugPrint("#Mirrorfly call User Not Found in list to mute the status");
    }
  }

  void videoMuteStatusChanged(String muteEvent, String userJid) {
    var callUserIndex = callList.indexWhere((element) => element.userJid!.value == userJid);
    if (!callUserIndex.isNegative) {
      debugPrint("index $callUserIndex");
      callList[callUserIndex].isVideoMuted(muteEvent == MuteStatus.remoteVideoMute);
    } else {
      debugPrint("#Mirrorfly call User Not Found in list to video mute the status");
    }
  }

  var speakingUsers = <SpeakingUsers>[].obs;
  void onUserSpeaking(String userJid, int audioLevel) {
    // LogMessage.d("speakingUsers", "${speakingUsers.length}");
    var index = speakingUsers.indexWhere((element) => element.userJid.toString() == userJid.toString());
    // LogMessage.d("speakingUsers indexWhere", "$index");
    if (index.isNegative) {
      speakingUsers.add(SpeakingUsers(userJid: userJid, audioLevel: audioLevel.obs));
      // LogMessage.d("speakingUsers", "added");
    } else {
      speakingUsers[index].audioLevel(audioLevel);
      // LogMessage.d("speakingUsers", "updated");
    }
  }

  void onUserStoppedSpeaking(String userJid) {
    //adding delay to show better ui
    Future.delayed(const Duration(milliseconds: 300), () {
      var index = speakingUsers.indexWhere((element) => element.userJid == userJid);
      if (!index.isNegative) {
        speakingUsers[index].audioLevel(0);
      }
    });
  }

  void denyCall() {
    LogMessage.d("denyCall", NavUtils.currentRoute);
    if (NavUtils.currentRoute == Routes.outGoingCallView) {
      NavUtils.back();
    }
  }

  void onCameraSwitch() {
    LogMessage.d("onCameraSwitch", cameraSwitch.value);
    cameraSwitch(!cameraSwitch.value);
  }

  void changedToAudioCall() {
    callType(CallType.audio);
    videoMuted(true);
  }

  void onUserLeft(String callMode, String userJid, String callType) {
    if(callList.length>2 && !callList.indexWhere((element) => element.userJid.toString() == userJid.toString()).isNegative) { //#FLUTTER-1300
      CallUtils.getNameOfJid(userJid).then((value) => toToast(getTranslated("userLeftOnCall").replaceFirst("%d", value)));
    }
    removeUser(callMode, userJid, callType);
  }
  void removeUser(String callMode, String userJid, String callType){
    this.callType(callType);
    debugPrint("before removeUser ${callList.length}");
    debugPrint("before removeUser index ${callList.indexWhere((element) => element.userJid!.value == userJid)}");
    callList.removeWhere((element){
      debugPrint("removeUser callStatus ${element.callStatus}");
      return element.userJid!.value == userJid;
    });
    users.removeWhere((element) => element == userJid);
    speakingUsers.removeWhere((element) => element.userJid == userJid);
    debugPrint("after removeUser ${callList.length}");
    debugPrint("removeUser ${callList.indexWhere((element) => element.userJid.toString() == userJid)}");
    /*if(callList.length>1 && pinnedUserJid.value == userJid) {
      pinnedUserJid(callList[0].userJid!.value);
    }*/
    userDisconnection(callMode, userJid, callType);
    // getNames();

  }

  void userUpdatedHisProfile(String jid){
    updateProfile(jid);
  }

  Future<void> updateProfile(String jid) async {
    if (jid.isNotEmpty) {
      var callListIndex = callList.indexWhere((element) => element.userJid!.value == jid);
      var usersIndex = users.indexWhere((element) => element == jid);
      if(!usersIndex.isNegative){
        users[usersIndex]=("");
        users[usersIndex]=(jid);
      }
      if (!callListIndex.isNegative) {
        callList[callListIndex].userJid!("");
        callList[callListIndex].userJid!(jid);
        // callList.refresh();
        // getNames();
      }
    }
  }

  void enterFullScreen() {
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  void exitFullScreen() {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

}