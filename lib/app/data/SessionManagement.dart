import 'dart:convert';

import 'package:mirror_fly_demo/app/model/registerModel.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SessionManagement {
  static late SharedPreferences _preferences;

  static Future onInit() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static Future setLogin(bool val) async {
    await _preferences.setBool("login", val);
  }

  static Future setSync(bool val) async {
    await _preferences.setBool("synced", val);
  }

  static Future setAuthtoken(String authtoken) async {
    await _preferences.setString("authtoken", authtoken);
  }
  static Future setMobile(String mobile) async {
    await _preferences.setString("mobile", mobile);
  }
  static Future setUserJID(String jid) async {
    await _preferences.setString("user_jid", jid);
  }
  static Future setUserImage(String image) async {
    await _preferences.setString("user_image", image);
  }
  static Future clear()async{
    await _preferences.clear();
  }

  static Future setUser(Data data) async {
    // register.toMap().forEach((key, value) async {
    //   await _preferences.setString(key, value.toString());
    // });
    var userData = jsonEncode(data);
    await _preferences.setString('userData', userData);
  }

  bool getLogin() => _preferences.getBool("login") == null
      ? false
      : _preferences.getBool("login")!;

  String? getUsername() => _preferences.getString("username").toString();
  String? getPassword() => _preferences.getString("password").toString();
  String? getUserJID() => _preferences.getString("user_jid").toString();
  String? getUserImage() => _preferences.getString("user_image");
  String? getauthToken() => _preferences.getString("authtoken");
  bool? synced() => _preferences.getBool("synced");
}