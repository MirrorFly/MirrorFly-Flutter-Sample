import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/app_localizations.dart';

import '../../../../common/constants.dart';
import '../settings_widgets.dart';
import 'app_lock_controller.dart';

class AppLockSettingsView extends GetView<AppLockController> {
  const AppLockSettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslated("appLock", context)),
        automaticallyImplyLeading: true,
      ),
      body: Obx(() {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            lockItem(title: getTranslated("pinLock", context),
                subtitle: getTranslated("pinLockDesc", context),
                on: controller.pinEnabled,
                onToggle: (value) => controller.enablePin()),
            Visibility(visible: controller.pinEnabled,
                child: lockItem(title: getTranslated("changePin", context),
                    subtitle: getTranslated("changePinDesc", context),
                    trailing: const SizedBox(),
                    on: false,
                    onToggle: (value) {},
                    onTap: () => controller.changePin())),
            lockItem(title: getTranslated("fingerPrintID", context),
                subtitle: getTranslated("fingerPrintIDDesc", context),
                on: controller.bioEnabled,
                onToggle: (value) => controller.enableBio()),
            const SizedBox(height: 8,),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getTranslated("appLockDesc", context),
                    style: const TextStyle(color: textColor),),
                  Text(getTranslated("appLockNote", context),
                    style: const TextStyle(color: textColor),)
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

}
