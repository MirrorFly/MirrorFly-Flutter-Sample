// import 'package:better_video_player/better_video_player.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../modules/video_preview/controllers/video_play_controller.dart';

import '../../../extensions/extensions.dart';
import '../../../widgets/video_player_widget.dart';

class VideoPlayerView extends NavViewStateful<VideoPlayController> {
  const VideoPlayerView({Key? key}) : super(key: key);

  @override
  VideoPlayController createController({String? tag}) => Get.put(VideoPlayController());

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
