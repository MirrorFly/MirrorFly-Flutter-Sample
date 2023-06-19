// To parse this JSON data, do
//
//     final callUserList = callUserListFromJson(jsonString);

import 'dart:convert';

List<CallUserList> callUserListFromJson(String str) => List<CallUserList>.from(json.decode(str).map((x) => CallUserList.fromJson(x)));

String callUserListToJson(List<CallUserList> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CallUserList {
  String? userJid;
  String? callStatus;

  CallUserList({
    this.userJid,
    this.callStatus,
  });

  factory CallUserList.fromJson(Map<String, dynamic> json) => CallUserList(
    userJid: json["userJid"],
    callStatus: json["callStatus"],
  );

  Map<String, dynamic> toJson() => {
    "userJid": userJid,
    "callStatus": callStatus,
  };
}
