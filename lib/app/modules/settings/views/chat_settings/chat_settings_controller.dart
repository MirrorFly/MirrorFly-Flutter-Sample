import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mirrorfly_chat/mirrorfly.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/session_management.dart';

import '../../../../data/apputils.dart';
import '../../../../data/helper.dart';
import '../../../../data/permissions.dart';
import '../../../../routes/app_pages.dart';

class ChatSettingsController extends GetxController {

  final _archiveEnabled = false.obs;
  final lastSeenPreference = false.obs;
  final busyStatusPreference = false.obs;
  final busyStatus = "".obs;
  bool get archiveEnabled => _archiveEnabled.value;

  final _autoDownloadEnabled = false.obs;
  bool get autoDownloadEnabled => _autoDownloadEnabled.value;

  final _translationEnabled = false.obs;
  bool get translationEnabled => _translationEnabled.value;

  final _translationLanguage = "English".obs;
  String get translationLanguage => _translationLanguage.value;

  @override
  Future<void> onInit() async {
    super.onInit();
    getArchivedSettingsEnabled();
    _translationEnabled(SessionManagement.isGoogleTranslationEnable());
    _translationLanguage(SessionManagement.getTranslationLanguage());
    _autoDownloadEnabled(await Mirrorfly.getMediaAutoDownload());
    getLastSeenSettingsEnabled();
    getBusyStatusPreference();
    getMyBusyStatus();

  }
  Future<void> getArchivedSettingsEnabled() async {
    await Mirrorfly.isArchivedSettingsEnabled().then((value) => _archiveEnabled(value));

  }

  Future<void> getLastSeenSettingsEnabled() async {
    // boolean lastSeenStatus = FlyCore.isHideLastSeenEnabled();
    await Mirrorfly.isHideLastSeenEnabled().then((value) => lastSeenPreference(value));
  }


  void enableArchive() async{
    if(await AppUtils.isNetConnected()) {
      Mirrorfly.enableDisableArchivedSettings(!archiveEnabled);
      _archiveEnabled(!archiveEnabled);
    }else{
      toToast(Constants.noInternetConnection);
    }
  }

  Future<void> enableDisableAutoDownload() async {
    var permission = await AppPermission.getStoragePermission();
    if (permission) {
      var enable = !_autoDownloadEnabled.value;//SessionManagement.isAutoDownloadEnable();
        Mirrorfly.setMediaAutoDownload(enable);
        _autoDownloadEnabled(enable);
    }
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
      var result = await Mirrorfly.clearAllConversation();
      if(result.checkNull()){
        toToast('All your conversation are cleared');
      }else{
        toToast('Server error, kindly try again later');
      }
    } else {
      toToast(Constants.noInternetConnection);
    }
  }

  lastSeenEnableDisable() async{
    if(await AppUtils.isNetConnected()) {
      Mirrorfly.enableDisableHideLastSeen(!lastSeenPreference.value).then((value) {
        debugPrint("enableDisableHideLastSeen--> $value");
        if(value != null && value) {
          lastSeenPreference(!lastSeenPreference.value);
        }
      });
    }else{
      toToast(Constants.noInternetConnection);
    }
  }

  busyStatusEnable() async {
    bool busyStatusVal = !busyStatusPreference.value;
    debugPrint("busy_status_val ${busyStatusVal.toString()}");
    busyStatusPreference(busyStatusVal);
    await Mirrorfly.enableDisableBusyStatus(busyStatusVal).then((value) => getMyBusyStatus());
  }

  void getMyBusyStatus() {
    Mirrorfly.getMyBusyStatus().then((value) {
      var userBusyStatus = json.decode(value);
      debugPrint("Busy Status ${userBusyStatus["status"]}");
      // var busyStatus = userBusyStatus["status"];
      // if(busyStatus)
      busyStatus(userBusyStatus["status"]);

    });
  }

  Future<void> getBusyStatusPreference() async {
    bool? busyStatusPref = await Mirrorfly.isBusyStatusEnabled();
    busyStatusPreference(busyStatusPref);
    debugPrint("busyStatusPref ${busyStatusPref.toString()}");
  }
}