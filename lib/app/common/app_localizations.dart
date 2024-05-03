import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:mirror_fly_demo/app/common/extensions.dart';

class AppLocalizations {

  Locale locale = defaultLocale;
  Map<String, String> _localizedStrings = {};

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  Future<bool> load() async {
    String jsonString = await rootBundle.loadString('assets/locales/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? "";
  }

  // Default language
  static const defaultLocale = Locale('en', 'US');
  // Supported languages
  static const langs = [
    'Tamil',
    'Arabic',
    'English',
    'Spanish',
  ];

  // Supported locales
  static const supportedLocales = [
    Locale('ta', 'IN'),
    Locale('en', 'US'),
    Locale('ar', 'UAE'),
  ];

  // Helper method to get the language from locale
  static String langFromLocale(Locale locale) {
    switch (locale.languageCode) {
      case 'ta':
        return 'Tamil';
      case 'ar':
        return 'Arabic';
      default:
        return 'English';
    }
  }

  // The async method to load the localization files
  static Future<Map<String, Map<String, String>>> loadTranslations() async {
    Map<String, Map<String, String>> translations = {};
    for (var locale in supportedLocales) {
      String jsonString = await rootBundle.loadString('assets/locales/${locale.languageCode}.json');
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      var map = jsonMap.map((key, value) {
        return MapEntry(key, value.toString());
      });
      translations[locale.toString()] = map;
    }
    return translations;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _DemoLocalizationsDelegate();
}

class _DemoLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _DemoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // List<String> _languageString = [];
    // AppConstants.languages.forEach((language) {
    //   _languageString.add(language.languageCode.checkNull());
    // });
    return AppLocalizations.supportedLocales.contains(locale);//_languageString.contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localization =  AppLocalizations(locale);
    await localization.load();
    return localization;
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}

String getTranslated(String key, BuildContext context) {
  return (AppLocalizations.of(context)?.translate(key)).checkNull();
}