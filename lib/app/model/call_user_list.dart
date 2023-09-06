// To parse this JSON data, do
//
//     final callUserList = callUserListFromJson(jsonString);

import 'dart:convert';

import 'package:get/get.dart';

List<CallUserList> callUserListFromJson(String str) => List<CallUserList>.from(json.decode(str).map((x) => CallUserList.fromJson(x)));

String callUserListToJson(List<CallUserList> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CallUserList {
  String? userJid;
  String? callStatus;
  RxBool isAudioMuted = RxBool(false);

  CallUserList({
    this.userJid,
    this.callStatus,
    required bool isAudioMuted,
  }) : isAudioMuted = RxBool(isAudioMuted);

  factory CallUserList.fromJson(Map<String, dynamic> json) => CallUserList(
    userJid: json["userJid"],
    callStatus: json["callStatus"],
    isAudioMuted: json["isAudioMuted"] ?? false,
  );

  Map<String, dynamic> toJson() => {
    "userJid": userJid,
    "callStatus": callStatus,
    "isAudioMuted": isAudioMuted.value,
  };
}
