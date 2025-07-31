import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/app_localizations.dart';
import '../../../common/widgets.dart';
import '../../../modules/group/controllers/group_info_controller.dart';

import '../../../common/constants.dart';
import '../../../data/utils.dart';
import '../../../extensions/extensions.dart';

class NameChangeView extends NavView<GroupInfoController> {
  const NameChangeView({Key? key}) : super(key: key);

  @override
  GroupInfoController createController({String? tag}) => GroupInfoController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: Text(getTranslated("enterNewName")),
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            return;
          }
          controller.onBackPressed();
        },
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextField(
                              focusNode: controller.focusNode,
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.normal,
                                  overflow: TextOverflow.visible),
                              onChanged: (_) => controller.onChanged(),
                              maxLength: 25,
                              maxLines: 1,
                              controller: controller.nameController,
                              decoration: const InputDecoration(
                                  border: InputBorder.none, counterText: ""),
                            ),
                          ),
                          Container(
                              height: 50,
                              padding: const EdgeInsets.all(4.0),
                              child: Center(
                                child: Obx(
                                  () => Text(
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
                                  debugPrint("showHideEmoji icon pressed");
                                  controller.showHideEmoji(context);
                                },
                                icon: controller.showEmoji.value
                                    ? const Icon(
                                        Icons.keyboard,
                                        color: iconColor,
                                      )
                                    : AppUtils.svgIcon(
                                        icon: smileIcon,
                                        width: 18,
                                        height: 18,
                                      ));
                          })
                        ],
                      ),
                      const Divider(
                        height: 1,
                        color: dividerColor,
                        thickness: 1,
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(
                thickness: 1,
                color: Colors.grey,
                height: 1,
              ),
              IntrinsicHeight(
                child: Row(children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => NavUtils.back(),
                      child: Text(
                        getTranslated("cancel").toUpperCase(),
                        style: const TextStyle(
                            color: Colors.black, fontSize: 16.0),
                      ),
                    ),
                  ),
                  const VerticalDivider(
                    color: Colors.grey,
                    thickness: 1,
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        if (controller.nameController.text.trim().isNotEmpty) {
                          NavUtils.back(
                              result: controller.nameController.text
                                  .trim()
                                  .toString());
                        } else {
                          toToast(getTranslated("nameCantEmpty"));
                        }
                      },
                      child: Text(
                        getTranslated("ok").toUpperCase(),
                        style: const TextStyle(
                            color: Colors.black, fontSize: 16.0),
                      ),
                    ),
                  ),
                ]),
              ),
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
          textController: TextEditingController(),
          onEmojiSelected: (cat, emoji) => controller.onEmojiSelected(emoji),
          onBackspacePressed: () => controller.onEmojiBackPressed(),
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }
}
