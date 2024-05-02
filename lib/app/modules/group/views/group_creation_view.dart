import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/extensions.dart';
import 'package:mirror_fly_demo/app/modules/group/controllers/group_creation_controller.dart';

import '../../../common/constants.dart';
import '../../../common/widgets.dart';
import '../../../routes/route_settings.dart';

class GroupCreationView extends GetView<GroupCreationController> {
  const GroupCreationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'New Group',
        ),
        actions: [
          TextButton(
              onPressed: () => controller.goToAddParticipantsPage(),
              child: const Text(
                "NEXT",
                style: TextStyle(color: Colors.black),
              )),
        ],
      ),
      body: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) {
            return;
          }
          if (controller.showEmoji.value) {
            controller.showEmoji(false);
          } else {
            Get.back();
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 18.0,
                                horizontal: 18.0,
                              ),
                              child: Obx(
                                () => InkWell(
                                  child: controller.imagePath.value.isNotEmpty
                                      ? SizedBox(
                                          width: 150,
                                          height: 150,
                                          child: ClipOval(
                                            child: Image.file(
                                              File(controller.imagePath.value),
                                              fit: BoxFit.fill,
                                            ),
                                          ))
                                      : ImageNetwork(
                                          url: controller.userImgUrl.value.checkNull(),
                                          width: 150,
                                          height: 150,
                                          clipOval: true,
                                          errorWidget: ClipOval(
                                            child: Image.asset(groupImg, width: 150, height: 150, fit: BoxFit.cover),
                                          ),
                                          isGroup: true,
                                          blocked: false,
                                          unknown: false,
                                        ),
                                  onTap: () {
                                    if (controller.imagePath.value.checkNull().isNotEmpty) {
                                      Get.toNamed(Routes.imageView,
                                          arguments: {'imageName': controller.groupName.text, 'imagePath': controller.imagePath.value.checkNull()});
                                    } else if (controller.userImgUrl.value.checkNull().isNotEmpty) {
                                      Get.toNamed(Routes.imageView,
                                          arguments: {'imageName': controller.groupName.text, 'imageUrl': controller.userImgUrl.value.checkNull()});
                                    } else {
                                      controller.choosePhoto();
                                    }
                                  },
                                ),
                              ),
                            ),
                            Obx(
                              () => Positioned(
                                right: 18,
                                bottom: 18,
                                child: InkWell(
                                  onTap: controller.loading.value
                                      ? null
                                      : () {
                                          controller.choosePhoto();
                                        },
                                  child: Image.asset(
                                    'assets/logos/camera_profile_change.png',
                                    height: 40,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 40.0, right: 20),
                              child: TextField(
                                focusNode: controller.focusNode,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, overflow: TextOverflow.visible),
                                onChanged: (_) => controller.onGroupNameChanged(),
                                maxLength: 25,
                                maxLines: 1,
                                controller: controller.groupName,
                                decoration: const InputDecoration(border: InputBorder.none, counterText: "", hintText: "Type group name here..."),
                              ),
                            ),
                          ),
                          Container(
                              height: 50,
                              padding: const EdgeInsets.all(4.0),
                              child: Center(
                                child: Obx(
                                  () => Text(
                                    controller.count.toString(),
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                                  ),
                                ),
                              )),
                          Obx(() {
                            return IconButton(
                                onPressed: () {
                                  controller.showHideEmoji(context);
                                },
                                icon: controller.showEmoji.value
                                    ? const Icon(
                                        Icons.keyboard,
                                        color: iconColor,
                                      )
                                    : SvgPicture.asset(
                                        smileIcon,
                                        width: 18,
                                        height: 18,
                                      ));
                          })
                        ],
                      ),
                      const AppDivider(),
                      const Text(
                        "Provide a Group Name and Icon",
                        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Obx(() {
                  if (controller.showEmoji.value) {
                    return EmojiLayout(
                      textController: TextEditingController(),
                      onBackspacePressed: () => controller.onEmojiBackPressed(),
                      onEmojiSelected: (cat, emoji) => controller.onEmojiSelected(emoji),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
