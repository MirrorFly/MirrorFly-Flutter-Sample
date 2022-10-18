// To parse this JSON data, do
//
//     final profileData = profileDataFromJson(jsonString);

import 'dart:convert';

ProfileModel profileDataFromJson(String str) => ProfileModel.fromJson(json.decode(str));

String profileDataToJson(ProfileModel data) => json.encode(data.toJson());

class ProfileModel {
  ProfileModel({
    this.data,
    this.status,
  });

  ProfileData? data;
  bool? status;

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    data: json["data"] == null ? null : ProfileData.fromJson(json["data"]),
    status: json["status"] == null ? null : json["status"],
  );

  Map<String, dynamic> toJson() => {
    "data": data == null ? null : data?.toJson(),
    "status": status == null ? null : status,
  };
}

class ProfileData {
  ProfileData({
    this.email,
    this.image,
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
    this.mobileNumber,
    this.name,
    this.nickName,
    this.status,
  });

  String? email;
  String? image;
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
  String? mobileNumber;
  String? name;
  String? nickName;
  String? status;

  factory ProfileData.fromJson(Map<String, dynamic> json) => ProfileData(
    email: json["email"] == null ? null : json["email"],
    image: json["image"] == null ? null : json["image"],
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
    mobileNumber: json["mobileNumber"] == null ? null : json["mobileNumber"],
    name: json["name"] == null ? null : json["name"],
    nickName: json["nickName"] == null ? null : json["nickName"],
    status: json["status"] == null ? null : json["status"],
  );

  Map<String, dynamic> toJson() => {
    "email": email == null ? null : email,
    "image": image == null ? null : image,
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
    "mobileNumber": mobileNumber == null ? null : mobileNumber,
    "name": name == null ? null : name,
    "nickName": nickName == null ? null : nickName,
    "status": status == null ? null : status,
  };
}
