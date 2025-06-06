
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/mention_text_field/mention_tag_text_field.dart';
import 'package:mirror_fly_demo/app/data/mention_utils.dart';
import 'package:mirror_fly_demo/app/modules/chat/views/mention_list_view.dart';
import '../../../common/app_localizations.dart';
import '../../../common/constants.dart';
import '../../../extensions/extensions.dart';
import '../../../modules/gallery_picker/controllers/gallery_picker_controller.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import '../../../app_style_config.dart';
import '../../../common/main_controller.dart';
import '../../../data/utils.dart';
import '../../../routes/route_settings.dart';
import '../../chat/controllers/chat_controller.dart';
import '../../gallery_picker/src/data/models/picked_asset_model.dart';

class MediaPreviewController extends FullLifeCycleController with FullLifeCycleMixin {

  var userName = NavUtils.arguments['userName'];
  var profile = NavUtils.arguments['profile'] as ProfileDetails;

  MentionTagTextEditingController caption = MentionTagTextEditingController();

  var filePath = <PickedAssetModel>[].obs;

  var pickerType = Constants.camera.obs;

  var captionMessage = (NavUtils.arguments['captionMessage'] as List<String>).obs;
  var captionMessageMentions = (NavUtils.arguments['captionMessageMentions'] as List<List<String>>).obs;
  var from = NavUtils.arguments['from'];
  var userJid = NavUtils.arguments['userJid'];
  var showAdd = NavUtils.arguments['showAdd'] ?? true;
  var currentPageIndex = 0.obs;
  var isFocused = false.obs;
  var showEmoji = false.obs;

  FocusNode captionFocusNode = FocusNode();
  PageController pageViewController = PageController(initialPage: 0, keepPage: false);

  final Map<int, File> imageCache = {};

  @override
  void onInit() {
    super.onInit();
    SchedulerBinding.instance
        .addPostFrameCallback((_) {
      pickerType(NavUtils.arguments['from']);
      debugPrint("pickerType $pickerType");
      // if(pickerType.value == Constants.gallery) {
        debugPrint("pickerType inside gallery type");
        filePath(NavUtils.arguments['filePath']);
      LogMessage.d("initial ","text: ${captionMessage.join(",")}, tags: ${captionMessageMentions.join(",")}");
      // _loadFiles();
    });
    if(captionMessage.isNotEmpty) {
      setMediaCaptionText(captionMessage[0], captionMessageMentions[0]);
    }
    captionFocusNode.addListener(() {
      if (captionFocusNode.hasFocus) {
        showEmoji(false);
      }else{
        showOrHideTagListView(false, Routes.galleryPicker);
      }
    });
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
    updateCaptionsArray();
  }

  void onUserTagClicked(ProfileDetails profile,MentionTagTextEditingController controller,String tag){
    // controller.addTag(id: profile.jid.checkNull().split("@")[0], name: profile.getName());
    controller.addMention(label: profile.getName(),data: profile.jid.checkNull().split("@")[0],stylingWidget: Text('@${profile.getName()}',style: const TextStyle(color: Colors.blueAccent),));
    showOrHideTagListView(false, tag);
    updateCaptionsArray();
  }

  Future<void> sendMedia() async {
    debugPrint("send media");
    var previousRoute = NavUtils.previousRoute;
    Platform.isIOS ? DialogUtils.showLoading(message: getTranslated("compressingFiles"),dialogStyle: AppStyleConfig.dialogStyle) : DialogUtils.progressLoading();
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
          await Get.find<ChatController>(tag: userJid).sendImageMessage(
              imageCache[i]?.path, captionMessage[i], "",captionMessageMentions[i]);
        } else if (data.type == 'video') {
          if (!availableFeatures.value.isVideoAttachmentAvailable.checkNull()) {
            featureNotAvailable = true;
            return false;
          }
          debugPrint("sending video");
          await Get.find<ChatController>(tag: userJid).sendVideoMessage(
              imageCache[i]!.path, captionMessage[i], "",captionMessageMentions[i]);
        }
        i++;
      });
    }finally {
      debugPrint("finally $featureNotAvailable");
      DialogUtils.hideLoading();
      if (!featureNotAvailable) {
        if (previousRoute == Routes.galleryPicker) {
          NavUtils.back();
        }
        NavUtils.back();
      } else {
        DialogUtils.showFeatureUnavailable();
      }
    }
  }

  void deleteMedia() {
    LogMessage.d("currentPageIndex : ",currentPageIndex);
    var provider = Get.find<GalleryPickerController>().provider;
    provider.unPick(currentPageIndex.value);
    filePath.removeAt(currentPageIndex.value);
    imageCache.removeWhere((k,v)=>k == currentPageIndex.value);
    removeCaptionsArray(currentPageIndex.value);
    if(currentPageIndex.value > 0) {
      currentPageIndex(currentPageIndex.value - 1);
      LogMessage.d("currentPageIndex.value.toDouble()", currentPageIndex.value.toDouble());
      pageViewController.animateToPage(currentPageIndex.value, duration: const Duration(milliseconds: 5), curve: Curves.easeInOut);
      setMediaCaptionText(captionMessage[currentPageIndex.value],captionMessageMentions[currentPageIndex.value]);
    }else if (currentPageIndex.value == 0){
      setMediaCaptionText(captionMessage[currentPageIndex.value],captionMessageMentions[currentPageIndex.value]);
    }
  }

  Future<void> setMediaCaptionText(String content,List<String> mentionedUsersIds) async {
    LogMessage.d("setMediaCaptionText $content",mentionedUsersIds);
    if(content.isNotEmpty) {
      var profileDetails = await MentionUtils.getProfileDetailsOfUsername(
          mentionedUsersIds);
      caption.setCustomText(content, profileDetails);
    }else{
      caption.setCustomText(Constants.emptyString, []);
    }
  }

  void onMediaPreviewPageChanged(int value) {
    LogMessage.d("onMediaPreviewPageChanged ",value.toString());
    captionFocusNode.unfocus();
    currentPageIndex(value);
    setMediaCaptionText(captionMessage[value],captionMessageMentions[value]);
  }

  void onCaptionTyped(String value) {
    LogMessage.d("onCaptionTyped ","index: ${currentPageIndex.value}, text: ${caption.formattedText}, tags: ${caption.getTags}");
    // updateCaptionsArray();
  }

  void updateCaptionsArray(){
    LogMessage.d("updateCaptionsArray ","index: ${currentPageIndex.value}, text: ${caption.formattedText}, tags: ${caption.getTags}");
    captionMessage[currentPageIndex.value] = caption.formattedText;
    captionMessageMentions[currentPageIndex.value] = caption.getTags;
  }

  void removeCaptionsArray(int index){
    captionMessage.removeAt(index);
    captionMessageMentions.removeAt(index);
  }

  void filterMentionUsers(String triggerCharacter,String? query,String tag) {
    if (Get.isRegistered<MentionController>(tag: tag)) {
      Get.find<MentionController>(tag: tag).filterMentionUsers(triggerCharacter, query);
    }
  }

  void showOrHideTagListView(bool show,String tag){
    if (Get.isRegistered<MentionController>(tag: tag)) {
      Get.find<MentionController>(tag: tag).showOrHideTagListView(show);
    }
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
