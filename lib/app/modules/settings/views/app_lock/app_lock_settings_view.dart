import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/app_localizations.dart';

import '../../../../common/constants.dart';
import '../../../../extensions/extensions.dart';
import '../settings_widgets.dart';
import 'app_lock_controller.dart';

class AppLockSettingsView extends NavViewStateful<AppLockController> {
  const AppLockSettingsView({Key? key}) : super(key: key);

  @override
AppLockController createController({String? tag}) => Get.put(AppLockController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTranslated("appLock")),
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Obx(() {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                lockItem(title: getTranslated("pinLock"),
                    subtitle: getTranslated("pinLockDesc"),
                    on: controller.pinEnabled,
                    onToggle: (value) => controller.enablePin()),
                Visibility(visible: controller.pinEnabled,
                    child: lockItem(title: getTranslated("changePin"),
                        subtitle: getTranslated("changePinDesc"),
                        trailing: const SizedBox(),
                        on: false,
                        onToggle: (value) {},
                        onTap: () => controller.changePin())),
                /*lockItem(title: getTranslated("fingerPrintID"),
                    subtitle: getTranslated("fingerPrintIDDesc"),
                    on: controller.bioEnabled,
                    onToggle: (value) => controller.enableBio()),*/
                const SizedBox(height: 8,),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getTranslated("appLockDesc"),
                        style: const TextStyle(color: textColor),),
                      Text(getTranslated("appLockNote"),
                        style: const TextStyle(color: textColor),)
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

}
