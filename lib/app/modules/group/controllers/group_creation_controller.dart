import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';
import 'package:mirror_fly_demo/app/routes/app_pages.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';

import '../../../common/crop_image.dart';
import '../../../data/permissions.dart';

class GroupCreationController extends GetxController {
  var imagePath = "".obs;
  var userImgUrl = "".obs;
  var name = "".obs;
  var loading = false.obs;

  final _count= 25.obs;
  set count(value) => _count.value = value;
  get count => _count.value.toString();

  // group name
  TextEditingController groupName = TextEditingController();
  FocusNode focusNode = FocusNode();
  var showEmoji = false.obs;

  @override
  void onInit(){
    super.onInit();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        showEmoji(false);
      }
    });
  }

  onGroupNameChanged(){
    debugPrint("text changing");
    debugPrint("length--> ${groupName.text.characters.length}");
    _count((25 - groupName.text.characters.length));
  }

  onEmojiBackPressed(){
    var text = groupName.text;
    var cursorPosition = groupName.selection.base.offset;

    // If cursor is not set, then place it at the end of the textfield
    if (cursorPosition < 0) {
      groupName.selection = TextSelection(
        baseOffset: groupName.text.length,
        extentOffset: groupName.text.length,
      );
      cursorPosition = groupName.selection.base.offset;
    }

    if (cursorPosition >= 0) {
      final selection = groupName.value.selection;
      final newTextBeforeCursor =
      selection.textBefore(text).characters.skipLast(1).toString();
      LogMessage.d("newTextBeforeCursor", newTextBeforeCursor);
      groupName
        ..text = newTextBeforeCursor + selection.textAfter(text)
        ..selection = TextSelection.fromPosition(
            TextPosition(offset: newTextBeforeCursor.length));
    }
    _count((25 - groupName.text.characters.length));
  }

  onEmojiSelected(Emoji emoji){
    if(groupName.text.characters.length < 25){
      final controller = groupName;
      final text = controller.text;
      final selection = controller.selection;
      final cursorPosition = controller.selection.base.offset;

      if (cursorPosition < 0) {
        controller.text += emoji.emoji;
        // widget.onEmojiSelected?.call(category, emoji);
        return;
      }

      final newText =
      text.replaceRange(selection.start, selection.end, emoji.emoji);
      final emojiLength = emoji.emoji.length;
      controller
        ..text = newText
        ..selection = selection.copyWith(
          baseOffset: selection.start + emojiLength,
          extentOffset: selection.start + emojiLength,
        );
    }
    _count((25 - groupName.text.characters.length));
  }

  goToAddParticipantsPage(){
    if(groupName.text.trim().isNotEmpty) {
      //Get.toNamed(Routes.ADD_PARTICIPANTS);
      Get.toNamed(Routes.contacts, arguments: {"forward" : false,"group":true,"groupJid":"" })?.then((value){
        if(value!=null){
          createGroup(value as List<String>);
        }
      });
    }else{
      toToast("Please provide group name");
    }
  }

  showHideEmoji(BuildContext context){
    if (!showEmoji.value) {
      focusNode.unfocus();
    }else{
      focusNode.requestFocus();
      return;
    }
    Future.delayed(const Duration(milliseconds: 500), () {
      showEmoji(!showEmoji.value);
    });
  }


  Future imagePick(BuildContext context) async {
    if(await AppPermission.getStoragePermission()) {
      FilePickerResult? result = await FilePicker.platform
          .pickFiles(allowMultiple: false, type: FileType.image);
      if (result != null) {
        // isImageSelected.value = true;
        Get.to(CropImage(
          imageFile: File(result.files.single.path!),
        ))?.then((value) {
          value as MemoryImage;
          // imageBytes = value.bytes;
          var name = "${DateTime
              .now()
              .millisecondsSinceEpoch}.jpg";
          writeImageTemp(value.bytes, name).then((value) {
            imagePath(value.path);
          });
        });
      } else {
        // User canceled the picker
        // isImageSelected.value = false;
      }
    }
  }

  final ImagePicker _picker = ImagePicker();
  camera() async {
    final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera);
    if (photo != null) {
      // isImageSelected.value = true;
      Get.to(CropImage(
        imageFile: File(photo.path),
      ))?.then((value) {
        value as MemoryImage;
        // imageBytes = value.bytes;
        var name ="${DateTime.now().millisecondsSinceEpoch}.jpg";
        writeImageTemp(value.bytes, name).then((value) {
          imagePath(value.path);
        });
      });
    } else {
      // User canceled the Camera
      // isImageSelected.value = false;
    }
  }

  createGroup(List<String> users,){
    mirrorFlyLog("group name", groupName.text);
    mirrorFlyLog("users", users.toString());
    mirrorFlyLog("group image", imagePath.value);
    Helper.showLoading();
    Mirrorfly.createGroup(groupName: groupName.text.toString(),userList: users,image: imagePath.value, flyCallBack: (FlyResponse response) {
      Helper.hideLoading();
      if(response.isSuccess) {
        Get.back();
        toToast('Group created Successfully');
      }
    });
  }

  void choosePhoto() {
    Helper.showVerticalButtonAlert([
      TextButton(
          onPressed: () {
            Get.back();
            imagePick(Get.context!);
          },
          child: const Text("Choose from Gallery",style: TextStyle(color: Colors.black),)),
      TextButton(
          onPressed: () async{
            Get.back();
            camera();
          },
          child: const Text("Take Photo",style: TextStyle(color: Colors.black))),
    ]);
  }
}