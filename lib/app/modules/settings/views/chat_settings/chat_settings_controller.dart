import 'package:flutter/material.dart';
import 'package:flysdk/flysdk.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';

import '../../../../data/apputils.dart';
import '../../../../data/helper.dart';

class ChatSettingsController extends GetxController {

  final _archiveEnabled = false.obs;
  final lastSeenPreference = false.obs;
  bool get archiveEnabled => _archiveEnabled.value;

  @override
  void onInit(){
    super.onInit();
    getArchivedSettingsEnabled();
  }
  Future<void> getArchivedSettingsEnabled() async {
    await FlyChat.isArchivedSettingsEnabled().then((value) => _archiveEnabled(value));

  }

  void enableArchive(){
    FlyChat.enableDisableArchivedSettings(!archiveEnabled);
    _archiveEnabled(!archiveEnabled);
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
}