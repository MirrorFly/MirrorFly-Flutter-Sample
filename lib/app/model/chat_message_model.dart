// To parse this JSON data, do
//
//     final chatMessageModel = chatMessageModelFromJson(jsonString);

import 'dart:convert';

import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import '../extensions/extensions.dart';
import 'package:mirrorfly_plugin/message_params.dart' show MessageMetaData;

List<ChatMessageModel> chatMessageModelFromJson(String str) =>
    List<ChatMessageModel>.from(
        json.decode(str).map((x) => ChatMessageModel.fromJson(x)));

String chatMessageModelToJson(List<ChatMessageModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

ChatMessageModel sendMessageModelFromJson(String str) =>
    ChatMessageModel.fromJson(json.decode(str));

String sendMessageModelToJson(ChatMessageModel data) =>
    json.encode(data.toJson());

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
    required this.isMessageEdited,
    required this.messageTextContent,
    required this.messageType,
    this.metaData = const [],
    required this.replyParentChatMessage,
    required this.senderNickName,
    required this.senderUserJid,
    required this.senderUserName,
    required this.contactChatMessage, //
    required this.mediaChatMessage, //
    required this.locationChatMessage, //
    required this.topicId, //
  });

  String chatUserJid;
  String contactType;
  bool isItCarbonMessage;
  bool isItSavedContact;
  bool isMessageDeleted;
  RxBool isMessageRecalled;
  bool isMessageSentByMe;
  RxBool isMessageStarred;
  RxBool isSelected;
  bool isThisAReplyMessage;
  String messageChatType;
  MessageCustomField? messageCustomField;
  String messageId;
  int messageSentTime;
  RxString messageStatus;
  RxBool isMessageEdited;
  String? messageTextContent;
  String messageType;
  List<MessageMetaData> metaData;
  ReplyParentChatMessage? replyParentChatMessage;
  String senderNickName;
  String senderUserJid;
  String senderUserName;
  ContactChatMessage? contactChatMessage;
  MediaChatMessage? mediaChatMessage;
  LocationChatMessage? locationChatMessage;
  String topicId;

  // var isSelected = false.obs;

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      ChatMessageModel(
          chatUserJid: json["chatUserJid"],
          contactType: json["contactType"],
          isItCarbonMessage: json["isItCarbonMessage"],
          isItSavedContact: json["isItSavedContact"],
          isMessageDeleted: json["isMessageDeleted"],
          isMessageRecalled: json["isMessageRecalled"].toString().toBool().obs,
          isMessageSentByMe: json["isMessageSentByMe"],
          isMessageStarred: json["isMessageStarred"].toString().toBool().obs,
          isSelected: json["isSelected"].toString().toBool().obs,
          isThisAReplyMessage: json["isThisAReplyMessage"],
          messageChatType: json["messageChatType"],
          messageCustomField: json["messageCustomField"] == null ? null : MessageCustomField.fromJson(json["messageCustomField"]),
          messageId: json["messageId"],
          messageSentTime: json["messageSentTime"],
          messageStatus: json["messageStatus"].toString().obs,
          isMessageEdited: json["isMessageEdited"].toString().toBool().obs,
          messageTextContent: json["messageTextContent"],
          messageType: json["messageType"],
          metaData: json["metaData"] == null ? [] : List<MessageMetaData>.from(json["metaData"]!.map((x) => MessageMetaData.fromJson(x))),
          replyParentChatMessage: json["replyParentChatMessage"] == null
              ? null
              : ReplyParentChatMessage.fromJson(json["replyParentChatMessage"]),
          senderNickName: json["senderNickName"],
          senderUserJid: json["senderUserJid"],
          senderUserName: json["senderUserName"],
          contactChatMessage: json["contactChatMessage"] == null
              ? null
              : ContactChatMessage.fromJson(json["contactChatMessage"]),
          mediaChatMessage: json["mediaChatMessage"] == null
              ? null
              : MediaChatMessage.fromJson(json["mediaChatMessage"]),
          locationChatMessage: json["locationChatMessage"] == null
              ? null
              : LocationChatMessage.fromJson(json["locationChatMessage"]),
          topicId: json["topicId"]);

  Map<String, dynamic> toJson() => {
        "chatUserJid": chatUserJid,
        "contactType": contactType,
        "isItCarbonMessage": isItCarbonMessage,
        "isItSavedContact": isItSavedContact,
        "isMessageDeleted": isMessageDeleted,
        "isMessageRecalled": isMessageRecalled.value,
        "isSelected": isSelected.value,
        "isMessageSentByMe": isMessageSentByMe,
        "isMessageStarred": isMessageStarred.value,
        "isThisAReplyMessage": isThisAReplyMessage,
        "messageChatType": messageChatType,
        "messageCustomField": messageCustomField,
        "messageId": messageId,
        "messageSentTime": messageSentTime,
        "messageStatus": messageStatus.value,
        "isMessageEdited": isMessageEdited.value,
        "messageTextContent": messageTextContent,
        "messageType": messageType,
        "metaData": metaData,
        "replyParentChatMessage":
            replyParentChatMessage ?? replyParentChatMessage?.toJson(),
        "senderNickName": senderNickName,
        "senderUserJid": senderUserJid,
        "senderUserName": senderUserName,
        "contactChatMessage": contactChatMessage?.toJson(),
        "mediaChatMessage": mediaChatMessage?.toJson(),
        "locationChatMessage": locationChatMessage?.toJson(),
        "topicId": topicId
      };
}

class ContactChatMessage {
  String contactName;
  List<String> contactPhoneNumbers;
  List<bool> isChatAppUser;
  String messageId;

  ContactChatMessage({
    required this.contactName,
    required this.contactPhoneNumbers,
    required this.isChatAppUser,
    required this.messageId,
  });

  factory ContactChatMessage.fromJson(Map<String, dynamic> json) => ContactChatMessage(
    contactName: json["contactName"],
    contactPhoneNumbers: json["contactPhoneNumbers"] == null ? [] : List<String>.from(json["contactPhoneNumbers"]!.map((x) => x)),
    isChatAppUser: json["isChatAppUser"] == null ? [] : List<bool>.from(json["isChatAppUser"]!.map((x) => x)),
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
  double latitude;
  double longitude;
  String mapLocationUrl;
  String messageId;

  LocationChatMessage({
    required this.latitude,
    required this.longitude,
    required this.mapLocationUrl,
    required this.messageId,
  });

  factory LocationChatMessage.fromJson(Map<String, dynamic> json) => LocationChatMessage(
    latitude: json["latitude"]?.toDouble(),
    longitude: json["longitude"]?.toDouble(),
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
    required this.mediaFileName,
    required this.mediaFileSize,
    required this.mediaLocalStoragePath,
    required this.mediaProgressStatus,
    required this.mediaThumbImage,
    required this.mediaUploadStatus,
    required this.messageId,
    required this.messageType,
    required this.isPlaying,
    required this.currentPos,
  });
  bool isAudioRecorded;
  String mediaCaptionText;
  RxInt mediaDownloadStatus;
  int mediaDuration;
  String mediaFileName;
  int mediaFileSize;
  RxString mediaLocalStoragePath;
  RxInt mediaProgressStatus;
  String mediaThumbImage;
  RxInt mediaUploadStatus;
  String messageId;
  String messageType;
  bool isPlaying;
  int currentPos;

  factory MediaChatMessage.fromJson(Map<String, dynamic> json) =>
      MediaChatMessage(
        isAudioRecorded: json["isAudioRecorded"],
        mediaCaptionText: json["mediaCaptionText"],
        mediaDownloadStatus: int.parse(json["mediaDownloadStatus"].toString()).obs,
        mediaDuration: json["mediaDuration"],
        mediaFileName: json["mediaFileName"],
        mediaFileSize: json["mediaFileSize"],
        mediaLocalStoragePath: json["mediaLocalStoragePath"].toString().obs,
        mediaProgressStatus: int.parse(json["mediaProgressStatus"].toString()).obs,
        mediaThumbImage: json["mediaThumbImage"],
        mediaUploadStatus: int.parse(json["mediaUploadStatus"].toString()).obs,
        messageId: json["messageId"],
        messageType: json["messageType"],
        isPlaying: false,
        currentPos: 0
      );

  Map<String, dynamic> toJson() => {
        "isAudioRecorded": isAudioRecorded,
        "mediaCaptionText": mediaCaptionText,
        "mediaDownloadStatus": mediaDownloadStatus.value,
        "mediaDuration": mediaDuration,
        "mediaFileName": mediaFileName,
        "mediaFileSize": mediaFileSize,
        "mediaLocalStoragePath": mediaLocalStoragePath.value,
        "mediaProgressStatus": mediaProgressStatus.value,
        "mediaThumbImage": mediaThumbImage,
        "mediaUploadStatus": mediaUploadStatus.value,
        "messageId": messageId,
        "messageType": messageType,
      };
}

class MessageCustomField {
  MessageCustomField();

  factory MessageCustomField.fromJson(Map<String, dynamic> json) =>
      MessageCustomField();

  Map<String, dynamic> toJson() => {};
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
  int messageSentTime;
  String? messageTextContent;
  String messageType;
  String senderNickName;
  String senderUserName;
  LocationChatMessage? locationChatMessage;
  ContactChatMessage? contactChatMessage;
  MediaChatMessage? mediaChatMessage;

  factory ReplyParentChatMessage.fromJson(Map<String, dynamic> json) =>
      ReplyParentChatMessage(
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
        locationChatMessage: json["locationChatMessage"] == null
            ? null
            : LocationChatMessage.fromJson(json["locationChatMessage"]),
        contactChatMessage: json["contactChatMessage"] == null
            ? null
            : ContactChatMessage.fromJson(json["contactChatMessage"]),
        mediaChatMessage: json["mediaChatMessage"] == null
            ? null
            : MediaChatMessage.fromJson(json["mediaChatMessage"]),
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
    "locationChatMessage": locationChatMessage?.toJson(),
    "contactChatMessage": contactChatMessage?.toJson(),
    "mediaChatMessage": mediaChatMessage?.toJson(),
  };
}
