import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:mirrorfly_chat/mirrorfly.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/routes/app_pages.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../common/constants.dart';
import '../../../data/permissions.dart';
import '../../../data/session_management.dart';

class ContactSyncController extends GetxController
    with GetTickerProviderStateMixin {
  final _obj = ''.obs;

  set obj(value) => _obj.value = value;

  get obj => _obj.value;

  var name = SessionManagement.getName() ?? '';
  late AnimationController animController;

  final Tween<double> turnsTween = Tween<double>(
    begin: 1,
    end: 0,
  );

  @override
  void onInit() {
    super.onInit();
    openContactPermission();
    animController =
        AnimationController(vsync: this, duration: const Duration(seconds: 10));
    // var animation=CurvedAnimation(parent: animController, curve: Curves.easeIn,);
    animController.repeat();
  }

  @override
  void onClose(){
    super.onClose();
    animController.dispose();
  }

  @override
  void dispose() {
    super.dispose();
    animController.dispose();
  }

  Rx<bool> syncing = false.obs;
  Rx<String> textContactSync = ''.obs;
  openContactPermission() async {
    if(!await Mirrorfly.contactSyncStateValue()) {
      var contactPermissionHandle = await AppPermission.checkPermission(
          Permission.contacts, contactPermission,
          Constants.contactPermission);
      if (contactPermissionHandle) {
        syncing(true);
        textContactSync('Contact sync is in process');
        Mirrorfly.syncContacts(!SessionManagement.isInitialContactSyncDone());
        checkContactSync();
      } else {
        Get.offNamed(Routes.dashboard);
      }
    }else{
      syncing(true);
      textContactSync('Contact sync is in process');
    }
  }
  checkContactSync() async {
    await Mirrorfly.contactSyncStateValue();
    /*if (contactSyncState == null || contactSyncState == Result.InProgress) {
      textContactSync('Contact sync is in process');
    } else {
      textContactSync('Please check your internet connection');
    }
    startContactSyncTask()
    observeContactSyncStatus()*/
  }

  void onContactSyncComplete(bool result) {
    if(Get.currentRoute==Routes.contactSync) {
      Mirrorfly.getRegisteredUsers(true).then((value) {
        mirrorFlyLog("registeredUsers", value.toString());
        navigateToDashboard();
      });
    }
  }

  void navigateToDashboard() {
    animController.dispose();
    Get.offNamed(Routes.dashboard);
  }

  Future<void> networkConnected() async {
    mirrorFlyLog('networkConnected', 'contactSync');
    textContactSync('');
    if(!await Mirrorfly.contactSyncStateValue()){
      openContactPermission();
    }else{
      syncing(true);
      textContactSync('Contact sync is in process');
    }
  }

  void networkDisconnected() {
    syncing(false);
    textContactSync(Constants.noInternetConnection);
  }
}
