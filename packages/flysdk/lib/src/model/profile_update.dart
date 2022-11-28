

import 'dart:convert';

ProfileUpdate profileUpdateFromJson(String str) => ProfileUpdate.fromJson(json.decode(str));

String profileUpdateToJson(ProfileUpdate data) => json.encode(data.toJson());

class ProfileUpdate {
  ProfileUpdate({
    this.data,
    this.message,
    this.status,
  });

  ProData? data;
  String? message;
  bool? status;

  factory ProfileUpdate.fromJson(Map<String, dynamic> json) => ProfileUpdate(
    data: json["data"] == null ? null : ProData.fromJson(json["data"]),
    message: json["message"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "data": data == null ? null : data!.toJson(),
    "message": message,
    "status": status,
  };
}

class ProData {
  ProData({
    this.email,
    this.image,
    this.mobileNumber,
    this.name,
    this.nickName,
    this.status,
  });

  String? email;
  String? image;
  String? mobileNumber;
  String? name;
  String? nickName;
  String? status;

  factory ProData.fromJson(Map<String, dynamic> json) => ProData(
    email: json["email"],
    image: json["image"],
    mobileNumber: json["mobileNumber"],
    name: json["name"],
    nickName: json["nickName"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "email": email,
    "image": image,
    "mobileNumber": mobileNumber,
    "name": name,
    "nickName": nickName,
    "status": status,
  };
}
