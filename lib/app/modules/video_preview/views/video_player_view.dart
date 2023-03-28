import 'package:better_video_player/better_video_player.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/modules/video_preview/controllers/video_play_controller.dart';

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
        body: SafeArea(
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 0.6,
                child: BetterVideoPlayer(
                    configuration:
                    const BetterVideoPlayerConfiguration(
                      looping: false,
                      autoPlay: false,
                      allowedScreenSleep: false,
                      autoPlayWhenResume: false,
                    ),
                    controller:
                    BetterVideoPlayerController(),
                    dataSource: BetterVideoPlayerDataSource(
                      BetterVideoPlayerDataSourceType.file,
                      controller.videoPath.value,
                    ),
                  ),
              ),
            ],
          ),
        ),
    );
  }
}
