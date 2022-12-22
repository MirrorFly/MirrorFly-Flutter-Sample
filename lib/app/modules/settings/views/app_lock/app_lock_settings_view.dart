import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';

import '../../../../common/constants.dart';
import '../../../../common/widgets.dart';
import 'app_lock_controller.dart';

class AppLockSettingsView extends GetView<AppLockController> {
  const AppLockSettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Lock'),
        automaticallyImplyLeading: true,
      ),
      body: Obx(() {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            lockItem(title: "Pin Lock",
                subtitle: "Add more security with 4 digit secret PIN",
                on: controller.pinenabled,
                onToggle: (value) => controller.enablePin()),
            Visibility(visible: controller.pinenabled,
                child: lockItem(title: "Change PIN",
                    subtitle: "Change 4 digit PIN",
                    trailing: const SizedBox(),
                    on: false,
                    onToggle: (value) {},
                    onTap: () => controller.changePin())),
            lockItem(title: "Fingerprint ID",
                subtitle: "Enable Fingerprint to unlock the app",
                on: controller.bioenabled,
                onToggle: (value) => controller.enableBio()),
            const SizedBox(height: 8,),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "If App Lock enabled, the app will be locked automatically after 32 sec when it is not in use.",
                    style: TextStyle(color: textColor),),
                  Text(
                    "Note: Once a PIN is set, it will be expired in 31 days and has to be renewed.",
                    style: TextStyle(color: textColor),)
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  ListItem lockItem(
      {required String title, required String subtitle, required bool on, Widget? trailing, required Function(bool value) onToggle, Function()? onTap}) {
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
        trailing: trailing ?? FlutterSwitch(
          width: 40.0,
          height: 20.0,
          valueFontSize: 12.0,
          toggleSize: 12.0,
          activeColor: Colors.white,
          activeToggleColor: Colors.blue,
          inactiveToggleColor: Colors.grey,
          inactiveColor: Colors.white,
          switchBorder: Border.all(
              color: on ? Colors.blue : Colors.grey,
              width: 1),
          value: on,
          onToggle: (value) => onToggle(value),
        ),
        dividerPadding: EdgeInsets.zero,
        onTap: onTap);
  }
}
