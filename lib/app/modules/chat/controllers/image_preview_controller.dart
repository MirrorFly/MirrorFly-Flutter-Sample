import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../../../data/utils.dart';
import 'chat_controller.dart';

class ImagePreviewController extends GetxController {
  // var filePath = NavUtils.arguments['filePath'];
  var userName = NavUtils.arguments['userName'];

  TextEditingController caption = TextEditingController();

  var filePath = "".obs;

  var textMessage = "";

  @override
  void onInit() {
    super.onInit();

    textMessage = NavUtils.arguments['caption'];
    // debugPrint("caption text received--> $textMessage");
    caption.text = textMessage;
    SchedulerBinding.instance.addPostFrameCallback((_) => filePath(NavUtils.arguments['filePath']));
  }

  sendImageMessage() async {
    if (File(filePath.value).existsSync()) {
      // if(await AppUtils.isNetConnected()) {
        var response = await Get.find<ChatController>().sendImageMessage(
            filePath.value, caption.text, "");
        // debugPrint("Preview View ==> $response");
        if (response != null) {
          NavUtils.back();
        }
      // }else{
      //   toToast(getTranslated("noInternetConnection"));
      // }
    } else {
      debugPrint("File Not Found For Image Upload");
    }
  }

}