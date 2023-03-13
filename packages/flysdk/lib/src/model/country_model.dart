// To parse this JSON data, do
//
//     final countryData = countryDataFromJson(jsonString);

import 'dart:convert';

List<CountryData> countryDataFromJson(String str) => List<CountryData>.from(json.decode(str).map((x) => CountryData.fromJson(x)));

String countryDataToJson(List<CountryData> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CountryData {
  CountryData({
    required this.name,
    required this.dialCode,
    required this.code,
  });

  String? name;
  String? dialCode;
  String? code;

  factory CountryData.fromJson(Map<String, dynamic> json) => CountryData(
    name: json["name"],
    dialCode: json["dial_code"],
    code: json["code"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "dial_code": dialCode,
    "code": code,
  };
}
