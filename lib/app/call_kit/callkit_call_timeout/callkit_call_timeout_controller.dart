
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import '../../common/app_localizations.dart';
import '../../common/constants.dart';
import '../../data/permissions.dart';
import '../../data/utils.dart';
import '../../routes/route_settings.dart';

class CallKitCallTimeoutController extends GetxController {
  var callType = ''.obs;
  var callMode = ''.obs;

  // var userJID = ''.obs;
  var calleeName = ''.obs;

  // Rx<Profile> profile = Profile().obs;

  RxList<String?> users = <String?>[].obs;
  var groupId = ''.obs;



  @override
  Future<void> onInit() async {
    if (NavUtils.arguments != null) {
      callType.value = (NavUtils.arguments["callType"]);
      users.value = (NavUtils.arguments["userJid"] as List<String?>);
      calleeName.value = (NavUtils.arguments["calleeName"]);
      callMode.value = (NavUtils.arguments["callMode"]);
      debugPrint("Call Timeout OnInit arguments => $callType $users $calleeName");
    }
    super.onInit();

    // var data = await getProfileDetails(userJID.value);
    // profile(data);
  }



  void cancelCallTimeout() {
    NavUtils.back();
  }

  callAgain() async {
    // NavUtils.offNamed(Routes.outGoingCallView, arguments: {"userJid": userJID.value});
    if (await AppUtils.isNetConnected()) {
      if (callType.value == CallType.audio) {
        if (await AppPermission.askAudioCallPermissions()) {
          if (users.length == 1) {
            await MirrorFlyCallKit.makeAudioCall(
                callersId: [
                  users.first ?? "",
                ],
                callMode: callMode.value,
                //callersId: ["919000000007"], //callersId: ["919944964758"], // callersId: ["919000000008"], //
                chatId: '',
              flyResult: (FlyResult response) {
                if (response.isSuccess) {
                  NavUtils.offNamed(Routes.callKitOutGoingCallView, arguments: {
                    "userJid": users.toList(),
                    "callType": callType.value
                  });
                } else {
                  toToast("CF Not connected");
                }
              },);
          } else {
            var usersList = <String>[];
            for (var element in users) {
              if (element != null) {
                usersList.add(element);
              }
            }
            // Mirrorfly.makeGroupVoiceCall(
            //     groupJid: groupId.value,
            //     toUserJidList: usersList,
            //     flyCallBack: (FlyResponse response) {
            //       NavUtils.offNamed(Routes.outGoingCallView,
            //           arguments: {"userJid": users});
            //     });
          }
        } else {
          debugPrint("permission not given");
        }
      } else {
        if (await AppPermission.askVideoCallPermissions()) {
          if (users.length == 1) {
            await MirrorFlyCallKit.makeVideoCall(
                callersId: [users.first ?? "",],
                chatId: '',
                callMode: callMode.value,
                flyResult: (FlyResult response) {
                  if (response.isSuccess) {
                    NavUtils.offNamed(Routes.callKitOutGoingCallView, arguments: {
                      "userJid": users.toList(),
                      "callType": CallType.video
                    });
                  } else {
                    toToast("CF Not connected");
                  }
                });
          } else {
            var usersList = <String>[];
            for (var element in users) {
              if (element != null) {
                usersList.add(element);
              }
            }
            // Mirrorfly.makeGroupVideoCall(
            //     groupJid: groupId.value,
            //     toUserJidList: usersList,
            //     flyCallBack: (FlyResponse response) {
            //       NavUtils.offNamed(Routes.outGoingCallView,
            //           arguments: {"userJid": users,"callType": CallType.video});
            //     });
          }
        } else {
          LogMessage.d("askVideoCallPermissions", "false");
        }
      }
    } else {
      toToast(getTranslated("noInternetConnection"));
    }
  }
}