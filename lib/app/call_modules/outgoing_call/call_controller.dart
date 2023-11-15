import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/call_modules/call_utils.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/model/call_user_list.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import '../../../main.dart';
import '../../data/permissions.dart';
import '../../data/session_management.dart';
import '../../routes/app_pages.dart';

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

  var callMode = "".obs;
  get isOneToOneCall => callList.length==2;//callMode.value == CallMode.oneToOne;
  get isGroupCall => callList.length>2;//callMode.value == CallMode.groupCall;

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

  @override
  Future<void> onInit() async {
    super.onInit();
    enterFullScreen();
    tabController = TabController(length: 2, vsync: this);
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    debugPrint("#Mirrorfly Call Controller onInit");
    groupId(await Mirrorfly.getGroupId());
    isCallTimerEnabled = true;
    if (Get.arguments != null) {
      users.value = Get.arguments?["userJid"] as List<String?>;
      cameraSwitch(Get.arguments?["cameraSwitch"]);
    }
    // await outGoingUsers();
    // callType.value = Get.arguments["callType"];
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
    if (Get.currentRoute == Routes.onGoingCallView) {
      //startTimer();
    }
    Mirrorfly.getAllAvailableAudioInput().then((value) {
      final availableList = audioDevicesFromJson(value);
      availableAudioList(availableList);
      debugPrint("${Constants.tag} flutter getAllAvailableAudioInput $availableList");
    });
    await Mirrorfly.getCallDirection().then((value) async {
      debugPrint("#Mirrorfly Call Direction $value");
      if (value == "Incoming") {
        Mirrorfly.getCallUsersList().then((value) {
          // [{"userJid":"919789482015@xmpp-uikit-qa.contus.us","callStatus":"Trying to Connect"},{"userJid":"919894940560@xmpp-uikit-qa.contus.us","callStatus":"Trying to Connect"},{"userJid":"917010279986@xmpp-uikit-qa.contus.us","callStatus":"Connected"}]
          debugPrint("#Mirrorfly call get users --> $value");
          final callUserList = callUserListFromJson(value);
          callList(callUserList);
          if(callUserList.length>1) {
            pinnedUserJid(callUserList[0].userJid);
          }
          getNames();
        });
      } else {
        debugPrint("#Mirrorfly Call Direction outgoing");
        debugPrint("#Mirrorfly Call getCallUsersList");
        Mirrorfly.getCallUsersList().then((value) {
          debugPrint("#Mirrorfly call get users --> $value");
          // callList.clear();
          final callUserList = callUserListFromJson(value);
          callList(callUserList);
          if(callUserList.length>1) {
            pinnedUserJid(callUserList[0].userJid);
          }
          getNames();
        });
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
      // getNames();
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
    await Mirrorfly.muteAudio(!muted.value).then((value) => debugPrint("#Mirrorfly Mute Audio Response $value"));
    muted(!muted.value);
    var callUserIndex = callList.indexWhere((element) => element.userJid == SessionManagement.getUserJID());
    if(!callUserIndex.isNegative) {
      callList[callUserIndex].isAudioMuted(muted.value);
    }
  }

  changeSpeaker() {
    // speakerOff(!speakerOff.value);
    debugPrint("availableAudioList.length ${availableAudioList.length}");
    //if connected other audio devices
    // if (availableAudioList.length > 2) {
    Get.dialog(
      Dialog(
        child: WillPopScope(
          onWillPop: () {
            return Future.value(true);
          },
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
                          Get.back();
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

  videoMute() {
    debugPrint("isOneToOneCall : $isOneToOneCall");
    if (callType.value != CallType.audio) {
      Mirrorfly.muteVideo(!videoMuted.value);
      videoMuted(!videoMuted.value);
    } else if (callType.value == CallType.audio && isOneToOneCall && Get.currentRoute == Routes.onGoingCallView) {
      showVideoSwitchPopup();
    } else if (isGroupCall) {
      Mirrorfly.muteVideo(!videoMuted.value);
      videoMuted(!videoMuted.value);
    }
  }

  switchCamera() async {
    // cameraSwitch(!cameraSwitch.value);
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
    Mirrorfly.disconnectCall().then((value) {
      debugPrint("#Disconnect call disconnect value $value");
      if (value.checkNull()) {
        debugPrint("#Disconnect call disconnect list size ${callList.length}");
        if (Get.previousRoute.isNotEmpty) {
          debugPrint("#Disconnect previous route is not empty");
          if (Get.currentRoute == Routes.onGoingCallView) {
            debugPrint("#Disconnect current route is ongoing call view");
            Future.delayed(const Duration(seconds: 1), () {
              debugPrint("#Disconnect call controller back called");
              Get.back();
            });
          }else if(Get.currentRoute == Routes.participants){
            Get.back();
            Future.delayed(const Duration(seconds: 1), () {
              debugPrint("#Disconnect call controller back called");
              Get.back();
            });
          }else{
            Get.back();
          }
        } else {
          Get.offNamed(getInitialRoute());
        }
      }
    });
  }

  getNames() async {
    //Need to check Call Mode and update the name for group call here
    callTitle('');
    if(groupId.isEmpty) {
      var userJids = <String>[];
      for (var element in callList) {
        if(element.userJid!=null && SessionManagement.getUserJID() != element.userJid) {
          userJids.add(element.userJid!);
        }}
      LogMessage.d("callList", userJids.length);
      var names = userJids.isNotEmpty ? await CallUtils.getCallersName(userJids) : "";
      callTitle(names);
      /*callList.asMap().forEach((index, users) async {
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
      });*/
    }else{
      callTitle((await getProfileDetails(groupId.value)).getName());
    }
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

  void callDisconnected(String callMode, String userJid, String callType) {
    this.callMode(callMode);
    this.callType(callType);
    if(Get.currentRoute==Routes.outGoingCallView){
      // This if condition is added for the group call remote busy - call action
      if(callList.length < 2){
        Get.back();
      }
      return;
    }
    debugPrint("#Mirrorfly call call disconnect called ${callList.length}");
    debugPrint("#Mirrorfly call call disconnect called ${callList.toJson()}");
    if (callList.isEmpty) {
      debugPrint("call list is empty returning");
      return;
    }
    debugPrint("call list is not empty");
    var index = callList.indexWhere((user) => user.userJid == userJid);
    debugPrint("#Mirrorfly call disconnected user Index $index ${Get.currentRoute}");
    if (!index.isNegative) {
      callList.removeAt(index);
    } else {
      debugPrint("#Mirrorflycall participant jid is not in the list");
    }
    if (callList.length <= 1 || userJid == SessionManagement.getUserJID()) {
      isCallTimerEnabled = false;
      //if user is in the participants screen all users end the call then we should close call pages
      if(Get.currentRoute==Routes.participants){
        Get.back();
      }
      // if there is an single user in that call and if he [disconnected] no need to disconnect the call from our side Observed in Android
      if (Platform.isIOS) {
        // in iOS needs to call disconnect.
        disconnectCall();
      } else {
        if (Get.previousRoute.isNotEmpty) {
          if (Get.currentRoute == Routes.onGoingCallView) {
            callTimer("Disconnected");
            Future.delayed(const Duration(seconds: 1), () {
              Get.back();
            });
          } else {
            Get.back();
          }
        } else {
          Get.offNamed(getInitialRoute());
        }
      }
    }
  }

  Future<void> remoteBusy(String callMode, String userJid, String callType, String callAction) async {
    //in Android, showing this user is busy toast inside SDK
    // if(Platform.isIOS) {
      if (callList.length > 2) {
        var data = await getProfileDetails(userJid);
        toToast("${data.getName()} is Busy");
      } else {
        toToast("User is Busy");
      }
    // }

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
    callDisconnected(callMode, userJid, callType);
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

  void ringing(String callMode, String userJid, String callType, String callStatus) {
    this.callMode(callMode);
    this.callType(callType);
    // this.callStatus(callStatus);
    var index = callList.indexWhere((userList) => userList.userJid == userJid);
    debugPrint("User List Index $index");
    if(index.isNegative){
      debugPrint("User List not Found, so adding the user to list");
      CallUserList callUserList = CallUserList(userJid: userJid, callStatus: RxString(callStatus), isAudioMuted: false,isVideoMuted: false);
      callList.insert(callList.length - 1, callUserList);
      // callList.add(callUserList);
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

  void connected(String callMode, String userJid, String callType, String callStatus) {
    this.callMode(callMode);
    this.callType(callType);
    // this.callStatus(callStatus);
    // getNames();
    // startTimer();
    if(Get.currentRoute != Routes.onGoingCallView) {
      Future.delayed(const Duration(milliseconds: 500), () {
        Get.offNamed(Routes.onGoingCallView, arguments: {"userJid": [userJid], "cameraSwitch": cameraSwitch.value});
      });
    }else{
      debugPrint("#MirrorflyCall user jid $userJid");
      CallUserList callUserList = CallUserList(userJid: userJid, callStatus: RxString(callStatus), isAudioMuted: false,isVideoMuted: false);
     if(callList.indexWhere((userList) => userList.userJid == userJid).isNegative) {
       callList.insert(callList.length - 1, callUserList);
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
    debugPrint("#Mirrorfly Call timeout callMode : $callMode -- userJid : $userJid -- callType $callType -- callStatus $callStatus");
    if(Get.currentRoute==Routes.outGoingCallView) {
      Get.offNamed(Routes.callTimeOutView,
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
    Mirrorfly.disconnectCall().then((value) {
      callList.clear();
      //if (Platform.isIOS) {
        Get.back();
      //}
      //Get.back();
    });
  }

  void statusUpdate(String userJid, String callStatus) {
    if (callList.isEmpty) {
      debugPrint("skipping statusUpdate as list is empty");
      return;
    }
    debugPrint("statusUpdate $callStatus");
    var displayStatus = CallStatus.calling;
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
      case CallStatus.inviteCallTimeout:
        displayStatus = CallStatus.calling;
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
      case CallStatus.calling10s:
      case CallStatus.callingAfter10s:
        displayStatus = callStatus;
        break;
      default:
        displayStatus = '';
        break;
    }
    if(pinnedUserJid.value==userJid) {
      this.callStatus(displayStatus);
    }
    if(Routes.onGoingCallView==Get.currentRoute) {
      ///update the status of the user in call user list
      var indexOfItem = callList.indexWhere((element) => element.userJid == userJid);
      /// check the index is valid or not
      if (!indexOfItem.isNegative && callStatus != CallStatus.disconnected) {
        debugPrint("indexOfItem of call status update $indexOfItem");

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
      debugPrint("${Constants.tag} flutter getAllAvailableAudioInput $availableList");
    });
  }

  Future<void> remoteEngaged(String userJid, String callMode, String callType) async {
    // if (Platform.isIOS) {
      var data = await getProfileDetails(userJid);
      toToast(data.getName() + Constants.remoteEngagedToast);
    // }
    debugPrint("***call list length ${callList.length}");
//The below condition (<= 2) -> (<2) is changed for Group call, to maintain the call to continue if there is a 2 users in call
    if(callList.length < 2){
      disconnectOutgoingCall();
    }else{
      removeUser(callMode, userJid, callType);
    }
    // disconnectOutgoingCall();
  }

  void audioMuteStatusChanged(String muteEvent, String userJid) {
    var callUserIndex = callList.indexWhere((element) => element.userJid == userJid);
    if (!callUserIndex.isNegative) {
      debugPrint("index $callUserIndex");
      callList[callUserIndex].isAudioMuted(muteEvent == MuteStatus.remoteAudioMute);
    } else {
      debugPrint("#Mirrorfly call User Not Found in list to mute the status");
    }
  }

  void videoMuteStatusChanged(String muteEvent, String userJid) {
    var callUserIndex = callList.indexWhere((element) => element.userJid == userJid);
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

  int audioLevel(userJid) {
    var index = speakingUsers.indexWhere((element) => element.userJid == userJid);
    var value = index.isNegative ? -1 : speakingUsers[speakingUsers.indexWhere((element) => element.userJid == userJid)].audioLevel.value;
    // debugPrint("speakingUsers Audio level $value");
    return value;
  }

  void onUserStoppedSpeaking(String userJid) {
    //adding delay to show better ui
    Future.delayed(const Duration(milliseconds: 300), () {
      var index = speakingUsers.indexWhere((element) => element.userJid == userJid);
      if (!index.isNegative) {
        speakingUsers.removeAt(index);
      }
    });
  }

  void denyCall() {
    LogMessage.d("denyCall", Get.currentRoute);
    if (Get.currentRoute == Routes.outGoingCallView) {
      Get.back();
    }
  }

  void onCameraSwitch() {
    LogMessage.d("onCameraSwitch", cameraSwitch.value);
    cameraSwitch(!cameraSwitch.value);
  }

  void changedToAudioCall() {
    if(Get.isDialogOpen ?? false){
      Navigator.of(Get.overlayContext!).pop();
    }
    callType(CallType.audio);

    videoMuted(true);

    //***Added for iOS. Sometimes this gets triggered when the timeout occurs at remote Android user but only after Rejecting the request once.
    // if(isVideoCallRequested){
    //   //Cancelling the Request Popup
    //
    //   //The below condition is must bcz iOS emit 2 times the delegate. so it navigates back to chat controller.
    //   if(Get.isDialogOpen ?? false) {
    //     Get.back();
    //   }
    // }
  }
  void closeDialog(){
    if (Get.isDialogOpen!) {
      Get.back();
    }
  }

  var showingVideoSwitchPopup = false;
  var outGoingRequest = false;
  var inComingRequest = false;
  Future<void> showVideoSwitchPopup() async {
    if (Platform.isAndroid ? await AppPermission.askVideoCallPermissions() : await AppPermission.askiOSVideoCallPermissions()) {
      showingVideoSwitchPopup = true;
      Helper.showAlert(
          message: Constants.videoSwitchMessage,
          actions: [
            TextButton(
                onPressed: () {
                  outGoingRequest = false;
                  showingVideoSwitchPopup = false;
                  closeDialog();
                },
                child: const Text("CANCEL")),
            TextButton(
                onPressed: () {
                  outGoingRequest = true;
                  Mirrorfly.requestVideoCallSwitch().then((value) {
                    if (value) {
                      showingVideoSwitchPopup = false;
                      closeDialog();
                      showWaitingPopup();
                    }
                  });
                },
                child: const Text("SWITCH"))
          ],
          barrierDismissible: false);
    }else{
      toToast("Camera Permission Needed to switch the call");
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
    Helper.showAlert(
        message: "${profile.getName()} ${Constants.videoSwitchRequestedMessage}",
        actions: [
          TextButton(
              onPressed: () {
                isVideoCallRequested = false;
                inComingRequest = false;
                closeDialog();
                Mirrorfly.declineVideoCallSwitchRequest();
              },
              child: const Text("DECLINE")),
          TextButton(
              onPressed: () async {
                closeDialog();
                if (Platform.isAndroid ? await AppPermission.askVideoCallPermissions() : await AppPermission.askiOSVideoCallPermissions()) {
                  isVideoCallRequested = false;
                  inComingRequest = false;
                  Mirrorfly.acceptVideoCallSwitchRequest().then((value) {
                    videoMuted(false);
                    callType(CallType.video);
                  });
                }else{
                  Future.delayed(const Duration(milliseconds:500 ),(){
                    toToast("Camera Permission Needed to switch the call");
                  });
                  Mirrorfly.declineVideoCallSwitchRequest();
                }
              },
              child: const Text("ACCEPT"))
        ],
        barrierDismissible: false);
  }

  void showWaitingPopup() {
    isWaitingCanceled = false;
    waitingCompleter = Completer<void>();

    Helper.showAlert(
        message: Constants.videoSwitchRequestMessage,
        actions: [
          TextButton(
              onPressed: () {
                isWaitingCanceled = true;
                outGoingRequest = false;
                closeDialog();
                Mirrorfly.cancelVideoCallSwitch();
              },
              child: const Text("CANCEL"))
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
        // Get.back();
        var profile = await getProfileDetails(callList.first.userJid.checkNull());
        toToast("No response from ${profile.getName()}");
      }
    });
  }

  void videoCallConversionAccepted() {
    if(Get.isDialogOpen ?? false){
      Navigator.of(Get.overlayContext!).pop();
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
    toToast("Request Declined");
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
    Get.toNamed(Routes.participants);
  }

  void onUserInvite(String callMode, String userJid, String callType) {
    addParticipants(callMode, userJid, callType);
  }

  void onUserJoined(String callMode, String userJid, String callType,String callStatus) {
    // addParticipants(callMode, userJid, callType);
  }

  void addParticipants(String callMode, String userJid, String callType){
    Mirrorfly.getInvitedUsersList().then((value) {
      LogMessage.d("addParticipants", value);
      if(value.isNotEmpty){
        var userJids = value;
        for (var jid in userJids) {
          callList.add(CallUserList(userJid: jid,isAudioMuted: false, isVideoMuted: false,callStatus: CallStatus.calling.obs));
          users.add(jid);
        };
      }
    });
  }
  void onUserLeft(String callMode, String userJid, String callType) {
    if(callList.length>2) {
      CallUtils.getNameOfJid(userJid).then((value) => toToast("$value Left"));
    }
    removeUser(callMode, userJid, callType);
  }
  void removeUser(String callMode, String userJid, String callType){
    this.callType(callType);
    debugPrint("before removeUser ${callList.length}");
    debugPrint("before removeUser index ${callList.indexWhere((element) => element.userJid == userJid)}");
    callList.removeWhere((element){
      debugPrint("removeUser callStatus ${element.callStatus}");
      return element.userJid == userJid;
    });
    users.removeWhere((element) => element == userJid);
    speakingUsers.removeWhere((element) => element.userJid == userJid);
    debugPrint("after removeUser ${callList.length}");
    debugPrint("removeUser ${callList.indexWhere((element) => element.userJid.toString() == userJid)}");
    if(callList.length>1 && pinnedUserJid.value == userJid) {
      pinnedUserJid(callList[0].userJid);
    }
    callDisconnected(callMode, userJid, callType);
    getNames();

  }

  void enterFullScreen() {
    //SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  void exitFullScreen() {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  var selected = false.obs;
  var isSearching = false.obs;
  var searchFocusNode = FocusNode();
  var search = TextEditingController();
  onChange(String str){

  }
  clearAllChatSelection(){

  }
  getBackFromSearch(){

  }
}
