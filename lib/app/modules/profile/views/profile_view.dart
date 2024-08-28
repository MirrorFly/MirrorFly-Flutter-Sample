import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:get/get.dart';
import '../../../app_style_config.dart';
import '../../../common/app_localizations.dart';
import '../../../common/constants.dart';
import '../../../extensions/extensions.dart';

import '../../../common/widgets.dart';
import '../../../data/utils.dart';
import '../../../routes/route_settings.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends NavViewStateful<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);
  @override
ProfileController createController({String? tag}) => Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return FocusDetector(
      onFocusGained: () {
        if (!KeyboardVisibilityController().isVisible) {
          ///Hidden this code, inorder to rectify the keyboard is displayed, then dismissed and then shown again. This type of checking is not needed.
          /*if (controller.userNameFocus.hasFocus) {
            controller.userNameFocus.unfocus();
            Future.delayed(const Duration(milliseconds: 100), () {
              controller.userNameFocus.requestFocus();
            });
          } else if (controller.emailFocus.hasFocus) {
            controller.emailFocus.unfocus();
            Future.delayed(const Duration(milliseconds: 100), () {
              controller.emailFocus.requestFocus();
            });
          }*/
        }
      },
      child: Theme(
        data: Theme.of(context).copyWith(
          appBarTheme: AppStyleConfig.profileViewStyle.appBarTheme,
        ),
        child: Scaffold(
            appBar: AppBar(
                title: Text(
                  getTranslated("profile"),
                  // style: const TextStyle(color: appbarTextColor),
                ),
                // centerTitle: true,
                automaticallyImplyLeading: NavUtils.previousRoute != Routes.login //controller.from.value == Routes.login
                // ? false
                // : true,
                ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(18.0, 0, 18.0, 0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Obx(() {
                                  debugPrint("controller.userImgUrl.value ${controller.userImgUrl.value}");
                                  debugPrint("controller.imagePath.value ${controller.imagePath.value}");
                                  debugPrint("controller.profile name ${controller.profileName.text}");

                                  return InkWell(
                                    child: controller.imagePath.value.isNotEmpty || controller.imagePathNew.value.isNotEmpty
                                        ? SizedBox(
                                            width: AppStyleConfig.profileViewStyle.profileImageSize.width,
                                            height: AppStyleConfig.profileViewStyle.profileImageSize.height,
                                            child: ClipOval(
                                              child: Image.file(
                                                File(controller.imagePath.value.isEmpty ? controller.imagePathNew.value : controller.imagePath.value),
                                                fit: BoxFit.fill,
                                              ),
                                            ))
                                        : controller.userImgUrl.value.isEmpty && controller.name.value.isNotEmpty
                                            ? ProfileTextImage(
                                                bgColor: buttonBgColor,
                                                text: controller.name.value.checkNull(),
                                                radius: AppStyleConfig.profileViewStyle.profileImageSize.width/2,
                                              )
                                            : ImageNetwork(
                                                url: controller.userImgUrl.value.checkNull(),
                                                width: AppStyleConfig.profileViewStyle.profileImageSize.width,
                                                height: AppStyleConfig.profileViewStyle.profileImageSize.height,
                                                clipOval: true,
                                                errorWidget: controller.profileName.text.checkNull().isNotEmpty
                                                    ? ProfileTextImage(
                                                        bgColor: buttonBgColor,
                                                        text: controller.profileName.text.checkNull(),
                                                        radius: AppStyleConfig.profileViewStyle.profileImageSize.width/2,
                                                      )
                                                    : null,
                                                isGroup: false,
                                                blocked: false,
                                                unknown: false,
                                              ),
                                    onTap: () {
                                      controller.goToImagePreview();
                                    },
                                  );
                                }),
                              ),
                            ),
                            Obx(
                              () => Positioned(
                                right: 10,
                                bottom: 10,
                                child: Container(
                                  width: 40,
                                  decoration: BoxDecoration(
                                    color: AppStyleConfig.profileViewStyle.cameraIconStyle.bgColor,
                                    border: Border.all(color: AppStyleConfig.profileViewStyle.cameraIconStyle.borderColor ?? Colors.white,width: 1),
                                    shape: BoxShape.circle
                                  ),
                                  child: InkWell(
                                    onTap: controller.loading.value
                                        ? null
                                        : () {
                                            controller.unFocusAll();
                                            bottomSheetView(context);
                                          },
                                    child: AppUtils.svgIcon(icon:
                                      'assets/logos/camera_profile_change.svg',
                                      colorFilter: ColorFilter.mode(AppStyleConfig.profileViewStyle.cameraIconStyle.iconColor, BlendMode.srcIn),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: Obx(() {
                          return SizedBox(
                            width: controller.name.isNotEmpty ? null : 80,
                            child: TextField(
                              cursorColor: buttonBgColor,
                              focusNode: controller.userNameFocus,
                              autofocus: false,
                              onChanged: (value) => controller.nameChanges(value),
                              textAlign: controller.profileName.text.isNotEmpty ? TextAlign.center : TextAlign.start,
                              maxLength: 30,
                              controller: controller.profileName,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: getTranslated("userName"),
                                hintStyle: AppStyleConfig.profileViewStyle.nameTextFieldStyle.editTextHintStyle,
                                counterText: '',
                              ),
                              style: AppStyleConfig.profileViewStyle.nameTextFieldStyle.editTextStyle,
                              // style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(getTranslated("email"),
                        style: AppStyleConfig.profileViewStyle.emailTextFieldStyle.titleStyle,
                        // style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      TextField(
                        cursorColor: buttonBgColor,
                        keyboardType: TextInputType.emailAddress,
                        focusNode: controller.emailFocus,
                        onChanged: (value) => controller.onEmailChange(value),
                        controller: controller.profileEmail,
                        enabled: controller.emailEditAccess,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: getTranslated("enterEmailID"),
                          icon: AppUtils.svgIcon(icon:'assets/logos/email.svg'),
                          hintStyle: AppStyleConfig.profileViewStyle.emailTextFieldStyle.editTextHintStyle
                        ),
                        style: AppStyleConfig.profileViewStyle.emailTextFieldStyle.editTextStyle,
                        // style: const TextStyle(fontWeight: FontWeight.normal, color: textColor),
                      ),
                      const AppDivider(),
                      const SizedBox(
                        height: 20,
                      ),
                  Text(getTranslated("mobileNumber"),
                        style: AppStyleConfig.profileViewStyle.mobileTextFieldStyle.titleStyle,
                        // style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      Obx(() {
                        return TextField(
                          cursorColor: buttonBgColor,
                          controller: controller.profileMobile,
                          onChanged: (value) => controller.onMobileChange(value),
                          enabled: controller.mobileEditAccess.value,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: getTranslated("enterMobileNumber"),
                            icon: AppUtils.svgIcon(icon:'assets/logos/phone.svg'),
                            hintStyle: AppStyleConfig.profileViewStyle.mobileTextFieldStyle.editTextHintStyle
                          ),
                          style: AppStyleConfig.profileViewStyle.mobileTextFieldStyle.editTextStyle,
                          // style: const TextStyle(fontWeight: FontWeight.normal, color: textColor),
                        );
                      }),
                      const AppDivider(),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        getTranslated("status"),
                        style: AppStyleConfig.profileViewStyle.statusTextFieldStyle.titleStyle,
                        // style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      Obx(() => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              controller.profileStatus.value.isNotEmpty ? controller.profileStatus.value : getTranslated("defaultStatus"),
                              style: controller.profileStatus.value.isNotEmpty ? AppStyleConfig.profileViewStyle.statusTextFieldStyle.editTextStyle : AppStyleConfig.profileViewStyle.statusTextFieldStyle.editTextHintStyle,
                              // style: TextStyle(color: controller.profileStatus.value.isNotEmpty ? textColor : Colors.black38, fontWeight: FontWeight.normal),
                            ),
                            minLeadingWidth: 10,
                            leading: AppUtils.svgIcon(icon:'assets/logos/status.svg'),
                            onTap: () {
                              controller.goToStatus();
                            },
                          )),
                      const AppDivider(
                        padding: EdgeInsets.only(bottom: 26),
                      ),
                      Center(
                        child: Obx(
                          () => ElevatedButton(
                            style: AppStyleConfig.profileViewStyle.buttonStyle,
                            onPressed: controller.loading.value
                                ? null
                                : controller.changed.value
                                    ? () {
                                        FocusScope.of(context).unfocus();
                                        if (!controller.loading.value) {
                                          controller.save();
                                        }
                                      }
                                    : null,
                            child: Text(
                              controller.from == Routes.login || controller.from.isEmpty
                                  ? getTranslated("save")
                                  : controller.changed.value
                                      ? getTranslated("updateAndContinue")
                                      : getTranslated("save"),
                              // style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )),
      ),
    );
  }

  bottomSheetView(BuildContext context) {
    showModalBottomSheet(
        useRootNavigator: true,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (builder) {
          return SafeArea(
            child: SizedBox(
              width: NavUtils.size.width,
              child: Theme(
                data: Theme.of(context).copyWith(cardTheme: AppStyleConfig.profileViewStyle.bottomSheetCardTheme),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Text(getTranslated("options"),style: AppStyleConfig.profileViewStyle.optionStyle,),
                        const SizedBox(
                          height: 10,
                        ),
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          onTap: () {
                            NavUtils.back();
                            controller.camera();
                          },
                          title: Text(
                            getTranslated("takePhoto"),
                            style: AppStyleConfig.profileViewStyle.optionsTextStyle,
                            // style: const TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          onTap: () {
                            NavUtils.back();
                            controller.imagePicker(context);
                          },
                          title: Text(
                            getTranslated("chooseFromGallery"),
                            style: AppStyleConfig.profileViewStyle.optionsTextStyle,
                            // style: const TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        controller.userImgUrl.value.isNotEmpty || controller.imagePath.value.isNotEmpty
                            ? ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                onTap: () {
                                  NavUtils.back();
                                  DialogUtils.showAlert(dialogStyle: AppStyleConfig.dialogStyle,message: getTranslated("areYouSureToRemovePhoto"), actions: [
                                    TextButton(style: AppStyleConfig.dialogStyle.buttonStyle,
                                        onPressed: () {
                                          NavUtils.back();
                                        },
                                        child: Text(getTranslated("cancel").toUpperCase(), )),
                                    TextButton(style: AppStyleConfig.dialogStyle.buttonStyle,
                                        onPressed: () {
                                          NavUtils.back();
                                          controller.removeProfileImage();
                                        },
                                        child: Text(getTranslated("remove").toUpperCase(), ))
                                  ]);
                                },
                                title: Text(
                                  getTranslated("removePhoto"),
                                  style: AppStyleConfig.profileViewStyle.optionsTextStyle,
                                  // style: const TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              )
                            : const Offstage(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }
}
