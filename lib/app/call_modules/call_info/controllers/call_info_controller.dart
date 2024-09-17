import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/permissions.dart';
import '../../../extensions/extensions.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';
import 'package:mirrorfly_plugin/model/call_log_model.dart';

import '../../../app_style_config.dart';
import '../../../common/app_localizations.dart';
import '../../../common/constants.dart';
import '../../../data/utils.dart';
import '../../../routes/route_settings.dart';


class CallInfoController extends GetxController{

  var callLogData_ = CallLogData().obs;
  CallLogData get callLogData => callLogData_.value;

  @override
  void onInit() {
    callLogData_((NavUtils.arguments as CallLogData));
    super.onInit();
  }

  makeCall(List<String>? userList, String callType, CallLogData item) async {
    if (userList!.isNotEmpty) {
      if (await AppUtils.isNetConnected()) {
        if (callType == CallType.video) {
          if (await AppPermission.askVideoCallPermissions()) {
            NavUtils.back();
            if ((await Mirrorfly.isOnGoingCall()).checkNull()) {
              debugPrint("#Mirrorfly Call You are on another call");
              toToast(getTranslated("msgOngoingCallAlert"));
            } else {
              Mirrorfly.makeGroupVideoCall(groupJid: item.groupId.checkNull().isNotEmpty ? item.groupId! : "", toUserJidList: userList, flyCallBack: (FlyResponse response) {
                if (response.isSuccess) {
                  NavUtils.toNamed(Routes.outGoingCallView, arguments: {"userJid": userList, "callType": CallType.video});
                }
              });
            }
          }
        } else {
          if (await AppPermission.askAudioCallPermissions()) {
            NavUtils.back();
            if ((await Mirrorfly.isOnGoingCall()).checkNull()) {
              debugPrint("#Mirrorfly Call You are on another call");
              toToast(getTranslated("msgOngoingCallAlert"));
            } else {
              Mirrorfly.makeGroupVoiceCall(groupJid: item.groupId.checkNull().isNotEmpty ? item.groupId! : "", toUserJidList: userList, flyCallBack: (FlyResponse response) {
                if (response.isSuccess) {
                  NavUtils.toNamed(Routes.outGoingCallView, arguments: {"userJid": userList, "callType": CallType.audio});
                }
              });
            }
          }
        }
      } else {
        toToast(getTranslated("noInternetConnection"));
      }
    }
  }

  itemDeleteCallLog(List<String> selectedCallLogs) {
    DialogUtils.showAlert(dialogStyle: AppStyleConfig.dialogStyle,
        message: getTranslated("deleteCallLogConfirmation"),
        actions: [
          TextButton(style: AppStyleConfig.dialogStyle.buttonStyle,
              onPressed: () {
                NavUtils.back();
              },
              child: Text(getTranslated("cancel").toUpperCase(), )),
          TextButton(style: AppStyleConfig.dialogStyle.buttonStyle,
              onPressed: () {
                NavUtils.back();
                Mirrorfly.deleteCallLog(jidList: selectedCallLogs, isClearAll: false, flyCallBack: (FlyResponse response) {
                  if (response.isSuccess) {
                    NavUtils.back(result: true);
                  } else {
                    toToast(getTranslated("errorOnCallLogDelete"));
                  }
                });
              },
              child: Text(getTranslated("ok").toUpperCase(), )),
        ],
        barrierDismissible: true);
  }

}