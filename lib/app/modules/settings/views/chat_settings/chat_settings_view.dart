import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/app_localizations.dart';
import '../../../../modules/settings/views/chat_settings/chat_settings_controller.dart';

import '../../../../common/constants.dart';
import '../../../../common/widgets.dart';
import '../../../../data/utils.dart';
import '../../../../extensions/extensions.dart';
import '../../../../routes/route_settings.dart';
import '../settings_widgets.dart';

class ChatSettingsView extends NavViewStateful<ChatSettingsController> {
  const ChatSettingsView({Key? key}) : super(key: key);

  @override
ChatSettingsController createController({String? tag}) => Get.put(ChatSettingsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslated("chats")),
        automaticallyImplyLeading: true,
      ),
      body: Obx(() {
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                lockItem(title: getTranslated("archiveSetting"),
                    subtitle: getTranslated("archiveSettingDec"),
                    on: controller.archiveEnabled,
                    onToggle: (value) => controller.enableArchive()),
                notificationItem(
                    title: getTranslated("lastSeen"),
                    subtitle: getTranslated("lastSeenDec"),
                    on: controller.lastSeenPreference.value,
                    onTap: () => controller.lastSeenEnableDisable()),
                notificationItem(
                    title: getTranslated("userBusyStatus"),
                    subtitle: getTranslated("userBusyStatusDescription"),
                    on: controller.busyStatusPreference.value,
                    onTap: () => controller.busyStatusEnable()),
                Visibility(
                  visible: controller.busyStatusPreference.value,
                    child: chatListItem(
                     Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(getTranslated("editBusyStatus"),
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
                    rightArrowIcon, () => {NavUtils.toNamed(Routes.busyStatus)},
                    )),
                notificationItem(title: getTranslated("autoDownload"), subtitle: getTranslated("autoDownloadLabel"),on: controller.autoDownloadEnabled, onTap: controller.enableDisableAutoDownload),
                Visibility(
                  visible: controller.autoDownloadEnabled,
                    child: chatListItem(Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(getTranslated("dataUsageSettings"),
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400)),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(getTranslated("dataUsageSettingsLabel"),
                            style: const TextStyle(
                                color: textColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w400)),
                      ),
                    ],
                  ),
                  rightArrowIcon, () => {NavUtils.toNamed(Routes.dataUsageSetting)},
                )),
                /*Commented out, because this feature is NI*/
                /* notificationItem(title: getTranslated("googleTranslationLabel"), subtitle: getTranslated("googleTranslationMessage"),on: controller.translationEnabled, onTap: controller.enableDisableTranslate),
                Visibility(
                    visible: controller.translationEnabled,
                    child: chatListItem(Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(getTranslated("googleTranslationLanguageLable"),
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
                        Text(getTranslated("googleTranslationLanguageDoubleTap"),
                            style: const TextStyle(
                                color: textColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w400))
                      ],
                    ), rightArrowIcon, () => controller.chooseLanguage())),*/

                ListItem(
                    title: Text(getTranslated("clearAllConversation"),
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
          ),
        );
      }),
    );
  }
}
