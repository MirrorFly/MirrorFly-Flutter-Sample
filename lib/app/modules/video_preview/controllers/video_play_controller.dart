


import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/utils.dart';
// import 'package:video_player/video_player.dart';

class VideoPlayController extends GetxController{

  var videoPath = "".obs;
  // late VideoPlayerController videoPlayerController;
  var isInitialized = false.obs;
  var isPlaying = false.obs;
  @override
  void onInit() {
    super.onInit();
    videoPath(NavUtils.arguments['filePath']);
    debugPrint("##path ${videoPath.value}");
    // videoPlayerController = VideoPlayerController.file(File(NavUtils.arguments['filePath']))
    //   ..initialize().then((_) {
    //     // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
    //     isInitialized(true);
    //   });
  }

  @override
  void onClose() {
    super.onClose();
    // isInitialized(false);
    videoPath("");
    // videoPlayerController.dispose();
  }

  // togglePlay() {
  //   if(videoPlayerController.value.isPlaying){
  //     // videoPlayerController.pause();
  //     isPlaying(false);
  //   }else{
  //
  //     isPlaying(true);
  //     // videoPlayerController.play();
  //
  //   }
  // }
}