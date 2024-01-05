import 'dart:io';

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
    debugPrint("length--> ${groupName.text.length}");
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
    Mirrorfly.createGroup(groupName.text.toString(),users,imagePath.value).then((value){
      Helper.hideLoading();
      if(value!=null) {
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