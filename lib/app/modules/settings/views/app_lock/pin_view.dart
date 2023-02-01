import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/constants.dart';
import 'app_lock_controller.dart';

class PinView extends GetView<AppLockController> {
  const PinView({Key? key}) : super(key: key);
  static const numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, -1, 0, 10];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 30.0, vertical: 50),
                child: Image.asset(icLogo),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Enter Your PIN"),
              ),
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
              const SizedBox(
                height: 20,
              ),
              GridView.builder(
                itemCount: numbers.length,
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, childAspectRatio: 1.8),
                itemBuilder: (BuildContext context, int index) {
                  var item = numbers[index];
                  return InkWell(
                    onTap: !item.isNegative
                        ? () => controller.numberClick(item)
                        : null,
                    child: numberItem(item),
                  );
                },
              ),
              /*const SizedBox(
                height: 20,
              ),
              const InkWell(
                child: Text(
                  "Forgot PIN?",
                  style: TextStyle(color: Colors.red),
                ),
              )*/
            ],
          ),
        ),
      ),
    );
  }

  Center numberItem(int item) {
    return Center(
      child: CircleAvatar(
          radius: 30,
          backgroundColor: (item == 10 || item.isNegative)
              ? Colors.transparent
              : textColor, //bg color,
          child: Visibility(
            visible: !item.isNegative,
            child: Center(
                child: item == 10
                    ? const Icon(
                  Icons.backspace_rounded,
                  color: Colors.black,
                )
                    : Text(
                  item.toString(),
                  style: const TextStyle(
                      fontSize: 17,
                      color: Colors.white,
                      fontWeight: FontWeight.w500),
                )),
          )),
    );
  }

  Padding pinItem(bool visible) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CircleAvatar(
        radius: 10,
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
