import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/modules/settings/controllers/settings_controller.dart';
import 'package:mirror_fly_demo/app/routes/app_pages.dart';

import '../../../common/constants.dart';
import '../../../common/widgets.dart';
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
            settingListItem("Profile", profileicon, rightarrowicon,
                () => Get.toNamed(Routes.PROFILE,arguments: {"from":Routes.SETTINGS})),
            settingListItem("Chats", chaticon, rightarrowicon, () {}),
            settingListItem(
                "Starred Messages", staredmsgicon, rightarrowicon, () {
                  Get.toNamed(Routes.STARRED_MESSAGES);
            }),
            settingListItem(
                "Notifications", notificationicon, rightarrowicon, ()=>Get.toNamed(Routes.NOTIFICATION)),
            settingListItem(
                "Blocked Contacts", blockedicon, rightarrowicon, ()=>Get.toNamed(Routes.BLOCKEDLIST)),
            settingListItem("App Lock", lockicon, rightarrowicon, ()=>Get.toNamed(Routes.APPLOCK)),
            settingListItem("About and Help", abouticon, rightarrowicon, () =>Get.to(const AboutAndHelpView())),
            settingListItem(
                "Connection Label", connectionicon, toggleofficon, () {}),
            settingListItem("Delete My Account", delete, rightarrowicon, () {
              Get.toNamed(Routes.DELETE_ACCOUNT);
            }),
            settingListItem("Logout", logouticon, rightarrowicon, () {
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
                          Get.back();
                          controller.logout();
                        },
                        child: const Text("YES"))
                  ]);
            }),
        Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                      text: const TextSpan(
                          text: "Released On: ",
                          style: TextStyle(color: textcolor),
                          children: [
                            TextSpan(
                                text: "Nov 2022",
                                style: TextStyle(color: texthintcolor))
                          ]),
                    ),
                    RichText(
                        text: TextSpan(
                            text: "Version ",
                            style: const TextStyle(color: textcolor),
                            children: [
                              TextSpan(
                                  text: controller.packageInfo != null
                                      ? controller.packageInfo!.version
                                      : "",
                                  style: const TextStyle(color: texthintcolor))
                            ]),
                      ),
                  ]),
            )
          ],
        ),
      ),
    );
  }

  Widget settingListItem(
      String title, String leading, String trailing, Function() onTap) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: SvgPicture.asset(leading),
              ),
              Expanded(
                  child: Text(
                title,
                style: const TextStyle(
                    fontSize: 15.0,
                    fontFamily: 'sf_ui',
                    fontWeight: FontWeight.w400),
              )),
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: SvgPicture.asset(trailing),
              ),
            ],
          ),
        ),
        const AppDivider(),
      ],
    );
  }
}
