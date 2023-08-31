import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mirror_fly_demo/app/call_modules/outgoing_call/call_controller.dart';
import 'package:mirrorfly_plugin/logmessage.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
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
import 'model/chat_message_model.dart';
import 'model/notification_message_model.dart';
import 'modules/archived_chats/archived_chat_list_controller.dart';
import 'modules/chat/controllers/forwardchat_controller.dart';
import 'modules/chatInfo/controllers/chat_info_controller.dart';
import 'modules/dashboard/controllers/dashboard_controller.dart';
// import 'modules/dashboard/controllers/recent_chat_search_controller.dart';
import 'modules/message_info/controllers/message_info_controller.dart';
import 'modules/notification/notification_builder.dart';
import 'modules/starred_messages/controllers/starred_messages_controller.dart';
import 'modules/view_all_media/controllers/view_all_media_controller.dart';

abstract class BaseController {

  initListeners() {
    Mirrorfly.onMessageReceived.listen(onMessageReceived);
    Mirrorfly.onMessageStatusUpdated.listen(onMessageStatusUpdated);
    Mirrorfly.onMediaStatusUpdated.listen(onMediaStatusUpdated);
    Mirrorfly.onUploadDownloadProgressChanged.listen((event){
      var data = json.decode(event.toString());
      debugPrint("Media Status Onprogress changed---> flutter $data");
      var messageId = data["message_id"] ?? "";
      var progressPercentage = data["progress_percentage"] ?? 0;
      onUploadDownloadProgressChanged(messageId,progressPercentage.toString());
    });
    Mirrorfly.onGroupProfileFetched.listen(onGroupProfileFetched);
    Mirrorfly.onNewGroupCreated.listen(onNewGroupCreated);
    Mirrorfly.onGroupProfileUpdated.listen(onGroupProfileUpdated);
    Mirrorfly.onNewMemberAddedToGroup.listen((event){
      if(event!=null){
        var data = json.decode(event.toString());
        var groupJid = data["groupJid"] ?? "";
        var newMemberJid = data["newMemberJid"] ?? "";
        var addedByMemberJid = data["addedByMemberJid"] ?? "";
        onNewMemberAddedToGroup(groupJid: groupJid, newMemberJid: newMemberJid,addedByMemberJid: addedByMemberJid);
      }
    });
    Mirrorfly.onMemberRemovedFromGroup.listen((event){
      if(event!=null){
        var data = json.decode(event.toString());
        var groupJid = data["groupJid"] ?? "";
        var removedMemberJid = data["removedMemberJid"] ?? "";
        var removedByMemberJid = data["removedByMemberJid"] ?? "";
        onMemberRemovedFromGroup(groupJid: groupJid, removedMemberJid: removedMemberJid,removedByMemberJid: removedByMemberJid);
      }
    });
    Mirrorfly.onFetchingGroupMembersCompleted
        .listen(onFetchingGroupMembersCompleted);
    Mirrorfly.onDeleteGroup.listen(onDeleteGroup);
    Mirrorfly.onFetchingGroupListCompleted.listen(onFetchingGroupListCompleted);
    Mirrorfly.onMemberMadeAsAdmin.listen((event){
      if(event!=null){
        var data = json.decode(event.toString());
        var groupJid = data["groupJid"] ?? "";
        var newAdminMemberJid = data["newAdminMemberJid"] ?? "";
        var madeByMemberJid = data["madeByMemberJid"] ?? "";
        onMemberMadeAsAdmin(groupJid: groupJid, newAdminMemberJid: newAdminMemberJid,madeByMemberJid: madeByMemberJid);
      }
    });
    Mirrorfly.onMemberRemovedAsAdmin.listen(onMemberRemovedAsAdmin);
    Mirrorfly.onLeftFromGroup.listen((event) {
      if (event != null) {
        var data = json.decode(event.toString());
        var groupJid = data["groupJid"] ?? "";
        var leftUserJid = data["leftUserJid"] ?? "";
        onLeftFromGroup(groupJid: groupJid, userJid: leftUserJid);
      }
    });
    Mirrorfly.onGroupNotificationMessage.listen(onGroupNotificationMessage);
    Mirrorfly.onGroupDeletedLocally.listen(onGroupDeletedLocally);

    Mirrorfly.blockedThisUser.listen(blockedThisUser);
    Mirrorfly.myProfileUpdated.listen(myProfileUpdated);
    Mirrorfly.onAdminBlockedUser.listen((event) {
      var data = json.decode(event.toString());
      var jid = data["jid"];
      var status = data["status"];
      onAdminBlockedUser(jid, status);
    });
    Mirrorfly.onContactSyncComplete.listen(onContactSyncComplete);
    Mirrorfly.unblockedThisUser.listen((event){
      var data = json.decode(event.toString());
      var jid = data["jid"];
      unblockedThisUser(jid);
    });
    Mirrorfly.userBlockedMe.listen((event){
          var data = json.decode(event.toString());
          var jid = data["jid"];
          userBlockedMe(jid.toString());
        });//{"jid":"919894940560@fly-qa19.mirrorfly.com"}
    Mirrorfly.userCameOnline.listen((event){
      var data = json.decode(event.toString());
      var jid = data["jid"];
      userCameOnline(jid);
    });
    Mirrorfly.userDeletedHisProfile.listen(userDeletedHisProfile);
    Mirrorfly.userProfileFetched.listen(userProfileFetched);
    Mirrorfly.userUnBlockedMe.listen(userUnBlockedMe);
    Mirrorfly.userUpdatedHisProfile.listen((event) {
      var data = json.decode(event.toString());
      var jid = data["jid"];
      userUpdatedHisProfile(jid);
    });
    Mirrorfly.userWentOffline.listen((event){
      var data = json.decode(event.toString());
      var jid = data["jid"];
      userWentOffline(jid);
    });
    Mirrorfly.usersIBlockedListFetched.listen(usersIBlockedListFetched);
    Mirrorfly.usersWhoBlockedMeListFetched.listen(usersWhoBlockedMeListFetched);
    Mirrorfly.onConnected.listen(onConnected);
    Mirrorfly.onDisconnected.listen(onDisconnected);
    // Mirrorfly.onConnectionNotAuthorized.listen(onConnectionNotAuthorized);
    // Mirrorfly.onConnectionFailed.listen(onConnectionFailed);
    Mirrorfly.connectionFailed.listen(connectionFailed);
    Mirrorfly.connectionSuccess.listen(connectionSuccess);
    Mirrorfly.onWebChatPasswordChanged.listen(onWebChatPasswordChanged);
    Mirrorfly.setTypingStatus.listen((event) {
      var data = json.decode(event.toString());
      mirrorFlyLog("setTypingStatus", data.toString());
      var singleOrgroupJid = data["singleOrgroupJid"];
      var userJid = data["userJid"];
      var typingStatus = data["status"];
      setTypingStatus(singleOrgroupJid, userJid, typingStatus);
    });
    Mirrorfly.onChatTypingStatus.listen(onChatTypingStatus);
    Mirrorfly.onGroupTypingStatus.listen(onGroupTypingStatus);
    Mirrorfly.onFailure.listen(onFailure);
    Mirrorfly.onProgressChanged.listen(onProgressChanged);
    Mirrorfly.onSuccess.listen(onSuccess);
    Mirrorfly.onLoggedOut.listen(onLogout);

    Mirrorfly.onLocalVideoTrackAdded.listen((event) {

    });
    Mirrorfly.onRemoteVideoTrackAdded.listen((event) {

    });
    Mirrorfly.onTrackAdded.listen((event) {
      debugPrint("#Mirrorfly Call track added --> $event");
    });
    Mirrorfly.onCallStatusUpdated.listen((event) {
      // {"callMode":"OneToOne","userJid":"","callType":"video","callStatus":"Attended"}
      debugPrint("#MirrorflyCall onCallStatusUpdated --> $event");

      var statusUpdateReceived = jsonDecode(event);
      var callMode = statusUpdateReceived["callMode"].toString();
      var userJid = statusUpdateReceived["userJid"].toString();
      var callType = statusUpdateReceived["callType"].toString();
      var callStatus = statusUpdateReceived["callStatus"].toString();

      if (Get.isRegistered<CallController>()) {
        Get.find<CallController>().statusUpdate(userJid,callStatus);
      }

      switch (callStatus){
        case CallStatus.connecting:
          break;
        case CallStatus.onResume:
          break;
        case CallStatus.userJoined:
          break;
        case CallStatus.userLeft:
          break;
        case CallStatus.inviteCallTimeout:
          break;
        case CallStatus.attended:
          if(Get.currentRoute!=Routes.onGoingCallView) {
            debugPrint("***opening cal page");
            Get.toNamed(
                Routes.onGoingCallView, arguments: { "userJid": userJid});
          }
          break;

        case CallStatus.disconnected:
          stopTimer();
          if (Get.isRegistered<CallController>()) {
            Get.find<CallController>().callDisconnected(
                callMode, userJid, callType);
          }else{
            debugPrint("#Mirrorfly call call controller not registered for disconnect event");
          }
          break;
        case CallStatus.calling10s:
          break;
        case CallStatus.callingAfter10s:
          break;
        case CallStatus.calling:
          if (Get.isRegistered<CallController>()) {
            Get.find<CallController>().calling(
                callMode, userJid, callType, callStatus);
          }else{
            debugPrint("#Mirrorfly call call controller not registered for calling event");
          }
          break;
        case CallStatus.reconnected:
          if (Get.isRegistered<CallController>()) {
            Get.find<CallController>().reconnected(
                callMode, userJid, callType, callStatus);
          }else{
            debugPrint("#Mirrorfly call call controller not registered for reconnected event");
          }
          break;
        case CallStatus.ringing:
          if (Get.isRegistered<CallController>()) {
            Get.find<CallController>().ringing(
                callMode, userJid, callType, callStatus);
          }else{
            debugPrint("#Mirrorfly call call controller not registered for ringing event");
          }
          break;
        case CallStatus.onHold:
          if (Get.isRegistered<CallController>()) {
            Get.find<CallController>().onHold(
                callMode, userJid, callType, callStatus);
          }else{
            debugPrint("#Mirrorfly call call controller not registered for onHold event");
          }
          break;
        case CallStatus.connected:
          startTimer();
          if (Get.isRegistered<CallController>()) {
            Get.find<CallController>().connected(
                callMode, userJid, callType, callStatus);
          }else{
            debugPrint("#Mirrorfly call call controller not registered for connected event");
          }
          break;

        case CallStatus.callTimeout:
          if (Get.isRegistered<CallController>()) {
            Get.find<CallController>().timeout(
                callMode, userJid, callType, callStatus);
          }else{
            debugPrint("#Mirrorfly call call controller not registered for timeout event");
          }
          break;

        default:
          debugPrint("onCall status updated error: $callStatus");
      }


    });
    Mirrorfly.onCallAction.listen((event) {
      // {"callAction":"REMOTE_HANGUP","userJid":""}
      mirrorFlyLog("onCallAction", "$event");
      var actionReceived = jsonDecode(event);
      var callAction = actionReceived["callAction"].toString();
      var userJid = actionReceived["userJid"].toString();
      var callMode = actionReceived["callMode"].toString();
      var callType = actionReceived["callType"].toString();
      switch(callAction){
        case CallAction.localHangup:{
          stopTimer();
          if (Get.isRegistered<CallController>()) {
            //if user hangup the call from background notification
            Get.find<CallController>().localHangup(
                callMode, userJid, callType, callAction);
          }
          break;
        }
        //if we called on user B, the user B is decline the call then this will be triggered in Android
        case CallAction.remoteBusy:{
          //in Android, showing this user is busy toast inside SDK
          //toToast("User is Busy");
          if (Get.isRegistered<CallController>()) {
            Get.find<CallController>().remoteBusy(
                callMode, userJid, callType, callAction);
          }
          break;
        }
      //if we called on user B, the user B is disconnect the call after connect then this will be triggered in Android
        case CallAction.remoteHangup:{
          if (Get.isRegistered<CallController>()) {
            Get.find<CallController>().remoteHangup(
                callMode, userJid, callType, callAction);
          }
          break;
        }
        //if we called on user B, the user B is on another call then this will triggered
        case CallAction.remoteEngaged:{
          if (Get.isRegistered<CallController>()) {
            Get.find<CallController>().remoteEngaged();
          }
          break;
        }
        case CallAction.audioDeviceChanged:{
          debugPrint("call action audioDeviceChanged");
          if (Get.isRegistered<CallController>()) {
            Get.find<CallController>().audioDeviceChanged();
          }
          break;
        }
      }
    });
    Mirrorfly.onMuteStatusUpdated.listen((event) {
      mirrorFlyLog("onMuteStatusUpdated", "$event");
      var muteStatus = jsonDecode(event);
      var muteEvent = muteStatus["muteEvent"].toString();
      var userJid = muteStatus["userJid"].toString();
      if(Get.isRegistered<CallController>()){
        if(muteEvent == MuteStatus.remoteAudioMute || muteEvent == MuteStatus.remoteAudioUnMute) {
          Get.find<CallController>().audioMuteStatusChanged(muteEvent, userJid);
        }
      }

    });
    Mirrorfly.onUserSpeaking.listen((event) {
      mirrorFlyLog("onUserSpeaking", "$event");
    });
    Mirrorfly.onUserStoppedSpeaking.listen((event) {
      mirrorFlyLog("onUserSpeaking", "$event");
    });
  }

  void onMessageReceived(chatMessage) {
    mirrorFlyLog("flutter onMessageReceived", chatMessage.toString());
    ChatMessageModel chatMessageModel = sendMessageModelFromJson(chatMessage);
    // debugPrint("")
    if(SessionManagement.getCurrentChatJID() == chatMessageModel.chatUserJid.checkNull()){
      debugPrint("Message Received user chat screen is in online");
    }else{
      var data = chatMessageFromJson(chatMessage.toString());
      if(data.messageId!=null) {
        NotificationBuilder.createNotification(data);
      }
     // showLocalNotification(chatMessageModel);
    }

    if (Get.isRegistered<ChatController>()) {
      // debugPrint("basecontroller ChatController registered");
      Get.find<ChatController>().onMessageReceived(chatMessageModel);
    }
    if (Get.isRegistered<DashboardController>()) {
      // debugPrint("basecontroller DashboardController registered");
      Get.find<DashboardController>().onMessageReceived(chatMessageModel);
    }
    if (Get.isRegistered<ArchivedChatListController>()) {
      // debugPrint("basecontroller ArchivedChatListController registered");
      Get.find<ArchivedChatListController>().onMessageReceived(chatMessageModel);
    }

    if(Get.isRegistered<ViewAllMediaController>() && chatMessageModel.isTextMessage() && chatMessageModel.messageTextContent!.contains("http")){
      Get.find<ViewAllMediaController>().onMessageReceived(chatMessageModel);
    }

  }

  void onMessageDeleteNotifyUI(String chatJid){
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().updateRecentChat(chatJid);
    }
  }

  void clearAllConvRecentChatUI(){
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().getRecentChatList();
    }
  }

  void onMessageStatusUpdated(event) {
    ChatMessageModel chatMessageModel = sendMessageModelFromJson(event);

    if(SessionManagement.getCurrentChatJID() == chatMessageModel.chatUserJid.checkNull()){
      debugPrint("Message Status updated user chat screen is in online");
    }else{
        var data = chatMessageFromJson(event.toString());
        if(data.isMessageRecalled.checkNull()) {
          // NotificationBuilder.createNotification(data);
        }
        // showLocalNotification(chatMessageModel);
    }

    if (Get.isRegistered<ChatController>()) {
      Get.find<ChatController>().onMessageStatusUpdated(chatMessageModel);
    }
    if (Get.isRegistered<ArchivedChatListController>()) {
      Get.find<ArchivedChatListController>().onMessageStatusUpdated(chatMessageModel);
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

  void markConversationReadNotifyUI(String jid) {
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().markConversationReadNotifyUI(jid);
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

    if(Get.isRegistered<ViewAllMediaController>() && chatMessageModel.isMediaMessage() && (chatMessageModel.isMediaUploaded() || chatMessageModel.isMediaDownloaded())){
      Get.find<ViewAllMediaController>().onMediaStatusUpdated(chatMessageModel);
    }

  }

  void onUploadDownloadProgressChanged(String messageId, String progressPercentage){
    if (Get.isRegistered<ChatController>()) {
      Get.find<ChatController>().onUploadDownloadProgressChanged(messageId,progressPercentage);
    }
    if (Get.isRegistered<StarredMessagesController>()) {
      Get.find<StarredMessagesController>().onUploadDownloadProgressChanged(messageId,progressPercentage);
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
    if(SessionManagement.getCurrentChatJID() == chatMessageModel.chatUserJid.checkNull()){
      debugPrint("Message Received group chat screen is in online");
    }else{
      var data = chatMessageFromJson(event.toString());
      debugPrint("notificationMadeByME ${notificationMadeByME(data)}");
      //checked own notification for (if group notification made by me like group member add,remove)
      if(data.messageId!=null && !notificationMadeByME(data)) {
        NotificationBuilder.createNotification(data);
      }
      // showLocalNotification(chatMessageModel);
    }
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

  bool notificationMadeByME(ChatMessage data){
    return data.messageTextContent.checkNull().startsWith("You added") || data.messageTextContent.checkNull().startsWith("You left") || data.messageTextContent.checkNull().startsWith("You removed") || data.messageTextContent.checkNull().startsWith("You created");
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

  void onContactSyncComplete(dynamic result) {
    mirrorFlyLog("onContactSyncComplete", result.toString());
    // Mirrorfly.getRegisteredUsers(true);
    if(result as bool) {
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
    //Mirrorfly.getRegisteredUsers(true).then((value) => mirrorFlyLog("registeredUsers", value.toString()));
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

  void userDeletedHisProfile(dynamic jid) {
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().userDeletedHisProfile(jid.toString());
    }
    if (Get.isRegistered<ChatController>()) {
      Get.find<ChatController>().userDeletedHisProfile(jid.toString());
    }
    if (Get.isRegistered<ArchivedChatListController>()) {
      Get.find<ArchivedChatListController>().userDeletedHisProfile(jid.toString());
    }
    if (Get.isRegistered<ContactController>()) {
      Get.find<ContactController>().userDeletedHisProfile(jid.toString());
    }
    if (Get.isRegistered<BlockedListController>()) {
      Get.find<BlockedListController>().userDeletedHisProfile(jid.toString());
    }
    if (Get.isRegistered<ForwardChatController>()) {
      Get.find<ForwardChatController>().userDeletedHisProfile(jid.toString());
    }
    if (Get.isRegistered<ChatInfoController>()) {
      Get.find<ChatInfoController>().userDeletedHisProfile(jid.toString());
    }
    if (Get.isRegistered<GroupInfoController>()) {
      Get.find<GroupInfoController>().userDeletedHisProfile(jid.toString());
    }
    if (Get.isRegistered<StarredMessagesController>()) {
      Get.find<StarredMessagesController>().userDeletedHisProfile(jid.toString());
    }
  }

  void userProfileFetched(result) {}

  void userUnBlockedMe(result) {
    mirrorFlyLog("userUnBlockedMe", result);
    var data = json.decode(result.toString());
    var jid = data["jid"];
    unblockedThisUser(jid);
  }

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

  // void onConnectionNotAuthorized(result) {}
  // void onConnectionFailed(result) {}

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
    var isUserMuted = await Mirrorfly.isMuted(chatMessageModel.chatUserJid);
    var isUserUnArchived = await Mirrorfly.isUserUnArchived(chatMessageModel.chatUserJid);
    var isArchivedSettingsEnabled =  await Mirrorfly.isArchivedSettingsEnabled();

    var archiveSettings = isArchivedSettingsEnabled.checkNull() ? isUserUnArchived.checkNull() : true;

    if(!chatMessageModel.isMessageSentByMe && !isUserMuted.checkNull() && archiveSettings) {
      final String? notificationUri = SessionManagement.getNotificationUri();
      final UriAndroidNotificationSound uriSound = UriAndroidNotificationSound(
          notificationUri!);
      debugPrint("notificationUri--> $notificationUri");

      var messageId = chatMessageModel.messageSentTime.toString().substring(chatMessageModel.messageSentTime.toString().length - 5);
      debugPrint("Mani Message ID $messageId");
      AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(chatMessageModel.messageId, 'MirrorFly',
          importance: Importance.max,
          priority: Priority.high,
          sound: uriSound,
          styleInformation: const DefaultStyleInformation(true, true));
      DarwinNotificationDetails iosNotificationDetails =
      DarwinNotificationDetails(
        categoryIdentifier: darwinNotificationCategoryPlain,
        sound: notificationUri,
        presentSound: true,
        presentBadge: true,
        presentAlert: true
      );

      NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails, iOS: iosNotificationDetails);
      await flutterLocalNotificationsPlugin.show(
          12345, chatMessageModel.senderUserName,
          chatMessageModel.isMessageRecalled.value ? "This message was deleted" : chatMessageModel.messageTextContent, notificationDetails,
          payload: chatMessageModel.chatUserJid);
    }else{
      debugPrint("self sent message don't need notification");
    }
  }

  void onLogout(isLogout) {
    mirrorFlyLog('Get.currentRoute', Get.currentRoute);
    if(isLogout && Get.currentRoute != Routes.login && SessionManagement.getLogin()){
      var token = SessionManagement.getToken().checkNull();
      SessionManagement.clear().then((value) {
        SessionManagement.setToken(token);
        Get.offAllNamed(Routes.login);
      });
      // Helper.progressLoading();
      // Mirrorfly.logoutOfChatSDK().then((value) {
      //   Helper.hideLoading();
      //   if(value) {
      //     var token = SessionManagement.getToken().checkNull();
      //     SessionManagement.clear().then((value){
      //       SessionManagement.setToken(token);
      //       Get.offAllNamed(Routes.login);
      //     });
      //   }else{
      //     Get.snackbar("Logout", "Logout Failed");
      //   }
      // }).catchError((er){
      //   Helper.hideLoading();
      //   SessionManagement.clear().then((value){
      //     // SessionManagement.setToken(token);
      //     Get.offAllNamed(Routes.login);
      //   });
      // });
    }
  }

  Timer? timer;
  void startTimer() {
    // if (timer == null) {
    timer = null;
      const oneSec = Duration(seconds: 1);
      var startTime = DateTime.now();
      timer = Timer.periodic(
        oneSec,
            (Timer timer) {
          final minDur = DateTime
              .now()
              .difference(startTime)
              .inMinutes;
          final secDur = DateTime
              .now()
              .difference(startTime)
              .inSeconds % 60;
          String min = minDur < 10 ? "0$minDur" : minDur.toString();
          String sec = secDur < 10 ? "0$secDur" : secDur.toString();
          var time = "$min:$sec";
          LogMessage.d("callTimer", time);
          if (Get.isRegistered<CallController>()) {
            Get.find<CallController>().callDuration(time);
          }
        },
      );
    // }
  }
  void stopTimer(){
    timer?.cancel();
    timer=null;
  }
}
