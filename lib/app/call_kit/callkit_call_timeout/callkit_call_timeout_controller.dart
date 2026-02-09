
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/call_kit/callkit_logger.dart';
import 'package:mirror_fly_demo/app/call_modules/call_utils.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import '../../common/app_localizations.dart';
import '../../common/constants.dart';
import '../../data/permissions.dart';
import '../../data/utils.dart';
import '../../routes/route_settings.dart';
import '../callkit_event_buffer.dart';

class CallKitCallTimeoutController extends GetxController {
  var callType = ''.obs;
  var callMode = ''.obs;

  // var userJID = ''.obs;
  var calleeName = ''.obs;

  // Rx<Profile> profile = Profile().obs;

  RxList<String> users = <String>[].obs;
  RxList<String> usersJid = <String>[].obs;
  var groupId = ''.obs;
  var groupJid = ''.obs;



  @override
  Future<void> onInit() async {
    if (NavUtils.arguments != null) {
      callType.value = (NavUtils.arguments["callType"]);
      users.value = (NavUtils.arguments["userJid"] as List<String>);
      calleeName.value = (NavUtils.arguments["calleeName"]);
      callMode.value = (NavUtils.arguments["callMode"]);
      groupId.value = (NavUtils.arguments["groupId"] ?? '');
      debugPrint("Call Timeout OnInit arguments => $callType $users $calleeName");
      addDomainToJid();
      addDomainToGroupJid();
    }
    super.onInit();

    // var data = await getProfileDetails(userJID.value);
    // profile(data);
  }

  void addDomainToJid() {
    const domain = "@xmpp-uikit-qa.contus.us";

    final formatted = users.map((id) {
      return id.endsWith(domain) ? id : "$id$domain";
    }).toList();

    usersJid.addAll(formatted);
  }

  void addDomainToGroupJid(){
    const domain = "@mix-xmpp-uikit-qa.contus.us";
    if(groupId.value.isEmpty) return;
    if(!groupId.value.endsWith(domain)){
      groupJid.value = "${groupId.value}$domain";
    }
  }



  void cancelCallTimeout() {
    NavUtils.back();
  }

  callAgain() async {
    // NavUtils.offNamed(Routes.outGoingCallView, arguments: {"userJid": userJID.value});
    callkitLogger.info("Call Again Pressed");
    if (await AppUtils.isNetConnected()) {
      if (callType.value == CallType.audio) {
        if (await AppPermission.askAudioCallPermissions()) {

            final List<String> userList = users.toList();
            callkitLogger.info("Making Audio Call to ${userList.toString()}");

            final List<String> normalizedUserList = userList.map((jid) => CallUtils.getIdFromJidList(jid)).toList();
            CallkitLogger().info("Normalized User List for Audio Call: ${normalizedUserList.toString()}");

            final String normalizedGroupId = CallUtils.getIdFromJidList(groupJid.value);
            CallkitLogger().info("Normalized Group ID for Audio Call: $normalizedGroupId");

            if (!await AppUtils.isNetConnected()) {
              callkitLogger.info('#callAgain No internet connection available');
              toToast(getTranslated("noInternetConnection"));
              return;
            }

            CallKitEventBuffer.flushAllEvents();
            await MirrorFlyCallKit.makeAudioCall(
                flyResult: (FlyResult response) {
                  if (response.isSuccess) {
                    NavUtils.offNamed(Routes.callKitOutGoingCallView, arguments: {
                      "userJid": normalizedUserList,
                      "callType": CallType.audio,
                      "callMode": callMode.value,
                      "chatId": normalizedGroupId,
                    });
                  } else {
                    toToast(response.message ?? response.data);
                  }
                },
                callersId:
                normalizedUserList,
                // callMode: "ONE-TO-ONE",
                //callersId: ["919000000007"], //callersId: ["919944964758"], // callersId: ["919000000008"], //
                chatId: normalizedGroupId);

        } else {
          debugPrint("permission not given");
        }
      } else {
        if (await AppPermission.askVideoCallPermissions()) {

          final List<String> normalizedUserList = users.map((jid) => CallUtils.getIdFromJidList(jid)).toList();
          CallkitLogger().info("Normalized User List for Video Call: ${normalizedUserList.toString()}");

          final String normalizedGroupId = CallUtils.getIdFromJidList(groupJid.value);
          CallkitLogger().info("Normalized Group ID for Video Call: $normalizedGroupId");

          if (!await AppUtils.isNetConnected()) {
            callkitLogger.info('#makeVideoCall No internet connection available');
            toToast(getTranslated("noInternetConnection"));
            return;
          }

          final List<String> userList = users.toList();
          CallKitEventBuffer.flushAllEvents();
          await MirrorFlyCallKit.makeVideoCall(
                flyResult: (FlyResult response) {
                  if (response.isSuccess) {
                    NavUtils.offNamed(Routes.callKitOutGoingCallView, arguments: {
                      "userJid": normalizedUserList,
                      "callType": CallType.video,
                      "callMode": callMode.value,
                      "chatId": normalizedGroupId,
                    });
                  } else {
                    toToast(response.message ?? response.data);
                  }
                },
                callersId:
                normalizedUserList,
                // callMode: "ONE-TO-ONE",
                //callersId: ["919000000007"], //callersId: ["919944964758"], // callersId: ["919000000008"], //
                chatId: normalizedGroupId);

        } else {
          LogMessage.d("askVideoCallPermissions", "false");
        }
      }
    } else {
      toToast(getTranslated("noInternetConnection"));
    }
  }

  String getJidFromUserId({required String userId, required bool isGroup}) {
    final domain = isGroup ? "@mix.xmpp-uikit-qa.contus.us" : "@xmpp-uikit-qa.contus.us";
    if (userId.endsWith(domain)) {
      return userId;
    } else {
      return "$userId$domain";
    }
  }
}