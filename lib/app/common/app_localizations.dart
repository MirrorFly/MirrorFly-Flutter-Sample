import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../extensions/extensions.dart';


class AppLocalizations {

  Locale locale = defaultLocale;
  static Map<String, dynamic> _localizedStrings = {};

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  Future<bool> load() async {
    try {
      String jsonString = await rootBundle.loadString(
          'assets/locales/${locale.languageCode}.json');
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      debugPrint("language load success ${locale.languageCode}");
      _localizedStrings = jsonMap;
    }catch(e){
      debugPrint("language load failed so default en is loaded $e}");
      String jsonString = await rootBundle.loadString(
          'assets/locales/en.json');
      Map<String, dynamic> jsonMap = json.decode(jsonString);

      _localizedStrings = jsonMap;
    }

    return true;
  }

  static String? translate(String key) {
    return _localizedStrings.containsKey(key) ?  _localizedStrings[key] : null;
  }

  static dynamic translateList(String key) {
    return _localizedStrings.containsKey(key) ?  List<String>.from(_localizedStrings[key] ?? '') : [];
  }

  // Default language
  static const defaultLocale = Locale('en', 'IN');
  // Supported languages
  // static const langs = [
  //   'Tamil',
  //   'Arabic',
  //   'English',
  //   'Spanish',
  // ];

  // Supported locales
  static var supportedLocales = [
    const Locale('en', 'IN'),
  ];

  static void addSupportedLocales(Locale locale){
    supportedLocales.add(locale);
  }
  // Helper method to get the language from locale
  // static String langFromLocale(Locale locale) {
  //   switch (locale.languageCode) {
  //     case 'ta':
  //       return 'Tamil';
  //     case 'ar':
  //       return 'Arabic';
  //     default:
  //       return 'English';
  //   }
  // }

  // The async method to load the localization files
  // static Future<Map<String, Map<String, String>>> loadTranslations() async {
  //   Map<String, Map<String, String>> translations = {};
  //   for (var locale in supportedLocales) {
  //     String jsonString = await rootBundle.loadString('assets/locales/${locale.languageCode}.json');
  //     Map<String, dynamic> jsonMap = json.decode(jsonString);
  //     var map = jsonMap.map((key, value) {
  //       return MapEntry(key, value.toString());
  //     });
  //     translations[locale.toString()] = map;
  //   }
  //   return translations;
  // }

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
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => true;
}

String getTranslated(String key) {
  return (AppLocalizations.translate(key)).checkNull();
}

List<String> getTranslatedList(String key) {
  return (AppLocalizations.translateList(key));
}