import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../common/constants.dart';
import '../../../common/widgets.dart';
import '../controllers/busy_status_controller.dart';

class AddBusyStatusView extends GetView<BusyStatusController> {
  const AddBusyStatusView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text('Add Busy Status'),
      ),
      body: WillPopScope(
        onWillPop: () {
          if (controller.showEmoji.value) {
            controller.showEmoji(false);
          } else {
            Get.back();
          }
          return Future.value(false);
        },
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                              overflow: TextOverflow.visible),
                          onChanged: (value) {
                            controller.onChanged();
                          },
                          maxLength: 139,
                          maxLines: 1,
                          autofocus: true,
                          focusNode: controller.focusNode,
                          controller: controller.addStatusController,
                          decoration: const InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: buttonBgColor),
                              ),
                              counterText: ""),
                          onTap: () {
                            if (controller.showEmoji.value) {
                              controller.showEmoji(false);
                            }
                          },
                        ),
                      ),
                      Container(
                          height: 50,
                          padding: const EdgeInsets.all(4.0),
                          child: Center(
                            child: Obx(
                                  () =>
                                  Text(
                                    controller.count.toString(),
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.normal),
                                  ),
                            ),
                          )),
                      Obx(() {
                        return IconButton(
                            onPressed: () {
                              controller.showHideEmoji(context);
                            },
                            icon: controller.showEmoji.value ? const Icon(
                              Icons.keyboard, color: iconColor,) : SvgPicture
                                .asset(smileIcon));
                      })
                    ],
                  ),
                ),
              ),
              Row(children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (controller.showEmoji.value) {
                        controller.showEmoji(false);
                      }
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: MaterialStateColor.resolveWith(
                                (states) => Colors.white),
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero)),
                    child: const Text(
                      "CANCEL",
                      style: TextStyle(color: Colors.black, fontSize: 16.0),
                    ),
                  ),
                ),
                const Divider(
                  color: Colors.grey,
                  thickness: 0.2,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (controller.showEmoji.value) {
                        controller.showEmoji(false);
                      }
                      controller.validateAndFinish();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: MaterialStateColor.resolveWith(
                                (states) => Colors.white),
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero)),
                    child: const Text(
                      "OK",
                      style: TextStyle(color: Colors.black, fontSize: 16.0),
                    ),
                  ),
                ),
              ]),
              emojiLayout(),
            ],
          ),
        ),
      ),
    );
  }

  Widget emojiLayout() {
    return Obx(() {
      if (controller.showEmoji.value) {
        return EmojiLayout(
            textController: controller.addStatusController,
            onBackspacePressed: () {
              controller.onChanged();
            },
            onEmojiSelected: (cat, emoji) => controller.onChanged());
      } else {
        return const SizedBox.shrink();
      }
    });
  }
}
