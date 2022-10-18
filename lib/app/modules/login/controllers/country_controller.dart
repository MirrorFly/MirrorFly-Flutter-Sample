import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/model/countryModel.dart';

class CountryController extends GetxController{

  var maincountrylist = List<CountryData>.empty(growable: true);
  var countrylist = List<CountryData>.empty(growable: true).obs;
  final TextEditingController searchQuery = new TextEditingController();
  var search=false.obs;
  var IsSearching=false;
  FocusNode focusNode = FocusNode();

  countrySearchFilter(String text){
    IsSearching=true;
    countrylist.value.clear();
    if(text.isNotEmpty) {
      var filter = maincountrylist.where((item) => item.name.toLowerCase().contains(text.toLowerCase()));
      countrylist.value.addAll(filter);
    }else{
      countrylist.value.addAll(maincountrylist);
    }
    countrylist.refresh();
  }

  void backfromSearch(){
    searchQuery.text="";
    search.value=false;
    if(IsSearching){
     countrylist.clear();
     countrylist.addAll(maincountrylist);
     countrylist.refresh();
     IsSearching=false;
    }else{
      Get.back();
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadAsset().then((value){
      maincountrylist.addAll(value);
      countrylist.addAll(value);
    });
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        IsSearching=true;
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