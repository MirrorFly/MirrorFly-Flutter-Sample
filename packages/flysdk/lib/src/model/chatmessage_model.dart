// To parse this JSON data, do
//
//     final chatMessage = chatMessageFromJson(jsonString);

import 'dart:convert';

List<ChatMessage> chatMessageFromJson(String str) => List<ChatMessage>.from(json.decode(str).map((x) => ChatMessage.fromJson(x)));

ChatMessage chatMessageFrmJson(String str) => ChatMessage.fromJson(json.decode(str));

String chatMessageToJson(List<ChatMessage> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ChatMessage {
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
    this.messageChatType,
    this.messageCustomField,
    this.messageId,
    this.messageSentTime,
    this.messageStatus,
    this.messageTextContent,
    this.messageType,
    this.senderNickName,
    this.senderUserJid,
    this.senderUserName,
  });

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
  String? messageChatType;
  MessageCustomField? messageCustomField;
  String? messageId;
  int? messageSentTime;
  MessageStatus? messageStatus;
  String? messageTextContent;
  String? messageType;
  String? senderNickName;
  String? senderUserJid;
  String? senderUserName;

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
    messageChatType: json["messageChatType"],
    messageCustomField: json["messageCustomField"] == null ? null : MessageCustomField.fromJson(json["messageCustomField"]),
    messageId: json["messageId"],
    messageSentTime: json["messageSentTime"],
    messageStatus: json["messageStatus"] == null ? null : MessageStatus.fromJson(json["messageStatus"]),
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
    "messageChatType": messageChatType,
    "messageCustomField": messageCustomField == null ? null : messageCustomField!.toJson(),
    "messageId": messageId,
    "messageSentTime": messageSentTime,
    "messageStatus": messageStatus == null ? null : messageStatus!.toJson(),
    "messageTextContent": messageTextContent,
    "messageType": messageType,
    "senderNickName": senderNickName,
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
  MessageStatus({
    this.status,
  });

  String? status;

  factory MessageStatus.fromJson(Map<String, dynamic> json) => MessageStatus(
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
  };
}
