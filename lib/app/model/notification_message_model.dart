// To parse this JSON data, do
//
//     final notificationModel = notificationModelFromJson(jsonString);

import 'dart:convert';
import 'dart:io';

import 'package:mirror_fly_demo/app/data/helper.dart';

NotificationMessageModel notificationModelFromJson(String str) =>
    NotificationMessageModel.fromJson(json.decode(str));

ChatMessage chatMessageFromJson(String str) =>
    ChatMessage.fromJson(json.decode(str));

String notificationModelToJson(NotificationMessageModel data) =>
    json.encode(data.toJson());

class NotificationMessageModel {
  ChatMessage? chatMessage;

  NotificationMessageModel({
    this.chatMessage,
  });

  factory NotificationMessageModel.fromJson(Map<String, dynamic> json) =>
      NotificationMessageModel(
        chatMessage: json["chatMessage"] == null
            ? null
            : ChatMessage.fromJson(json["chatMessage"]),
      );

  Map<String, dynamic> toJson() => {
        "chatMessage": chatMessage?.toJson(),
      };
}

class MessageCustomField {
  MessageCustomField();

  factory MessageCustomField.fromJson(Map<String, dynamic> json) =>
      MessageCustomField();

  Map<String, dynamic> toJson() => {};
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
    this.isThisAReplyMessage,
    this.isSelected,
    this.mentionedUsersIds,
    this.messageChatType,
    this.messageCustomField,
    this.messageId,
    this.messageSentTime,
    this.messageStatus,
    this.messageTextContent,
    this.messageType,
    this.replyParentChatMessage, //
    this.senderNickName,
    this.senderUserJid,
    this.senderUserName,
    this.contactChatMessage, //
    this.mediaChatMessage, //
    this.locationChatMessage, //
    this.topicId, //
  });

  String? chatUserJid;
  String? contactType;
  bool? isItCarbonMessage;
  bool? isItSavedContact;
  bool? isMessageDeleted;
  bool? isMessageRecalled;
  bool? isMessageSentByMe;
  bool? isMessageStarred;
  bool? isThisAReplyMessage;
  bool? isSelected;
  List<dynamic>? mentionedUsersIds;
  String? messageChatType;
  Map<String, dynamic>? messageCustomField;
  String? messageId;
  dynamic messageSentTime;
  String? messageStatus;
  String? messageTextContent;
  String? messageType;
  ReplyParentChatMessage? replyParentChatMessage;
  String? senderNickName;
  String? senderUserJid;
  String? senderUserName;
  ContactChatMessage? contactChatMessage;
  MediaChatMessage? mediaChatMessage;
  LocationChatMessage? locationChatMessage;
  String? topicId;

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        chatUserJid: json["chatUserJid"] ?? "",
        contactType: json["contactType"] == "unknown"
            ? "unknown_contact"
            : json["contactType"] == "live"
                ? "live_contact"
                : json["contactType"] == "local"
                    ? "local_contact"
                    : json["contactType"] == "deleted"
                        ? "deleted_contact"
                        : json["contactType"] ?? "",
        isItCarbonMessage: Platform.isAndroid
            ? json["isItCarbonMessage"] ?? false
            : json["isCarbonMessage"] ?? false,
        isItSavedContact: Platform.isAndroid
            ? json["isItSavedContact"] ?? false
            : json["isSavedContact"] ?? false,
        isMessageDeleted: json["isMessageDeleted"],
        isMessageRecalled: json["isMessageRecalled"].toString().toBool(),
        isMessageSentByMe: json["isMessageSentByMe"],
        isMessageStarred: json["isMessageStarred"].toString().toBool(),
        isThisAReplyMessage: Platform.isAndroid
            ? json["isThisAReplyMessage"]
            : json["isReplyMessage"],
        isSelected: json["isSelected"],
        mentionedUsersIds: json["mentionedUsersIds"] == null
            ? []
            : List<dynamic>.from(json["mentionedUsersIds"]!.map((x) => x)),
        messageChatType: json["messageChatType"] == "singleChat"
            ? "chat"
            : json["messageChatType"].toLowerCase(),
        messageCustomField: json["messageCustomField"] ?? {},
        messageId: json["messageId"],
        messageSentTime: json["messageSentTime"].toInt(),
        messageStatus: Platform.isAndroid
            ? (json["messageStatus"]["status"]).toString()
            : json["messageStatus"] == 2
                ? "A"
                : json["messageStatus"] == 3
                    ? "D"
                    : json["messageStatus"] == 4
                        ? "S"
                        : json["messageStatus"] == 5
                            ? "R"
                            : "N",
        //"N" for "sent" in iOS
        messageTextContent: json["messageTextContent"].toString(),
        messageType: json["messageType"].toString().toUpperCase() == "FILE"
            ? "DOCUMENT"
            : json["messageType"].toString().toUpperCase(),
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
        topicId: Platform.isIOS ? json["topicID"] : json["topicId"]
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
        "mentionedUsersIds": mentionedUsersIds == null
            ? []
            : List<dynamic>.from(mentionedUsersIds!.map((x) => x)),
        "messageChatType": messageChatType,
        "messageCustomField": messageCustomField,
        "messageId": messageId,
        "messageSentTime": messageSentTime,
        "messageStatus": messageStatus,
        "messageTextContent": messageTextContent,
        "messageType": messageType,
        "replyParentChatMessage":
            replyParentChatMessage ?? replyParentChatMessage?.toJson(),
        "senderNickName": senderNickName,
        "senderUserJid": senderUserJid,
        "senderUserName": senderUserName,
        "contactChatMessage":
            contactChatMessage == null ? null : contactChatMessage!.toJson(),
        "mediaChatMessage":
            mediaChatMessage == null ? null : mediaChatMessage!.toJson(),
        "locationChatMessage":
            locationChatMessage == null ? null : locationChatMessage!.toJson(),
        "topicId": topicId
      };
}

class ContactChatMessage {
  ContactChatMessage({
    this.contactName,
    this.contactPhoneNumbers,
    this.isChatAppUser,
    this.messageId,
  });

  String? contactName;
  List<String>? contactPhoneNumbers;
  List<bool>? isChatAppUser;
  String? messageId;

  factory ContactChatMessage.fromJson(Map<String, dynamic> json) =>
      ContactChatMessage(
        contactName: json["contactName"],
        contactPhoneNumbers:
            List<String>.from(json["contactPhoneNumbers"].map((x) => x)),
        isChatAppUser: Platform.isAndroid
            ? List<bool>.from(json["isChatAppUser"].map((x) => x))
            : List<bool>.from(json["isChatUser"].map((x) => x)),
        messageId: json["messageId"],
      );

  Map<String, dynamic> toJson() => {
        "contactName": contactName,
        "contactPhoneNumbers": contactPhoneNumbers == null
            ? null
            : List<dynamic>.from(contactPhoneNumbers!.map((x) => x)),
        "isChatAppUser": isChatAppUser == null
            ? null
            : List<dynamic>.from(isChatAppUser!.map((x) => x)),
        "messageId": messageId,
      };
}

class LocationChatMessage {
  LocationChatMessage({
    this.latitude,
    this.longitude,
    this.mapLocationUrl,
    this.messageId,
  });

  double? latitude;
  double? longitude;
  String? mapLocationUrl;
  String? messageId;

  factory LocationChatMessage.fromJson(Map<String, dynamic> json) =>
      LocationChatMessage(
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
    this.isAudioRecorded,
    this.mediaCaptionText,
    this.mediaDownloadStatus,
    this.mediaDuration,
    this.mediaFileHeight,
    this.mediaFileName,
    this.mediaFileSize,
    this.mediaFileType,
    this.mediaFileWidth,
    this.mediaLocalStoragePath,
    this.mediaProgressStatus,
    this.mediaThumbImage,
    this.mediaUploadStatus,
    this.messageId,
    this.messageType,
    this.isPlaying,
    this.currentPos,
  });

  bool? isAudioRecorded;
  String? mediaCaptionText;
  int? mediaDownloadStatus;
  int? mediaDuration;
  int? mediaFileHeight;
  String? mediaFileName;
  int? mediaFileSize;
  String? mediaFileType;
  int? mediaFileWidth;
  String? mediaLocalStoragePath;
  int? mediaProgressStatus;
  String? mediaThumbImage;
  int? mediaUploadStatus;
  String? messageId;
  String? messageType;
  bool? isPlaying;
  int? currentPos;

  factory MediaChatMessage.fromJson(Map<String, dynamic> json) =>
      MediaChatMessage(
        isAudioRecorded: Platform.isAndroid
            ? json["isAudioRecorded"] ?? false
            : json["audioType"] == "recording"
                ? true
                : false,
        mediaCaptionText: json["mediaCaptionText"] ?? "",
        mediaDownloadStatus: Platform.isIOS
            ? json["mediaDownloadStatus"] == 4
                ? 5
                : json["mediaDownloadStatus"] == 5
                    ? 3
                    : json["mediaDownloadStatus"] == 6
                        ? 4
                        : json["mediaDownloadStatus"] == 7
                            ? 6
                            : json["mediaDownloadStatus"] == 9
                                ? 401
                                : json["mediaDownloadStatus"]
            : json["mediaDownloadStatus"] == "not_downloaded"
                ? 5
                : json["mediaDownloadStatus"] == "downloading"
                    ? 3
                    : json["mediaDownloadStatus"] == "downloaded"
                        ? 4
                        : json["mediaDownloadStatus"] == "not_available"
                            ? 6
                            : json["mediaDownloadStatus"] == "failed"
                                ? 401
                                : json["mediaDownloadStatus"],
        mediaDuration: json["mediaDuration"],
        mediaFileHeight: json["mediaFileHeight"] ?? 0,
        mediaFileName: json["mediaFileName"],
        mediaFileSize: json["mediaFileSize"],
        // mediaFileType: json["mediaFileType"],
        mediaFileType: Platform.isAndroid
            ? json["mediaFileType"]
            : json["mediaFileType"].toString().toUpperCase() == "FILE"
                ? "DOCUMENT"
                : json["mediaFileType"].toString().toUpperCase(),
        mediaFileWidth: json["mediaFileWidth"] ?? 0,
        mediaLocalStoragePath: json["mediaLocalStoragePath"],
        mediaProgressStatus: json["mediaProgressStatus"] == null
            ? null
            : int.parse(json["mediaProgressStatus"].toString()),
        mediaThumbImage: json["mediaThumbImage"]
            .toString()
            .replaceAll("\\\\n", "\\n")
            .replaceAll("\\n", "\n")
            .replaceAll("\n", "")
            .replaceAll(" ", ""),
        mediaUploadStatus: Platform.isIOS
            ? json["mediaUploadStatus"] == 3
                ? 7
                : json["mediaUploadStatus"] == 8
                    ? 401
                    : json["mediaUploadStatus"]
            : json["mediaUploadStatus"] == "not_uploaded"
                ? 0
                : json["mediaUploadStatus"] == "uploading"
                    ? 1
                    : json["mediaUploadStatus"] == "uploaded"
                        ? 2
                        : json["mediaUploadStatus"] == "not_available"
                            ? 7
                            : json["mediaUploadStatus"] == "failed"
                                ? 401
                                : json["mediaUploadStatus"],
        messageId: json["messageId"],
        messageType: Platform.isAndroid
            ? json["messageType"]
            : json["mediaFileType"].toString().toUpperCase() == "FILE"
                ? "DOCUMENT"
                : json["mediaFileType"],
        isPlaying: false,
        currentPos: 0,
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

class ReplyParentChatMessage {
  ReplyParentChatMessage({
    this.chatUserJid,
    this.isMessageDeleted,
    this.isMessageRecalled,
    this.isMessageSentByMe,
    this.isMessageStarred,
    this.messageId,
    this.messageSentTime,
    this.messageTextContent,
    this.messageType,
    this.senderNickName,
    this.senderUserName,
    this.locationChatMessage,
    this.contactChatMessage,
    this.mediaChatMessage,
  });

  String? chatUserJid;
  bool? isMessageDeleted;
  bool? isMessageRecalled;
  bool? isMessageSentByMe;
  bool? isMessageStarred;
  String? messageId;
  dynamic messageSentTime;
  String? messageTextContent;
  String? messageType;
  String? senderNickName;
  String? senderUserName;
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
        messageType: Platform.isAndroid
            ? json["messageType"]
            : json["messageTextContent"].toString().isNotEmpty
                ? "TEXT"
                : json["mediaChatMessage"] != null &&
                        json["mediaChatMessage"]["mediaFileType"]
                            .toString()
                            .isNotEmpty
                    ? json["mediaChatMessage"]["mediaFileType"]
                                .toString()
                                .toUpperCase() ==
                            "FILE"
                        ? "DOCUMENT"
                        : json["mediaChatMessage"]["mediaFileType"]
                            .toString()
                            .toUpperCase()
                    : json["contactChatMessage"] != null
                        ? "CONTACT"
                        : json["locationChatMessage"] != null
                            ? "LOCATION"
                            : null,
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
        "locationChatMessage":
            locationChatMessage ?? locationChatMessage?.toJson(),
        "contactChatMessage":
            contactChatMessage ?? contactChatMessage?.toJson(),
        "mediaChatMessage": mediaChatMessage ?? mediaChatMessage?.toJson(),
      };
}
