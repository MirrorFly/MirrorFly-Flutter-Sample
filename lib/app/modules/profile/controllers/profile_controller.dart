import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_cropping/image_cropping.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/SessionManagement.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/model/profileupdate.dart';
import 'package:mirror_fly_demo/app/routes/app_pages.dart';
import 'package:path_provider/path_provider.dart';

import '../../../common/cropimage.dart';
import '../../../model/profileModel.dart';
import '../../../nativecall/platformRepo.dart';

class ProfileController extends GetxController {
  TextEditingController profileName = TextEditingController();
  TextEditingController profileEmail = TextEditingController();
  TextEditingController profileMobile = TextEditingController();
  var profileStatus = "".obs;
  var isImageSelected = false.obs;
  var isUserProfileRemoved = false.obs;
  var imagepath = "".obs;
  var userImgUrl = "".obs;

  var loading = false.obs;
  var changed = false.obs;

  dynamic imageBytes;
  var from=Routes.LOGIN.obs;

  var name = "".obs;


  @override
  void onInit() {
    super.onInit();
    userImgUrl.value  = SessionManagement().getUserImage() ?? "";
    print("auth : "+SessionManagement().getauthToken().toString());
    if (Get.arguments!=null) {
      from(Get.arguments["from"]);
      if(from.value==Routes.LOGIN) {
        profileMobile.text = Get.arguments['mobile'] ?? "";
      }
    } else {
      profileMobile.text = "";
    }
    getProfile();
    //profileStatus.value="I'm Mirrorfly user";
  }

  void save(){
    if(profileName.text.isEmpty){
      toToast("Enter Profile Name");
    }else if(profileEmail.text.isEmpty) {
      toToast("Enter Profile Email");
    }else if(profileStatus.value.isEmpty) {
     toToast("Enter Profile Status");
    }else{
      loading.value=true;
      if(imagepath.value.isNotEmpty){
        updateProfileImage(imagepath.value,update: true);
      }else {
        PlatformRepo().updateProfile(profileName.text.toString(),
            profileEmail.text.toString(),
            profileMobile.text.toString(),
            profileStatus.value.toString(),
            userImgUrl.value.isEmpty ? null : userImgUrl.value).then((value) {
          loading.value = false;
          if (value != null) {
            var data = profileUpdateFromJson(value);
            if (data.status != null) {
              toToast(data.message.toString());
              if (data.status!) {
                SessionManagement.setCurrentUser(data.data!);
                from.value == Routes.SETTINGS ? Get.back() : Get.offNamed(
                    Routes.DASHBOARD);
              }
            }
          }
        }).catchError((error) {
          loading.value = false;
          debugPrint("issue===> $error");
          toToast(error.toString());
        });
      }
    }
  }
  updateProfileImage(String path, {bool update = false}){
    loading.value=true;
    PlatformRepo().updateProfileImage(path).then((value){
      loading.value=false;
      var data = json.decode(value);
      imagepath.value = Constants.EMPTY_STRING;
      userImgUrl.value = data['data']['image'];
      SessionManagement.setUserImage(data['data']['image'].toString());
      if(update){
        save();
      }
    }).catchError((onError){
      loading.value=false;
    });
  }
  remomveProfileImage() {
    loading.value = true;
    PlatformRepo().removeProfileImage().then((value) {
      loading.value = false;
      if (value != null) {
        SessionManagement.setUserImage(Constants.EMPTY_STRING);
        isImageSelected.value = false;
        isUserProfileRemoved.value = true;
        userImgUrl(Constants.EMPTY_STRING);
        changed(true);
        update();
      }
    }).catchError((onError) {
      loading.value = false;
    });
  }


  getProfile(){
    var jid = SessionManagement().getUserJID().checkNull();
    Log("jid", jid);
    if(jid.isNotEmpty) {
      Log("jid.isNotEmpty", jid.isNotEmpty.toString());
      loading.value=true;
      PlatformRepo().getProfile(jid).then((value) {
        loading.value = false;
        var data = profileDataFromJson(value);
        if (data.status != null && data.status!) {
          if (data.data != null) {
            profileName.text = data.data!.name ?? "";
            profileMobile.text = data.data!.mobileNumber ?? "";
            profileEmail.text = data.data!.email ?? "";
            profileStatus.value = data.data!.status ?? "";
            userImgUrl.value =
                data.data!.image ?? SessionManagement().getUserImage() ?? "";
            changed((from.value==Routes.LOGIN));
            name(data.data!.name.toString());
            update();
          }
        } else {
          debugPrint("Unable to load Profile data");
        }
      }).catchError((onError) {
        loading.value = false;
      });
    }
  }

  Future ImagePicker(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: false,type: FileType.image);
    if (result != null) {
      isImageSelected.value = true;
      Get.to(CropImage(imageFile: File(result.files.single.path!),))?.then((value){
        value as MemoryImage;
        imageBytes = value.bytes;
        writeImageTemp(value.bytes,"profile.jpg").then((value){
          imagepath(value.path);
          changed(true);
          updateProfileImage(value.path);
        });
      });
      /*var imgBytes = await File(result.files.single.path!).readAsBytes();
      ImageCropping.cropImage(
          context: context,
          imageBytes: imgBytes,
          onImageDoneListener: (data) {
            imageBytes = data;
            writeImageTemp(data,"temp.jpg").then((value){
              updateProfileImage(value.path);
            });
          },
          selectedImageRatio: const CropAspectRatio(
            ratioX: 5,
            ratioY: 5,
          ),
          onImageStartLoading: showLoader,
          onImageEndLoading: hideLoader,
          visibleOtherAspectRatios: false,
          squareBorderWidth: 2,
          isConstrain: false,
          squareCircleColor: Colors.orange,
          defaultTextColor: Colors.black,
          selectedTextColor: Colors.orange,
          colorForWhiteSpace: Colors.white,
          makeDarkerOutside: true,
          outputImageFormat: OutputImageFormat.jpg,
          encodingQuality: 10);*/
    } else {
      // User canceled the picker
      isImageSelected.value = false;
    }
  }

  Camera(XFile? result){
    if (result != null) {
      isImageSelected.value = true;
      Get.to(CropImage(imageFile: File(result.path),))?.then((value){
        value as MemoryImage;
        imageBytes = value.bytes;
        writeImageTemp(value.bytes,"profile.jpg").then((value){
          imagepath(result.path);
          changed(true);
          //updateProfileImage(value.path);
        });
      });
      /*var imgBytes = await File(result.files.single.path!).readAsBytes();
      ImageCropping.cropImage(
          context: context,
          imageBytes: imgBytes,
          onImageDoneListener: (data) {
            imageBytes = data;
            writeImageTemp(data,"temp.jpg").then((value){
              updateProfileImage(value.path);
            });
          },
          selectedImageRatio: const CropAspectRatio(
            ratioX: 5,
            ratioY: 5,
          ),
          onImageStartLoading: showLoader,
          onImageEndLoading: hideLoader,
          visibleOtherAspectRatios: false,
          squareBorderWidth: 2,
          isConstrain: false,
          squareCircleColor: Colors.orange,
          defaultTextColor: Colors.black,
          selectedTextColor: Colors.orange,
          colorForWhiteSpace: Colors.white,
          makeDarkerOutside: true,
          outputImageFormat: OutputImageFormat.jpg,
          encodingQuality: 10);*/
    } else {
      // User canceled the Camera
      isImageSelected.value = false;
    }
  }
  void showLoader() {
    loading.value=true;
    if (EasyLoading.isShow) {
      return;
    }
    EasyLoading.show();
  }

  /// To hide loader
  void hideLoader() {
    loading.value=false;
    EasyLoading.dismiss();
  }

  Future<File> writeImageTemp(dynamic bytes, String imageName) async {
    final dir = await getTemporaryDirectory();
    await dir.create(recursive: true);
    final tempFile = File((dir.path)+"/"+imageName);
    await tempFile.writeAsBytes(bytes);
    return tempFile;
  }

  nameChanges(String text){
    changed(true);
    name(profileName.text.toString());
    update();
  }
  onEmailChange(String text){
    changed(true);
    update();
  }

}
