// import 'package:better_video_player/better_video_player.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/modules/video_preview/controllers/video_play_controller.dart';

import '../../../widgets/video_player_widget.dart';

class VideoPlayerView extends GetView<VideoPlayController> {
  const VideoPlayerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: VideoPlayerWidget(
          videoPath: controller.videoPath.value,
          videoTitle: "Video",
        ),
      ),
    );
  }
}
