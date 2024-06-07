import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/app_style_config.dart';
import 'package:mirror_fly_demo/app/common/app_localizations.dart';
import 'package:mirror_fly_demo/app/modules/settings/controllers/settings_controller.dart';
import 'package:mirror_fly_demo/app/modules/settings/views/settings_widgets.dart';

import '../../../common/constants.dart';
import '../../../data/utils.dart';
import '../../../extensions/extensions.dart';
import '../../../routes/route_settings.dart';
import 'about/about_and_help_view.dart';

class SettingsView extends NavView<SettingsController> {
  const SettingsView({Key? key}) : super(key: key);

  @override
  SettingsController createController() {
    return SettingsController();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(appBarTheme: AppStyleConfig.settingsPageStyle.appBarTheme),
      child: Scaffold(
        appBar: AppBar(
          title: Text(getTranslated("settings")),
          automaticallyImplyLeading: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              settingListItem(title:
                getTranslated("profile"), leading: profileIcon, trailing: rightArrowIcon,listItemStyle: AppStyleConfig.settingsPageStyle.listItemStyle,
                      onTap: () =>
                      NavUtils.toNamed(
                          Routes.profile, arguments: {"from": Routes.settings})),
              settingListItem(title:
                getTranslated("chats"), leading: chatIcon, trailing: rightArrowIcon,listItemStyle: AppStyleConfig.settingsPageStyle.listItemStyle, onTap: () {
                NavUtils.toNamed(Routes.chatSettings);
              }),
              settingListItem(title:
                getTranslated("starredMessages"), leading: staredMsgIcon, trailing: rightArrowIcon,listItemStyle: AppStyleConfig.settingsPageStyle.listItemStyle, onTap: () {
                NavUtils.toNamed(Routes.starredMessages);
              }),
              settingListItem(title:
                  getTranslated("notifications"), leading: notificationIcon, trailing: rightArrowIcon,listItemStyle: AppStyleConfig.settingsPageStyle.listItemStyle, onTap: () =>
                  NavUtils.toNamed(Routes.notification)),
              settingListItem(title:
                  getTranslated("blockedContacts"), leading: blockedIcon, trailing: rightArrowIcon,listItemStyle: AppStyleConfig.settingsPageStyle.listItemStyle, onTap: () =>
                  NavUtils.toNamed(Routes.blockedList)),
              settingListItem(title:
                  getTranslated("appLock"), leading: lockIcon, trailing: rightArrowIcon,listItemStyle: AppStyleConfig.settingsPageStyle.listItemStyle, onTap: () =>
                  NavUtils.toNamed(Routes.appLock)),
              settingListItem(title:
                  getTranslated("aboutAndHelp"),leading:  aboutIcon, trailing: rightArrowIcon,listItemStyle: AppStyleConfig.settingsPageStyle.listItemStyle, onTap: () =>
                  NavUtils.to(const AboutAndHelpView())),
              settingListItem(title:
                  getTranslated("connectionLabel"), leading: connectionIcon, trailing: toggleOffIcon,listItemStyle: AppStyleConfig.settingsPageStyle.listItemStyle, onTap: () {}),
              settingListItem(title:
                  getTranslated("deleteMyAccount"), leading: delete, trailing: rightArrowIcon,listItemStyle: AppStyleConfig.settingsPageStyle.listItemStyle, onTap: () {
                NavUtils.toNamed(Routes.deleteAccount);
              }),
              settingListItem(title:
                  getTranslated("logout"), leading: logoutIcon, trailing: rightArrowIcon,listItemStyle: AppStyleConfig.settingsPageStyle.listItemStyle, onTap: () {
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
      ),
    );
  }


}
