import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/app_localizations.dart';
import '../../../common/constants.dart';
import '../../../extensions/extensions.dart';

import '../../../data/utils.dart';
import '../controllers/contact_sync_controller.dart';

class ContactSyncPage extends StatefulWidget {
  const ContactSyncPage({super.key});

  @override
  State<ContactSyncPage> createState() => _ContactSyncPageState();
}

class _ContactSyncPageState extends State<ContactSyncPage> {
  final ContactSyncController controller = ContactSyncController().get();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            Text(getTranslated("hello"), style: const TextStyle(fontSize: 23,
                fontWeight: FontWeight.w800,
                color: textHintColor), textAlign: TextAlign.center,),
            Text(controller.name,
              style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,),
            const SizedBox(height: 20,),
            Obx(() {
              return Text(controller.textContactSync.value,
                style: const TextStyle(fontSize: 16, color: textColor),
                textAlign: TextAlign.center,);
            }),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: Stack(
                children: [
                  AppUtils.assetIcon(assetName:contactSyncBg),
                  Positioned(
                    top: 100,
                    left: 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppUtils.svgIcon(icon:contactBookFill),
                        Obx(() {
                          return Visibility(
                            visible: controller.syncing.value,
                            child: RotationTransition(
                                turns: controller.turnsTween.animate(
                                    controller.animController),
                                child: AppUtils.svgIcon(icon:syncIcon)),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
