import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../controllers/video_preview_controller.dart';

class VideoPreviewView extends GetView<VideoPreviewController> {
  const VideoPreviewView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
          iconTheme: const IconThemeData(
              color: Colors.white
          ),

      ),
      body: SafeArea(
        child: SizedBox(
          width: MediaQuery
              .of(context)
              .size
              .width,
          height: MediaQuery
              .of(context)
              .size
              .height,
          child: Stack(
            children: [
              Obx(() {
                if (controller.isInitialized.value) {
                  return Center(
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: controller.videoPlayerController.value.size.height,
                        child: AspectRatio(
                          aspectRatio:
                          controller.videoPlayerController.value.aspectRatio,
                          child: VideoPlayer(controller.videoPlayerController),
                        )
                    ),
                  );
                } else {
                  return Container();
                }
              }),
              Positioned(
                bottom: 0,
                child: Container(
                  color: Colors.black38,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  padding: const EdgeInsets.symmetric(
                      vertical: 5, horizontal: 15),
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
                            const SizedBox(width: 5,),
                            const Padding(
                              padding: EdgeInsets.only(top: 12.0, bottom: 12.0),
                              child: VerticalDivider(
                                color: Colors.white,
                                thickness: 1,
                              ),
                            ),
                            const SizedBox(width: 5,),
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
                                  ),),
                              ),
                            ),
                            InkWell(
                                onTap: () {
                                  controller.sendVideoMessage();

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
                            Text(controller.userName, style: const TextStyle(
                                color: Colors.white),),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: InkWell(
                  onTap: () {
                    controller.togglePlay();
                  },
                  child: CircleAvatar(
                    radius: 33,
                    backgroundColor: Colors.black38,
                    child: Obx(() {
                      return controller.isPlaying.value ?
                      const Icon(Icons.pause,
                        color: Colors.white,
                        size: 50,
                      ) : const Icon(Icons.play_arrow,
                        color: Colors.white,
                        size: 50,
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
