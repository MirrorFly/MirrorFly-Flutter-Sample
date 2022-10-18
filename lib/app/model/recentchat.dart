// To parse this JSON data, do
//
//     final recentChat = recentChatFromJson(jsonString);

import 'dart:convert';

RecentChat recentChatFromJson(String str) => RecentChat.fromJson(json.decode(str));

String recentChatToJson(RecentChat data) => json.encode(data.toJson());

class RecentChat {
  RecentChat({
    this.data,
  });

  List<RecentChatData>? data;

  factory RecentChat.fromJson(Map<String, dynamic> json) => RecentChat(
    data: json["data"] == null ? null : List<RecentChatData>.from(json["data"].map((x) => RecentChatData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "data": data == null ? null : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class RecentChatData {
  RecentChatData({
    this.contactType,
    this.isAdminBlocked,
    this.isBlocked,
    this.isBlockedMe,
    this.isBroadCast,
    this.isChatArchived,
    this.isChatPinned,
    this.isConversationUnRead,
    this.isGroup,
    this.isGroupInOfflineMode,
    this.isItSavedContact,
    this.isLastMessageRecalledByUser,
    this.isLastMessageSentByMe,
    this.isMuted,
    this.isSelected,
    this.jid,
    this.lastMessageContent,
    this.lastMessageId,
    this.lastMessageStatus,
    this.lastMessageTime,
    this.lastMessageType,
    this.nickName,
    this.profileImage,
    this.profileName,
    this.unreadMessageCount,
  });

  String? contactType;
  bool? isAdminBlocked;
  bool? isBlocked;
  bool? isBlockedMe;
  bool? isBroadCast;
  bool? isChatArchived;
  bool? isChatPinned;
  bool? isConversationUnRead;
  bool? isGroup;
  bool? isGroupInOfflineMode;
  bool? isItSavedContact;
  bool? isLastMessageRecalledByUser;
  bool? isLastMessageSentByMe;
  bool? isMuted;
  bool? isSelected;
  String? jid;
  String? lastMessageContent;
  String? lastMessageId;
  String? lastMessageStatus;
  int? lastMessageTime;
  String? lastMessageType;
  String? nickName;
  String? profileImage;
  String? profileName;
  int? unreadMessageCount;

  factory RecentChatData.fromJson(Map<String, dynamic> json) => RecentChatData(
    contactType: json["contactType"] == null ? null : json["contactType"],
    isAdminBlocked: json["isAdminBlocked"] == null ? null : json["isAdminBlocked"],
    isBlocked: json["isBlocked"] == null ? null : json["isBlocked"],
    isBlockedMe: json["isBlockedMe"] == null ? null : json["isBlockedMe"],
    isBroadCast: json["isBroadCast"] == null ? null : json["isBroadCast"],
    isChatArchived: json["isChatArchived"] == null ? null : json["isChatArchived"],
    isChatPinned: json["isChatPinned"] == null ? null : json["isChatPinned"],
    isConversationUnRead: json["isConversationUnRead"] == null ? null : json["isConversationUnRead"],
    isGroup: json["isGroup"] == null ? null : json["isGroup"],
    isGroupInOfflineMode: json["isGroupInOfflineMode"] == null ? null : json["isGroupInOfflineMode"],
    isItSavedContact: json["isItSavedContact"] == null ? null : json["isItSavedContact"],
    isLastMessageRecalledByUser: json["isLastMessageRecalledByUser"] == null ? null : json["isLastMessageRecalledByUser"],
    isLastMessageSentByMe: json["isLastMessageSentByMe"] == null ? null : json["isLastMessageSentByMe"],
    isMuted: json["isMuted"] == null ? null : json["isMuted"],
    isSelected: json["isSelected"] == null ? null : json["isSelected"],
    jid: json["jid"] == null ? null : json["jid"],
    lastMessageContent: json["lastMessageContent"] == null ? null : json["lastMessageContent"],
    lastMessageId: json["lastMessageId"] == null ? null : json["lastMessageId"],
    lastMessageStatus: json["lastMessageStatus"] == null ? null : json["lastMessageStatus"],
    lastMessageTime: json["lastMessageTime"] == null ? null : json["lastMessageTime"],
    lastMessageType: json["lastMessageType"] == null ? null : json["lastMessageType"],
    nickName: json["nickName"] == null ? null : json["nickName"],
    profileImage: json["profileImage"] == null ? null : json["profileImage"],
    profileName: json["profileName"] == null ? null : json["profileName"],
    unreadMessageCount: json["unreadMessageCount"] == null ? null : json["unreadMessageCount"],
  );

  Map<String, dynamic> toJson() => {
    "contactType": contactType == null ? null : contactType,
    "isAdminBlocked": isAdminBlocked == null ? null : isAdminBlocked,
    "isBlocked": isBlocked == null ? null : isBlocked,
    "isBlockedMe": isBlockedMe == null ? null : isBlockedMe,
    "isBroadCast": isBroadCast == null ? null : isBroadCast,
    "isChatArchived": isChatArchived == null ? null : isChatArchived,
    "isChatPinned": isChatPinned == null ? null : isChatPinned,
    "isConversationUnRead": isConversationUnRead == null ? null : isConversationUnRead,
    "isGroup": isGroup == null ? null : isGroup,
    "isGroupInOfflineMode": isGroupInOfflineMode == null ? null : isGroupInOfflineMode,
    "isItSavedContact": isItSavedContact == null ? null : isItSavedContact,
    "isLastMessageRecalledByUser": isLastMessageRecalledByUser == null ? null : isLastMessageRecalledByUser,
    "isLastMessageSentByMe": isLastMessageSentByMe == null ? null : isLastMessageSentByMe,
    "isMuted": isMuted == null ? null : isMuted,
    "isSelected": isSelected == null ? null : isSelected,
    "jid": jid == null ? null : jid,
    "lastMessageContent": lastMessageContent == null ? null : lastMessageContent,
    "lastMessageId": lastMessageId == null ? null : lastMessageId,
    "lastMessageStatus": lastMessageStatus == null ? null : lastMessageStatus,
    "lastMessageTime": lastMessageTime == null ? null : lastMessageTime,
    "lastMessageType": lastMessageType == null ? null : lastMessageType,
    "nickName": nickName == null ? null : nickName,
    "profileImage": profileImage == null ? null : profileImage,
    "profileName": profileName == null ? null : profileName,
    "unreadMessageCount": unreadMessageCount == null ? null : unreadMessageCount,
  };
}
