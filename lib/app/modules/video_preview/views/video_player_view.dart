


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/modules/video_preview/controllers/video_play_controller.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerView extends GetView<VideoPlayController> {
  const VideoPlayerView({Key? key}) : super(key: key);
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
      body: SizedBox(
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
                    Icon(Icons.pause,
                      color: Colors.white,
                      size: 50,
                    ) : Icon(Icons.play_arrow,
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
    );
  }
}
