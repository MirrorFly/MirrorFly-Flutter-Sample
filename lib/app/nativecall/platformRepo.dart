
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';

import '../common/constants.dart';
import '../model/statusModel.dart';

class PlatformRepo {
  static const mirrorFlyMethodChannel =
  MethodChannel('contus.mirrorfly/sdkCall');

  //Event Channels
  static const EventChannel MESSAGE_ONRECEIVED_CHANNEL = EventChannel('contus.mirrorfly/onMessageReceived');
  static const EventChannel MESSAGE_STATUS_UPDATED_CHANNEL = EventChannel('contus.mirrorfly/onMessageStatusUpdated');
  static const EventChannel MEDIA_STATUS_UPDATED_CHANNEL = EventChannel('contus.mirrorfly/onMediaStatusUpdated');
  static const EventChannel UPLOAD_DOWNLOAD_PROGRESS_CHANGED_CHANNEL = EventChannel('contus.mirrorfly/onUploadDownloadProgressChanged');
  static const EventChannel SHOW_UPDATE_CANCEL_NOTIFICTION_CHANNEL = EventChannel('contus.mirrorfly/showOrUpdateOrCancelNotification');


  Future<String> media_endpoint() async {
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

  Future<String> authtoken() async {
    String? registerResponse = "";
    try {
      registerResponse = await mirrorFlyMethodChannel
          .invokeMethod<String>('authtoken');
      debugPrint("authtoken Result ==> $registerResponse");

      return registerResponse.checkNull();
    } on PlatformException catch (e) {
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  Future<dynamic> registerUser(String userIdentifier,String token) async {
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

  Future<String> verifyToken(String userName,String token) async {
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

  Future<dynamic> getUserJID(String username) async {
    dynamic userJID;
    try {
      userJID = await mirrorFlyMethodChannel
          .invokeMethod('get_user_jid', {"username": username});
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

  Future<dynamic> sendTextMessage(String message, String JID, String replyMessageId) async {
    dynamic messageResp;
    try {
      messageResp = await mirrorFlyMethodChannel
          .invokeMethod('send_text_msg', {"message": message, "JID": JID, "replyMessageId" : replyMessageId});
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

  Future<dynamic> sentLocationMessage(String JID,double latitude,double longitude, String replyMessageId) async {
    dynamic messageResp;
    try {
      messageResp = await mirrorFlyMethodChannel
          .invokeMethod('sentLocationMessage', {"jid": JID,"latitude":latitude,"longitude":longitude, "replyMessageId" : replyMessageId});
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

  Future<dynamic> sendImageMessage(
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

  Future<dynamic> sendMediaMessage(
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

  Future<dynamic> getRegisteredUserList() async {
    dynamic messageResp;
    try {
      messageResp = await mirrorFlyMethodChannel.invokeMethod('get_user_list');
      debugPrint("Userlist Result ==> $messageResp");
      return messageResp;
    } on PlatformException catch (e) {
      debugPrint("Userlist Exception ===> $e");
      rethrow;
    } on Exception catch (error) {
      debugPrint("Userlist Exception ==> $error");
      rethrow;
    }
  }

  Future<dynamic> getUsers(int page,String search) async {
    var re = "";
    try {
      // final result = await mirrorFlyMethodChannel
      //     .invokeMethod("get_user_list", {"page": page});
      final result = await mirrorFlyMethodChannel.invokeMethod("get_user_list",{"page":page,"search":search});
      debugPrint('RESULT ==> $result');
      return result;
    } on PlatformException catch (e) {
      print(e);
      return re;
    }
  }


  // connectChatManager(String username) async{
  //   String chatManagerResponse;
  //   try {
  //     chatManagerResponse = await mirrorFlyMethodChannel.invokeMethod('connect_chat_manager', { "userIdentifier":username });
  //     debugPrint("Chat Manager Response ==> $chatManagerResponse");
  //     return chatManagerResponse;
  //   }on PlatformException catch (e){
  //     debugPrint("Chat Manager Exception ===> $e");
  //     rethrow;
  //   } on Exception catch(error){
  //     debugPrint("Chat Manager Exception ==> $error");
  //     rethrow;
  //   }
  // }

  Stream<dynamic> get onMessageReceived {
    return MESSAGE_ONRECEIVED_CHANNEL.receiveBroadcastStream().cast();
  }
  Stream<dynamic> get onMessageStatusUpdated {
    return MESSAGE_STATUS_UPDATED_CHANNEL.receiveBroadcastStream().cast();
  }
  Stream<dynamic> get onMediaStatusUpdated {
    return MEDIA_STATUS_UPDATED_CHANNEL.receiveBroadcastStream().cast();
  }

  // Stream<dynamic> chatEvents(String event) {
  //   return chatEventChannel.receiveBroadcastStream(event).cast();
  // }
  Future<String?> imagePath(String imgurl) async {
    var re = "";
    try {
      final result = await mirrorFlyMethodChannel
          .invokeMethod<String>("get_image_path", {"image": imgurl});
      debugPrint('RESULT ==> $result');
      return result;
    } on PlatformException catch (e) {
      print(e);
      return re;
    }
  }

  Future<dynamic> saveProfile(String name, String email) async {
    var re;
    try {
      final result =
      await mirrorFlyMethodChannel.invokeMethod("updateProfile", {
        "name": name,
        "email": email,
      });
      print('RESULT -> $result');
      return result;
    } on PlatformException catch (e) {
      print(e);
      return re;
    }
  }

  Future<dynamic> sentFileMessage(String? file, String jid) async {
    var re = "";
    try {
      final result = await mirrorFlyMethodChannel
          .invokeMethod("sentfile", {"file": file, "jid": jid, "message": ""});
      print('RESULT -> $result');
      return result;
    } on PlatformException catch (e) {
      print(e);
      return re;
    }
  }

  Future<dynamic> getRecentChats() async {
    dynamic recentResponse;
    try {
      recentResponse =
      await mirrorFlyMethodChannel.invokeMethod('get_recent_chats');
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
  Future<dynamic> getStatusList() async {
    dynamic statusResponse;
    try {
      statusResponse =
      await mirrorFlyMethodChannel.invokeMethod('getStatusList');
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
  Future<dynamic> insertStatus(String status) async {
    try {
      await mirrorFlyMethodChannel.invokeMethod('insertStatus', {"status" : status });
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }
  void insertDefaultStatusToUser() async{
    try {
      await mirrorFlyMethodChannel.invokeMethod('getStatusList').then((value) {
        Log("statuslist", "$value");
        if (value != null) {
          var profileStatus = statusDataFromJson(value);
          if (profileStatus.isNotEmpty) {
            var defaultStatus = Constants.defaultStatuslist;
            defaultStatus.forEach((statusValue) {
              var isStatusNotExist = true;
              profileStatus.forEach((flyStatus) {
                if (flyStatus == (statusValue))
                  isStatusNotExist = false;
              });
              if (isStatusNotExist) {
                PlatformRepo().insertStatus(statusValue);
              }
            });
          }else{
            var defaultStatus = Constants.defaultStatuslist;
            defaultStatus.forEach((statusValue) {
              PlatformRepo().insertStatus(statusValue);
            });
          }
        }
      });
    } on Exception catch(er){
      debugPrint("Exception ==> $er");
    }
  }
  Future<dynamic> updateProfile(String name, String email,String mobile, String status,String? image) async {
    dynamic profileResponse;
    try {
      profileResponse = await mirrorFlyMethodChannel.invokeMethod('updateProfile',{"name":name,"email":email,"mobile":mobile,"status":status,"image":image});
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

  Future<dynamic> getProfile(String jid) async {
    dynamic profileResponse;
    try {
      profileResponse = await mirrorFlyMethodChannel.invokeMethod('getProfile',{"jid":jid});
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

  Future<dynamic> getProfileLocal(String jid,bool server) async {
    dynamic profileResponse;
    try {
      profileResponse = await mirrorFlyMethodChannel.invokeMethod('getProfile',{"jid":jid,"server":server});
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

  Future<dynamic> updateProfileStatus(String status) async {
    dynamic profileResponse;
    try {
      profileResponse = await mirrorFlyMethodChannel.invokeMethod('updateProfileStatus',{"status":status});
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

  Future<dynamic> updateProfileImage(String image) async {
    dynamic profileResponse;
    try {
      profileResponse = await mirrorFlyMethodChannel.invokeMethod('updateProfileImage',{"image":image});
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

  Future<bool?> removeProfileImage() async {
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

  Future<bool?> refreshAuthToken() async {
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

  Future<dynamic> getChatHistory(String jid) async {
    dynamic chatResponse;
    try {
      chatResponse = await mirrorFlyMethodChannel.invokeMethod('get_user_chat_history',{ "JID" : jid });
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
  Future<dynamic> listenMessageEvents() async {
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
  Future<dynamic> getMedia(String mid) async {
    dynamic media;
    try {
      media = await mirrorFlyMethodChannel.invokeMethod('get_media',{ "message_id" : mid });
      // debugPrint("mediaResponse ==> $media");
      return media;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  Future<dynamic> sendReadReceipts(String jid) async {
    dynamic readReceiptResponse;
    try {
      readReceiptResponse = await mirrorFlyMethodChannel.invokeMethod('send_read_receipts',{ "jid" : jid });
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

  Future<dynamic> sendContacts(List<String> contactList, String jid, String contactName, String replyMessageId) async {
    dynamic contactResponse;
    try {
      contactResponse = await mirrorFlyMethodChannel.invokeMethod('send_contact',{ "contact_list" : contactList , "jid" : jid, "contact_name" : contactName, "replyMessageId" : replyMessageId});
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

  Future<dynamic> logout() async {
    dynamic logoutResponse;
    try {
      logoutResponse = await mirrorFlyMethodChannel.invokeMethod('logout');
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

  ongoingChat(String jid) async {
    try {
      await mirrorFlyMethodChannel.invokeMethod('ongoing_chat', {"jid" : jid });
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }
  mediaDownload(String mid) async {
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

  Future<dynamic> sendDocument(String jid, String documentPath, String replyMessageId) async {
    dynamic documentResponse;
    try {
      documentResponse = await mirrorFlyMethodChannel.invokeMethod('send_document',{ "file" : documentPath , "jid" : jid, "replyMessageId" : replyMessageId});
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
  Future<dynamic> openFile(String filePath) async {
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

  Future<dynamic> sendAudio(String jid, String filePath, bool isRecorded, String duration, String replyMessageId) async {
    dynamic audioResponse;
    try {
      audioResponse = await mirrorFlyMethodChannel.invokeMethod('send_audio',{ "filePath" : filePath , "jid" : jid, "isRecorded" : isRecorded, "duration" : duration, "replyMessageId" : replyMessageId});
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

  Future<dynamic> filteredRecentChatList() async {
    dynamic response;
    try {
      response = await mirrorFlyMethodChannel.invokeMethod('filteredRecentChatList');
      debugPrint("filteredRecentChatList ==> $response");
      return response;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  Future<dynamic> filteredMessageList(String searchKey) async {
    dynamic response;
    try {
      response = await mirrorFlyMethodChannel.invokeMethod('filteredMessageList',{"searchKey":searchKey});
      debugPrint("filteredMessageList ==> $response");
      return response;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  Future<dynamic> filteredContactList() async {
    dynamic response;
    try {
      response = await mirrorFlyMethodChannel.invokeMethod('filteredContactList');
      debugPrint("filteredContactList ==> $response");
      return response;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }
  Future<dynamic> getMessageOfId(String mid) async {
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
  Future<dynamic> getRecentChatOf(String jid) async {
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

  Future<dynamic> clearChatHistory(String jid, String chatType, bool clearExceptStarred) async {
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

  Future<dynamic> reportChatOrUser(String jid, String chatType, String? MessageId) async {
    dynamic reportResponse;
    try {
      reportResponse = await mirrorFlyMethodChannel.invokeMethod('report_chat',{ "jid" : jid, "chat_type" : chatType, "selectedMessageID" : MessageId});
      debugPrint("clear chat Response ==> $reportResponse");
      return reportResponse;
    }on PlatformException catch (e){
      debugPrint("Platform Exception ===> $e");
      rethrow;
    } on Exception catch(error){
      debugPrint("Exception ==> $error");
      rethrow;
    }
  }

  Future<dynamic> getMessagesUsingIds(List<String> messageIds) async {
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

  Future<dynamic> deleteMessages(String jid, List<String> messageIds, bool isDeleteForEveryOne) async {
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
  Future<dynamic> getMessageInfo(String messageID) async {
    dynamic messageInfoResponse;
    try {
      messageInfoResponse = await mirrorFlyMethodChannel.invokeMethod('get_message_info', { "messageID" : messageID});
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
  Future<dynamic> blockUser(String userJID) async {
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
  Future<dynamic> unBlockUser(String userJID) async {
    dynamic userBlockResponse;
    try {
      userBlockResponse = await mirrorFlyMethodChannel.invokeMethod('un_block_user', { "userJID" : userJID});
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


  Future<dynamic> favouriteMessage(String messageID, String chatUserJID, bool isFavourite) async {
    dynamic favResponse;
    try {
      favResponse = await mirrorFlyMethodChannel.invokeMethod('favourite_message', { "messageID" : messageID, "chatUserJID": chatUserJID, "isFavourite": isFavourite});
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

  Future<dynamic> forwardMessage(List<String> messageIds, List<String> userList) async {
    dynamic forwardMessageResponse;
    try {
      forwardMessageResponse = await mirrorFlyMethodChannel.invokeMethod('forward_messages', { "message_ids" : messageIds, "userList": userList});
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

  Future<dynamic> createGroup(String groupname, List<String> userList,String image) async {
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

  exportChat(String jid) async {
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

  copyTextMessages(String messageId) async {
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

}