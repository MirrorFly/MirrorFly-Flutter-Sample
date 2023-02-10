
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

  var captionMessage = <String>[].obs;

  var currentPageIndex = 0.obs;

  FocusNode captionFocusNode = FocusNode();
  PageController pageViewController = PageController(initialPage: 0, keepPage: false);

  @override
  void onInit() {
    super.onInit();
    SchedulerBinding.instance
        .addPostFrameCallback((_) {
          filePath(Get.arguments['filePath']);
          for(var _ in filePath){
            captionMessage.add("");
          }
    });

  }

  sendMedia() async {
    debugPrint("send media");
    if (await AppUtils.isNetConnected()) {
      try {
        int i = 0;
        for (var data in filePath) {
          /// show image
          debugPrint(data.type);
          if (data.type == 'image') {
            debugPrint("sending image");
            var response = await Get.find<ChatController>()
                .sendImageMessage(data.path, captionMessage[i], "");
            debugPrint("Preview View ==> $response");
            if (response != null) {
              debugPrint("Image send Success");
            }
          } else if (data.type == 'video') {
            debugPrint("sending video");
            var response = await Get.find<ChatController>()
                .sendVideoMessage(data.path, captionMessage[i], "");
            debugPrint("Preview View ==> $response");
            if (response != null) {
              debugPrint("Video send Success");
            }
          }
          i++;
        }
      } finally {
        Get.back();
        Get.back();
      }
      // Get.back();
    } else {
      toToast(Constants.noInternetConnection);
    }
    // debugPrint("caption text-> $captionMessage");
  }

  void deleteMedia() {
    filePath.removeAt(currentPageIndex.value);
    captionMessage.removeAt(currentPageIndex.value);
    // captionMessage.refresh();
    // filePath.refresh();
    caption.text = captionMessage[currentPageIndex.value];
  }

  void onCaptionTyped(String value) {
    debugPrint("length--> ${captionMessage.length}");
    captionMessage[currentPageIndex.value] = value;
  }
}
