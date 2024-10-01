import 'package:get/get.dart';
import '../../../../data/session_management.dart';

class NotificationAlertController extends FullLifeCycleController
with FullLifeCycleMixin {
  final _defaultTone = ''.obs;

  set defaultTone(value) => _defaultTone.value = value;

  get defaultTone => _defaultTone.value;

  final _displayNotificationSoundPreference = false.obs;

  set displayNotificationSoundPreference(value) =>
      _displayNotificationSoundPreference.value = value;

  bool get displayNotificationSoundPreference =>
      _displayNotificationSoundPreference.value;

  final _displayNotificationPopupPreference = false.obs;

  set displayNotificationPopupPreference(value) =>
      _displayNotificationPopupPreference.value = value;

  bool get displayNotificationPopupPreference =>
      _displayNotificationPopupPreference.value;

  final _displayVibrationPreference = false.obs;

  set displayVibrationPreference(value) =>
      _displayVibrationPreference.value = value;

  bool get displayVibrationPreference => _displayVibrationPreference.value;

  final _displayMuteNotificationPreference = false.obs;

  set displayMuteNotificationPreference(value) =>
      _displayMuteNotificationPreference.value = value;

  bool get displayMuteNotificationPreference =>
      _displayMuteNotificationPreference.value;

  @override
  void onInit() {
    super.onInit();
    getRingtoneName();
    _displayNotificationSoundPreference(
        SessionManagement.getNotificationSound());
    _displayNotificationPopupPreference(
        SessionManagement.getNotificationPopup());
    _displayVibrationPreference(SessionManagement.getVibration());
    displayMutePreference();
  }


  showCustomTones() {
    // var uri = SessionManagement.getNotificationUri();
    /*Mirrorfly.showCustomTones().then((value) {
      if (value != null) {
        debugPrint("Custom tone set --> $value");
        // Mirrorfly.setNotificationUri(value);
        SessionManagement.setNotificationUri(value)
            .then((value) => getRingtoneName());
      }
    });*/
  }

  getRingtoneName() {
    // var uri = SessionManagement.getNotificationUri();
    // LogMessage.d("uri", uri.toString());
    /*Mirrorfly.getRingtoneName().then((value) {
      var jsonNotification = json.decode(value!);
      if (jsonNotification != null) {
        var notificationName = jsonNotification["name"];
        var notificationURI = jsonNotification["tone_uri"];
        debugPrint("notificationName--> $notificationName");
        debugPrint("notificationURI--> $notificationURI");
        _defaultTone(notificationName);
        SessionManagement.setNotificationUri(notificationURI);
      }
    });*/
  }

  displayMutePreference() {
    _displayMuteNotificationPreference(SessionManagement.getMuteNotification());
    if (SessionManagement.getMuteNotification()) {
      _displayVibrationPreference(false);
      _displayNotificationPopupPreference(false);
      _displayNotificationSoundPreference(false);
    }
  }

  notificationSound(){
    SessionManagement.setNotificationSound(!displayNotificationSoundPreference);
    // Mirrorfly.setNotificationSound(!displayNotificationSoundPreference);
    SessionManagement.setKeyChangeFlag(true);
    _displayNotificationSoundPreference(!displayNotificationSoundPreference);
    checkWhetherMuteEnabled();
  }
  notificationPopup(){
    checkWhetherMuteEnabled();
    SessionManagement.setNotificationPopup(!displayNotificationPopupPreference);
    _displayNotificationPopupPreference(!displayNotificationPopupPreference);
  }
  vibration(){
    checkWhetherMuteEnabled();
    SessionManagement.setNotificationVibration(!displayVibrationPreference);
    // Mirrorfly.setNotificationVibration(!displayVibrationPreference);
    SessionManagement.setKeyChangeFlag(true);
    _displayVibrationPreference(!displayVibrationPreference);
  }
  mute(){
    if(!SessionManagement.getMuteNotification()){
      unSetAlerts();
    }else{
      enableNotification();
    }
    SessionManagement.setMuteNotification(!displayMuteNotificationPreference);
    // Mirrorfly.setMuteNotification(!displayMuteNotificationPreference);
    SessionManagement.setKeyChangeFlag(true);
    _displayMuteNotificationPreference(!displayMuteNotificationPreference);
  }
  unSetAlerts(){
    SessionManagement.setNotificationSound(false);
    // Mirrorfly.setNotificationSound(false);
    SessionManagement.setNotificationPopup(false);
    SessionManagement.setNotificationPopup(false);
    SessionManagement.setNotificationVibration(false);
    // Mirrorfly.setNotificationVibration(false);
    _displayNotificationSoundPreference(false);
    _displayNotificationPopupPreference(false);
    _displayVibrationPreference(false);
  }
  enableNotification(){
    SessionManagement.setNotificationSound(true);
    // Mirrorfly.setNotificationSound(true);
    SessionManagement.setNotificationPopup(true);
    _displayNotificationSoundPreference(true);
    _displayNotificationPopupPreference(true);
  }

  checkWhetherMuteEnabled() {
    if (SessionManagement.getMuteNotification()) {
      SessionManagement.setNotificationSound(true);
      // Mirrorfly.setNotificationSound(true);
      SessionManagement.setMuteNotification(false);
      // Mirrorfly.setMuteNotification(false);
      _displayMuteNotificationPreference(false);
      _displayNotificationSoundPreference(true);
    }
  }

  @override
  void onDetached() {

  }

  @override
  void onInactive() {

  }

  @override
  void onPaused() {

  }

  @override
  void onResumed() {
    getRingtoneName();
    // Mirrorfly.setNotificationUri(value);
    // SessionManagement.setNotificationUri(value)
    //     .then((value) => getRingtoneName());
  }

  @override
  void onHidden() {

  }
}
