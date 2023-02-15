import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/modules/settings/views/notification/notification_alert_controller.dart';
import 'package:mirror_fly_demo/app/modules/settings/views/notification/notification_alert_view.dart';

import '../../../../common/widgets.dart';
import 'notification_not_working_view.dart';

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
              onTap: () => Get.to(() => const NotificationAlertView())),
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
              onTap: () => Get.to(const NotificationNotWorkingView())),
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
            const SizedBox(
              height: 4,
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 13, color: textColor),
            ),
          ],
        ),
        dividerPadding: const EdgeInsets.symmetric(horizontal: 16),
        trailing: SvgPicture.asset(rightArrowIcon),
        onTap: onTap);
  }
}
