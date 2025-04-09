import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mirror_fly_demo/app/common/app_localizations.dart';
import 'package:mirror_fly_demo/app/extensions/extensions.dart';
import 'package:mirror_fly_demo/app/modules/backup_restore/backup_utils/backup_restore_manager.dart';
import 'package:mirrorfly_plugin/logmessage.dart';

import '../../../app_style_config.dart';
import '../../../common/constants.dart';
import '../../../data/permissions.dart';
import '../../../data/session_management.dart';
import '../../../data/utils.dart';
import '../../../routes/route_settings.dart';
import '../backup_utils/backup_utils.dart';

class RestoreController extends GetxController
    with GetSingleTickerProviderStateMixin {
  AnimationController? animationController;

  var currentIndex = 1.obs;

  final List<String> backupAnimationIcons = [
    backupAnimation1,
    backupAnimation2,
    backupAnimation3,
    backupAnimation4,
    backupAnimation5,
    backupAnimation6,
  ];


  var selectedBackupFrequency = "Monthly".obs;

  var isAccountSelected = false.obs;
  var backUpEmailId = ''.obs;
  bool get isAndroid => Platform.isAndroid;
  bool get isIOS => Platform.isIOS;

  var driveAccessible = false.obs;

  var from = NavUtils.previousRoute;
  var mobileNumber = '';

  var isAutoBackupEnabled = false.obs;

  var isAutoBackupFeatureEnabled = false;

  var isBackupFound = false.obs;
  Rx<BackupFile> backupFile = BackupFile().obs;
  var isBackupAnimationRunning = false.obs;

  final List<String> backupFrequency = ["Daily", "Weekly", "Monthly"];

  final backupUtils = BackupUtils();

  var fetchingBackupDetails = false.obs;
  var backupRestoreStarted = false.obs;
  var backupDownloadStarted = false.obs;
  var restoreCompleted = false.obs;

  var remoteDownloadProgress = 0.0.obs;
  var remoteRestoreProgress = 0.0.obs;

  @override
  void onInit() {
    super.onInit();

    fetchingBackupDetails(true);

    LogMessage.d(
        "Restore Controller", " => onInit Method called");

    var previousBackupEmail = SessionManagement.getBackUpAccount().isEmpty ? (BackupRestoreManager.instance.getGoogleAccountSignedIn?.email).checkNull() : SessionManagement.getBackUpAccount();

    if (previousBackupEmail.isNotEmpty){
      isAccountSelected(true);
      backUpEmailId(previousBackupEmail);
    }

    if (NavUtils.previousRoute.isEmpty) {
      from = Routes.login;
    }

    if (NavUtils.arguments != null) {
      if (from == Routes.login) {
        mobileNumber =
            NavUtils.arguments['mobile'] ?? SessionManagement.getMobileNumber();
      }
    } else {
      mobileNumber = "";
    }


    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 230),
    );
    animationController?.addListener(() async {
      if (animationController?.status == AnimationStatus.completed) {
        /*if (currentIndex.value == 6) {
          await Future.delayed(const Duration(seconds: 1));
        }*/
        currentIndex.value =
            (currentIndex.value % backupAnimationIcons.length) + 1;
        animationController?.reset();
        animationController?.forward();
      }
    });
  }

  @override
  void onReady() {
    super.onReady();
    initialiseBackUpProcess();
  }

  @override
  void onClose() {
    if(animationController != null){
    animationController?.dispose();
    }
    super.onClose();
  }

  void skipBackup() {
    if(animationController != null){
      animationController?.stop();
    }

    if (backupDownloadStarted.value) {
      BackupRestoreManager.instance.cancelDownload();
      backupDownloadStarted(false);
      LogMessage.d("Restore Controller", "Backup Download cancelled while skip");
    } else if (backupRestoreStarted.value) {
      BackupRestoreManager.instance.cancelRestore();
      backupRestoreStarted(false);
      LogMessage.d("Restore Controller", "Backup Restore cancelled while skip");
    } else {
      LogMessage.d(
          "Restore Controller", "No backup restore initiated while skip");
    }

    SessionManagement.setBackUpState(Constants.backupSkipped);
    // if (BackupRestoreManager.instance.getGoogleAccountSignedIn?.email != null) {
    //   SessionManagement.setBackUpAccount((BackupRestoreManager.instance.getGoogleAccountSignedIn?.email).checkNull());
    // }
    NavUtils.offAllNamed(Routes.profile, arguments: {"mobile": mobileNumber});
  }

  void nextScreen() {
    if(animationController != null){
      animationController?.stop();
    }
    SessionManagement.setBackUpAccount(backUpEmailId.value);
    SessionManagement.setBackUpState(Constants.backupAccountSelected);
    SessionManagement.setBackUpFrequency(selectedBackupFrequency.value);
    NavUtils.offAllNamed(Routes.profile, arguments: {"mobile": mobileNumber});
  }

  void updateAutoBackupOption(bool isEnabled) {
    LogMessage.d("Restore Controller", "Auto Backup Toggle => $isEnabled");
    if (Platform.isAndroid && backUpEmailId.value == ''){
      toToast(getTranslated("autoBackupAndroidError"));
      return;
    }
    if (Platform.isIOS && !driveAccessible.value){
      toToast(getTranslated("autoBackupIOSError"));
      return;
    }
    isAutoBackupEnabled(isEnabled);
  }

  Future<void> checkForBackUpFiles() async {
    fetchingBackupDetails(true);
    await BackupRestoreManager.instance.checkBackUpFiles().then((backupFileDetails) {
      LogMessage.d(
          "Restore Controller", "Backup file Available => ${backupFileDetails?.toJson()}");
      if(backupFileDetails != null) {
        isBackupFound(backupFileDetails.fileId?.isNotEmpty);
        backupFile(backupFileDetails);
        fetchingBackupDetails(false);
      }
      DialogUtils.hideLoading();
    }).catchError((onError){
      DialogUtils.hideLoading();
    });
  }

  Future<void> startMessageRestore() async {
    if (!await AppUtils.isNetConnected()) {
      toToast(getTranslated("noInternetConnection"));
      return;
    }
    if (Platform.isAndroid) {
      var permission = await AppPermission.getStoragePermission();
      if (permission) {
        backupDownloadStarted(true);
        isBackupAnimationRunning(true);
        if(animationController != null) {
          animationController?.forward();
        }
        BackupRestoreManager.instance.downloadAndroidBackupFile(
            backupFile.value).listen((progress) {
          LogMessage.d(
              "Restore Controller",
              "Backup file Download Progress=> $progress");
          remoteDownloadProgress((progress / 100));
          // backupDownloadStarted(false);
        }, onDone: () {
          String backUpPath = BackupRestoreManager.instance.remoteBackupPath;
          backupDownloadStarted(false);
          backupRestoreStarted(true);
          BackupRestoreManager.instance.restoreBackup(
              backupFilePath: backUpPath);
        }, onError: (error) {
          LogMessage.d(
              "Restore Controller", "Backup file Download Failed=> $error");
          backupDownloadStarted(false);
          backupRestoreStarted(false);
        });
      }else{
        toToast(getTranslated("backupPermissionDeniedToast"));
      }

    } else {
      if (backupFile.value.iCloudRelativePath != null) {
        backupDownloadStarted(false);
        backupRestoreStarted(true);
        /*BackupRestoreManager.instance.startIcloudFileDownload(
            relativePath: backupFile.value.iCloudRelativePath ?? '').listen((progress){
          remoteDownloadProgress((progress / 100));
        }, onDone: () {
          String backUpPath = BackupRestoreManager.instance.remoteBackupPath;
          LogMessage.d(
              "Restore Controller", "Backup file Downloaded => Restoring the messages==> ${backupFile.toJson()}");
          backupDownloadStarted(false);
          backupRestoreStarted(true);
          BackupRestoreManager.instance.restoreBackup(backupFilePath: backUpPath);
        });*/

        LogMessage.d("Restore Controller", "download backup url: ${backupFile.value.filePath}");
        BackupRestoreManager.instance.restoreBackup(backupFilePath: backupFile.value.filePath ?? "");

        /*BackupRestoreManager.instance.getBackupUrl().then((backupPath){
          LogMessage.d("Restore Controller", "download backup url: $backupPath");
          final fullFilePath = backupPath != null ? "$backupPath/${backupFile.value.iCloudRelativePath}" : '';

          LogMessage.d("Restore Controller", "download full backup url: $fullFilePath");
          BackupRestoreManager.instance.restoreBackup(backupFilePath: fullFilePath);
        });*/

      }else{
        LogMessage.d(
            "Restore Controller", "Backup file Download => Backup file relative path is not found ==> ${backupFile.toJson()}");
        backupDownloadStarted(false);
        backupRestoreStarted(false);
      }
    }
  }

  showBackupFrequency() async {
    selectedBackupFrequency(await backupUtils.showBackupOptionList(selectedValue: selectedBackupFrequency.value, listValue: backupFrequency));
  }

  Future<void> pickAccount() async {

    var accounts = await BackupRestoreManager.instance.selectGoogleAccount();
    LogMessage.d(
        "Restore Controller", "pick Account => $accounts");
    if (accounts != null) {
      /*backUpEmailId(accounts.email);
      isAccountSelected(true);
      if (BackupRestoreManager.instance.isDriveApiInitialized) {
        checkForBackUpFiles();
      }else{
        BackupRestoreManager.instance.assignAccountAuth(accounts).then((isSuccess) {
          checkForBackUpFiles();
        });
      }*/
      initialiseBackUpProcess();
    }else{
      LogMessage.d(
          "Restore Controller", "Account selection cancelled by user");
    }
  }

  switchAccount() async {
    var newAccount = await BackupRestoreManager.instance.switchGoogleAccount();
    LogMessage.d(
        "Restore Controller", "New Switched Account => $newAccount");

    backUpEmailId(newAccount?.email ?? BackupRestoreManager.instance.getGoogleAccountSignedIn?.email);

  }

  Future<void> checkCloudAccess() async {
    await BackupRestoreManager.instance.checkDriveAccess().then((isDriveAccessible) {
      LogMessage.d(
          "Restore Controller",
          "Drive Access Status => $isDriveAccessible");
      driveAccessible(isDriveAccessible);

      if (Platform.isAndroid) {
        GoogleSignInAccount? googleSignInAccount = BackupRestoreManager.instance.getGoogleAccountSignedIn;
        if (googleSignInAccount != null) {
          isAccountSelected(true);
          backUpEmailId(googleSignInAccount.email);
        } else {
          isAccountSelected(false);
        }
      }
      checkForBackUpFiles();
    }).catchError((er){
      DialogUtils.hideLoading();
    });
  }

  Future<void> initialiseBackUpProcess() async {
    DialogUtils.showLoading(dialogStyle: AppStyleConfig.dialogStyle);
    await BackupRestoreManager.instance.initialize(
        iCloudContainerID: "iCloud.com.mirrorfly.uikitflutter").then((isSuccess) {
      if (isSuccess) {
        checkCloudAccess();
      }else {
        LogMessage.d(
            "Restore Controller", "Sign In to Drive to access the drive");
        DialogUtils.hideLoading();
      }
    }).catchError((onError){
      LogMessage.d(
          "Restore Controller", "Sign In to Drive to access the drive $onError");
      DialogUtils.hideLoading();
    });
  }

  void restoreBackupProgress(progress) {
    LogMessage.d(
        "Restore Controller", "Restore Progress $progress");
    remoteRestoreProgress(double.parse(progress.toString()));
  }

  void restoreSuccess(event) {
    // backupRestoreStarted(false);
    LogMessage.d(
        "Restore Controller", "Restore Success $event");
    if(animationController != null){
      animationController?.stop();
      currentIndex(0);
    }
    remoteRestoreProgress(100);
    toToast(getTranslated("localRestoreSuccess"));
    restoreCompleted(true);
    // BackupRestoreManager.instance.completeWorkManagerTask();
  }

  void restoreFailed(event) {
    backupRestoreStarted(false);
    toToast(event);
  }

}

