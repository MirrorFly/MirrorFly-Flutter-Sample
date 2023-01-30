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
            notificationItem(
                title: "Last Seen",
                subtitle: "Hiding the last seen activity to other users",
                on: controller.lastSeenPreference.value,
                onTap: () => controller.lastSeenEnableDisable()),
            notificationItem(
                title: "User Busy Status",
                subtitle: "Set busy status as the Auto response to the message received from the individuals",
                on: controller.lastSeenPreference.value,
                onTap: () => controller.lastSeenEnableDisable()),
            controller.lastSeenPreference.value ? ListItem(
                title: const Text('Edit Busy Status Message',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400)),
                // description: const Text("I'm Busy"),
                dividerPadding: const EdgeInsets.symmetric(horizontal: 16),
                onTap: (){
                  controller.clearAllConversation();
                }) : const SizedBox.shrink(),
            ListItem(
                title: const Text('Clear All Conversation',
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
