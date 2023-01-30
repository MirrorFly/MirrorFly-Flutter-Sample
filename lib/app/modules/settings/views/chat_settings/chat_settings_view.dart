import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/modules/settings/views/chat_settings/chat_settings_controller.dart';

import '../../../../common/widgets.dart';
import '../settings_widgets.dart';

class ChatSettingsView extends GetView<ChatSettingsController> {
  const ChatSettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chat'),
          automaticallyImplyLeading: true,
        ),
        body: Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              lockItem(title: "Archive Settings",
                  subtitle: "Archived chats will remain archived when you receive a new message",
                  on: controller.archiveEnabled,
                  onToggle: (value) => controller.enableArchive()),
              notificationItem(title: Constants.googleTranslationLabel, subtitle: Constants.googleTranslationMessage,on: controller.translationEnabled, onTap: controller.enableDisableTranslate),
              Visibility(
                  visible: controller.translationEnabled,
                  child: ListItem(
                      title: Column(
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
                      ),
                      dividerPadding: const EdgeInsets.symmetric(horizontal: 16),
                      onTap: (){
                        controller.chooseLanguage();
                      })),
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
          );
        }),
      ),
    );
  }
}
