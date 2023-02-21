import 'package:flysdk/flysdk.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/constants.dart';


class SessionManagement {
  static late SharedPreferences _preferences;

  setDefaultValues(){
    if(_preferences.containsKey("${Constants.package}notification_sound")){

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
  static Future setCountryCode(String countryCode) async {
    await _preferences.setString("country_code", countryCode);
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
    await _preferences.setBool("${Constants.package}notification_sound", sound);
  }
  static Future setKeyChangeFlag(bool change) async {
    await _preferences.setBool("${Constants.package}change.flag", change);
  }
  static Future setNotificationPopup(bool popup) async {
    await _preferences.setBool("${Constants.package}notification_popup", popup);
  }
  static Future setNotificationVibration(bool vibration) async {
    await _preferences.setBool("${Constants.package}vibration", vibration);
  }
  static Future setMuteNotification(bool mute) async {
    await _preferences.setBool("mute_notification", mute);
  }
  static Future setWebChatLogin(bool webChatLogin) async {
    await _preferences.setBool("web_chat_login", webChatLogin);
  }
  static Future setChatJid(String setChatJid) async {
    await _preferences.setString("chatJid", setChatJid);
  }
  static void setAdminBlocked(bool status) async {
    await _preferences.setBool("admin_blocked", status);
  }
  static void setAutoDownloadEnable(bool status) async {
    await _preferences.setBool("MediaAutoDownload", status);
  }
  static void setGoogleTranslationEnable(bool status) async {
    await _preferences.setBool("TranslateLanguageChecked", status);
  }
  static void setGoogleTranslationLanguage(String language) async {
    await _preferences.setString("LanguageName", language);
  }
  static void setGoogleTranslationLanguageCode(String languagecode) async {
    await _preferences.setString("LanguageCode", languagecode);
  }
  static Future clear()async{
    await _preferences.clear();
  }

  static Future setUser(Data data) async {
    await _preferences.setString('token', data.token.checkNull());
    await _preferences.setString('username', data.username.checkNull());
    await _preferences.setString('password', data.password.checkNull());
    /*data.toJson().forEach((key, value) async {
      await _preferences.setString(key, value.toString());
    });
    var userData = jsonEncode(data);
    await _preferences.setString('userData', userData);*/
  }

  static void setCurrentChatJID(String chatJID) async {
    await _preferences.setString("CurrentChatJID", chatJID);
  }

  static Future setCurrentUser(ProData data) async {
    data.toJson().forEach((key, value) async {
      await _preferences.setString(key, value.toString());
    });
  }

  static bool getLogin() => _preferences.getBool("login") ?? false;

  static String? getChatJid() => _preferences.getString("chatJid");
  static String? getCurrentChatJID() => _preferences.getString("CurrentChatJID");
  static String? getName() => _preferences.getString("name");
  static String? getMobileNumber() => _preferences.getString("mobileNumber");
  static String? getCountryCode() => _preferences.getString("country_code") ?? "+91";
  static String? getUsername() => _preferences.getString("username");
  static String? getPassword() => _preferences.getString("password");
  static String? getUserJID() => _preferences.getString("user_jid").toString();
  static String? getUserImage() => _preferences.getString("image");
  static String? getToken() => _preferences.getString("firebase_token");
  static String? getAuthToken() => _preferences.getString("token");
  static String? getMediaEndPoint() => _preferences.getString("media_endpoint");
  static String? getNotificationUri() => _preferences.getString("notification_uri");
  static bool getWebLogin() => _preferences.getBool("web_chat_login") ?? false;
  static bool getNotificationSound() => _preferences.getBool("${Constants.package}notification_sound") ?? true;
  static bool getNotificationPopup() => _preferences.getBool("${Constants.package}notification_popup") ?? false;
  static bool getVibration() => _preferences.getBool("${Constants.package}vibration") ?? false;
  static bool getMuteNotification() => _preferences.getBool("mute_notification") ?? false;
  static String getPin() => _preferences.getString("pin") ?? "";
  static bool getEnablePin() => _preferences.getBool("enable_pin") ?? false;
  static bool getEnableBio() => _preferences.getBool("enable_bio") ?? false;
  static bool? synced() => _preferences.getBool("synced");
  static bool adminBlocked() => _preferences.getBool("admin_blocked") ?? false;
  static bool isGoogleTranslationEnable() => _preferences.getBool("TranslateLanguageChecked") ?? false;
  static bool isAutoDownloadEnable() => _preferences.getBool("MediaAutoDownload") ?? false;
  static String getTranslationLanguage() => _preferences.getString("LanguageName") ?? "English";
  static String getTranslationLanguageCode() => _preferences.getString("LanguageCode") ?? "en";
}