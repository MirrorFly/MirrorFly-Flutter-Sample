import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/app_localizations.dart';
import '../../../common/constants.dart';
import '../../../common/widgets.dart';
import '../../../data/utils.dart';
import '../../../extensions/extensions.dart';
import '../controllers/busy_status_controller.dart';

class AddBusyStatusView extends NavViewStateful<BusyStatusController> {
  const AddBusyStatusView(
      {super.key, required this.status, this.enableAppBar = true});
  final bool enableAppBar;
  final String? status;

  @override
BusyStatusController createController({String? tag}) => Get.put(BusyStatusController());

  @override
  void onInit() {
    controller.addStatusController.text = status ?? "";
    controller.count(139 - controller.addStatusController.text.characters.length);
    super.onInit();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(getTranslated("addBusyStatus")),
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            return;
          }
          if (controller.showEmoji.value) {
            controller.showEmoji(false);
          } else {
            NavUtils.back();
          }
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
                              Icons.keyboard, color: iconColor,) : AppUtils.svgIcon(icon:smileIcon));
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
                      NavUtils.back();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: WidgetStateColor.resolveWith(
                                (states) => Colors.white),
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero)),
                    child: Text(
                      getTranslated("cancel").toUpperCase(),
                      style: const TextStyle(color: Colors.black, fontSize: 16.0),
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
                      controller.validateAndFinish(context);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: WidgetStateColor.resolveWith(
                                (states) => Colors.white),
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero)),
                    child: Text(
                      getTranslated("ok").toUpperCase(),
                      style: const TextStyle(color: Colors.black, fontSize: 16.0),
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
            textController: TextEditingController(),//controller.addStatusController,
            onBackspacePressed: () {
              controller.onEmojiBackPressed();
            },
            onEmojiSelected: (cat, emoji) => controller.onEmojiSelected(emoji));
      } else {
        return const SizedBox.shrink();
      }
    });
  }
}
