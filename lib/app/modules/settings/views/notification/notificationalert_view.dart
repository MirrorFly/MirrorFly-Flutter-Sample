import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';

import '../../../../common/widgets.dart';
import 'notificationalert_controller.dart';

class NotificationAlertView extends GetView<NotificationAlertController> {
  const NotificationAlertView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications Alert'),
        automaticallyImplyLeading: true,
      ),
      body: Obx(() {
        return Column(
          children: [
            notificationItem(
                title: "Notification Sound",
                subtitle: "Play sounds for incoming messages",
                on: controller.displayNotificationSoundPreference,
                onTap: () => controller.notificationSound()),
            /*notificationItem(
              title: "Notification Popup",
              subtitle: "Showing popup for incoming messages",
              on: controller.displayNotificationPopupPreference,
              onTap: () =>controller.notificationPopup()),*/
            notificationItem(
                title: "Vibration",
                subtitle:
                "Vibrate when a new message arrives while application is running",
                on: controller.displayVibrationPreference,
                onTap: () => controller.vibration()),
            notificationItem(
                title: "Mute Notification",
                subtitle:
                "This will mute all notifications alerts for incoming messages",
                on: controller.displayMuteNotificationPreference,
                onTap: () => controller.mute()),
          ],
        );
      }),
    );
  }

  ListItem notificationItem({required String title,
    required String subtitle,
    bool on = false,
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
              style: const TextStyle(fontSize: 13, color: textcolor),
            ),
          ],
        ),
        dividerpadding: const EdgeInsets.symmetric(horizontal: 16),
        trailing: SvgPicture.asset(
          on ? tick_round_blue : tick_round,
        ),
        onTap: onTap);
  }
}
