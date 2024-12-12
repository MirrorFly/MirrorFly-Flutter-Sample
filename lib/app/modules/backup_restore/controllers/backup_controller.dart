import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/app_localizations.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/session_management.dart';
import 'package:mirror_fly_demo/app/extensions/extensions.dart';
import 'package:mirrorfly_plugin/flychat.dart';
import 'package:mirrorfly_plugin/logmessage.dart';

import '../../../app_style_config.dart';
import '../../../data/permissions.dart';
import '../../../data/utils.dart';
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

  var isLocalBackupStarted = false.obs;
  var isRemoteBackupStarted = false.obs;
  var isRestoreStarted = false.obs;

  var localBackupProgress = 0.0.obs;
  var remoteBackupProgress = 0.0.obs;
  var restoreProgress = 0.0.obs;

  var backUpEmailId = ''.obs;

  @override
  Future<void> onInit() async {
    super.onInit();

    backupRestoreManager = BackupRestoreManager();
    backupRestoreManager
        .initialize(iCloudContainerID: "iCloud.com.mirrorfly.uikitflutter")
        .then((isSuccess) {
      if (isSuccess) {
        backupRestoreManager.checkDriveAccess().then((isDriveAccessible) {
          LogMessage.d(
              "Backup Controller", "Drive Access Status => $isDriveAccessible");
          driveAccessible(isDriveAccessible);
          checkForBackUpFiles();
        });
      } else {
        LogMessage.d(
            "Backup Controller", "Sign In to Drive/Console to access the drive");
      }
    });

    var backUpFrequency = SessionManagement.getBackUpFrequency().checkNull();
    debugPrint("backUpFrequency at backup controller $backUpFrequency");
    selectedBackupFrequency(backUpFrequency);
    isAutoBackupEnabled.value = backUpFrequency.isNotEmpty;

    var previousBackupEmail = SessionManagement.getBackUpAccount().isEmpty
        ? (BackupRestoreManager().getGoogleAccountSignedIn?.email).checkNull()
        : SessionManagement.getBackUpAccount();

    if (previousBackupEmail.isNotEmpty) {
      // isAccountSelected(true);
      backUpEmailId(previousBackupEmail);
      LogMessage.d(
          "Backup Controller", "Logged In User => $previousBackupEmail");
    } else {
      LogMessage.d("Backup Controller", "Gmail Not Configured");
    }
  }

  Future<void> checkForBackUpFiles() async {
    await backupRestoreManager.checkBackUpFiles().then((backupFileDetails) {
      LogMessage.d(
          "Restore Controller", "Backup file Available => ${backupFileDetails?.toJson()}");
      if(backupFileDetails != null) {
        isBackupFound(backupFileDetails.fileId?.isNotEmpty);
        backUpFoundDate(backupFileDetails.fileCreatedDate);
        backUpFoundSize(backupFileDetails.fileSize);
      }
    });
  }

  Future<void> initializeBackUp() async {
    if (!driveAccessible.value) {
      toToast("Unable to access drive");
    } else if (await AppPermission.getStoragePermission()) {
      isRemoteBackupStarted(true);
      backupRestoreManager.startBackup(isServerUploadRequired: true);
    } else {
      toToast("Storage Permission Needed for backup process");
    }
  }

  Future<void> downloadBackup() async {
    if (await AppPermission.getStoragePermission()) {
      isLocalBackupStarted(true);
      backupRestoreManager.startBackup();
    } else {
      toToast("Need Storage Permission for creating the Backup file");
    }
  }

  showBackupFrequency() async {
    var backUpFrequencyResult = await backupUtils.showBackupOptionList(
        selectedValue: selectedBackupFrequency.value,
        listValue: backupFrequency);
    selectedBackupFrequency(backUpFrequencyResult);
    SessionManagement.setBackUpFrequency(backUpFrequencyResult);
  }

  showBackupNetworkFrequency() async {
    selectedBackupNetworkFrequency(await backupUtils.showBackupOptionList(
        selectedValue: selectedBackupNetworkFrequency.value,
        listValue: networkFrequency));
  }

  void updateAutoBackupOption(bool isEnabled) {
    LogMessage.d("Backup Controller", "Auto Backup Toggle => $isEnabled");
    if (Platform.isAndroid && !driveAccessible.value){
      toToast(getTranslated("autoBackupAndroidError"));
      return;
    }
    if (Platform.isIOS && !driveAccessible.value){
      toToast(getTranslated("autoBackupIOSError"));
      return;
    }
    isAutoBackupEnabled(isEnabled);
  }

  Future<void> restoreLocalBackup() async {
    if (await AppPermission.getStoragePermission()) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['txt'],
      );
      if (result != null) {
        LogMessage.d("Backup Controller",
            "Backup selected file path => ${result.files.single.path}");
        isRestoreStarted(true);
        Mirrorfly.restoreBackup(backupPath: result.files.single.path ?? "");
      } else {
        LogMessage.d("Backup Controller", "Restore file is not Selected");
      }
    } else {
      toToast(getTranslated("backupPermissionDeniedToast"));
    }
  }

  void backUpSuccess(String backUpPath) {
    LogMessage.d("Backup Controller", "Backup Success => $backUpPath");
    isLocalBackupStarted(false);
    toToast(getTranslated("localBackupSuccess"));
  }

  void backUpProgress(event) {
    LogMessage.d("Backup Controller", "backUp Progress => $event");
    if(isLocalBackupStarted.value) {
      localBackupProgress(int.parse(event.toString()) / 100);
    }else{
      remoteBackupProgress(int.parse(event.toString()) / 100);
    }
  }

  void backUpFailed(event) {
    isLocalBackupStarted(false);
    isRemoteBackupStarted(false);
    toToast(event);
  }

  void restoreBackupProgress(event) {
    LogMessage.d("Backup Controller", "restore Progress => $event");
    restoreProgress(int.parse(event.toString()) / 100);
  }

  void restoreFailed(event) {
    isRestoreStarted(false);
    toToast(event);
  }

  void restoreSuccess(event) {
    LogMessage.d("Backup Controller", "Restore Success => $event");
    isRestoreStarted(false);
    toToast(getTranslated("localRestoreSuccess"));
  }

  void handleGoogleAccount() {
    if (backUpEmailId.value.isNotEmpty){
      DialogUtils.showAlert(dialogStyle: AppStyleConfig.dialogStyle,
          message:
          getTranslated("restoreAndroidAccountSwitch"),
          actions: [
            TextButton(style: AppStyleConfig.dialogStyle.buttonStyle,
                onPressed: () {
                  NavUtils.back();
                },
                child: Text(getTranslated("no").toUpperCase(), )),
            TextButton(style: AppStyleConfig.dialogStyle.buttonStyle,
                onPressed: () {
                  NavUtils.back();
                  _switchAccount();
                },
                child: Text(getTranslated("yes").toUpperCase(), ))
          ]);
    }else{
      _switchAccount();
    }

  }

  Future<void> _switchAccount() async {
    var newAccount = await BackupRestoreManager().switchGoogleAccount();
    LogMessage.d("Backup Controller", "New Switched Account => $newAccount");

    backUpEmailId(newAccount?.email ??
        BackupRestoreManager().getGoogleAccountSignedIn?.email);

    if (newAccount?.email != null) {
      SessionManagement.setBackUpAccount(backUpEmailId.value);
      SessionManagement.setBackUpState(Constants.backupAccountSelected);
    }
  }
}
