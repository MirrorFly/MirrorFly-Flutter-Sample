import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../chat/controllers/chat_controller.dart';

class VideoPreviewController extends GetxController {
  //TODO: Implement VideoPreviewController
  late VideoPlayerController videoPlayerController;

  var isInitialized = false.obs;
  var isPlaying = false.obs;
  var userName = "";
  var videoPath = "";

  TextEditingController caption = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    userName = Get.arguments['userName'];
    videoPath = Get.arguments['filePath'];
    videoPlayerController = VideoPlayerController.file(File(Get.arguments['filePath']))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        isInitialized(true);
      });
  }


  @override
  void onClose() {
    super.onClose();
    isInitialized(false);
    videoPlayerController.dispose();
  }

   togglePlay() {
     if(videoPlayerController.value.isPlaying){
       videoPlayerController.pause();
       isPlaying(false);
     }else{

       isPlaying(true);
       videoPlayerController.play();

     }
   }

   sendVideoMessage() async{
     var response = await Get.find<ChatController>().sendVideoMessage(videoPath, caption.text , "");
     debugPrint("Preview View ==> $response");
     if(response != null){
       Get.back();
     }
   }

}
