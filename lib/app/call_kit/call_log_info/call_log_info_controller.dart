import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/call_kit/callkit_logger.dart';
import 'package:mirror_fly_demo/app/extensions/extensions.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import 'package:mirrorfly_plugin/mirrorflychat.dart';
import 'package:mirrorfly_plugin/model/call_log_model.dart';

import '../../app_style_config.dart';
import '../../call_modules/call_utils.dart';
import '../../common/app_localizations.dart';
import '../../common/constants.dart';
import '../../data/permissions.dart';
import '../../data/utils.dart';
import '../../routes/route_settings.dart';


class CallLogInfoController extends GetxController{

  var callKitLogData = CallLog().obs;
  CallLog get callKitLog => callKitLogData.value;
  final String tag = "CallInfoController";

  @override
  void onInit() {
    callKitLogData(NavUtils.arguments as CallLog);
    callkitLogger.info("CallInfoController initialized");
    super.onInit();
  }

  makeCallKitCall() {
    callkitLogger.info("$tag makeCallKitCall called");

    final bool isVideoCall = callKitLog.callType == CallType.video;
    callkitLogger.info("$tag Call type determined: ${isVideoCall ? 'Video' : 'Audio'}");

    final List<String> callersId = callKitLog.callParticipants ?? [];
    final String chatId = callKitLog.chatId ?? "";
    final bool isOneToOne = callersId.length == 1;

    if (isVideoCall) {
      _makeCallKitVideoCall(callersId: callersId, chatId: chatId, isOneToOne: isOneToOne);
    } else {
      _makeCallKitAudioCall(callersId: callersId, chatId: chatId, isOneToOne: isOneToOne);
    }
  }

  void _makeCallKitVideoCall({required List<String> callersId, required String chatId, required bool isOneToOne}) async {
    callkitLogger.info("$tag makeCallKitVideoCall function called with callersId: $callersId, chatId: $chatId, isOneToOne: $isOneToOne");

    if ((await MirrorFlyCallKit.isOngoingCall()).checkNull()) {
      debugPrint("#Mirrorfly Call You are on another call");
      toToast(getTranslated("msgOngoingCallAlert"));
      return;
    }

    final blockedUsers = (await getUsersIBlocked()).toSet();
    final List<String> blockedUsersId = blockedUsers.map((e) => CallUtils.getIdFromJidList(e)).toList();
    callkitLogger.info("$tag Blocked users fetched: $blockedUsersId");

    final List<String> filteredCallersId = callersId.where((callerId) {
      final isBlocked = blockedUsersId.contains(callerId);
      if (isBlocked) {
        callkitLogger.info("$tag User $callerId is blocked. Removing from call.");
      }
      return !isBlocked;
    }).toList();

    if (await AppUtils.isNetConnected()) {
      if (await AppPermission.askVideoCallPermissions()) {
        MirrorFlyCallKit.makeVideoCall(
          callersId: filteredCallersId,
          chatId: chatId,
          flyResult: (FlyResult response) {
            if (response.isSuccess) {
              callkitLogger.info("Call started successfully");
              NavUtils.toNamed(Routes.callKitOutGoingCallView, arguments: {
                "userJid": callersId,
                "callType": CallType.video,
                "callMode": isOneToOne ? "ONE-TO-ONE" : "ONE-TO-MANY",
                "chatId": chatId,
              });
            } else {
              callkitLogger.info("Call failed: ${response.errorMessage}");
            }
          },
        );
      } else {
        LogMessage.d("askVideoCallPermissions", "false");
      }
    } else {
      toToast(getTranslated("noInternetConnection"));
    }
  }

  Future<List<String>> getUsersIBlocked() async {
    final completer = Completer<List<String>>();

    Mirrorfly.getUsersIBlocked(
      fetchFromServer: true,
      flyCallBack: (FlyResponse response) {
        if (response.isSuccess && response.hasData) {
          LogMessage.d("getUsersIBlocked", response.toString());

          final List<ProfileDetails> data =
          profileFromJson(response.data);

          final List<String> blockedJIds =
          data.map((e) => e.jid ?? "").toList();

          completer.complete(blockedJIds);
        } else {
          LogMessage.d(
            "getUsersIBlocked",
            "Failed to fetch blocked users",
          );

          completer.complete([]);
        }
      },
    );

    return completer.future;
  }


  void _makeCallKitAudioCall({required List<String> callersId, required String chatId, required bool isOneToOne}) async {
    callkitLogger.info("$tag makeCallKitAudioCall function called with callersId: $callersId, chatId: $chatId, isOneToOne: $isOneToOne");

    if ((await MirrorFlyCallKit.isOngoingCall()).checkNull()) {
      debugPrint("#Mirrorfly Call You are on another call");
      toToast(getTranslated("msgOngoingCallAlert"));
      return;
    }

    if (!(await AppUtils.isNetConnected())) {
      toToast(getTranslated("noInternetConnection"));
      return;
    }

    final blockedUsers = (await getUsersIBlocked()).toSet();
   final List<String> blockedUsersId = blockedUsers.map((e) => CallUtils.getIdFromJidList(e)).toList();
    callkitLogger.info("$tag Blocked users fetched: $blockedUsersId");

    final List<String> filteredCallersId = callersId.where((callerId) {
      final isBlocked = blockedUsersId.contains(callerId);
      if (isBlocked) {
        callkitLogger.info("$tag User $callerId is blocked. Removing from call.");
      }
      return !isBlocked;
    }).toList();

    if (await AppPermission.askAudioCallPermissions()) {
      MirrorFlyCallKit.makeAudioCall(
          callersId: filteredCallersId,
          chatId: chatId,
          flyResult: (FlyResult response) {
            if (response.isSuccess) {
              callkitLogger.info("Audio call started successfully");
              NavUtils.toNamed(Routes.callKitOutGoingCallView, arguments: {
                "userJid": callersId,
                "callType": CallType.audio,
                "callMode": isOneToOne ? "ONE-TO-ONE" : "ONE-TO-MANY",
                "chatId": chatId,
              });
            } else {
              callkitLogger.info("Audio call failed: ${response.errorMessage}");
            }
          });
    } else {
      debugPrint("permission not given");
    }
  }


  itemDeleteCallKitCall() {
    callkitLogger.info("$tag itemDeleteCallKitCall called");
    DialogUtils.showAlert(dialogStyle: AppStyleConfig.dialogStyle,
        message: getTranslated("deleteCallLogConfirmation"),
        actions: [
          TextButton(style: AppStyleConfig.dialogStyle.buttonStyle,
              onPressed: () {
                NavUtils.back();
              },
              child: Text(getTranslated("cancel").toUpperCase(), )),
          TextButton(style: AppStyleConfig.dialogStyle.buttonStyle,
              onPressed: () async {
                NavUtils.back();
                final bool isDeleted = await MirrorFlyCallKit.clearCallLogs(callIds: [callKitLogData.value.callId ?? 0]);
                if (isDeleted) {
                  NavUtils.back(result: true);
                } else {
                  callkitLogger.info("$tag Failed to delete call log");
                }
              },
              child: Text(getTranslated("ok").toUpperCase(), )),
        ],
        barrierDismissible: true);
  }
}