import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/modules/settings/views/chat_settings/chat_settings_controller.dart';

import '../../../../common/widgets.dart';
import '../settings_widgets.dart';

class ChatSettingsView extends GetView<ChatSettingsController> {
  const ChatSettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
