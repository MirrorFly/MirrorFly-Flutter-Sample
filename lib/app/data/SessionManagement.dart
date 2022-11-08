import 'dart:convert';

import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/model/registerModel.dart' as register;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/profileupdate.dart';


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

  static Future setMediaEndPoint(String media_endpoint) async {
    await _preferences.setString("media_endpoint", media_endpoint);
  }
  static Future setAuthtoken(String authtoken) async {
    await _preferences.setString("token", authtoken);
  }
  static Future setToken(String firebase_token) async {
    await _preferences.setString("firebase_token", firebase_token);
  }
  static Future setMobile(String mobile) async {
    await _preferences.setString("mobile", mobile);
  }
  static Future setUserJID(String jid) async {
    await _preferences.setString("user_jid", jid);
  }
  static Future setUserImage(String image) async {
    await _preferences.setString("image", image);
  }
  static Future clear()async{
    await _preferences.clear();
  }

  static Future setUser(register.Data data) async {
    await _preferences.setString('token', data.token.checkNull());
    await _preferences.setString('username', data.username.checkNull());
    await _preferences.setString('password', data.password.checkNull());
    /*data.toJson().forEach((key, value) async {
      await _preferences.setString(key, value.toString());
    });
    var userData = jsonEncode(data);
    await _preferences.setString('userData', userData);*/
  }

  static Future setCurrentUser(Data data) async {
    data.toJson().forEach((key, value) async {
      await _preferences.setString(key, value.toString());
    });
  }

  bool getLogin() => _preferences.getBool("login") == null
      ? false
      : _preferences.getBool("login")!;

  String? getName() => _preferences.getString("name");
  String? getMobileNumber() => _preferences.getString("mobileNumber");
  String? getUsername() => _preferences.getString("username");
  String? getPassword() => _preferences.getString("password");
  String? getUserJID() => _preferences.getString("user_jid").toString();
  String? getUserImage() => _preferences.getString("image");
  String? getToken() => _preferences.getString("firebase_token");
  String? getauthToken() => _preferences.getString("token");
  String? getMediaEndPoint() => _preferences.getString("media_endpoint");
  bool? synced() => _preferences.getBool("synced");
}