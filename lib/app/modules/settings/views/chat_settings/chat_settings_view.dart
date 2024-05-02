import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/modules/settings/views/chat_settings/chat_settings_controller.dart';

import '../../../../common/constants.dart';
import '../../../../common/widgets.dart';
import '../../../../routes/route_settings.dart';
import '../settings_widgets.dart';

class ChatSettingsView extends GetView<ChatSettingsController> {
  const ChatSettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        automaticallyImplyLeading: true,
      ),
      body: Obx(() {
        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              lockItem(title: "Archive Settings",
                  subtitle: "Archived chats will remain archived when you receive a new message",
                  on: controller.archiveEnabled,
                  onToggle: (value) => controller.enableArchive()),
              notificationItem(
                  title: "Last Seen",
                  subtitle: "Hiding the last seen activity to other users",
                  on: controller.lastSeenPreference.value,
                  onTap: () => controller.lastSeenEnableDisable()),
              notificationItem(
                  title: "User Busy Status",
                  subtitle: "Set busy status as the Auto response to the message received from the individuals",
                  on: controller.busyStatusPreference.value,
                  onTap: () => controller.busyStatusEnable()),
              Visibility(
                visible: controller.busyStatusPreference.value,
                  child: chatListItem(
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Edit Busy Status Message',
                          style: TextStyle(
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
              notificationItem(title: Constants.autoDownload, subtitle: Constants.autoDownloadLable,on: controller.autoDownloadEnabled, onTap: controller.enableDisableAutoDownload),
              Visibility(
                visible: controller.autoDownloadEnabled,
                  child: chatListItem(
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(Constants.dataUsageSettings,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400)),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(Constants.dataUsageSettingsLable,
                          style: TextStyle(
                              color: textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w400)),
                    ),
                  ],
                ),
                rightArrowIcon, () => {Get.toNamed(Routes.dataUsageSetting)},
              )),
              notificationItem(title: Constants.googleTranslationLabel, subtitle: Constants.googleTranslationMessage,on: controller.translationEnabled, onTap: controller.enableDisableTranslate),
              Visibility(
                  visible: controller.translationEnabled,
                  child: chatListItem(Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(Constants.googleTranslationLanguageLable,
                          style: TextStyle(
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
                      const Text(Constants.googleTranslationLanguageDoubleTap,
                          style: TextStyle(
                              color: textColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w400))
                    ],
                  ), rightArrowIcon, () => controller.chooseLanguage())),

              ListItem(
                  title: const Text('Cleat All Conversation',
                      style: TextStyle(
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
