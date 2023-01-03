import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../../../common/constants.dart';
import '../../../data/apputils.dart';
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

  sendImageMessage() async {
    if (File(filePath.value).existsSync()) {
      if(await AppUtils.isNetConnected()) {
        var response = await Get.find<ChatController>().sendImageMessage(
            filePath.value, caption.text, "");
        debugPrint("Preview View ==> $response");
        if (response != null) {
          Get.back();
        }
      }else{
        toToast(Constants.noInternetConnection);
      }
    } else {
      debugPrint("File Not Found For Image Upload");
    }
  }

}