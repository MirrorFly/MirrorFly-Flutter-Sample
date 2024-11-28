import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/app_localizations.dart';
import 'package:mirror_fly_demo/app/modules/backup_restore/backup_restore_manager.dart';
import 'package:mirrorfly_plugin/logmessage.dart';

import '../../../common/constants.dart';
import '../../../data/session_management.dart';
import '../../../data/utils.dart';
import '../../../routes/route_settings.dart';
import '../../settings/views/settings_widgets.dart';

class RestoreController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late AnimationController animationController;

  var currentIndex = 1.obs;

  final List<String> backupAnimationIcons = [
    backupAnimation1,
    backupAnimation2,
    backupAnimation3,
    backupAnimation4,
    backupAnimation5,
    backupAnimation6,
  ];

  final List<String> backupFrequency = ["Daily", "Weekly", "Monthly"];

  var selectedBackupFrequency = "Monthly".obs;

  var isAccountSelected = false.obs;
  bool get isAndroid => Platform.isAndroid;

  var driveAccessible = false.obs;

  var from = NavUtils.previousRoute;
  var mobileNumber = '';

  var isAutoBackupEnabled = false.obs;
  var isBackupFound = false.obs;

  var isBackupAnimationRunning = false.obs;

  @override
  Future<void> onInit() async {
    super.onInit();

    BackupRestoreManager().initialize(
        iCloudContainerID: "iCloud.com.mirrorfly.uikitflutter",
        googleClientId: "");

    await BackupRestoreManager().checkDriveAccess().then((isDriveAccessible) {
      LogMessage.d(
          "Restore Controller", "Drive Access Status => $isDriveAccessible");
      driveAccessible(isDriveAccessible);
      checkForBackUpFiles();
    });

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
    animationController.addListener(() async {
      if (animationController.status == AnimationStatus.completed) {
        /*if (currentIndex.value == 6) {
          await Future.delayed(const Duration(seconds: 1));
        }*/
        currentIndex.value =
            (currentIndex.value % backupAnimationIcons.length) + 1;
        animationController.reset();
        animationController.forward();
      }
    });
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }

  void skipBackup() {
    animationController.stop();
    NavUtils.offAllNamed(Routes.profile, arguments: {"mobile": mobileNumber});
  }

  void updateAutoBackupOption(bool isEnabled) {
    LogMessage.d("Restore Controller", "Auto Backup Toggle => $isEnabled");
    isAutoBackupEnabled(isEnabled);
  }

  Future<void> checkForBackUpFiles() async {
    await BackupRestoreManager().checkBackUpFiles().then((isBackUpAvailable) {
      LogMessage.d(
          "Restore Controller", "Backup file Available => $isBackUpAvailable");
      isBackupFound(isBackUpAvailable);
    });
  }

  void startMessageRestore() {
    isBackupAnimationRunning(true);
    animationController.forward();
  }

  void showBackupFrequency() {
    DialogUtils.createDialog(
      Dialog(
        child: Padding(
          padding:
              const EdgeInsets.only(left: 20.0, top: 20, right: 15, bottom: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                getTranslated("backupScheduleTitle"),
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 15,
              ),
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: backupFrequency.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    var frequencyItem = backupFrequency[index];
                    return Obx(() {
                      return ListTile(
                        contentPadding: const EdgeInsets.only(left: 10),
                        title: Text(frequencyItem,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.normal)),
                        leading: frequencyItem == selectedBackupFrequency.value
                            ? const Icon(
                                Icons.check_circle_rounded,
                                color: Colors.green,
                              )
                            : const SizedBox.shrink(),
                        onTap: () {
                          if (frequencyItem != selectedBackupFrequency.value) {
                            NavUtils.back();
                            debugPrint("selected audio item $frequencyItem");
                            selectedBackupFrequency(frequencyItem);
                          } else {
                            LogMessage.d("routeAudioOption",
                                "clicked on same audio type selected");
                          }
                        },
                      );
                    });
                  }),
              TextButton(
                  onPressed: () {
                    NavUtils.back();
                  },
                  child: Text(getTranslated("cancel")))
            ],
          ),
        ),
      ),
    );
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
}

class IcloudInstructionView extends StatelessWidget {
  const IcloudInstructionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslated("restoreBackup")),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
              onPressed: () => NavUtils.back(),
              child: Text(getTranslated("done")))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              Text(
                getTranslated("iCloudTitleDesc"),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              ListTile(
                leading: AppUtils.assetIcon(
                    assetName: restoreSetting, width: 30, height: 30),
                title: Text(
                  getTranslated("openIphoneSettings"),
                  style: TextStyle(fontSize: 12, color: Color(0xff767676)),
                ),
              ),
              ListTile(
                leading: AppUtils.assetIcon(
                    assetName: restoreCloud, width: 30, height: 30),
                title: Text(getTranslated("iCloudSignInDesc"),
                    style: TextStyle(fontSize: 12, color: Color(0xff767676))),
              ),
              ListTile(
                leading: AppUtils.assetIcon(
                    assetName: restoreCloud, width: 30, height: 30),
                title: Text(getTranslated("iCloudDriveOnDesc"),
                    style: TextStyle(fontSize: 12, color: Color(0xff767676))),
              ),
              ListTile(
                leading: AppUtils.assetIcon(
                    assetName: restoreCloud, width: 30, height: 30),
                title: Text(getTranslated("iCloudDriveMirrorFlyOnDesc"),
                    style: TextStyle(fontSize: 12, color: Color(0xff767676))),
              ),
              const SizedBox(height: 35),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 0.5,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(5),
                  ),
                ),
                child: lockItem(
                    title: getTranslated("appName"),
                    on: true,
                    onToggle: (value) {},
                    subtitle: ''),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
