import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mirror_fly_demo/app/common/main_controller.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/session_management.dart';

import '../../../../data/apputils.dart';
import '../../../../data/helper.dart';
import '../../../../data/permissions.dart';
import '../../../../routes/route_settings.dart';

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
    await Mirrorfly.isLastSeenVisible().then((value) => lastSeenPreference(value));
  }


  void enableArchive() async{
    if(await AppUtils.isNetConnected()) {
      Mirrorfly.enableDisableArchivedSettings(enable: !archiveEnabled, flyCallBack: (FlyResponse response) {
        if(response.isSuccess){
          _archiveEnabled(!archiveEnabled);
        }
      });
    }else{
      toToast(Constants.noInternetConnection);
    }
  }

  Future<void> enableDisableAutoDownload() async {
    var permission = await AppPermission.getStoragePermission();
    if (permission) {
      var enable = !_autoDownloadEnabled.value;//SessionManagement.isAutoDownloadEnable();
        Mirrorfly.setMediaAutoDownload(enable: enable);
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
          child: const Text("NO",style: TextStyle(color: buttonBgColor))),
      TextButton(
          onPressed: () {
            Get.back();
            clearAllConv();
          },
          child: const Text("YES",style: TextStyle(color: buttonBgColor))),
    ]);
  }

  Future<void> clearAllConv() async {
    if (await AppUtils.isNetConnected()) {
     Mirrorfly.clearAllConversation(flyCallBack: (FlyResponse response) {
        if(response.isSuccess){
          clearAllConvRecentChatUI();
          toToast('All your conversation are cleared');
        }else{
          toToast('Server error, kindly try again later');
        }
     });
    } else {
      toToast(Constants.noInternetConnection);
    }
  }

  lastSeenEnableDisable() async{
    if(await AppUtils.isNetConnected()) {
      Mirrorfly.setLastSeenVisibility(enable: !lastSeenPreference.value, flyCallBack: (FlyResponse response) {
        debugPrint("enableDisableHideLastSeen--> $response");
        if(response.isSuccess) {
          lastSeenPreference(!lastSeenPreference.value);
        }
      });
    }else{
      toToast(Constants.noInternetConnection);
    }
  }

  busyStatusEnable() {
    bool busyStatusVal = !busyStatusPreference.value;
    debugPrint("busy_status_val ${busyStatusVal.toString()}");
    busyStatusPreference(busyStatusVal);
    Mirrorfly.enableDisableBusyStatus(enable: busyStatusVal, flyCallBack: (FlyResponse response) {
      getMyBusyStatus();
    });
  }

  void getMyBusyStatus() {
    Mirrorfly.getMyBusyStatus().then((value) {
      var userBusyStatus = json.decode(value);
      debugPrint("Busy Status $userBusyStatus");
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

  void clearAllConvRecentChatUI() {
    Get.find<MainController>().clearAllConvRecentChatUI();
  }
}