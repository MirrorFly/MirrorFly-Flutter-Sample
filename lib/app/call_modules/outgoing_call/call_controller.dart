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

import '../../app_style_config.dart';
import '../../data/permissions.dart';
import '../../data/session_management.dart';
import '../../data/utils.dart';
import '../../routes/route_settings.dart';

class CallController extends GetxController with GetTickerProviderStateMixin {
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

  var pinnedUserJid = ''.obs;
  var pinnedUser = CallUserList(isAudioMuted: false, isVideoMuted: false).obs;

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

  late Completer<void> waitingCompleter;
  bool isWaitingCanceled = false;
  bool isVideoCallRequested = false;
  bool isCallTimerEnabled = false;

  var users = <String?>[].obs;
  var groupId = ''.obs;

  TabController? tabController ;
  var getMaxCallUsersCount = 8;

  var joinViaLink = false;
  @override
  Future<void> onInit() async {
    super.onInit();
    enterFullScreen();
    tabController = TabController(length: 2, vsync: this);
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    debugPrint("#Mirrorfly Call Controller onInit");
    groupId(await Mirrorfly.getCallGroupJid());
    isCallTimerEnabled = true;
    if (NavUtils.arguments != null) {
      users.value = NavUtils.arguments?["userJid"] as List<String?>;
      cameraSwitch(NavUtils.arguments?["cameraSwitch"] ?? false);
      joinViaLink = NavUtils.arguments?["joinViaLink"] ?? false;
    }
    // await outGoingUsers();
    // callType.value = NavUtils.arguments["callType"];
    if (users.isNotEmpty) {
      debugPrint("#Mirrorfly Call UserJid $users");
      // var profile = await Mirrorfly.getUserProfile(userJid);
      // var data = profileDataFromJson(profile);
      // if(users.length==1) {
      //   var data = await getProfileDetails(users[0]);
        // profile(data);
        // calleeName(data.getName());
      // }
    }
    audioDeviceChanged();
    if (NavUtils.currentRoute == Routes.onGoingCallView) {
      //startTimer();
    }
    getAudioDevices();
    await Mirrorfly.getCallDirection().then((value) async {
      debugPrint("#Mirrorfly Call Direction $value");
    });
    Mirrorfly.getCallUsersList().then((value) {
      // [{"userJid":"919789482015@xmpp-uikit-qa.contus.us","callStatus":"Trying to Connect"},{"userJid":"919894940560@xmpp-uikit-qa.contus.us","callStatus":"Trying to Connect"},{"userJid":"917010279986@xmpp-uikit-qa.contus.us","callStatus":"Connected"}]
      debugPrint("#Mirrorfly call get users --> $value");
      final callUserList = callUserListFromJson(value);
      callList(callUserList);
      users(List.from(callUserList.map((e) => e.userJid!.value)));
      if(callUserList.length > 1) {
        // pinnedUserJid(callUserList[0].userJid);
        CallUserList firstAttendedCallUser = callUserList.firstWhere((callUser) => callUser.callStatus?.value == CallStatus.attended || callUser.callStatus?.value == CallStatus.connected, orElse: () => callUserList[0]);
        pinnedUserJid(firstAttendedCallUser.userJid!.value);
        pinnedUser(firstAttendedCallUser);
      }else if(joinViaLink){
        pinnedUserJid(callUserList.first.userJid!.value);
        pinnedUser(callUserList.first);
      }
    });

    await Mirrorfly.getCallType().then((value) => callType(value));

    debugPrint("#Mirrorfly call type ${callType.value}");
    if (callType.value == 'audio') {
      Mirrorfly.isUserAudioMuted().then((value) => muted(value));
      videoMuted(true);
    } else {
      Mirrorfly.isUserAudioMuted().then((value) => muted(value));
      Mirrorfly.isUserVideoMuted().then((value) => videoMuted(value));
      // videoMuted(false);
    }

    ever(callList, (callback) {
      debugPrint("#Mirrorfly call list is changed ******");
      debugPrint("#Mirrorfly call list ${callUserListToJson(callList)}");
      if (pinnedUserJid.isEmpty){
        CallUserList firstAttendedCallUser = callList.firstWhere((callUser) => callUser.callStatus?.value == CallStatus.attended || callUser.callStatus?.value == CallStatus.connected || callUser.callStatus?.value == CallStatus.ringing, orElse: () => callList[0]);
        pinnedUserJid(firstAttendedCallUser.userJid!.value);
      }
    });
  }

  var calleeNames = <String>[].obs;
  Future outGoingUsers() async {
    debugPrint("outGoingUsers $users");
    calleeNames();
    if(users.length>1){
      for (var value in users) {
        if(value!=null) {
          var data = await getProfileDetails(value);
          calleeNames.add(data.getName());
        }
      }
    }else{
      if(users.isNotEmpty && users[0]!=null){
        var data = await getProfileDetails(users[0]!);
        calleeNames.add(data.getName());
      }
    }
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
    // }else{
    //   //speaker or ear-piece option only available then change accordingly
    //   var speaker = availableAudioList[0];
    //   var earPiece = availableAudioList[1];
    //   //check already audio route is speaker or not
    //   if(audioOutputType.value == speaker.type){
    //     debugPrint("selected audio item ${earPiece.type}");
    //     audioOutputType(earPiece.type);
    //     Mirrorfly.routeAudioTo(routeType: earPiece.type ?? "");
    //   }else{
    //     debugPrint("selected audio item ${speaker.type}");
    //     audioOutputType(speaker.type);
    //     Mirrorfly.routeAudioTo(routeType: speaker.type ?? "");
    //   }
    // }
  }

  videoMute() async {
    debugPrint("isOneToOneCall : $isOneToOneCall");
    if (await AppPermission.askVideoCallPermissions()) {
      if (callType.value != CallType.audio || joinViaLink) {
        Mirrorfly.muteVideo(status: !videoMuted.value, flyCallBack: (_) {  });
        videoMuted(!videoMuted.value);
      } else if (callType.value == CallType.audio && isOneToOneCall && NavUtils.currentRoute == Routes.onGoingCallView) {
        showVideoSwitchPopup();
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

  void showCallOptions() {
    isVisible(true);
  }

  void changeLayout() {
    layoutSwitch(!layoutSwitch.value);
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

  void backCalledFromDisconnect(){
    if (NavUtils.previousRoute.isNotEmpty) {
      debugPrint("#Disconnect previous route is not empty");
      if (NavUtils.currentRoute == Routes.onGoingCallView) {
        debugPrint("#Disconnect current route is ongoing call view");
        // Future.delayed(const Duration(seconds: 1), () {
        //   debugPrint("#Disconnect call controller back called from Ongoing Screen");
          NavUtils.back();
        // });
      }else if(NavUtils.currentRoute == Routes.participants){
        NavUtils.back();
        // Future.delayed(const Duration(seconds: 1), () {
          debugPrint("#Disconnect call controller back called from Participant Screen");
          NavUtils.back();
        // });
      }else if(NavUtils.currentRoute == Routes.outGoingCallView){
        NavUtils.back();
      }
    } else {
      debugPrint("#Disconnect previous route is empty");
      // NavUtils.offNamed(getInitialRoute());
      NavUtils.offNamed(NavUtils.defaultRouteName);
    }
  }

  /*Future<void> getNames() async {
    //Need to check Call Mode and update the name for group call here
    callTitle('');
    if(groupId.isEmpty) {
      var userJids = List<String>.from(callList.where((p0) => p0.userJid!=null && SessionManagement.getUserJID() != p0.userJid!.value).map((e) => e.userJid!.value));//<String>[];
      // for (var element in callList) {
      //   if(element.userJid!=null && SessionManagement.getUserJID() != element.userJid!.value) {
      //     userJids.add(element.userJid!.value);
      //   }}
      LogMessage.d("callList users", userJids);
      var names = userJids.isNotEmpty ? await CallUtils.getCallersName(userJids,true) : "";
      LogMessage.d("callList users names", names);
      callTitle(names);
      callTitle.refresh();
      *//*callList.asMap().forEach((index, users) async {
        LogMessage.d("callList", "$index ${users.userJid}");
        if (users.userJid == SessionManagement.getUserJID()) {
          callTitle("${callTitle.value} You,");
        } else {
          var profile = await getProfileDetails(users.userJid!);
          var userName = profile.name;
          callTitle("${callTitle.value} ${userName!}");
          if (callList.length > 2 && index == 0) {
            callTitle("${callTitle.value} and ");
          } else if (callList.length > 2 && index < callList.length - 1) {
            callTitle("${callTitle.value} ,");
          }
        }
        LogMessage.d("callList", callTitle.value);
      });*//*
    }else{
      callTitle((await getProfileDetails(groupId.value)).getName());
    }
  }*/

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
    if(NavUtils.currentRoute == Routes.outGoingCallView){
      // This if condition is added for the group call remote busy - call action
      if(callList.length < 2){
        NavUtils.back();
      }
      return;
    }
    debugPrint("#Mirrorfly call call disconnect called ${callList.length} userJid to remove $userJid");
    debugPrint("#Mirrorfly call call disconnect called ${callUserListToJson(callList)}");
    // if (callList.isEmpty) {
    //   debugPrint("call list is empty returning");
    //   return;
    // }
    debugPrint("call list is not empty");
    var index = callList.indexWhere((user) => user.userJid!.value == userJid);
    debugPrint("#Mirrorfly call disconnected user Index $index ${NavUtils.currentRoute}");
    if (!index.isNegative) {
      // callList.removeAt(index);
      callList.removeWhere((callUser) => callUser.userJid?.value == userJid);
    } else {
      debugPrint("#Mirrorflycall participant jid is not in the list");
    }
    // debugPrint("#Mirrorfly call call disconnect called after user removed ${callList.length}");
    if (callList.length <= 1 || userJid == SessionManagement.getUserJID()) {
      debugPrint("Entering Call Disconnection Loop");
      isCallTimerEnabled = false;
      //if user is in the participants screen all users end the call then we should close call pages
      if(NavUtils.currentRoute == Routes.participants){
        NavUtils.back();
      }

      if (NavUtils.previousRoute.isNotEmpty) {
        if (NavUtils.currentRoute == Routes.onGoingCallView) {
          callTimer("Disconnected");
          Future.delayed(const Duration(seconds: 1), () {
            NavUtils.back();
          });
        } else if(NavUtils.currentRoute == Routes.outGoingCallView){
          NavUtils.back();
        }
      } else {
        NavUtils.offNamed(NavUtils.defaultRouteName);
      }
    }
  }

  callDisconnectedStatus(){
    debugPrint("callDisconnectedStatus is called");
    callList.clear();
    callTimer("Disconnected");
    backCalledFromDisconnect();
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

  void remoteHangup(String callMode, String userJid, String callType, String callAction) {
    this.callMode(callMode);
    this.callType(callType);
    // if(callList.isNotEmpty) {
    //   disconnectCall();
    // }
  }

  void calling(String callMode, String userJid, String callType, String callStatus) {
    this.callMode(callMode);
    this.callType(callType);
    // this.callStatus(callStatus);
  }

  void reconnected(String callMode, String userJid, String callType, String callStatus) {
    this.callMode(callMode);
    this.callType(callType);
    // this.callStatus(callStatus);
  }

  Future<void> ringing(String callMode, String userJid, String callType, String callStatus) async {
    this.callMode(callMode);
    this.callType(callType);
    // this.callStatus(callStatus);
    var isAudioMuted = (await Mirrorfly.isUserAudioMuted(userJid: userJid)).checkNull();
    var isVideoMuted = (await Mirrorfly.isUserVideoMuted(userJid: userJid)).checkNull();
    var index = callList.indexWhere((userList) => userList.userJid!.value == userJid);
    debugPrint("User List Index $index");
    if(index.isNegative){
      debugPrint("User List not Found, so adding the user to list");
      CallUserList callUserList = CallUserList(userJid: userJid.obs, callStatus: RxString(callStatus), isAudioMuted: isAudioMuted, isVideoMuted: isVideoMuted,);
      if(callList.length > 1) {
        callList.insert(callList.length - 1, callUserList);
        users.insert(users.length - 1 , userJid);
      }else {
        callList.add(callUserList);
      }
    }else{
      callList[index].callStatus?.value = callStatus;
    }
  }

  void onHold(String callMode, String userJid, String callType, String callStatus) {
    this.callMode(callMode);
    this.callType(callType);
    // this.callStatus(callStatus);
    // isCallTimerEnabled = false;

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
    }else if(NavUtils.currentRoute == Routes.participants){
      //commenting this for when user reconnected then toast is displayed so no need to display
      // var data = await getProfileDetails(userJid);
      // toToast("${data.getName()} joined the Call");
    }else{
      var isAudioMuted = (await Mirrorfly.isUserAudioMuted(userJid: userJid)).checkNull();
      var isVideoMuted = (await Mirrorfly.isUserVideoMuted(userJid: userJid)).checkNull();
      var indexValid = callList.indexWhere((element) => element.userJid?.value == userJid);
      debugPrint("#MirrorflyCall user jid $userJid");
      CallUserList callUserList = CallUserList(userJid: userJid.obs, callStatus: RxString(callStatus), isAudioMuted: isAudioMuted, isVideoMuted: isVideoMuted,);
     if(indexValid.isNegative) {
       callList.insert(callList.length - 1, callUserList);
       users.insert(users.length - 1, userJid);
       // callList.add(callUserList);
       debugPrint("#MirrorflyCall List value updated ${callList.length}");
     }else{
       debugPrint("#MirrorflyCall List value not updated due to jid $userJid is already in list ${callList.length}");

     }

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
    }else{
      var userJids = userJid.split(",");
      debugPrint("#Mirrorfly Call timeout userJids $userJids");
      for (var jid in userJids) {
        debugPrint("removeUser userJid $jid");
        removeUser(callMode, jid.toString().trim(), callType);
      }
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
    if (callList.isEmpty) {
      debugPrint("skipping statusUpdate as list is empty");
      return;
    }

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
        displayStatus = CallStatus.calling;
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
    if(pinnedUserJid.value == userJid && isGroupCall) {
      this.callStatus(displayStatus);
    }else if (isOneToOneCall){
      this.callStatus(displayStatus);
    }else{
      debugPrint("isOneToOneCall $isOneToOneCall");
      debugPrint("isGroupCall $isGroupCall");
      debugPrint("Status is not updated");
    }
    if(Routes.onGoingCallView==NavUtils.currentRoute) {
      ///update the status of the user in call user list
      var indexOfItem = callList.indexWhere((element) => element.userJid!.value == userJid);
      /// check the index is valid or not
      if (!indexOfItem.isNegative && callStatus != CallStatus.disconnected) {
        debugPrint("indexOfItem of call status update $indexOfItem $callStatus");

        /// update the current status of the user in the list
        callList[indexOfItem].callStatus?.value = (callStatus);
      }
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

  void callDuration(String timer) {
    // debugPrint("baseController callDuration Update");
    // if (isCallTimerEnabled) {
    if(callTimer.value!="Disconnected") {
      callTimer(timer);
    }
    // }
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

  int audioLevel(String userJid) {
    var index = speakingUsers.indexWhere((element) => element.userJid == userJid);
    var value = index.isNegative ? -1 : speakingUsers[index].audioLevel.value;
    // debugPrint("speakingUsers Audio level $value");
    return value;
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
    if(DialogUtils.isDialogOpen()){
      // Navigator.of(Get.overlayContext!).pop();
      NavUtils.back();
    }
    callType(CallType.audio);

    videoMuted(true);

    //***Added for iOS. Sometimes this gets triggered when the timeout occurs at remote Android user but only after Rejecting the request once.
    // if(isVideoCallRequested){
    //   //Cancelling the Request Popup
    //
    //   //The below condition is must bcz iOS emit 2 times the delegate. so it navigates back to chat controller.
    //   if(Get.isDialogOpen ?? false) {
    //     NavUtils.back();
    //   }
    // }
  }
  void closeDialog(){
    if (DialogUtils.isDialogOpen()) {
      NavUtils.back();
    }
  }

  var showingVideoSwitchPopup = false;
  var outGoingRequest = false;
  var inComingRequest = false;
  Future<void> showVideoSwitchPopup() async {
    if (await AppPermission.askVideoCallPermissions()) {
      showingVideoSwitchPopup = true;
      DialogUtils.showAlert(dialogStyle: AppStyleConfig.dialogStyle,
          message: getTranslated("videoSwitchMessage"),
          actions: [
            TextButton(style: AppStyleConfig.dialogStyle.buttonStyle,
                onPressed: () {
                  outGoingRequest = false;
                  showingVideoSwitchPopup = false;
                  closeDialog();
                },
                child: Text(getTranslated("cancel").toUpperCase(), )),
            TextButton(style: AppStyleConfig.dialogStyle.buttonStyle,
                onPressed: () {
                  if(callType.value == CallType.audio && isOneToOneCall && NavUtils.previousRoute == Routes.onGoingCallView) {//currentRoute is Dialog so checking previousRoute
                    outGoingRequest = true;
                    Mirrorfly.requestVideoCallSwitch().then((value) {
                      if (value) {
                        showingVideoSwitchPopup = false;
                        closeDialog();
                        showWaitingPopup();
                      }
                    });
                  }else{
                    closeDialog();
                  }
                },
                child: Text(getTranslated("switchCall"), ))
          ],
          barrierDismissible: false);
    }else{
      toToast(getTranslated("needCameraPermissionForSwitch"));
    }
  }

  // when request was canceled from requester side
  void videoCallConversionCancel(){
    if (isVideoCallRequested) {
      isVideoCallRequested = false;
      //To Close the Request Popup
      closeDialog();
    }
  }

  void videoCallConversionRequest(String userJid) async {
    inComingRequest = true;
    if(showingVideoSwitchPopup){
      closeDialog();
    }
    //if both users are made switch request then accept the request without confirmation popup
    LogMessage.d("Both Call Switch Request", "inComingRequest : $inComingRequest outGoingRequest : $outGoingRequest");
    if(inComingRequest && outGoingRequest){
      inComingRequest = false;
      outGoingRequest = false;
      Mirrorfly.acceptVideoCallSwitchRequest().then((value) {
        videoMuted(false);
        callType(CallType.video);
      });
      return;
    }
    var profile = await getProfileDetails(userJid);
    isVideoCallRequested = true;
    DialogUtils.showAlert(dialogStyle: AppStyleConfig.dialogStyle,
        message: getTranslated("videoSwitchRequestedMessage").replaceFirst("%d", profile.getName()),
        actions: [
          TextButton(style: AppStyleConfig.dialogStyle.buttonStyle,
              onPressed: () {
                isVideoCallRequested = false;
                inComingRequest = false;
                closeDialog();
                Mirrorfly.declineVideoCallSwitchRequest();
              },
              child: Text(getTranslated("declineRequest").toUpperCase(), )),
          TextButton(style: AppStyleConfig.dialogStyle.buttonStyle,
              onPressed: () async {
                closeDialog();
                if (await AppPermission.askVideoCallPermissions()) {
                  isVideoCallRequested = false;
                  inComingRequest = false;
                  Mirrorfly.acceptVideoCallSwitchRequest().then((value) {
                    videoMuted(false);
                    callType(CallType.video);
                  });
                }else{
                  Future.delayed(const Duration(milliseconds:500 ),(){
                    toToast(getTranslated("needCameraPermissionForSwitch"));
                  });
                  Mirrorfly.declineVideoCallSwitchRequest();
                }
              },
              child: Text(getTranslated("acceptRequest"), ))
        ],
        barrierDismissible: false);
  }

  void showWaitingPopup() {
    isWaitingCanceled = false;
    waitingCompleter = Completer<void>();

    DialogUtils.showAlert(dialogStyle: AppStyleConfig.dialogStyle,
        message: getTranslated("videoSwitchRequestMessage"),
        actions: [
          TextButton(style: AppStyleConfig.dialogStyle.buttonStyle,
              onPressed: () {
                isWaitingCanceled = true;
                outGoingRequest = false;
                closeDialog();
                Mirrorfly.cancelVideoCallSwitch();
              },
              child: Text(getTranslated("cancel").toUpperCase(), ))
        ],
        barrierDismissible: false);

    // Wait for 20 seconds or until canceled
    Future.delayed(const Duration(seconds: 20)).then((_) async {
      debugPrint("waiting duration end");
      if (!isWaitingCanceled) {
        outGoingRequest=false;
        closeDialog();
        Mirrorfly.cancelVideoCallSwitch();
        waitingCompleter.complete();
        // NavUtils.back();
        var profile = await getProfileDetails(callList.first.userJid!.value.checkNull());
        toToast(getTranslated("noResponseFrom").replaceFirst("%d", profile.getName()));
      }
    });
  }

  void videoCallConversionAccepted() {
    if(DialogUtils.isDialogOpen()){
      // Navigator.of(Get.overlayContext!).pop();
      NavUtils.back();
    }
    inComingRequest = false;
    outGoingRequest = false;
    if (!waitingCompleter.isCompleted) {
      isWaitingCanceled = true;
      waitingCompleter.complete();
      //To Close the Waiting Popup
      closeDialog();
      videoMuted(false);
      callType(CallType.video);
    }
  }

  void videoCallConversionRejected() {
    toToast(getTranslated("callSwitchRequestDeclined"));
    inComingRequest = false;
    outGoingRequest = false;
    if (!waitingCompleter.isCompleted) {
      isWaitingCanceled = true;
      waitingCompleter.complete();
      //To Close the Waiting Popup
      closeDialog();
    }
  }

  void onResume(String callMode, String userJid, String callType, String callStatus) {
    this.callType(callType);
    this.callMode(callMode);
    // isCallTimerEnabled = true;
  }

  void openParticipantScreen() {
    NavUtils.toNamed(Routes.participants);
  }

  void onUserInvite(String callMode, String userJid, String callType) {
    closeVideoConversationAvailable();
    addParticipants(callMode, userJid, callType);
  }

  void closeVideoConversationAvailable(){
    if(inComingRequest || outGoingRequest || showingVideoSwitchPopup){
      closeDialog();
    }
    if(!isWaitingCanceled){
      isWaitingCanceled = true;
      outGoingRequest = false;
    }
    if(inComingRequest) {
      isVideoCallRequested = false;
      inComingRequest = false;
    }
    videoCallConversionCancel();
  }

  Future<void> onUserJoined(String callMode, String userJid, String callType,String callStatus) async {
    LogMessage.d("callController", " onUserJoined $userJid from joinViaLink");
    var isAudioMuted = (await Mirrorfly.isUserAudioMuted(userJid: userJid))
        .checkNull();
    var isVideoMuted = (await Mirrorfly.isUserVideoMuted(userJid: userJid))
        .checkNull();
    var indexValid = callList.indexWhere((element) => element.userJid?.value == userJid);
    LogMessage.d("callController", "indexValid : $indexValid jid : $userJid");
    if(indexValid.isNegative && callList.length != getMaxCallUsersCount) {
      callList.insert(callList.length - 1, CallUserList(
          userJid: userJid.obs,
          isAudioMuted: isAudioMuted,
          isVideoMuted: isVideoMuted,
          callStatus: CallStatus.connected.obs));
      users.insert(users.length - 1, userJid);
    }
  }

  void addParticipants(String callMode, String userJid, String callType){
    Mirrorfly.getInvitedUsersList().then((value) async {
      LogMessage.d("callController", " getInvitedUsersList $value");
      if(value.isNotEmpty){
        var userJids = value;
        for (var jid in userJids) {
          LogMessage.d("callController", "before ${callUserListToJson(callList)}");
          var isAudioMuted = (await Mirrorfly.isUserAudioMuted(userJid: jid)).checkNull();
          var isVideoMuted = (await Mirrorfly.isUserVideoMuted(userJid: jid)).checkNull();
          var indexValid = callList.indexWhere((element) => element.userJid?.value == jid);
          LogMessage.d("callController", "indexValid : $indexValid jid : $jid callList.length ${callList.length} getMaxCallUsersCount : $getMaxCallUsersCount");
          if(indexValid.isNegative && callList.length != getMaxCallUsersCount) {
            callList.insert(callList.length - 1, CallUserList(
                userJid: jid.obs,
                isAudioMuted: isAudioMuted,
                isVideoMuted: isVideoMuted,
                callStatus: CallStatus.calling.obs));
            users.insert(users.length - 1, jid);
            // getNames();
            LogMessage.d("callController", "after ${callUserListToJson(callList)}");
          }else{
            LogMessage.d("callController", "User already in the list");
          }
        }
      }
    });
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
    if(callList.isNotEmpty && pinnedUserJid.value == userJid) {
      pinnedUserJid(callList[0].userJid!.value);
    }
    ///if user is from joinViaLink then no need to close the screen until user disconnects manually.
    if(joinViaLink){
      return;
    }
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

  void swap(int index) {
    if(isOneToOneCall && isVideoCall && !videoMuted.value){
      var itemToReplace = callList.indexWhere((y) => y.userJid!.value==pinnedUserJid.value);
      var itemToRemove = callList[index];
      var userJid = itemToRemove.userJid?.value;
      pinnedUserJid(userJid);
      callList.swap(index, itemToReplace);
    }
  }

}
