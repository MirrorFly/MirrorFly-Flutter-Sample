
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:fly_chat/flysdk.dart';
import 'package:get/get.dart';

import '../../../common/constants.dart';
import '../../../data/helper.dart';
import '../../chat/controllers/chat_controller.dart';

class MediaPreviewController extends FullLifeCycleController with FullLifeCycleMixin {

  var userName = Get.arguments['userName'];
  var profile = Get.arguments['profile'] as Profile;

  TextEditingController caption = TextEditingController();

  var filePath = [].obs;

  var captionMessage = <String>[].obs;
  var textMessage = Get.arguments['caption'];
  var currentPageIndex = 0.obs;
  var isFocused = false.obs;
  var showEmoji = false.obs;

  FocusNode captionFocusNode = FocusNode();
  PageController pageViewController = PageController(initialPage: 0, keepPage: false);

  @override
  void onInit() {
    super.onInit();
    SchedulerBinding.instance
        .addPostFrameCallback((_) {
          filePath(Get.arguments['filePath']);
          var index = 0;
          for(var _ in filePath){
            if(index == 0 && textMessage != null){
              captionMessage.add(textMessage);
              index = index + 1;
            }else {
              captionMessage.add("");
            }
          }
    });
    if(textMessage != null){
      caption.text = textMessage;
    }
  }
  onChanged() {
    // count(139 - addStatusController.text.length);
  }

  sendMedia() async {
    debugPrint("send media");
    // if (await AppUtils.isNetConnected()) {
      try {
        int i = 0;
        Platform.isIOS ? Helper.showLoading(message: "Compressing files") : null;
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
        Platform.isIOS ? Helper.hideLoading() : null;
        Get.back();
        Get.back();
      }
      // Get.back();
    /*} else {
      toToast(Constants.noInternetConnection);
    }*/
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

  @override
  void onPaused() {}

  @override
  void onResumed() {
    mirrorFlyLog("LifeCycle", "onResumed");
    if(!KeyboardVisibilityController().isVisible) {
      if (captionFocusNode.hasFocus) {
        captionFocusNode.unfocus();
        Future.delayed(const Duration(milliseconds: 100), () {
          captionFocusNode.requestFocus();
        });
      }
    }
  }

  @override
  void onDetached() {}

  @override
  void onInactive() {}
}
