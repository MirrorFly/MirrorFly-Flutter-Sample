

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/app_localizations.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirrorfly_plugin/flychat.dart';
import 'package:mirrorfly_plugin/logmessage.dart';

import '../../../data/permissions.dart';
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

  var isBackupStarted = false.obs;
  var isRestoreStarted = false.obs;

  var backupProgress = 0.0.obs;
  var restoreProgress = 0.0.obs;

  @override
  Future<void> onInit() async {
    super.onInit();

    backupRestoreManager = BackupRestoreManager();
    backupRestoreManager.initialize(
        iCloudContainerID: "iCloud.com.mirrorfly.uikitflutter");

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
    if(!driveAccessible.value){
      toToast("Unable to access drive");
    }else{
      backupRestoreManager.startBackup(isServerUploadRequired: true);
    }
  }

  Future<void> downloadBackup() async {
    if(await AppPermission.getStoragePermission()) {
      isBackupStarted(true);
      backupRestoreManager.startBackup();
    }else {
      toToast("Need Storage Permission for creating the Backup file");
    }
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

  Future<void> restoreLocalBackup() async {
    if(await AppPermission.getStoragePermission()) {
      FilePickerResult? result = await FilePicker.platform
          .pickFiles(allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['txt'],);
      if (result != null) {
        LogMessage.d("Backup Controller",
            "Restore selected file path => ${result.files.single.path}");
        isRestoreStarted(true);
        Mirrorfly.restoreBackup(backupPath: result.files.single.path ?? "");
      } else {
        LogMessage.d("Backup Controller", "Restore file is not Selected");
      }
    }else{
      toToast(getTranslated("backupPermissionDeniedToast"));
    }

  }

  void backUpSuccess(String backUpPath) {
    LogMessage.d(
        "Restore Controller", "Backup Success => $backUpPath");
    isBackupStarted(false);
    toToast(getTranslated("localBackupSuccess"));
  }

  void backUpProgress(event) {
    LogMessage.d(
        "Restore Controller", "backUp Progress => $event");
    backupProgress(int.parse(event.toString()) / 100);
  }

  void backUpFailed(event) {
    isBackupStarted(false);
    toToast(event);
  }

  void restoreBackupProgress(event) {
    LogMessage.d(
        "Restore Controller", "restore Progress => $event");
    restoreProgress(int.parse(event.toString()) / 100);
  }

  void restoreFailed(event) {
    isRestoreStarted(false);
    toToast(event);
  }

  void restoreSuccess(event) {
    LogMessage.d(
        "Restore Controller", "Restore Success => $event");
    isRestoreStarted(false);
    toToast(getTranslated("localRestoreSuccess"));
  }

}