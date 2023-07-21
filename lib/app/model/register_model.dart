// To parse this JSON data, do
//
//     final registerModel = registerModelFromJson(jsonString);

import 'dart:convert';

RegisterModel registerModelFromJson(String str) => RegisterModel.fromJson(json.decode(str));

String registerModelToJson(RegisterModel data) => json.encode(data.toJson());

class RegisterModel {
  Data? data;
  bool? isNewUser;
  String? message;

  RegisterModel({
    this.data,
    this.isNewUser,
    this.message,
  });

  factory RegisterModel.fromJson(Map<String, dynamic> json) => RegisterModel(
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
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
  Config? config;
  bool? isExisting;
  bool? isProfileUpdated;
  String? message;
  bool? newLogin;
  String? password;
  String? token;
  String? username;

  Data({
    this.config,
    this.isExisting,
    this.isProfileUpdated,
    this.message,
    this.newLogin,
    this.password,
    this.token,
    this.username,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    config: json["config"] == null ? null : Config.fromJson(json["config"]),
    isExisting: json["isExisting"],
    isProfileUpdated: json["isProfileUpdated"],
    message: json["message"],
    newLogin: json["newLogin"],
    password: json["password"],
    token: json["token"],
    username: json["username"],
  );

  Map<String, dynamic> toJson() => {
    "config": config?.toJson(),
    "isExisting": isExisting,
    "isProfileUpdated": isProfileUpdated,
    "message": message,
    "newLogin": newLogin,
    "password": password,
    "token": token,
    "username": username,
  };
}

class Config {
  String? adminUser;
  bool? attachment;
  bool? audioAttachment;
  int? audioLimit;
  bool? block;
  String? callRoutingServer;
  String? chatBackupFrequency;
  String? chatBackupType;
  bool? clearChat;
  bool? contactAttachment;
  bool? deleteChat;
  bool? deleteMessage;
  bool? documentAttachment;
  String? domain;
  int? fileSizeLimit;
  String? googleTranslate;
  bool? groupCall;
  bool? groupChat;
  bool? imageAttachment;
  bool? isLiveStreamingEnabled;
  String? iv;
  String? ivProfile;
  String? liveStreamingSignalServer;
  bool? locationAttachment;
  String? notificationHelpUrl;
  bool? one2OneCall;
  int? pinExpireDays;
  int? pinTimeOut;
  int? privateTime;
  int? recallTime;
  bool? recentchatSearch;
  bool? report;
  String? sdkUrl;
  String? signalServerDomain;
  bool? sipcallEnabled;
  String? sipServer;
  bool? starMessage;
  List<String>? stuns;
  bool? translation;
  List<Turn>? turns;
  bool? videoAttachment;
  int? videoLimit;
  bool? viewAllMedias;
  String? xmppDomain;
  String? xmppHost;
  int? xmppPort;
  String? xmppPortWeb;

  Config({
    this.adminUser,
    this.attachment,
    this.audioAttachment,
    this.audioLimit,
    this.block,
    this.callRoutingServer,
    this.chatBackupFrequency,
    this.chatBackupType,
    this.clearChat,
    this.contactAttachment,
    this.deleteChat,
    this.deleteMessage,
    this.documentAttachment,
    this.domain,
    this.fileSizeLimit,
    this.googleTranslate,
    this.groupCall,
    this.groupChat,
    this.imageAttachment,
    this.isLiveStreamingEnabled,
    this.iv,
    this.ivProfile,
    this.liveStreamingSignalServer,
    this.locationAttachment,
    this.notificationHelpUrl,
    this.one2OneCall,
    this.pinExpireDays,
    this.pinTimeOut,
    this.privateTime,
    this.recallTime,
    this.recentchatSearch,
    this.report,
    this.sdkUrl,
    this.signalServerDomain,
    this.sipcallEnabled,
    this.sipServer,
    this.starMessage,
    this.stuns,
    this.translation,
    this.turns,
    this.videoAttachment,
    this.videoLimit,
    this.viewAllMedias,
    this.xmppDomain,
    this.xmppHost,
    this.xmppPort,
    this.xmppPortWeb,
  });

  factory Config.fromJson(Map<String, dynamic> json) => Config(
    adminUser: json["adminUser"],
    attachment: json["attachment"],
    audioAttachment: json["audioAttachment"],
    audioLimit: json["audioLimit"],
    block: json["block"],
    callRoutingServer: json["callRoutingServer"],
    chatBackupFrequency: json["chatBackupFrequency"],
    chatBackupType: json["chatBackupType"],
    clearChat: json["clearChat"],
    contactAttachment: json["contactAttachment"],
    deleteChat: json["deleteChat"],
    deleteMessage: json["deleteMessage"],
    documentAttachment: json["documentAttachment"],
    domain: json["domain"],
    fileSizeLimit: json["fileSizeLimit"],
    googleTranslate: json["googleTranslate"],
    groupCall: json["groupCall"],
    groupChat: json["groupChat"],
    imageAttachment: json["imageAttachment"],
    isLiveStreamingEnabled: json["isLiveStreamingEnabled"],
    iv: json["iv"],
    ivProfile: json["ivProfile"],
    liveStreamingSignalServer: json["liveStreamingSignalServer"],
    locationAttachment: json["locationAttachment"],
    notificationHelpUrl: json["notificationHelpUrl"],
    one2OneCall: json["one2oneCall"],
    pinExpireDays: json["pinExpireDays"],
    pinTimeOut: json["pinTimeOut"],
    privateTime: json["privateTime"],
    recallTime: json["recallTime"],
    recentchatSearch: json["recentchatSearch"],
    report: json["report"],
    sdkUrl: json["sdkUrl"],
    signalServerDomain: json["signalServerDomain"],
    sipcallEnabled: json["sipcallEnabled"],
    sipServer: json["sipServer"],
    starMessage: json["starMessage"],
    stuns: json["stuns"] == null ? [] : List<String>.from(json["stuns"]!.map((x) => x)),
    translation: json["translation"],
    turns: json["turns"] == null ? [] : List<Turn>.from(json["turns"]!.map((x) => Turn.fromJson(x))),
    videoAttachment: json["videoAttachment"],
    videoLimit: json["videoLimit"],
    viewAllMedias: json["viewAllMedias"],
    xmppDomain: json["xmppDomain"],
    xmppHost: json["xmppHost"],
    xmppPort: json["xmppPort"],
    xmppPortWeb: json["xmppPortWeb"],
  );

  Map<String, dynamic> toJson() => {
    "adminUser": adminUser,
    "attachment": attachment,
    "audioAttachment": audioAttachment,
    "audioLimit": audioLimit,
    "block": block,
    "callRoutingServer": callRoutingServer,
    "chatBackupFrequency": chatBackupFrequency,
    "chatBackupType": chatBackupType,
    "clearChat": clearChat,
    "contactAttachment": contactAttachment,
    "deleteChat": deleteChat,
    "deleteMessage": deleteMessage,
    "documentAttachment": documentAttachment,
    "domain": domain,
    "fileSizeLimit": fileSizeLimit,
    "googleTranslate": googleTranslate,
    "groupCall": groupCall,
    "groupChat": groupChat,
    "imageAttachment": imageAttachment,
    "isLiveStreamingEnabled": isLiveStreamingEnabled,
    "iv": iv,
    "ivProfile": ivProfile,
    "liveStreamingSignalServer": liveStreamingSignalServer,
    "locationAttachment": locationAttachment,
    "notificationHelpUrl": notificationHelpUrl,
    "one2oneCall": one2OneCall,
    "pinExpireDays": pinExpireDays,
    "pinTimeOut": pinTimeOut,
    "privateTime": privateTime,
    "recallTime": recallTime,
    "recentchatSearch": recentchatSearch,
    "report": report,
    "sdkUrl": sdkUrl,
    "signalServerDomain": signalServerDomain,
    "sipcallEnabled": sipcallEnabled,
    "sipServer": sipServer,
    "starMessage": starMessage,
    "stuns": stuns == null ? [] : List<dynamic>.from(stuns!.map((x) => x)),
    "translation": translation,
    "turns": turns == null ? [] : List<dynamic>.from(turns!.map((x) => x.toJson())),
    "videoAttachment": videoAttachment,
    "videoLimit": videoLimit,
    "viewAllMedias": viewAllMedias,
    "xmppDomain": xmppDomain,
    "xmppHost": xmppHost,
    "xmppPort": xmppPort,
    "xmppPortWeb": xmppPortWeb,
  };
}

class Turn {
  String? password;
  String? turn;
  String? username;

  Turn({
    this.password,
    this.turn,
    this.username,
  });

  factory Turn.fromJson(Map<String, dynamic> json) => Turn(
    password: json["password"],
    turn: json["turn"],
    username: json["username"],
  );

  Map<String, dynamic> toJson() => {
    "password": password,
    "turn": turn,
    "username": username,
  };
}
