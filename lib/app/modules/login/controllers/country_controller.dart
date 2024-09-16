import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import '../../../data/utils.dart';

class CountryController extends GetxController{

  var mainCountryList = List<CountryData>.empty(growable: true);
  var countryList = List<CountryData>.empty(growable: true).obs;
  final TextEditingController searchQuery = TextEditingController();
  var search=false.obs;
  var isSearching=false;
  FocusNode focusNode = FocusNode();

  countrySearchFilter(String text){
    isSearching=true;
    countryList.clear();
    if(text.isNotEmpty) {
      var filter = mainCountryList.where((item) => item.name!.toLowerCase().contains(text.toLowerCase()));
      countryList.addAll(filter);
    }else{
      countryList.addAll(mainCountryList);
    }
    countryList.refresh();
  }

  void backFromSearch(){
    searchQuery.text="";
    search.value=false;
    if(isSearching){
     countryList.clear();
     countryList.addAll(mainCountryList);
     countryList.refresh();
     isSearching=false;
    }else{
      NavUtils.back();
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadAsset().then((value){
      mainCountryList.addAll(value);
      countryList.addAll(value);
    });
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        isSearching=true;
      }
    });
  }

  Future<List<CountryData>> loadAsset() async {
    var data = await rootBundle.loadString('assets/countries.txt');
    if(data.isNotEmpty){
      return countryDataFromJson(data);
    }else{
      return List.empty();
    }
  }
}