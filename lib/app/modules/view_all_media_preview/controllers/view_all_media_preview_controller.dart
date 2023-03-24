
import 'package:flutter/material.dart';
import 'package:fly_chat/flysdk.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class ViewAllMediaPreviewController extends GetxController {


  var previewMediaList = List<ChatMessageModel>.empty(growable: true).obs;
  var index = 0.obs;
  late PageController pageViewController;
  var title = "Sent Media".obs;

  @override
  void onInit() {
    super.onInit();
    previewMediaList.addAll(Get.arguments['images']);
    index(Get.arguments['index']);
    pageViewController = PageController(initialPage: index.value, keepPage: false);
  }

  shareMedia() {
    var mediaItem = previewMediaList.elementAt(index.value).mediaChatMessage!.mediaLocalStoragePath;
    Share.shareXFiles([XFile(mediaItem)]);
  }

  void onMediaPreviewPageChanged(int value) {
    index(value);
    setTitle(value);
  }

  void setTitle(int index) {
    if(previewMediaList.elementAt(index).isMessageSentByMe){
      title("Sent Media");
    }else{
      title("Received Media");
    }
  }
}
