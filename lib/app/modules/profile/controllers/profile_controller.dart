import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart' as libphonenumber;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../common/constants.dart';
import '../../../data/session_management.dart';
import '../../../extensions/extensions.dart';
import '../../../model/arguments.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import '../../../common/app_localizations.dart';
import '../../../common/crop_image.dart';
import '../../../data/permissions.dart';
import '../../../data/utils.dart';
import '../../../routes/route_settings.dart';

class ProfileController extends GetxController {
  TextEditingController profileName = TextEditingController();
  TextEditingController profileEmail = TextEditingController();
  TextEditingController profileMobile = TextEditingController();
  var profileStatus = getTranslated("defaultStatus").obs;
  var isImageSelected = false.obs;
  var isUserProfileRemoved = false.obs;
  var imagePathNew = "".obs;
  var imagePath = "".obs;
  var userImgUrl = "".obs;
  var emailPatternMatch = RegExp(Constants.emailPattern,multiLine: false);
  var loading = false.obs;
  var changed = false.obs;

  dynamic imageBytes;
  var from = NavUtils.previousRoute;//Routes.login.obs;

  var name = "".obs;

  bool get emailEditAccess => true;//NavUtils.previousRoute!=Routes.settings;
  RxBool mobileEditAccess = false.obs;//NavUtils.previousRoute!=Routes.settings;

  var userNameFocus= FocusNode();
  var emailFocus= FocusNode();
  @override
  Future<void> onInit() async {
    super.onInit();

    if (NavUtils.previousRoute.isEmpty){
      from = Routes.login;
    }
    userImgUrl.value = SessionManagement.getUserImage() ?? "";
    LogMessage.d("auth : ", SessionManagement.getAuthToken().toString());
    if (NavUtils.arguments != null) {
      // from(NavUtils.arguments["from"]);
      if (from == Routes.login) {
        profileMobile.text = NavUtils.arguments['mobile'] ?? SessionManagement.getMobileNumber();
      }
    } else {
      profileMobile.text = "";
    }
    if (from == Routes.login) {
      if (!await AppUtils.isNetConnected()) {
        toToast(getTranslated("noInternetConnection"));
        return;
      }
    }
    checkAndEnableNotificationSound();
    getProfile();
    //profileStatus.value="I'm Mirror fly user";
    // await askStoragePermission();
    getMetaData();
  }

  Future<void> save({bool frmImage=false}) async {
    var valid = await validMobileNumber(profileMobile.text.removeAllWhitespace.replaceAll("+", ""));
    // var permission = await AppPermission.getStoragePermission();
    // if (permission) {
      if (profileName.text
          .trim()
          .isEmpty) {
        toToast(getTranslated("pleaseEnterUserName"));
      } else if (profileName.text
          .trim()
          .length < 3) {
        toToast(getTranslated("userNameTooShort"));
      } else if (profileEmail.text
          .trim()
          .isEmpty) {
        toToast(getTranslated("emailNotEmpty"));
      } else if (!emailPatternMatch.hasMatch(profileEmail.text.toString())) {
        toToast(getTranslated("pleaseEnterValidMail"));
      } else if (profileStatus.value.isEmpty) {
        toToast(getTranslated("pleaseEnterProfileStatus"));
      } else if(!valid){
        toToast(getTranslated("pleaseEnterValidMobile"));
      }
      else {
        loading.value = true;
        showLoader();
        if (imagePath.value.isNotEmpty) {
          debugPrint("profile image update");
          updateProfileImage(imagePath.value, update: true);
        } else {
          if (await AppUtils.isNetConnected()) {
            debugPrint("profile update");
            var formattedNumber = await libphonenumber.parse(profileMobile.text);
            debugPrint("parse-----> $formattedNumber");
            var unformatted = formattedNumber['national_number'];//profileMobile.text.replaceAll(" ", "").replaceAll("+", "");
            // var unformatted = profileMobile.text;
            Mirrorfly.updateMyProfile(name: profileName.text.toString(), email: profileEmail.text.toString(),
                mobile: unformatted,
                status: profileStatus.value.toString(),
                image: userImgUrl.value.isEmpty ? null : userImgUrl.value,
              flyCallback: (FlyResponse response){
                loading.value = false;
                hideLoader();
                if (response.isSuccess) {
                  LogMessage.d("updateMyProfile", response.data.toString());
                  var data = profileUpdateFromJson(response.data);
                  if (data.status != null) {
                    toToast(frmImage ? getTranslated("removedProfileImage") : data.message.toString());
                    if (data.status!) {
                      changed(false);
                      var userProfileData = ProData(
                          email: profileEmail.text.toString(),
                          image: userImgUrl.value,
                          mobileNumber: unformatted,
                          nickName: profileName.text,
                          name: profileName.text,
                          status: profileStatus.value);
                      SessionManagement.setCurrentUser(userProfileData);
                      if (from == Routes.login || from.isEmpty) {
                        // Mirrorfly.isTrailLicence().then((trail){
                        if(!Constants.enableContactSync) {
                          NavUtils.offNamed(Routes.dashboard,arguments: const DashboardViewArguments());
                        }else{
                          NavUtils.offNamed(Routes.contactSync);
                        }
                        // });
                      }
                    }
                  }
                } else {
                  toToast(getTranslated("unableToUpdateProfile"));
                }
              }
            );
            /*    .then((value) {
              LogMessage.d("updateMyProfile", value.toString());
              loading.value = false;
              hideLoader();
              if (value != null) {
                debugPrint(value);
                var data = profileUpdateFromJson(value);
                if (data.status != null) {
                  toToast(frmImage ? 'Removed profile image successfully' : data.message.toString());
                  if (data.status!) {
                    changed(false);
                    var userProfileData = ProData(
                        email: profileEmail.text.toString(),
                        image: userImgUrl.value,
                        mobileNumber: unformatted,
                        nickName: profileName.text,
                        name: profileName.text,
                        status: profileStatus.value);
                    SessionManagement.setCurrentUser(userProfileData);
                    if (from == Routes.login) {
                      // Mirrorfly.isTrailLicence().then((trail){
                        if(!Constants.enableContactSync) {
                          NavUtils.offNamed(Routes.dashboard);
                        }else{
                          NavUtils.offNamed(Routes.contactSync);
                        }
                      // });
                    }
                  }
                }
              } else {
                toToast("Unable to update profile");
              }
            }).catchError((error) {
              loading.value = false;
              hideLoader();
              debugPrint("issue===> $error");
              toToast(error.toString());
            });*/
          } else {
            loading(false);
            hideLoader();
            toToast(getTranslated("noInternetConnection"));
          }
        }
      }
    // }
  }

  updateProfileImage(String path, {bool update = false}) async {
    debugPrint("Profile Controller updateProfileImage path $path");
    if(await AppUtils.isNetConnected()) {
      loading.value = true;
      debugPrint("Profile Controller showing loader");

      // if(checkFileUploadSize(path, Constants.mImage)) {
        showLoader();
      debugPrint("Profile Controller updateMyProfileImage");
        Mirrorfly.updateMyProfileImage(image: path,flyCallback: (FlyResponse response){
          if(response.isSuccess) {
            LogMessage.d("updateMyProfileImage", response.data);
            loading.value = false;
            var data = json.decode(response.data);
            imagePathNew(imagePath.value);
            imagePath.value = Constants.emptyString;
            userImgUrl.value = data['data']['image'];
            SessionManagement.setUserImage(data['data']['image'].toString());
            hideLoader();
            if (update) {
              save();
            }
          }else{
            toToast(getTranslated("profileImageUpdateFailed"));
            debugPrint("Profile Update on error--> ${response.exception.toString()}");
            loading.value = false;
            hideLoader();
          }
        });
            /*.then((value) {
          LogMessage.d("updateMyProfileImage", value);
          loading.value = false;
          var data = json.decode(value);
          imagePath.value = Constants.emptyString;
          userImgUrl.value = data['data']['image'];
          SessionManagement.setUserImage(data['data']['image'].toString());
          hideLoader();
          if (update) {
            save();
          }
        }).catchError((onError) {
          debugPrint("Profile Update on error--> ${onError.toString()}");
          loading.value = false;
          hideLoader();
        });*/
      // }else{
      //   toToast("Image Size exceeds 10MB");
      // }
    }else{
      toToast(getTranslated("noInternetConnection"));
    }

  }

  removeProfileImage() async {
    if(userImgUrl.value.isNotEmpty) {
      if (await AppUtils.isNetConnected()) {
        showLoader();
        loading.value = true;
        Mirrorfly.removeProfileImage(flyCallBack: (response) {
          loading.value = false;
          hideLoader();
          if (response.isSuccess) {
            SessionManagement.setUserImage(Constants.emptyString);
            isImageSelected.value = false;
            isUserProfileRemoved.value = true;
            imagePathNew("");
            userImgUrl(Constants.emptyString);
            if (from == Routes.login) {
              changed(true);
            } else {
              // save(frmImage: true);
            }
            update();
          } else {
            toToast(getTranslated("profileImageRemoveFailed"));
          }
        });
      } else {
        toToast(getTranslated("noInternetConnection"));
      }
    }else{
      imagePath("");
    }
  }

  getProfile() async {
    //if(await AppUtils.isNetConnected()) {
      var jid = SessionManagement.getUserJID().checkNull();
      LogMessage.d("jid", jid);
      if (jid.isNotEmpty) {
        LogMessage.d("jid.isNotEmpty", jid.isNotEmpty.toString());
        loading.value = true;
        Mirrorfly.getUserProfile(jid: jid,fetchFromServer: await AppUtils.isNetConnected(),flyCallback:(FlyResponse response){
          LogMessage.d("getUserProfile", response.toString());
          if(response.isSuccess) {
            insertDefaultStatusToUser();
            loading.value = false;
            var data = profileDataFromJson(response.data);
            if (data.status != null && data.status!) {
              if (data.data != null) {
                profileName.text = data.data!.name ?? "";
                if (data.data!
                    .mobileNumber
                    .checkNull()
                    .isNotEmpty) {
                  //if (from.value != Routes.login) {
                  validMobileNumber(data.data!.mobileNumber.checkNull()).then((valid) {
                    // if(valid) profileMobile.text = data.data!.mobileNumber.checkNull();
                    mobileEditAccess(!valid);
                  });
                } else {
                  var userIdentifier = SessionManagement.getUserIdentifier();
                  validMobileNumber(userIdentifier).then((value) => mobileEditAccess(value));
                  // mobileEditAccess(true);
                }

                profileEmail.text = data.data!.email ?? "";
                profileStatus.value = data.data!
                    .status
                    .checkNull()
                    .isNotEmpty ? data.data!.status.checkNull() : getTranslated("defaultStatus");
                userImgUrl.value = data.data!.image ?? ""; //SessionManagement.getUserImage() ?? "";
                SessionManagement.setUserImage(Constants.emptyString);
                changed((from == Routes.login));
                name(data.data!.name.toString());
                var userProfileData = ProData(
                    email: profileEmail.text.toString(),
                    image: userImgUrl.value,
                    mobileNumber: data.data!.mobileNumber.checkNull(),
                    nickName: profileName.text,
                    name: profileName.text,
                    status: profileStatus.value);
                SessionManagement.setCurrentUser(userProfileData);
                update();
              }
            } else {
              debugPrint("Unable to load Profile data");
              toToast(getTranslated("unableConnectServer"));
            }
          }else{
            loading.value = false;
            toToast(getTranslated("unableToLoadProfileData"));
          }
        });
      }
   /* }else{
      toToast(getTranslated("noInternetConnection"));
      NavUtils.back();
    }*/

  }

  static void insertDefaultStatusToUser() async{
    try {
      await Mirrorfly.getProfileStatusList().then((value) {
        LogMessage.d("status list", "$value");
        if (value != null) {
          var profileStatus = statusDataFromJson(value.toString());
          if (profileStatus.isNotEmpty) {
            debugPrint("profile status list is not empty");
            var defaultStatus = getTranslatedList("defaultStatusList");

            for (var statusValue in defaultStatus) {
              var isStatusNotExist = true;
              for (var flyStatus in profileStatus) {
                if (flyStatus.status == (statusValue)) {
                  isStatusNotExist = false;
                }
              }
              if (isStatusNotExist) {
                Mirrorfly.insertDefaultStatus(status: statusValue);
              }
            }
          }else{
            insertStatus();
          }
        }else{
          debugPrint("status list is empty");
          insertStatus();

        }
      });
    } on Exception catch(er){
      debugPrint("Exception ==> $er");
    }
  }

  Future imagePicker(BuildContext context) async {
    if(await AppPermission.getStoragePermission()) {
      if (await AppUtils.isNetConnected()) {
        FilePickerResult? result = await FilePicker.platform
            .pickFiles(allowMultiple: false, type: FileType.image);
        if (result != null) {
          if (MediaUtils.checkFileUploadSize(
              result.files.single.path!, Constants.mImage)) {
            isImageSelected.value = true;
            NavUtils.to(CropImage(
              imageFile: File(result.files.single.path!),
            ))?.then((value) {
              if (value != null) {
                value as MemoryImage;
                imageBytes = value.bytes;
                var name = "${DateTime
                    .now()
                    .millisecondsSinceEpoch}.jpg";
                MessageUtils.writeImageTemp(value.bytes, name).then((value) {
                  if (from == Routes.login) {
                    imagePath(value.path);
                    changed(true);
                    update();
                  } else {
                    imagePath(value.path);
                    // changed(true);
                    updateProfileImage(value.path, update: false);
                  }
                });
              }
            });
          } else {
            toToast(getTranslated("imageLess10mb"));
          }
        } else {
          // User canceled the picker
          isImageSelected.value = false;
        }
      } else {
        toToast(getTranslated("noInternetConnection"));
      }
    }
  }

  final ImagePicker _picker = ImagePicker();
  camera() async {
    if(await AppUtils.isNetConnected()) {
      final XFile? photo = await _picker.pickImage(
          source: ImageSource.camera);
      if (photo != null) {
        isImageSelected.value = true;
        NavUtils.to(CropImage(
          imageFile: File(photo.path),
        ))?.then((value) {
          debugPrint("Profile Controller Got Image from Crop Image $value");
          if (value != null) {
            value as MemoryImage;
            imageBytes = value.bytes;
            var name = "${DateTime
                .now()
                .millisecondsSinceEpoch}.jpg";
            MessageUtils.writeImageTemp(value.bytes, name).then((value) {
              if (from == Routes.login) {
                debugPrint("Profile Controller from login");
                imagePath(value.path);
                changed(true);
              } else {
                debugPrint("Profile Controller not from login");
                imagePath(value.path);
                // changed(true);
                updateProfileImage(value.path, update: false);
              }
            });
          }
        });
      } else {
        // User canceled the Camera
        isImageSelected.value = false;
      }
    }else{
      toToast(getTranslated("noInternetConnection"));
    }
  }

  void showLoader() {
    DialogUtils.progressLoading();
  }

  /// To hide loader
  void hideLoader() {
    DialogUtils.hideLoading();
  }

  nameChanges(String text) {
    changed(true);
    name(profileName.text.toString());
    update();
  }

  onEmailChange(String text) {
    changed(true);
    update();
  }

  onMobileChange(String text){
    changed(true);
    validMobileNumber(text.replaceAll("+", ""));
    update();
  }

  Future<bool> validMobileNumber(String text)async{
    var coded = text;
    if(!text.startsWith(SessionManagement.getCountryCode().checkNull().replaceAll("+", "").toString())){
      LogMessage.d("SessionManagement.getCountryCode()", SessionManagement.getCountryCode().toString());
      coded = SessionManagement.getCountryCode().checkNull()+text;
    }
    var m = coded.contains("+") ? coded : "+$coded";
    await libphonenumber.init();
    try {
      var formatNumberSync = libphonenumber.formatNumberSync(m);
      var parse = await libphonenumber.parse(formatNumberSync);
      debugPrint("parse-----> $parse");
      //{country_code: 91, e164: +91xxxxxxxxxx, national: 0xxxxx xxxxx, type: mobile, international: +91 xxxxx xxxxx, national_number: xxxxxxxxxx, region_code: IN}
      if (parse.isNotEmpty) {
        var formatted = parse['international'];//.replaceAll("+", '');
        profileMobile.text = (formatted.toString());
        return true;
      } else {
        return false;
      }
    }catch(e){
      debugPrint('validMobileNumber $e');
      return false;
    }
  }

  static void insertStatus() {
    debugPrint("Inserting Status");
    var defaultStatus = getTranslatedList("defaultStatusList");

    for (var statusValue in defaultStatus) {
      Mirrorfly.insertDefaultStatus(status: statusValue);

    }
    // Mirrorfly.getDefaultNotificationUri().then((value) {
    //   if (value != null) {
    //     // Mirrorfly.setNotificationUri(value);
    //     SessionManagement.setNotificationUri(value);
    //   }
    // });
  }
  static void checkAndEnableNotificationSound() {

    SessionManagement.vibrationType("0");
    SessionManagement.convSound(true);
    SessionManagement.muteAll(false);

    /*Mirrorfly.getDefaultNotificationUri().then((value) {
      debugPrint("getDefaultNotificationUri--> $value");
      if (value != null) {
        // Mirrorfly.setNotificationUri(value);
        SessionManagement.setNotificationUri(value);
        Mirrorfly.setNotificationSound(true);
        Mirrorfly.setDefaultNotificationSound();
        SessionManagement.setNotificationSound(true);
      }
    });*/
  }

  //Unfocused all text fields
  void unFocusAll(){
    userNameFocus.unfocus();
    emailFocus.unfocus();
  }

  //Navigate to status list
  void goToStatus(){
    unFocusAll();
    NavUtils.toNamed(Routes.statusList, arguments: {'status': profileStatus.value})?.then((value) {
      if (value != null) {
        profileStatus.value = value;
      }
    });
  }

  //Navigate to image preview
  void goToImagePreview(){
    unFocusAll();
    if (imagePath.value.checkNull().isNotEmpty) {
      NavUtils.toNamed(Routes.imageView,
          arguments: {'imageName': profileName.text, 'imagePath': imagePath.value.checkNull()});
    } else if (userImgUrl.value.checkNull().isNotEmpty) {
      NavUtils.toNamed(Routes.imageView,
          arguments: {'imageName': profileName.text, 'imageUrl': userImgUrl.value.checkNull()});
    }
  }

  //#metaData
  void getMetaData(){
    Mirrorfly.getMetaData(flyCallback: (FlyResponse response){
      LogMessage.d("getMetaData", response.toString());
      var list = identifierMetaDataFromJson(response.data);
      log(list.toJson());
    });
    /*Mirrorfly.updateMetaData(identifierMetaDataList: [IdentifierMetaData(key: "platform", value: "flutter")],flyCallback: (FlyResponse response){
      LogMessage.d("updateMetaData", response.toString());
    });*/
  }

  void onConnected(){
    if(changed.value){
      return;
    }
    getProfile();
  }
}
