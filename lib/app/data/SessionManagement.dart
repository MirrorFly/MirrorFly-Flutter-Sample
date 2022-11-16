
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/model/registerModel.dart' as register;
import 'package:shared_preferences/shared_preferences.dart';

import '../common/constants.dart';
import '../model/profile_update.dart';


class SessionManagement {
  static late SharedPreferences _preferences;

  setDefaultValues(){
    if(_preferences.containsKey("${Constants.PACKAGE}notification_sound")){

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

  static Future setMediaEndPoint(String mediaEndpoint) async {
    await _preferences.setString("media_endpoint", mediaEndpoint);
  }
  static Future setAuthToken(String authToken) async {
    await _preferences.setString("token", authToken);
  }
  static Future setToken(String firebaseToken) async {
    await _preferences.setString("firebase_token", firebaseToken);
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
  static Future setPIN(String pin) async {
    await _preferences.setString("pin", pin);
  }
  static Future setEnablePIN(bool pin) async {
    await _preferences.setBool("enable_pin", pin);
  }
  static Future setEnableBio(bool bio) async {
    await _preferences.setBool("enable_bio", bio);
  }
  static Future convSound(bool convSound) async {
    await _preferences.setBool("conv_sound", convSound);
  }
  static Future vibrationType(String vibrationType) async {
    await _preferences.setString("vibration_type", vibrationType);
  }
  static Future muteAll(bool muteAll) async {
    await _preferences.setBool("mute_all", muteAll);
  }
  static Future setNotificationUri(String notificationUri) async {
    await _preferences.setString("notification_uri", notificationUri);
  }
  static Future setNotificationSound(bool sound) async {
    await _preferences.setBool("${Constants.PACKAGE}notification_sound", sound);
  }
  static Future setKeyChangeFlag(bool change) async {
    await _preferences.setBool("${Constants.PACKAGE}change.flag", change);
  }
  static Future setNotificationPopup(bool popup) async {
    await _preferences.setBool("${Constants.PACKAGE}notification_popup", popup);
  }
  static Future setNotificationVibration(bool vibration) async {
    await _preferences.setBool("${Constants.PACKAGE}vibration", vibration);
  }
  static Future setMuteNotification(bool mute) async {
    await _preferences.setBool("mute_notification", mute);
  }
  static Future setWebChatLogin(bool webChatLogin) async {
    await _preferences.setBool("web_chat_login", webChatLogin);
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
  String? getAuthToken() => _preferences.getString("token");
  String? getMediaEndPoint() => _preferences.getString("media_endpoint");
  String? getNotificationUri() => _preferences.getString("notification_uri");
  bool getWebLogin() => _preferences.getBool("web_chat_login") ?? false;
  bool getNotificationSound() => _preferences.getBool("${Constants.PACKAGE}notification_sound") ?? true;
  bool getNotificationPopup() => _preferences.getBool("${Constants.PACKAGE}notification_popup") ?? false;
  bool getVibration() => _preferences.getBool("${Constants.PACKAGE}vibration") ?? false;
  bool getMuteNotification() => _preferences.getBool("mute_notification") ?? false;
  String getPin() => _preferences.getString("pin") ?? "";
  bool getEnablePin() => _preferences.getBool("enable_pin") ?? false;
  bool getEnableBio() => _preferences.getBool("enable_bio") ?? false;
  bool? synced() => _preferences.getBool("synced");
}