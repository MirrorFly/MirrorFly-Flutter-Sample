import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../../data/session_management.dart';
import '../../../../../data/utils.dart';
import '../../../../../model/language_model.dart';

class LanguageController extends GetxController{

  var mainLanguageList = List<LanguageData>.empty(growable: true);
  var languageList = List<LanguageData>.empty(growable: true).obs;
  final TextEditingController searchQuery = TextEditingController();
  var search=false.obs;
  var isSearching=false;
  FocusNode focusNode = FocusNode();

  var translationLanguage = ''.obs;

  languageSearchFilter(String text){
    isSearching=true;
    languageList.clear();
    if(text.isNotEmpty) {
      var filter = mainLanguageList.where((item) => item.languageName.toLowerCase().contains(text.toLowerCase()));
      languageList.addAll(filter.toList());
    }else{
      languageList.addAll(mainLanguageList);
    }
    languageList.refresh();
  }

  void backFromSearch(){
    searchQuery.text="";
    search.value=false;
    if(isSearching){
     languageList.clear();
     languageList.addAll(mainLanguageList);
     languageList.refresh();
     isSearching=false;
    }else{
      NavUtils.back();
    }
  }

  @override
  void onInit() {
    super.onInit();
    translationLanguage(NavUtils.arguments as String);
    loadAsset().then((value){
      mainLanguageList.addAll(value);
      languageList.addAll(value);
    });
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        isSearching=true;
      }
    });
  }

  Future<List<LanguageData>> loadAsset() async {
    var data = await rootBundle.loadString('assets/languages.txt');
    if(data.isNotEmpty){
      return languageDataFromJson(data);
    }else{
      return List.empty();
    }
  }

  void selectLanguage(LanguageData item){
    translationLanguage(item.languageName);
    SessionManagement.setGoogleTranslationLanguage(item.languageName);
    SessionManagement.setGoogleTranslationLanguageCode(item.languageCode);
    NavUtils.back(result: item.languageName);
  }
}