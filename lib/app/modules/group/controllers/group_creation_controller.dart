import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../common/app_localizations.dart';
import '../../../common/constants.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import '../../../app_style_config.dart';
import '../../../common/crop_image.dart';
import '../../../data/permissions.dart';
import '../../../data/utils.dart';
import '../../../model/arguments.dart';
import '../../../routes/route_settings.dart';

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
      //NavUtils.toNamed(Routes.ADD_PARTICIPANTS);
      NavUtils.toNamed(Routes.contacts, arguments: const ContactListArguments(forGroup:true)
          /*{"forward" : false,"group":true,"groupJid":"" }*/)?.then((value){
        if(value!=null){
          createGroup(value as List<String>);
        }
      });
    }else{
      toToast(getTranslated("pleaseProvideGroupName"));
    }
  }

  showHideEmoji(){
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


  Future imagePick() async {
    if(await AppPermission.getStoragePermission()) {
      FilePickerResult? result = await FilePicker.platform
          .pickFiles(allowMultiple: false, type: FileType.image);
      if (result != null) {
        // isImageSelected.value = true;
        NavUtils.to(CropImage(
          imageFile: File(result.files.single.path!),
        ))?.then((value) {
          if (value != null) {
            value as MemoryImage;
            // imageBytes = value.bytes;
            var name = "${DateTime
                .now()
                .millisecondsSinceEpoch}.jpg";
            MessageUtils.writeImageTemp(value.bytes, name).then((value) {
              imagePath(value.path);
            });
          }
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
      NavUtils.to(CropImage(
        imageFile: File(photo.path),
      ))?.then((value) {
        if (value != null) {
          value as MemoryImage;
          // imageBytes = value.bytes;
          var name = "${DateTime
              .now()
              .millisecondsSinceEpoch}.jpg";
          MessageUtils.writeImageTemp(value.bytes, name).then((value) {
            imagePath(value.path);
          });
        }
      });
    } else {
      // User canceled the Camera
      // isImageSelected.value = false;
    }
  }

  createGroup(List<String> users,){
    LogMessage.d("group name", groupName.text);
    LogMessage.d("users", users.toString());
    LogMessage.d("group image", imagePath.value);
    DialogUtils.showLoading(dialogStyle: AppStyleConfig.dialogStyle);
    Mirrorfly.createGroup(groupName: groupName.text.toString(),userList: users,image: imagePath.value, flyCallBack: (FlyResponse response) {
      DialogUtils.hideLoading();
      if(response.isSuccess) {
        NavUtils.back();
        toToast(getTranslated("groupCreatedSuccessfully"));
      }
    });
  }

  void choosePhoto() {
    DialogUtils.showVerticalButtonAlert(actions:[
      ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        onTap: () {
          NavUtils.back();
          imagePick();
        },
        title: Text(
          getTranslated("chooseFromGallery"),
          style: const TextStyle(color: textBlackColor, fontSize: 14),
        ),
      ),
      ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        onTap: () {
          NavUtils.back();
          camera();
        },
        title: Text(
          getTranslated("takePhoto"),
          style: const TextStyle(color: textBlackColor, fontSize: 14),
        ),
      ),
    ]);
  }
}