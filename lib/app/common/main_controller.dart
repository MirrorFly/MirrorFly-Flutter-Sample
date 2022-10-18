import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/SessionManagement.dart';
import 'package:mirror_fly_demo/app/model/countryModel.dart';

import '../nativecall/platformRepo.dart';

class MainController extends GetxController{
  var AUTHTOKEN = "";
  @override
  void onInit() {
    super.onInit();
    PlatformRepo().authtoken().then((value) {
      AUTHTOKEN=value;
      SessionManagement.setAuthtoken(value);
    });
  }
}