import 'dart:io';

import 'package:better_video_player/better_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

import '../controllers/media_preview_controller.dart';

class MediaPreviewView extends GetView<MediaPreviewController> {
  const MediaPreviewView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            Obx(() {
              return controller.filePath.length > 1 ? IconButton(
                  onPressed: () {
                    controller.deleteMedia();
                  }, icon: const Icon(Icons.delete_outline)) : const SizedBox.shrink();
            })
          ],
        ),
        body: SafeArea(
          child: Container(
            height: MediaQuery
                .of(context)
                .size
                .height,
            color: Colors.black,
            child: Stack(
              children: [
                SizedBox(
                  height: 500,
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
                        : PageView(
                      onPageChanged: onMediaPreviewPageChanged,
                      children: [
                        ...controller.filePath.map((data) {
                          /// show image
                          if (data.type == 'image') {
                            return Center(
                                child: PhotoView(
                                  imageProvider: FileImage(File(data.path)),
                                  // Contained = the smallest possible size to fit one dimension of the screen
                                  minScale: PhotoViewComputedScale.contained *
                                      0.8,
                                  // Covered = the smallest possible size to fit the whole screen
                                  maxScale: PhotoViewComputedScale.covered * 2,
                                  enableRotation: true,
                                  // Set the background color to the "classic white"
                                  backgroundDecoration: const BoxDecoration(
                                      color: Colors.transparent
                                  ),
                                  loadingBuilder: (context, event) =>
                                  const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              // PhotoView.customChild(
                              //   enablePanAlways: true,
                              //   maxScale: 2.0,
                              //   minScale: 1.0,
                              //   child: Image.file(File(data.path)),
                              // ),
                            );
                          }

                          /// show video
                          else {
                            return AspectRatio(
                              aspectRatio: 16.0 / 9.0,
                              child: BetterVideoPlayer(
                                configuration:
                                const BetterVideoPlayerConfiguration(
                                  looping: false,
                                  autoPlay: false,
                                  allowedScreenSleep: false,
                                  autoPlayWhenResume: false,
                                ),
                                controller: BetterVideoPlayerController(),
                                dataSource: BetterVideoPlayerDataSource(
                                  BetterVideoPlayerDataSourceType.file,
                                  data.path,
                                ),
                              ),
                            );
                          }
                        })
                      ],
                    );
                  }),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    color: Colors.black38,
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
                    padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.add_photo_alternate,
                                color: Colors.white,
                                size: 27,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              const Padding(
                                padding: EdgeInsets.only(
                                    top: 12.0, bottom: 12.0),
                                child: VerticalDivider(
                                  color: Colors.white,
                                  thickness: 1,
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: TextFormField(
                                  controller: controller.caption,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                  ),
                                  maxLines: 6,
                                  minLines: 1,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Add Caption....",
                                    hintStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                  onTap: () {
                                    controller.sendMedia();
                                    // controller.sendMessage(controller.profile);
                                  },
                                  child: SvgPicture.asset(
                                      'assets/logos/img_send.svg')),
                            ],
                          ),
                          // SvgPicture.asset(
                          //   rightArrow,
                          //   width: 18,
                          //   height: 18,
                          //   fit: BoxFit.contain,
                          //   color: Colors.white,
                          // ),
                          Row(
                            children: [
                              const Icon(
                                Icons.chevron_right_sharp,
                                color: Colors.white,
                                size: 27,
                              ),
                              Text(
                                controller.userName,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  void onMediaPreviewPageChanged(int value) {
    controller.currentPageIndex(value);
  }
}
