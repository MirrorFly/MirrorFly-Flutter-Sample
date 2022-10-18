// To parse this JSON data, do
//
//     final userList = userListFromJson(jsonString);

import 'dart:convert';

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
    status: json["status"] == null ? null : json["status"],
  );

  Map<String, dynamic> toJson() => {
    "data": data == null ? null : List<dynamic>.from(data!.map((x) => x.toJson())),
    "status": status == null ? null : status,
  };
}

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
  });

  String? contactType;
  String? email;
  String? groupCreatedTime;
  String? image;
  String? imagePrivacyFlag;
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
  String? lastSeenPrivacyFlag;
  String? mobileNUmberPrivacyFlag;
  String? mobileNumber;
  String? name;
  String? nickName;
  String? status;

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    contactType: json["contactType"] == null ? null : json["contactType"],
    email: json["email"] == null ? null : json["email"],
    groupCreatedTime: json["groupCreatedTime"] == null ? null : json["groupCreatedTime"],
    image: json["image"] == null ? null : json["image"],
    imagePrivacyFlag: json["imagePrivacyFlag"] == null ? null : json["imagePrivacyFlag"],
    isAdminBlocked: json["isAdminBlocked"] == null ? null : json["isAdminBlocked"],
    isBlocked: json["isBlocked"] == null ? null : json["isBlocked"],
    isBlockedMe: json["isBlockedMe"] == null ? null : json["isBlockedMe"],
    isGroupAdmin: json["isGroupAdmin"] == null ? null : json["isGroupAdmin"],
    isGroupInOfflineMode: json["isGroupInOfflineMode"] == null ? null : json["isGroupInOfflineMode"],
    isGroupProfile: json["isGroupProfile"] == null ? null : json["isGroupProfile"],
    isItSavedContact: json["isItSavedContact"] == null ? null : json["isItSavedContact"],
    isMuted: json["isMuted"] == null ? null : json["isMuted"],
    isSelected: json["isSelected"] == null ? null : json["isSelected"],
    jid: json["jid"] == null ? null : json["jid"],
    lastSeenPrivacyFlag: json["lastSeenPrivacyFlag"] == null ? null : json["lastSeenPrivacyFlag"],
    mobileNUmberPrivacyFlag: json["mobileNUmberPrivacyFlag"] == null ? null : json["mobileNUmberPrivacyFlag"],
    mobileNumber: json["mobileNumber"] == null ? null : json["mobileNumber"],
    name: json["name"] == null ? null : json["name"],
    nickName: json["nickName"] == null ? null : json["nickName"],
    status: json["status"] == null ? null : json["status"],
  );

  Map<String, dynamic> toJson() => {
    "contactType": contactType == null ? null : contactType,
    "email": email == null ? null : email,
    "groupCreatedTime": groupCreatedTime == null ? null : groupCreatedTime,
    "image": image == null ? null : image,
    "imagePrivacyFlag": imagePrivacyFlag == null ? null : imagePrivacyFlag,
    "isAdminBlocked": isAdminBlocked == null ? null : isAdminBlocked,
    "isBlocked": isBlocked == null ? null : isBlocked,
    "isBlockedMe": isBlockedMe == null ? null : isBlockedMe,
    "isGroupAdmin": isGroupAdmin == null ? null : isGroupAdmin,
    "isGroupInOfflineMode": isGroupInOfflineMode == null ? null : isGroupInOfflineMode,
    "isGroupProfile": isGroupProfile == null ? null : isGroupProfile,
    "isItSavedContact": isItSavedContact == null ? null : isItSavedContact,
    "isMuted": isMuted == null ? null : isMuted,
    "isSelected": isSelected == null ? null : isSelected,
    "jid": jid == null ? null : jid,
    "lastSeenPrivacyFlag": lastSeenPrivacyFlag == null ? null : lastSeenPrivacyFlag,
    "mobileNUmberPrivacyFlag": mobileNUmberPrivacyFlag == null ? null : mobileNUmberPrivacyFlag,
    "mobileNumber": mobileNumber == null ? null : mobileNumber,
    "name": name == null ? null : name,
    "nickName": nickName == null ? null : nickName,
    "status": status == null ? null : status,
  };
}
