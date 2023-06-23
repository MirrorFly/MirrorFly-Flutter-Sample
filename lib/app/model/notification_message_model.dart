// To parse this JSON data, do
//
//     final notificationModel = notificationModelFromJson(jsonString);

import 'dart:convert';

NotificationModel notificationModelFromJson(String str) => NotificationModel.fromJson(json.decode(str));

String notificationModelToJson(NotificationModel data) => json.encode(data.toJson());

class NotificationModel {
  String? groupJid;
  String? titleContent;
  ChatMessage? chatMessage;
  bool? cancel;

  NotificationModel({
    this.groupJid,
    this.titleContent,
    this.chatMessage,
    this.cancel,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) => NotificationModel(
    groupJid: json["groupJid"],
    titleContent: json["titleContent"],
    chatMessage: json["chatMessage"] == null ? null : ChatMessage.fromJson(json["chatMessage"]),
    cancel: json["cancel"],
  );

  Map<String, dynamic> toJson() => {
    "groupJid": groupJid,
    "titleContent": titleContent,
    "chatMessage": chatMessage?.toJson(),
    "cancel": cancel,
  };
}

class ChatMessage {
  String? chatUserJid;
  String? contactType;
  bool? isItCarbonMessage;
  bool? isItSavedContact;
  bool? isMessageDeleted;
  bool? isMessageRecalled;
  bool? isMessageSentByMe;
  bool? isMessageStarred;
  bool? isSelected;
  bool? isThisAReplyMessage;
  List<dynamic>? mentionedUsersIds;
  String? messageChatType;
  MessageCustomField? messageCustomField;
  String? messageId;
  int? messageSentTime;
  MessageStatus? messageStatus;
  String? messageTextContent;
  String? messageType;
  String? senderNickName;
  String? senderProfileImage;
  String? senderUserJid;
  String? senderUserName;

  ChatMessage({
    this.chatUserJid,
    this.contactType,
    this.isItCarbonMessage,
    this.isItSavedContact,
    this.isMessageDeleted,
    this.isMessageRecalled,
    this.isMessageSentByMe,
    this.isMessageStarred,
    this.isSelected,
    this.isThisAReplyMessage,
    this.mentionedUsersIds,
    this.messageChatType,
    this.messageCustomField,
    this.messageId,
    this.messageSentTime,
    this.messageStatus,
    this.messageTextContent,
    this.messageType,
    this.senderNickName,
    this.senderProfileImage,
    this.senderUserJid,
    this.senderUserName,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
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
    mentionedUsersIds: json["mentionedUsersIds"] == null ? [] : List<dynamic>.from(json["mentionedUsersIds"]!.map((x) => x)),
    messageChatType: json["messageChatType"],
    messageCustomField: json["messageCustomField"] == null ? null : MessageCustomField.fromJson(json["messageCustomField"]),
    messageId: json["messageId"],
    messageSentTime: json["messageSentTime"],
    messageStatus: json["messageStatus"] == null ? null : MessageStatus.fromJson(json["messageStatus"]),
    messageTextContent: json["messageTextContent"],
    messageType: json["messageType"],
    senderNickName: json["senderNickName"],
    senderProfileImage: json["senderProfileImage"],
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
    "mentionedUsersIds": mentionedUsersIds == null ? [] : List<dynamic>.from(mentionedUsersIds!.map((x) => x)),
    "messageChatType": messageChatType,
    "messageCustomField": messageCustomField?.toJson(),
    "messageId": messageId,
    "messageSentTime": messageSentTime,
    "messageStatus": messageStatus?.toJson(),
    "messageTextContent": messageTextContent,
    "messageType": messageType,
    "senderNickName": senderNickName,
    "senderProfileImage": senderProfileImage,
    "senderUserJid": senderUserJid,
    "senderUserName": senderUserName,
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
  String? status;

  MessageStatus({
    this.status,
  });

  factory MessageStatus.fromJson(Map<String, dynamic> json) => MessageStatus(
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
  };
}
