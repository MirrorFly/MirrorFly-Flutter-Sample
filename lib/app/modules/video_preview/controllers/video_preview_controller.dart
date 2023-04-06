import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../chat/controllers/chat_controller.dart';

class VideoPreviewController extends GetxController {
  late VideoPlayerController videoPlayerController;

  var isInitialized = false.obs;
  var isPlaying = false.obs;
  var userName = "";
  var videoPath = "";
  var textMessage = "";

  TextEditingController caption = TextEditingController();

  var seekTo = const Duration(seconds: 0).obs;
  @override
  Future<void> onInit() async {
    super.onInit();
    userName = Get.arguments['userName'];
    videoPath = Get.arguments['filePath'];
    textMessage = Get.arguments['caption'];
    debugPrint("caption text received--> $textMessage");
    caption.text = textMessage;
    videoPlayerController = VideoPlayerController.file(File(Get.arguments['filePath']))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        isInitialized(true);
      });
    videoPlayerController.addListener(() {
      if(!videoPlayerController.value.isPlaying){
        isPlaying(false);
        seekTo(const Duration(seconds: 0));
      }else{
        isPlaying(videoPlayerController.value.isPlaying);
      }
    });
  }


  @override
  void onClose() {
    super.onClose();
    isInitialized(false);
    videoPlayerController.dispose();
  }

   togglePlay() {
     if(isPlaying.value){
       videoPlayerController.pause();
       seekTo(videoPlayerController.value.position);
       isPlaying(false);
     }else{
       isPlaying(true);
       videoPlayerController.seekTo(seekTo.value);
      videoPlayerController.play();
     }
   }

   sendVideoMessage() async{
     // if(await AppUtils.isNetConnected()) {
       var response = await Get.find<ChatController>().sendVideoMessage(videoPath, caption.text , "");
       debugPrint("Preview View ==> $response");
       if(response != null){
         Get.back();
       }
    /* }else{
       toToast(Constants.noInternetConnection);
     }*/

   }

}
