// To parse this JSON data, do
//
//     final chatMessageModel = chatMessageModelFromJson(jsonString);

import 'dart:convert';

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
    required this.senderNickName,
    required this.senderUserJid,
    required this.senderUserName,
    required this.mediaChatMessage,
    required this.locationChatMessage,
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
  String messageChatType;
  MessageCustomField messageCustomField;
  String messageId;
  int messageSentTime;
  MessageStatus messageStatus;
  String messageTextContent;
  String messageType;
  String senderNickName;
  String senderUserJid;
  String senderUserName;
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
    isSelected: json["isSelected"],
    isThisAReplyMessage: json["isThisAReplyMessage"],
    messageChatType: json["messageChatType"],
    messageCustomField: MessageCustomField.fromJson(json["messageCustomField"]),
    messageId: json["messageId"],
    messageSentTime: json["messageSentTime"],
    messageStatus: MessageStatus.fromJson(json["messageStatus"]),
    messageTextContent: json["messageTextContent"],
    messageType: json["messageType"],
    senderNickName: json["senderNickName"],
    senderUserJid: json["senderUserJid"],
    senderUserName: json["senderUserName"],
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
    "messageCustomField": messageCustomField.toJson(),
    "messageId": messageId,
    "messageSentTime": messageSentTime,
    "messageStatus": messageStatus.toJson(),
    "messageTextContent": messageTextContent,
    "messageType": messageType,
    "senderNickName": senderNickName,
    "senderUserJid": senderUserJid,
    "senderUserName": senderUserName,
    "mediaChatMessage": mediaChatMessage == null ? null : mediaChatMessage!.toJson(),
    "locationChatMessage": locationChatMessage == null ? null : locationChatMessage!.toJson(),
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
