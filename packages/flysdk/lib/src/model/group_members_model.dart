// To parse this JSON data, do
//
//     final member = memberFromJson(jsonString);

import 'dart:convert';
List<Member> memberFromJson(String str) => List<Member>.from(json.decode(str).map((x) => Member.fromJson(x)));

String memberToJson(List<Member> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Member {
  Member({
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

  factory Member.fromJson(Map<String, dynamic> json) => Member(
    contactType: json["contactType"],
    email: json["email"],
    groupCreatedTime: json["groupCreatedTime"].toString(),
    image: json["image"],
    imagePrivacyFlag: json["imagePrivacyFlag"],
    isAdminBlocked: json["isAdminBlocked"],
    isBlocked: json["isBlocked"],
    isBlockedMe: json["isBlockedMe"],
    isGroupAdmin: json["isGroupAdmin"],
    isGroupInOfflineMode: json["isGroupInOfflineMode"],
    isGroupProfile: json["isGroupProfile"],
    isItSavedContact: json["isItSavedContact"],
    isMuted: json["isMuted"],
    isSelected: json["isSelected"],
    jid: json["jid"],
    lastSeenPrivacyFlag: json["lastSeenPrivacyFlag"],
    mobileNUmberPrivacyFlag: json["mobileNUmberPrivacyFlag"],
    mobileNumber: json["mobileNumber"],
    name: json["name"],
    nickName: json["nickName"],
    status: json["status"],
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
  };
}
