import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:flysdk/flysdk.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/data/session_management.dart';
import 'package:mirror_fly_demo/app/modules/chat/controllers/chat_controller.dart';
import 'package:mirror_fly_demo/app/modules/chat/controllers/contact_controller.dart';
import 'package:mirror_fly_demo/app/modules/contact_sync/controllers/contact_sync_controller.dart';
import 'package:mirror_fly_demo/app/modules/group/controllers/group_info_controller.dart';
import 'package:mirror_fly_demo/app/modules/settings/views/blocked/blocked_list_controller.dart';
import 'package:mirror_fly_demo/app/routes/app_pages.dart';

import 'common/main_controller.dart';
import 'common/notification_service.dart';
import 'modules/archived_chats/archived_chat_list_controller.dart';
import 'modules/chat/controllers/forwardchat_controller.dart';
import 'modules/chatInfo/controllers/chat_info_controller.dart';
import 'modules/dashboard/controllers/dashboard_controller.dart';
// import 'modules/dashboard/controllers/recent_chat_search_controller.dart';
import 'modules/message_info/controllers/message_info_controller.dart';
import 'modules/starred_messages/controllers/starred_messages_controller.dart';

abstract class BaseController {

  initListeners() {
    FlyChat.onMessageReceived.listen(onMessageReceived);
    FlyChat.onMessageStatusUpdated.listen(onMessageStatusUpdated);
    FlyChat.onMediaStatusUpdated.listen(onMediaStatusUpdated);
    FlyChat.onUploadDownloadProgressChanged.listen((event){
      var data = json.decode(event.toString());
      var messageId = data["message_id"] ?? "";
      var progressPercentage = data["progress_percentage"] ?? 0;
      onUploadDownloadProgressChanged(messageId,progressPercentage);
    });
    FlyChat.onGroupProfileFetched.listen(onGroupProfileFetched);
    FlyChat.onNewGroupCreated.listen(onNewGroupCreated);
    FlyChat.onGroupProfileUpdated.listen(onGroupProfileUpdated);
    FlyChat.onNewMemberAddedToGroup.listen((event){
      if(event!=null){
        var data = json.decode(event.toString());
        var groupJid = data["groupJid"] ?? "";
        var newMemberJid = data["newMemberJid"] ?? "";
        var addedByMemberJid = data["addedByMemberJid"] ?? "";
        onNewMemberAddedToGroup(groupJid: groupJid, newMemberJid: newMemberJid,addedByMemberJid: addedByMemberJid);
      }
    });
    FlyChat.onMemberRemovedFromGroup.listen((event){
      if(event!=null){
        var data = json.decode(event.toString());
        var groupJid = data["groupJid"] ?? "";
        var removedMemberJid = data["removedMemberJid"] ?? "";
        var removedByMemberJid = data["removedByMemberJid"] ?? "";
        onMemberRemovedFromGroup(groupJid: groupJid, removedMemberJid: removedMemberJid,removedByMemberJid: removedByMemberJid);
      }
    });
    FlyChat.onFetchingGroupMembersCompleted
        .listen(onFetchingGroupMembersCompleted);
    FlyChat.onDeleteGroup.listen(onDeleteGroup);
    FlyChat.onFetchingGroupListCompleted.listen(onFetchingGroupListCompleted);
    FlyChat.onMemberMadeAsAdmin.listen((event){
      if(event!=null){
        var data = json.decode(event.toString());
        var groupJid = data["groupJid"] ?? "";
        var newAdminMemberJid = data["newAdminMemberJid"] ?? "";
        var madeByMemberJid = data["madeByMemberJid"] ?? "";
        onMemberMadeAsAdmin(groupJid: groupJid, newAdminMemberJid: newAdminMemberJid,madeByMemberJid: madeByMemberJid);
      }
    });
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
    FlyChat.userBlockedMe.listen((event){
          var data = json.decode(event.toString());
          var jid = data["jid"];
          userBlockedMe(jid.toString());
        });//{"jid":"919894940560@fly-qa19.mirrorfly.com"}
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
    FlyChat.onLoggedOut.listen(onLogout);
  }

  void onMessageReceived(chatMessage) {
    mirrorFlyLog("flutter onMessageReceived", chatMessage.toString());
    ChatMessageModel chatMessageModel = sendMessageModelFromJson(chatMessage);
    if(SessionManagement.getCurrentChatJID().checkNull() == chatMessageModel.chatUserJid.checkNull()){
      debugPrint("Message Received user chat screen is in online");
    }else{
     showLocalNotification(chatMessageModel);
    }

    if (Get.isRegistered<ChatController>()) {
      debugPrint("basecontroller ChatController registered");
      Get.find<ChatController>().onMessageReceived(chatMessageModel);
    }
    if (Get.isRegistered<DashboardController>()) {
      debugPrint("basecontroller DashboardController registered");
      Get.find<DashboardController>().onMessageReceived(chatMessageModel);
    }
    if (Get.isRegistered<ArchivedChatListController>()) {
      debugPrint("basecontroller ArchivedChatListController registered");
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

  void onUploadDownloadProgressChanged(String messageId, int progressPercentage){
    if (Get.isRegistered<ChatController>()) {
      Get.find<ChatController>().onUploadDownloadProgressChanged(messageId,progressPercentage);
    }
    /*if (Get.isRegistered<StarredMessagesController>()) {
      Get.find<StarredMessagesController>().onUploadDownloadProgressChanged(messageId,progressPercentage);
    }*/
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
    if (Get.isRegistered<GroupInfoController>()) {
      Get.find<GroupInfoController>().onGroupProfileUpdated(groupJid);
    }
  }

  void onNewMemberAddedToGroup({required String groupJid,
  required String newMemberJid, required String addedByMemberJid}) {
    debugPrint('onNewMemberAddedToGroup $newMemberJid');
    if (Get.isRegistered<GroupInfoController>()) {
      Get.find<GroupInfoController>().onNewMemberAddedToGroup(groupJid: groupJid, newMemberJid: newMemberJid, addedByMemberJid: addedByMemberJid);
    }
    if (Get.isRegistered<ChatController>()) {
      Get.find<ChatController>().onNewMemberAddedToGroup(groupJid: groupJid, newMemberJid: newMemberJid, addedByMemberJid: addedByMemberJid);
    }
  }

  void onMemberRemovedFromGroup({required String groupJid,
    required String removedMemberJid, required String removedByMemberJid}) {
    debugPrint('onMemberRemovedFromGroup $removedMemberJid');
    if (Get.isRegistered<GroupInfoController>()) {
      Get.find<GroupInfoController>().onMemberRemovedFromGroup(groupJid: groupJid, removedMemberJid: removedMemberJid, removedByMemberJid: removedByMemberJid);
    }
    if (Get.isRegistered<ChatController>()) {
      Get.find<ChatController>().onMemberRemovedFromGroup(groupJid: groupJid, removedMemberJid: removedMemberJid, removedByMemberJid: removedByMemberJid);
    }
  }

  void onFetchingGroupMembersCompleted(groupJid) {}

  void onDeleteGroup(groupJid) {
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().onDeleteGroup(groupJid);
    }
  }

  void onFetchingGroupListCompleted(noOfGroups) {}

  void onMemberMadeAsAdmin({required String groupJid,
    required String newAdminMemberJid, required String madeByMemberJid}) {
    debugPrint('onMemberMadeAsAdmin $newAdminMemberJid');
    if (Get.isRegistered<GroupInfoController>()) {
      Get.find<GroupInfoController>().onMemberMadeAsAdmin(groupJid: groupJid, newAdminMemberJid: newAdminMemberJid, madeByMemberJid: madeByMemberJid);
    }
  }

  void onMemberRemovedAsAdmin(event) {
    debugPrint('onMemberRemovedAsAdmin $event');
  }

  void onLeftFromGroup({required String groupJid, required String userJid}) {
    if (Get.isRegistered<ChatController>()) {
      Get.find<ChatController>().onLeftFromGroup(groupJid: groupJid, userJid : userJid);
    }
    if (Get.isRegistered<GroupInfoController>()) {
      Get.find<GroupInfoController>().onLeftFromGroup(groupJid: groupJid, userJid : userJid);
    }
  }

  void onGroupNotificationMessage(event) {
    debugPrint('onGroupNotificationMessage $event');
    ChatMessageModel chatMessageModel = sendMessageModelFromJson(event);
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().onMessageReceived(chatMessageModel);
    }
    if (Get.isRegistered<ArchivedChatListController>()) {
      Get.find<ArchivedChatListController>().onMessageReceived(chatMessageModel);
    }
    if (Get.isRegistered<ChatController>()) {
      Get.find<ChatController>().onMessageReceived(chatMessageModel);
    }
  }

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

  void onContactSyncComplete(bool result) {
    mirrorFlyLog("onContactSyncComplete", result.toString());
    // FlyChat.getRegisteredUsers(true);
    if(result) {
      SessionManagement.setInitialContactSync(true);
      SessionManagement.setSyncDone(true);
    }
    if (Get.isRegistered<ContactSyncController>()) {
      Get.find<ContactSyncController>().onContactSyncComplete(result);
    }
    if (Get.isRegistered<ContactController>()) {
      Get.find<ContactController>().onContactSyncComplete(result);
    }
    if (Get.isRegistered<ForwardChatController>()) {
      Get.find<ForwardChatController>().onContactSyncComplete(result);
    }
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().onContactSyncComplete(result);
    }
    if (Get.isRegistered<ChatController>()) {
      Get.find<ChatController>().onContactSyncComplete(result);
    }
    if (Get.isRegistered<ChatInfoController>()) {
      Get.find<ChatInfoController>().onContactSyncComplete(result);
    }
    //FlyChat.getRegisteredUsers(true).then((value) => mirrorFlyLog("registeredUsers", value.toString()));
  }

  void onLoggedOut(result) {
    mirrorFlyLog('logout called', result.toString());
  }

  void unblockedThisUser(String jid) {
    mirrorFlyLog("unblockedThisUser", jid.toString());
    if (Get.isRegistered<ChatController>()) {
      Get.find<ChatController>().unblockedThisUser(jid);
    }
    if (Get.isRegistered<ChatInfoController>()) {
      Get.find<ChatInfoController>().unblockedThisUser(jid);
    }
    if (Get.isRegistered<GroupInfoController>()) {
      Get.find<GroupInfoController>().unblockedThisUser(jid);
    }
    if (Get.isRegistered<ContactController>()) {
      Get.find<ContactController>().unblockedThisUser(jid);
    }
  }

  void userBlockedMe(String jid) {
    mirrorFlyLog('userBlockedMe', jid.toString());
    if (Get.isRegistered<ChatController>()) {
      Get.find<ChatController>().userBlockedMe(jid);
    }
    if (Get.isRegistered<ChatInfoController>()) {
      Get.find<ChatInfoController>().userBlockedMe(jid);
    }
    if (Get.isRegistered<GroupInfoController>()) {
      Get.find<GroupInfoController>().userBlockedMe(jid);
    }
    if (Get.isRegistered<ContactController>()) {
      Get.find<ContactController>().userBlockedMe(jid);
    }
  }

  void userCameOnline(String jid) {
    if (Get.isRegistered<ChatController>()) {
      Get.find<ChatController>().userCameOnline(jid);
    }
    if (Get.isRegistered<ChatInfoController>()) {
      Get.find<ChatInfoController>().userCameOnline(jid);
    }
  }

  void userDeletedHisProfile(String jid) {
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().userDeletedHisProfile(jid);
    }
    if (Get.isRegistered<ChatController>()) {
      Get.find<ChatController>().userDeletedHisProfile(jid);
    }
    if (Get.isRegistered<ArchivedChatListController>()) {
      Get.find<ArchivedChatListController>().userDeletedHisProfile(jid);
    }
    if (Get.isRegistered<ContactController>()) {
      Get.find<ContactController>().userDeletedHisProfile(jid);
    }
    if (Get.isRegistered<BlockedListController>()) {
      Get.find<BlockedListController>().userDeletedHisProfile(jid);
    }
    if (Get.isRegistered<ForwardChatController>()) {
      Get.find<ForwardChatController>().userDeletedHisProfile(jid);
    }
    if (Get.isRegistered<ChatInfoController>()) {
      Get.find<ChatInfoController>().userDeletedHisProfile(jid);
    }
    if (Get.isRegistered<GroupInfoController>()) {
      Get.find<GroupInfoController>().userDeletedHisProfile(jid);
    }
    if (Get.isRegistered<StarredMessagesController>()) {
      Get.find<StarredMessagesController>().userDeletedHisProfile(jid);
    }
  }

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
    /*if (Get.isRegistered<RecentChatSearchController>()) {
      Get.find<RecentChatSearchController>().userUpdatedHisProfile(jid);
    }*/
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
    if (Get.isRegistered<ChatInfoController>()) {
      Get.find<ChatInfoController>().userWentOffline(jid);
    }
  }

  void usersIBlockedListFetched(result) {}

  void usersWhoBlockedMeListFetched(result) {}

  void onConnected(result) {}

  void onDisconnected(result) {
    mirrorFlyLog('onDisconnected', result.toString());
  }

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

  Future<void> showLocalNotification(ChatMessageModel chatMessageModel) async {
    debugPrint("showing local notification");
    var isUserMuted = await FlyChat.isMuted(chatMessageModel.chatUserJid);
    var isUserUnArchived = await FlyChat.isUserUnArchived(chatMessageModel.chatUserJid);
    var isArchivedSettingsEnabled =  await FlyChat.isArchivedSettingsEnabled();

    var archiveSettings = isArchivedSettingsEnabled.checkNull() ? isUserUnArchived.checkNull() : true;

    if(!chatMessageModel.isMessageSentByMe && !isUserMuted.checkNull() && archiveSettings) {
      final String? notificationUri = SessionManagement.getNotificationUri();
      final UriAndroidNotificationSound uriSound = UriAndroidNotificationSound(
          notificationUri!);
      debugPrint("notificationUri--> $notificationUri");
      int id = DateTime
          .now()
          .millisecond;
      debugPrint("id--> $id");
      AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(chatMessageModel.messageId, 'MirrorFly',
          importance: Importance.max,
          priority: Priority.high,
          sound: uriSound,
          styleInformation: const DefaultStyleInformation(true, true));
      NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);
      await flutterLocalNotificationsPlugin.show(
          id, chatMessageModel.senderUserName,
          chatMessageModel.messageTextContent, notificationDetails,
          payload: chatMessageModel.chatUserJid);
    }else{
      debugPrint("self sent message don't need notification");
    }
  }

  void onLogout(isLogout) {
    mirrorFlyLog('Get.currentRoute', Get.currentRoute);
    if(isLogout && Get.currentRoute != Routes.login){
      Helper.progressLoading();
      FlyChat.logoutOfChatSDK().then((value) {
        Helper.hideLoading();
        if(value) {
          var token = SessionManagement.getToken().checkNull();
          SessionManagement.clear().then((value){
            SessionManagement.setToken(token);
            Get.offAllNamed(Routes.login);
          });
        }else{
          Get.snackbar("Logout", "Logout Failed");
        }
      }).catchError((er){
        Helper.hideLoading();
        SessionManagement.clear().then((value){
          // SessionManagement.setToken(token);
          Get.offAllNamed(Routes.login);
        });
      });
    }
  }
}
