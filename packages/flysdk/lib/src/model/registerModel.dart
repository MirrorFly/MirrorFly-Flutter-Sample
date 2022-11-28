// To parse this JSON data, do
//
//     final registerModel = registerModelFromJson(jsonString);

import 'dart:convert';

RegisterModel registerModelFromJson(String str) => RegisterModel.fromJson(json.decode(str));

String registerModelToJson(RegisterModel data) => json.encode(data.toJson());

class RegisterModel {
  RegisterModel({
     this.data,
     this.isNewUser,
     this.message,
  });

  Data? data;
  bool? isNewUser;
  String? message;

  factory RegisterModel.fromJson(Map<String, dynamic> json) => RegisterModel(
    data: Data.fromJson(json["data"]),
    isNewUser: json["is_new_user"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "data": data?.toJson(),
    "is_new_user": isNewUser,
    "message": message,
  };
}



class Data {
  Data({
     this.token,
     this.username,
     this.password,
     this.isExisting,
     this.isProfileUpdated,
     this.config,
  });

  String? token;
  String? username;
  String? password;
  bool? isExisting;
  bool? isProfileUpdated;
  RegConfig? config;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    token: json["token"],
    username: json["username"],
    password: json["password"],
    isExisting: json["isExisting"],
    isProfileUpdated: json["isProfileUpdated"],
    config: RegConfig.fromJson(json["config"]),
  );

  Map<String, dynamic> toJson() => {
    "token": token,
    "username": username,
    "password": password,
    "isExisting": isExisting,
    "isProfileUpdated": isProfileUpdated,
    "config": config?.toJson(),
  };
}

class RegConfig {
  RegConfig({
     this.domain,
     this.videoLimit,
     this.audioLimit,
     this.recallTime,
     this.privateTime,
     this.xmppDomain,
     this.xmppHost,
     this.xmppPort,
     this.adminUser,
     this.googleTranslate,
     this.signalServerDomain,
     this.notificationHelpUrl,
    this.sdkUrl,
     this.pinExpireDays,
     this.pinTimeOut,
     this.fileSizeLimit,
     required this.stuns,
     required this.turns,
     this.liveStreamingSignalServer,
     this.isLiveStreamingEnabled,
     this.sipcallEnabled,
     this.sipServer,
     this.callRoutingServer,
     this.chatBackupType,
     this.chatBackupFrequency,
     this.xmppPortWeb,
     this.iv,
     this.ivProfile,
  });

  String? domain;
  int? videoLimit;
  int? audioLimit;
  int? recallTime;
  int? privateTime;
  String? xmppDomain;
  String? xmppHost;
  int? xmppPort;
  String? adminUser;
  String? googleTranslate;
  String? signalServerDomain;
  String? notificationHelpUrl;
  dynamic sdkUrl;
  int? pinExpireDays;
  int? pinTimeOut;
  int? fileSizeLimit;
  List<String> stuns;
  List<Turn> turns;
  String? liveStreamingSignalServer;
  bool? isLiveStreamingEnabled;
  bool? sipcallEnabled;
  String? sipServer;
  String? callRoutingServer;
  String? chatBackupType;
  String? chatBackupFrequency;
  String? xmppPortWeb;
  String? iv;
  String? ivProfile;

  factory RegConfig.fromJson(Map<String, dynamic> json) => RegConfig(
    domain: json["domain"],
    videoLimit: json["videoLimit"],
    audioLimit: json["audioLimit"],
    recallTime: json["recallTime"],
    privateTime: json["privateTime"],
    xmppDomain: json["xmppDomain"],
    xmppHost: json["xmppHost"],
    xmppPort: json["xmppPort"],
    adminUser: json["adminUser"],
    googleTranslate: json["googleTranslate"],
    signalServerDomain: json["signalServerDomain"],
    notificationHelpUrl: json["notificationHelpUrl"],
    sdkUrl: json["sdkUrl"],
    pinExpireDays: json["pinExpireDays"],
    pinTimeOut: json["pinTimeOut"],
    fileSizeLimit: json["fileSizeLimit"],
    stuns: List<String>.from(json["stuns"].map((x) => x)),
    turns: List<Turn>.from(json["turns"].map((x) => Turn.fromJson(x))),
    liveStreamingSignalServer: json["liveStreamingSignalServer"],
    isLiveStreamingEnabled: json["isLiveStreamingEnabled"],
    sipcallEnabled: json["sipcallEnabled"],
    sipServer: json["sipServer"],
    callRoutingServer: json["callRoutingServer"],
    chatBackupType: json["chatBackupType"],
    chatBackupFrequency: json["chatBackupFrequency"],
    xmppPortWeb: json["xmppPortWeb"],
    iv: json["iv"],
    ivProfile: json["ivProfile"],
  );

  Map<String, dynamic> toJson() => {
    "domain": domain,
    "videoLimit": videoLimit,
    "audioLimit": audioLimit,
    "recallTime": recallTime,
    "privateTime": privateTime,
    "xmppDomain": xmppDomain,
    "xmppHost": xmppHost,
    "xmppPort": xmppPort,
    "adminUser": adminUser,
    "googleTranslate": googleTranslate,
    "signalServerDomain": signalServerDomain,
    "notificationHelpUrl": notificationHelpUrl,
    "sdkUrl": sdkUrl,
    "pinExpireDays": pinExpireDays,
    "pinTimeOut": pinTimeOut,
    "fileSizeLimit": fileSizeLimit,
    "stuns": List<dynamic>.from(stuns.map((x) => x)),
    "turns": List<dynamic>.from(turns.map((x) => x.toJson())),
    "liveStreamingSignalServer": liveStreamingSignalServer,
    "isLiveStreamingEnabled": isLiveStreamingEnabled,
    "sipcallEnabled": sipcallEnabled,
    "sipServer": sipServer,
    "callRoutingServer": callRoutingServer,
    "chatBackupType": chatBackupType,
    "chatBackupFrequency": chatBackupFrequency,
    "xmppPortWeb": xmppPortWeb,
    "iv": iv,
    "ivProfile": ivProfile,
  };
}

class Turn {
  Turn({
     this.turn,
     this.username,
     this.password,
  });

  String? turn;
  String? username;
  String? password;

  factory Turn.fromJson(Map<String, dynamic> json) => Turn(
    turn: json["turn"],
    username: json["username"],
    password: json["password"],
  );

  Map<String, dynamic> toJson() => {
    "turn": turn,
    "username": username,
    "password": password,
  };
}
