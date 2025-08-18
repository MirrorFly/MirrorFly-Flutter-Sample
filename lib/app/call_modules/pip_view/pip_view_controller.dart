import 'dart:io';

import 'package:fl_pip/fl_pip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_in_app_pip/flutter_in_app_pip.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/call_modules/call_utils.dart';
import 'package:mirror_fly_demo/app/common/app_localizations.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/data/utils.dart';
import 'package:mirror_fly_demo/app/extensions/extensions.dart';
import 'package:mirror_fly_demo/app/model/call_user_list.dart';
import 'package:mirror_fly_demo/app/routes/app_pages.dart';
import 'package:mirror_fly_demo/app/routes/route_settings.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import '../../base_controller.dart';

class PipViewController extends FullLifeCycleController
    with FullLifeCycleMixin, CallEventListeners, ProfileEventListeners {
  final String tag = "PipViewController";

  get isOneToOneCall => callList.length <= 2;

  var callList = List<CallUserList>.empty(growable: true).obs;
  var availableAudioList = List<AudioDevices>.empty(growable: true).obs;
  var isPIPActive = false.obs;
  var showExpand = false.obs;
  final prioritizedStatuses = [CallStatus.connected, CallStatus.reconnected];

  @override
  Future<void> onInit() async {
    Mirrorfly.setProfileEventListener(this);
    Mirrorfly.setCallEventListener(this);
    checkPIP();
    try {
      var value = await Mirrorfly.getCallUsersList();
      final callUserList = callUserListFromJson(value);
      callUserList.sort((a, b) {
        final aPriority =
            prioritizedStatuses.contains(a.callStatus!.value) ? 0 : 1;
        final bPriority =
            prioritizedStatuses.contains(b.callStatus!.value) ? 0 : 1;
        return aPriority.compareTo(bPriority);
      });
      callList(callUserList);
    } catch (e) {
      LogMessage.d("PipView", e);
    }
    super.onInit();
  }

  @override
  void onCallAction(
      String userJid, String callMode, String callType, String callAction) {
    switch (callAction) {
      case CallAction.videoCallConversionRequest:
        {
          videoCallConversionRequest();
          break;
        }
      case CallAction.inviteUsers:
        {
          onUserInvite(callMode, userJid, callType);
          break;
        }
      case CallAction.remoteBusy:
        {
          remoteBusy(callMode, userJid, callType, callAction);
          break;
        }
      case CallAction.remoteHangup:
        {
          BaseController.stopTimer();
          callDisconnected();
          break;
        }
      case CallAction.localHangup:
        {
          BaseController.stopTimer();
          callDisconnected();
          break;
        }
      case CallAction.remoteOtherBusy:
        {
          remoteOtherBusy(callMode, userJid, callType, callAction);
          break;
        }
      case CallAction.remoteEngaged:
        {
          remoteEngaged(userJid, callMode, callType);
          break;
        }
    }
  }

  Future<void> videoCallConversionRequest() async {
      movePIPToOngoingCallView();
  }

  @override
  void onCallLogDeleted(String callLogId) {
    // TODO: implement onCallLogDeleted
  }

  @override
  void onCallLogsCleared() {
    // TODO: implement onCallLogsCleared
  }

  @override
  void onCallLogsUpdated() {
    // TODO: implement onCallLogsUpdated
  }

  @override
  void onCallStatusUpdated(
      String userJid, String callMode, String callType, String callStatus) {
    updateStatus(userJid, callStatus);
    switch (callStatus) {
      case CallStatus.disconnected:
        {
          BaseController.stopTimer();
          callDisconnected();
          break;
        }
      case CallStatus.callTimeout:
        {
          var userJids = userJid.split(",");
          debugPrint("#Mirrorfly Call timeout userJids $userJids");
          removeUsersInCall(userJids, callStatus);
          break;
        }
      case CallStatus.userLeft:
        {
          onUserLeft(callMode, userJid, callType);
          break;
        }
      case CallStatus.userJoined:
        {
          onUserJoined(callMode, userJid, callType, callStatus);
          break;
        }
    }
  }

  @override
  void onLocalVideoTrackAdded(String userJid) {
    // TODO: implement onLocalVideoTrackAdded
  }

  @override
  void onMissedCall(String userJid, String groupId, bool isOneToOneCall,
      String callType, List<String> userList) {
    // TODO: implement onMissedCall
  }

  @override
  void onMuteStatusUpdated(String userJid, String muteEvent) {
    audioMuteStatusChanged(muteEvent, userJid);
  }

  @override
  void onRemoteVideoTrackAdded(String userJid) {
    // TODO: implement onRemoteVideoTrackAdded
  }

  @override
  void onTrackAdded(String userJid) {
    // TODO: implement onTrackAdded
  }

  var speakingUsers = <SpeakingUsers>[].obs;
  @override
  void onUserSpeaking(String userJid, int audioLevel) {
    LogMessage.d(
        "onUserSpeaking", "userJid: $userJid, audioLevel : $audioLevel");
    var index = speakingUsers.indexWhere(
        (element) => element.userJid.toString() == userJid.toString());
    // LogMessage.d("speakingUsers indexWhere", "$index");
    if (index.isNegative) {
      speakingUsers
          .add(SpeakingUsers(userJid: userJid, audioLevel: audioLevel.obs));
      // LogMessage.d("speakingUsers", "added");
    } else {
      speakingUsers[index].audioLevel(audioLevel);
      // LogMessage.d("speakingUsers", "updated");
    }
  }

  int audioLevel(String userJid) {
    var index =
        speakingUsers.indexWhere((element) => element.userJid == userJid);
    var value = index.isNegative ? -1 : speakingUsers[index].audioLevel.value;
    // debugPrint("speakingUsers Audio level $value");
    return value;
  }

  @override
  void onUserStoppedSpeaking(String userJid) {
    Future.delayed(const Duration(milliseconds: 300), () {
      var index =
          speakingUsers.indexWhere((element) => element.userJid == userJid);
      if (!index.isNegative) {
        speakingUsers[index].audioLevel(0);
      }
    });
  }

  @override
  void onDetached() {
    // TODO: implement onDetached
  }

  @override
  void onHidden() {
    // TODO: implement onHidden
  }

  @override
  void onInactive() {
    // checkPIP();
  }

  var hasPaused = false;
  @override
  void onPaused() {
    hasPaused = true;
  }

  @override
  Future<void> onResumed() async {
    ///when notification drawer was dragged then app goes inactive,when closes the drawer its trigger onResume
    ///so that this checking hasPaused added, this will invoke only when app is opened from background state.
    if (hasPaused) {
      hasPaused = false;
      // var status = await FlPiP().isActive;
      // if((status?.isCreateNewEngine).checkNull()) {
      //   FlPiP().disable();
      // }
    }
    checkPIP();
  }

  Future<void> checkPIP() async {
    debugPrint("checkPIP");
    isPIPActive((await FlPiP().isActive)?.status == PiPStatus.enabled);
  }

  void hideOptions() {
    isPIPActive(true);
  }

  void expandPIP() {
    PictureInPicture.stopPiP();
    NavUtils.toNamed(AppPages.onGoingCall);
  }

  void stopPIP() {
    // enterPIPMode();
    PictureInPicture.stopPiP();
  }

  void callDisconnected() {
    PictureInPicture.stopPiP();
    FlPiP().toggle(AppState.foreground);
  }

  Future<void> movePIPToOngoingCallView() async {
    LogMessage.d("PIPView", PictureInPicture.isActive);
    if(PictureInPicture.isActive) {
      if ((await Mirrorfly.isOnGoingCall()).checkNull()) {
          LogMessage.d(tag, "stopPiP ${NavUtils.currentRoute} toNamed pipView");
          PictureInPicture.stopPiP();
          NavUtils.toNamed(Routes.onGoingCallView);
      }else{
        PictureInPicture.stopPiP();
        LogMessage.d(tag, "isOnGoingCall not available so closing pip view");
      }
    }else{
      if (Platform.isAndroid) {
        FlPiP().toggle(AppState.foreground);
      }
    }
  }

  Future<void> removeUsersInCall(
      List<String> userJids, String callStatus) async {
    callList
        .removeWhere((element) => userJids.contains(element.userJid!.value));
    speakingUsers.removeWhere((element) => userJids.contains(element.userJid));
    for (var userJid in userJids) {
      getProfileDetails(userJid).then((user) {
        debugPrint("removeUser callStatus $userJid ${user.getName()}");
      });
    }
  }

  void audioMuteStatusChanged(String muteEvent, String userJid) {
    var callUserIndex =
        callList.indexWhere((element) => element.userJid!.value == userJid);
    if (!callUserIndex.isNegative) {
      debugPrint("index $callUserIndex");
      callList[callUserIndex]
          .isAudioMuted(muteEvent == MuteStatus.remoteAudioMute);
    } else {
      debugPrint("#Mirrorfly call User Not Found in list to mute the status");
    }
  }

  void onUserInvite(String callMode, String userJid, String callType) {
    // closeVideoConversationAvailable();
    addParticipants(callMode, userJid, callType);
  }

  Future<void> onUserJoined(String callMode, String userJid, String callType,
      String callStatus) async {
    LogMessage.d(tag, " onUserJoined $userJid from joinViaLink");
    var isAudioMuted =
        (await Mirrorfly.isUserAudioMuted(userJid: userJid)).checkNull();
    var isVideoMuted =
        (await Mirrorfly.isUserVideoMuted(userJid: userJid)).checkNull();
    var indexValid =
        callList.indexWhere((element) => element.userJid?.value == userJid);
    LogMessage.d(tag, "indexValid : $indexValid jid : $userJid");
    if (indexValid.isNegative &&
        callList.length != Constants.getMaxCallUsersCount) {
      callList.insert(
          callList.length - 1,
          CallUserList(
              userJid: userJid.obs,
              isAudioMuted: isAudioMuted,
              isVideoMuted: isVideoMuted,
              callStatus: CallStatus.connected.obs));
    }
  }

  void addParticipants(String callMode, String userJid, String callType) {
    Mirrorfly.getInvitedUsersList().then((value) async {
      LogMessage.d(tag, " getInvitedUsersList $value");
      if (value.isNotEmpty) {
        var userJids = value;
        for (var jid in userJids) {
          LogMessage.d(tag, "before ${callUserListToJson(callList)}");
          var isAudioMuted =
              (await Mirrorfly.isUserAudioMuted(userJid: jid)).checkNull();
          var isVideoMuted =
              (await Mirrorfly.isUserVideoMuted(userJid: jid)).checkNull();
          var indexValid =
              callList.indexWhere((element) => element.userJid?.value == jid);
          LogMessage.d(tag,
              "indexValid : $indexValid jid : $jid callList.length ${callList.length} getMaxCallUsersCount : ${Constants.getMaxCallUsersCount}");
          if (indexValid.isNegative &&
              callList.length != Constants.getMaxCallUsersCount) {
            callList.insert(
                callList.length - 1,
                CallUserList(
                    userJid: jid.obs,
                    isAudioMuted: isAudioMuted,
                    isVideoMuted: isVideoMuted,
                    callStatus: CallStatus.calling.obs));
            LogMessage.d(tag, "after ${callUserListToJson(callList)}");
          } else {
            LogMessage.d(tag, "User already in the list");
          }
        }
      }
    });
  }

  Future<void> remoteBusy(String callMode, String userJid, String callType,
      String callAction) async {
    if (callList.length > 2) {
      var data = await getProfileDetails(userJid);
      toToast(
          getTranslated("usernameIsBusy").replaceFirst("%d", data.getName()));
    } else {
      toToast(getTranslated("userIsBusy"));
    }

    debugPrint("onCallAction CallList Length ${callList.length}");
    if (callList.length < 2) {
      // disconnectOutgoingCall();
    } else {
      removeUser(callMode, userJid, callType);
    }
  }

  Future<void> remoteOtherBusy(String callMode, String userJid, String callType,
      String callAction) async {
    // this.callMode(callMode);
    //remove the user from the list and update ui
    // users.remove(userJid);//out going call view
    remoteBusy(callMode, userJid, callType, callAction);
  }

  Future<void> remoteEngaged(
      String userJid, String callMode, String callType) async {
    var data = await getProfileDetails(userJid);
    toToast(
        getTranslated("remoteEngagedToast").replaceFirst("%d", data.getName()));

    debugPrint("***call list length ${callList.length}");
//The below condition (<= 2) -> (<2) is changed for Group call, to maintain the call to continue if there is a 2 users in call
    if (callList.length < 2) {
      // disconnectOutgoingCall();
    } else {
      removeUser(callMode, userJid, callType);
    }
  }

  void videoMuteStatusChanged(String muteEvent, String userJid) {
    var callUserIndex =
        callList.indexWhere((element) => element.userJid!.value == userJid);
    if (!callUserIndex.isNegative) {
      debugPrint("index $callUserIndex");
      callList[callUserIndex]
          .isVideoMuted(muteEvent == MuteStatus.remoteVideoMute);
    } else {
      debugPrint(
          "#Mirrorfly call User Not Found in list to video mute the status");
    }
  }

  void onUserLeft(String callMode, String userJid, String callType) {
    if (callList.length > 2 &&
        !callList
            .indexWhere(
                (element) => element.userJid.toString() == userJid.toString())
            .isNegative) {
      CallUtils.getNameOfJid(userJid).then((value) =>
          toToast(getTranslated("userLeftOnCall").replaceFirst("%d", value)));
    }
    removeUser(callMode, userJid, callType);
  }

  void removeUser(String callMode, String userJid, String callType) {
    debugPrint("before removeUser ${callList.length}");
    debugPrint(
        "before removeUser index ${callList.indexWhere((element) => element.userJid!.value == userJid)}");
    callList.removeWhere((element) {
      debugPrint("removeUser callStatus ${element.callStatus}");
      return element.userJid!.value == userJid;
    });
    speakingUsers.removeWhere((element) => element.userJid == userJid);
    debugPrint("after removeUser ${callList.length}");
    debugPrint(
        "removeUser ${callList.indexWhere((element) => element.userJid.toString() == userJid)}");
  }

  void updateStatus(String userJid, String callStatus) {
    if (callList.isEmpty) {
      debugPrint("skipping statusUpdate as list is empty");
      return;
    }

    var indexOfItem =
        callList.indexWhere((element) => element.userJid!.value == userJid);

    /// check the index is valid or not
    if (!indexOfItem.isNegative && callStatus != CallStatus.disconnected) {
      debugPrint("indexOfItem of call status update $indexOfItem $callStatus");

      /// update the current status of the user in the list
      callList[indexOfItem].callStatus?.value = (callStatus);
    }
  }

  Future<void> updateProfile(String jid) async {
    if (jid.isNotEmpty) {
      var callListIndex =
          callList.indexWhere((element) => element.userJid!.value == jid);
      if (!callListIndex.isNegative) {
        callList[callListIndex].userJid!("");
        callList[callListIndex].userJid!(jid);
      }
    }
  }

  @override
  void blockedThisUser(String userJid) {
    // TODO: implement blockedThisUser
  }

  @override
  void myProfileUpdated() {
    // TODO: implement myProfileUpdated
  }

  @override
  void onAdminBlockedOtherUser(String jid, String chatType, String isBlocked) {
    // TODO: implement onAdminBlockedOtherUser
  }

  @override
  void onAdminBlockedUser(String jid, String isBlocked) {
    // TODO: implement onAdminBlockedUser
  }

  @override
  void onContactSyncComplete(bool isSuccess) {
    // TODO: implement onContactSyncComplete
  }

  @override
  void unblockedThisUser(String jid) {
    // TODO: implement unblockedThisUser
  }

  @override
  void userBlockedMe(String jid) {
    // TODO: implement userBlockedMe
  }

  @override
  void userDeletedHisProfile(String jid) {
    // TODO: implement userDeletedHisProfile
  }

  @override
  void userProfileFetched(String jid, ProfileData profileData) {
    // TODO: implement userProfileFetched
  }

  @override
  void userUnBlockedMe(String jid) {
    // TODO: implement userUnBlockedMe
  }

  @override
  void usersIBlockedListFetched(List<String> jidList) {
    // TODO: implement usersIBlockedListFetched
  }

  @override
  void usersProfilesFetched() {
    // TODO: implement usersProfilesFetched
  }

  @override
  void usersWhoBlockedMeListFetched(List<String> jidList) {
    // TODO: implement usersWhoBlockedMeListFetched
  }

  @override
  void userUpdatedHisProfile(String jid) {
    updateProfile(jid);
  }

  @override
  void onIncomingCallReceived(String callAction) {
    // TODO: implement onIncomingCallReceived
  }
}
