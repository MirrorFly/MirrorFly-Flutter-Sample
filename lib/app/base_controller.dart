import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/call_modules/pip_view/pip_view_controller.dart';
import 'package:mirror_fly_demo/app/modules/chat/controllers/schedule_calender.dart';
import 'package:mirror_fly_demo/app/modules/backup_restore/backup_utils/backup_restore_manager.dart';
import 'package:mirror_fly_demo/app/modules/scanner/web_login_controller.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'call_modules/call_timeout/controllers/call_timeout_controller.dart';
import 'call_modules/group_participants/group_participants_controller.dart';
import 'call_modules/join_call_preview/join_call_controller.dart';
import 'call_modules/outgoing_call/call_controller.dart';
import 'call_modules/outgoing_call/call_swap_state.dart';
import 'call_modules/outgoing_call/outgoing_call_controller.dart';
import 'call_modules/participants/add_participants_controller.dart';
import 'common/app_localizations.dart';
import 'common/constants.dart';
import 'data/helper.dart';
import 'data/session_management.dart';
import 'extensions/extensions.dart';
import 'modules/backup_restore/controllers/backup_controller.dart';
import 'modules/backup_restore/controllers/restore_controller.dart';
import 'modules/chat/controllers/chat_controller.dart';
import 'modules/chat/controllers/contact_controller.dart';
import 'modules/contact_sync/controllers/contact_sync_controller.dart';
import 'modules/group/controllers/group_info_controller.dart';
import 'modules/media_preview/controllers/media_preview_controller.dart';
import 'modules/settings/views/blocked/blocked_list_controller.dart';
import 'routes/route_settings.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';

import 'common/main_controller.dart';
import 'common/notification_service.dart';
import 'data/utils.dart';
import 'model/chat_message_model.dart';
import 'model/notification_message_model.dart';
import 'modules/archived_chats/archived_chat_list_controller.dart';
import 'modules/chat/controllers/forwardchat_controller.dart';
import 'modules/chatInfo/controllers/chat_info_controller.dart';
import 'modules/dashboard/controllers/dashboard_controller.dart';
// import 'modules/dashboard/controllers/recent_chat_search_controller.dart';
import 'modules/message_info/controllers/message_info_controller.dart';
import 'modules/notification/notification_builder.dart';
import 'modules/profile/controllers/profile_controller.dart';
import 'modules/starred_messages/controllers/starred_messages_controller.dart';
import 'modules/view_all_media/controllers/view_all_media_controller.dart';

class BaseController {
  static void initListeners() {
    Mirrorfly.getCurrentCallDuration().then((value){
      var startTime = value ?? 0;
      if(startTime>0){
        var difference = (DateTime.now().millisecondsSinceEpoch-startTime);
        startTimer(time: difference);
      }
    });
    Mirrorfly.onMessageReceived.listen(onMessageReceived);
    Mirrorfly.onMessageStatusUpdated.listen(onMessageStatusUpdated);
    Mirrorfly.onMediaStatusUpdated.listen(onMediaStatusUpdated);
    Mirrorfly.onUploadDownloadProgressChanged.listen((event){
      var data = json.decode(event.toString());
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
    // Mirrorfly.onDeleteGroup.listen(onDeleteGroup);
    // Mirrorfly.onFetchingGroupListCompleted.listen(onFetchingGroupListCompleted);
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
    Mirrorfly.onSuperAdminDeleteGroup.listen((event) {
      if(event!=null) {
        var data = json.decode(event.toString());
        var groupJid = data["groupJid"] ?? "";
        var groupName = data["groupName"] ?? "";
        onSuperAdminDeleteGroup(groupJid: groupJid, groupName: groupName);
      }

    });
    Mirrorfly.onLeftFromGroup.listen((event) {
      if (event != null) {
        var data = json.decode(event.toString());
        var groupJid = data["groupJid"] ?? "";
        var leftUserJid = data["leftUserJid"] ?? "";
        onLeftFromGroup(groupJid: groupJid, userJid: leftUserJid);
      }
    });
    Mirrorfly.onGroupNotificationMessage.listen(onGroupNotificationMessage);
    Mirrorfly.showOrUpdateOrCancelNotification.listen((event){
      LogMessage.d("showOrUpdateOrCancelNotification",event);
      var data  = json.decode(event.toString());
      var jid = data["jid"];
      var chatMessage = sendMessageModelFromJson(data["chatMessage"]);
      showOrUpdateOrCancelNotification(jid,chatMessage);
    });
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
    Mirrorfly.userDeletedHisProfile.listen((event){
      var data = json.decode(event.toString());
      var jid = data["jid"];
      userDeletedHisProfile(jid);
    });
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
    Mirrorfly.onConnectionFailed.listen(onConnectionFailed);
    // Mirrorfly.onWebChatPasswordChanged.listen(onWebChatPasswordChanged);
    Mirrorfly.typingStatus.listen((event) {
      var data = json.decode(event.toString());
      LogMessage.d("setTypingStatus", data.toString());
      var singleOrgroupJid = data["singleOrgroupJid"];
      var userJid = data["userJid"];
      var typingStatus = data["status"];
      setTypingStatus(singleOrgroupJid, userJid, typingStatus);
    });

    //#editMessage
    Mirrorfly.onMessageEdited.listen(onMessageEdited);

    Mirrorfly.onLoggedOut.listen(onLogout);

    Mirrorfly.onMissedCall.listen((event){
      LogMessage.d("onMissedCall", event);
      var data = json.decode(event.toString());
      var isOneToOneCall = data["isOneToOneCall"];
      var userJid = data["userJid"];
      var groupId = data["groupId"];
      var callType = data["callType"];
      var userList = data["userList"].toString().split(",");
      Future.delayed(const Duration(seconds: 2), () {
        // for same user chat page is opened
        onMissedCall(isOneToOneCall, userJid, groupId, callType, userList);
      });
    });

    Mirrorfly.onLocalVideoTrackAdded.listen((event) {});
    Mirrorfly.onRemoteVideoTrackAdded.listen((event) {});
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

      if (Get.isRegistered<OutgoingCallController>()) {
        Get.find<OutgoingCallController>().statusUpdate(userJid, callStatus);
      }
      if (Get.isRegistered<CallController>()) {
        Get.find<CallController>().statusUpdate(userJid, callStatus);
      }

      switch (callStatus) {
        case CallStatus.connecting:
          break;
        case CallStatus.onResume:
          if (Get.isRegistered<CallController>()) {
            Get.find<CallController>().onResume(
                callMode, userJid, callType, callStatus);
          } else {
            debugPrint("#Mirrorfly call call controller not registered for onHold event");
          }
          break;
        case CallStatus.userJoined:
          if (Get.isRegistered<CallController>()) {
            Get.find<CallController>().onUserJoined(callMode, userJid, callType, callStatus);
          }
          break;
        case CallStatus.userLeft:
          //{"callStatus":"User_Left","userJid":"919789482015@xmpp-uikit-qa.contus.us","callType":"audio","callMode":"onetomany"}
          if (Get.isRegistered<CallController>()) {
            Get.find<CallController>().onUserLeft(callMode, userJid, callType);
          }
          break;
        case CallStatus.inviteCallTimeout:
          break;
        case CallStatus.attended:
          debugPrint("onCallStatusUpdated Current Route ${NavUtils.currentRoute}");
          /*if (NavUtils.currentRoute == Routes.callTimeOutView) {
            debugPrint("onCallStatusUpdated Inside Get.back");
            NavUtils.back();
          }*/
          if (callMode.toLowerCase() == CallMode.meet){
            /// This condition is added as the meet link,
            /// when joining we will be receiving the "Attended" in call status update,
            /// which makes the route to navigate to ongoing call screen.
            /// But we will be redirecting to ongoing call screen manually
            /// on clicking join now button in join_call_controller => joinCall() function
            LogMessage.d("CallStatus Received for Meet link", statusUpdateReceived);
            return;
          }
          if (NavUtils.currentRoute != Routes.onGoingCallView && NavUtils.currentRoute !=
              Routes.participants) {
            debugPrint("onCallStatusUpdated ***opening cal page");
            if (NavUtils.currentRoute == Routes.outGoingCallView || NavUtils.currentRoute == Routes.callTimeOutView) {
              NavUtils.offNamed(Routes.onGoingCallView, arguments: {
                "userJid": [userJid]
              });
            }else{
              NavUtils.toNamed(Routes.onGoingCallView, arguments: {
                "userJid": [userJid]
              });
            }
          }
          break;

        case CallStatus.disconnected:
            if (Get.isRegistered<CallController>()) {
            /*Get.find<CallController>().callDisconnected(
                callMode, userJid, callType);*/ //commenting because when call disconnected we no need to check anything

            debugPrint("Call List length base controller ${Get.find<CallController>().callList.length}");

            Get.find<CallController>().callDisconnectedStatus();

            if (Get.find<CallController>().callList.length <= 1) {
              stopTimer();
            }
          } else {
            debugPrint(
                "#Mirrorfly call call controller not registered for disconnect event Route : ${NavUtils
                    .currentRoute}");
            // if(NavUtils.currentRoute==Routes.outGoingCallView || NavUtils.currentRoute==Routes.onGoingCallView){
            //   NavUtils.back();
            // }
          }
            if (Get.isRegistered<OutgoingCallController>()) {
              debugPrint(
                  "Call List length base controller ${Get.find<OutgoingCallController>().callList.length}");

              if (Get.isRegistered<OutgoingCallController>()) {
                Get.find<OutgoingCallController>()
                    .userDisconnection(callMode, userJid, callType);
              }

              if (Get.isRegistered<CallController>()) {
                if (Get.find<CallController>().callList.length <= 1) {
                  stopTimer();
                }
              } else {
                debugPrint(
                    "#Mirrorfly call CallController not registered for disconnect event");
              }
            } else {
              debugPrint(
                  "#Mirrorfly call Outgoing call controller not registered for disconnect event");
            }

            // Command the below line because we have handle the below functionality in the pip view controller

            // if (Get.isRegistered<PipViewController>(tag: "pipView")) {
            //   Get.find<PipViewController>(tag: "pipView").callDisconnected();
            //   stopTimer();
            // }
            // if (Get.isRegistered<PipViewController>()) {
            //   Get.find<PipViewController>().callDisconnected();
            //   stopTimer();
            // }
          break;
        case CallStatus.calling10s:
          break;
        case CallStatus.callingAfter10s:
          break;
        case CallStatus.calling:
          if (Get.isRegistered<CallController>()) {
            Get.find<CallController>().calling(callMode, userJid, callType, callStatus);
          } else {
            debugPrint("#Mirrorfly call call controller not registered for calling event");
          }
          break;
        case CallStatus.reconnected:
          if (Get.isRegistered<CallController>()) {
            Get.find<CallController>().reconnected(callMode, userJid, callType, callStatus);
          } else {
            debugPrint("#Mirrorfly call call controller not registered for reconnected event");
          }
          break;
        case CallStatus.ringing:
          if (Get.isRegistered<CallController>()) {
            Get.find<CallController>().ringing(callMode, userJid, callType, callStatus);
          } else {
            debugPrint("#Mirrorfly call call controller not registered for ringing event");
          }
          break;
        case CallStatus.onHold:
          if (Get.isRegistered<CallController>()) {
            Get.find<CallController>().onHold(callMode, userJid, callType, callStatus);
          } else {
            debugPrint("#Mirrorfly call call controller not registered for onHold event");
          }
          break;
        case CallStatus.connected:
          if (timer == null) {
            startTimer();
          }
          if (Get.isRegistered<OutgoingCallController>()) {
            Get.find<OutgoingCallController>().connected(callMode, userJid, callType, callStatus);
          }else{
            debugPrint("#Mirrorfly call OutgoingCallController not registered for connected event");
          }
          if (Get.isRegistered<CallController>()) {
            Get.find<CallController>().connected(callMode, userJid, callType, callStatus);
          } else {
            debugPrint("#Mirrorfly call call controller not registered for connected event");
          }
          break;

        case CallStatus.callTimeout:
          if (Get.isRegistered<OutgoingCallController>()) {
            Get.find<OutgoingCallController>().timeout(callMode, userJid, callType, callStatus);
          }
          if (Get.isRegistered<CallController>()) {
            Get.find<CallController>().timeout(callMode, userJid, callType, callStatus);
          } else {
            debugPrint("#Mirrorfly call call controller not registered for timeout event");
          }
          break;
        case CallStatus.callFailed:
            // Helper.showAlert(message: callStatus);
          toToast(callStatus);
          break;

        default:
          debugPrint("onCall status updated error: $callStatus");
      }
    });
    Mirrorfly.onCallAction.listen((event) {
      // {"callAction":"REMOTE_HANGUP","userJid":""}
      LogMessage.d("onCallAction", "$event");
      var actionReceived = jsonDecode(event);
      var callAction = actionReceived["callAction"].toString();
      var userJid = actionReceived["userJid"].toString();
      var callMode = actionReceived["callMode"].toString();
      var callType = actionReceived["callType"].toString();
      switch (callAction) {
        case CallAction.localHangup:
          {
            stopTimer();
            if (Get.isRegistered<OutgoingCallController>()) {
              //if user hangup the call from background notification
              Get.find<OutgoingCallController>().localHangup(callMode, userJid, callType, callAction);
            }
            if (Get.isRegistered<CallController>()) {
              //if user hangup the call from background notification
              Get.find<CallController>().localHangup(callMode, userJid, callType, callAction);
            }
            break;
          }
        case CallAction.inviteUsers:
          if (Get.isRegistered<CallController>()) {
            Get.find<CallController>().onUserInvite(callMode, userJid, callType);
          }
          if (Get.isRegistered<AddParticipantsController>()) {
            Get.find<AddParticipantsController>().onUserInvite(callMode, userJid, callType);
          }
          break;
        case CallAction.remoteOtherBusy:
          {
            // for group call users decline the call before attend
            if (Get.isRegistered<OutgoingCallController>()) {
              Get.find<OutgoingCallController>().remoteOtherBusy(callMode, userJid, callType, callAction);
            }
            if (Get.isRegistered<CallController>()) {
              Get.find<CallController>().remoteOtherBusy(callMode, userJid, callType, callAction);
            }
            break;
          }
        //if we called on user B, the user B is decline the call then this will be triggered in Android
        case CallAction.remoteBusy:
          {
            if (Get.isRegistered<OutgoingCallController>()) {
              Get.find<OutgoingCallController>().remoteBusy(callMode, userJid, callType, callAction);
            }
            if (Get.isRegistered<CallController>()) {
              Get.find<CallController>().remoteBusy(callMode, userJid, callType, callAction);
            }
            break;
          }
        //if we called on user B, the user B is disconnect the call after connect then this will be triggered in Android
        case CallAction.remoteHangup:
          {
            if (Get.isRegistered<CallController>()) {
              Get.find<CallController>().remoteHangup(callMode, userJid, callType, callAction);
            }
            break;
          }
        //if we called on user B, the user B is on another call then this will triggered
        case CallAction.remoteEngaged:
          {
            if (Get.isRegistered<OutgoingCallController>()) {
              Get.find<OutgoingCallController>().remoteEngaged(userJid, callMode, callType);
            }
            if (Get.isRegistered<CallController>()) {
              Get.find<CallController>().remoteEngaged(userJid, callMode, callType);
            }
            break;
          }
        case CallAction.audioDeviceChanged:
          {
            debugPrint("call action audioDeviceChanged");
            if (Get.isRegistered<OutgoingCallController>()) {
              Get.find<OutgoingCallController>().audioDeviceChanged();
            }
            if (Get.isRegistered<CallController>()) {
              Get.find<CallController>().audioDeviceChanged();
            }
            break;
          }
        case CallAction.denyCall:
          {
            debugPrint("call action denyCall");
            // local user deny the call
            if (Get.isRegistered<OutgoingCallController>()) {
              Get.find<OutgoingCallController>().denyCall();
            }
            if (Get.isRegistered<CallController>()) {
              Get.find<CallController>().denyCall();
            }
            break;
          }
        case CallAction.cameraSwitchSuccess:
          {
            debugPrint("call action switchCamera");
            // local user deny the call
            if (Get.isRegistered<OutgoingCallController>()) {
              Get.find<OutgoingCallController>().onCameraSwitch();
            }
            if (Get.isRegistered<CallController>()) {
              Get.find<CallController>().onCameraSwitch();
            }
            break;
          }
        case CallAction.changedToAudioCall:
          {
            debugPrint("call action Video Call Switched to Audio Call");
            // local user deny the call
            if (Get.isRegistered<OutgoingCallController>()) {
              Get.find<OutgoingCallController>().changedToAudioCall();
            }
            if (Get.isRegistered<CallController>()) {
              Get.find<CallController>().changedToAudioCall();
            }
            break;
          }
        case CallAction.videoCallConversionCancel:
          {
            debugPrint("#Mirrorfly call videoCallConversionCancel");
            // local user deny the call
            if (Get.isRegistered<CallController>()) {
              Get.find<CallController>().videoCallConversionCancel();
            }
            break;
          }
        case CallAction.videoCallConversionRequest:
          {
            debugPrint("#Mirrorfly call videoCallConversionRequest");
            // local user deny the call
            if (Get.isRegistered<CallController>()) {
              Get.find<CallController>().videoCallConversionRequest(userJid);
            }
            break;
          }
        case CallAction.videoCallConversionAccepted:
          {
            debugPrint("#Mirrorfly call videoCallConversionAccepted");
            // local user deny the call
            if (Get.isRegistered<CallController>()) {
              Get.find<CallController>().videoCallConversionAccepted();
            }
            break;
          }
        case CallAction.videoCallConversionRejected:
          {
            debugPrint("#Mirrorfly call videoCallConversionRejected");
            // local user deny the call
            if (Get.isRegistered<CallController>()) {
              Get.find<CallController>().videoCallConversionRejected();
            }
            break;
          }
      }
    });
    Mirrorfly.onMuteStatusUpdated.listen((event) {
      LogMessage.d("onMuteStatusUpdated", "$event");
      var muteStatus = jsonDecode(event);
      var muteEvent = muteStatus["muteEvent"].toString();
      var userJid = muteStatus["userJid"].toString();

      LogMessage.d("Get.isRegistered<CallController>()", "${Get.isRegistered<CallController>()}");
      if (Get.isRegistered<OutgoingCallController>()) {
        if (muteEvent == MuteStatus.remoteAudioMute || muteEvent == MuteStatus.remoteAudioUnMute) {
          Get.find<OutgoingCallController>().audioMuteStatusChanged(muteEvent, userJid);
        }
        if (muteEvent == MuteStatus.remoteVideoMute || muteEvent == MuteStatus.remoteVideoUnMute) {
          Get.find<OutgoingCallController>().videoMuteStatusChanged(muteEvent, userJid);
        }
      }
      if (Get.isRegistered<CallController>()) {
        if (muteEvent == MuteStatus.remoteAudioMute || muteEvent == MuteStatus.remoteAudioUnMute) {
          Get.find<CallController>().audioMuteStatusChanged(muteEvent, userJid);
        }
        if (muteEvent == MuteStatus.remoteVideoMute || muteEvent == MuteStatus.remoteVideoUnMute) {
          Get.find<CallController>().videoMuteStatusChanged(muteEvent, userJid);
        }
      }
    });
    Mirrorfly.onUserSpeaking.listen((event) {
      // LogMessage.d("onUserSpeaking", "$event");
      var data = json.decode(event.toString());
      var audioLevel = data["audioLevel"];
      var userJid = data["userJid"];
      if (Get.isRegistered<OutgoingCallController>()) {
        Get.find<OutgoingCallController>().onUserSpeaking(userJid, audioLevel);
      }
      if (Get.isRegistered<CallController>()) {
        Get.find<CallController>().onUserSpeaking(userJid, audioLevel);
      }
    });
    Mirrorfly.onUserStoppedSpeaking.listen((event) {
      // LogMessage.d("onUserSpeaking", "$event");
      if (Get.isRegistered<OutgoingCallController>()) {
        Get.find<OutgoingCallController>().onUserStoppedSpeaking(event.toString());
      }
      if (Get.isRegistered<CallController>()) {
        Get.find<CallController>().onUserStoppedSpeaking(event.toString());
      }
    });

    Mirrorfly.onAvailableFeaturesUpdated.listen(onAvailableFeaturesUpdated);

    Mirrorfly.onCallLogsUpdated.listen(onCallLogsUpdated);

    Mirrorfly.onCallLogsCleared.listen((event) {
      LogMessage.d("onCallLogsCleared", event);
      if(Get.isRegistered<DashboardController>()){
        Get.find<DashboardController>().onCallLogsCleared();
      }
    });

    Mirrorfly.onMessageDeleted.listen((event) async {
      LogMessage.d("onMessageDeleted", event);
      final Map<String, dynamic> rawJson = jsonDecode(event);
      final List<String>? messageIds = (rawJson['messageIds'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList();
      if (messageIds != null) {
        for (String id in messageIds) {
          if (Get.isRegistered<DashboardController>()) {
            Get.find<DashboardController>().onMessageDeleted(messageId: id);
          }
          if (Get.isRegistered<ChatController>(tag: controllerTag)) {
            Get.find<ChatController>(tag: controllerTag)
                .onMessageDeleted(messageId: id);
          }
          if (Get.isRegistered<ArchivedChatListController>()) {
            Get.find<ArchivedChatListController>()
                .onMessageDeleted(messageId: id);
          }
          if (Get.isRegistered<MessageInfoController>()) {
            Get.find<MessageInfoController>().onMessageDeleted(messageId: id);
          }
          if (Get.isRegistered<StarredMessagesController>()) {
            Get.find<StarredMessagesController>()
                .onMessageDeleted(messageId: id);
          }
        }
      } else {
        LogMessage.d("Invalid message delete event format", event);
      }
    });

    Mirrorfly.onAllChatsCleared.listen((event) {
      LogMessage.d("onAllChatsCleared", event);
    });

    Mirrorfly.onChatCleared.listen((event) {
      LogMessage.d("onChatCleared", event);
    });

    Mirrorfly.onArchiveUnArchiveChats.listen((event) {
      LogMessage.d("onArchiveUnArchiveChats", event);
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().updateArchiveChat();
      }
    });


    Mirrorfly.onArchivedSettingsUpdated.listen((event) {
      LogMessage.d("onArchivedSettingsUpdated", event);
    });

    Mirrorfly.onUpdateMuteSettings.listen((event) {
      LogMessage.d("onUpdateMuteSettings", event);
    });

    Mirrorfly.onWebLogout.listen(onWebLogout);

    Mirrorfly.onChatMuteStatusUpdated.listen((event) {
      LogMessage.d("onChatMuteStatusUpdated", event);
      final Map<String, dynamic>? json = jsonDecode(event);
      final bool? muteStatus = json?['muteStatus'];
      final List<String>? jidList =
          (json?['jidList'] as List?)?.map((e) => e.toString()).toList();

      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>()
            .onChatMuteStatusUpdated(muteStatus: muteStatus, jidList: jidList);
      }

      if (Get.isRegistered<ChatInfoController>()) {
        Get.find<ChatInfoController>()
            .onChatMuteStatusUpdated(muteStatus: muteStatus, jidList: jidList);
      }

      if (Get.isRegistered<GroupInfoController>()) {
        Get.find<GroupInfoController>()
            .onChatMuteStatusUpdated(muteStatus: muteStatus, jidList: jidList);
      }
    });

    initializeBackupListeners();
  }

  static void onCallLogsUpdated(value) {
    LogMessage.d("onCallLogUpdated", value);
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().onCallLogUpdate(value);
    }
  }

  static void onAvailableFeaturesUpdated(dynamic value) {
    LogMessage.d("onAvailableFeaturesUpdated", value);
    var features = availableFeaturesFromJson(value.toString());
    if (Get.isRegistered<MainController>()) {
      Get.find<MainController>().onAvailableFeatures(features);
    }
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().onAvailableFeaturesUpdated(features);
    }
    if (Get.isRegistered<ChatController>(tag: controllerTag )) {
      Get.find<ChatController>(tag: controllerTag).onAvailableFeaturesUpdated(features);
    }
    if (Get.isRegistered<MediaPreviewController>()) {
      Get.find<MediaPreviewController>().onAvailableFeaturesUpdated(features);
    }
    if (Get.isRegistered<ForwardChatController>()) {
      Get.find<ForwardChatController>().onAvailableFeaturesUpdated(features);
    }
    if (Get.isRegistered<GroupInfoController>()) {
      Get.find<GroupInfoController>().onAvailableFeaturesUpdated(features);
    }
    if (Get.isRegistered<ArchivedChatListController>()) {
      Get.find<ArchivedChatListController>().onAvailableFeaturesUpdated(features);
    }
    if (Get.isRegistered<GroupParticipantsController>()) {
      Get.find<GroupParticipantsController>().onAvailableFeaturesUpdated(features);
    }
    if (Get.isRegistered<ContactController>()) {
      Get.find<ContactController>().onAvailableFeaturesUpdated(features);
    }
    if (Get.isRegistered<AddParticipantsController>()) {
      Get.find<AddParticipantsController>().onAvailableFeaturesUpdated(features);
    }
  }

  static void onMessageReceived(chatMessage) {
    LogMessage.d("flutter onMessageReceived", chatMessage.toString());
    ChatMessageModel chatMessageModel = sendMessageModelFromJson(chatMessage);
    if (Get.isRegistered<ChatController>(tag: controllerTag)) {
      // debugPrint("basecontroller ChatController registered");
      Get.find<ChatController>(tag: controllerTag).onMessageReceived(chatMessageModel);
    }
    if (Get.isRegistered<DashboardController>()) {
      // debugPrint("basecontroller DashboardController registered");
      Get.find<DashboardController>().onMessageReceived(chatMessageModel);
    }
    if (Get.isRegistered<ArchivedChatListController>()) {
      // debugPrint("basecontroller ArchivedChatListController registered");
      Get.find<ArchivedChatListController>().onMessageReceived(chatMessageModel);
    }
    if (Get.isRegistered<ViewAllMediaController>() &&
        chatMessageModel.isTextMessage() &&
        chatMessageModel.messageTextContent!.contains("http")) {
      Get.find<ViewAllMediaController>().onMessageReceived(chatMessageModel);
    }
    if(chatMessageModel.messageType==MessageType.meet.value){
      ScheduleCalender().addEvent(chatMessageModel.meetChatMessage!);
    }
  }

  static void onMessageStatusUpdated(event) {
    ChatMessageModel chatMessageModel = sendMessageModelFromJson(event);
    if (Get.isRegistered<ChatController>(tag: controllerTag)) {
      Get.find<ChatController>(tag: controllerTag).onMessageStatusUpdated(chatMessageModel);
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

  void chatMuteChangesNotifyUI(String jid) {
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().chatMuteChangesNotifyUI(jid);
    }
  }

  static void onMediaStatusUpdated(event) {
    ChatMessageModel chatMessageModel = sendMessageModelFromJson(event);
    LogMessage.d("Media Status Updated",chatMessageModel.toJson());
    if (Get.isRegistered<ChatController>(tag: controllerTag)) {
      Get.find<ChatController>(tag: controllerTag).onMediaStatusUpdated(chatMessageModel);
    }
    if (Get.isRegistered<StarredMessagesController>()) {
      Get.find<StarredMessagesController>().onMediaStatusUpdated(chatMessageModel);
    }

    if (Get.isRegistered<ViewAllMediaController>() &&
        chatMessageModel.isMediaMessage() &&
        (chatMessageModel.isMediaUploaded() || chatMessageModel.isMediaDownloaded())) {
      Get.find<ViewAllMediaController>().onMediaStatusUpdated(chatMessageModel);
    }
    if (chatMessageModel.mediaChatMessage!.mediaUploadStatus.value == MediaUploadStatus.mediaUploadedNotAvailable.value) {
      toToast(getTranslated("mediaDoesNotExist"));
    } else if (chatMessageModel.mediaChatMessage!.mediaDownloadStatus.value == MediaDownloadStatus.storageNotEnough.value) {
      toToast(getTranslated("insufficientMemoryError"));
    }
  }

  static void onUploadDownloadProgressChanged(String messageId, String progressPercentage) {
    if (Get.isRegistered<ChatController>(tag: controllerTag)) {
      Get.find<ChatController>(tag: controllerTag).onUploadDownloadProgressChanged(messageId, progressPercentage);
    }
    if (Get.isRegistered<StarredMessagesController>()) {
      Get.find<StarredMessagesController>().onUploadDownloadProgressChanged(messageId, progressPercentage);
    }
  }

  static void onGroupProfileFetched(groupJid) {}

  static void onNewGroupCreated(groupJid) {
    // if (Get.isRegistered<ChatController>(tag: controllerTag)) {
    //   Get.find<ChatController>(tag: controllerTag).onUserAddedToGroup(groupJid: groupJid);
    // }
  }

  static void onGroupProfileUpdated(groupJid) {
    LogMessage.d("flutter GroupProfileUpdated", groupJid.toString());
    if (Get.isRegistered<ChatController>(tag: controllerTag)) {
      Get.find<ChatController>(tag: controllerTag).onGroupProfileUpdated(groupJid);
    }
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().onGroupProfileUpdated(groupJid);
    }
    if (Get.isRegistered<GroupInfoController>()) {
      Get.find<GroupInfoController>().onGroupProfileUpdated(groupJid);
    }
  }

  static void onNewMemberAddedToGroup(
      {required String groupJid, required String newMemberJid, required String addedByMemberJid}) {
    debugPrint('onNewMemberAddedToGroup $newMemberJid');
    if (Get.isRegistered<GroupInfoController>()) {
      Get.find<GroupInfoController>()
          .onNewMemberAddedToGroup(groupJid: groupJid, newMemberJid: newMemberJid, addedByMemberJid: addedByMemberJid);
    }
    if (Get.isRegistered<ChatController>(tag: controllerTag)) {
      Get.find<ChatController>(tag: controllerTag)
          .onNewMemberAddedToGroup(groupJid: groupJid, newMemberJid: newMemberJid, addedByMemberJid: addedByMemberJid);
    }
  }

  static void onMemberRemovedFromGroup(
      {required String groupJid, required String removedMemberJid, required String removedByMemberJid}) {
    debugPrint('onMemberRemovedFromGroup $removedMemberJid');
    if (Get.isRegistered<GroupInfoController>()) {
      Get.find<GroupInfoController>().onMemberRemovedFromGroup(
          groupJid: groupJid, removedMemberJid: removedMemberJid, removedByMemberJid: removedByMemberJid);
    }
    if (Get.isRegistered<ChatController>(tag: controllerTag)) {
      Get.find<ChatController>(tag: controllerTag).onMemberRemovedFromGroup(
          groupJid: groupJid, removedMemberJid: removedMemberJid, removedByMemberJid: removedByMemberJid);
    }
  }

  static void onFetchingGroupMembersCompleted(groupJid) {}

  static void onDeleteGroup(groupJid) {
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().onDeleteGroup(groupJid);
    }
  }

  // void onFetchingGroupListCompleted(noOfGroups) {}

  static void onMemberMadeAsAdmin(
      {required String groupJid, required String newAdminMemberJid, required String madeByMemberJid}) {
    debugPrint('onMemberMadeAsAdmin $newAdminMemberJid');
    if (Get.isRegistered<GroupInfoController>()) {
      Get.find<GroupInfoController>().onMemberMadeAsAdmin(
          groupJid: groupJid, newAdminMemberJid: newAdminMemberJid, madeByMemberJid: madeByMemberJid);
    }
  }

  static void onMemberRemovedAsAdmin(event) {
    debugPrint('onMemberRemovedAsAdmin $event');
  }

  static void onSuperAdminDeleteGroup({required String groupJid, required String groupName}) {
    debugPrint('onSuperAdminDeleteGroup groupJid - $groupJid groupName- $groupName');
    if (Get.isRegistered<GroupInfoController>()) {
      debugPrint('onSuperAdminDeleteGroup GroupInfoController registered');
      Get.find<GroupInfoController>().onSuperAdminDeleteGroup(
          groupJid: groupJid, groupName: groupName);
      return;
    }else{
      debugPrint('onSuperAdminDeleteGroup Group Info Controller not Found');
    }

    if (Get.isRegistered<ChatController>(tag: controllerTag)) {
      debugPrint('onSuperAdminDeleteGroup ChatController registered');
      Get.find<ChatController>(tag: controllerTag).onSuperAdminDeleteGroup(groupJid: groupJid, groupName: groupName);
      return;
    }else{
      debugPrint('onSuperAdminDeleteGroup ChatController with tag $controllerTag not Found');
    }
    if (Get.isRegistered<DashboardController>()) {
      debugPrint('onSuperAdminDeleteGroup DashboardController registered');
      Get.find<DashboardController>().deleteGroup(groupJid: groupJid, groupName: groupName);
      return;
    }else{
      debugPrint('onSuperAdminDeleteGroup ChatController with tag $controllerTag not Found');
    }
  }

  static void onLeftFromGroup({required String groupJid, required String userJid}) {
    debugPrint('onLeftFromGroup $groupJid $userJid');
    if (Get.isRegistered<ChatController>(tag: controllerTag)) {
      Get.find<ChatController>(tag: controllerTag).onLeftFromGroup(groupJid: groupJid, userJid: userJid);
    }
    if (Get.isRegistered<GroupInfoController>()) {
      Get.find<GroupInfoController>().onLeftFromGroup(groupJid: groupJid, userJid: userJid);
    }
  }

  static void onGroupNotificationMessage(event) {
    debugPrint('onGroupNotificationMessage $event');
    ChatMessageModel chatMessageModel = sendMessageModelFromJson(event);
    if (SessionManagement.getCurrentChatJID() == chatMessageModel.chatUserJid.checkNull()) {
      debugPrint("Message Received group chat screen is in online");
    } else {
      var data = chatMessageFromJson(event.toString());
      debugPrint("notificationMadeByME ${notificationMadeByME(data)}");
      //checked own notification for (if group notification made by me like group member add,remove)
      if(data.messageId.isNotEmpty && !notificationMadeByME(data)) {
        // NotificationBuilder.createNotification(data);
      }
      // showLocalNotification(chatMessageModel);
    }
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().onMessageReceived(chatMessageModel);
    }
    if (Get.isRegistered<ArchivedChatListController>()) {
      Get.find<ArchivedChatListController>().onMessageReceived(chatMessageModel);
    }
    if (Get.isRegistered<ChatController>(tag: controllerTag)) {
      Get.find<ChatController>(tag: controllerTag).onMessageReceived(chatMessageModel);
    }
  }

  static Future<void> showOrUpdateOrCancelNotification(String jid, ChatMessageModel chatMessage) async {
    if (SessionManagement.getCurrentChatJID() == chatMessage.chatUserJid.checkNull() || chatMessage.isMessageEdited.value.checkNull()) {
      return;
    }
    var profileDetails = await getProfileDetails(jid);
    if (profileDetails.isMuted == true) {
      return;
    }
    if(chatMessage.messageId.isNotEmpty) {
      NotificationBuilder.createNotification(chatMessage);
    }
  }

  static bool notificationMadeByME(ChatMessage data) {
    return data.messageTextContent.checkNull().startsWith("You added") ||
        data.messageTextContent.checkNull().startsWith("You left") ||
        data.messageTextContent.checkNull().startsWith("You removed") ||
        data.messageTextContent.checkNull().startsWith("You created");
  }

  static void onGroupDeletedLocally(groupJid) {
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().onGroupDeletedLocally(groupJid);
    }
  }

  static void blockedThisUser(result) {}

  static void myProfileUpdated(result) {
    var myJid = SessionManagement.getUserJID().checkNull();
    Mirrorfly.getUserProfile(jid: myJid,fetchFromServer: false,flyCallback:(FlyResponse response){
    LogMessage.d("MyProfileUpdated base controller getUserProfile", response.toString());
    if(response.isSuccess) {
      var data = profileDataFromJson(response.data);
      var userProfileData = ProData(
              email: data.data?.email,
              image: data.data?.image,
              mobileNumber: data.data?.mobileNumber,
              nickName: data.data?.nickName,
              name: data.data?.name,
              status: data.data?.status);
      SessionManagement.setCurrentUser(userProfileData);
    }else{
      LogMessage.d("Base Controller myProfileUpdated Error", response);
    }
    });

    if (Get.isRegistered<GroupInfoController>()) {
      Get.find<GroupInfoController>().myProfileUpdated();
    }
  }

  static void onAdminBlockedUser(String jid, bool status) {
    Get.find<MainController>().handleAdminBlockedUser(jid, status);
  }

  static void onContactSyncComplete(dynamic result) {
    LogMessage.d("onContactSyncComplete", result.toString());
    // Mirrorfly.getRegisteredUsers(true);
    if (result as bool) {
      SessionManagement.setInitialContactSync(true);
      SessionManagement.setSyncDone(true);
    }
    if (Get.isRegistered<ContactSyncController>()) {
      Get.find<ContactSyncController>().onContactSyncComplete(result);
    }
    if (Get.isRegistered<ContactController>()) {
      Get.find<ContactController>().onContactSyncComplete(result);
    }
    if (Get.isRegistered<AddParticipantsController>()) {
      Get.find<AddParticipantsController>().onContactSyncComplete(result);
    }
    if (Get.isRegistered<ForwardChatController>()) {
      Get.find<ForwardChatController>().onContactSyncComplete(result);
    }
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().onContactSyncComplete(result);
    }
    if (Get.isRegistered<ChatController>(tag: controllerTag)) {
      Get.find<ChatController>(tag: controllerTag).onContactSyncComplete(result);
    }
    if (Get.isRegistered<ChatInfoController>()) {
      Get.find<ChatInfoController>().onContactSyncComplete(result);
    }
    //Mirrorfly.getRegisteredUsers(true).then((value) => LogMessage.d("registeredUsers", value.toString()));
  }

  static void unblockedThisUser(String jid) {
    LogMessage.d("unblockedThisUser", jid.toString());
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().updateRecentChat(jid: jid, changePosition: false);
    }
    if (Get.isRegistered<ChatController>(tag: controllerTag)) {
      Get.find<ChatController>(tag: controllerTag).unblockedThisUser(jid);
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
    if (Get.isRegistered<AddParticipantsController>()) {
      Get.find<AddParticipantsController>().unblockedThisUser(jid);
    }
  }

  static void userBlockedMe(String jid) async{
    LogMessage.d('userBlockedMe', jid.toString());
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().updateRecentChat(jid: jid, changePosition: false);
    }
    if (Get.isRegistered<ChatController>(tag: controllerTag)) {
      Get.find<ChatController>(tag: controllerTag).userBlockedMe(jid);
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
    if (Get.isRegistered<AddParticipantsController>()) {
      Get.find<AddParticipantsController>().userBlockedMe(jid);
    }
    if (Get.isRegistered<CallController>()) {
      if((await Mirrorfly.isOnGoingCall()).checkNull()){
        Get.find<CallController>().disconnectCall();
      }
    }
  }

  static void userCameOnline(String jid) {
    if (Get.isRegistered<ChatController>(tag: controllerTag)) {
      Get.find<ChatController>(tag: controllerTag).userCameOnline(jid);
    }
    if (Get.isRegistered<ChatInfoController>()) {
      Get.find<ChatInfoController>().userCameOnline(jid);
    }
  }

  static void userDeletedHisProfile(dynamic jid) {
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().userDeletedHisProfile(jid.toString());
    }
    if (Get.isRegistered<ChatController>(tag: controllerTag)) {
      Get.find<ChatController>(tag: controllerTag).userDeletedHisProfile(jid.toString());
    }
    if (Get.isRegistered<ArchivedChatListController>()) {
      Get.find<ArchivedChatListController>().userDeletedHisProfile(jid.toString());
    }
    if (Get.isRegistered<ContactController>()) {
      Get.find<ContactController>().userDeletedHisProfile(jid.toString());
    }
    if (Get.isRegistered<AddParticipantsController>()) {
      Get.find<AddParticipantsController>().userDeletedHisProfile(jid.toString());
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

  static void userProfileFetched(result) {}

  static void userUnBlockedMe(result) {
    LogMessage.d("userUnBlockedMe", result);
    var data = json.decode(result.toString());
    var jid = data["jid"];
    unblockedThisUser(jid);
  }

  static void userUpdatedHisProfile(String jid) {
    LogMessage.d("userUpdatedHisProfile", jid.toString());

    if (Get.isRegistered<ChatController>(tag: controllerTag)) {
      Get.find<ChatController>(tag: controllerTag).userUpdatedHisProfile(jid);
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
    if (Get.isRegistered<AddParticipantsController>()) {
      Get.find<AddParticipantsController>().userUpdatedHisProfile(jid);
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
    if (Get.isRegistered<OutgoingCallController>()) {
      Get.find<OutgoingCallController>().userUpdatedHisProfile(jid);
    }
    if (Get.isRegistered<CallController>()) {
      Get.find<CallController>().userUpdatedHisProfile(jid);
    }
    if (Get.isRegistered<CallTimeoutController>()) {
      Get.find<CallTimeoutController>().userUpdatedHisProfile(jid);
    }
  }

  static void userWentOffline(String jid) {
    LogMessage.d("userWentOffline", "jid $jid");
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().setTypingStatus(jid, "", Constants.gone);
    }
    if (Get.isRegistered<ChatController>(tag: controllerTag)) {
      Get.find<ChatController>(tag: controllerTag).userWentOffline(jid);
    }
    if (Get.isRegistered<ChatInfoController>()) {
      Get.find<ChatInfoController>().userWentOffline(jid);
    }
  }

  static void usersIBlockedListFetched(result) {}

  static void usersWhoBlockedMeListFetched(result) {}

  static void onConnected(result) {
    LogMessage.d('onConnected', result.toString());
    if(Get.isRegistered<ChatController>(tag: controllerTag)){
      Get.find<ChatController>(tag: controllerTag).onConnected();
    }
    if (Get.isRegistered<ChatInfoController>()) {
      Get.find<ChatInfoController>().onConnected();
    }
    if (Get.isRegistered<ContactSyncController>()) {
      Get.find<ContactSyncController>().onConnected();
    }
    if(Get.isRegistered<ProfileController>()){
      Get.find<ProfileController>().onConnected();
    }
    if(Get.isRegistered<JoinCallController>()){
      Get.find<JoinCallController>().onConnected();
    }else{
      LogMessage.d('onConnected', "JoinCallController not found");
    }
  }

  static void onDisconnected(result) {
    LogMessage.d('onDisconnected', result.toString());
    if(Get.isRegistered<ChatController>(tag: controllerTag)){
      Get.find<ChatController>(tag: controllerTag).onDisconnected();
    }
    if (Get.isRegistered<ChatInfoController>()) {
      Get.find<ChatInfoController>().onDisconnected();
    }
    if (Get.isRegistered<ContactSyncController>()) {
      Get.find<ContactSyncController>().onDisconnected();
    }
    if(Get.isRegistered<JoinCallController>()){
      Get.find<JoinCallController>().onDisconnected();
    }
  }

  // void onConnectionNotAuthorized(result) {}
  static void onConnectionFailed(result) {}

  static void connectionFailed(result) {}

  static void connectionSuccess(result) {}

  static void onWebChatPasswordChanged(result) {}

  static void setTypingStatus(String singleOrgroupJid, String userId, String typingStatus) {
    if (Get.isRegistered<ChatController>(tag: controllerTag)) {
      Get.find<ChatController>(tag: controllerTag).setTypingStatus(singleOrgroupJid, userId, typingStatus);
    }
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().setTypingStatus(singleOrgroupJid, userId, typingStatus);
    }
    if (Get.isRegistered<MyController>()) {
      Get.find<MyController>().setTypingStatus(singleOrgroupJid, userId, typingStatus);
    }
    if (Get.isRegistered<ArchivedChatListController>()) {
      Get.find<ArchivedChatListController>().setTypingStatus(singleOrgroupJid, userId, typingStatus);
    }
  }

  void onChatTypingStatus(result) {}

  void onGroupTypingStatus(result) {}

  void onFailure(result) {}

  void onProgressChanged(result) {}

  void onSuccess(result) {}

  Future<void> showLocalNotification(ChatMessageModel chatMessageModel) async {
    debugPrint("showing local notification");
    var isUserMuted = await Mirrorfly.isChatMuted(jid: chatMessageModel.chatUserJid);
    var isUserUnArchived = await Mirrorfly.isChatUnArchived(jid: chatMessageModel.chatUserJid);
    var isArchivedSettingsEnabled = await Mirrorfly.isArchivedSettingsEnabled();

    var archiveSettings = isArchivedSettingsEnabled.checkNull() ? isUserUnArchived.checkNull() : true;

    if (!chatMessageModel.isMessageSentByMe && !isUserMuted.checkNull() && archiveSettings) {
      final String? notificationUri = SessionManagement.getNotificationUri();
      final UriAndroidNotificationSound uriSound = UriAndroidNotificationSound(notificationUri!);
      debugPrint("notificationUri--> $notificationUri");

      var messageId =
          chatMessageModel.messageSentTime.toString().substring(chatMessageModel.messageSentTime.toString().length - 5);
      debugPrint("Mani Message ID $messageId");
      AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
          chatMessageModel.messageId, 'MirrorFly',
          importance: Importance.max,
          priority: Priority.high,
          sound: uriSound,
          styleInformation: const DefaultStyleInformation(true, true));
      DarwinNotificationDetails iosNotificationDetails = DarwinNotificationDetails(
          categoryIdentifier: darwinNotificationCategoryPlain,
          sound: notificationUri,
          presentSound: true,
          presentBadge: true,
          presentAlert: true);

      NotificationDetails notificationDetails =
          NotificationDetails(android: androidNotificationDetails, iOS: iosNotificationDetails);
      await flutterLocalNotificationsPlugin.show(
          12345,
          chatMessageModel.senderUserName,
          chatMessageModel.isMessageRecalled.value ? "This message was deleted" : chatMessageModel.messageTextContent,
          notificationDetails,
          payload: chatMessageModel.chatUserJid);
    } else {
      debugPrint("self sent message don't need notification");
    }
  }

  static Future<void> onMissedCall(
      bool isOneToOneCall, String userJid, String groupId, String callType, List<String> userList) async {
    if (SessionManagement.getCurrentChatJID() == userJid.checkNull()) {
      return;
    }
    //show MissedCall Notification
    var missedCallTitleContent =
        await getMissedCallNotificationContent(isOneToOneCall, userJid, groupId, callType, userList);
    LogMessage.d("onMissedCallContent", "${missedCallTitleContent.first} ${missedCallTitleContent.last}");
    NotificationBuilder.createCallNotification(missedCallTitleContent.first, missedCallTitleContent.last);
  }

  static Future<List<String>> getMissedCallNotificationContent(
      bool isOneToOneCall, String userJid, String groupId, String callType, List<String> userList) async {
    String messageContent;
    StringBuffer missedCallTitle = StringBuffer();
    missedCallTitle.write("You missed ");
    if (isOneToOneCall && groupId.isEmpty) {
      if (callType == CallType.audio) {
        missedCallTitle.write("an ");
      } else {
        missedCallTitle.write("a ");
      }
      missedCallTitle.write(callType);
      missedCallTitle.write(" call");
      messageContent = await getDisplayName(userJid);
    } else {
      missedCallTitle.write("a group $callType call");
      if (groupId.isNotEmpty) {
        messageContent = await getDisplayName(groupId);
      } else {
        messageContent = await getCallUsersName(userList);
      }
    }
    return [missedCallTitle.toString(), messageContent];
  }

  static Future<String> getCallUsersName(List<String> callUsers) async {
    var name = StringBuffer("");
    for (var i = 0; i < callUsers.length; i++) {
      var displayName = await getDisplayName(callUsers[i]);
      if (i == 2) {
        name.write(" and (+${callUsers.length - i})");
        break;
      } else if (i == 1) {
        name.write(", $displayName");
      } else {
        name = StringBuffer(await getDisplayName(callUsers[i]));
      }
    }
    return name.toString();
  }

  static Future<String> getDisplayName(String jid) async {
    return (await getProfileDetails(jid)).getName();
  }

  static void onLogout(isLogout) {
    LogMessage.d('NavUtils.currentRoute', NavUtils.currentRoute);
    DialogUtils.hideLoading();
    if (isLogout && NavUtils.currentRoute != Routes.login && SessionManagement.getLogin()) {
      var token = SessionManagement.getToken().checkNull();
      SessionManagement.clear().then((value) {
        SessionManagement.setToken(token);
        NavUtils.offAllNamed(Routes.login);
      });
      // DialogUtils.progressLoading();
      // Mirrorfly.logoutOfChatSDK().then((value) {
      //   DialogUtils.hideLoading();
      //   if(value) {
      //     var token = SessionManagement.getToken().checkNull();
      //     SessionManagement.clear().then((value){
      //       SessionManagement.setToken(token);
      //       NavUtils.offAllNamed(Routes.login);
      //     });
      //   }else{
      //     Get.snackbar("Logout", "Logout Failed");
      //   }
      // }).catchError((er){
      //   DialogUtils.hideLoading();
      //   SessionManagement.clear().then((value){
      //     // SessionManagement.setToken(token);
      //     NavUtils.offAllNamed(Routes.login);
      //   });
      // });
    }
  }

  static Timer? timer;
  static void startTimer({int? time}) {
    // if (timer == null) {
    if (timer != null) {
      timer?.cancel();
    }
    timer = null;
    const oneSec = Duration(seconds: 1);
    var startTime = time != null ? DateTime.fromMillisecondsSinceEpoch(time) : DateTime.now();
    timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        final hrDur = DateTime.now().difference(startTime).inHours;
        final minDur = DateTime.now().difference(startTime).inMinutes;
        final secDur = DateTime.now().difference(startTime).inSeconds % 60;
        final hours = hrDur.remainder(24).toStringAsFixed(0).padLeft(2, '0');
        final minutes = minDur.remainder(60).toStringAsFixed(0).padLeft(2, '0');
        final seconds = secDur.remainder(60).toStringAsFixed(0).padLeft(2, '0');
        var time = '${hours != "00" ? '$hours:' : ''}$minutes:$seconds';
        // LogMessage.d("callTimer", time);
        if (Get.isRegistered<CallController>()) {
          wakeLockEnable();
          Get.find<CallController>().callDuration(time);
        }
      },
    );
    // }
  }

  static Future<void> wakeLockEnable() async {
    try {
      final isEnabled = await WakelockPlus.enabled;
      if (!isEnabled) {
        await WakelockPlus.enable();
        debugPrint("Wakelock enabled.");
      } else {
        debugPrint("Wakelock already enabled.");
      }
    } catch (e) {
      debugPrint("Failed to enable wakelock: $e");
    }
  }

  static void stopTimer() {
    debugPrint("baseController stopTimer");
    CallViewState.isSwapped = false;
    CallViewState.swappedUserJid = null;

    if (timer == null) {
      debugPrint("baseController Timer is null");
      return;
    }
    timer?.cancel();
    timer = null;
    wakeLockDisable();
  }

  static Future<void> wakeLockDisable() async {
    try {
      final isEnabled = await WakelockPlus.enabled;
      if (isEnabled) {
        await WakelockPlus.disable();
        debugPrint("baseController: Wakelock disabled.:");
      } else {
        debugPrint("baseController: Wakelock was already disabled.");
      }
    } catch (e) {
      debugPrint("baseController: Failed to disable wakelock - $e");
    }
     }

  //#editMessage
  static void onMessageEdited(editedChatMessage) {
    ChatMessageModel chatMessageModel = sendMessageModelFromJson(editedChatMessage);
    if (Get.isRegistered<ChatController>(tag: controllerTag)) {
      Get.find<ChatController>(tag: controllerTag).onMessageEdited(chatMessageModel);
    }
    if (Get.isRegistered<MessageInfoController>()) {
      Get.find<MessageInfoController>().onMessageEdited(chatMessageModel);
    }
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().onMessageEdited(chatMessageModel);
    }
    if (Get.isRegistered<ArchivedChatListController>()) {
      Get.find<ArchivedChatListController>().onMessageEdited(chatMessageModel);
    }
    if (Get.isRegistered<StarredMessagesController>()) {
      Get.find<StarredMessagesController>().onMessageEdited(chatMessageModel);
    }
  }

  static String get controllerTag => SessionManagement.getCurrentChatJID();

  static void initializeBackupListeners() {
    debugPrint("initializeBackupListeners");
    Mirrorfly.onBackupSuccess.listen((backUpPath) {
      debugPrint(
          "onBackupSuccess==> $backUpPath isServerUploadRequired ==> ${BackupRestoreManager.instance.isServerUploadRequired}");
      if (BackupRestoreManager.instance.isServerUploadRequired) {
        if (Get.isRegistered<BackupController>()) {
          Get.find<BackupController>().remoteBackUpFileReady(backUpPath: backUpPath);
        }
      } else {
        if (Get.isRegistered<BackupController>()) {
          Get.find<BackupController>().backUpSuccess(backUpPath);
        }
      }
    });

    Mirrorfly.onBackupFailure.listen((event) {
      if (Get.isRegistered<BackupController>()) {
        Get.find<BackupController>().backUpFailed(event);
      }
    });

    Mirrorfly.onBackupProgressChanged.listen((event) {
      if (Get.isRegistered<BackupController>()) {
        Get.find<BackupController>().backUpProgress(event);
      }
    });

    Mirrorfly.onRestoreSuccess.listen((event) {
      if (Get.isRegistered<BackupController>()) {
        Get.find<BackupController>().restoreSuccess(event);
      }
      if (Get.isRegistered<RestoreController>()) {
        Get.find<RestoreController>().restoreSuccess(event);
      }
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().getRecentChatList();
      }
    });

    Mirrorfly.onRestoreFailure.listen((event) {
      if (Get.isRegistered<BackupController>()) {
        Get.find<BackupController>().restoreFailed(event);
      }
      if (Get.isRegistered<RestoreController>()) {
        Get.find<RestoreController>().restoreFailed(event);
      }
    });

    Mirrorfly.onRestoreProgressChanged.listen((event) {
      if (Get.isRegistered<BackupController>()) {
        Get.find<BackupController>().restoreBackupProgress(event);
      }
      if (Get.isRegistered<RestoreController>()) {
        Get.find<RestoreController>().restoreBackupProgress(event);
      }
    });
  }

  static void onWebLogout(response){
    LogMessage.d("onWebLogout",response);
    //{"socketIdList":["8mXojaLkd4CC773aAAFh"]}
    var data = json.decode(response.toString());
    var socketIdList = List<String>.from((data["socketIdList"] ?? "").map((x) => x.toString()));
    if(Get.isRegistered<DashboardController>()){
      Get.find<DashboardController>().onWebLogout(socketIdList);
    }
    if(Get.isRegistered<WebLoginController>()){
      Get.find<WebLoginController>().onWebLogout(socketIdList);
    }
  }
}
