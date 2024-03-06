// To parse this JSON data, do
//
//     final callUserList = callUserListFromJson(jsonString);

import 'dart:convert';

import 'package:get/get.dart';

List<CallUserList> callUserListFromJson(String str) => List<CallUserList>.from(json.decode(str).map((x) => CallUserList.fromJson(x)));

String callUserListToJson(List<CallUserList> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CallUserList {
  RxString? userJid;
  RxString? callStatus = ''.obs;
  RxBool isAudioMuted = RxBool(false);
  RxBool isVideoMuted = RxBool(false);

  CallUserList({
    this.userJid,
    this.callStatus,
    required bool isAudioMuted,
    required bool isVideoMuted,
  }) : isAudioMuted = RxBool(isAudioMuted),isVideoMuted = RxBool(isVideoMuted);

  factory CallUserList.fromJson(Map<String, dynamic> json) => CallUserList(
    userJid: RxString(json["userJid"]),
    callStatus: RxString(json["callStatus"]),
    isAudioMuted: json["isAudioMuted"] ?? false,
    isVideoMuted: json["isVideoMuted"] ?? false,
  );

  Map<String, dynamic> toJson() => {
    "userJid": userJid?.value,
    "callStatus": callStatus?.value,
    "isAudioMuted": isAudioMuted.value,
    "isVideoMuted": isVideoMuted.value,
  };
}

class SpeakingUsers{
  String userJid;
  RxInt audioLevel = RxInt(0);
  SpeakingUsers({required this.userJid,required this.audioLevel});
}

extension SwappableList<E> on List<E> {
  void swap(int first, int second) {
    final temp = this[first];
    this[first] = this[second];
    this[second] = temp;
  }
}