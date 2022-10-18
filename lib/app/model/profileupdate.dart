// To parse this JSON data, do
//
//     final profileUpdate = profileUpdateFromJson(jsonString);

import 'dart:convert';

ProfileUpdate profileUpdateFromJson(String str) => ProfileUpdate.fromJson(json.decode(str));

String profileUpdateToJson(ProfileUpdate data) => json.encode(data.toJson());

class ProfileUpdate {
  ProfileUpdate({
    this.data,
    this.message,
    this.status,
  });

  Data? data;
  String? message;
  bool? status;

  factory ProfileUpdate.fromJson(Map<String, dynamic> json) => ProfileUpdate(
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
    message: json["message"] == null ? null : json["message"],
    status: json["status"] == null ? null : json["status"],
  );

  Map<String, dynamic> toJson() => {
    "data": data == null ? null : data!.toJson(),
    "message": message == null ? null : message,
    "status": status == null ? null : status,
  };
}

class Data {
  Data({
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

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    email: json["email"] == null ? null : json["email"],
    image: json["image"] == null ? null : json["image"],
    mobileNumber: json["mobileNumber"] == null ? null : json["mobileNumber"],
    name: json["name"] == null ? null : json["name"],
    nickName: json["nickName"] == null ? null : json["nickName"],
    status: json["status"] == null ? null : json["status"],
  );

  Map<String, dynamic> toJson() => {
    "email": email == null ? null : email,
    "image": image == null ? null : image,
    "mobileNumber": mobileNumber == null ? null : mobileNumber,
    "name": name == null ? null : name,
    "nickName": nickName == null ? null : nickName,
    "status": status == null ? null : status,
  };
}
