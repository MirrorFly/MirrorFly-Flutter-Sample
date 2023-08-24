import 'package:mirrorfly_plugin/mirrorfly.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/constants.dart';


class SessionManagement {
  static late SharedPreferences _preferences;
  ///Commenting as this is not used anywhere
  // setDefaultValues(){
  //   if(_preferences.containsKey("${Constants.package}notification_sound")){
  //
  //   }
  // }
  static Future onInit() async {
    try {
      _preferences = await SharedPreferences.getInstance();
    }catch(e){
      SharedPreferences.setMockInitialValues({});
      _preferences = await SharedPreferences.getInstance();
    }
    SessionManagement.setCurrentChatJID("");
  }

  static Future setLogin(bool val) async {
    await _preferences.setBool("mirrorFly_plugin_login", val);
  }


  static setIsTrailLicence(bool trail) async {
    await _preferences.setBool("mirrorFly_plugin_IS_TRIAL_LICENSE", trail);
  }
  static Future setInitialContactSync(bool val) async {
    await _preferences.setBool("mirrorFly_plugin_is_initial_contact_sync_done", val);
  }
  static Future setSyncDone(bool val) async {
    await _preferences.setBool("mirrorFly_plugin_is_contact_sync_done", val);
  }

  static Future setMediaEndPoint(String mediaEndpoint) async {
    await _preferences.setString("mirrorFly_plugin_media_endpoint", mediaEndpoint);
  }
  static Future setAuthToken(String authToken) async {
    await _preferences.setString("mirrorFly_plugin_token", authToken);
  }
  static Future setToken(String firebaseToken) async {
    await _preferences.setString("mirrorFly_plugin_firebase_token", firebaseToken);
  }
  ///Commenting as this is not used anywhere
  // static Future setMobile(String mobile) async {
  //   await _preferences.setString("mirrorFly_plugin_mobile", mobile);
  // }
  static Future setCountryCode(String countryCode) async {
    await _preferences.setString("mirrorFly_plugin_country_code", countryCode);
  }
  static Future setUserJID(String jid) async {
    await _preferences.setString("mirrorFly_plugin_user_jid", jid);
  }
  static Future setUserIdentifier(String userIdentifier) async {
    await _preferences.setString("mirrorFly_plugin_userIdentifier", userIdentifier);
  }
  static Future setUserImage(String image) async {
    await _preferences.setString("mirrorFly_plugin_image", image);
  }
  static Future setPIN(String pin) async {
    await _preferences.setString("mirrorFly_plugin_pin", pin);
    await _preferences.setInt(Constants.changedPinAt, DateTime.now().millisecondsSinceEpoch);
  }
  static Future setChangePinNext(String pin) async {
    await _preferences.setString("mirrorFly_plugin_change_pin_next", pin);
  }
  static Future setEnablePIN(bool pin) async {
    await _preferences.setBool("mirrorFly_plugin_enable_pin", pin);
  }
  static Future setEnableBio(bool bio) async {
    await _preferences.setBool("mirrorFly_plugin_enable_bio", bio);
  }
  static Future convSound(bool convSound) async {
    await _preferences.setBool("mirrorFly_plugin_conv_sound", convSound);
  }
  static Future vibrationType(String vibrationType) async {
    await _preferences.setString("mirrorFly_plugin_vibration_type", vibrationType);
  }
  static Future muteAll(bool muteAll) async {
    await _preferences.setBool("mirrorFly_plugin_mute_all", muteAll);
  }
  static Future setNotificationUri(String notificationUri) async {
    await _preferences.setString("mirrorFly_plugin_notification_uri", notificationUri);
  }
  static Future setSummaryChannelId(String summaryChannelId) async {
    await _preferences.setString("mirrorFly_plugin_${Constants.packageName}summary_channel.id", summaryChannelId);
  }
  static Future setNotificationSound(bool sound) async {
    await _preferences.setBool("mirrorFly_plugin_${Constants.package}notification_sound", sound);
  }
  static Future setKeyChangeFlag(bool change) async {
    await _preferences.setBool("mirrorFly_plugin_${Constants.package}change.flag", change);
  }
  static Future setNotificationPopup(bool popup) async {
    await _preferences.setBool("mirrorFly_plugin_${Constants.package}notification_popup", popup);
  }
  static Future setNotificationVibration(bool vibration) async {
    await _preferences.setBool("mirrorFly_plugin_${Constants.package}vibration", vibration);
  }
  static Future setMuteNotification(bool mute) async {
    await _preferences.setBool("mirrorFly_plugin_mute_notification", mute);
  }
  static Future setWebChatLogin(bool webChatLogin) async {
    await _preferences.setBool("mirrorFly_plugin_web_chat_login", webChatLogin);
  }
  static Future setChatJid(String setChatJid) async {
    await _preferences.setString("mirrorFly_plugin_chatJid", setChatJid);
  }
  static void setAdminBlocked(bool status) async {
    await _preferences.setBool("mirrorFly_plugin_admin_blocked", status);
  }
  static void setAutoDownloadEnable(bool status) async {
    await _preferences.setBool("mirrorFly_plugin_MediaAutoDownload", status);
  }
  static void setGoogleTranslationEnable(bool status) async {
    await _preferences.setBool("mirrorFly_plugin_TranslateLanguageChecked", status);
  }
  static void setGoogleTranslationLanguage(String language) async {
    await _preferences.setString("mirrorFly_plugin_LanguageName", language);
  }
  static void setGoogleTranslationLanguageCode(String languageCode) async {
    await _preferences.setString("mirrorFly_plugin_LanguageCode", languageCode);
  }
  static void setAppSessionNow() async {
    await _preferences.setInt("mirrorFly_plugin_${Constants.appSession}", DateTime.now().millisecondsSinceEpoch);
  }
  static void setLockExpiry(int expiryTimeStamp) async {
    await _preferences.setInt("mirrorFly_plugin_${Constants.expiryDate}", expiryTimeStamp);
  }
  static void setLockAlert(int alertTimeStamp) async {
    await _preferences.setInt("mirrorFly_plugin_${Constants.alertDate}", alertTimeStamp);
  }
  static void setDontShowAlert() async {
    await _preferences.setBool('mirrorFly_plugin_show_alert', false);
  }

  static Future clear()async{
    // await _preferences.clear();
    final keys = _preferences.getKeys();
    for (String key in keys) {
      if (key.startsWith("mirrorFly_plugin_")) {
        // Remove the key-value pair with the specified prefix
        await _preferences.remove(key);
      }
    }
  }

  static Future setUser(Data data) async {
    await _preferences.setString('mirrorFly_plugin_token', data.token.checkNull());
    await _preferences.setString('mirrorFly_plugin_username', data.username.checkNull());
    await _preferences.setString('mirrorFly_plugin_password', data.password.checkNull());
    /*data.toJson().forEach((key, value) async {
      await _preferences.setString(key, value.toString());
    });
    var userData = jsonEncode(data);
    await _preferences.setString('userData', userData);*/
  }

  static void setCurrentChatJID(String chatJID) async {
    await _preferences.setString("mirrorFly_plugin_CurrentChatJID", chatJID);
  }

  static Future setCurrentUser(ProData data) async {
    data.toJson().forEach((key, value) async {
      await _preferences.setString("mirrorFly_plugin_$key", value.toString());
    });
  }

  static Future setBool(String key, bool value) async => await _preferences.setBool("mirrorFly_plugin_$key",value);
  static Future setString(String key,String value) async => await _preferences.setString("mirrorFly_plugin_$key",value);

  static bool getBool(String key) => _preferences.getBool("mirrorFly_plugin_$key") ?? false;
  static String getString(String key) => _preferences.getString("mirrorFly_plugin_$key") ?? "";

  static bool getLogin() => _preferences.getBool("mirrorFly_plugin_login") ?? false;

  static String getUserIdentifier() => _preferences.getString("mirrorFly_plugin_userIdentifier") ?? "";
  static String? getChatJid() => _preferences.getString("mirrorFly_plugin_chatJid");
  static String getCurrentChatJID() => _preferences.getString("mirrorFly_plugin_CurrentChatJID") ?? "";
  static String? getName() => _preferences.getString("mirrorFly_plugin_name");
  static String? getMobileNumber() => _preferences.getString("mirrorFly_plugin_mobileNumber");
  static String? getCountryCode() => _preferences.getString("mirrorFly_plugin_country_code") ?? "+91";
  static String? getUsername() => _preferences.getString("mirrorFly_plugin_username");
  static String? getPassword() => _preferences.getString("mirrorFly_plugin_password");
  static String? getUserJID() => _preferences.getString("mirrorFly_plugin_user_jid").toString();
  static String? getUserImage() => _preferences.getString("mirrorFly_plugin_image");
  static String? getToken() => _preferences.getString("mirrorFly_plugin_firebase_token");
  static String? getAuthToken() => _preferences.getString("mirrorFly_plugin_token");
  static String? getMediaEndPoint() => _preferences.getString("mirrorFly_plugin_media_endpoint");
  static String? getNotificationUri() => _preferences.getString("mirrorFly_plugin_notification_uri");
  static String? getSummaryChannelId() => _preferences.getString("mirrorFly_plugin_${Constants.packageName}summary_channel.id");
  static bool getWebLogin() => _preferences.getBool("mirrorFly_plugin_web_chat_login") ?? false;
  static bool getNotificationSound() => _preferences.getBool("mirrorFly_plugin_${Constants.package}notification_sound") ?? true;
  static bool getNotificationPopup() => _preferences.getBool("mirrorFly_plugin_${Constants.package}notification_popup") ?? false;
  static bool getVibration() => _preferences.getBool("mirrorFly_plugin_${Constants.package}vibration") ?? false;
  static bool getMuteNotification() => _preferences.getBool("mirrorFly_plugin_mute_notification") ?? false;
  static String getPin() => _preferences.getString("mirrorFly_plugin_pin") ?? "";
  static String getChangePinNext() => _preferences.getString("mirrorFly_plugin_change_pin_next") ?? "";
  static bool getEnablePin() => _preferences.getBool("mirrorFly_plugin_enable_pin") ?? false;
  static bool getEnableBio() => _preferences.getBool("mirrorFly_plugin_enable_bio") ?? false;
  static bool? synced() => _preferences.getBool("mirrorFly_plugin_synced");
  static bool adminBlocked() => _preferences.getBool("mirrorFly_plugin_admin_blocked") ?? false;
  static bool isGoogleTranslationEnable() => _preferences.getBool("mirrorFly_plugin_TranslateLanguageChecked") ?? false;
  static bool isAutoDownloadEnable() => _preferences.getBool("mirrorFly_plugin_MediaAutoDownload") ?? false;
  static String getTranslationLanguage() => _preferences.getString("mirrorFly_plugin_LanguageName") ?? "English";
  static String getTranslationLanguageCode() => _preferences.getString("mirrorFly_plugin_LanguageCode") ?? "en";
  static bool isInitialContactSyncDone() => _preferences.getBool("mirrorFly_plugin_is_initial_contact_sync_done") ?? false;
  static bool isContactSyncDone() => _preferences.getBool("mirrorFly_plugin_is_contact_sync_done") ?? false;
  static bool isTrailLicence() => _preferences.getBool("mirrorFly_plugin_IS_TRIAL_LICENSE") ?? true;
  static int appLastSession() => _preferences.getInt("mirrorFly_plugin_${Constants.appSession}") ?? DateTime.now().millisecondsSinceEpoch;
  static int lastPinChangedAt() => _preferences.getInt("mirrorFly_plugin_${Constants.changedPinAt}") ?? DateTime.now().millisecondsSinceEpoch;
  static bool showAlert() => _preferences.getBool('mirrorFly_plugin_show_alert') ?? true;
}