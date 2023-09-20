import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirrorfly_plugin/flychat.dart';
import 'package:mirrorfly_plugin/logmessage.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';

import '../../../common/constants.dart';
import '../../../data/apputils.dart';
import '../../../data/permissions.dart';
import '../../../routes/app_pages.dart';

class CallTimeoutController extends GetxController {
  var callType = ''.obs;
  var callMode = ''.obs;
  var userJID = ''.obs;
  var calleeName = ''.obs;
  Rx<Profile> profile = Profile().obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    callType(Get.arguments["callType"]);
    callMode(Get.arguments["callMode"]);
    userJID(Get.arguments["userJid"]);
    calleeName(Get.arguments["calleeName"]);
    var data = await getProfileDetails(userJID.value);
    profile(data);
  }

  void cancelCallTimeout() {
    Get.back();
  }

  callAgain() async {
    // Get.offNamed(Routes.outGoingCallView, arguments: {"userJid": userJID.value});
    if (await AppUtils.isNetConnected()) {
      if(callType.value.toUpperCase() == Constants.mAudio) {
        if (await AppPermission.askAudioCallPermissions()) {
          Mirrorfly.makeVoiceCall(userJID.value).then((value) {
            Get.offNamed(
                Routes.outGoingCallView, arguments: {"userJid": userJID.value});
          });
        } else {
          debugPrint("permission not given");
        }
      }else{
        if (Platform.isAndroid
            ? await AppPermission.askVideoCallPermissions()
            : await AppPermission.askiOSVideoCallPermissions()) {
          Mirrorfly.makeVideoCall(userJID.value).then((value) {
            if (value) {
              Get.offNamed(
                  Routes.outGoingCallView, arguments: {"userJid": userJID.value});
            }
          }).catchError((e) {
            debugPrint("#Mirrorfly Call $e");
          });
        } else {
          LogMessage.d("askVideoCallPermissions", "false");
        }
      }
    } else {
      toToast(Constants.noInternetConnection);
    }
  }
}
