import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mirror_fly_demo/app/common/app_localizations.dart';
import 'package:mirror_fly_demo/app/extensions/extensions.dart';
import 'package:mirror_fly_demo/app/modules/backup_restore/backup_restore_manager.dart';
import 'package:mirrorfly_plugin/logmessage.dart';

import '../../../common/constants.dart';
import '../../../data/session_management.dart';
import '../../../data/utils.dart';
import '../../../routes/route_settings.dart';
import '../backup_utils.dart';
import '../icloud_instruction_view.dart';

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
  Future<void> onInit() async {
    super.onInit();

    fetchingBackupDetails(true);

    LogMessage.d(
        "Restore Controller", " => onInit Method called");

    var previousBackupEmail = SessionManagement.getBackUpAccount().isEmpty ? (BackupRestoreManager().getGoogleAccountSignedIn?.email).checkNull() : SessionManagement.getBackUpAccount();

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

    initialiseBackUpProcess();

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
    SessionManagement.setBackUpState(Constants.backupSkipped);
    // if (BackupRestoreManager().getGoogleAccountSignedIn?.email != null) {
    //   SessionManagement.setBackUpAccount((BackupRestoreManager().getGoogleAccountSignedIn?.email).checkNull());
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
    await BackupRestoreManager().checkBackUpFiles().then((backupFileDetails) {
      LogMessage.d(
          "Restore Controller", "Backup file Available => ${backupFileDetails?.toJson()}");
      if(backupFileDetails != null) {
        isBackupFound(backupFileDetails.fileId?.isNotEmpty);
        backupFile(backupFileDetails);
        fetchingBackupDetails(false);
      }
    });
  }

  void startMessageRestore() {
    backupDownloadStarted(true);
    isBackupAnimationRunning(true);
    if(animationController != null) {
      animationController?.forward();
    }

    if (Platform.isAndroid) {
      BackupRestoreManager().downloadAndroidBackupFile(backupFile.value).listen((progress){
        LogMessage.d(
            "Restore Controller", "Backup file Download Progress=> $progress");
        remoteDownloadProgress((progress / 100));
        // backupDownloadStarted(false);
      }, onDone: () {
        String backUpPath = BackupRestoreManager().remoteBackupPath;
        backupDownloadStarted(false);
        backupRestoreStarted(true);
        BackupRestoreManager().restoreBackup(backupFilePath: backUpPath);
      }, onError: (error) {
        LogMessage.d(
            "Restore Controller", "Backup file Download Failed=> $error");
        backupDownloadStarted(false);
        backupRestoreStarted(false);
      });

    } else {
      if (backupFile.value.iCloudRelativePath != null) {
        BackupRestoreManager().startIcloudFileDownload(
            relativePath: backupFile.value.iCloudRelativePath ?? '');
      }else{
        LogMessage.d(
            "Restore Controller", "Backup file Download => Backup file relative path is not found ==> ${backupFile.toJson()}");
      }
    }
  }

  void showIcloudSetupInstruction() {
    showModalBottomSheet(
      context: NavUtils.currentContext,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return const IcloudInstructionView();
      },
    );
  }

  showBackupFrequency() async {
    selectedBackupFrequency(await backupUtils.showBackupOptionList(selectedValue: selectedBackupFrequency.value, listValue: backupFrequency));
  }

  Future<void> pickAccount() async {

    var accounts = await BackupRestoreManager().selectGoogleAccount();
    LogMessage.d(
        "Restore Controller", "pick Account => $accounts");
    if (accounts != null) {
      /*backUpEmailId(accounts.email);
      isAccountSelected(true);
      if (BackupRestoreManager().isDriveApiInitialized) {
        checkForBackUpFiles();
      }else{
        BackupRestoreManager().assignAccountAuth(accounts).then((isSuccess) {
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
    var newAccount = await BackupRestoreManager().switchGoogleAccount();
    LogMessage.d(
        "Restore Controller", "New Switched Account => $newAccount");

    backUpEmailId(newAccount?.email ?? BackupRestoreManager().getGoogleAccountSignedIn?.email);

  }

  void checkCloudAccess() {
    BackupRestoreManager().checkDriveAccess().then((isDriveAccessible) {
      LogMessage.d(
          "Restore Controller",
          "Drive Access Status => $isDriveAccessible");
      driveAccessible(isDriveAccessible);

      if (Platform.isAndroid) {
        GoogleSignInAccount? googleSignInAccount = BackupRestoreManager()
            .getGoogleAccountSignedIn;
        if (googleSignInAccount != null) {
          isAccountSelected(true);
          backUpEmailId(googleSignInAccount.email);
        } else {
          isAccountSelected(false);
        }
      }
      checkForBackUpFiles();
    });
  }

  void initialiseBackUpProcess() {
    BackupRestoreManager().initialize(
        iCloudContainerID: "iCloud.com.mirrorfly.uikitflutter").then((isSuccess) {
      if (isSuccess) {
        checkCloudAccess();
      }else {
        LogMessage.d(
            "Restore Controller", "Sign In to Drive to access the drive");
      }
    });
  }

  void restoreBackupProgress(progress) {
    LogMessage.d(
        "Restore Controller", "Restore Progress $progress");
    remoteRestoreProgress(double.parse(progress.toString()));
  }

  void restoreSuccess(event) {
    // backupRestoreStarted(false);
    if(animationController != null){
      animationController?.stop();
      currentIndex(0);
    }
    remoteRestoreProgress(100);
    toToast(getTranslated("localRestoreSuccess"));
    restoreCompleted(true);
  }

  void restoreFailed(event) {
    backupRestoreStarted(false);
    toToast(event);
  }

}

