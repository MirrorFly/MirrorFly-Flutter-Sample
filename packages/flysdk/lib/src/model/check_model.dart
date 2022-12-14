// To parse this JSON data, do
//
//     final checkModel = checkModelFromJson(jsonString);

import 'dart:convert';

import '../../flysdk.dart';

CheckModel checkModelFromJson(String str) => CheckModel.fromJson(json.decode(str));

String checkModelToJson(CheckModel data) => json.encode(data.toJson());


//
// ChatMessageModel sendMessageModelFromJson(String str) => ChatMessageModel.fromJson(json.decode(str));
//
// String sendMessageModelToJson(ChatMessageModel data) => json.encode(data.toJson());

class CheckModel {
  CheckModel({
    required this.chatUserJid,
    required this.contactType,
    required this.isItCarbonMessage,
    required this.isItSavedContact,
    required this.isMessageDeleted,
    required this.isMessageRecalled,
    required this.isMessageSentByMe,
    required this.isMessageStarred,
    required this.isSelected,
    required this.isThisAReplyMessage,
    required this.mediaChatMessage,
    required this.messageChatType,
    // required this.messageCustomField,
    required this.messageId,
    required this.messageSentTime,
    required this.messageStatus,
    required this.messageTextContent,
    required this.messageType,
    required this.senderNickName,
    required this.senderUserJid,
    required this.senderUserName,
  });

  String chatUserJid;
  String contactType;
  bool isItCarbonMessage;
  bool isItSavedContact;
  bool isMessageDeleted;
  bool isMessageRecalled;
  bool isMessageSentByMe;
  bool isMessageStarred;
  bool isSelected;
  bool isThisAReplyMessage;
  MediaChatMessage mediaChatMessage;
  String messageChatType;
  // MessageCustomField messageCustomField;
  String messageId;
  int messageSentTime;
  MessageStatus messageStatus;
  dynamic messageTextContent;
  String messageType;
  String senderNickName;
  String senderUserJid;
  String senderUserName;

  factory CheckModel.fromJson(Map<String, dynamic> json) => CheckModel(
    chatUserJid: json["chatUserJid"],
    contactType: json["contactType"],
    isItCarbonMessage: json["isItCarbonMessage"],
    isItSavedContact: json["isItSavedContact"],
    isMessageDeleted: json["isMessageDeleted"],
    isMessageRecalled: json["isMessageRecalled"],
    isMessageSentByMe: json["isMessageSentByMe"],
    isMessageStarred: json["isMessageStarred"],
    isSelected: json["isSelected"],
    isThisAReplyMessage: json["isThisAReplyMessage"],
    mediaChatMessage: MediaChatMessage.fromJson(json["mediaChatMessage"]),
    messageChatType: json["messageChatType"] == "singleChat" ? "chat" : json["messageChatType"].toLowerCase(),
    // messageCustomField: MessageCustomField.fromJson(json["messageCustomField"]),
    messageId: json["messageId"],
    messageSentTime: json["messageSentTime"],
    messageStatus: MessageStatus.fromJson(json["messageStatus"]),
    messageTextContent: json["messageTextContent"],
    messageType: json["messageType"],
    senderNickName: json["senderNickName"],
    senderUserJid: json["senderUserJid"],
    senderUserName: json["senderUserName"],
  );

  Map<String, dynamic> toJson() => {
    "chatUserJid": chatUserJid,
    "contactType": contactType,
    "isItCarbonMessage": isItCarbonMessage,
    "isItSavedContact": isItSavedContact,
    "isMessageDeleted": isMessageDeleted,
    "isMessageRecalled": isMessageRecalled,
    "isMessageSentByMe": isMessageSentByMe,
    "isMessageStarred": isMessageStarred,
    "isSelected": isSelected,
    "isThisAReplyMessage": isThisAReplyMessage,
    "mediaChatMessage": mediaChatMessage.toJson(),
    "messageChatType": messageChatType,
    // "messageCustomField": messageCustomField.toJson(),
    "messageId": messageId,
    "messageSentTime": messageSentTime,
    "messageStatus": messageStatus.toJson(),
    "messageTextContent": messageTextContent,
    "messageType": messageType,
    "senderNickName": senderNickName,
    "senderUserJid": senderUserJid,
    "senderUserName": senderUserName,
  };
}

/*
class MediaChatMessage {
  MediaChatMessage({
    required this.isAudioRecorded,
    required this.mediaCaptionText,
    required this.mediaDownloadStatus,
    required this.mediaDuration,
    required this.mediaFileHeight,
    required this.mediaFileName,
    required this.mediaFileSize,
    required this.mediaFileType,
    required this.mediaFileWidth,
    required this.mediaLocalStoragePath,
    required this.mediaProgressStatus,
    required this.mediaThumbImage,
    required this.mediaUploadStatus,
    required this.messageId,
    required this.messageType,
  });

  bool isAudioRecorded;
  dynamic mediaCaptionText;
  int mediaDownloadStatus;
  int mediaDuration;
  int mediaFileHeight;
  String mediaFileName;
  int mediaFileSize;
  dynamic mediaFileType;
  int mediaFileWidth;
  dynamic mediaLocalStoragePath;
  int mediaProgressStatus;
  String mediaThumbImage;
  int mediaUploadStatus;
  String messageId;
  String messageType;

  factory MediaChatMessage.fromJson(Map<String, dynamic> json) => MediaChatMessage(
    isAudioRecorded: json["isAudioRecorded"],
    mediaCaptionText: json["mediaCaptionText"],
    mediaDownloadStatus: json["mediaDownloadStatus"],
    mediaDuration: json["mediaDuration"],
    mediaFileHeight: json["mediaFileHeight"],
    mediaFileName: json["mediaFileName"],
    mediaFileSize: json["mediaFileSize"],
    mediaFileType: json["mediaFileType"],
    mediaFileWidth: json["mediaFileWidth"],
    mediaLocalStoragePath: json["mediaLocalStoragePath"],
    mediaProgressStatus: json["mediaProgressStatus"],
    mediaThumbImage: json["mediaThumbImage"],
    mediaUploadStatus: json["mediaUploadStatus"],
    messageId: json["messageId"],
    messageType: json["messageType"],
  );

  Map<String, dynamic> toJson() => {
    "isAudioRecorded": isAudioRecorded,
    "mediaCaptionText": mediaCaptionText,
    "mediaDownloadStatus": mediaDownloadStatus,
    "mediaDuration": mediaDuration,
    "mediaFileHeight": mediaFileHeight,
    "mediaFileName": mediaFileName,
    "mediaFileSize": mediaFileSize,
    "mediaFileType": mediaFileType,
    "mediaFileWidth": mediaFileWidth,
    "mediaLocalStoragePath": mediaLocalStoragePath,
    "mediaProgressStatus": mediaProgressStatus,
    "mediaThumbImage": mediaThumbImage,
    "mediaUploadStatus": mediaUploadStatus,
    "messageId": messageId,
    "messageType": messageType,
  };
}
*/

/*class MessageCustomField {
  MessageCustomField();

  factory MessageCustomField.fromJson(Map<String, dynamic> json) => MessageCustomField(
  );

  Map<String, dynamic> toJson() => {
  };
}*/

/*class MessageStatus {
  MessageStatus({
    required this.status,
  });

  String status;

  factory MessageStatus.fromJson(Map<String, dynamic> json) => MessageStatus(
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
  };
}*/
