
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/modules/gallery_picker/controllers/gallery_picker_controller.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';
import 'package:mirror_fly_demo/app/common/extensions.dart';
import 'package:get/get.dart';

import '../../../common/main_controller.dart';
import '../../../data/helper.dart';
import '../../../routes/route_settings.dart';
import '../../chat/controllers/chat_controller.dart';
import '../../gallery_picker/src/data/models/picked_asset_model.dart';

class MediaPreviewController extends FullLifeCycleController with FullLifeCycleMixin {

  var userName = Get.arguments['userName'];
  var profile = Get.arguments['profile'] as ProfileDetails;

  TextEditingController caption = TextEditingController();

  var filePath = <PickedAssetModel>[].obs;

  var pickerType = Constants.camera.obs;

  var captionMessage = <String>[].obs;
  var textMessage = Get.arguments['caption'];
  var from = Get.arguments['from'];
  var showAdd = Get.arguments['showAdd'] ?? true;
  var currentPageIndex = 0.obs;
  var isFocused = false.obs;
  var showEmoji = false.obs;

  FocusNode captionFocusNode = FocusNode();
  PageController pageViewController = PageController(initialPage: 0, keepPage: false);

  final Map<int, File> imageCache = {};
  final Map<int, File> imageCache1 = {};

  @override
  void onInit() {
    super.onInit();
    SchedulerBinding.instance
        .addPostFrameCallback((_) {
      pickerType(Get.arguments['from']);
      debugPrint("pickerType $pickerType");
      // if(pickerType.value == Constants.gallery) {
        debugPrint("pickerType inside gallery type");
        filePath(Get.arguments['filePath']);
      // }else{
      //   debugPrint("pickerType inside camera type");
      //   cameraFilePath(Get.arguments['filePath']);
      // }
      var index = 0;
      for(var _ in filePath){
        if(index == 0 && textMessage != null){
          captionMessage.add(textMessage);
          index = index + 1;
        }else {
          captionMessage.add("");
        }
      }
      // _loadFiles();
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

  Future<void> _loadFiles() async {
    int index = 0;
    for (var pickedAssetModel in filePath) {
      try {
        File? file = await _getFileFromAsset(pickedAssetModel);
        if (file != null) {
          imageCache[index] = file;
        }
      } catch (e) {
        debugPrint("Failed to load file: $e");
      }
      index++;
    }
  }
  Future<File?> _getFileFromAsset(PickedAssetModel pickedAssetModel) async {
    return await pickedAssetModel.asset?.file;
  }

  checkCacheFile(int index){
    if (imageCache.containsKey(index)) {
      debugPrint("returning true");
      return true;
    }
    debugPrint("returning false");
    return false;
  }

  getCacheFile(int index){
    return imageCache[index];
  }

  // Future<File?> getFile(int index) async {
  //   if (imageCache.containsKey(index)) {
  //     return imageCache[index];
  //   } else if(pickerType.value == Constants.gallery){
  //     debugPrint("getFile inside gallery file type");
  //     File? file = await filePath[index].asset?.file;
  //     if (file != null) {
  //       imageCache[index] = file;
  //     }
  //     return file;
  //   }else{
  //     debugPrint("getFile inside camera file type");
  //     imageCache[index] = filePath[index].file!;
  //     return filePath[index].file;
  //   }
  // }
  Future<File?> getFile(int index) async {
    if (imageCache.containsKey(index)) {
      return imageCache[index];
    } else {
      File? file;
      try {
        debugPrint("getFile attempt for index: $index");
        if (pickerType.value == Constants.gallery) {
          file = await filePath[index].asset?.file;
        } else {
          file = filePath[index].file;
        }
        if (file != null) {
          imageCache[index] = file;
        }
      } catch (e) {
        debugPrint("Error loading file for index $index: $e");
      }
      return file;
    }
  }
  onChanged() {
    // count(139 - addStatusController.text.length);

    //Adding the below code, to send the emoji in caption text
    captionMessage[currentPageIndex.value] = caption.text.toString();
  }

  Future<void> sendMedia() async {
    debugPrint("send media");
    var previousRoute = Get.previousRoute;
    Platform.isIOS ? Helper.showLoading(message: "Compressing files") : Helper.progressLoading();
    var featureNotAvailable = false;
    try {
      int i = 0;
      await Future.forEach(filePath, (data) async {
        // debugPrint(data.type);
        /// show image
        if (data.type == 'image') {
          if (!availableFeatures.value.isImageAttachmentAvailable.checkNull()) {
            featureNotAvailable = true;
            return false;
          }
          debugPrint("sending image");
          await Get.find<ChatController>().sendImageMessage(
              imageCache[i]?.path, captionMessage[i], "");
        } else if (data.type == 'video') {
          if (!availableFeatures.value.isVideoAttachmentAvailable.checkNull()) {
            featureNotAvailable = true;
            return false;
          }
          debugPrint("sending video");
          await Get.find<ChatController>().sendVideoMessage(
              imageCache[i]!.path, captionMessage[i], "");
        }
        i++;
      });
    }finally {
      debugPrint("finally $featureNotAvailable");
      Helper.hideLoading();
      if (!featureNotAvailable) {
        if (previousRoute == Routes.galleryPicker) {
          Get.back();
        }
        Get.back();
      } else {
        Helper.showFeatureUnavailable();
      }
    }
  }

  void deleteMedia() {
    LogMessage.d("currentPageIndex : ",currentPageIndex);
    var provider = Get.find<GalleryPickerController>().provider;
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
    LogMessage.d("LifeCycle", "onResumed");
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

  hideKeyBoard() {
    // FocusManager.instance.primaryFocus!.unfocus();
  }

}
