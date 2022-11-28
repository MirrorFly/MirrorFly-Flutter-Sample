// To parse this JSON data, do
//
//     final statusData = statusDataFromJson(jsonString);

import 'dart:convert';

List<StatusData> statusDataFromJson(String str) => List<StatusData>.from(json.decode(str).map((x) => StatusData.fromJson(x)));

String statusDataToJson(List<StatusData> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class StatusData {
  StatusData({
    this.id,
    this.isCurrentStatus,
    this.status,
  });

  int? id;
  bool? isCurrentStatus;
  String? status;

  factory StatusData.fromJson(Map<String, dynamic> json) => StatusData(
    id: json["id"],
    isCurrentStatus: json["isCurrentStatus"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "isCurrentStatus": isCurrentStatus,
    "status": status,
  };
}
