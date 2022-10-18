import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../../../model/chatMessageModel.dart';
import '../../../nativecall/platformRepo.dart';
import 'chat_controller.dart';

class ImagePreviewController extends GetxController {
  // var filePath = Get.arguments['filePath'];
  var userName = Get.arguments['userName'];

  TextEditingController caption = TextEditingController();

  var filePath = "".obs;

  @override
  void onInit() {
    super.onInit();
    SchedulerBinding.instance.addPostFrameCallback((_) => filePath(Get.arguments['filePath']));
  }

  sendImageMessage() async{

     var response = await Get.find<ChatController>().sendImageMessage(filePath.value, caption.text , "");
     debugPrint("Preview View ==> $response");
     if(response != null){
       Get.back();
     }
   }

}