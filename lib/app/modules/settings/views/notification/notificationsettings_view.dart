import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/modules/settings/views/notification/notificationalert_controller.dart';
import 'package:mirror_fly_demo/app/modules/settings/views/notification/notificationalert_view.dart';

import '../../../../common/widgets.dart';

class NotificationSettingsView extends GetView<NotificationAlertController> {
  const NotificationSettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          notificationSettingsItem(
              title: "Notification Alert",
              subtitle: 'Choose alert type for incoming message',
              onTap: () => Get.to(() => NotificationAlertView())),
          FutureBuilder(
              future: controller.getRingtoneName(),
              builder: (context, data) {
                return Obx(() {
                  return notificationSettingsItem(
                      title: "Notification Tone",
                      subtitle: 'Default (${controller.defaultTone})',
                      onTap: () => controller.showCustomTones());
                });
              }),
          notificationSettingsItem(
              title: "Notification Not Working?",
              subtitle: 'Learn more in our Help Center',
              onTap: () => launchWeb(notification_not_working_URL)),
        ],
      ),
    );
  }

  ListItem notificationSettingsItem(
      {required String title,
      required String subtitle,
      required Function() onTap}) {
    return ListItem(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w400)),
            SizedBox(
              height: 4,
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 13, color: textcolor),
            ),
          ],
        ),
        dividerpadding: const EdgeInsets.symmetric(horizontal: 16),
        trailing: SvgPicture.asset(rightarrowicon),
        onTap: onTap);
  }
}
