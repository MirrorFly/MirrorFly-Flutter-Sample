import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/utils.dart';
import '../../../extensions/extensions.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';
import 'package:photo_view/photo_view.dart';

import '../../../common/constants.dart';
import '../../../widgets/video_player_widget.dart';
import '../controllers/view_all_media_preview_controller.dart';

class ViewAllMediaPreviewView
    extends NavViewStateful<ViewAllMediaPreviewController> {
  const ViewAllMediaPreviewView({Key? key}) : super(key: key);

  @override
  ViewAllMediaPreviewController createController({String? tag}) =>
      Get.put(ViewAllMediaPreviewController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Obx(() {
          return Text(controller.title.value);
        }),
        centerTitle: false,
        actions: [
          IconButton(
              onPressed: () {
                controller.shareMedia();
              },
              icon: AppUtils.svgIcon(icon: shareIcon))
        ],
      ),
      body: SafeArea(
        child: PageView(
          controller: controller.pageViewController,
          onPageChanged: controller.onMediaPreviewPageChanged,
          children: [
            ...controller.previewMediaList
                .where((p0) =>
                    p0.isMediaMessage() &&
                    MediaUtils.isMediaExists(p0
                        .mediaChatMessage!.mediaLocalStoragePath.value
                        .checkNull()))
                .map((data) {
              /// show image
              if (data.messageType.toLowerCase() == 'image') {
                return Center(
                  child: PhotoView(
                    imageProvider: FileImage(File(
                        data.mediaChatMessage!.mediaLocalStoragePath.value)),
                    // Contained = the smallest possible size to fit one dimension of the screen
                    minScale: PhotoViewComputedScale.contained * 1,
                    // Covered = the smallest possible size to fit the whole screen
                    maxScale: PhotoViewComputedScale.covered * 2,
                    enableRotation: true,
                    basePosition: Alignment.center,
                    // Set the background color to the "classic white"
                    backgroundDecoration:
                        const BoxDecoration(color: Colors.transparent),
                    loadingBuilder: (context, event) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              }

              /// show video
              else if (data.messageType == MessageType.video.value) {
                // return AspectRatio(
                //   aspectRatio: 2,
                //   child: BetterVideoPlayer(
                //     configuration:
                //     const BetterVideoPlayerConfiguration(
                //       looping: false,
                //       autoPlay: false,
                //       allowedScreenSleep: false,
                //       autoPlayWhenResume: false,
                //     ),
                //     controller:
                //     BetterVideoPlayerController(),
                //     dataSource: BetterVideoPlayerDataSource(
                //       BetterVideoPlayerDataSourceType.file,
                //       data.mediaChatMessage!.mediaLocalStoragePath,
                //     ),
                //   ),
                // );
                return VideoPlayerWidget(
                  videoPath:
                      data.mediaChatMessage?.mediaLocalStoragePath.value ?? "",
                  videoTitle: data.mediaChatMessage?.mediaFileName ?? "Video",
                );
              } else {
                return Container(
                  color: const Color(0xff97A5C7),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AppUtils.svgIcon(
                        icon: data.mediaChatMessage!.isAudioRecorded.checkNull()
                            ? audioMic1
                            : headsetImg,
                        height: 150,
                        width: 150,
                      ),
                      FloatingActionButton.small(
                        onPressed: () {
                          AppUtils.openDocument(data
                              .mediaChatMessage!.mediaLocalStoragePath.value
                              .checkNull());
                        },
                        backgroundColor: Colors.white,
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: buttonBgColor,
                        ),
                      )
                    ],
                  ),
                );
              }
            })
          ],
        ),
      ),
    );
  }
}
