import 'package:flutter/material.dart';
import 'package:flutter_in_app_pip/picture_in_picture.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/call_kit/callkit_logger.dart';
import 'package:mirror_fly_demo/app/call_kit/callkit_outgoing_call_controller.dart';
import '../../app/common/app_localizations.dart';
import '../../app/data/helper.dart';
import '../../app/data/session_management.dart';
import '../../app/extensions/extensions.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';
import 'package:mirrorfly_plugin/model/call_log_model.dart';

import '../call_kit/callkit_pip/callkit_pip_controller.dart';
import '../common/constants.dart';
import '../data/utils.dart';
import '../routes/app_pages.dart';
import '../routes/route_settings.dart';

class CallUtils {

  static Future<bool> _isMirrorFlyCallKitCallOngoing() async {
    if (!Constants.useMirrorFlyCallKit) {
      return false;
    }
    return await MirrorFlyCallKit.isOngoingCall();
  }

  /// ---------------------------------------------------
  /// Check whether tapped link is same as current call link
  /// ---------------------------------------------------
  static Future<bool> _isSameJoinLink({
    required String linkTapped,
  }) async {
    callkitLogger.info("#CallUtils #isSameJoinLink tappedLink: $linkTapped");
    if (!Constants.useMirrorFlyCallKit) {
      return false;
    }

    final GetCallJoinLinkResponse response = await MirrorFlyCallKit.getCallJoinLink();
    callkitLogger.info("#CallUtils #isSameJoinLink response: ${response.toMap()}");

    if (!response.isSuccess) {
      return false;
    }
    return response.callId == linkTapped;
  }

  static Future<bool> _isCallControllerRegistered() async {
    if (!Constants.useMirrorFlyCallKit) {
      return false;
    }

    final bool isOutGoingCallControllerRegistered = Get.isRegistered<CallKitOutgoingCallController>();
    final bool isPipControllerRegistered = Get.isRegistered<CallKitPipController>();

    callkitLogger.info("#CallUtils #_isCallControllerRegistered"
        " #isOutGoingCallControllerRegistered: $isOutGoingCallControllerRegistered, #isPipControllerRegistered: $isPipControllerRegistered");
    return isOutGoingCallControllerRegistered || isPipControllerRegistered;
  }

  static Future<void> onJoinLinkTapped({required String link}) async {
    callkitLogger.info("#CallUtils #onJoinLinkTapped called with link: $link");

    if (link.isEmpty) {
      callkitLogger.info("#onJoinLinkTapped #invalidLink");
      return;
    }

    if (Constants.useMirrorFlyCallKit) {

      final bool isAlreadyInCall = await _isMirrorFlyCallKitCallOngoing();
      if (!isAlreadyInCall) {
        callkitLogger.info("#CallUtils #onJoinLinkTapped no ongoing call, navigating to join call preview");
        NavUtils.toNamed(Routes.callKitJoinCallPreview, arguments: {
          "callLinkId": link,
          "navigatedFrom": "MeetLinkView-Build"
        });
        return;
      }

      final bool isSameJoinLink = await _isSameJoinLink(linkTapped: link);
      final bool isCallControllerActive = await _isCallControllerRegistered();

      callkitLogger.info("#CallUtils #onJoinLinkTapped #isSameJoinLink: $isSameJoinLink,"
              " #isCallControllerActive: $isCallControllerActive");

      if (isAlreadyInCall && isSameJoinLink && isCallControllerActive) {
        final bool isPipControllerRegistered = Get.isRegistered<CallKitPipController>();

        if (isPipControllerRegistered) {
          PictureInPicture.stopPiP();
        }

        NavUtils.toNamed(AppPages.callKitCallView);
        return;
      }

      if (isAlreadyInCall) {
        toToast(getTranslated("alreadyInOnGoingCall"));
        return;
      }

      NavUtils.toNamed(Routes.callKitJoinCallPreview, arguments: {
        "callLinkId": link,
        "navigatedFrom": "MeetLinkView-Build"
      });
    }
  }

  /// Removes everything after '@' from each caller ID.
  static String getIdFromJidList(String callersId) {
    return callersId.split('@').first;
  }

  static String getGroupJidFromGroupId(String groupId){
    const domain =  "@mix.xmpp-fergus.mirrorfly.com";
    if(groupId != "") {
      if (groupId.endsWith(domain)) {
        return groupId;
      } else {
        return "$groupId$domain";
      }
    }else{
      return groupId;
    }

  }

  static String getJidFromUserId({required String userId, required bool isGroup}) {
    final domain = isGroup ? "@mix.xmpp-fergus.mirrorfly.com" : "@xmpp-fergus.mirrorfly.com";
    if (userId.endsWith(domain)) {
      return userId;
    } else {
      return "$userId$domain";
    }
  }

  static Future<String> getCallersName(List<String?> callUsers,
      [bool addYou = false]) async {
    LogMessage.d("getCallersName callUsers", callUsers);
    if (callUsers.isEmpty) {
      return "";
    }
    var membersName = StringBuffer();
    if (addYou) {
      membersName.write(callUsers.length <= 1
          ? "${getTranslated("youAndOtherUsersName")} "
          : "${getTranslated("you")}, ");
    }
    var isMaxMemberNameNotReached = true;
    var spaceAvailable = true;
    for (var i = 0; i < callUsers.length; i++) {
      if (callUsers[i] != null) {
        var pair = await AppUtils.getNameAndProfileDetails(callUsers[i]!);
        if (i == 0) {
          membersName.write(pair.item1);
          var actualMemberName = AppUtils.getActualMemberName(membersName);
          membersName = actualMemberName.item1;
          isMaxMemberNameNotReached = actualMemberName.item2;
          spaceAvailable = membersName.toString().characters.length <
              Constants.maxNameLength;
          // LogMessage.d("getCallersName $i", "pair.item1 : ${pair.item1} actualMemberName : $membersName isMaxMemberNameNotReached : $isMaxMemberNameNotReached spaceAvailable : $spaceAvailable");
        } else if (spaceAvailable && isMaxMemberNameNotReached && i == 1) {
          membersName.write(", ${pair.item1}");
          var actualMemberName = AppUtils.getActualMemberName(membersName);
          membersName = actualMemberName.item1;
          isMaxMemberNameNotReached = actualMemberName.item2;
          spaceAvailable = membersName.toString().characters.length <
              Constants.maxNameLength;
          // LogMessage.d("getCallersName $i", "pair.item1 : ${pair.item1} actualMemberName : $membersName isMaxMemberNameNotReached : $isMaxMemberNameNotReached spaceAvailable : $spaceAvailable");
        } else if (spaceAvailable && isMaxMemberNameNotReached && i == 2) {
          membersName.write(", ${pair.item1}");
          var actualMemberName = AppUtils.getActualMemberName(membersName);
          membersName = actualMemberName.item1;
          spaceAvailable = membersName.toString().characters.length <
              Constants.maxNameLength;
          // LogMessage.d("getCallersName $i", "pair.item1 : ${pair.item1} actualMemberName : $membersName isMaxMemberNameNotReached : $isMaxMemberNameNotReached spaceAvailable : $spaceAvailable");
        } else {
          membersName.write(" (+${(callUsers.length - i)})");
          // LogMessage.d("getCallersName $i else", "pair.item1 : ${pair.item1} actualMemberName : $membersName isMaxMemberNameNotReached : $isMaxMemberNameNotReached spaceAvailable : $spaceAvailable");
          break;
        }
      } else {
        break;
      }
    }
    LogMessage.d("getCallersName membersName", membersName);
    return membersName.toString();
  }

  static Future<String> getNameOfJid(String jid) async {
    if (jid == SessionManagement.getUserJID()) {
      return getTranslated("you");
    }
    var profile = await getProfileDetails(jid);
    return profile.getName();
  }

  static Future<String> getCallLogUserNames(
      List<String?> callUsers, CallLogData item) async {
    var membersName = StringBuffer();
    var isMaxMemberNameNotReached = true;
    var spaceAvailable = true;
    // if (item.callState == CallState.missedCall || item.callState == CallState.incomingCall) {
    //   var pair = await AppUtils.getNameAndProfileDetails(item.fromUser!);
    //   membersName.write("${pair.item1}, ");
    // }

    for (var i = 0; i < callUsers.length; i++) {
      if (callUsers[i] != null) {
        var pair = await AppUtils.getNameAndProfileDetails(callUsers[i]!);
        if (i == 0) {
          membersName.write(pair.item1);
          var actualMemberName = AppUtils.getActualMemberName(membersName);
          membersName = actualMemberName.item1;
          isMaxMemberNameNotReached = actualMemberName.item2;
          spaceAvailable = membersName.toString().characters.length <
              Constants.maxNameLength;
          // LogMessage.d("getCallLogUserNames $i", "pair.item1 : ${pair.item1} actualMemberName : $membersName isMaxMemberNameNotReached : $isMaxMemberNameNotReached spaceAvailable : $spaceAvailable");
        } else if (spaceAvailable && isMaxMemberNameNotReached && i == 1) {
          membersName.write(", ${pair.item1}");
          var actualMemberName = AppUtils.getActualMemberName(membersName);
          membersName = actualMemberName.item1;
          isMaxMemberNameNotReached = actualMemberName.item2;
          spaceAvailable = membersName.toString().characters.length <
              Constants.maxNameLength;
          // LogMessage.d("getCallLogUserNames $i", "pair.item1 : ${pair.item1} actualMemberName : $membersName isMaxMemberNameNotReached : $isMaxMemberNameNotReached spaceAvailable : $spaceAvailable");
        } else if (spaceAvailable && isMaxMemberNameNotReached && i == 2) {
          membersName.write(", ${pair.item1}");
          var actualMemberName = AppUtils.getActualMemberName(membersName);
          membersName = actualMemberName.item1;
          spaceAvailable = membersName.toString().characters.length <
              Constants.maxNameLength;
          // LogMessage.d("getCallLogUserNames $i", "pair.item1 : ${pair.item1} actualMemberName : $membersName isMaxMemberNameNotReached : $isMaxMemberNameNotReached spaceAvailable : $spaceAvailable");
        } else {
          membersName.write(" (+${(callUsers.length - i)})");
          // LogMessage.d("getCallLogUserNames $i else", "pair.item1 : ${pair.item1} actualMemberName : $membersName isMaxMemberNameNotReached : $isMaxMemberNameNotReached spaceAvailable : $spaceAvailable");
          break;
        }
      } else {
        break;
      }
    }
    return membersName.toString();
  }

  static Future<String> getCallKitLogUserNames(List<String?> callUsers, CallLog item) async {
    var membersName = StringBuffer();
    var isMaxMemberNameNotReached = true;
    var spaceAvailable = true;
    // if (item.callState == CallState.missedCall || item.callState == CallState.incomingCall) {
    //   var pair = await AppUtils.getNameAndProfileDetails(item.fromUser!);
    //   membersName.write("${pair.item1}, ");
    // }

    final List<String> callUsersJid = callUsers.map((e) => getJidFromUserId(userId: e ?? "", isGroup: false)).toList();

    for (var i = 0; i < callUsersJid.length; i++) {
      var pair = await AppUtils.getNameAndProfileDetails(callUsersJid[i]);
      if (i == 0) {
        membersName.write(pair.item1);
        var actualMemberName = AppUtils.getActualMemberName(membersName);
        membersName = actualMemberName.item1;
        isMaxMemberNameNotReached = actualMemberName.item2;
        spaceAvailable = membersName.toString().characters.length <
            Constants.maxNameLength;
        // LogMessage.d("getCallLogUserNames $i", "pair.item1 : ${pair.item1} actualMemberName : $membersName isMaxMemberNameNotReached : $isMaxMemberNameNotReached spaceAvailable : $spaceAvailable");
      } else if (spaceAvailable && isMaxMemberNameNotReached && i == 1) {
        membersName.write(", ${pair.item1}");
        var actualMemberName = AppUtils.getActualMemberName(membersName);
        membersName = actualMemberName.item1;
        isMaxMemberNameNotReached = actualMemberName.item2;
        spaceAvailable = membersName.toString().characters.length <
            Constants.maxNameLength;
        // LogMessage.d("getCallLogUserNames $i", "pair.item1 : ${pair.item1} actualMemberName : $membersName isMaxMemberNameNotReached : $isMaxMemberNameNotReached spaceAvailable : $spaceAvailable");
      } else if (spaceAvailable && isMaxMemberNameNotReached && i == 2) {
        membersName.write(", ${pair.item1}");
        var actualMemberName = AppUtils.getActualMemberName(membersName);
        membersName = actualMemberName.item1;
        spaceAvailable = membersName.toString().characters.length <
            Constants.maxNameLength;
        // LogMessage.d("getCallLogUserNames $i", "pair.item1 : ${pair.item1} actualMemberName : $membersName isMaxMemberNameNotReached : $isMaxMemberNameNotReached spaceAvailable : $spaceAvailable");
      } else {
        membersName.write(" (+${(callUsersJid.length - i)})");
        // LogMessage.d("getCallLogUserNames $i else", "pair.item1 : ${pair.item1} actualMemberName : $membersName isMaxMemberNameNotReached : $isMaxMemberNameNotReached spaceAvailable : $spaceAvailable");
        break;
      }
        }
    return membersName.toString();
  }

}
