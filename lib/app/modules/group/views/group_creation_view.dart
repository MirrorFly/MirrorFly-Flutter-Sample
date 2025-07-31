import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app_style_config.dart';
import '../../../common/app_localizations.dart';
import '../../../extensions/extensions.dart';
import '../../../modules/group/controllers/group_creation_controller.dart';

import '../../../common/constants.dart';
import '../../../common/widgets.dart';
import '../../../data/utils.dart';
import '../../../routes/route_settings.dart';

class GroupCreationView extends NavViewStateful<GroupCreationController> {
  const GroupCreationView({Key? key}) : super(key: key);

  @override
  GroupCreationController createController({String? tag}) =>
      Get.put(GroupCreationController());

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
          appBarTheme: AppStyleConfig.createGroupPageStyle.appbarTheme),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            getTranslated("newGroup"),
          ),
          actions: [
            TextButton(
                onPressed: () => controller.goToAddParticipantsPage(),
                child: Text(
                  getTranslated("next").toUpperCase(),
                  style: AppStyleConfig.createGroupPageStyle.actionTextStyle,
                  // style: const TextStyle(color: Colors.black),
                )),
          ],
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
                                            width: AppStyleConfig
                                                .createGroupPageStyle
                                                .profileImageSize
                                                .width,
                                            height: AppStyleConfig
                                                .createGroupPageStyle
                                                .profileImageSize
                                                .height,
                                            child: ClipOval(
                                              child: Image.file(
                                                File(
                                                    controller.imagePath.value),
                                                fit: BoxFit.fill,
                                              ),
                                            ))
                                        : ImageNetwork(
                                            url: controller.userImgUrl.value
                                                .checkNull(),
                                            width: AppStyleConfig
                                                .createGroupPageStyle
                                                .profileImageSize
                                                .width,
                                            height: AppStyleConfig
                                                .createGroupPageStyle
                                                .profileImageSize
                                                .height,
                                            clipOval: true,
                                            errorWidget: ClipOval(
                                              child: AppUtils.assetIcon(
                                                  assetName: groupImg,
                                                  width: AppStyleConfig
                                                      .createGroupPageStyle
                                                      .profileImageSize
                                                      .width,
                                                  height: AppStyleConfig
                                                      .createGroupPageStyle
                                                      .profileImageSize
                                                      .height,
                                                  fit: BoxFit.cover),
                                            ),
                                            isGroup: true,
                                            blocked: false,
                                            unknown: false,
                                          ),
                                    onTap: () {
                                      if (controller.imagePath.value
                                          .checkNull()
                                          .isNotEmpty) {
                                        NavUtils.toNamed(Routes.imageView,
                                            arguments: {
                                              'imageName':
                                                  controller.groupName.text,
                                              'imagePath': controller
                                                  .imagePath.value
                                                  .checkNull()
                                            });
                                      } else if (controller.userImgUrl.value
                                          .checkNull()
                                          .isNotEmpty) {
                                        NavUtils.toNamed(Routes.imageView,
                                            arguments: {
                                              'imageName':
                                                  controller.groupName.text,
                                              'imageUrl': controller
                                                  .userImgUrl.value
                                                  .checkNull()
                                            });
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
                                  child: Container(
                                    width: 40,
                                    decoration: BoxDecoration(
                                        color: AppStyleConfig
                                            .createGroupPageStyle
                                            .cameraIconStyle
                                            .bgColor,
                                        border: Border.all(
                                            color: AppStyleConfig
                                                    .createGroupPageStyle
                                                    .cameraIconStyle
                                                    .borderColor ??
                                                Colors.white,
                                            width: 1),
                                        shape: BoxShape.circle),
                                    child: InkWell(
                                      onTap: controller.loading.value
                                          ? null
                                          : () {
                                              controller.choosePhoto();
                                            },
                                      child: AppUtils.svgIcon(
                                        icon:
                                            'assets/logos/camera_profile_change.svg',
                                        colorFilter: ColorFilter.mode(
                                            AppStyleConfig.createGroupPageStyle
                                                .cameraIconStyle.iconColor,
                                            BlendMode.srcIn),
                                      ),
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
                                padding: const EdgeInsets.only(
                                    left: 40.0, right: 20),
                                child: TextField(
                                  focusNode: controller.focusNode,
                                  // style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal, overflow: TextOverflow.visible),
                                  onChanged: (_) =>
                                      controller.onGroupNameChanged(),
                                  maxLength: 25,
                                  maxLines: 1,
                                  controller: controller.groupName,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    counterText: "",
                                    hintText:
                                        getTranslated("typeGroupNameHere"),
                                    hintStyle: AppStyleConfig
                                        .createGroupPageStyle
                                        .nameTextFieldStyle
                                        .editTextHintStyle,
                                  ),
                                  style: AppStyleConfig.createGroupPageStyle
                                      .nameTextFieldStyle.editTextStyle,
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
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  ),
                                )),
                            Obx(() {
                              return IconButton(
                                  onPressed: () {
                                    controller.showHideEmoji();
                                  },
                                  icon: controller.showEmoji.value
                                      ? Icon(
                                          Icons.keyboard,
                                          color: AppStyleConfig
                                              .createGroupPageStyle.emojiColor,
                                        )
                                      : AppUtils.svgIcon(
                                          icon: smileIcon,
                                          width: 18,
                                          height: 18,
                                          colorFilter: ColorFilter.mode(
                                              AppStyleConfig
                                                  .createGroupPageStyle
                                                  .emojiColor,
                                              BlendMode.srcIn),
                                        ));
                            })
                          ],
                        ),
                        const AppDivider(),
                        Text(
                          getTranslated("provideGroupNameIcon"),
                          style: AppStyleConfig.createGroupPageStyle
                              .nameTextFieldStyle.titleStyle,
                          // style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
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
                        onBackspacePressed: () =>
                            controller.onEmojiBackPressed(),
                        onEmojiSelected: (cat, emoji) =>
                            controller.onEmojiSelected(emoji),
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
      ),
    );
  }
}
