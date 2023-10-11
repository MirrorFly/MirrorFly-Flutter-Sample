import '../data/apputils.dart';

class CallUtils{
  static Future<String> getCallersName(List<String?> callUsers) async {
    var membersName = StringBuffer("");
    var isMaxMemberNameNotReached = true;
    for (var i = 0; i<callUsers.length;i++) {
      if(callUsers[i]!=null) {
        var pair = await AppUtils.getNameAndProfileDetails(callUsers[i]!);
        if (i == 0) {
          var actualMemberName = AppUtils.getActualMemberName(StringBuffer(pair.item1));
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
      }else{
        break;
      }
    }
    return membersName.toString();
  }
}