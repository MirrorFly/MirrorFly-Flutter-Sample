import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/app_localizations.dart';
import 'package:mirror_fly_demo/app/modules/settings/views/chat_settings/chat_settings_controller.dart';

import '../../../../common/constants.dart';
import '../../../../common/widgets.dart';
import '../../../../routes/app_pages.dart';
import '../settings_widgets.dart';

class ChatSettingsView extends GetView<ChatSettingsController> {
  const ChatSettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslated("chats", context)),
        automaticallyImplyLeading: true,
      ),
      body: Obx(() {
        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              lockItem(title: getTranslated("archiveSetting", context),
                  subtitle: getTranslated("archiveSettingDec", context),
                  on: controller.archiveEnabled,
                  onToggle: (value) => controller.enableArchive()),
              notificationItem(
                  title: getTranslated("lastSeen", context),
                  subtitle: getTranslated("lastSeenDec", context),
                  on: controller.lastSeenPreference.value,
                  onTap: () => controller.lastSeenEnableDisable()),
              notificationItem(
                  title: getTranslated("userBusyStatus", context),
                  subtitle: getTranslated("userBusyStatusDescription", context),
                  on: controller.busyStatusPreference.value,
                  onTap: () => controller.busyStatusEnable()),
              Visibility(
                visible: controller.busyStatusPreference.value,
                  child: chatListItem(
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(getTranslated("editBusyStatus", context),
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400)),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(controller.busyStatus.value,
                            maxLines: null,
                            style: const TextStyle(
                                color: buttonBgColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w400)),
                      ),
                    ],
                  ),
                  rightArrowIcon, () => {Get.toNamed(Routes.busyStatus)},
                  )),
              notificationItem(title: getTranslated("autoDownload", context), subtitle: getTranslated("autoDownloadLabel", context),on: controller.autoDownloadEnabled, onTap: controller.enableDisableAutoDownload),
              Visibility(
                visible: controller.autoDownloadEnabled,
                  child: chatListItem(Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(getTranslated("dataUsageSettings", context),
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400)),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(getTranslated("dataUsageSettingsLabel", context),
                          style: const TextStyle(
                              color: textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w400)),
                    ),
                  ],
                ),
                rightArrowIcon, () => {Get.toNamed(Routes.dataUsageSetting)},
              )),
              notificationItem(title: getTranslated("googleTranslationLabel", context), subtitle: getTranslated("googleTranslationMessage", context),on: controller.translationEnabled, onTap: controller.enableDisableTranslate),
              Visibility(
                  visible: controller.translationEnabled,
                  child: chatListItem(Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(getTranslated("googleTranslationLanguageLable", context),
                          style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w400)),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(controller.translationLanguage,
                            style: const TextStyle(
                                color: buttonBgColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w400)),
                      ),
                      Text(getTranslated("googleTranslationLanguageDoubleTap", context),
                          style: const TextStyle(
                              color: textColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w400))
                    ],
                  ), rightArrowIcon, () => controller.chooseLanguage())),

              ListItem(
                  title: Text(getTranslated("clearAllConversation", context),
                      style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.w400)),
                  dividerPadding: const EdgeInsets.symmetric(horizontal: 16),
                  onTap: (){
                    controller.clearAllConversation();
                  })
            ],
          ),
        );
      }),
    );
  }
}
