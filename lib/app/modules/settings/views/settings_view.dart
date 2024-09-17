import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app_style_config.dart';
import '../../../common/app_localizations.dart';
import '../../../modules/settings/controllers/settings_controller.dart';
import '../../../modules/settings/views/settings_widgets.dart';

import '../../../common/constants.dart';
import '../../../data/utils.dart';
import '../../../extensions/extensions.dart';
import '../../../routes/route_settings.dart';
import 'about/about_and_help_view.dart';

class SettingsView extends NavView<SettingsController> {
  const SettingsView({Key? key}) : super(key: key);

  @override
  SettingsController createController({String? tag}) => SettingsController();

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(appBarTheme: AppStyleConfig.settingsPageStyle.appBarTheme),
      child: Scaffold(
        appBar: AppBar(
          title: Text(getTranslated("settings")),
          automaticallyImplyLeading: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SettingListItem(title:
                getTranslated("profile"), leading: profileIcon, trailing: rightArrowIcon,listItemStyle: AppStyleConfig.settingsPageStyle.listItemStyle,
                      onTap: () =>
                      NavUtils.toNamed(
                          Routes.profile, arguments: {"from": Routes.settings})),
              SettingListItem(title:
                getTranslated("chats"), leading: chatIcon, trailing: rightArrowIcon,listItemStyle: AppStyleConfig.settingsPageStyle.listItemStyle, onTap: () {
                NavUtils.toNamed(Routes.chatSettings);
              }),
              SettingListItem(title:
                getTranslated("starredMessages"), leading: staredMsgIcon, trailing: rightArrowIcon,listItemStyle: AppStyleConfig.settingsPageStyle.listItemStyle, onTap: () {
                NavUtils.toNamed(Routes.starredMessages);
              }),
              SettingListItem(title:
                  getTranslated("notifications"), leading: notificationIcon, trailing: rightArrowIcon,listItemStyle: AppStyleConfig.settingsPageStyle.listItemStyle, onTap: () =>
                  NavUtils.toNamed(Routes.notification)),
              SettingListItem(title:
                  getTranslated("blockedContacts"), leading: blockedIcon, trailing: rightArrowIcon,listItemStyle: AppStyleConfig.settingsPageStyle.listItemStyle, onTap: () =>
                  NavUtils.toNamed(Routes.blockedList)),
              SettingListItem(title:
                  getTranslated("appLock"), leading: lockIcon, trailing: rightArrowIcon,listItemStyle: AppStyleConfig.settingsPageStyle.listItemStyle, onTap: () =>
                  NavUtils.toNamed(Routes.appLock)),
              SettingListItem(title:
                  getTranslated("aboutAndHelp"),leading:  aboutIcon, trailing: rightArrowIcon,listItemStyle: AppStyleConfig.settingsPageStyle.listItemStyle, onTap: () =>
                  NavUtils.to(const AboutAndHelpView())),
              /*Commented out, because this feature is NA*/
              // SettingListItem(title:
              //     getTranslated("connectionLabel"), leading: connectionIcon, trailing: toggleOffIcon,listItemStyle: AppStyleConfig.settingsPageStyle.listItemStyle, onTap: () {}),
              SettingListItem(title:
                  getTranslated("deleteMyAccount"), leading: delete, trailing: rightArrowIcon,listItemStyle: AppStyleConfig.settingsPageStyle.listItemStyle, onTap: () {
                NavUtils.toNamed(Routes.deleteAccount);
              }),
              SettingListItem(title:
                  getTranslated("logout"), leading: logoutIcon, trailing: rightArrowIcon,listItemStyle: AppStyleConfig.settingsPageStyle.listItemStyle, onTap: () {
                DialogUtils.showAlert(dialogStyle: AppStyleConfig.dialogStyle,
                    message:
                    getTranslated("logoutMessage"),
                    actions: [
                      TextButton(style: AppStyleConfig.dialogStyle.buttonStyle,
                          onPressed: () {
                            NavUtils.back();
                          },
                          child: Text(getTranslated("no").toUpperCase(), )),
                      TextButton(style: AppStyleConfig.dialogStyle.buttonStyle,
                          onPressed: () {
                            NavUtils.back();
                            controller.logout();
                          },
                          child: Text(getTranslated("yes").toUpperCase(), ))
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
