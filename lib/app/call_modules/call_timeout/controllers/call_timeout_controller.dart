import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  // var userJID = ''.obs;
  var calleeName = ''.obs;
  // Rx<Profile> profile = Profile().obs;

  var users = <String?>[].obs;
  var groupId = ''.obs;
  @override
  Future<void> onInit() async {
    super.onInit();
    enterFullScreen();
    groupId(await Mirrorfly.getGroupId());
    callType(Get.arguments["callType"]);
    callMode(Get.arguments["callMode"]);
    users.value = (Get.arguments["userJid"] as List<String?>);
    calleeName(Get.arguments["calleeName"]);
    // var data = await getProfileDetails(userJID.value);
    // profile(data);
  }

  @override
  void dispose() {
    super.dispose();
    exitFullScreen();
  }

  void cancelCallTimeout() {
    Get.back();
  }

  callAgain() async {
    // Get.offNamed(Routes.outGoingCallView, arguments: {"userJid": userJID.value});
    if (await AppUtils.isNetConnected()) {
      if(callType.value == Constants.audioCall) {
        if (await AppPermission.askAudioCallPermissions()) {
          if(users.length==1) {
            Mirrorfly.makeVoiceCall(users.first!).then((value) {
              Get.offNamed(
                  Routes.outGoingCallView, arguments: {"userJid": users});
            });
          }else{
            var usersList = <String>[];
            for (var element in users) {if(element!=null) { usersList.add(element);}}
            Mirrorfly.makeGroupVoiceCall(jidList: usersList).then((value) {
              Get.offNamed(
                  Routes.outGoingCallView, arguments: {"userJid": users});
            });
          }
        } else {
          debugPrint("permission not given");
        }
      }else{
        if (Platform.isAndroid
            ? await AppPermission.askVideoCallPermissions()
            : await AppPermission.askiOSVideoCallPermissions()) {
          if(users.length==1) {
            Mirrorfly.makeVideoCall(users.first!).then((value) {
              if (value) {
                Get.offNamed(
                    Routes.outGoingCallView, arguments: {"userJid": users});
              }
            }).catchError((e) {
              debugPrint("#Mirrorfly Call $e");
            });
          }else{
            var usersList = <String>[];
            for (var element in users) {if(element!=null) { usersList.add(element);}}
            Mirrorfly.makeGroupVideoCall(jidList: usersList).then((value) {
              Get.offNamed(
                  Routes.outGoingCallView, arguments: {"userJid": users});
            });
          }
        } else {
          LogMessage.d("askVideoCallPermissions", "false");
        }
      }
    } else {
      toToast(Constants.noInternetConnection);
    }
  }

  void userUpdatedHisProfile(String jid){
    updateProfile(jid);
  }
  Future<void> updateProfile(String jid) async {
    if (jid.isNotEmpty) {
      var callListIndex = users.indexWhere((element) => element == jid);
      if (!callListIndex.isNegative) {
        users[callListIndex] = jid;
        users.refresh();
      }
    }
  }

  void enterFullScreen() {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  void exitFullScreen() {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }
}
