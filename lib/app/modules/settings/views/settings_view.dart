import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/app_localizations.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/modules/settings/controllers/settings_controller.dart';
import 'package:mirror_fly_demo/app/modules/settings/views/settings_widgets.dart';
import 'package:mirror_fly_demo/app/routes/app_pages.dart';

import '../../../common/constants.dart';
import 'about/about_and_help_view.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslated("settings", context)),
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            settingListItem(getTranslated("profile", context), profileIcon, rightArrowIcon,
                    () =>
                    Get.toNamed(
                        Routes.profile, arguments: {"from": Routes.settings})),
            settingListItem(getTranslated("chats", context), chatIcon, rightArrowIcon, () {
              Get.toNamed(Routes.chatSettings);
            }),
            settingListItem(
                getTranslated("starredMessages", context), staredMsgIcon, rightArrowIcon, () {
              Get.toNamed(Routes.starredMessages);
            }),
            settingListItem(
                getTranslated("notifications", context), notificationIcon, rightArrowIcon, () =>
                Get.toNamed(Routes.notification)),
            settingListItem(
                getTranslated("blockedContacts", context), blockedIcon, rightArrowIcon, () =>
                Get.toNamed(Routes.blockedList)),
            settingListItem(getTranslated("appLock", context), lockIcon, rightArrowIcon, () =>
                Get.toNamed(Routes.appLock)),
            settingListItem(getTranslated("aboutAndHelp", context), aboutIcon, rightArrowIcon, () =>
                Get.to(const AboutAndHelpView())),
            settingListItem(
                getTranslated("connectionLabel", context), connectionIcon, toggleOffIcon, () {}),
            settingListItem(getTranslated("deleteMyAccount", context), delete, rightArrowIcon, () {
              Get.toNamed(Routes.deleteAccount);
            }),
            settingListItem(getTranslated("logout", context), logoutIcon, rightArrowIcon, () {
              Helper.showAlert(
                  message:
                  getTranslated("logoutMessage", context),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: Text(getTranslated("no", context).toUpperCase(),style: const TextStyle(color: buttonBgColor))),
                    TextButton(
                        onPressed: () {
                          controller.logout();
                        },
                        child: Text(getTranslated("yes", context).toUpperCase(),style: const TextStyle(color: buttonBgColor)))
                  ]);
            }),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Obx(() {
                return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(
                            text: "Released On: ",
                            style: const TextStyle(color: textColor),
                            children: [
                              TextSpan(
                                  text: controller.releaseDate.value,
                                  style: const TextStyle(color: textHintColor))
                            ]),
                      ),
                      RichText(
                        text: TextSpan(
                            text: "Version ",
                            style: const TextStyle(color: textColor),
                            children: [
                              TextSpan(
                                  text: controller.version.value,
                                  style: const TextStyle(color: textHintColor))
                            ]),
                      ),
                    ]);
              }),
            )
          ],
        ),
      ),
    );
  }


}
