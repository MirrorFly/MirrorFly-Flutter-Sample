import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
        title: const Text('Settings'),
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            settingListItem("Profile", profileIcon, rightArrowIcon,
                    () =>
                    Get.toNamed(
                        Routes.profile, arguments: {"from": Routes.settings})),
            settingListItem("Chats", chatIcon, rightArrowIcon, () {
              Get.toNamed(Routes.chatSettings);
            }),
            settingListItem(
                "Starred Messages", staredMsgIcon, rightArrowIcon, () {
              Get.toNamed(Routes.starredMessages);
            }),
            settingListItem(
                "Notifications", notificationIcon, rightArrowIcon, () =>
                Get.toNamed(Routes.notification)),
            settingListItem(
                "Blocked Contacts", blockedIcon, rightArrowIcon, () =>
                Get.toNamed(Routes.blockedList)),
            settingListItem("App Lock", lockIcon, rightArrowIcon, () =>
                Get.toNamed(Routes.appLock)),
            settingListItem("About and Help", aboutIcon, rightArrowIcon, () =>
                Get.to(const AboutAndHelpView())),
            settingListItem(
                "Connection Label", connectionIcon, toggleOffIcon, () {}),
            settingListItem("Delete My Account", delete, rightArrowIcon, () {
              Get.toNamed(Routes.deleteAccount);
            }),
            settingListItem("Logout", logoutIcon, rightArrowIcon, () {
              Helper.showAlert(
                  message:
                  "Are you sure want to logout from the app?",
                  actions: [
                    TextButton(
                        onPressed: () {
                          Get.back();
                        },
                        child: const Text("NO")),
                    TextButton(
                        onPressed: () {
                          controller.logout();
                        },
                        child: const Text("YES"))
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
