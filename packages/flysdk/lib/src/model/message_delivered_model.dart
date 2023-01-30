// To parse this JSON data, do
//
//     final messageDelivered = messageDeliveredFromJson(jsonString);

import 'dart:convert';

import 'package:flysdk/flysdk.dart';

List<MessageDeliveredStatus> messageDeliveredStatusFromJson(String str) => List<MessageDeliveredStatus>.from(json.decode(str).map((x) => MessageDeliveredStatus.fromJson(x)));

String messageDeliveredStatusToJson(List<MessageDeliveredStatus> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class MessageDeliveredStatus {
  MessageDeliveredStatus({
    this.memberProfileDetails,
    this.messageId,
    this.status,
    this.time,
    this.userJid,
  });

  Member? memberProfileDetails;
  String? messageId;
  Status? status;
  String? time;
  String? userJid;

  factory MessageDeliveredStatus.fromJson(Map<String, dynamic> json) => MessageDeliveredStatus(
    memberProfileDetails: json["memberProfileDetails"] == null ? null : Member.fromJson(json["memberProfileDetails"]),
    messageId: json["messageId"] == null ? null : json["messageId"],
    status: json["status"] == null ? null : Status.fromJson(json["status"]),
    time: json["time"] == null ? null : json["time"],
    userJid: json["userJid"] == null ? null : json["userJid"],
  );

  Map<String, dynamic> toJson() => {
    "memberProfileDetails": memberProfileDetails == null ? null : memberProfileDetails?.toJson(),
    "messageId": messageId == null ? null : messageId,
    "status": status == null ? null : status?.toJson(),
    "time": time == null ? null : time,
    "userJid": userJid == null ? null : userJid,
  };
}

class Status {
  Status({
    required this.status,
  });

  String status;

  factory Status.fromJson(Map<String, dynamic> json) => Status(
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
  };
}
