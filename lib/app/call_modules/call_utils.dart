import 'package:flutter/material.dart';
import '../../app/common/app_localizations.dart';
import '../../app/data/helper.dart';
import '../../app/data/session_management.dart';
import '../../app/extensions/extensions.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';
import 'package:mirrorfly_plugin/model/call_log_model.dart';

import '../common/constants.dart';
import '../data/utils.dart';

class CallUtils {
  static Future<String> getCallersName(List<String?> callUsers,[bool addYou = false]) async {
    LogMessage.d("getCallersName callUsers", callUsers);
    if(callUsers.isEmpty){
      return "";
    }
    var membersName = StringBuffer();
    if(addYou) {
      membersName.write(callUsers.length <= 1 ? "${getTranslated("youAndOtherUsersName")} " : "${getTranslated("you")}, ");
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
          spaceAvailable = membersName.toString().characters.length < Constants.maxNameLength;
          // LogMessage.d("getCallersName $i", "pair.item1 : ${pair.item1} actualMemberName : $membersName isMaxMemberNameNotReached : $isMaxMemberNameNotReached spaceAvailable : $spaceAvailable");
        } else if (spaceAvailable && isMaxMemberNameNotReached && i == 1) {
          membersName.write(", ${pair.item1}");
          var actualMemberName = AppUtils.getActualMemberName(membersName);
          membersName = actualMemberName.item1;
          isMaxMemberNameNotReached = actualMemberName.item2;
          spaceAvailable = membersName.toString().characters.length < Constants.maxNameLength;
          // LogMessage.d("getCallersName $i", "pair.item1 : ${pair.item1} actualMemberName : $membersName isMaxMemberNameNotReached : $isMaxMemberNameNotReached spaceAvailable : $spaceAvailable");
        } else if (spaceAvailable && isMaxMemberNameNotReached && i == 2) {
          membersName.write(", ${pair.item1}");
          var actualMemberName = AppUtils.getActualMemberName(membersName);
          membersName = actualMemberName.item1;
          spaceAvailable = membersName.toString().characters.length < Constants.maxNameLength;
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

  static Future<String> getCallLogUserNames(List<String?> callUsers, CallLogData item) async {

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
          spaceAvailable = membersName.toString().characters.length < Constants.maxNameLength;
          // LogMessage.d("getCallLogUserNames $i", "pair.item1 : ${pair.item1} actualMemberName : $membersName isMaxMemberNameNotReached : $isMaxMemberNameNotReached spaceAvailable : $spaceAvailable");
        } else if (spaceAvailable && isMaxMemberNameNotReached && i == 1) {
          membersName.write(", ${pair.item1}");
          var actualMemberName = AppUtils.getActualMemberName(membersName);
          membersName = actualMemberName.item1;
          isMaxMemberNameNotReached = actualMemberName.item2;
          spaceAvailable = membersName.toString().characters.length < Constants.maxNameLength;
          // LogMessage.d("getCallLogUserNames $i", "pair.item1 : ${pair.item1} actualMemberName : $membersName isMaxMemberNameNotReached : $isMaxMemberNameNotReached spaceAvailable : $spaceAvailable");
        } else if (spaceAvailable && isMaxMemberNameNotReached && i == 2) {
          membersName.write(", ${pair.item1}");
          var actualMemberName = AppUtils.getActualMemberName(membersName);
          membersName = actualMemberName.item1;
          spaceAvailable = membersName.toString().characters.length < Constants.maxNameLength;
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
}
