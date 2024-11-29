

import 'dart:io';

import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirrorfly_plugin/logmessage.dart';

import '../backup_restore_manager.dart';
import '../backup_utils.dart';

class BackupController extends GetxController {

  bool get isAndroid => Platform.isAndroid;

  var driveAccessible = false.obs;

  var mobileNumber = '';

  var isAutoBackupEnabled = false.obs;

  var isBackupFound = false.obs;

  var backUpFoundDate = ''.obs;
  var backUpFoundSize = ''.obs;

  late BackupRestoreManager backupRestoreManager;

  var selectedBackupFrequency = "Monthly".obs;

  var selectedBackupNetworkFrequency = "Wi-Fi".obs;

  final backupUtils = BackupUtils();

  final List<String> backupFrequency = ["Daily", "Weekly", "Monthly"];

  final List<String> networkFrequency = ["Wi-Fi", "Wi-Fi or Cellular"];

  @override
  Future<void> onInit() async {
    super.onInit();

    backupRestoreManager = BackupRestoreManager();
    backupRestoreManager.initialize(
        iCloudContainerID: "iCloud.com.mirrorfly.uikitflutter",
        googleClientId: "");

    await backupRestoreManager.checkDriveAccess().then((isDriveAccessible) {
      LogMessage.d(
          "Restore Controller", "Drive Access Status => $isDriveAccessible");
      driveAccessible(isDriveAccessible);
      checkForBackUpFiles();
    });
  }

  Future<void> checkForBackUpFiles() async {
    await backupRestoreManager.checkBackUpFiles().then((isBackUpAvailable) {
      LogMessage.d(
          "Restore Controller", "Backup file Available => $isBackUpAvailable");
      isBackupFound(isBackUpAvailable);
    });
  }

  void initializeBackUp() {
    if(driveAccessible.value){
      toToast("Unable to access drive");
    }else{
      backupRestoreManager.startBackup();
    }
  }

  void downloadBackup() {
    backupRestoreManager.startBackup();
  }

  backUpProgress(event) {
    LogMessage.d(
        "Restore Controller", "backUpProgress => $event");
  }

  showBackupFrequency() async {
    selectedBackupFrequency(await backupUtils.showBackupOptionList(selectedValue: selectedBackupFrequency.value, listValue: backupFrequency));
  }

  showBackupNetworkFrequency() async {
    selectedBackupNetworkFrequency(await backupUtils.showBackupOptionList(selectedValue: selectedBackupNetworkFrequency.value, listValue: networkFrequency));
  }

  void updateAutoBackupOption(bool isEnabled) {
    LogMessage.d("Backup Controller", "Auto Backup Toggle => $isEnabled");
    isAutoBackupEnabled(isEnabled);
  }


}