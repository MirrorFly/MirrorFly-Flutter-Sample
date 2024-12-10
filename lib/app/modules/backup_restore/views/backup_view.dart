import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/modules/backup_restore/controllers/backup_controller.dart';

import '../../../app_style_config.dart';
import '../../../common/app_localizations.dart';
import '../../../common/widgets.dart';
import '../../../extensions/extensions.dart';
import '../../settings/views/settings_widgets.dart';

class BackupView extends NavViewStateful<BackupController> {
  const BackupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslated("chatBackup")),
        centerTitle: true,
      ),
      body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Text(
                    getTranslated("lastBackUp"),
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 18.0, right: 18.0),
                  child: Text(
                    getTranslated("lastBackUpDesc"),
                    style: TextStyle(color: Color(0xff767676)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    children: [
                      Text(getTranslated("lastBackUp"),
                          style: TextStyle(color: Color(0xff767676))),
                      Obx(() {
                        return controller.isBackupFound.value
                            ? Text(
                          controller.backUpFoundDate.value,
                          style: const TextStyle(color: Colors.black),
                        )
                            : const Text("--");
                      })
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 18.0, right: 18.0),
                  child: Row(
                    children: [
                      Text(getTranslated("totalSize"),
                          style: TextStyle(color: Color(0xff767676))),
                      Obx(() {
                        return controller.isBackupFound.value
                            ? Text(controller.backUpFoundSize.value,
                            style: const TextStyle(color: Colors.black))
                            : const Text("--");
                      }),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Center(
                  child: ElevatedButton(
                    style: AppStyleConfig.loginPageStyle.loginButtonStyle,
                    onPressed: () {
                      controller.initializeBackUp();
                    },
                    child: Text(
                      getTranslated("backupNow"),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const AppDivider(color: Color(0xffEBEBEB)),
                Obx(() {
                  return lockItem(
                      title: getTranslated("autoBackup"),
                      on: controller.isAutoBackupEnabled.value,
                      onToggle: (value) {
                        controller.updateAutoBackupOption(value);
                      },
                      subtitle: '');
                }),
                Obx(() {
                  return controller.isAutoBackupEnabled.value
                      ? InkWell(
                    onTap: () => controller.showBackupFrequency(),
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Row(
                        children: [
                          Text(getTranslated("scheduleBackUp")),
                          const Spacer(),
                          Obx(() {
                            return Text(
                                controller.selectedBackupFrequency.value);
                          }),
                          const SizedBox(width: 10),
                          const Icon(Icons.keyboard_arrow_right_rounded),
                        ],
                      ),
                    ),
                  )
                      : const Offstage();
                }),
                const AppDivider(color: Color(0xffEBEBEB)),
                if (controller.isAndroid) ...[
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Text(getTranslated("googleDriveSettings"),
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                  ),
                  Obx(() {
                    return ListTile(
                      title: Text(getTranslated("googleAccount"),
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                      subtitle: Text(controller.backUpEmailId.value.isEmpty
                          ? getTranslated("googleAccountEmail")
                          : controller.backUpEmailId.value,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                          )),
                      trailing: const Icon(Icons.keyboard_arrow_right_rounded),
                      onTap: () => controller.handleGoogleAccount(),
                    );
                  }),
                ],
                const AppDivider(color: Color(0xffEBEBEB)),
                Obx(() {
                  return ListTile(
                    title: Text(getTranslated("backUpOver"),
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        controller.selectedBackupNetworkFrequency.value,
                        style: const TextStyle(
                            color: Colors.black, fontSize: 12)),
                    trailing: const Icon(Icons.keyboard_arrow_right_rounded),
                    onTap: () => controller.showBackupNetworkFrequency(),
                  );
                }),
                const AppDivider(color: Color(0xffEBEBEB)),
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Text(getTranslated("localBackUpRestore"),
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 18.0, right: 18.0),
                  child: Text(getTranslated("localBackupDesc"),
                      style: TextStyle(color: Color(0xff767676))),
                ),
                const SizedBox(
                  height: 30,
                ),
                Obx(() {
                  return controller.isBackupStarted.value ||
                      controller.isRestoreStarted.value
                      ? Padding(
                    padding: const EdgeInsets.only(left: 18.0, right: 10),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                value: controller.isBackupStarted.value
                                    ? controller.backupProgress.value
                                    : controller.restoreProgress.value,
                              ),
                            ),
                            IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {}),
                          ],
                        ),
                        Row(
                          children: [
                            controller.isBackupStarted.value ? Text(
                                getTranslated("backupStatusInfo")) : Text(
                                getTranslated("restoreStatusInfo")),
                            controller.isBackupStarted.value ? Text(
                                "(${(controller.backupProgress.value * 100)
                                    .floor()}%)") : Text(
                                "(${(controller.restoreProgress.value * 100)
                                    .floor()}%)"),
                          ],
                        )
                      ],
                    ),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: AppStyleConfig.loginPageStyle.loginButtonStyle,
                        onPressed: () {
                          controller.downloadBackup();
                        },
                        child: Text(
                          getTranslated("download"),
                        ),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        style: AppStyleConfig.loginPageStyle.loginButtonStyle,
                        onPressed: () {
                          controller.restoreLocalBackup();
                        },
                        child: Text(
                          getTranslated("restore"),
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(
                  height: 50,
                ),
              ],
            ),
          )),
    );
  }

  @override
  BackupController createController({String? tag}) =>
      Get.put(BackupController());
}
