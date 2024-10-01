import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/app_localizations.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../common/constants.dart';
import '../../../data/permissions.dart';
import '../../../data/session_management.dart';
import '../../../data/utils.dart';
import '../../../routes/route_settings.dart';

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
      var contactPermissionHandle = await AppPermission.checkAndRequestPermissions(permissions: [Permission.contacts],
          permissionIcon: contactPermission,
          permissionContent:getTranslated("contactPermissionContent"),permissionPermanentlyDeniedContent:getTranslated("contactPermissionDeniedContent") );
      if (contactPermissionHandle) {
        syncing(true);
        textContactSync(getTranslated("contactSyncInProcess"));
        Mirrorfly.syncContacts(isFirstTime: !SessionManagement.isInitialContactSyncDone(), flyCallBack: (_) {  });
        checkContactSync();
      } else {
        NavUtils.offNamed(Routes.dashboard);
      }
    }else{
      syncing(true);
      textContactSync(getTranslated("contactSyncInProcess"));
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
    if(NavUtils.currentRoute==Routes.contactSync) {
      Mirrorfly.getRegisteredUsers(fetchFromServer: true,flyCallback: (FlyResponse response){
        LogMessage.d("registeredUsers", response.isSuccess.toString());
        navigateToDashboard();
      });
      /*then((value) {
        LogMessage.d("registeredUsers", value.toString());
        navigateToDashboard();
      });*/
    }
  }

  void navigateToDashboard() {
    animController.dispose();
    NavUtils.offNamed(Routes.dashboard);
  }

  Future<void> onConnected() async {
    LogMessage.d('networkConnected', 'contactSync');
    textContactSync('');
    if(!await Mirrorfly.contactSyncStateValue()){
      openContactPermission();
    }else{
      syncing(true);
      textContactSync(getTranslated("contactSyncInProcess"));
    }
  }

  void onDisconnected() {
    syncing(false);
    textContactSync(getTranslated("noInternetConnection"));
  }
}
