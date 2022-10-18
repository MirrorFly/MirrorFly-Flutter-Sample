// To parse this JSON data, do
//
//     final statusData = statusDataFromJson(jsonString);

import 'dart:convert';

List<StatusData> statusDataFromJson(String str) => List<StatusData>.from(json.decode(str).map((x) => StatusData.fromJson(x)));

String statusDataToJson(List<StatusData> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class StatusData {
  StatusData({
    required this.id,
    required this.isCurrentStatus,
    required this.status,
  });

  int id;
  bool isCurrentStatus;
  String status;

  factory StatusData.fromJson(Map<String, dynamic> json) => StatusData(
    id: json["id"] == null ? null : json["id"],
    isCurrentStatus: json["isCurrentStatus"] == null ? null : json["isCurrentStatus"],
    status: json["status"] == null ? null : json["status"],
  );

  Map<String, dynamic> toJson() => {
    "id": id == null ? null : id,
    "isCurrentStatus": isCurrentStatus == null ? null : isCurrentStatus,
    "status": status == null ? null : status,
  };
}
