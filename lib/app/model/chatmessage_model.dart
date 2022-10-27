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
    chatUserJid: json["chatUserJid"] == null ? null : json["chatUserJid"],
    contactType: json["contactType"] == null ? null : json["contactType"],
    isItCarbonMessage: json["isItCarbonMessage"] == null ? null : json["isItCarbonMessage"],
    isItSavedContact: json["isItSavedContact"] == null ? null : json["isItSavedContact"],
    isMessageDeleted: json["isMessageDeleted"] == null ? null : json["isMessageDeleted"],
    isMessageRecalled: json["isMessageRecalled"] == null ? null : json["isMessageRecalled"],
    isMessageSentByMe: json["isMessageSentByMe"] == null ? null : json["isMessageSentByMe"],
    isMessageStarred: json["isMessageStarred"] == null ? null : json["isMessageStarred"],
    isSelected: json["isSelected"] == null ? null : json["isSelected"],
    isThisAReplyMessage: json["isThisAReplyMessage"] == null ? null : json["isThisAReplyMessage"],
    messageChatType: json["messageChatType"] == null ? null : json["messageChatType"],
    messageCustomField: json["messageCustomField"] == null ? null : MessageCustomField.fromJson(json["messageCustomField"]),
    messageId: json["messageId"] == null ? null : json["messageId"],
    messageSentTime: json["messageSentTime"] == null ? null : json["messageSentTime"],
    messageStatus: json["messageStatus"] == null ? null : MessageStatus.fromJson(json["messageStatus"]),
    messageTextContent: json["messageTextContent"] == null ? null : json["messageTextContent"],
    messageType: json["messageType"] == null ? null : json["messageType"],
    senderNickName: json["senderNickName"] == null ? null : json["senderNickName"],
    senderUserJid: json["senderUserJid"] == null ? null : json["senderUserJid"],
    senderUserName: json["senderUserName"] == null ? null : json["senderUserName"],
  );

  Map<String, dynamic> toJson() => {
    "chatUserJid": chatUserJid == null ? null : chatUserJid,
    "contactType": contactType == null ? null : contactType,
    "isItCarbonMessage": isItCarbonMessage == null ? null : isItCarbonMessage,
    "isItSavedContact": isItSavedContact == null ? null : isItSavedContact,
    "isMessageDeleted": isMessageDeleted == null ? null : isMessageDeleted,
    "isMessageRecalled": isMessageRecalled == null ? null : isMessageRecalled,
    "isMessageSentByMe": isMessageSentByMe == null ? null : isMessageSentByMe,
    "isMessageStarred": isMessageStarred == null ? null : isMessageStarred,
    "isSelected": isSelected == null ? null : isSelected,
    "isThisAReplyMessage": isThisAReplyMessage == null ? null : isThisAReplyMessage,
    "messageChatType": messageChatType == null ? null : messageChatType,
    "messageCustomField": messageCustomField == null ? null : messageCustomField!.toJson(),
    "messageId": messageId == null ? null : messageId,
    "messageSentTime": messageSentTime == null ? null : messageSentTime,
    "messageStatus": messageStatus == null ? null : messageStatus!.toJson(),
    "messageTextContent": messageTextContent == null ? null : messageTextContent,
    "messageType": messageType == null ? null : messageType,
    "senderNickName": senderNickName == null ? null : senderNickName,
    "senderUserJid": senderUserJid == null ? null : senderUserJid,
    "senderUserName": senderUserName == null ? null : senderUserName,
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
    status: json["status"] == null ? null : json["status"],
  );

  Map<String, dynamic> toJson() => {
    "status": status == null ? null : status,
  };
}
