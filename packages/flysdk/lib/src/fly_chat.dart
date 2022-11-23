library flysdk;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class FlyChat {

  FlyChat._();

  static const mirrorFlyMethodChannel = MethodChannel('contus.mirrorfly/sdkCall');

  //Event Channels
  static const EventChannel MESSAGE_ONRECEIVED_CHANNEL = EventChannel('contus.mirrorfly/onMessageReceived');
  static const EventChannel MESSAGE_STATUS_UPDATED_CHANNEL = EventChannel('contus.mirrorfly/onMessageStatusUpdated');
  static const EventChannel MEDIA_STATUS_UPDATED_CHANNEL = EventChannel('contus.mirrorfly/onMediaStatusUpdated');
  static const EventChannel UPLOAD_DOWNLOAD_PROGRESS_CHANGED_CHANNEL = EventChannel('contus.mirrorfly/onUploadDownloadProgressChanged');
  static const EventChannel SHOW_UPDATE_CANCEL_NOTIFICTION_CHANNEL = EventChannel('contus.mirrorfly/showOrUpdateOrCancelNotification');

  static const EventChannel onGroupProfileFetched_channel = EventChannel('contus.mirrorfly/onGroupProfileFetched');
  static const EventChannel onNewGroupCreated_channel = EventChannel('contus.mirrorfly/onNewGroupCreated');
  static const EventChannel onGroupProfileUpdated_channel = EventChannel('contus.mirrorfly/onGroupProfileUpdated');
  static const EventChannel onNewMemberAddedToGroup_channel = EventChannel('contus.mirrorfly/onNewMemberAddedToGroup');
  static const EventChannel onMemberRemovedFromGroup_channel = EventChannel('contus.mirrorfly/onMemberRemovedFromGroup');
  static const EventChannel onFetchingGroupMembersCompleted_channel = EventChannel('contus.mirrorfly/onFetchingGroupMembersCompleted');
  static const EventChannel onDeleteGroup_channel = EventChannel('contus.mirrorfly/onDeleteGroup');
  static const EventChannel onFetchingGroupListCompleted_channel = EventChannel('contus.mirrorfly/onFetchingGroupListCompleted');
  static const EventChannel onMemberMadeAsAdmin_channel = EventChannel('contus.mirrorfly/onMemberMadeAsAdmin');
  static const EventChannel onMemberRemovedAsAdmin_channel = EventChannel('contus.mirrorfly/onMemberRemovedAsAdmin');
  static const EventChannel onLeftFromGroup_channel = EventChannel('contus.mirrorfly/onLeftFromGroup');
  static const EventChannel onGroupNotificationMessage_channel = EventChannel('contus.mirrorfly/onGroupNotificationMessage');
  static const EventChannel onGroupDeletedLocally_channel = EventChannel('contus.mirrorfly/onGroupDeletedLocally');


  static Future<bool?> syncContacts() async {
    bool? res;
    try {
      res = await mirrorFlyMethodChannel
          .invokeMethod<bool>('syncContacts');
      return res;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }



  static Stream<dynamic> get onMessageReceived => MESSAGE_ONRECEIVED_CHANNEL.receiveBroadcastStream().cast();
  static Stream<dynamic> get onMessageStatusUpdated => MESSAGE_STATUS_UPDATED_CHANNEL.receiveBroadcastStream().cast();
  static Stream<dynamic> get onMediaStatusUpdated => MEDIA_STATUS_UPDATED_CHANNEL.receiveBroadcastStream().cast();

  static Stream<dynamic> get onGroupProfileFetched => onGroupProfileFetched_channel.receiveBroadcastStream().cast();
  static Stream<dynamic> get onNewGroupCreated => onNewGroupCreated_channel.receiveBroadcastStream().cast();
  static Stream<dynamic> get onGroupProfileUpdated => onGroupProfileUpdated_channel.receiveBroadcastStream().cast();
  static Stream<dynamic> get onNewMemberAddedToGroup => onNewMemberAddedToGroup_channel.receiveBroadcastStream().cast();
  static Stream<dynamic> get onMemberRemovedFromGroup => onMemberRemovedFromGroup_channel.receiveBroadcastStream().cast();
  static Stream<dynamic> get onFetchingGroupMembersCompleted => onFetchingGroupMembersCompleted_channel.receiveBroadcastStream().cast();
  static Stream<dynamic> get onDeleteGroup => onDeleteGroup_channel.receiveBroadcastStream().cast();
  static Stream<dynamic> get onFetchingGroupListCompleted => onFetchingGroupListCompleted_channel.receiveBroadcastStream().cast();
  static Stream<dynamic> get onMemberMadeAsAdmin => onMemberMadeAsAdmin_channel.receiveBroadcastStream().cast();
  static Stream<dynamic> get onMemberRemovedAsAdmin => onMemberRemovedAsAdmin_channel.receiveBroadcastStream().cast();
  static Stream<dynamic> get onLeftFromGroup => onLeftFromGroup_channel.receiveBroadcastStream().cast();
  static Stream<dynamic> get onGroupNotificationMessage => onGroupNotificationMessage_channel.receiveBroadcastStream().cast();
  static Stream<dynamic> get onGroupDeletedLocally => onGroupDeletedLocally_channel.receiveBroadcastStream().cast();



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

  static updateChatMuteStatus(String jid,bool checked) async {//groupMute
    try {
      await mirrorFlyMethodChannel.invokeMethod('updateChatMuteStatus', {"jid" : jid,"checked":checked });
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static copyTextMessages(String messageId) async {
    List<String> messageIds = [messageId];
    try {
      await mirrorFlyMethodChannel.invokeMethod('copy_text_messages', {"message_id_list" : messageIds });
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


}