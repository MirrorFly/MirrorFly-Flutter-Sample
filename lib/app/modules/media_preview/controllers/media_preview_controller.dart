
import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../../../common/constants.dart';
import '../../../data/apputils.dart';
import '../../chat/controllers/chat_controller.dart';

class MediaPreviewController extends GetxController {

  var userName = Get.arguments['userName'];

  TextEditingController caption = TextEditingController();

  var filePath = [].obs;

  @override
  void onInit() {
    super.onInit();
    SchedulerBinding.instance
        .addPostFrameCallback((_) => filePath(Get.arguments['filePath']));
  }

  sendMedia() async {
    debugPrint("send media");
    if (await AppUtils.isNetConnected()) {
      try {
        for (var data in filePath) {
          /// show image
          debugPrint(data.type);
          if (data.type == 'image') {
            debugPrint("sending image");
            var response = await Get.find<ChatController>()
                .sendImageMessage(data.path, caption.text, "");
            debugPrint("Preview View ==> $response");
            if (response != null) {
              debugPrint("Image send Success");
            }
          } else if (data.type == 'video') {
            debugPrint("sending video");
            var response = await Get.find<ChatController>()
                .sendVideoMessage(data.path, caption.text, "");
            debugPrint("Preview View ==> $response");
            if (response != null) {
              debugPrint("Video send Success");
            }
          }
        }
      } finally {
        Get.back();
        Get.back();
      }
      // Get.back();
    } else {
      toToast(Constants.noInternetConnection);
    }
  }
}
