import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/utils.dart';

import '../../../app_style_config.dart';
import '../../../common/app_localizations.dart';
import '../../../common/widgets.dart';
import '../../../extensions/extensions.dart';
import '../../settings/views/settings_widgets.dart';
import '../controllers/restore_controller.dart';

class RestoreView extends NavViewStateful<RestoreController> {
  const RestoreView({super.key});

  @override
  RestoreController createController({String? tag}) =>
      Get.put(RestoreController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslated("restoreBackup")),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Obx(() {
                  return !controller.driveAccessible.value &&
                      !controller.isAndroid
                      ? InkWell(
                    onTap: () => controller.showIcloudSetupInstruction(),
                    child: Container(
                      padding: const EdgeInsets.only(
                          left: 15, top: 10, bottom: 10, right: 15),
                      color: Colors.blueAccent,
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 15,
                            child: AppUtils.assetIcon(
                                assetName: backupHistoryIcon,
                                width: 15,
                                height: 15),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Flexible(
                              child: Text(
                                getTranslated("iCloudInstructions"),
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.white),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              )),
                        ],
                      ),
                    ),
                  )
                      : const Offstage();
                }),
                const SizedBox(
                  height: 40,
                ),
                SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 250,
                        child: Obx(() {
                          int visibleIndex1 = controller.currentIndex.value;
                          int visibleIndex2 = (controller.currentIndex.value %
                              controller.backupAnimationIcons.length) +
                              1;
                          int visibleIndex3 = (controller.currentIndex.value %
                              controller.backupAnimationIcons.length) +
                              2;
                          return Stack(
                            children: [
                              for (int i = 1;
                              i <= controller.backupAnimationIcons.length;
                              i++)
                                Positioned(
                                  left: (i * 30),
                                  top: i < 4 ? 90 - (i * 28) : 10 +
                                      ((i - 4) * 25),
                                  child: Opacity(
                                    opacity:
                                    controller.isBackupAnimationRunning.value
                                        ? (i == visibleIndex1 ||
                                        i == visibleIndex2 ||
                                        i == visibleIndex3)
                                        ? 1.0
                                        : 0.0
                                        : 1.0,
                                    child: Image.asset(
                                      controller.backupAnimationIcons[i - 1],
                                      width: 35,
                                      height: 35,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        }),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Row(
                          children: [
                            const Spacer(),
                            SizedBox(
                              width: 70,
                              height: 70,
                              child: FloatingActionButton(
                                onPressed: () {},
                                heroTag: "backupDatabase",
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18)),
                                backgroundColor: backUpDbColor,
                                child: AppUtils.svgIcon(icon: backupDatabase),
                              ),
                            ),
                            const SizedBox(
                              width: 35,
                            ),
                            Container(
                                width: 33,
                                height: 33,
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: backupTimerColor),
                                child: AppUtils.svgIcon(icon: backupTimer)),
                            const SizedBox(
                              width: 35,
                            ),
                            SizedBox(
                              width: 70,
                              height: 70,
                              child: FloatingActionButton(
                                  onPressed: () {},
                                  heroTag: "backupSmartPhone",
                                  backgroundColor: backupPhoneColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18)),
                                  child: AppUtils.svgIcon(
                                      icon: backupSmartPhone)),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 35,
                ),
                controller.isAndroid
                    ? Obx(() {
                  return controller.isAccountSelected.value
                      ? backupFound()
                      : addAccount();
                })
                    : backupFound(),
              ],
            ),
          )),
    );
  }

  Widget addAccount() {
    return Column(
      children: [
        Text(getTranslated("addAccount"),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        const SizedBox(
          height: 15,
        ),
        Padding(
          padding: const EdgeInsets.all(18.0),
          child: Text(
            getTranslated("addAccountDesc"),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        const AppDivider(color: Color(0xffEBEBEB)),
        controller.isAndroid
            ? SettingListItem(
            title: getTranslated("addGoogleAccount"),
            leading: addAccountUser,
            listItemStyle: AppStyleConfig.settingsPageStyle.listItemStyle,
            onTap: () {
              controller.pickAccount();
            })
            : const Offstage(),
        const SizedBox(height: 50),
        ElevatedButton(
          style: AppStyleConfig.loginPageStyle.loginButtonStyle,
          onPressed: () {
            controller.skipBackup();
          },
          child: Text(
            getTranslated("skip"),
          ),
        ),
      ],
    );
  }

  Widget backupFound() {
    return Column(
      children: [
        Obx(() {
          return Text(
              controller.isBackupFound.value
                  ? getTranslated("backupFound")
                  : getTranslated("backupNotFound"),
              style:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 20));
        }),
        const SizedBox(
          height: 15,
        ),
        Obx(() {
          return controller.isBackupFound.value
              ? Text(getTranslated("backupTime"))
              : const Offstage();
        }),
        Obx(() {
          return controller.isBackupFound.value
              ? Text(getTranslated("backupSize"))
              : const Offstage();
        }),
        const SizedBox(
          height: 15,
        ),
        Padding(
          padding: const EdgeInsets.all(18.0),
          child: Text(
            controller.isAndroid
                ? getTranslated("restoreDescAndroid")
                : getTranslated("restoreDescIos"),
            textAlign: TextAlign.center,
          ),
        ),
        controller.isAndroid
            ? ListTile(
          title: Text(getTranslated("googleAccount")),
          subtitle: Text(controller.selectedEmail.value),
          trailing: const Icon(Icons.keyboard_arrow_right_rounded),
          onTap: () => controller.switchAccount(),
        )
            : const Offstage(),
        Obx(() {
          return lockItem(
              title: getTranslated("autoBackup"),
              on: controller.isAutoBackupEnabled.value,
              onToggle: (value) {
                controller.updateAutoBackupOption(value);
              },
              subtitle: '');
        }),
        const SizedBox(height: 5),
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
                    return Text(controller.selectedBackupFrequency.value);
                  }),
                  const SizedBox(width: 10),
                  const Icon(Icons.keyboard_arrow_right_rounded),
                ],
              ),
            ),
          )
              : const Offstage();
        }),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() {
              return ElevatedButton(
                style: AppStyleConfig.loginPageStyle.loginButtonStyle,
                onPressed: controller.isBackupFound.value
                    ? () => controller.startMessageRestore()
                    : () => controller.nextScreen(),
                child: Text(
                  controller.isBackupFound.value
                      ? getTranslated("restore") : getTranslated("next"),
                ),
              );
            }),
            const SizedBox(width: 20),
            ElevatedButton(
              style: AppStyleConfig.loginPageStyle.loginButtonStyle,
              onPressed: () {
                controller.skipBackup();
              },
              child: Text(
                getTranslated("skip"),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
