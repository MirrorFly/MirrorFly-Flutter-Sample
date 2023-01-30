import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flysdk/flysdk.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/session_management.dart';

import '../../../../data/apputils.dart';
import '../../../../data/helper.dart';
import '../../../../routes/app_pages.dart';

class ChatSettingsController extends GetxController {

  final _archiveEnabled = false.obs;
  final lastSeenPreference = false.obs;
  final busyStatusPreference = false.obs;
  final busyStatus = "".obs;
  bool get archiveEnabled => _archiveEnabled.value;

  final _translationEnabled = false.obs;
  bool get translationEnabled => _translationEnabled.value;

  final _translationLanguage = "English".obs;
  String get translationLanguage => _translationLanguage.value;

  @override
  void onInit(){
    super.onInit();
    getArchivedSettingsEnabled();
    _translationEnabled(SessionManagement.isGoogleTranslationEnable());
    _translationLanguage(SessionManagement.getTranslationLanguage());
    getBusyStatusPreference();
    getMyBusyStatus();
  }
  Future<void> getArchivedSettingsEnabled() async {
    await FlyChat.isArchivedSettingsEnabled().then((value) => _archiveEnabled(value));

  }

  void enableArchive(){
    FlyChat.enableDisableArchivedSettings(!archiveEnabled);
    _archiveEnabled(!archiveEnabled);
  }

  Future<void> enableDisableTranslate() async {
    //if (await AppUtils.isNetConnected() && SessionManagement.isGoogleTranslationEnable()) {
    var enable = !SessionManagement.isGoogleTranslationEnable();
      SessionManagement.setGoogleTranslationEnable(enable);
      _translationEnabled(enable);
    /*}else{
      toToast(Constants.noInternetConnection);
    }*/
  }

  void displayTranslateLanguagePreference(){

  }

  void chooseLanguage(){
    Get.toNamed(Routes.languages,arguments: translationLanguage)?.then((value){
      if(value!=null){
        var language = value as String;
        _translationLanguage(language);
      }
    });
  }

  void clearAllConversation(){
    Helper.showAlert(message: 'Are you sure want to clear your conversation history?',actions: [
      TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text("NO")),
      TextButton(
          onPressed: () {
            Get.back();
            clearAllConv();
          },
          child: const Text("YES")),
    ]);
  }

  Future<void> clearAllConv() async {
    if (await AppUtils.isNetConnected()) {
      var result = await FlyChat.clearAllConversation();
      if(result.checkNull()){
        toToast('All your conversation are cleared');
      }else{
        toToast('Server error, kindly try again later');
      }
    } else {
      toToast(Constants.noInternetConnection);
    }
  }

  lastSeenEnableDisable() {
    lastSeenPreference(!lastSeenPreference.value);
  }

  busyStatusEnable() async {
    bool busyStatusVal = !busyStatusPreference.value;
    debugPrint("busy_status_val ${busyStatusVal.toString()}");
    busyStatusPreference(busyStatusVal);
    await FlyChat.enableDisableBusyStatus(busyStatusVal);
  }

  void getMyBusyStatus() {
    FlyChat.getMyBusyStatus().then((value) {
      var userBusyStatus = json.decode(value);
      debugPrint("Busy Status ${userBusyStatus["status"]}");
      busyStatus(userBusyStatus["status"]);

    });
  }

  Future<void> getBusyStatusPreference() async {
    bool? busyStatusPref = await FlyChat.isBusyStatusEnabled();
    busyStatusPreference(busyStatusPref);
    debugPrint("busyStatusPref ${busyStatusPref.toString()}");
  }
}