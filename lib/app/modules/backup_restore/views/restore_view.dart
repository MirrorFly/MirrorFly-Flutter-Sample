import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/utils.dart';

import '../../../extensions/extensions.dart';
import '../controllers/restore_controller.dart';

class RestoreView extends NavViewStateful<RestoreController> {
  const RestoreView({super.key});

  @override
  RestoreController createController({String? tag}) =>
      Get.put(RestoreController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                const Spacer(),
                SizedBox(
                  width: 70,
                  height: 70,
                  child: FloatingActionButton(
                    onPressed: () {},
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                    child: AppUtils.svgIcon(icon: backupDatabase),
                  ),
                ),
                Container(child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.add),
                ), decoration: const BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),),
                Card(child: AppUtils.svgIcon(icon: backupSmartPhone)),
                const Spacer(),
              ],
            )
          ],
        ),
      )),
    );
  }
}
