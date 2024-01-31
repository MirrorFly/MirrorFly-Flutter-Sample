import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';
import 'package:tuple/tuple.dart';

class AppUtils{
  AppUtils._();
  static Future<bool> isNetConnected() async {
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    return isConnected;
  }

  /// * Build initials with given name.
  /// * @parameter Name instance of Profile name
  /// * return initials of the name.
  static String getInitials(String name){
      String string = "";
      // debugPrint("str.characters.length ${str}");
      if (name.characters.length >= 2) {
        if (name.trim().contains(" ")) {
          var st = name.trim().split(" ");
          string = st[0].characters.take(1).toUpperCase().toString() +
              st[1].characters.take(1).toUpperCase().toString();
        } else {
          string = name.characters.take(2).toUpperCase().toString();
        }
      } else {
        string = name;
      }
      return string;
  }

  static Tuple2<StringBuffer,bool> getActualMemberName(StringBuffer string){
    // LogMessage.d("getActualMemberName","${string} string length ${string.length} characters ${string.toString().characters.length}");
    return (string.toString().characters.length > Constants.maxNameLength) ?
    Tuple2(
      StringBuffer("${string.toString().characters.take(Constants.maxNameLength)}..."),
      false
    )
    :
    Tuple2(string, true);
  }

  static Future<Tuple2<String, ProfileDetails>> getNameAndProfileDetails(String jid) async {
    var profileDetails = await getProfileDetails(jid);
    var name = profileDetails.getName();
    return Tuple2(name, profileDetails);
  }

  static Map getExceptionMap(String code,String message){
    var map = {};
    map["code"]=code;
    map["message"]=message;
    return map;
  }
}