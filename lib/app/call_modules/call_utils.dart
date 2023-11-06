import 'package:mirror_fly_demo/app/call_modules/call_logs/call_log_model.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/data/session_management.dart';
import 'package:mirrorfly_plugin/logmessage.dart';

import '../data/apputils.dart';

class CallUtils {
  static Future<String> getCallersName(List<String?> callUsers) async {
    var membersName = StringBuffer();
    membersName.write(callUsers.length <= 1 ? "You and " : "You, ");
    var isMaxMemberNameNotReached = true;
    for (var i = 0; i < callUsers.length; i++) {
      if (callUsers[i] != null) {
        var pair = await AppUtils.getNameAndProfileDetails(callUsers[i]!);
        if (i == 0) {
          membersName.write(pair.item1);
          var actualMemberName = AppUtils.getActualMemberName(membersName);
          membersName = actualMemberName.item1;
          isMaxMemberNameNotReached = actualMemberName.item2;
        } else if (isMaxMemberNameNotReached && i == 1) {
          membersName.write(", ${pair.item1}");
          var actualMemberName = AppUtils.getActualMemberName(membersName);
          membersName = actualMemberName.item1;
          isMaxMemberNameNotReached = actualMemberName.item2;
        } else if (isMaxMemberNameNotReached && i == 2) {
          membersName.write(", ${pair.item1}");
          var actualMemberName = AppUtils.getActualMemberName(membersName);
          membersName = actualMemberName.item1;
        } else {
          membersName.write(" (+${(callUsers.length - i)})");
          break;
        }
      } else {
        break;
      }
    }
    return membersName.toString();
  }

  static Future<String> getNameOfJid(String jid) async {
    if (jid == SessionManagement.getUserJID()) {
      return "You";
    }
    var profile = await getProfileDetails(jid);
    return profile.getName();
  }

  static Future<String> getCallLogUserNames(List<String?> callUsers, CallLogData item) async {

    var membersName = StringBuffer();
    var isMaxMemberNameNotReached = true;

    if (item.callState == 0 || item.callState == 2) {
      var pair = await AppUtils.getNameAndProfileDetails(item.fromUser!);
      membersName.write("${pair.item1}, ");
    }

    for (var i = 0; i < callUsers.length; i++) {
      if (callUsers[i] != null) {
        var pair = await AppUtils.getNameAndProfileDetails(callUsers[i]!);
        if (i == 0) {
          membersName.write(pair.item1);
          var actualMemberName = AppUtils.getActualMemberName(membersName);
          membersName = actualMemberName.item1;
          isMaxMemberNameNotReached = actualMemberName.item2;
        } else if (isMaxMemberNameNotReached && i == 1) {
          membersName.write(", ${pair.item1}");
          var actualMemberName = AppUtils.getActualMemberName(membersName);
          membersName = actualMemberName.item1;
          isMaxMemberNameNotReached = actualMemberName.item2;
        } else if (isMaxMemberNameNotReached && i == 2) {
          membersName.write(", ${pair.item1}");
          var actualMemberName = AppUtils.getActualMemberName(membersName);
          membersName = actualMemberName.item1;
        } else {
          membersName.write(" (+${(callUsers.length - i)})");
          break;
        }
      } else {
        break;
      }
    }
    return membersName.toString();
  }
}
