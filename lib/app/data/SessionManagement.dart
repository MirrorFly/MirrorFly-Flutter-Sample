import 'dart:convert';

import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/model/registerModel.dart' as register;
import 'package:shared_preferences/shared_preferences.dart';

import '../common/constants.dart';
import '../model/profileupdate.dart';


class SessionManagement {
  static late SharedPreferences _preferences;

  setDefaultValues(){
    if(_preferences.containsKey(Constants.PACKAGE+"notification_sound")){

    }
  }
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
  static Future conv_sound(bool conv_sound) async {
    await _preferences.setBool("conv_sound", conv_sound);
  }
  static Future vibration_type(String vibration_type) async {
    await _preferences.setString("vibration_type", vibration_type);
  }
  static Future mute_all(bool mute_all) async {
    await _preferences.setBool("mute_all", mute_all);
  }
  static Future setNotification_uri(String notification_uri) async {
    await _preferences.setString("notification_uri", notification_uri);
  }
  static Future setNotificationSound(bool sound) async {
    await _preferences.setBool(Constants.PACKAGE+"notification_sound", sound);
  }
  static Future setKeyChangeFlag(bool change) async {
    await _preferences.setBool(Constants.PACKAGE+"change.flag", change);
  }
  static Future setNotificationPopup(bool popup) async {
    await _preferences.setBool(Constants.PACKAGE+"notification_popup", popup);
  }
  static Future setNotificationVibration(bool vibration) async {
    await _preferences.setBool(Constants.PACKAGE+"vibration", vibration);
  }
  static Future setMuteNotification(bool mute) async {
    await _preferences.setBool("mute_notification", mute);
  }
  static Future setWebChatLogin(bool web_chat_login) async {
    await _preferences.setBool("web_chat_login", web_chat_login);
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
  String? getNotification_uri() => _preferences.getString("notification_uri");
  bool getNotificationSound() => _preferences.getBool(Constants.PACKAGE+"notification_sound") ?? true;
  bool getNotificationPopup() => _preferences.getBool(Constants.PACKAGE+"notification_popup") ?? false;
  bool getVibration() => _preferences.getBool(Constants.PACKAGE+"vibration") ?? false;
  bool getMuteNotification() => _preferences.getBool("mute_notification") ?? false;
  bool? synced() => _preferences.getBool("synced");
}