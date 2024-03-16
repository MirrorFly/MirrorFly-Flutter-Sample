
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:mirror_fly_demo/app/modules/gallery_picker/controllers/gallery_picker_controller.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';
import 'package:mirror_fly_demo/app/common/extensions.dart';
import 'package:get/get.dart';

import '../../../common/constants.dart';
import '../../../common/main_controller.dart';
import '../../../data/helper.dart';
import '../../../routes/app_pages.dart';
import '../../chat/controllers/chat_controller.dart';
import '../../gallery_picker/src/data/models/picked_asset_model.dart';

class MediaPreviewController extends FullLifeCycleController with FullLifeCycleMixin {
  var provider = Get.find<GalleryPickerController>().provider;

  var userName = Get.arguments['userName'];
  var profile = Get.arguments['profile'] as ProfileDetails;

  TextEditingController caption = TextEditingController();

  var filePath = <PickedAssetModel>[].obs;

  var captionMessage = <String>[].obs;
  var textMessage = Get.arguments['caption'];
  var from = Get.arguments['from'];
  var showAdd = Get.arguments['showAdd'] ?? true;
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
    captionFocusNode.addListener(() {
      if (captionFocusNode.hasFocus) {
        showEmoji(false);
      }
    });
  }
  onChanged() {
    // count(139 - addStatusController.text.length);
  }

  sendMedia() async {
    debugPrint("send media");
    var previousRoute = Get.previousRoute;
    // if (await AppUtils.isNetConnected()) {
    var featureNotAvailable = false;
    try {
      int i = 0;
      Platform.isIOS ? Helper.showLoading(message: "Compressing files") : null;
      for (var data in filePath) {
        /// show image
        debugPrint(data.type);
        if (data.type == 'image') {
          if(!availableFeatures.value.isImageAttachmentAvailable.checkNull()){
            featureNotAvailable=true;
            break;
          }
          debugPrint("sending image");
          var response = await Get.find<ChatController>()
              .sendImageMessage(data.path, captionMessage[i], "");
          debugPrint("Preview View ==> $response");
          if (response != null) {
            debugPrint("Image send Success");
          }
        } else if (data.type == 'video') {
          if(!availableFeatures.value.isVideoAttachmentAvailable.checkNull()){
            featureNotAvailable = true;
            break;
          }
          debugPrint("sending video");
          var response = await Get.find<ChatController>()
              .sendVideoMessage(data.path!, captionMessage[i], "");
          debugPrint("Preview View ==> $response");
          if (response != null) {
            debugPrint("Video send Success");
          }
        }
        i++;
      }
    } finally {
      debugPrint("finally $featureNotAvailable");
      Platform.isIOS ? Helper.hideLoading() : null;
      if(!featureNotAvailable) {
        if (previousRoute == Routes.galleryPicker) {
          Get.back();
        }
        Get.back();
      }else{
        Helper.showFeatureUnavailable();
      }
    }
    // Get.back();
    /*} else {
      toToast(Constants.noInternetConnection);
    }*/
    // debugPrint("caption text-> $captionMessage");
  }

  void deleteMedia() {
    LogMessage.d("currentPageIndex : ",currentPageIndex);
    provider.unPick(currentPageIndex.value);
    filePath.removeAt(currentPageIndex.value);
    captionMessage.removeAt(currentPageIndex.value);
    if(currentPageIndex.value > 0) {
      currentPageIndex(currentPageIndex.value - 1);
      LogMessage.d("currentPageIndex.value.toDouble()", currentPageIndex.value.toDouble());
      pageViewController.animateToPage(currentPageIndex.value, duration: const Duration(milliseconds: 5), curve: Curves.easeInOut);
      caption.text = captionMessage[currentPageIndex.value];
    }else if (currentPageIndex.value == 0){
      caption.text = captionMessage[currentPageIndex.value];
    }
  }

  void onMediaPreviewPageChanged(int value) {
    LogMessage.d("onMediaPreviewPageChanged ",value.toString());
    currentPageIndex(value);
    caption.text = captionMessage[value];
    captionFocusNode.unfocus();
  }

  void onCaptionTyped(String value) {
    LogMessage.d("onCaptionTyped ",captionMessage.length);
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

  var availableFeatures = Get.find<MainController>().availableFeature;
  void onAvailableFeaturesUpdated(AvailableFeatures features) {
    LogMessage.d("MediaPreview", "onAvailableFeaturesUpdated ${features.toJson()}");
    availableFeatures(features);
  }

  @override
  void onHidden() {

  }
}
