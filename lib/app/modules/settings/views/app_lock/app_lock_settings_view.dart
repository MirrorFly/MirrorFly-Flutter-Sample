import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/constants.dart';
import '../settings_widgets.dart';
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

}
