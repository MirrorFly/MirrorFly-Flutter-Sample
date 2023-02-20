// To parse this JSON data, do
//
//     final userList = userListFromJson(jsonString);

import 'dart:convert';
import 'dart:io';

UserList userListFromJson(String str) => UserList.fromJson(json.decode(str));

String userListToJson(UserList data) => json.encode(data.toJson());

class UserList {
  UserList({
    this.data,
    this.status,
  });

  List<Profile>? data;
  bool? status;

  factory UserList.fromJson(Map<String, dynamic> json) => UserList(
    data: json["data"] == null ? null : List<Profile>.from(json["data"].map((x) => Profile.fromJson(x))),
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "data": data == null ? null : List<dynamic>.from(data!.map((x) => x.toJson())),
    "status": status,
  };
}


List<Profile> profileFromJson(String str) => List<Profile>.from(json.decode(str).map((x) => Profile.fromJson(x)));
Profile profiledata(String str) => Profile.fromJson(json.decode(str.toString()));

class Profile {
  Profile({
    this.contactType,
    this.email,
    this.groupCreatedTime,
    this.image,
    this.imagePrivacyFlag,
    this.isAdminBlocked,
    this.isBlocked,
    this.isBlockedMe,
    this.isGroupAdmin,
    this.isGroupInOfflineMode,
    this.isGroupProfile,
    this.isItSavedContact,
    this.isMuted,
    this.isSelected,
    this.jid,
    this.lastSeenPrivacyFlag,
    this.mobileNUmberPrivacyFlag,
    this.mobileNumber,
    this.name,
    this.nickName,
    this.status,
    //only for iOS
    this.profileChatType
  });

  String? contactType;
  String? email;
  dynamic groupCreatedTime;
  String? image;
  dynamic imagePrivacyFlag;
  bool? isAdminBlocked;
  bool? isBlocked;
  bool? isBlockedMe;
  bool? isGroupAdmin;
  bool? isGroupInOfflineMode;
  bool? isGroupProfile;
  bool? isItSavedContact;
  bool? isMuted;
  bool? isSelected;
  String? jid;
  dynamic lastSeenPrivacyFlag;
  dynamic mobileNUmberPrivacyFlag;
  String? mobileNumber;
  String? name;
  String? nickName;
  String? status;
  dynamic profileChatType;

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    contactType: json["contactType"],
    email: json["email"],
    groupCreatedTime: json["groupCreatedTime"],
    image: json["image"],
    imagePrivacyFlag: json["imagePrivacyFlag"],
    isAdminBlocked: Platform.isAndroid ? json["isAdminBlocked"] : json["isBlockedByAdmin"],
    isBlocked: json["isBlocked"],
    isBlockedMe: json["isBlockedMe"],
    isGroupAdmin: json["isGroupAdmin"],
    isGroupInOfflineMode: json["isGroupInOfflineMode"],
    isGroupProfile: Platform.isAndroid ? json["isGroupProfile"] : json["profileChatType"] == "singleChat" ? false : true,
    isItSavedContact: json["isItSavedContact"],
    isMuted: json["isMuted"],
    isSelected: json["isSelected"],
    jid: json["jid"],
    lastSeenPrivacyFlag: json["lastSeenPrivacyFlag"],
    mobileNUmberPrivacyFlag: json["mobileNUmberPrivacyFlag"],
    mobileNumber: json["mobileNumber"],
    name: json["name"],
    nickName: json["nickName"].toString(),
    status: json["status"],
    profileChatType: json["profileChatType"],
  );

  Map<String, dynamic> toJson() => {
    "contactType": contactType,
    "email": email,
    "groupCreatedTime": groupCreatedTime,
    "image": image,
    "imagePrivacyFlag": imagePrivacyFlag,
    "isAdminBlocked": isAdminBlocked,
    "isBlocked": isBlocked,
    "isBlockedMe": isBlockedMe,
    "isGroupAdmin": isGroupAdmin,
    "isGroupInOfflineMode": isGroupInOfflineMode,
    "isGroupProfile": isGroupProfile,
    "isItSavedContact": isItSavedContact,
    "isMuted": isMuted,
    "isSelected": isSelected,
    "jid": jid,
    "lastSeenPrivacyFlag": lastSeenPrivacyFlag,
    "mobileNUmberPrivacyFlag": mobileNUmberPrivacyFlag,
    "mobileNumber": mobileNumber,
    "name": name,
    "nickName": nickName,
    "status": status,
    "profileChatType": profileChatType,
  };
}
