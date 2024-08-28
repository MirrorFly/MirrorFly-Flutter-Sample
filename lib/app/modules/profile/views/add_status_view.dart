import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/app_localizations.dart';
import '../../../common/widgets.dart';
import '../../../modules/profile/controllers/status_controller.dart';

import '../../../common/constants.dart';
import '../../../data/utils.dart';
import '../../../extensions/extensions.dart';

class AddStatusView extends NavView<StatusListController> {
  const AddStatusView({Key? key}) : super(key: key);

  @override
StatusListController createController({String? tag}) => StatusListController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(getTranslated("addNewStatus")),
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
            controller.onBackPressed();
          }
        },
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
                        onChanged: (_) => controller.onChanged(),
                        autofocus: true,
                        focusNode: controller.focusNode,
                        maxLength: 139,
                        maxLines: 1,
                        controller: controller.addStatusController,
                        decoration: const InputDecoration(
                            border: InputBorder.none, counterText: ""),
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
                            if (controller.showEmoji.value) {
                              controller.showEmoji(false);
                              controller.focusNode.requestFocus();
                              return;
                            }
                            if (!controller.showEmoji.value) {
                              controller.focusNode.unfocus();
                            }
                            Future.delayed(
                                const Duration(milliseconds: 500), () {
                              controller.showEmoji(!controller.showEmoji.value);
                            });
                          },
                          icon: controller.showEmoji.value ? const Icon(Icons.keyboard, color: iconColor,) : AppUtils.svgIcon(icon:smileIcon));
                    })
                  ],
                ),
              ),
            ),
            Row(children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => controller.onBackPressed(),
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
                    controller.validateAndFinish();
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
    );
  }

  Widget emojiLayout() {
    return Obx(() {
      if (controller.showEmoji.value) {
        return EmojiLayout(
            textController: TextEditingController(),//controller.addStatusController,
            onBackspacePressed: () => controller.onEmojiBackPressed(),
            onEmojiSelected: (cat, emoji) => controller.onEmojiSelected(emoji));
      } else {
        return const SizedBox.shrink();
      }
    });
  }
}
