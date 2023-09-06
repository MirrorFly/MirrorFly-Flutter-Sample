import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

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
}