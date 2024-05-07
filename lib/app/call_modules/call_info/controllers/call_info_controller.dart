import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/apputils.dart';
import 'package:mirror_fly_demo/app/data/permissions.dart';
import '../../../routes/route_settings.dart';
import 'package:mirrorfly_plugin/model/call_log_model.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/extensions/extensions.dart';


class CallInfoController extends GetxController{

  var callLogData_ = CallLogData().obs;
  CallLogData get callLogData => callLogData_.value;

  @override
  void onInit() {
    callLogData_((Get.arguments as CallLogData));
    super.onInit();
  }

  makeCall(List<String>? userList, String callType, CallLogData item) async {
    if (userList!.isNotEmpty) {
      if (await AppUtils.isNetConnected()) {
        if (callType == CallType.video) {
          if (await AppPermission.askVideoCallPermissions()) {
            Get.back();
            if ((await Mirrorfly.isOnGoingCall()).checkNull()) {
              debugPrint("#Mirrorfly Call You are on another call");
              toToast(Constants.msgOngoingCallAlert);
            } else {
              Mirrorfly.makeGroupVideoCall(groupJid: item.groupId.checkNull().isNotEmpty ? item.groupId! : "", toUserJidList: userList, flyCallBack: (FlyResponse response) {
                if (response.isSuccess) {
                  Get.toNamed(Routes.outGoingCallView, arguments: {"userJid": userList, "callType": CallType.video});
                }
              });
            }
          }
        } else {
          if (await AppPermission.askAudioCallPermissions()) {
            Get.back();
            if ((await Mirrorfly.isOnGoingCall()).checkNull()) {
              debugPrint("#Mirrorfly Call You are on another call");
              toToast(Constants.msgOngoingCallAlert);
            } else {
              Mirrorfly.makeGroupVoiceCall(groupJid: item.groupId.checkNull().isNotEmpty ? item.groupId! : "", toUserJidList: userList, flyCallBack: (FlyResponse response) {
                if (response.isSuccess) {
                  Get.toNamed(Routes.outGoingCallView, arguments: {"userJid": userList, "callType": CallType.audio});
                }
              });
            }
          }
        }
      } else {
        toToast(Constants.noInternetConnection);
      }
    }
  }

  itemDeleteCallLog(List<String> selectedCallLogs) {
    Helper.showAlert(
        message: "Do you want to delete a call log?",
        actions: [
          TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text(Constants.cancel.toUpperCase(),style: const TextStyle(color: buttonBgColor))),
          TextButton(
              onPressed: () {
                Get.back();
                Mirrorfly.deleteCallLog(jidList: selectedCallLogs, isClearAll: false, flyCallBack: (FlyResponse response) {
                  if (response.isSuccess) {
                    Get.back(result: true);
                  } else {
                    toToast("Error in call log delete");
                  }
                });
              },
              child: const Text(Constants.ok,style: TextStyle(color: buttonBgColor))),
        ],
        barrierDismissible: true);
  }

}