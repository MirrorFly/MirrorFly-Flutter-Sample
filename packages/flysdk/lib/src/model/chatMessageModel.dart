// To parse this JSON data, do
//
//     final chatMessageModel = chatMessageModelFromJson(jsonString);

import 'dart:convert';
import 'dart:io';

List<ChatMessageModel> chatMessageModelFromJson(String str) => List<ChatMessageModel>.from(json.decode(str).map((x) => ChatMessageModel.fromJson(x)));

String chatMessageModelToJson(List<ChatMessageModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));


ChatMessageModel sendMessageModelFromJson(String str) => ChatMessageModel.fromJson(json.decode(str));

String sendMessageModelToJson(ChatMessageModel data) => json.encode(data.toJson());


class ChatMessageModel {
  ChatMessageModel({
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
    required this.messageChatType,
    required this.messageCustomField,
    required this.messageId,
    required this.messageSentTime,
    required this.messageStatus,
    required this.messageTextContent,
    required this.messageType,
    required this.replyParentChatMessage,//
    required this.senderNickName,
    required this.senderUserJid,
    required this.senderUserName,
    required this.contactChatMessage,//
    required this.mediaChatMessage,//
    required this.locationChatMessage,//
  });

  String chatUserJid;
  String? contactType;
  bool? isItCarbonMessage;
  bool? isItSavedContact;
  bool isMessageDeleted;
  bool isMessageRecalled;
  bool isMessageSentByMe;
  bool isMessageStarred;
  bool isSelected;
  bool isThisAReplyMessage;
  String messageChatType;
  MessageCustomField? messageCustomField;
  String messageId;
  dynamic messageSentTime;
  String messageStatus;
  String? messageTextContent;
  String messageType;
  ReplyParentChatMessage? replyParentChatMessage;
  String senderNickName;
  String senderUserJid;
  String senderUserName;
  ContactChatMessage? contactChatMessage;
  MediaChatMessage? mediaChatMessage;
  LocationChatMessage? locationChatMessage;

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) => ChatMessageModel(
    chatUserJid: json["chatUserJid"],
    contactType: json["contactType"],
    isItCarbonMessage: json["isItCarbonMessage"],
    isItSavedContact: json["isItSavedContact"],
    isMessageDeleted: json["isMessageDeleted"],
    isMessageRecalled: json["isMessageRecalled"],
    isMessageSentByMe: json["isMessageSentByMe"],
    isMessageStarred: json["isMessageStarred"],
    isSelected: json["isSelected"] ?? false,
    isThisAReplyMessage: Platform.isAndroid ? json["isThisAReplyMessage"] : json["isReplyMessage"],
    messageChatType: json["messageChatType"] == "singleChat" ? "chat" : json["messageChatType"].toLowerCase(),
    messageCustomField: json["replyParentChatMessage"] == null ? null : MessageCustomField.fromJson(json["messageCustomField"]),
    messageId: json["messageId"],
    messageSentTime: json["messageSentTime"],
    messageStatus: Platform.isAndroid ? json["messageStatus"]["status"] : json["messageStatus"],
    messageTextContent: json["messageTextContent"].toString(),
    messageType: json["messageType"].toString().toUpperCase(),
    replyParentChatMessage: json["replyParentChatMessage"] == null ? null : ReplyParentChatMessage.fromJson(json["replyParentChatMessage"]),
    senderNickName: json["senderNickName"],
    senderUserJid: json["senderUserJid"],
    senderUserName: json["senderUserName"],
    contactChatMessage: json["contactChatMessage"] == null ? null : ContactChatMessage.fromJson(json["contactChatMessage"]),
    mediaChatMessage: json["mediaChatMessage"] == null ? null : MediaChatMessage.fromJson(json["mediaChatMessage"]),
    locationChatMessage: json["locationChatMessage"] == null ? null : LocationChatMessage.fromJson(json["locationChatMessage"]),
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
    "messageChatType": messageChatType,
    "messageCustomField": messageCustomField ?? messageCustomField?.toJson(),
    "messageId": messageId,
    "messageSentTime": messageSentTime,
    "messageStatus": messageStatus,
    "messageTextContent": messageTextContent,
    "messageType": messageType,
    "replyParentChatMessage": replyParentChatMessage ?? replyParentChatMessage?.toJson(),
    "senderNickName": senderNickName,
    "senderUserJid": senderUserJid,
    "senderUserName": senderUserName,
    "contactChatMessage": contactChatMessage == null ? null : contactChatMessage!.toJson(),
    "mediaChatMessage": mediaChatMessage == null ? null : mediaChatMessage!.toJson(),
    "locationChatMessage": locationChatMessage == null ? null : locationChatMessage!.toJson(),
  };

}


class ContactChatMessage {
  ContactChatMessage({
    required this.contactName,
    required this.contactPhoneNumbers,
    required this.isChatAppUser,
    required this.messageId,
  });

  String contactName;
  List<String> contactPhoneNumbers;
  List<bool> isChatAppUser;
  String messageId;

  factory ContactChatMessage.fromJson(Map<String, dynamic> json) => ContactChatMessage(
    contactName: json["contactName"],
    contactPhoneNumbers: List<String>.from(json["contactPhoneNumbers"].map((x) => x)),
    isChatAppUser: Platform.isAndroid ? List<bool>.from(json["isChatAppUser"].map((x) => x)) : List<bool>.from(json["isChatUser"].map((x) => x)),
    messageId: json["messageId"],
  );

  Map<String, dynamic> toJson() => {
    "contactName": contactName,
    "contactPhoneNumbers": List<dynamic>.from(contactPhoneNumbers.map((x) => x)),
    "isChatAppUser": List<dynamic>.from(isChatAppUser.map((x) => x)),
    "messageId": messageId,
  };
}

class LocationChatMessage {
  LocationChatMessage({
    required this.latitude,
    required this.longitude,
    required this.mapLocationUrl,
    required this.messageId,
  });

  double latitude;
  double longitude;
  String mapLocationUrl;
  String messageId;

  factory LocationChatMessage.fromJson(Map<String, dynamic> json) => LocationChatMessage(
    latitude: json["latitude"].toDouble(),
    longitude: json["longitude"].toDouble(),
    mapLocationUrl: json["mapLocationUrl"],
    messageId: json["messageId"],
  );

  Map<String, dynamic> toJson() => {
    "latitude": latitude,
    "longitude": longitude,
    "mapLocationUrl": mapLocationUrl,
    "messageId": messageId,
  };
}

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
    required this.isPlaying,
  });

  bool isAudioRecorded;
  String mediaCaptionText;
  int mediaDownloadStatus;
  int mediaDuration;
  int mediaFileHeight;
  String mediaFileName;
  int mediaFileSize;
  String mediaFileType;
  int mediaFileWidth;
  String mediaLocalStoragePath;
  int mediaProgressStatus;
  String mediaThumbImage;
  int mediaUploadStatus;
  String messageId;
  String messageType;
  bool isPlaying;

  factory MediaChatMessage.fromJson(Map<String, dynamic> json) => MediaChatMessage(
    isAudioRecorded: json["isAudioRecorded"] ?? false,
    mediaCaptionText: json["mediaCaptionText"] ?? "",
    mediaDownloadStatus: json["mediaDownloadStatus"] == "not_downloaded" ? 5 : json["mediaDownloadStatus"] == "downloading" ? 3 : json["mediaDownloadStatus"] == "downloaded" ? 4 : json["mediaDownloadStatus"] == "not_available" ? 6 : json["mediaDownloadStatus"] == "failed" ? 401 : json["mediaDownloadStatus"],
    mediaDuration: json["mediaDuration"],
    mediaFileHeight: json["mediaFileHeight"] ?? 0,
    mediaFileName: json["mediaFileName"],
    mediaFileSize: json["mediaFileSize"],
    mediaFileType: json["mediaFileType"],
    mediaFileWidth: json["mediaFileWidth"] ?? 0,
    mediaLocalStoragePath: json["mediaLocalStoragePath"],
    mediaProgressStatus: json["mediaProgressStatus"],
    mediaThumbImage: json["mediaThumbImage"],
    mediaUploadStatus: json["mediaUploadStatus"] == "not_uploaded" ? 0 : json["mediaUploadStatus"] == "uploading" ? 1 : json["mediaUploadStatus"] == "uploaded" ? 2 : json["mediaUploadStatus"] == "not_available" ? 7 : json["mediaUploadStatus"] == "failed" ? 401 : json["mediaUploadStatus"],
    messageId: json["messageId"],
    messageType: json["messageType"],
    isPlaying: false,
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
    "isPlaying": isPlaying,
  };
}

class MessageCustomField {
  MessageCustomField();

  factory MessageCustomField.fromJson(Map<String, dynamic> json) => MessageCustomField(
  );

  Map<String, dynamic> toJson() => {
  };
}

class MessageStatus {
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
}
class ReplyParentChatMessage {
  ReplyParentChatMessage({
    required this.chatUserJid,
    required this.isMessageDeleted,
    required this.isMessageRecalled,
    required this.isMessageSentByMe,
    required this.isMessageStarred,
    required this.messageId,
    required this.messageSentTime,
    required this.messageTextContent,
    required this.messageType,
    required this.senderNickName,
    required this.senderUserName,
    required this.locationChatMessage,
    required this.contactChatMessage,
    required this.mediaChatMessage,
  });

  String chatUserJid;
  bool isMessageDeleted;
  bool isMessageRecalled;
  bool isMessageSentByMe;
  bool isMessageStarred;
  String messageId;
  dynamic messageSentTime;
  String? messageTextContent;
  String messageType;
  String senderNickName;
  String senderUserName;
  LocationChatMessage? locationChatMessage;
  ContactChatMessage? contactChatMessage;
  MediaChatMessage? mediaChatMessage;

  factory ReplyParentChatMessage.fromJson(Map<String, dynamic> json) => ReplyParentChatMessage(
    chatUserJid: json["chatUserJid"],
    isMessageDeleted: json["isMessageDeleted"],
    isMessageRecalled: json["isMessageRecalled"],
    isMessageSentByMe: json["isMessageSentByMe"],
    isMessageStarred: json["isMessageStarred"],
    messageId: json["messageId"],
    messageSentTime: json["messageSentTime"],
    messageTextContent: json["messageTextContent"],
    messageType: json["messageType"],
    senderNickName: json["senderNickName"],
    senderUserName: json["senderUserName"],
    locationChatMessage: json["locationChatMessage"] == null ? null : LocationChatMessage.fromJson(json["locationChatMessage"]),
    contactChatMessage: json["contactChatMessage"] == null ? null : ContactChatMessage.fromJson(json["contactChatMessage"]),
    mediaChatMessage: json["mediaChatMessage"] == null ? null : MediaChatMessage.fromJson(json["mediaChatMessage"]),
  );

  Map<String, dynamic> toJson() => {
    "chatUserJid": chatUserJid,
    "isMessageDeleted": isMessageDeleted,
    "isMessageRecalled": isMessageRecalled,
    "isMessageSentByMe": isMessageSentByMe,
    "isMessageStarred": isMessageStarred,
    "messageId": messageId,
    "messageSentTime": messageSentTime,
    "messageTextContent": messageTextContent,
    "messageType": messageType,
    "senderNickName": senderNickName,
    "senderUserName": senderUserName,
    "locationChatMessage": locationChatMessage ?? locationChatMessage?.toJson(),
    "contactChatMessage": contactChatMessage ?? contactChatMessage?.toJson(),
    "mediaChatMessage": mediaChatMessage ?? mediaChatMessage?.toJson(),
  };
}
