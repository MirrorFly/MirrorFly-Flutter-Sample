import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/modules/settings/views/chat_settings/chat_settings_controller.dart';

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
          ],
        );
      }),
    );
  }
}
