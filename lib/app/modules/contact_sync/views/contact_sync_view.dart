import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';

import '../controllers/contact_sync_controller.dart';

class ContactSyncPage extends GetView<ContactSyncController> {
  const ContactSyncPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            const Text('Hello..!!', style: TextStyle(fontSize: 23,
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
                  Image.asset(contactSyncBg),
                  Positioned(
                    top: 100,
                    left: 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(contactBookFill),
                        Obx(() {
                          return Visibility(
                            visible: controller.syncing.value,
                            child: RotationTransition(
                                turns: controller.turnsTween.animate(
                                    controller.animController),
                                child: SvgPicture.asset(syncIcon)),
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
