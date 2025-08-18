import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/utils.dart';
import '../../../model/chat_message_model.dart';

class ViewAllMediaPreviewController extends GetxController {
  var previewMediaList = List<ChatMessageModel>.empty(growable: true).obs;
  var index = 0.obs;
  late PageController pageViewController;
  var title = getTranslated("sentMedia").obs;

  @override
  void onInit() {
    super.onInit();
    previewMediaList.addAll(NavUtils.arguments['images']);
    index(NavUtils.arguments['index']);
    pageViewController =
        PageController(initialPage: index.value, keepPage: false);
  }

  shareMedia() {
    var mediaItem = previewMediaList
        .elementAt(index.value)
        .mediaChatMessage!
        .mediaLocalStoragePath
        .value;
    Share.shareXFiles([XFile(mediaItem)]);
  }

  void onMediaPreviewPageChanged(int value) {
    index(value);
    setTitle(value);
  }

  void setTitle(int index) {
    if (previewMediaList.elementAt(index).isMessageSentByMe) {
      title(getTranslated("sentMedia"));
    } else {
      title(getTranslated("receivedMedia"));
    }
  }
}
