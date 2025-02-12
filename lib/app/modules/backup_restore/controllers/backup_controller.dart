import 'dart:io';

import 'package:file_picker/file_picker.dart';
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
import '../backup_utils/backup_restore_manager.dart';
import '../backup_utils/backup_utils.dart';

class BackupController extends GetxController {
  bool get isAndroid => Platform.isAndroid;

  var driveAccessible = false.obs;

  var mobileNumber = '';

  var isAutoBackupEnabled = false.obs;
  var isAutoBackupFeatureEnabled = false;

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
  var isRemoteUploadStarted = false.obs;
  var isRestoreStarted = false.obs;

  var localBackupProgress = 0.0.obs;
  var remoteBackupProgress = 0.0.obs;
  var remoteUploadProgress = 0.0.obs;
  var restoreProgress = 0.0.obs;

  var backupUploadingSize = "0 KB".obs;
  var backupTotalSize = "0 KB".obs;

  var backUpEmailId = ''.obs;

  @override
  Future<void> onInit() async {
    super.onInit();

    backupRestoreManager = BackupRestoreManager.instance;
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
        LogMessage.d("Backup Controller",
            "Sign In to Drive/Console to access the drive");
      }
    });

    var backUpFrequency = SessionManagement.getBackUpFrequency().checkNull();
    debugPrint("backUpFrequency at backup controller $backUpFrequency");
    selectedBackupFrequency(backUpFrequency);
    isAutoBackupEnabled.value = backUpFrequency.isNotEmpty;

    /// Restoring the mail id in Android Backup Screen
    if (Platform.isAndroid) {
      var previousBackupEmail = SessionManagement.getBackUpAccount().isEmpty
          ? (BackupRestoreManager.instance.getGoogleAccountSignedIn?.email).checkNull()
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
  }

  Future<void> checkForBackUpFiles() async {
    await backupRestoreManager.checkBackUpFiles().then((backupFileDetails) {
      LogMessage.d("Restore Controller",
          "Backup file Available => ${backupFileDetails?.toJson()}");
      if (backupFileDetails != null) {
        isBackupFound(backupFileDetails.fileId?.isNotEmpty);
        backUpFoundDate(backupFileDetails.fileCreatedDate);
        backUpFoundSize(backupFileDetails.fileSize);
      }
    });
  }

  resetBackupProgress() {
    localBackupProgress(0);
    remoteBackupProgress(0);
    remoteUploadProgress(0);
    restoreProgress(0);
    backupUploadingSize("0 KB");
    backupTotalSize("0 KB");
  }

  Future<void> initializeBackUp() async {
    resetBackupProgress();
    if (await AppUtils.isNetConnected()) {
      if (!driveAccessible.value) {
        toToast("Unable to access drive");
      } else if (await AppPermission.getStoragePermission()) {
        isRemoteBackupStarted(true);
        showBackupDialog();
        backupRestoreManager.startBackup(isServerUploadRequired: true);
      } else {
        toToast("Storage Permission Needed for backup process");
      }
    } else {
      toToast(getTranslated("noInternetConnection"));
      return;
    }
  }

  Future<void> downloadBackup() async {
    if (await AppUtils.isNetConnected()) {
      if (await AppPermission.getStoragePermission()) {
        isLocalBackupStarted(true);
        backupRestoreManager.startBackup();
      } else {
        toToast("Need Storage Permission for creating the Backup file");
      }
    } else {
      toToast(getTranslated("noInternetConnection"));
      return;
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
    if (Platform.isAndroid && !driveAccessible.value) {
      toToast(getTranslated("autoBackupAndroidError"));
      return;
    }
    if (Platform.isIOS && !driveAccessible.value) {
      toToast(getTranslated("autoBackupIOSError"));
      return;
    }
    isAutoBackupEnabled(isEnabled);
  }

  Future<void> restoreLocalBackup() async {
    if (await AppPermission.getStoragePermission()) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
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
    isRemoteBackupStarted(false);
    toToast(getTranslated("localBackupSuccess"));
  }

  void remoteBackUpFileReady({required String backUpPath}) {
    DialogUtils.hideLoading();

    String backupFilePath = backUpPath.replaceFirst('file://', '');
    File backupFile = File(backupFilePath);
    int totalFileSize = backupFile.lengthSync();

    backupTotalSize(MediaUtils.fileSize(totalFileSize));

    LogMessage.d("Backup Controller", "Upload fileSize*** $totalFileSize");
    isRemoteUploadStarted(true);
    backupRestoreManager
        .uploadBackupFile(filePath: backupFilePath, fileSize: totalFileSize)
        .listen((progress) {
      LogMessage.d("Backup Controller", "Upload Progress*** $progress");
      remoteUploadProgress(progress.toDouble());
      int uploadedBytes = ((progress / 100) * totalFileSize).floor();
      backupUploadingSize(MediaUtils.fileSize(uploadedBytes, 2));
    }, onDone: () {
      isRemoteBackupStarted(false);
      isRemoteUploadStarted(false);
      toToast(Platform.isAndroid
          ? getTranslated("androidRemoteBackupSuccess")
          : getTranslated("iOSRemoteBackupSuccess"));
      checkForBackUpFiles();
      // BackupRestoreManager.instance.completeWorkManagerTask();
    }, onError: (error) {
      isRemoteBackupStarted(false);
      isRemoteUploadStarted(false);
      LogMessage.d("Backup Controller", "Upload Backup File Error => $error");
    });
  }

  void serverUploadSuccess() {
    isRemoteUploadStarted(false);
  }

  void backUpProgress(event) {
    LogMessage.d("Backup Controller", "backUp Progress => $event");
    if (isLocalBackupStarted.value) {
      localBackupProgress(int.parse(event.toString()) / 100);
    } else {
      remoteBackupProgress(int.parse(event.toString()) / 100);
    }
  }

  void backUpFailed(event) {
    DialogUtils.hideLoading();
    isLocalBackupStarted(false);
    isRemoteBackupStarted(false);
    isRemoteUploadStarted(false);
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
    if (backUpEmailId.value.isNotEmpty) {
      DialogUtils.showAlert(
          dialogStyle: AppStyleConfig.dialogStyle,
          message: getTranslated("restoreAndroidAccountSwitch"),
          actions: [
            TextButton(
                style: AppStyleConfig.dialogStyle.buttonStyle,
                onPressed: () {
                  NavUtils.back();
                },
                child: Text(
                  getTranslated("no").toUpperCase(),
                )),
            TextButton(
                style: AppStyleConfig.dialogStyle.buttonStyle,
                onPressed: () {
                  NavUtils.back();
                  _switchAccount();
                },
                child: Text(
                  getTranslated("yes").toUpperCase(),
                ))
          ]);
    } else {
      _switchAccount();
    }
  }

  Future<void> _switchAccount() async {
    var newAccount = await BackupRestoreManager.instance.switchGoogleAccount();
    LogMessage.d("Backup Controller", "New Switched Account => $newAccount");

    backUpEmailId(newAccount?.email ??
        BackupRestoreManager.instance.getGoogleAccountSignedIn?.email);

    if (newAccount?.email != null) {
      SessionManagement.setBackUpAccount(backUpEmailId.value);
      SessionManagement.setBackUpState(Constants.backupAccountSelected);
      checkForBackUpFiles();
    }
  }

  showBackupDialog() {
    showDialog(
      context: NavUtils.currentContext,
      routeSettings: DialogUtils.routeSettings,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.white,
          child: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) {
                return;
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, left: 16.0),
                  child: Text(
                    getTranslated("backingUpMessages"),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(width: 16),
                      Obx(() {
                        return Flexible(
                            child: Text(
                                "${getTranslated("pleaseWaitAMoment")} (${(remoteBackupProgress.value * 100).floor()}%)"));
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      barrierDismissible: false,
    );
  }
}
