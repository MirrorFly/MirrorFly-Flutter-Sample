import 'dart:collection';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/data/SessionManagement.dart';
import 'package:mirror_fly_demo/app/model/registerModel.dart';
import 'package:mirror_fly_demo/app/nativecall/platformRepo.dart';
import 'package:mirror_fly_demo/app/routes/app_pages.dart';

class HomeController extends GetxController {
  //TODO: Implement HomeController

  TextEditingController userIdentifier = TextEditingController();

  registerUser() {
    RegisterModel userData;
    PlatformRepo().registerUser(userIdentifier.text).then((value) {
      if (value.contains("data")) {
        userData = registerModelFromJson(value);//message
        SessionManagement.setLogin(userData.data!.username!.isNotEmpty);
        SessionManagement.setUser(userData.data!);
        setUserJID(userData.data!.username!);
        SessionManagement.setUser(userData.data!);
        // connectChatManager(userData.data.username);

        Get.toNamed(Routes.DASHBOARD);
      }
    }).catchError((error) {
      debugPrint("issue===> $error");
      debugPrint(error.message);
    });
  }

  setUserJID(String username) {
    PlatformRepo().getUserJID(username).then((value) {
      if(value != null){
        SessionManagement.setUserJID(value);
      }
    }).catchError((error) {
      debugPrint(error.message);
    });
  }

  // connectChatManager(String username) {
  //   PlatformRepo().connectChatManager(username).then((value) {
  //     debugPrint("Flutter Response ===> $value");
  //
  //   }).catchError((error) {
  //     debugPrint("Error===> $error");
  //   });
  //
  // }
}
