import '../extensions/extensions.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/constants.dart';


class SessionManagement {
  static late SharedPreferences _preferences;
  static const prefix = "mirrorFly_plugin_";
  ///Commenting as this is not used anywhere
  // setDefaultValues(){
  //   if(_preferences.containsKey("${Constants.package}notification_sound")){
  //
  //   }
  // }
  static Future onInit() async {
    _preferences = await SharedPreferences.getInstance();
    /*try {
      _preferences = await SharedPreferences.getInstance();
    }catch(e){
      SharedPreferences.setMockInitialValues({});
      _preferences = await SharedPreferences.getInstance();
    }*/
    SessionManagement.setCurrentChatJID("");
  }

  static Future setLogin(bool val) async {
    await _preferences.setBool("${prefix}login", val);
  }


  static setIsTrailLicence(bool trail) async {
    await _preferences.setBool("${prefix}IS_TRIAL_LICENSE", trail);
  }
  static Future setInitialContactSync(bool val) async {
    await _preferences.setBool("${prefix}is_initial_contact_sync_done", val);
  }
  static Future setSyncDone(bool val) async {
    await _preferences.setBool("${prefix}is_contact_sync_done", val);
  }

  static Future setMediaEndPoint(String mediaEndpoint) async {
    await _preferences.setString("${prefix}media_endpoint", mediaEndpoint);
  }
  static Future setAuthToken(String authToken) async {
    await _preferences.setString("${prefix}token", authToken);
  }
  static Future setToken(String firebaseToken) async {
    await _preferences.setString("${prefix}firebase_token", firebaseToken);
  }
  ///Commenting as this is not used anywhere
  // static Future setMobile(String mobile) async {
  //   await _preferences.setString("${prefix}mobile", mobile);
  // }
  static Future setCountryCode(String countryCode) async {
    await _preferences.setString("${prefix}country_code", countryCode);
  }
  static Future setUserJID(String jid) async {
    await _preferences.setString("${prefix}user_jid", jid);
  }
  static Future setUserIdentifier(String userIdentifier) async {
    await _preferences.setString("${prefix}userIdentifier", userIdentifier);
  }
  static Future setUserImage(String image) async {
    await _preferences.setString("${prefix}image", image);
  }
  static Future setPIN(String pin) async {
    await _preferences.setString("${prefix}pin", pin);
    await _preferences.setInt(Constants.changedPinAt, DateTime.now().millisecondsSinceEpoch);
  }
  static Future setChangePinNext(String pin) async {
    await _preferences.setString("${prefix}change_pin_next", pin);
  }
  static Future setEnablePIN(bool pin) async {
    await _preferences.setBool("${prefix}enable_pin", pin);
  }
  static Future setEnableBio(bool bio) async {
    await _preferences.setBool("${prefix}enable_bio", bio);
  }
  static Future convSound(bool convSound) async {
    await _preferences.setBool("${prefix}conv_sound", convSound);
  }
  static Future vibrationType(String vibrationType) async {
    await _preferences.setString("${prefix}vibration_type", vibrationType);
  }
  static Future muteAll(bool muteAll) async {
    await _preferences.setBool("${prefix}mute_all", muteAll);
  }
  static Future setNotificationUri(String notificationUri) async {
    await _preferences.setString("${prefix}notification_uri", notificationUri);
  }
  static Future setSummaryChannelId(String summaryChannelId) async {
    await _preferences.setString("$prefix${Constants.packageName}summary_channel.id", summaryChannelId);
  }
  static Future setNotificationSound(bool sound) async {
    await _preferences.setBool("$prefix${Constants.package}notification_sound", sound);
  }
  static Future setKeyChangeFlag(bool change) async {
    await _preferences.setBool("$prefix${Constants.package}change.flag", change);
  }
  static Future setNotificationPopup(bool popup) async {
    await _preferences.setBool("$prefix${Constants.package}notification_popup", popup);
  }
  static Future setNotificationVibration(bool vibration) async {
    await _preferences.setBool("$prefix${Constants.package}vibration", vibration);
  }
  static Future setMuteNotification(bool mute) async {
    await _preferences.setBool("${prefix}mute_notification", mute);
  }
  static Future setWebChatLogin(bool webChatLogin) async {
    await _preferences.setBool("${prefix}web_chat_login", webChatLogin);
  }

  static void setAdminBlocked(bool status) async {
    await _preferences.setBool("${prefix}admin_blocked", status);
  }
  static void setAutoDownloadEnable(bool status) async {
    await _preferences.setBool("${prefix}MediaAutoDownload", status);
  }
  static void setGoogleTranslationEnable(bool status) async {
    await _preferences.setBool("${prefix}TranslateLanguageChecked", status);
  }
  static void setGoogleTranslationLanguage(String language) async {
    await _preferences.setString("${prefix}LanguageName", language);
  }
  static void setGoogleTranslationLanguageCode(String languageCode) async {
    await _preferences.setString("${prefix}LanguageCode", languageCode);
  }
  static void setAppSessionNow() async {
    await _preferences.setInt("$prefix${Constants.appSession}", DateTime.now().millisecondsSinceEpoch);
  }
  static void setLockExpiry(int expiryTimeStamp) async {
    await _preferences.setInt("$prefix${Constants.expiryDate}", expiryTimeStamp);
  }
  static void setLockAlert(int alertTimeStamp) async {
    await _preferences.setInt("$prefix${Constants.alertDate}", alertTimeStamp);
  }
  static void setDontShowAlert() async {
    await _preferences.setBool('${prefix}show_alert', false);
  }

  static Future clear()async{
    // await _preferences.clear();
    final keys = _preferences.getKeys();
    for (String key in keys) {
      if (key.startsWith(prefix)) {
        // Remove the key-value pair with the specified prefix
        await _preferences.remove(key);
      }
    }
  }

  static Future setUser(Data data) async {
    await _preferences.setString('${prefix}token', data.token.checkNull());
    await _preferences.setString('${prefix}username', data.username.checkNull());
    await _preferences.setString('${prefix}password', data.password.checkNull());
    /*data.toJson().forEach((key, value) async {
      await _preferences.setString(key, value.toString());
    });
    var userData = jsonEncode(data);
    await _preferences.setString('userData', userData);*/
  }

  static void setCurrentChatJID(String chatJID) async {
    await _preferences.setString("${prefix}CurrentChatJID", chatJID);
  }

  static Future setCurrentUser(ProData data) async {
    data.toJson().forEach((key, value) async {
      await _preferences.setString("$prefix$key", value.toString());
    });
  }

  static Future setBool(String key, bool value) async => await _preferences.setBool("$prefix$key",value);
  static Future setString(String key,String value) async => await _preferences.setString("$prefix$key",value);

  static bool getBool(String key) => _preferences.getBool("$prefix$key") ?? false;
  static String getString(String key) => _preferences.getString("$prefix$key") ?? "";

  static bool getLogin() => _preferences.getBool("${prefix}login") ?? false;
  static String getUserIdentifier() => _preferences.getString("${prefix}userIdentifier") ?? "";
  static String getCurrentChatJID() => _preferences.getString("${prefix}CurrentChatJID") ?? "";
  static String? getName() => _preferences.getString("${prefix}name");
  static String? getMobileNumber() => _preferences.getString("${prefix}mobileNumber");
  static String? getCountryCode() => _preferences.getString("${prefix}country_code") ?? "+91";
  static String? getUsername() => _preferences.getString("${prefix}username");
  static String? getPassword() => _preferences.getString("${prefix}password");
  static String? getUserJID() => _preferences.getString("${prefix}user_jid").toString();
  static String? getUserImage() => _preferences.getString("${prefix}image");
  static String? getToken() => _preferences.getString("${prefix}firebase_token");
  static String? getAuthToken() => _preferences.getString("${prefix}token");
  static String? getMediaEndPoint() => _preferences.getString("${prefix}media_endpoint");
  static String? getNotificationUri() => _preferences.getString("${prefix}notification_uri");
  static String? getSummaryChannelId() => _preferences.getString("$prefix${Constants.packageName}summary_channel.id");
  static bool getWebLogin() => _preferences.getBool("${prefix}web_chat_login") ?? false;
  static bool getNotificationSound() => _preferences.getBool("$prefix${Constants.package}notification_sound") ?? true;
  static bool getNotificationPopup() => _preferences.getBool("$prefix${Constants.package}notification_popup") ?? false;
  static bool getVibration() => _preferences.getBool("$prefix${Constants.package}vibration") ?? false;
  static bool getMuteNotification() => _preferences.getBool("${prefix}mute_notification") ?? false;
  static String getPin() => _preferences.getString("${prefix}pin") ?? "";
  static String getChangePinNext() => _preferences.getString("${prefix}change_pin_next") ?? "";
  static bool getEnablePin() => _preferences.getBool("${prefix}enable_pin") ?? false;
  static bool getEnableBio() => _preferences.getBool("${prefix}enable_bio") ?? false;
  static bool? synced() => _preferences.getBool("${prefix}synced");
  static bool adminBlocked() => _preferences.getBool("${prefix}admin_blocked") ?? false;
  static bool isGoogleTranslationEnable() => _preferences.getBool("${prefix}TranslateLanguageChecked") ?? false;
  static bool isAutoDownloadEnable() => _preferences.getBool("${prefix}MediaAutoDownload") ?? false;
  static String getTranslationLanguage() => _preferences.getString("${prefix}LanguageName") ?? "English";
  static String getTranslationLanguageCode() => _preferences.getString("${prefix}LanguageCode") ?? "en";
  static bool isInitialContactSyncDone() => _preferences.getBool("${prefix}is_initial_contact_sync_done") ?? false;
  static bool isContactSyncDone() => _preferences.getBool("${prefix}is_contact_sync_done") ?? false;
  static bool isTrailLicence() => _preferences.getBool("${prefix}IS_TRIAL_LICENSE") ?? true;
  static int appLastSession() => _preferences.getInt("$prefix${Constants.appSession}") ?? DateTime.now().millisecondsSinceEpoch;
  static int lastPinChangedAt() => _preferences.getInt("$prefix${Constants.changedPinAt}") ?? DateTime.now().millisecondsSinceEpoch;
  static bool showAlert() => _preferences.getBool('${prefix}show_alert') ?? true;
  // static String getTopicId() =>  Constants.enableTopic ? Constants.topicId/*_preferences.getString('${prefix}topicId')*/ ?? ("5d3788c1-78ef-4158-a92b-a48f092da0b9") : "";
}