import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class FlyChat {
  FlyChat._();
  static const mirrorFlyMethodChannel = MethodChannel('contus.mirrorfly/sdkCall');

  //Event Channels
  static const EventChannel messageOnReceivedChannel = EventChannel('contus.mirrorfly/onMessageReceived');
  static const EventChannel messageStatusUpdatedChanel = EventChannel('contus.mirrorfly/onMessageStatusUpdated');
  static const EventChannel mediaStatusUpdatedChannel = EventChannel('contus.mirrorfly/onMediaStatusUpdated');
  static const EventChannel uploadDownloadProgressChangedChannel = EventChannel('contus.mirrorfly/onUploadDownloadProgressChanged');
  static const EventChannel showUpdateCancelNotificationChannel = EventChannel('contus.mirrorfly/showOrUpdateOrCancelNotification');

  static const EventChannel onGroupProfileFetchedChannel = EventChannel('contus.mirrorfly/onGroupProfileFetched');
  static const EventChannel onNewGroupCreatedChannel = EventChannel('contus.mirrorfly/onNewGroupCreated');
  static const EventChannel onGroupProfileUpdatedChannel = EventChannel('contus.mirrorfly/onGroupProfileUpdated');
  static const EventChannel onNewMemberAddedToGroupChannel = EventChannel('contus.mirrorfly/onNewMemberAddedToGroup');
  static const EventChannel onMemberRemovedFromGroupChannel = EventChannel('contus.mirrorfly/onMemberRemovedFromGroup');
  static const EventChannel onFetchingGroupMembersCompletedChannel = EventChannel('contus.mirrorfly/onFetchingGroupMembersCompleted');
  static const EventChannel onDeleteGroupChannel = EventChannel('contus.mirrorfly/onDeleteGroup');
  static const EventChannel onFetchingGroupListCompletedChannel = EventChannel('contus.mirrorfly/onFetchingGroupListCompleted');
  static const EventChannel onMemberMadeAsAdminChannel = EventChannel('contus.mirrorfly/onMemberMadeAsAdmin');
  static const EventChannel onMemberRemovedAsAdminChannel = EventChannel('contus.mirrorfly/onMemberRemovedAsAdmin');
  static const EventChannel onLeftFromGroupChannel = EventChannel('contus.mirrorfly/onLeftFromGroup');
  static const EventChannel onGroupNotificationMessageChannel = EventChannel('contus.mirrorfly/onGroupNotificationMessage');
  static const EventChannel onGroupDeletedLocallyChannel = EventChannel('contus.mirrorfly/onGroupDeletedLocally');

  static const EventChannel blockedThisUserChannel = EventChannel('contus.mirrorfly/blockedThisUser');
  static const EventChannel myProfileUpdatedChannel = EventChannel('contus.mirrorfly/myProfileUpdated');
  static const EventChannel onAdminBlockedOtherUserChannel = EventChannel('contus.mirrorfly/onAdminBlockedOtherUser');
  static const EventChannel onAdminBlockedUserChannel = EventChannel('contus.mirrorfly/onAdminBlockedUser');
  static const EventChannel onContactSyncCompleteChannel = EventChannel('contus.mirrorfly/onContactSyncComplete');
  static const EventChannel onLoggedOutChannel = EventChannel('contus.mirrorfly/onLoggedOut');
  static const EventChannel unblockedThisUserChannel = EventChannel('contus.mirrorfly/unblockedThisUser');
  static const EventChannel userBlockedMeChannel = EventChannel('contus.mirrorfly/userBlockedMe');
  static const EventChannel userCameOnlineChannel = EventChannel('contus.mirrorfly/userCameOnline');
  static const EventChannel userDeletedHisProfileChannel = EventChannel('contus.mirrorfly/userDeletedHisProfile');
  static const EventChannel userProfileFetchedChannel = EventChannel('contus.mirrorfly/userProfileFetched');
  static const EventChannel userUnBlockedMeChannel = EventChannel('contus.mirrorfly/userUnBlockedMe');
  static const EventChannel userUpdatedHisProfileChannel = EventChannel('contus.mirrorfly/userUpdatedHisProfile');
  static const EventChannel userWentOfflineChannel = EventChannel('contus.mirrorfly/userWentOffline');
  static const EventChannel usersIBlockedListFetchedChannel = EventChannel('contus.mirrorfly/usersIBlockedListFetched');
  static const EventChannel usersProfilesFetchedChannel = EventChannel('contus.mirrorfly/usersProfilesFetched');
  static const EventChannel usersWhoBlockedMeListFetchedChannel = EventChannel('contus.mirrorfly/usersWhoBlockedMeListFetched');
  static const EventChannel onConnectedChannel = EventChannel('contus.mirrorfly/onConnected');
  static const EventChannel onDisconnectedChannel = EventChannel('contus.mirrorfly/onDisconnected');
  static const EventChannel onConnectionNotAuthorizedChannel = EventChannel('contus.mirrorfly/onConnectionNotAuthorized');
  static const EventChannel connectionFailedChannel = EventChannel('contus.mirrorfly/connectionFailed');
  static const EventChannel connectionSuccessChannel = EventChannel('contus.mirrorfly/connectionSuccess');
  static const EventChannel onWebChatPasswordChangedChannel = EventChannel('contus.mirrorfly/onWebChatPasswordChanged');
  static const EventChannel setTypingStatusChannel = EventChannel('contus.mirrorfly/setTypingStatus');
  static const EventChannel onChatTypingStatusChannel = EventChannel('contus.mirrorfly/onChatTypingStatus');
  static const EventChannel onGroupTypingStatusChannel = EventChannel('contus.mirrorfly/onGroupTypingStatus');
  static const EventChannel onFailureChannel = EventChannel('contus.mirrorfly/onFailure');
  static const EventChannel onProgressChangedChannel = EventChannel('contus.mirrorfly/onProgressChanged');
  static const EventChannel onSuccessChannel = EventChannel('contus.mirrorfly/onSuccess');


  static Future<bool?> syncContacts(bool isfirsttime) async {
    bool? res;
    try {
      res = await mirrorFlyMethodChannel
          .invokeMethod<bool>('syncContacts',{"is_first_time":isfirsttime});
      return res;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<String?> getSendData() async {
    String? response;
    try {
      response = await mirrorFlyMethodChannel
          .invokeMethod<String>('sendData');
      debugPrint("sendData Result ==> $response");
      return response;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<String?> contactSyncStateValue() async {
    String? response;
    try {
      response = await mirrorFlyMethodChannel
          .invokeMethod<String>('contactSyncStateValue');
      debugPrint("contactSyncState Result ==> $response");
      return response;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> contactSyncState() async {
    dynamic response = "";
    try {
      response = await mirrorFlyMethodChannel
          .invokeMethod('contactSyncState');
      debugPrint("contactSyncState Result ==> $response");
      return response;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> revokeContactSync() async {
    dynamic response = "";
    try {
      response = await mirrorFlyMethodChannel
          .invokeMethod('revokeContactSync');
      debugPrint("revokeContactSync Result ==> $response");
      return response;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> getUsersWhoBlockedMe([bool server =false]) async {
    dynamic response = "";
    try {
      response = await mirrorFlyMethodChannel
          .invokeMethod('getUsersWhoBlockedMe',{"server":server});
      debugPrint("getUsersWhoBlockedMe Result ==> $response");
      return response;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> getUnKnownUserProfiles() async {
    dynamic response = "";
    try {
      response = await mirrorFlyMethodChannel
          .invokeMethod('getUnKnownUserProfiles');
      debugPrint("getUnKnownUserProfiles Result ==> $response");
      return response;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> getMyProfileStatus() async {
    dynamic response = "";
    try {
      response = await mirrorFlyMethodChannel
          .invokeMethod('getMyProfileStatus');
      debugPrint("getMyProfileStatus Result ==> $response");
      return response;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> getMyBusyStatus() async {
    dynamic response = "";
    try {
      response = await mirrorFlyMethodChannel
          .invokeMethod('getMyBusyStatus');
      debugPrint("getMyBusyStatus Result ==> $response");
      return response;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> getBusyStatusList() async {
    dynamic response = "";
    try {
      response = await mirrorFlyMethodChannel
          .invokeMethod('getBusyStatusList');
      debugPrint("getBusyStatusList Result ==> $response");
      return response;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> getRecalledMessagesOfAConversation(String jid) async {
    dynamic response = "";
    try {
      response = await mirrorFlyMethodChannel
          .invokeMethod('getRecalledMessagesOfAConversation',{"jid":jid});
      debugPrint("getRecalledMessagesOfAConversation Result ==> $response");
      return response;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<bool?> setMyBusyStatus(String busystatus) async {
    bool? res;
    try {
      res = await mirrorFlyMethodChannel
          .invokeMethod<bool>('setMyBusyStatus',{"status":busystatus});
      return res;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<bool?> enableDisableBusyStatus(bool enable) async {
    bool? res;
    try {
      res = await mirrorFlyMethodChannel
          .invokeMethod<bool>('enableDisableBusyStatus',{"enable":enable});
      return res;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<bool?> enableDisableHideLastSeen(bool enable) async {
    bool? res;
    try {
      res = await mirrorFlyMethodChannel
          .invokeMethod<bool>('enableDisableHideLastSeen',{"enable":enable});
      return res;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<bool?> isBusyStatusEnabled() async {
    bool? res;
    try {
      res = await mirrorFlyMethodChannel
          .invokeMethod<bool>('isBusyStatusEnabled');
      debugPrint("isBusyStatusEnabled--> $res");
      return res;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<bool?> deleteProfileStatus(num id, String status,bool isCurrentStatus) async {
    bool? res;
    try {
      res = await mirrorFlyMethodChannel
          .invokeMethod<bool>('deleteProfileStatus',{"id":id,"status":status,"isCurrentStatus":isCurrentStatus,});
      return res;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<bool?> deleteBusyStatus(num id, String status,bool isCurrentStatus) async {
    bool? res;
    try {
      res = await mirrorFlyMethodChannel
          .invokeMethod<bool>('deleteBusyStatus',{"id":id,"status":status,"isCurrentStatus":isCurrentStatus,});
      return res;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<String?> mediaEndPoint() async {
    String? response;
    try {
      response = await mirrorFlyMethodChannel
          .invokeMethod<String>('media_endpoint');
      debugPrint("media_endpoint Result ==> $response");
      return response;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<bool?> unFavouriteAllFavouriteMessages() async {
    bool? res;
    try {
      res = await mirrorFlyMethodChannel
          .invokeMethod<bool>('unFavouriteAllFavouriteMessages');
      return res;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<bool?> markAsRead(String jid) async {
    bool? res;
    try {
      res = await mirrorFlyMethodChannel
          .invokeMethod<bool>('markAsRead',{"jid":jid});
      return res;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<bool?> uploadMedia(String messageid) async {
    bool? res;
    try {
      res = await mirrorFlyMethodChannel
          .invokeMethod<bool>('uploadMedia',{"messageid":messageid});
      return res;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<bool?> deleteUnreadMessageSeparatorOfAConversation(String jid) async {
    bool? res;
    try {
      res = await mirrorFlyMethodChannel
          .invokeMethod<bool>('deleteUnreadMessageSeparatorOfAConversation',{"jid":jid});
      return res;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<int?> getMembersCountOfGroup(String groupJid) async {
    int? res;
    try {
      res = await mirrorFlyMethodChannel
          .invokeMethod<int>('getMembersCountOfGroup',{"groupJid":groupJid});
      return res;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<bool?> doesFetchingMembersListFromServedRequired(String groupJid) async {
    bool? res;
    try {
      res = await mirrorFlyMethodChannel
          .invokeMethod<bool>('doesFetchingMembersListFromServedRequired',{"groupJid":groupJid});
      return res;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<bool?> isHideLastSeenEnabled() async {
    bool? res;
    try {
      res = await mirrorFlyMethodChannel
          .invokeMethod<bool>('isHideLastSeenEnabled');
      return res;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static deleteOfflineGroup(String groupJid) async {
    try {
      await mirrorFlyMethodChannel
          .invokeMethod('deleteOfflineGroup',{"groupJid":groupJid});
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static sendTypingStatus(String toJid,String chattype) async {
    try {
      await mirrorFlyMethodChannel
          .invokeMethod('sendTypingStatus',{"to_jid":toJid,"chattype":chattype});
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static sendTypingGoneStatus(String toJid,String chattype) async {
    try {
      await mirrorFlyMethodChannel
          .invokeMethod('sendTypingGoneStatus',{"to_jid":toJid,"chattype":chattype});
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static updateChatMuteStatus(String jid,bool muteStatus) async {
    try {
      await mirrorFlyMethodChannel
          .invokeMethod('updateChatMuteStatus',{"jid":jid,"mute_status":muteStatus});
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static updateRecentChatPinStatus(String jid,bool pinStatus) async {
    try {
      await mirrorFlyMethodChannel
          .invokeMethod('updateRecentChatPinStatus',{"jid":jid,"pin_recent_chat":pinStatus});
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static deleteRecentChat(String jid) async {
    try {
      await mirrorFlyMethodChannel
          .invokeMethod('deleteRecentChat',{"jid":jid});
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static setTypingStatusListener() async {
    try {
      await mirrorFlyMethodChannel
          .invokeMethod('setTypingStatusListener');
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<bool?> isUserUnArchived(String jid) async {
    bool? res;
    try {
      res = await mirrorFlyMethodChannel
          .invokeMethod<bool>('isUserUnArchived',{"jid":jid});
      debugPrint("isUserUnArchived==>$res");
      return res;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<bool?> getIsProfileBlockedByAdmin() async {
    bool? res;
    try {
      res = await mirrorFlyMethodChannel
          .invokeMethod<bool>('getIsProfileBlockedByAdmin');
      return res;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<bool?> deleteRecentChats(List<String> jidlist) async {
    bool? res;
    try {
      res = await mirrorFlyMethodChannel
          .invokeMethod<bool>('deleteRecentChats',{"jidlist":jidlist});
      return res;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static markConversationAsRead(List<String> jidlist) async {
    try {
      await mirrorFlyMethodChannel
          .invokeMethod('markConversationAsRead',{"jidlist":jidlist});
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static markConversationAsUnread(List<String> jidlist) async {
    try {
      await mirrorFlyMethodChannel
          .invokeMethod('markConversationAsUnread',{"jidlist":jidlist});
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static getArchivedChatsFromServer() async {
    try {
      await mirrorFlyMethodChannel
          .invokeMethod('getArchivedChatsFromServer');
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static setCustomValue(String messageId,String key,String value) async {
    try {
      await mirrorFlyMethodChannel
          .invokeMethod('setCustomValue',{"message_id":messageId,"key":key,"value":value});
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static removeCustomValue(String messageId,String key) async {
    try {
      await mirrorFlyMethodChannel
          .invokeMethod('removeCustomValue',{"message_id":messageId,"key":key});
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static inviteUserViaSMS(String mobileNo,String message) async {
    try {
      await mirrorFlyMethodChannel
          .invokeMethod('inviteUserViaSMS',{"mobile_no":mobileNo,"message":message});
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static cancelBackup() async {
    try {
      await mirrorFlyMethodChannel
          .invokeMethod('cancelBackup');
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static startBackup() async {
    try {
      await mirrorFlyMethodChannel
          .invokeMethod('startBackup');
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static cancelRestore() async {
    try {
      await mirrorFlyMethodChannel
          .invokeMethod('cancelRestore');
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static clearAllSDKData() async {
    try {
      await mirrorFlyMethodChannel
          .invokeMethod('clearAllSDKData');
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static getRoster() async {
    try {
      await mirrorFlyMethodChannel
          .invokeMethod('getRoster');
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<String?> getCustomValue(String messageId,String key) async {
    String? res;
    try {
      res = await mirrorFlyMethodChannel
          .invokeMethod<String>('getCustomValue',{"message_id":messageId,"key":key});
      return res;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<bool?> clearAllConversation() async {
    bool? res;
    try {
      res = await mirrorFlyMethodChannel
          .invokeMethod<bool>('clearAllConversation');
      return res;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<bool?> updateFcmToken(String firebasetoken) async {
    bool? res;
    try {
      res = await mirrorFlyMethodChannel
          .invokeMethod<bool>('updateFcmToken',{"token":firebasetoken});
      return res;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<bool?> isMuted(String jid) async {
    bool? res;
    try {
      res = await mirrorFlyMethodChannel
          .invokeMethod<bool>('isMuted',{"jid":jid});
      return res;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> handleReceivedMessage(Map notificationdata) async {
    dynamic res;
    try {
      res = await mirrorFlyMethodChannel
          .invokeMethod('handleReceivedMessage',{"notificationdata":notificationdata});
      return res;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> getLastNUnreadMessages(int messagesCount) async {
    dynamic res;
    try {
      res = await mirrorFlyMethodChannel
          .invokeMethod('getLastNUnreadMessages',{"messagecount":messagesCount});
      return res;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> getNUnreadMessagesOfEachUsers(int messagesCount) async {
    dynamic res;
    try {
      res = await mirrorFlyMethodChannel
          .invokeMethod('getNUnreadMessagesOfEachUsers',{"messagecount":messagesCount});
      return res;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<bool?> isArchivedSettingsEnabled() async {
    bool? res;
    try {
      res = await mirrorFlyMethodChannel
          .invokeMethod<bool>('isArchivedSettingsEnabled');
      return res;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<bool?> enableDisableArchivedSettings(bool enable) async {
    bool? res;
    try {
      res = await mirrorFlyMethodChannel
          .invokeMethod<bool>('enableDisableArchivedSettings',{"enable":enable});
      return res;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<bool?> updateArchiveUnArchiveChat(String jid,bool isArchived) async {
    bool? res;
    try {
      res = await mirrorFlyMethodChannel
          .invokeMethod<bool>('updateArchiveUnArchiveChat',{"jid":jid,"isArchived":isArchived});
      return res;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<int?> getGroupMessageStatusCount(String messageid) async {
    int? res;
    try {
      res = await mirrorFlyMethodChannel
          .invokeMethod<int>('getGroupMessageStatusCount',{"messageid":messageid});
      return res;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<int?> getUnreadMessageCountExceptMutedChat() async {
    int? res;
    try {
      res = await mirrorFlyMethodChannel
          .invokeMethod<int>('getUnreadMessageCountExceptMutedChat');
      return res;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<int?> recentChatPinnedCount() async {
    int? res;
    try {
      res = await mirrorFlyMethodChannel
          .invokeMethod<int>('getGroupMessageStatusCount');
      return res;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<int?> getUnreadMessagesCount() async {
    int? res;
    try {
      res = await mirrorFlyMethodChannel
          .invokeMethod<int>('getUnreadMessagesCount');
      return res;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<String?> getUnsentMessageOfAJid(String jid) async {
    String? res;
    try {
      res = await mirrorFlyMethodChannel
          .invokeMethod<String>('getUnsentMessageOfAJid',{"jid":jid});
      return res;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> getUsersListToAddMembersInOldGroup(String groupJid) async {
    dynamic res;
    try {
      res = await mirrorFlyMethodChannel
          .invokeMethod('getUsersListToAddMembersInOldGroup',{"groupJid":groupJid});
      return res;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> prepareChatConversationToExport(String jid) async {
    dynamic res;
    try {
      res = await mirrorFlyMethodChannel
          .invokeMethod('prepareChatConversationToExport',{"jid":jid});
      return res;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> getArchivedChatList() async {
    dynamic res;
    try {
      res = await mirrorFlyMethodChannel
          .invokeMethod('getArchivedChatList');
      return res;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> getMessageActions(List<String> messageidlist) async {
    dynamic res;
    try {
      res = await mirrorFlyMethodChannel
          .invokeMethod('getMessageActions',{"messageidlist":messageidlist});
      return res;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> getUsersListToAddMembersInNewGroup() async {
    dynamic res;
    try {
      res = await mirrorFlyMethodChannel
          .invokeMethod('getUsersListToAddMembersInNewGroup');
      return res;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<bool?> createOfflineGroupInOnline(String groupId) async {
    bool? res;
    try {
      res = await mirrorFlyMethodChannel
          .invokeMethod<bool>('createOfflineGroupInOnline',{"groupId":groupId});
      return res;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> getGroupProfile(String groupJid,bool server) async {
    dynamic res;
    try {
      res = await mirrorFlyMethodChannel
          .invokeMethod('getGroupProfile',{"groupJid":groupJid,"server":server});
      return res;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static updateMediaDownloadStatus(String mediaMessageId, int progress, int downloadStatus, num dataTransferred) async {
    try {
      await mirrorFlyMethodChannel
          .invokeMethod('updateMediaDownloadStatus',{"mediaMessageId":mediaMessageId, "progress":progress, "downloadStatus":downloadStatus, "dataTransferred":dataTransferred});
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static updateMediaUploadStatus(String mediaMessageId, int progress, int uploadStatus, num dataTransferred) async {
    try {
      await mirrorFlyMethodChannel
          .invokeMethod('updateMediaUploadStatus',{"mediaMessageId":mediaMessageId, "progress":progress, "downloadStatus":uploadStatus, "dataTransferred":dataTransferred});
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static cancelMediaUploadOrDownload(String messageId) async {
    try {
      await mirrorFlyMethodChannel
          .invokeMethod('cancelMediaUploadOrDownload',{"messageId":messageId});
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static setMediaEncryption(String encryption) async {
    try {
      await mirrorFlyMethodChannel
          .invokeMethod('setMediaEncryption',{"encryption":encryption});
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static deleteAllMessages() async {
    try {
      await mirrorFlyMethodChannel
          .invokeMethod('deleteAllMessages');
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<String?> getGroupJid(String jid) async {
    String? response;
    try {
      response = await mirrorFlyMethodChannel
          .invokeMethod<String>('getGroupJid',{"jid":jid});
      debugPrint("getGroupJid Result ==> $response");
      return response;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<String?> getUserLastSeenTime(String jid) async {
    String? response;
    try {
      response = await mirrorFlyMethodChannel
          .invokeMethod<String>('getUserLastSeenTime',{"jid":jid});
      debugPrint("getUserLastSeenTime Result ==> $response");
      return response;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<String?> authToken() async {
    String? registerResponse = "";
    try {
      registerResponse = await mirrorFlyMethodChannel
          .invokeMethod<String>('authtoken');
      debugPrint("authToken Result ==> $registerResponse");

      return registerResponse;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> registerUser(String userIdentifier,String token) async {
    dynamic registerResponse;
    try {
      registerResponse = await mirrorFlyMethodChannel
          .invokeMethod('register_user', {"userIdentifier": userIdentifier,"token":token});
      debugPrint("Register Result ==> $registerResponse");
      return registerResponse;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<String?> verifyToken(String userName,String token) async {
    String? response = "";
    try {
      response = await mirrorFlyMethodChannel.invokeMethod<String>('verifyToken', {"userName": userName,"googleToken":token});
      debugPrint("verifyToken Result ==> $response");
      return response;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> getJid(String username) async {//getuserjid
    dynamic userJID;
    try {
      userJID = await mirrorFlyMethodChannel
          .invokeMethod('get_jid', {"username": username});
      debugPrint("User JID Result ==> $userJID");
      return userJID;
    } on PlatformException catch (e) {
      debugPrint("Flutter Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Flutter Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> sendTextMessage(String message, String jid, String replyMessageId) async {
    dynamic messageResp;
    try {
      messageResp = await mirrorFlyMethodChannel
          .invokeMethod('send_text_msg', {"message": message, "JID": jid, "replyMessageId" : replyMessageId});
      debugPrint("Message Result ==> $messageResp");
      return messageResp;
    } on PlatformException catch (e) {
      debugPrint("Flutter Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Flutter Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> sendLocationMessage(String jid,double latitude,double longitude, String replyMessageId) async {//sentLocationMessage
    dynamic messageResp;
    try {
      messageResp = await mirrorFlyMethodChannel
          .invokeMethod('sendLocationMessage', {"jid": jid,"latitude":latitude,"longitude":longitude, "replyMessageId" : replyMessageId});
      debugPrint("Message Result ==> $messageResp");
      return messageResp;
    } on PlatformException catch (e) {
      debugPrint("Flutter Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Flutter Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> sendImageMessage(
      String jid,
      String filePath,
      String? caption,
      String? replyMessageID,[String? imageFileUrl]) async {
    dynamic messageResp;
    try {
      messageResp =
      await mirrorFlyMethodChannel.invokeMethod('send_image_message', {
        "jid": jid,
        "filePath": filePath,
        "caption": caption,
        "replyMessageId": replyMessageID,"imageFileUrl":imageFileUrl
      });
      debugPrint("Image Message Result ==> $messageResp");
      return messageResp;
    } on PlatformException catch (e) {
      debugPrint("Image Message Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Image Message Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> sendVideoMessage(//sendMediaMessage
      String jid,
      String filePath,
      String? caption,
      String? replyMessageID,[String? videoFileUrl, num? videoDuration, String? thumbImageBase64]) async {
    dynamic messageResp;
    try {
      messageResp =
      await mirrorFlyMethodChannel.invokeMethod('send_video_message', {
        "jid": jid,
        "filePath": filePath,
        "caption": caption,
        "replyMessageId": replyMessageID,
        "videoFileUrl":videoFileUrl,
        "videoDuration":videoDuration,
        "thumbImageBase64":thumbImageBase64
      });
      debugPrint("Video Message Result ==> $messageResp");
      return messageResp;
    } on PlatformException catch (e) {
      debugPrint("Video Message Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Video Message Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> getRegisteredUserList({required bool server}) async {//getRegisteredUserList
    dynamic messageResp;
    try {
      messageResp = await mirrorFlyMethodChannel.invokeMethod('getRegisteredUsers',{'server':server});
      debugPrint("User list Result ==> $messageResp");
      return messageResp;
    } on PlatformException catch (e) {
      debugPrint("User list Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("User list Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> getUserList(int page,String search,[int perPageResultSize =20]) async {
    dynamic re;
    try {
      re = await mirrorFlyMethodChannel.invokeMethod("get_user_list",{"page":page,"search":search,"perPageResultSize":perPageResultSize});
      debugPrint('RESULT ==> $re');
      return re;
    } on PlatformException catch (e) {
      debugPrint("er $e");
      return re;
    }
  }

  static Stream<dynamic> get onMessageReceived => messageOnReceivedChannel.receiveBroadcastStream().cast();
  static Stream<dynamic> get onMessageStatusUpdated => messageStatusUpdatedChanel.receiveBroadcastStream().cast();
  static Stream<dynamic> get onMediaStatusUpdated => mediaStatusUpdatedChannel.receiveBroadcastStream().cast();

  static Stream<dynamic> get onGroupProfileFetched => onGroupProfileFetchedChannel.receiveBroadcastStream().cast();
  static Stream<dynamic> get onNewGroupCreated => onNewGroupCreatedChannel.receiveBroadcastStream().cast();
  static Stream<dynamic> get onGroupProfileUpdated => onGroupProfileUpdatedChannel.receiveBroadcastStream().cast();
  static Stream<dynamic> get onNewMemberAddedToGroup => onNewMemberAddedToGroupChannel.receiveBroadcastStream().cast();
  static Stream<dynamic> get onMemberRemovedFromGroup => onMemberRemovedFromGroupChannel.receiveBroadcastStream().cast();
  static Stream<dynamic> get onFetchingGroupMembersCompleted => onFetchingGroupMembersCompletedChannel.receiveBroadcastStream().cast();
  static Stream<dynamic> get onDeleteGroup => onDeleteGroupChannel.receiveBroadcastStream().cast();
  static Stream<dynamic> get onFetchingGroupListCompleted => onFetchingGroupListCompletedChannel.receiveBroadcastStream().cast();
  static Stream<dynamic> get onMemberMadeAsAdmin => onMemberMadeAsAdminChannel.receiveBroadcastStream().cast();
  static Stream<dynamic> get onMemberRemovedAsAdmin => onMemberRemovedAsAdminChannel.receiveBroadcastStream().cast();
  static Stream<dynamic> get onLeftFromGroup => onLeftFromGroupChannel.receiveBroadcastStream().cast();
  static Stream<dynamic> get onGroupNotificationMessage => onGroupNotificationMessageChannel.receiveBroadcastStream().cast();
  static Stream<dynamic> get onGroupDeletedLocally => onGroupDeletedLocallyChannel.receiveBroadcastStream().cast();

  static Stream<dynamic> get blockedThisUser => blockedThisUserChannel.receiveBroadcastStream().cast();
  static Stream<dynamic> get myProfileUpdated => myProfileUpdatedChannel.receiveBroadcastStream().cast();
  static Stream<dynamic> get onAdminBlockedOtherUser => onAdminBlockedOtherUserChannel.receiveBroadcastStream().cast();
  static Stream<dynamic> get onAdminBlockedUser => onAdminBlockedUserChannel.receiveBroadcastStream().cast();
  static Stream<dynamic> get onContactSyncComplete => onContactSyncCompleteChannel.receiveBroadcastStream().cast();
  static Stream<dynamic> get onLoggedOut => onLoggedOutChannel.receiveBroadcastStream().cast();
  static Stream<dynamic> get unblockedThisUser => unblockedThisUserChannel.receiveBroadcastStream().cast();
  static Stream<dynamic> get userBlockedMe => userBlockedMeChannel.receiveBroadcastStream().cast();
  static Stream<dynamic> get userCameOnline => userCameOnlineChannel.receiveBroadcastStream().cast();
  static Stream<dynamic> get userDeletedHisProfile => userDeletedHisProfileChannel.receiveBroadcastStream().cast();
  static Stream<dynamic> get userProfileFetched => userProfileFetchedChannel.receiveBroadcastStream().cast();
  static Stream<dynamic> get userUnBlockedMe => userUnBlockedMeChannel.receiveBroadcastStream().cast();
  static Stream<dynamic> get userUpdatedHisProfile => userUpdatedHisProfileChannel.receiveBroadcastStream().cast();
  static Stream<dynamic> get userWentOffline => userWentOfflineChannel.receiveBroadcastStream().cast();
  static Stream<dynamic> get usersIBlockedListFetched => usersIBlockedListFetchedChannel.receiveBroadcastStream().cast();
  static Stream<dynamic> get usersWhoBlockedMeListFetched => usersWhoBlockedMeListFetchedChannel.receiveBroadcastStream().cast();
  static Stream<dynamic> get onConnected => onConnectedChannel.receiveBroadcastStream().cast();
  static Stream<dynamic> get onDisconnected => onDisconnectedChannel.receiveBroadcastStream().cast();
  static Stream<dynamic> get onConnectionNotAuthorized => onConnectionNotAuthorizedChannel.receiveBroadcastStream().cast();
  static Stream<dynamic> get connectionFailed => connectionFailedChannel.receiveBroadcastStream().cast();
  static Stream<dynamic> get connectionSuccess => connectionSuccessChannel.receiveBroadcastStream().cast();
  static Stream<dynamic> get onWebChatPasswordChanged => onWebChatPasswordChangedChannel.receiveBroadcastStream().cast();
  static Stream<dynamic> get setTypingStatus => setTypingStatusChannel.receiveBroadcastStream().cast();
  static Stream<dynamic> get onChatTypingStatus => onChatTypingStatusChannel.receiveBroadcastStream().cast();
  static Stream<dynamic> get onGroupTypingStatus => onGroupTypingStatusChannel.receiveBroadcastStream().cast();
  static Stream<dynamic> get onFailure => onFailureChannel.receiveBroadcastStream().cast();
  static Stream<dynamic> get onProgressChanged => onProgressChangedChannel.receiveBroadcastStream().cast();
  static Stream<dynamic> get onSuccess => onSuccessChannel.receiveBroadcastStream().cast();

  static Future<String?> imagePath(String imgurl) async {
    var re = "";
    try {
      final result = await mirrorFlyMethodChannel
          .invokeMethod<String>("get_image_path", {"image": imgurl});
      debugPrint('RESULT ==> $result');
      return result;
    } on PlatformException catch (e) {
      debugPrint("er $e");
      return re;
    }
  }

  static Future<dynamic> saveProfile(String name, String email) async {
    dynamic result;
    try {
      result =
      await mirrorFlyMethodChannel.invokeMethod("updateProfile", {
        "name": name,
        "email": email,
      });
      debugPrint('RESULT $result');
      return result;
    } on PlatformException catch (e) {
      debugPrint("er $e");
      return result;
    }
  }

  static Future<dynamic> sentFileMessage(String? file, String jid) async {
    var re = "";
    try {
      final result = await mirrorFlyMethodChannel
          .invokeMethod("sent file", {"file": file, "jid": jid, "message": ""});
      debugPrint('RESULT $result');
      return result;
    } on PlatformException catch (e) {
      debugPrint("er $e");
      return re;
    }
  }

  static Future<dynamic> getRecentChatList() async {//getRecentChats
    dynamic recentResponse;
    try {
      recentResponse =
      await mirrorFlyMethodChannel.invokeMethod('getRecentChatList');
      debugPrint("recent Result ==> $recentResponse");
      return recentResponse;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }
  static Future<dynamic> getProfileStatusList() async {//getStatusList
    dynamic statusResponse;
    try {
      statusResponse =
      await mirrorFlyMethodChannel.invokeMethod('getProfileStatusList');
      debugPrint("statuslist $statusResponse");
      return statusResponse;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }
  static Future<dynamic> insertDefaultStatus(String status) async {
    try {
      await mirrorFlyMethodChannel.invokeMethod('insertDefaultStatus', {"status" : status });
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }
  /*static void insertDefaultStatusToUser() async{
    try {
      await mirrorFlyMethodChannel.invokeMethod('getProfileStatusList').then((value) {
        mirrorFlyLog("status list", "$value");
        if (value != null) {
          var profileStatus = statusDataFromJson(value);
          if (profileStatus.isNotEmpty) {
            var defaultStatus = Constants.defaultStatusList;
            for (var statusValue in defaultStatus) {
              var isStatusNotExist = true;
              for (var flyStatus in profileStatus) {
                if (flyStatus.status == (statusValue)) {
                  isStatusNotExist = false;
                }
              }
              if (isStatusNotExist) {
                FlyChat.insertDefaultStatus(statusValue);
              }
            }
            SessionManagement.vibrationType("0");
            FlyChat.getRingtoneName(null).then((value) {
              if (value != null) {
                SessionManagement.setNotificationUri(value);
              }
            });
            SessionManagement.convSound(true);
            SessionManagement.muteAll( false);
          }else{
            var defaultStatus = Constants.defaultStatusList;
            for (var statusValue in defaultStatus) {
              FlyChat.insertDefaultStatus(statusValue);
            }
            FlyChat.getRingtoneName(null).then((value) {
              if (value != null) {
                SessionManagement.setNotificationUri(value);
              }
            });
          }
        }
      });
    } on Exception catch(er){
      debugPrint("Exception ==> $er");
    }
  }*/
  static Future<dynamic> updateMyProfile(String name, String email,String mobile, String status,String? image) async {//updateProfile
    dynamic profileResponse;
    try {
      profileResponse = await mirrorFlyMethodChannel.invokeMethod('updateMyProfile',{"name":name,"email":email,"mobile":mobile,"status":status,"image":image});
      debugPrint("recent Result ==> $profileResponse");
      return profileResponse;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> getUserProfile(String jid,[bool fromserver=false,bool saveasfriend = false]) async {//getProfile
    dynamic profileResponse;
    try {
      profileResponse = await mirrorFlyMethodChannel.invokeMethod('getUserProfile',{"jid":jid,"server":fromserver,"saveasfriend":saveasfriend});
      debugPrint("getUserProfile Result ==> $profileResponse");
      //insertDefaultStatusToUser();
      return profileResponse;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> getProfileDetails(String jid, bool fromServer) async {
    dynamic profileResponse;
    try {
      profileResponse = await mirrorFlyMethodChannel.invokeMethod('getProfileDetails',{"jid":jid, "server" : fromServer});
      debugPrint("getProfileDetails Result ==> $profileResponse");
      return profileResponse;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> getProfileLocal(String jid,bool server) async {
    dynamic profileResponse;
    try {
      profileResponse = await mirrorFlyMethodChannel.invokeMethod('getUserProfile',{"jid":jid,"server":server});
      debugPrint("getProfileLocal Result ==> $profileResponse");
      return profileResponse;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> setMyProfileStatus(String status) async {//updateProfileStatus
    dynamic profileResponse;
    try {
      profileResponse = await mirrorFlyMethodChannel.invokeMethod('setMyProfileStatus',{"status":status});
      debugPrint("setMyProfileStatus Result ==> $profileResponse");
      return profileResponse;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> updateMyProfileImage(String image) async {//updateProfileImage
    dynamic profileResponse;
    try {
      profileResponse = await mirrorFlyMethodChannel.invokeMethod('updateMyProfileImage',{"image":image});
      debugPrint("updateMyProfileImage Result ==> $profileResponse");
      return profileResponse;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<bool?> removeProfileImage() async {
    bool? profileResponse;
    try {
      profileResponse = await mirrorFlyMethodChannel.invokeMethod<bool>('removeProfileImage');
      debugPrint("removeProfileImage Result ==> $profileResponse");
      return profileResponse;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      return false;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      return false;
    }
  }

  static Future<bool?> removeGroupProfileImage(String jid) async {
    bool? response;
    try {
      response = await mirrorFlyMethodChannel.invokeMethod<bool>('removeGroupProfileImage',{"jid":jid});
      debugPrint("grp_image Result ==> $response");
      return response;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      return false;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      return false;
    }
  }

  static Future<bool?> refreshAndGetAuthToken() async {
    bool? tokenResponse;
    try {
      tokenResponse = await mirrorFlyMethodChannel.invokeMethod<bool>('refreshAuthToken');
      debugPrint("refreshAuthToken Result ==> $tokenResponse");
      return tokenResponse;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      return false;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      return false;
    }
  }

  static Future<dynamic> getMessagesOfJid(String jid) async {//getChatHistory
    dynamic chatResponse;
    try {
      chatResponse = await mirrorFlyMethodChannel.invokeMethod('getMessagesOfJid',{ "JID" : jid });
      debugPrint("user Chat Result ==> $chatResponse");
      // List<ChatMessageModel> chatMessageModel = chatMessageModelFromJson(chatResponse);
      // return chatMessageModel;
      return chatResponse;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }
  //Removed and added in MainActivity.kt during configuration. User just need to listen the event after initialization

  /*static Future<dynamic> listenMessageEvents() async {
    dynamic chatListenerResponse;
    try {
      chatListenerResponse = await mirrorFlyMethodChannel.invokeMethod('chat_listener');
      debugPrint("chatListenerResponse ==> $chatListenerResponse");
      return chatListenerResponse;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }
  static Future<dynamic> listenGroupChatEvents() async {
    dynamic chatListenerResponse;
    try {
      chatListenerResponse = await mirrorFlyMethodChannel.invokeMethod('groupchat_listener');
      debugPrint("groupchatListenerResponse ==> $chatListenerResponse");
      return chatListenerResponse;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }*/

  //Duplicate method call of getMessageOfId
  // static Future<dynamic> getMedia(String mid) async {
  //   dynamic media;
  //   try {//
  //     media = await mirrorFlyMethodChannel.invokeMethod('get_media',{ "message_id" : mid });
  //     // debugPrint("mediaResponse ==> $media");
  //     return media;
  //   }on PlatformException catch (e){
  //     debugPrint("Platform Exception ===> $e");
  //     rethrow;
  //   } on Exception catch(error){
  //     debugPrint("Exception ==> $error");
  //     rethrow;
  //   }
  // }

  static Future<dynamic> markAsReadDeleteUnreadSeparator(String jid) async {//sendReadReceipts
    //Handled Both Functions ChatManager.markAsRead and FlyMessenger.deleteUnreadMessageSeparatorOfAConversation in this same Function
    dynamic readReceiptResponse;
    try {
      readReceiptResponse = await mirrorFlyMethodChannel.invokeMethod('markAsReadDeleteUnreadSeparator',{ "jid" : jid });
      // debugPrint("mediaResponse ==> $readReceiptResponse");
      return readReceiptResponse;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> sendContactMessage(List<String> contactList, String jid, String contactName, String replyMessageId) async {
    dynamic contactResponse;
    try {
      contactResponse = await mirrorFlyMethodChannel.invokeMethod('sendContactMessage',{ "contact_list" : contactList , "jid" : jid, "contact_name" : contactName, "replyMessageId" : replyMessageId});
      // debugPrint("mediaResponse ==> $readReceiptResponse");
      return contactResponse;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> logoutOfChatSDK() async {//logout
    dynamic logoutResponse;
    try {
      logoutResponse = await mirrorFlyMethodChannel.invokeMethod('logoutOfChatSDK');
      debugPrint("logoutResponse ==> $logoutResponse");
      return logoutResponse;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static setOnGoingChatUser(String jid) async {//ongoingChat
    try {
      await mirrorFlyMethodChannel.invokeMethod('setOnGoingChatUser', {"jid" : jid });
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }
  static downloadMedia(String mid) async {//mediaDownload
    try {
      await mirrorFlyMethodChannel.invokeMethod('downloadMedia', {"mediaMessage_id" : mid });
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> sendDocumentMessage(String jid, String documentPath, String replyMessageId,[String? fileUrl]) async {
    dynamic documentResponse;
    try {
      documentResponse = await mirrorFlyMethodChannel.invokeMethod('sendDocumentMessage',{ "file" : documentPath , "jid" : jid, "replyMessageId" : replyMessageId,"file_url":fileUrl});
      debugPrint("documentResponse ==> $documentResponse");
      return documentResponse;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }
  static Future<dynamic> openFile(String filePath) async {
    dynamic documentResponse;
    try {
      documentResponse = await mirrorFlyMethodChannel.invokeMethod('open_file',{ "filePath" : filePath });
      debugPrint("documentResponse ==> $documentResponse");
      return documentResponse;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> sendAudioMessage(String jid, String filePath, bool isRecorded, String duration, String replyMessageId,[String? audiofileUrl]) async {//sendAudio
    dynamic audioResponse;
    try {
      audioResponse = await mirrorFlyMethodChannel.invokeMethod('sendAudioMessage',{ "filePath" : filePath , "jid" : jid, "isRecorded" : isRecorded, "duration" : duration, "replyMessageId" : replyMessageId,"audiofileUrl":audiofileUrl});
      debugPrint("audioResponse ==> $audioResponse");
      return audioResponse;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  //Recent Chat Search

  static Future<dynamic> getRecentChatListIncludingArchived() async {//filteredRecentChatList
    dynamic response;
    try {
      response = await mirrorFlyMethodChannel.invokeMethod('getRecentChatListIncludingArchived');
      debugPrint("getRecentChatListIncludingArchived ==> $response");
      return response;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> searchConversation(String searchKey,[String? jidForSearch,bool globalSearch = true]) async {//filteredMessageList
    dynamic response;
    try {
      response = await mirrorFlyMethodChannel.invokeMethod('searchConversation',{"searchKey":searchKey,"jidForSearch":jidForSearch,"globalSearch":globalSearch});
      debugPrint("searchConversation ==> $response");
      return response;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> getRegisteredUsers() async {//filteredContactList
    dynamic response;
    try {
      response = await mirrorFlyMethodChannel.invokeMethod('getRegisteredUsers');
      debugPrint("getRegisteredUsers ==> $response");
      return response;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }
  static Future<dynamic> getMessageOfId(String mid) async {
    dynamic response;
    try {
      response = await mirrorFlyMethodChannel.invokeMethod('getMessageOfId',{"mid":mid});
      debugPrint("response ==> $response");
      return response;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }
  static Future<dynamic> getRecentChatOf(String jid) async {
    dynamic response;
    try {
      response = await mirrorFlyMethodChannel.invokeMethod('getRecentChatOf',{"jid":jid});
      debugPrint("getRecentChatOf response ==> $response");
      return response;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> clearChat(String jid, String chatType, bool clearExceptStarred) async {
    dynamic clearChatResponse;
    try {
      clearChatResponse = await mirrorFlyMethodChannel.invokeMethod('clear_chat',{ "jid" : jid, "chat_type" : chatType, "clear_except_starred" : clearExceptStarred});
      debugPrint("clear chat Response ==> $clearChatResponse");
      return clearChatResponse;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  //Duplicate of reportUserOrMessages
  /*static Future<dynamic> reportChatOrUser(String jid, String chatType, String? messageId) async {
    dynamic reportResponse;
    try {
      reportResponse = await mirrorFlyMethodChannel.invokeMethod('report_chat',{ "jid" : jid, "chat_type" : chatType, "selectedMessageID" : messageId});
      debugPrint("clear chat Response ==> $reportResponse");
      return reportResponse;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }*/

  static Future<dynamic> getMessagesUsingIds(List<String> messageIds) async {
    dynamic messageListResponse;
    try {
      messageListResponse = await mirrorFlyMethodChannel.invokeMethod('getMessagesUsingIds',{ "MessageIds" : messageIds});
      debugPrint("getMessagesUsingIds Response ==> $messageListResponse");
      return messageListResponse;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  //Handled deleteMessagesForEveryone and deleteMessagesForMe in same function. so Named Commonly
  static Future<dynamic> deleteMessagesForMe(String jid,String chatType, List<String> messageIds,bool? isMediaDelete) async {
    dynamic messageDeleteResponse;
    try {
      messageDeleteResponse = await mirrorFlyMethodChannel.invokeMethod('deleteMessagesForMe', { "jid" : jid, "chat_type" : chatType,"isMediaDelete":isMediaDelete, "message_ids": messageIds});
      debugPrint("deleteMessagesForMe Response ==> $messageDeleteResponse");
      return messageDeleteResponse;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }
  static Future<dynamic> deleteMessagesForEveryone(String jid,String chatType, List<String> messageIds,bool? isMediaDelete) async {
    dynamic messageDeleteResponse;
    try {
      messageDeleteResponse = await mirrorFlyMethodChannel.invokeMethod('deleteMessagesForEveryone', { "jid" : jid, "chat_type" : chatType,"isMediaDelete":isMediaDelete, "message_ids": messageIds});
      debugPrint("deleteMessagesForEveryone Response ==> $messageDeleteResponse");
      return messageDeleteResponse;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }
  static Future<dynamic> deleteMessages(String jid, List<String> messageIds, bool isDeleteForEveryOne) async {
    dynamic messageDeleteResponse;
    try {
      messageDeleteResponse = await mirrorFlyMethodChannel.invokeMethod('delete_messages', { "jid" : jid, "chat_type" : "chat", "message_ids": messageIds, "is_delete_for_everyone" : isDeleteForEveryOne});
      debugPrint("Message Delete Response ==> $messageDeleteResponse");
      return messageDeleteResponse;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> getGroupMessageDeliveredToList(String messageId) async {
    dynamic messageDeleteResponse;
    try {
      messageDeleteResponse = await mirrorFlyMethodChannel.invokeMethod('getGroupMessageDeliveredToList', { "messageId" : messageId});
      debugPrint("getGroupMessageDeliveredToList Response ==> $messageDeleteResponse");
      return messageDeleteResponse;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> getGroupMessageReadByList(String messageId) async {
    dynamic messageDeleteResponse;
    try {
      messageDeleteResponse = await mirrorFlyMethodChannel.invokeMethod('getGroupMessageReadByList', { "messageId" : messageId});
      debugPrint("getGroupMessageReadByList Response ==> $messageDeleteResponse");
      return messageDeleteResponse;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> getMessageStatusOfASingleChatMessage(String messageID) async {//getMessageInfo
    dynamic messageInfoResponse;
    try {
      messageInfoResponse = await mirrorFlyMethodChannel.invokeMethod('getMessageStatusOfASingleChatMessage', { "messageID" : messageID});
      debugPrint("Message Info Response ==> $messageInfoResponse");
      return messageInfoResponse;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }
  static Future<dynamic> blockUser(String userJID) async {
    dynamic userBlockResponse;
    try {
      userBlockResponse = await mirrorFlyMethodChannel.invokeMethod('block_user', { "userJID" : userJID});
      debugPrint("Blocked Response ==> $userBlockResponse");
      return userBlockResponse;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }
  static Future<bool?> unblockUser(String userJID) async {//unBlockUser
    bool? userBlockResponse;
    try {
      userBlockResponse = await mirrorFlyMethodChannel.invokeMethod<bool>('un_block_user', { "userJID" : userJID});
      debugPrint("Un-Blocked Response ==> $userBlockResponse");
      return userBlockResponse;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }


  static Future<String?> showCustomTones(String? uri) async {
    String? response;
    try {
      response = await mirrorFlyMethodChannel.invokeMethod<String>('showCustomTones', { "ringtone_uri" : uri});
      debugPrint("showCustomTones Response ==> $response");
      return response;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }


  static Future<String?> getRingtoneName(String? uri) async {
    String? response;
    try {
      response = await mirrorFlyMethodChannel.invokeMethod<String>('getRingtoneName', { "ringtone_uri" : uri});
      debugPrint("getRingtoneName Response ==> $response");
      return response;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }


  static Future<bool?> loginWebChatViaQRCode(String barcode) async {
    bool? response;
    try {
      response = await mirrorFlyMethodChannel.invokeMethod<bool>('loginWebChatViaQRCode', { "barcode" : barcode});
      debugPrint("loginWebChatViaQRCode Response ==> $response");
      return response;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<bool?> webLoginDetailsCleared() async {
    bool? response;
    try {
      response = await mirrorFlyMethodChannel.invokeMethod<bool>('webLoginDetailsCleared');
      debugPrint("webLoginDetailsCleared Response ==> $response");
      return response;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<bool?> logoutWebUser(List<String> logins) async {
    bool? response;
    try {
      response = await mirrorFlyMethodChannel.invokeMethod<bool>('logoutWebUser',{"listWebLogin":logins});
      debugPrint("logoutWebUser Response ==> $response");
      return response;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> getWebLoginDetails() async {
    dynamic response;
    try {
      response = await mirrorFlyMethodChannel.invokeMethod('getWebLoginDetails');
      debugPrint("getWebLoginDetails Response ==> $response");
      return response;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> updateFavouriteStatus(String messageID, String chatUserJID, bool isFavourite) async {//favouriteMessage
    dynamic favResponse;
    try {
      favResponse = await mirrorFlyMethodChannel.invokeMethod('updateFavouriteStatus', { "messageID" : messageID, "chatUserJID": chatUserJID, "isFavourite": isFavourite});
      debugPrint("Favourite Msg Response ==> $favResponse");
      return favResponse;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> forwardMessagesToMultipleUsers(List<String> messageIds, List<String> userList) async {//forwardMessage
    dynamic forwardMessageResponse;
    try {
      forwardMessageResponse = await mirrorFlyMethodChannel.invokeMethod('forwardMessagesToMultipleUsers', { "message_ids" : messageIds, "userList": userList});
      debugPrint("Forward Msg Response ==> $forwardMessageResponse");
      return forwardMessageResponse;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> forwardMessages(List<String> messageIds, String tojid,String chattype) async {//forwardMessage
    dynamic forwardMessageResponse;
    try {
      forwardMessageResponse = await mirrorFlyMethodChannel.invokeMethod('forwardMessages', { "message_ids" : messageIds, "to_jid": tojid,"chat_type":chattype});
      debugPrint("forwardMessages Response ==> $forwardMessageResponse");
      return forwardMessageResponse;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> createGroup(String groupname, List<String> userList,String image) async {
    dynamic response;
    try {
      response = await mirrorFlyMethodChannel.invokeMethod('createGroup', { "group_name" : groupname, "members": userList,"file":image,});
      debugPrint("create group Response ==> $response");
      return response;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<bool?> addUsersToGroup(String jid, List<String> userList) async {
    bool? response;
    try {
      response = await mirrorFlyMethodChannel.invokeMethod<bool>('addUsersToGroup', { "jid" : jid, "members": userList});
      debugPrint("addUsersToGroup Response ==> $response");
      return response;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> getGroupMembersList(String jid, bool? server) async {//getGroupMembers
    dynamic response;
    try {
      response = await mirrorFlyMethodChannel.invokeMethod('getGroupMembersList', { "jid" : jid, "server": server,});
      debugPrint("getGroupMembersList Response ==> $response");
      return response;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> getUsersIBlocked( bool? server) async {
    dynamic response;
    try {
      response = await mirrorFlyMethodChannel.invokeMethod('getUsersIBlocked', { "serverCall": server,});
      debugPrint("getUsersIBlocked Response ==> $response");
      return response;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> getMediaMessages(String jid) async {
    dynamic response;
    try {
      response = await mirrorFlyMethodChannel.invokeMethod('getMediaMessages', { "jid" : jid,});
      debugPrint("getMediaMessages Response ==> $response");
      return response;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> getDocsMessages(String jid) async {
    dynamic response;
    try {
      response = await mirrorFlyMethodChannel.invokeMethod('getDocsMessages', { "jid" : jid,});
      debugPrint("getDocsMessages Response ==> $response");
      return response;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> getLinkMessages(String jid) async {
    dynamic response;
    try {
      response = await mirrorFlyMethodChannel.invokeMethod('getLinkMessages', { "jid" : jid,});
      debugPrint("getLinkMessages Response ==> $response");
      return response;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static exportChatConversationToEmail(String jid) async {
    try {
      await mirrorFlyMethodChannel.invokeMethod('exportChatConversationToEmail', {"jid" : jid });
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }
  static Future<bool?> reportUserOrMessages(String jid,String type, String? messageId) async {
    bool? response;
    try {
      response = await mirrorFlyMethodChannel.invokeMethod<bool>('reportUserOrMessages',{"jid" : jid,"chat_type":type, "selectedMessageID" : messageId });
      debugPrint("report Result ==> $response");
      return response;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      return false;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      return false;
    }
  }
  static Future<bool?> makeAdmin(String groupjid,String userjid) async {
    bool? response;
    try {
      response = await mirrorFlyMethodChannel.invokeMethod<bool>('makeAdmin',{"jid" : groupjid,"userjid":userjid });
      debugPrint("report Result ==> $response");
      return response;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      return false;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      return false;
    }
  }
  static Future<bool?> removeMemberFromGroup(String groupjid,String userjid) async {
    bool? response;
    try {
      response = await mirrorFlyMethodChannel.invokeMethod<bool>('removeMemberFromGroup',{"jid" : groupjid,"userjid":userjid });
      debugPrint("report Result ==> $response");
      return response;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      return false;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      return false;
    }
  }
  static Future<bool?> leaveFromGroup(String jid) async {
    bool? response;
    try {
      response = await mirrorFlyMethodChannel.invokeMethod<bool>('leaveFromGroup',{"jid" : jid });
      debugPrint("leaveFromGroup Result ==> $response");
      return response;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      return false;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      return false;
    }
  }
  static Future<bool?> deleteGroup(String jid) async {
    bool? response;
    try {
      response = await mirrorFlyMethodChannel.invokeMethod<bool>('deleteGroup',{"jid" : jid });
      debugPrint("leaveFromGroup Result ==> $response");
      return response;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      return false;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      return false;
    }
  }

  static Future<bool?> isAdmin(String jid) async {
    bool? response;
    try {
      response = await mirrorFlyMethodChannel.invokeMethod<bool>('isAdmin',{"jid" : jid });
      debugPrint("isAdmin Result ==> $response");
      return response;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      return false;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      return false;
    }
  }

  static Future<bool?> updateGroupProfileImage(String jid,String file) async {
    bool? response;
    try {
      response = await mirrorFlyMethodChannel.invokeMethod<bool>('updateGroupProfileImage',{"jid" : jid,"file":file });
      debugPrint("updateGroupProfileImage Result ==> $response");
      return response;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      return false;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      return false;
    }
  }

  static Future<bool?> updateGroupName(String jid,String name) async {
    bool? response;
    try {
      response = await mirrorFlyMethodChannel.invokeMethod<bool>('updateGroupName',{"jid" : jid,"name":name });
      debugPrint("updateGroupName Result ==> $response");
      return response;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      return false;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      return false;
    }
  }

  static Future<bool?> isMemberOfGroup(String jid,String? userjid) async {
    bool? response;
    try {
      response = await mirrorFlyMethodChannel.invokeMethod<bool>('isMemberOfGroup',{"jid" : jid,"userjid":userjid });
      debugPrint("isMemberOfGroup Result ==> $response");
      return response;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      return false;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      return false;
    }
  }

  static Future<bool?> sendContactUsInfo(String title,String description) async {
    bool? response;
    try {
      response = await mirrorFlyMethodChannel.invokeMethod<bool>('sendContactUsInfo',{"title" : title,"description":description });
      debugPrint("sendContactUsInfo Result ==> $response");
      return response;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      return false;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      return false;
    }
  }

  static copyTextMessages(List<String> messageIds) async {
    try {
      await mirrorFlyMethodChannel.invokeMethod('copyTextMessages', {"messageidlist" : messageIds });
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static saveUnsentMessage(String jid, String message) async {
    try {
      await mirrorFlyMethodChannel.invokeMethod('saveUnsentMessage', {"jid" : jid,"message":message });
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> deleteAccount(String reason, String? feedback) async {
    dynamic response;
    try {
      response = await mirrorFlyMethodChannel.invokeMethod('delete_account', {"delete_reason" : reason, "delete_feedback" : feedback });
      return response;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }
  static Future<dynamic> getFavouriteMessages() async {
    dynamic favResponse;
    try {
      favResponse = await mirrorFlyMethodChannel.invokeMethod('get_favourite_messages');
      debugPrint("fav response ==> $favResponse");
      return favResponse;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }
  static Future<dynamic> getAllGroups([bool? server]) async {
    dynamic response;
    try {
      response = await mirrorFlyMethodChannel.invokeMethod('getAllGroups',{"server":server});
      debugPrint("getAllGroups response ==> $response");
      return response;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<String?> getDefaultNotificationUri() async {
    String? uri = "";
    try {
      uri = await mirrorFlyMethodChannel
          .invokeMethod<String?>('getDefaultNotificationUri');
      return uri;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }
  static setNotificationUri(String uri) async {
    try {
      await mirrorFlyMethodChannel
          .invokeMethod('setNotificationUri',{"uri":uri});
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }
  static setNotificationSound(bool enable) async {
    try {
      await mirrorFlyMethodChannel
          .invokeMethod('setNotificationSound',{"enable":enable});
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }
  static setMuteNotification(bool enable) async {
    try {
      await mirrorFlyMethodChannel
          .invokeMethod('setMuteNotification',{"enable":enable});
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }
  static setNotificationVibration(bool enable) async {
    try {
      await mirrorFlyMethodChannel
          .invokeMethod('setNotificationVibration',{"enable":enable});
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }
  static cancelNotifications() async {
    try {
      await mirrorFlyMethodChannel
          .invokeMethod('cancelNotifications');
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

}