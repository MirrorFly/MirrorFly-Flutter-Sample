import 'dart:convert';

import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:flysdk/flysdk.dart';
import 'package:mirror_fly_demo/app/modules/chat/controllers/chat_controller.dart';
import 'package:mirror_fly_demo/app/modules/chat/controllers/contact_controller.dart';
import 'package:mirror_fly_demo/app/modules/group/controllers/group_info_controller.dart';
import 'package:mirror_fly_demo/app/modules/settings/views/blocked/blocked_list_controller.dart';

import 'common/main_controller.dart';
import 'modules/archived_chats/archived_chat_list_controller.dart';
import 'modules/chat/controllers/forwardchat_controller.dart';
import 'modules/chatInfo/controllers/chat_info_controller.dart';
import 'modules/dashboard/controllers/dashboard_controller.dart';
import 'modules/dashboard/controllers/recent_chat_search_controller.dart';
import 'modules/message_info/controllers/message_info_controller.dart';
import 'modules/starred_messages/controllers/starred_messages_controller.dart';

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
    FlyChat.unblockedThisUser.listen((event){
      var data = json.decode(event.toString());
      var jid = data["jid"];
      unblockedThisUser(jid);
    });
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
    ChatMessageModel chatMessageModel = sendMessageModelFromJson(chatMessage);

    if (Get.isRegistered<ChatController>()) {
      Get.find<ChatController>().onMessageReceived(chatMessageModel);
    }
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().onMessageReceived(chatMessageModel);
    }
    if (Get.isRegistered<ArchivedChatListController>()) {
      Get.find<ArchivedChatListController>().onMessageReceived(chatMessageModel);
    }

  }

  void onMessageStatusUpdated(event) {
    ChatMessageModel chatMessageModel = sendMessageModelFromJson(event);

    if (Get.isRegistered<ChatController>()) {
      Get.find<ChatController>().onMessageStatusUpdated(chatMessageModel);
    }
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().onMessageStatusUpdated(chatMessageModel);
    }
    if (Get.isRegistered<MessageInfoController>()) {
      Get.find<MessageInfoController>().onMessageStatusUpdated(chatMessageModel);
    }
    if (Get.isRegistered<StarredMessagesController>()) {
      Get.find<StarredMessagesController>().onMessageStatusUpdated(chatMessageModel);
    }
  }

  void onMediaStatusUpdated(event) {
    ChatMessageModel chatMessageModel = sendMessageModelFromJson(event);

    if (Get.isRegistered<ChatController>()) {
      Get.find<ChatController>().onMediaStatusUpdated(chatMessageModel);
    }
    if (Get.isRegistered<StarredMessagesController>()) {
      Get.find<StarredMessagesController>().onMediaStatusUpdated(chatMessageModel);
    }

  }

  void onGroupProfileFetched(groupJid) {}

  void onNewGroupCreated(groupJid) {}

  void onGroupProfileUpdated(groupJid) {
    mirrorFlyLog("flutter GroupProfileUpdated", groupJid.toString());
    if (Get.isRegistered<ChatController>()) {
      Get.find<ChatController>().onGroupProfileUpdated(groupJid);
    }
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().onGroupProfileUpdated(groupJid);
    }
  }

  void onNewMemberAddedToGroup(event) {}

  void onMemberRemovedFromGroup(event) {}

  void onFetchingGroupMembersCompleted(groupJid) {}

  void onDeleteGroup(groupJid) {
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().onDeleteGroup(groupJid);
    }
  }

  void onFetchingGroupListCompleted(noOfGroups) {}

  void onMemberMadeAsAdmin(event) {}

  void onMemberRemovedAsAdmin(event) {}

  void onLeftFromGroup({required String groupJid, required String userJid}) {
    if (Get.isRegistered<ChatController>()) {
      Get.find<ChatController>().onLeftFromGroup(groupJid: groupJid, userJid : userJid);
    }
  }

  void onGroupNotificationMessage(event) {}

  void onGroupDeletedLocally(groupJid) {
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().onGroupDeletedLocally(groupJid);
    }
  }

  void blockedThisUser(result) {}

  void myProfileUpdated(result) {}

  void onAdminBlockedUser(String jid, bool status) {
    Get.find<MainController>().handleAdminBlockedUser(jid, status);

  }

  void onContactSyncComplete(result) {
    mirrorFlyLog("onContactSyncComplete", result.toString());
    //FlyChat.getRegisteredUsers(true).then((value) => mirrorFlyLog("registeredUsers", value.toString()));
  }

  void onLoggedOut(result) {}

  void unblockedThisUser(String jid) {
    mirrorFlyLog("unblockedThisUser", jid.toString());
    if (Get.isRegistered<ChatController>()) {
      Get.find<ChatController>().unblockedThisUser(jid);
    }
  }

  void userBlockedMe(result) {}

  void userCameOnline(String jid) {
    if (Get.isRegistered<ChatController>()) {
      Get.find<ChatController>().userCameOnline(jid);
    }
  }

  void userDeletedHisProfile(result) {}

  void userProfileFetched(result) {}

  void userUnBlockedMe(result) {}

  void userUpdatedHisProfile(String jid) {
    mirrorFlyLog("userUpdatedHisProfile", jid.toString());

    if (Get.isRegistered<ChatController>()) {
      Get.find<ChatController>().userUpdatedHisProfile(jid);
    }
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().userUpdatedHisProfile(jid);
    }
    if (Get.isRegistered<ForwardChatController>()) {
      Get.find<ForwardChatController>().userUpdatedHisProfile(jid);
    }
    if (Get.isRegistered<ArchivedChatListController>()) {
      Get.find<ArchivedChatListController>().userUpdatedHisProfile(jid);
    }
    if (Get.isRegistered<RecentChatSearchController>()) {
      Get.find<RecentChatSearchController>().userUpdatedHisProfile(jid);
    }
    if (Get.isRegistered<ContactController>()) {
      Get.find<ContactController>().userUpdatedHisProfile(jid);
    }
    if (Get.isRegistered<ChatInfoController>()) {
      Get.find<ChatInfoController>().userUpdatedHisProfile(jid);
    }
    if (Get.isRegistered<StarredMessagesController>()) {
      Get.find<StarredMessagesController>().userUpdatedHisProfile(jid);
    }
    if (Get.isRegistered<BlockedListController>()) {
      Get.find<BlockedListController>().userUpdatedHisProfile(jid);
    }
    if (Get.isRegistered<GroupInfoController>()) {
      Get.find<GroupInfoController>().userUpdatedHisProfile(jid);
    }
  }

  void userWentOffline(String jid) {
    if (Get.isRegistered<ChatController>()) {
      Get.find<ChatController>().userWentOffline(jid);
    }
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
      String singleOrgroupJid, String userId, String typingStatus) {
    if (Get.isRegistered<ChatController>()) {
      Get.find<ChatController>().setTypingStatus(singleOrgroupJid, userId, typingStatus);
    }
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().setTypingStatus(singleOrgroupJid, userId, typingStatus);
    }
    if (Get.isRegistered<ArchivedChatListController>()) {
      Get.find<ArchivedChatListController>()
          .setTypingStatus(singleOrgroupJid, userId, typingStatus);
    }
  }

  void onChatTypingStatus(result) {}

  void onGroupTypingStatus(result) {}

  void onFailure(result) {}

  void onProgressChanged(result) {}

  void onSuccess(result) {}
}
