
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';

import '../common/constants.dart';
import '../data/session_management.dart';
import '../model/statusModel.dart';

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


  static Future<String> mediaEndPoint() async {
    String? response = "";
    try {
      response = await mirrorFlyMethodChannel
          .invokeMethod<String>('media_endpoint');
      debugPrint("media_endpoint Result ==> $response");
      return response.checkNull();
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<String> getUserLastSeenTime(String jid) async {
    String? response = "";
    try {
      response = await mirrorFlyMethodChannel
          .invokeMethod<String>('getUserLastSeenTime',{"jid":jid});
      debugPrint("getUserLastSeenTime Result ==> $response");
      return response.checkNull();
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<String> authToken() async {
    String? registerResponse = "";
    try {
      registerResponse = await mirrorFlyMethodChannel
          .invokeMethod<String>('authtoken');
      debugPrint("authToken Result ==> $registerResponse");

      return registerResponse.checkNull();
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

  static Future<String> verifyToken(String userName,String token) async {
    String? response = "";
    try {
      response = await mirrorFlyMethodChannel.invokeMethod<String>('verifyToken', {"userName": userName,"googleToken":token});
      debugPrint("verifyToken Result ==> $response");
      return response.checkNull();
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
          .invokeMethod('sentLocationMessage', {"jid": jid,"latitude":latitude,"longitude":longitude, "replyMessageId" : replyMessageId});
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
      String? replyMessageID) async {
    dynamic messageResp;
    try {
      messageResp =
      await mirrorFlyMethodChannel.invokeMethod('send_image_message', {
        "jid": jid,
        "filePath": filePath,
        "caption": caption,
        "replyMessageId": replyMessageID
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
      String? replyMessageID) async {
    dynamic messageResp;
    try {
      messageResp =
      await mirrorFlyMethodChannel.invokeMethod('send_video_message', {
        "jid": jid,
        "filePath": filePath,
        "caption": caption,
        "replyMessageId": replyMessageID
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

  static Future<dynamic> getUserList() async {//getRegisteredUserList
    dynamic messageResp;
    try {
      messageResp = await mirrorFlyMethodChannel.invokeMethod('get_user_list');
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

  static Future<dynamic> getUsers(int page,String search) async {
    dynamic re;
    try {
      re = await mirrorFlyMethodChannel.invokeMethod("get_user_list",{"page":page,"search":search});
      debugPrint('RESULT ==> $re');
      return re;
    } on PlatformException catch (e) {
      Log("er",e.toString());
      return re;
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

  static Future<String?> imagePath(String imgurl) async {
    var re = "";
    try {
      final result = await mirrorFlyMethodChannel
          .invokeMethod<String>("get_image_path", {"image": imgurl});
      debugPrint('RESULT ==> $result');
      return result;
    } on PlatformException catch (e) {
      Log("er",e.toString());
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
      Log('RESULT', '$result');
      return result;
    } on PlatformException catch (e) {
      Log("er",e.toString());
      return result;
    }
  }

  static Future<dynamic> sentFileMessage(String? file, String jid) async {
    var re = "";
    try {
      final result = await mirrorFlyMethodChannel
          .invokeMethod("sent file", {"file": file, "jid": jid, "message": ""});
      Log('RESULT', '$result');
      return result;
    } on PlatformException catch (e) {
      Log("er",e.toString());
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
      Log("statuslist","$statusResponse");
      return statusResponse;
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }
  static Future<dynamic> insertDefaultStatus(String status) async {//insertStatus
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
  static void insertDefaultStatusToUser() async{
    try {
      await mirrorFlyMethodChannel.invokeMethod('getStatusList').then((value) {
        Log("status list", "$value");
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
  }
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

  static Future<dynamic> getUserProfile(String jid) async {//getProfile
    dynamic profileResponse;
    try {
      profileResponse = await mirrorFlyMethodChannel.invokeMethod('getUserProfile',{"jid":jid});
      debugPrint("profile Result ==> $profileResponse");
      insertDefaultStatusToUser();
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
      debugPrint("profile Result ==> $profileResponse");
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
      debugPrint("profile Result ==> $profileResponse");
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
      debugPrint("profile Result ==> $profileResponse");
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
      debugPrint("profile Result ==> $profileResponse");
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
      debugPrint("profile Result ==> $profileResponse");
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
      await mirrorFlyMethodChannel.invokeMethod('download_media', {"media_id" : mid });
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  static Future<dynamic> sendDocumentMessage(String jid, String documentPath, String replyMessageId) async {
    dynamic documentResponse;
    try {
      documentResponse = await mirrorFlyMethodChannel.invokeMethod('sendDocumentMessage',{ "file" : documentPath , "jid" : jid, "replyMessageId" : replyMessageId});
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

  static Future<dynamic> sendAudioMessage(String jid, String filePath, bool isRecorded, String duration, String replyMessageId) async {//sendAudio
    dynamic audioResponse;
    try {
      audioResponse = await mirrorFlyMethodChannel.invokeMethod('sendAudioMessage',{ "filePath" : filePath , "jid" : jid, "isRecorded" : isRecorded, "duration" : duration, "replyMessageId" : replyMessageId});
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

  static Future<dynamic> searchConversation(String searchKey) async {//filteredMessageList
    dynamic response;
    try {
      response = await mirrorFlyMethodChannel.invokeMethod('searchConversation',{"searchKey":searchKey});
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
      messageListResponse = await mirrorFlyMethodChannel.invokeMethod('get_message_using_ids',{ "MessageIds" : messageIds});
      debugPrint("Message List Response ==> $messageListResponse");
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

  static Future<dynamic> addUsersToGroup(String jid, List<String> userList) async {
    dynamic response;
    try {
      response = await mirrorFlyMethodChannel.invokeMethod('addUsersToGroup', { "jid" : jid, "members": userList});
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
      await mirrorFlyMethodChannel.invokeMethod('exportChat', {"jid" : jid });
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