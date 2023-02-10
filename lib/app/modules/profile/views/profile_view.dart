import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_svg/svg.dart';
import 'package:focus_detector/focus_detector.dart';

import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/routes/app_pages.dart';

import '../../../common/widgets.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FocusDetector(
        onFocusGained: () {
          if (!KeyboardVisibilityController().isVisible) {
            if (controller.userNameFocus.hasFocus) {
              controller.userNameFocus.unfocus();
              Future.delayed(const Duration(milliseconds: 100), () {
                controller.userNameFocus.requestFocus();
              });
            } else if (controller.emailFocus.hasFocus) {
              controller.emailFocus.unfocus();
              Future.delayed(const Duration(milliseconds: 100), () {
                controller.emailFocus.requestFocus();
              });
            }
          }
        },
        child: Scaffold(
            appBar: AppBar(
              title: const Text(
                'Profile',
                style: TextStyle(color: appbarTextColor),
              ),
              centerTitle: true,
              automaticallyImplyLeading:
              controller.from.value == Routes.login ? false : true,
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
                              padding:
                              const EdgeInsets.fromLTRB(18.0, 0, 18.0, 0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Obx(
                                      () =>
                                      InkWell(
                                        child: controller.imagePath.value
                                            .isNotEmpty
                                            ? SizedBox(
                                            width: 150,
                                            height: 150,
                                            child: ClipOval(
                                              child: Image.file(
                                                File(
                                                    controller.imagePath.value),
                                                fit: BoxFit.fill,
                                              ),
                                            ))
                                            : ImageNetwork(
                                          url: controller.userImgUrl.value
                                              .checkNull(),
                                          width: 150,
                                          height: 150,
                                          clipOval: true,
                                          errorWidget: controller.name.value
                                              .checkNull()
                                              .isNotEmpty
                                              ? ProfileTextImage(
                                            fontSize: 40,
                                            bgColor: buttonBgColor,
                                            text: controller.name.value
                                                .checkNull(),
                                            radius: 75,
                                          )
                                              : null,
                                        ),
                                        onTap: () {
                                          if (controller.imagePath.value
                                              .checkNull()
                                              .isNotEmpty) {
                                            Get.toNamed(Routes.imageView,
                                                arguments: {
                                                  'imageName':
                                                  controller.profileName.text,
                                                  'imagePath': controller
                                                      .imagePath.value
                                                      .checkNull()
                                                });
                                          } else if (controller.userImgUrl.value
                                              .checkNull()
                                              .isNotEmpty) {
                                            Get.toNamed(Routes.imageView,
                                                arguments: {
                                                  'imageName':
                                                  controller.profileName.text,
                                                  'imageUrl': controller
                                                      .userImgUrl.value
                                                      .checkNull()
                                                });
                                          }
                                        },
                                      ),
                                ),
                              ),
                            ),
                            Obx(
                                  () =>
                                  Positioned(
                                    right: 10,
                                    bottom: 10,
                                    child: InkWell(
                                      onTap: controller.loading.value
                                          ? null
                                          : () {
                                        bottomSheetView(context);
                                      },
                                      child: Image.asset(
                                        'assets/logos/camera_profile_change.png',
                                        height: 40,
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
                            width: controller.name.isNotEmpty
                                ? null
                                : 80,
                            child: TextField(
                              focusNode: controller.userNameFocus,
                              autofocus: false,
                              onChanged: (value) =>
                                  controller.nameChanges(value),
                              textAlign: controller.profileName.text.isNotEmpty
                                  ? TextAlign
                                  .center
                                  : TextAlign.start,
                              maxLength: 30,
                              controller: controller.profileName,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Username',
                                counterText: '',
                              ),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        'Email',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextField(
                        keyboardType: TextInputType.emailAddress,
                        focusNode: controller.emailFocus,
                        onChanged: (value) => controller.onEmailChange(value),
                        controller: controller.profileEmail,
                        enabled: controller.emailEditAccess,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter Email Id',
                          icon: SvgPicture.asset('assets/logos/email.svg'),
                        ),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const AppDivider(),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        'Mobile Number',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: controller.profileMobile,
                        enabled: false,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter Mobile Number',
                          icon: SvgPicture.asset('assets/logos/phone.svg'),
                        ),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const AppDivider(),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        'Status',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Obx(() =>
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              controller.profileStatus.value.isNotEmpty
                                  ? controller.profileStatus.value
                                  : Constants.defaultStatus,
                              style: TextStyle(
                                  color:
                                  controller.profileStatus.value.isNotEmpty
                                      ? Colors.black
                                      : Colors.black38),
                            ),
                            leading:
                            SvgPicture.asset('assets/logos/status.svg'),
                            onTap: () {
                              Get.toNamed(Routes.statusList, arguments: {
                                'status': controller.profileStatus.value
                              })?.then((value) {
                                if (value != null) {
                                  controller.profileStatus.value = value;
                                }
                              });
                            },
                          )),
                      const AppDivider(
                        padding: EdgeInsets.only(bottom: 16),
                      ),
                      Center(
                        child: Obx(
                              () =>
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 40, vertical: 15),
                                    textStyle: const TextStyle(fontSize: 14),
                                    shape: const StadiumBorder()),
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
                                  controller.from.value == Routes.login
                                      ? 'Save'
                                      : controller.changed.value
                                      ? 'Update & Continue'
                                      : 'Save',
                                  style:
                                  const TextStyle(fontWeight: FontWeight.w600),
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
              child: Card(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30))),
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // const Text("Options"),
                      TextButton(
                          onPressed: () async {
                            Get.back();
                            controller.camera();
                          },
                          child: const Text("Take Photo",
                              style: TextStyle(color: textHintColor))),
                      TextButton(
                          onPressed: () {
                            Get.back();
                            controller.imagePicker(context);
                          },
                          child: const Text("Choose from Gallery",
                              style: TextStyle(color: textHintColor))),
                      controller.userImgUrl.value.isNotEmpty
                          ? TextButton(
                          onPressed: () {
                            Get.back();
                            Helper.showAlert(
                                message:
                                "Are you sure want to remove the photo?",
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Get.back();
                                      },
                                      child: const Text("CANCEL")),
                                  TextButton(
                                      onPressed: () {
                                        Get.back();
                                        controller.removeProfileImage();
                                      },
                                      child: const Text("REMOVE"))
                                ]);
                          },
                          child: const Text(
                            "Remove Profile Image",
                            style: TextStyle(color: textHintColor),
                          ))
                          : const SizedBox(),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
