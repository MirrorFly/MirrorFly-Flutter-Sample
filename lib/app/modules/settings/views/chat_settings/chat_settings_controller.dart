import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/constants.dart';
import '../../../../common/main_controller.dart';
import '../../../../data/session_management.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import '../../../../app_style_config.dart';
import '../../../../common/app_localizations.dart';
import '../../../../data/permissions.dart';
import '../../../../data/utils.dart';
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
      toToast(getTranslated("noInternetConnection"));
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
      toToast(getTranslated("noInternetConnection"));
    }*/
  }

  void chooseLanguage(){
    NavUtils.toNamed(Routes.languages,arguments: translationLanguage)?.then((value){
      if(value!=null){
        var language = value as String;
        _translationLanguage(language);
      }
    });
  }

  void clearAllConversation(){
    DialogUtils.showAlert(dialogStyle: AppStyleConfig.dialogStyle,message: getTranslated("areYouClearAllChat"),actions: [
      TextButton(style: AppStyleConfig.dialogStyle.buttonStyle,
          onPressed: () {
            NavUtils.back();
          },
          child: Text(getTranslated("no").toUpperCase(), )),
      TextButton(style: AppStyleConfig.dialogStyle.buttonStyle,
          onPressed: () {
            NavUtils.back();
            clearAllConv();
          },
          child: Text(getTranslated("yes").toUpperCase(), )),
    ]);
  }

  Future<void> clearAllConv() async {
    if (await AppUtils.isNetConnected()) {
     Mirrorfly.clearAllConversation(flyCallBack: (FlyResponse response) {
        if(response.isSuccess){
          clearAllConvRecentChatUI();
          toToast(getTranslated("allChatsCleared"));
        }else{
          toToast(getTranslated("serverError"));
        }
     });
    } else {
      toToast(getTranslated("noInternetConnection"));
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
      toToast(getTranslated("noInternetConnection"));
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