import 'dart:convert';

List<WebLogin> webLoginFromJson(String str) => List<WebLogin>.from(json.decode(str).map((x) => WebLogin.fromJson(x)));

String webLoginToJson(List<WebLogin> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class WebLogin {
  WebLogin({
    required this.id,
    required this.lastLoginTime,
    required this.osName,
    required this.qrUniqeToken,
    required this.webBrowserName,
  });

  int id;
  String lastLoginTime;
  String osName;
  String qrUniqeToken;
  String webBrowserName;

  factory WebLogin.fromJson(Map<String, dynamic> json) => WebLogin(
    id: json["id"],
    lastLoginTime: json["lastLoginTime"],
    osName: json["osName"],
    qrUniqeToken: json["qrUniqeToken"],
    webBrowserName: json["webBrowserName"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "lastLoginTime": lastLoginTime,
    "osName": osName,
    "qrUniqeToken": qrUniqeToken,
    "webBrowserName": webBrowserName,
  };
}
