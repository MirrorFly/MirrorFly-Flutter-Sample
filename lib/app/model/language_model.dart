import 'dart:convert';

List<LanguageData> languageDataFromJson(String str) => List<LanguageData>.from(json.decode(str).map((x) => LanguageData.fromJson(x)));

String languageDataToJson(List<LanguageData> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class LanguageData {
  LanguageData({
    required this.languageName,
    required this.languageCode,
  });

  String languageName;
  String languageCode;

  factory LanguageData.fromJson(Map<String, dynamic> json) => LanguageData(
    languageName: json["language_name"],
    languageCode: json["language_code"],
  );

  Map<String, dynamic> toJson() => {
    "language_name": languageName,
    "language_code": languageCode,
  };
}
