import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/modules/settings/controllers/settings_controller.dart';
import 'package:mirror_fly_demo/app/routes/app_pages.dart';

import '../../../common/constants.dart';
import '../../../common/widgets.dart';

class SettingsView extends GetView<SettingsController> {
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
            SettingListItem("Profile", profileicon, rightarrowicon,
                () => Get.toNamed(Routes.PROFILE,arguments: {"from":Routes.SETTINGS})),
            SettingListItem("Chats", chaticon, rightarrowicon, () {}),
            SettingListItem(
                "Starred Messages", staredmsgicon, rightarrowicon, () {}),
            SettingListItem(
                "Notifications", notificationicon, rightarrowicon, () {}),
            SettingListItem(
                "Blocked Contacts", blockedicon, rightarrowicon, () {}),
            SettingListItem(
                "Archived Chats", archiveicon, rightarrowicon, () {}),
            SettingListItem("App Lock", lockicon, rightarrowicon, () {}),
            SettingListItem("About and Help", abouticon, rightarrowicon, () {}),
            SettingListItem(
                "Connection Label", connectionicon, toggleofficon, () {}),
            SettingListItem("Report Log", reporticon, rightarrowicon, () {}),
            SettingListItem("Logout", logouticon, rightarrowicon, () {
              controller.logout();
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
                                text: "August 28, 2022",
                                style: TextStyle(color: texthintcolor))
                          ]),
                    ),
                    RichText(
                        text: TextSpan(
                            text: "Version ",
                            style: TextStyle(color: textcolor),
                            children: [
                              TextSpan(
                                  text: controller.packageInfo != null
                                      ? controller.packageInfo!.version
                                      : "",
                                  style: TextStyle(color: texthintcolor))
                            ]),
                      ),
                  ]),
            )
          ],
        ),
      ),
    );
  }

  Widget SettingListItem(
      String title, String leading, String trailing, Function() ontap) {
    return Container(
      child: Column(
        children: [
          InkWell(
            onTap: ontap,
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
                      fontWeight: FontWeight.w700),
                )),
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: SvgPicture.asset(trailing),
                ),
              ],
            ),
          ),
          AppDivider(),
        ],
      ),
    );
  }
}
