import 'dart:convert';

import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:flysdk/flysdk.dart';

abstract class BaseController {
  initListeners() {
    FlyChat.onMessageReceived.listen(onMessageReceived);
    FlyChat.onMessageStatusUpdated.listen(onMessageStatusUpdated);
    FlyChat.onMediaStatusUpdated.listen(onMediaStatusUpdated);

    FlyChat.onGroupProfileFetched.listen(onGroupProfileFetched);
    FlyChat.onNewGroupCreated.listen(onNewGroupCreated);
    FlyChat.onGroupProfileUpdated.listen(onGroupProfileUpdated);
    FlyChat.onNewMemberAddedToGroup.listen(onNewMemberAddedToGroup);
    FlyChat.onMemberRemovedFromGroup.listen(onMemberRemovedFromGroup);
    FlyChat.onFetchingGroupMembersCompleted
        .listen(onFetchingGroupMembersCompleted);
    FlyChat.onDeleteGroup.listen(onDeleteGroup);
    FlyChat.onFetchingGroupListCompleted.listen(onFetchingGroupListCompleted);
    FlyChat.onMemberMadeAsAdmin.listen(onMemberMadeAsAdmin);
    FlyChat.onMemberRemovedAsAdmin.listen(onMemberRemovedAsAdmin);
    FlyChat.onLeftFromGroup.listen((event) {
      if (event != null) {
        var data = json.decode(event.toString());
        var groupJid = data["groupJid"] ?? "";
        var leftUserJid = data["leftUserJid"] ?? "";
        onLeftFromGroup(groupJid: groupJid, userJid: leftUserJid);
      }
    });
    FlyChat.onGroupNotificationMessage.listen(onGroupNotificationMessage);
    FlyChat.onGroupDeletedLocally.listen(onGroupDeletedLocally);

    FlyChat.blockedThisUser.listen(blockedThisUser);
    FlyChat.myProfileUpdated.listen(myProfileUpdated);
    FlyChat.onAdminBlockedUser.listen((event) {
      var data = json.decode(event.toString());
      var jid = data["jid"];
      var status = data["status"];
      onAdminBlockedUser(jid, status);
    });
    FlyChat.onContactSyncComplete.listen(onContactSyncComplete);
    FlyChat.onLoggedOut.listen(onLoggedOut);
    FlyChat.unblockedThisUser.listen(unblockedThisUser);
    FlyChat.userBlockedMe.listen(userBlockedMe);
    FlyChat.userCameOnline.listen((event){
      var data = json.decode(event.toString());
      var jid = data["jid"];
      userCameOnline(jid);
    });
    FlyChat.userDeletedHisProfile.listen(userDeletedHisProfile);
    FlyChat.userProfileFetched.listen(userProfileFetched);
    FlyChat.userUnBlockedMe.listen(userUnBlockedMe);
    FlyChat.userUpdatedHisProfile.listen((event) {
      var data = json.decode(event.toString());
      var jid = data["jid"];
      userUpdatedHisProfile(jid);
    });
    FlyChat.userWentOffline.listen((event){
      var data = json.decode(event.toString());
      var jid = data["jid"];
      userWentOffline(jid);
    });
    FlyChat.usersIBlockedListFetched.listen(usersIBlockedListFetched);
    FlyChat.usersWhoBlockedMeListFetched.listen(usersWhoBlockedMeListFetched);
    FlyChat.onConnected.listen(onConnected);
    FlyChat.onDisconnected.listen(onDisconnected);
    FlyChat.onConnectionNotAuthorized.listen(onConnectionNotAuthorized);
    FlyChat.connectionFailed.listen(connectionFailed);
    FlyChat.connectionSuccess.listen(connectionSuccess);
    FlyChat.onWebChatPasswordChanged.listen(onWebChatPasswordChanged);
    FlyChat.setTypingStatus.listen((event) {
      var data = json.decode(event.toString());
      mirrorFlyLog("setTypingStatus", data.toString());
      var singleOrgroupJid = data["singleOrgroupJid"];
      var userId = data["userId"];
      var typingStatus = data["composing"];
      setTypingStatus(singleOrgroupJid, userId, typingStatus);
    });
    FlyChat.onChatTypingStatus.listen(onChatTypingStatus);
    FlyChat.onGroupTypingStatus.listen(onGroupTypingStatus);
    FlyChat.onFailure.listen(onFailure);
    FlyChat.onProgressChanged.listen(onProgressChanged);
    FlyChat.onSuccess.listen(onSuccess);
  }

  void onMessageReceived(chatMessage) {
    mirrorFlyLog("flutter onMessageReceived", chatMessage.toString());
  }

  void onMessageStatusUpdated(event) {
    //Log("flutter onMessageStatusUpdated", event.toString());
  }

  void onMediaStatusUpdated(event) {}

  void onGroupProfileFetched(groupJid) {}

  void onNewGroupCreated(groupJid) {}

  void onGroupProfileUpdated(groupJid) {
    mirrorFlyLog("flutter GroupProfileUpdated", groupJid.toString());
  }

  void onNewMemberAddedToGroup(event) {}

  void onMemberRemovedFromGroup(event) {}

  void onFetchingGroupMembersCompleted(groupJid) {}

  void onDeleteGroup(groupJid) {}

  void onFetchingGroupListCompleted(noOfGroups) {}

  void onMemberMadeAsAdmin(event) {}

  void onMemberRemovedAsAdmin(event) {}

  void onLeftFromGroup({required String groupJid, required String userJid}) {}

  void onGroupNotificationMessage(event) {}

  void onGroupDeletedLocally(groupJid) {}

  void blockedThisUser(result) {}

  void myProfileUpdated(result) {}

  void onAdminBlockedUser(String jid, bool status) {}

  void onContactSyncComplete(result) {
    mirrorFlyLog("onContactSyncComplete", result.toString());
    //FlyChat.getRegisteredUsers(true).then((value) => mirrorFlyLog("registeredUsers", value.toString()));
  }

  void onLoggedOut(result) {}

  void unblockedThisUser(result) {}

  void userBlockedMe(result) {}

  void userCameOnline(String jid) {
    // debugPrint("userCameOnline : $jid");
  }

  void userDeletedHisProfile(result) {}

  void userProfileFetched(result) {}

  void userUnBlockedMe(result) {}

  void userUpdatedHisProfile(String jid) {
    mirrorFlyLog("userUpdatedHisProfile", jid.toString());
  }

  void userWentOffline(String jid) {
    // debugPrint("userWentOffline : $jid");
  }

  void usersIBlockedListFetched(result) {}

  void usersWhoBlockedMeListFetched(result) {}

  void onConnected(result) {}

  void onDisconnected(result) {}

  void onConnectionNotAuthorized(result) {}

  void connectionFailed(result) {}

  void connectionSuccess(result) {}

  void onWebChatPasswordChanged(result) {}

  void setTypingStatus(
      String singleOrgroupJid, String userId, String typingStatus) {}

  void onChatTypingStatus(result) {}

  void onGroupTypingStatus(result) {}

  void onFailure(result) {}

  void onProgressChanged(result) {}

  void onSuccess(result) {}
}
