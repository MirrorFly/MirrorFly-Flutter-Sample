import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/app_localizations.dart';

import '../../../../common/constants.dart';
import '../../../../data/utils.dart';
import '../../../../extensions/extensions.dart';
import 'app_lock_controller.dart';

class PinView extends NavView<AppLockController> {
  const PinView({Key? key}) : super(key: key);
  static const numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, -1, 0, 10];

  @override
AppLockController createController({String? tag}) => Get.put(AppLockController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              return;
            }
            SystemNavigator.pop();
          },
          child: Stack(
            children: [
              AppUtils.assetIcon(assetName:icBioBackground),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 30.0, vertical: 50),
                    child: AppUtils.assetIcon(assetName:icLogo),
                  ),
                  Text(getTranslated("enterYourPIN"),style: const TextStyle(fontWeight: FontWeight.w300,color: appbarTextColor,fontSize: 16.0),),
                  Obx(() {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        pinItem(controller.pin1),
                        pinItem(controller.pin2),
                        pinItem(controller.pin3),
                        pinItem(controller.pin4),
                      ],
                    );
                  }),
                  Center(
                    child: SizedBox(
                      width: 280,
                      child: GridView.builder(
                        itemCount: numbers.length,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,childAspectRatio: 1.5),
                        itemBuilder: (BuildContext context, int index) {
                          var item = numbers[index];
                          return numberItem(item,!item.isNegative
                              ? () => controller.numberClick(item)
                              : null);
                        },
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: (){
                      controller.forgetPin();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        getTranslated("forgotPIN"),
                        style: const TextStyle(color: Color(0XFFFF0000),fontWeight: FontWeight.normal,fontSize: 14),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Center numberItem(int item,Function()? onTap) {
    return Center(
      child: CircleAvatar(
          radius: 25,
          backgroundColor: (item == 10 || item.isNegative)
              ? Colors.transparent
              : const Color(0Xff989898), //bg color,
          child: InkWell(
            onTap: onTap,
            child: Visibility(
              visible: !item.isNegative,
              child: Center(
                  child: item == 10
                      ? AppUtils.svgIcon(icon:icDeleteIcon)
                      : Text(
                    item.toString(),
                    style: const TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.w500),
                  )),
            ),
          )),
    );
  }

  Padding pinItem(bool visible) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CircleAvatar(
        radius: 12,
        backgroundColor: Colors.black12, //bg color,
        child: Center(
            child: CircleAvatar(
              radius: 5,
              backgroundColor: visible ? Colors.black : Colors.transparent,
            )),
      ),
    );
  }
}
