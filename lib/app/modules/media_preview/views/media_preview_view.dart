import 'dart:io';

// import 'package:better_video_player/better_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/common/extensions.dart';
import 'package:photo_view/photo_view.dart';

import '../../../common/widgets.dart';
import '../../../widgets/video_player_widget.dart';
import '../controllers/media_preview_controller.dart';

class MediaPreviewView extends GetView<MediaPreviewController> {
  const MediaPreviewView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          automaticallyImplyLeading: false,
          leadingWidth: 80,
          leading: InkWell(
            onTap: () {
              Get.back();
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 10,
                ),
                const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
                const SizedBox(
                  width: 10,
                ),
                ImageNetwork(
                  url: controller.profile.image.checkNull(),
                  width: 35,
                  height: 35,
                  clipOval: true,
                  errorWidget: controller.profile.isGroupProfile ?? false
                      ? ClipOval(
                          child: Image.asset(
                            groupImg,
                            height: 35,
                            width: 35,
                            fit: BoxFit.cover,
                          ),
                        )
                      : ProfileTextImage(
                          text: controller.profile.name.checkNull().isEmpty
                              ? controller.profile.nickName.checkNull().isEmpty
                                  ? controller.profile.mobileNumber.checkNull()
                                  : controller.profile.nickName.checkNull()
                              : controller.profile.name.checkNull(),
                          radius: 18,
                        ),
                  isGroup: controller.profile.isGroupProfile.checkNull(),
                  blocked: controller.profile.isBlockedMe.checkNull() ||
                      controller.profile.isAdminBlocked.checkNull(),
                  unknown: (!controller.profile.isItSavedContact.checkNull() ||
                      controller.profile.isDeletedContact()),
                ),
              ],
            ),
          ),
          actions: [
            Obx(() {
              return controller.filePath.length > 1
                  ? IconButton(
                      onPressed: () {
                        controller.deleteMedia();
                      },
                      icon: SvgPicture.asset(deleteBinWhite))
                  : const SizedBox.shrink();
            })
          ],
        ),
        body: PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            if (didPop) {
              return;
            }
            Get.back(result: "back");
          },
          child: SafeArea(
            child: Container(
              height: MediaQuery.of(context).size.height,
              color: Colors.black,
              child: Column(
                children: [
                  Expanded(
                    child: Obx(() {
                      return controller.filePath.isEmpty

                          /// no images selected
                          ? Container(
                              height: double.infinity,
                              width: double.infinity,
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Transform.scale(
                                    scale: 8,
                                    child: const Icon(
                                      Icons.image_outlined,
                                      color: Colors.white,
                                      size: 10,
                                    ),
                                  ),
                                  const SizedBox(height: 50),
                                  const Text(
                                    'No Media selected',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white70),
                                  )
                                ],
                              ),
                            )

                          /// selected media
                          : GestureDetector(
                              onTap: () {
                                controller.captionFocusNode.unfocus();
                              },
                              child: PageView(
                                controller: controller.pageViewController,
                                onPageChanged:
                                    controller.onMediaPreviewPageChanged,
                                children: [
                                  ...controller.filePath.map((data) {
                                    /// show image
                                    if (data.type == 'image') {
                                      return Center(
                                          child: PhotoView(
                                        imageProvider:
                                            FileImage(File(data.path!)),
                                        // Contained = the smallest possible size to fit one dimension of the screen
                                        minScale:
                                            PhotoViewComputedScale.contained *
                                                1,
                                        // Covered = the smallest possible size to fit the whole screen
                                        maxScale:
                                            PhotoViewComputedScale.covered * 2,
                                        enableRotation: true,
                                        basePosition: Alignment.center,
                                        // Set the background color to the "classic white"
                                        backgroundDecoration:
                                            const BoxDecoration(
                                                color: Colors.transparent),
                                        loadingBuilder: (context, event) =>
                                            const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ));
                                    }

                                    /// show video
                                    else {
                                      return VideoPlayerWidget(
                                        videoPath: data.path ?? "",
                                        videoTitle: data.title ?? "Video",
                                      );
                                    }
                                  })
                                ],
                              ),
                            );
                    }),
                  ),
                  Container(
                    color: Colors.black38,
                    width: MediaQuery.of(context).size.width,
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                    child: Column(
                      children: [
                        IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Obx(() {
                                    return controller.isFocused.value ||
                                            controller.showEmoji.value ||
                                            !controller.showAdd
                                        ? InkWell(
                                            onTap: () {
                                              if (!controller.showEmoji.value) {
                                                controller.captionFocusNode
                                                    .unfocus();
                                              }
                                              Future.delayed(
                                                  const Duration(
                                                      milliseconds: 100), () {
                                                controller.showEmoji(!controller
                                                    .showEmoji.value);
                                              });
                                            },
                                            child: SvgPicture.asset(
                                                'assets/logos/smile.svg'))
                                        : controller.filePath.length < 10 &&
                                                controller.showAdd
                                            ? InkWell(
                                                onTap: () {
                                                  Get.back();
                                                },
                                                child: SvgPicture.asset(
                                                    previewAddImg),
                                              )
                                            : const SizedBox.shrink();
                                  }),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Container(
                                    color: previewTextColor,
                                    width: 1,
                                    height: 25,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 5),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                    child: Focus(
                                      onFocusChange: (isFocus) =>
                                          controller.isFocused(isFocus),
                                      child: TextFormField(
                                        focusNode: controller.captionFocusNode,
                                        controller: controller.caption,
                                        onChanged: controller.onCaptionTyped,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),
                                        maxLines: 6,
                                        minLines: 1,
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "Add Caption...",
                                          hintStyle: TextStyle(
                                            color: previewTextColor,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                      onTap: () {
                                        controller.sendMedia();
                                      },
                                      child: SvgPicture.asset(
                                          'assets/logos/img_send.svg')),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.keyboard_arrow_right,
                                    color: Colors.white,
                                    size: 13,
                                  ),
                                  Text(
                                    controller.userName,
                                    style: const TextStyle(
                                        color: previewTextColor, fontSize: 13),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Obx(() {
                          return controller.filePath.length > 1
                              ? SizedBox(
                                  height: 45,
                                  child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: controller.filePath.length,
                                      itemBuilder: (context, index) {
                                        return Stack(
                                          children: [
                                            Obx(() {
                                              return InkWell(
                                                onTap: () {
                                                  controller
                                                      .currentPageIndex(index);
                                                  controller.pageViewController
                                                      .animateToPage(index,
                                                          duration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      1),
                                                          curve: Curves.easeIn);
                                                },
                                                child: Container(
                                                  width: 45,
                                                  height: 45,
                                                  decoration: controller
                                                              .currentPageIndex
                                                              .value ==
                                                          index
                                                      ? BoxDecoration(
                                                          border: Border.all(
                                                          color: Colors.blue,
                                                          width: 1,
                                                        ))
                                                      : null,
                                                  margin: const EdgeInsets
                                                      .symmetric(horizontal: 1),
                                                  child: Image.memory(controller
                                                      .filePath[index]
                                                      .thumbnail!),
                                                ),
                                              );
                                            }),
                                            controller.filePath[index].type ==
                                                    "image"
                                                ? const SizedBox.shrink()
                                                : Positioned(
                                                    bottom: 4,
                                                    left: 4,
                                                    child: SvgPicture.asset(
                                                      videoCamera,
                                                      width: 5,
                                                      height: 5,
                                                    )),
                                          ],
                                        );
                                      }),
                                )
                              : const Offstage();
                        }),
                        emojiLayout(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget emojiLayout() {
    return Obx(() {
      if (controller.showEmoji.value) {
        return EmojiLayout(
            textController: controller.caption,
            onEmojiSelected: (cat, emoji) => controller.onChanged());
      } else {
        return const SizedBox.shrink();
      }
    });
  }
}
