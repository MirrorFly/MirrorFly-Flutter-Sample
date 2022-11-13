import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/nativecall/platformRepo.dart';
import 'package:mirror_fly_demo/app/routes/app_pages.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';

import '../../../common/cropimage.dart';

class GroupCreationController extends GetxController {
  var imagepath = "".obs;
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
    _count((25 - groupName.text.length));
  }
  goToAddParticipantsPage(){
    if(groupName.text.trim().isNotEmpty) {
      //Get.toNamed(Routes.ADD_PARTICIPANTS);
      Get.toNamed(Routes.CONTACTS, arguments: {"forward" : false,"group":true,"groupJid":"" })?.then((value){
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
      FocusScope.of(context).unfocus();
      focusNode.canRequestFocus = false;
    }
    Future.delayed(const Duration(milliseconds: 500), () {
      showEmoji(!showEmoji.value);
    });
  }


  Future ImagePicker(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowMultiple: false, type: FileType.image);
    if (result != null) {
      // isImageSelected.value = true;
      Get.to(CropImage(
        imageFile: File(result.files.single.path!),
      ))?.then((value) {
        value as MemoryImage;
        // imageBytes = value.bytes;
        var name ="${DateTime.now().millisecondsSinceEpoch}.jpg";
        writeImageTemp(value.bytes, name).then((value) {
          imagepath(value.path);
        });
      });
    } else {
      // User canceled the picker
      // isImageSelected.value = false;
    }
  }

  Camera(XFile? result) {
    if (result != null) {
      // isImageSelected.value = true;
      Get.to(CropImage(
        imageFile: File(result.path),
      ))?.then((value) {
        value as MemoryImage;
        // imageBytes = value.bytes;
        var name ="${DateTime.now().millisecondsSinceEpoch}.jpg";
        writeImageTemp(value.bytes, name).then((value) {
          imagepath(value.path);
        });
      });
    } else {
      // User canceled the Camera
      // isImageSelected.value = false;
    }
  }

  createGroup(List<String> users,){
    Log("groupname", groupName.text);
    Log("users", users.toString());
    Log("groupimage", imagepath.value);
    Helper.showLoading();
    PlatformRepo().createGroup(groupName.text.toString(),users,imagepath.value).then((value){
      Helper.hideLoading();
      if(value!=null) {
        Get.back();
      }
    });
  }
}