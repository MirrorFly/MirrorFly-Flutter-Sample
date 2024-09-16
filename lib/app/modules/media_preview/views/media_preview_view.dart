import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app_style_config.dart';
import '../../../common/app_localizations.dart';
import '../../../common/constants.dart';
import '../../../extensions/extensions.dart';
import 'package:photo_view/photo_view.dart';

import '../../../common/widgets.dart';
import '../../../data/utils.dart';
import '../../../widgets/video_player_widget.dart';
import '../controllers/media_preview_controller.dart';
class MediaPreviewView extends NavViewStateful<MediaPreviewController> {
  const MediaPreviewView({Key? key}) : super(key: key);

  @override
MediaPreviewController createController({String? tag}) => Get.put(MediaPreviewController());

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        appBarTheme: AppStyleConfig.mediaSentPreviewPageStyle.appBarTheme,
        floatingActionButtonTheme: AppStyleConfig.mediaSentPreviewPageStyle.sentIcon,
      ),
      child: Scaffold(
          backgroundColor: AppStyleConfig.mediaSentPreviewPageStyle.scaffoldBackgroundColor,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leadingWidth: 80,
            leading: InkWell(
              onTap: () {
                NavUtils.back();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  Icon(
                    Icons.arrow_back,
                    color: AppStyleConfig.mediaSentPreviewPageStyle.appBarTheme.iconTheme?.color,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  ImageNetwork(
                    url: controller.profile.image.checkNull(),
                    width: AppStyleConfig.mediaSentPreviewPageStyle.chatUserAppBarStyle.profileImageSize.width,
                    height: AppStyleConfig.mediaSentPreviewPageStyle.chatUserAppBarStyle.profileImageSize.height,
                    clipOval: true,
                    errorWidget: controller.profile.isGroupProfile ?? false
                        ? ClipOval(
                            child: AppUtils.assetIcon(assetName:
                              groupImg,
                              width: AppStyleConfig.mediaSentPreviewPageStyle.chatUserAppBarStyle.profileImageSize.width,
                              height: AppStyleConfig.mediaSentPreviewPageStyle.chatUserAppBarStyle.profileImageSize.height,
                              fit: BoxFit.cover,
                            ),
                          )
                        : ProfileTextImage(
                            text: controller.profile.getName(),/*controller.profile.name.checkNull().isEmpty
                                ? controller.profile.nickName.checkNull().isEmpty
                                    ? controller.profile.mobileNumber.checkNull()
                                    : controller.profile.nickName.checkNull()
                                : controller.profile.name.checkNull(),*/
                            radius: AppStyleConfig.mediaSentPreviewPageStyle.chatUserAppBarStyle.profileImageSize.width / 2,
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
                        icon: AppUtils.svgIcon(icon:deleteBinWhite,colorFilter: ColorFilter.mode(AppStyleConfig.mediaSentPreviewPageStyle.appBarTheme.actionsIconTheme?.color ?? Colors.white, BlendMode.srcIn),))
                    : const Offstage();
              })
            ],
          ),
          body: SafeArea(
            child: PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) {
                if (didPop) {
                  return;
                }
                NavUtils.back(result: "back");
              },
              child: GestureDetector(
                onTap: () => controller.hideKeyBoard(),
                child: Container(
                  height: NavUtils.size.height,
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
                                      Text(
                                        getTranslated("noMediaSelected"),
                                        style: const TextStyle(
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
                                      if (controller.filePath.isNotEmpty)
                                        // ...controller.filePath.map((data) {
                                        ...controller.filePath.asMap().entries.map((entry) {
                                          int index = entry.key;
                                          var data = entry.value;
                                          /// show image
                                          if (data.type == 'image') {
                                            return controller.checkCacheFile(index) ? Center(
                                              child: imagePreview(controller.getCacheFile(index)),
                                            )
                                                : FutureBuilder<File?>(
                                              future: controller.getFile(index),
                                              builder: (BuildContext context, AsyncSnapshot<File?> snapshot) {
                                                if (snapshot.connectionState == ConnectionState.waiting) {
                                                  return const Center(child: CircularProgressIndicator());
                                                } else if (snapshot.hasError) {
                                                  return Text(getTranslated("errorLoadingImage"));
                                                } else if (snapshot.hasData && snapshot.data != null) {
                                                  return Center(
                                                    child: imagePreview(snapshot.data!),
                                                  );
                                                } else {
                                                  return Text(getTranslated("noData"));
                                                }
                                              },
                                            );
                                          }
                                          /// show video
                                          else {
                                            return FutureBuilder<File?>(
                                              future: controller.getFile(index),
                                              builder: (BuildContext context, AsyncSnapshot<File?> snapshot) {
                                                if (snapshot.connectionState == ConnectionState.waiting) {
                                                  return const Center(child: CircularProgressIndicator());
                                                } else if (snapshot.hasError) {
                                                  return Text(getTranslated("errorLoadingImage"));
                                                } else if (snapshot.hasData && snapshot.data != null) {
                                                  return VideoPlayerWidget(
                                                    videoPath: snapshot.data?.path ?? "",
                                                    videoTitle: data.title ?? "Video",
                                                  );
                                                } else {
                                                  return Text(getTranslated("noData"));
                                                }
                                              },
                                            );

                                          }
                                        })
                                      else
                                      ...[
                                            () {
                                          return Center(child: Text(getTranslated("noDataAvailable")));
                                        }()
                                      ],
                                    ],
                                  ),
                                );
                        }),
                      ),
                      SizedBox(
                        width: NavUtils.size.width,
                        child: Column(
                          children: [
                            IntrinsicHeight(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                                    child: Row(
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
                                                  child: AppUtils.svgIcon(icon:
                                                      'assets/logos/smile.svg', colorFilter: ColorFilter.mode(AppStyleConfig.mediaSentPreviewPageStyle.iconColor, BlendMode.srcIn),))
                                              : controller.filePath.length < 10 &&
                                                      controller.showAdd
                                                  ? InkWell(
                                                      onTap: () {
                                                        NavUtils.back();
                                                      },
                                                      child: AppUtils.svgIcon(icon:
                                                          previewAddImg,colorFilter: ColorFilter.mode(AppStyleConfig.mediaSentPreviewPageStyle.iconColor, BlendMode.srcIn),),
                                                    )
                                                  : const Offstage();
                                        }),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Container(
                                          color: AppStyleConfig.mediaSentPreviewPageStyle.iconColor,
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
                                              style: AppStyleConfig.mediaSentPreviewPageStyle.textFieldStyle.editTextStyle,
                                              // style: const TextStyle(
                                              //   color: Colors.white,
                                              //   fontSize: 15,
                                              // ),
                                              maxLines: 6,
                                              minLines: 1,
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                                hintText: getTranslated("addCaption"),
                                                hintStyle: AppStyleConfig.mediaSentPreviewPageStyle.textFieldStyle.editTextHintStyle,
                                                // hintStyle: const TextStyle(
                                                //   color: previewTextColor,
                                                //   fontSize: 15,
                                                // ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        FloatingActionButton(
                                            onPressed: () {
                                              controller.sendMedia();
                                            },
                                            child: const Icon(Icons.send)),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.keyboard_arrow_right,
                                        color: AppStyleConfig.mediaSentPreviewPageStyle.iconColor,
                                        // color: Colors.white,
                                        size: 13,
                                      ),
                                      Text(
                                        controller.userName,
                                        style: AppStyleConfig.mediaSentPreviewPageStyle.nameTextStyle,
                                        // style: const TextStyle(
                                        //     color: previewTextColor, fontSize: 13),
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
                                                    ? const Offstage()
                                                    : Positioned(
                                                        bottom: 4,
                                                        left: 4,
                                                        child: AppUtils.svgIcon(icon:
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
            ),
          )),
    );
  }

  Widget emojiLayout() {
    return Obx(() {
      if (controller.showEmoji.value) {
        return EmojiLayout(
            textController: controller.caption,
            onEmojiSelected: (cat, emoji) => controller.onChanged());
      } else {
        return const Offstage();
      }
    });
  }

  Widget imagePreview(File file){
    return PhotoView(
      imageProvider: FileImage(file),
      minScale: PhotoViewComputedScale.contained * 1,
      maxScale: PhotoViewComputedScale.covered * 2,
      enableRotation: true,
      basePosition: Alignment.center,
      backgroundDecoration: const BoxDecoration(color: Colors.transparent),
      loadingBuilder: (context, event) => const Center(
        child: CircularProgressIndicator(),
      ),
      // errorBuilder: (ct, ob, trace) {
      //   return Image.memory(data.thumbnail!); // Ensure `data.thumbnail` is available or handle this case properly.
      // },
    );
  }
}
