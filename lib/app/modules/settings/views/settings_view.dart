import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/app_localizations.dart';
import 'package:mirror_fly_demo/app/modules/settings/controllers/settings_controller.dart';
import 'package:mirror_fly_demo/app/modules/settings/views/settings_widgets.dart';
import '../../../data/utils.dart';
import '../../../routes/route_settings.dart';

import '../../../common/constants.dart';
import 'about/about_and_help_view.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslated("settings")),
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            settingListItem(getTranslated("profile"), profileIcon, rightArrowIcon,
                    () =>
                    NavUtils.toNamed(
                        Routes.profile, arguments: {"from": Routes.settings})),
            settingListItem(getTranslated("chats"), chatIcon, rightArrowIcon, () {
              NavUtils.toNamed(Routes.chatSettings);
            }),
            settingListItem(
                getTranslated("starredMessages"), staredMsgIcon, rightArrowIcon, () {
              NavUtils.toNamed(Routes.starredMessages);
            }),
            settingListItem(
                getTranslated("notifications"), notificationIcon, rightArrowIcon, () =>
                NavUtils.toNamed(Routes.notification)),
            settingListItem(
                getTranslated("blockedContacts"), blockedIcon, rightArrowIcon, () =>
                NavUtils.toNamed(Routes.blockedList)),
            settingListItem(getTranslated("appLock"), lockIcon, rightArrowIcon, () =>
                NavUtils.toNamed(Routes.appLock)),
            settingListItem(getTranslated("aboutAndHelp"), aboutIcon, rightArrowIcon, () =>
                Get.to(const AboutAndHelpView())),
            settingListItem(
                getTranslated("connectionLabel"), connectionIcon, toggleOffIcon, () {}),
            settingListItem(getTranslated("deleteMyAccount"), delete, rightArrowIcon, () {
              NavUtils.toNamed(Routes.deleteAccount);
            }),
            settingListItem(getTranslated("logout"), logoutIcon, rightArrowIcon, () {
              DialogUtils.showAlert(
                  message:
                  getTranslated("logoutMessage"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          NavUtils.back();
                        },
                        child: Text(getTranslated("no").toUpperCase(),style: const TextStyle(color: buttonBgColor))),
                    TextButton(
                        onPressed: () {
                          controller.logout();
                        },
                        child: Text(getTranslated("yes").toUpperCase(),style: const TextStyle(color: buttonBgColor)))
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
