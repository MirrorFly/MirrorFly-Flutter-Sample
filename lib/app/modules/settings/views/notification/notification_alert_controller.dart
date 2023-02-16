import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/data/session_management.dart';
import 'package:flysdk/flysdk.dart';

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
    FlyChat.showCustomTones().then((value) {
      if (value != null) {
        debugPrint("Custom tone set --> $value");
        // FlyChat.setNotificationUri(value);
        SessionManagement.setNotificationUri(value)
            .then((value) => getRingtoneName());
      }
    });
  }

  getRingtoneName() {
    // var uri = SessionManagement.getNotificationUri();
    // mirrorFlyLog("uri", uri.toString());
    FlyChat.getRingtoneName().then((value) {
      if (value != null) {
        _defaultTone(value);
      }
    });
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
    FlyChat.setNotificationSound(!displayNotificationSoundPreference);
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
    FlyChat.setNotificationVibration(!displayVibrationPreference);
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
    FlyChat.setMuteNotification(!displayMuteNotificationPreference);
    SessionManagement.setKeyChangeFlag(true);
    _displayMuteNotificationPreference(!displayMuteNotificationPreference);
  }
  unSetAlerts(){
    SessionManagement.setNotificationSound(false);
    FlyChat.setNotificationSound(false);
    SessionManagement.setNotificationPopup(false);
    SessionManagement.setNotificationPopup(false);
    SessionManagement.setNotificationVibration(false);
    FlyChat.setNotificationVibration(false);
    _displayNotificationSoundPreference(false);
    _displayNotificationPopupPreference(false);
    _displayVibrationPreference(false);
  }
  enableNotification(){
    SessionManagement.setNotificationSound(true);
    FlyChat.setNotificationSound(true);
    SessionManagement.setNotificationPopup(true);
    _displayNotificationSoundPreference(true);
    _displayNotificationPopupPreference(true);
  }

  checkWhetherMuteEnabled() {
    if (SessionManagement.getMuteNotification()) {
      SessionManagement.setNotificationSound(true);
      FlyChat.setNotificationSound(true);
      SessionManagement.setMuteNotification(false);
      FlyChat.setMuteNotification(false);
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
    // FlyChat.setNotificationUri(value);
    // SessionManagement.setNotificationUri(value)
    //     .then((value) => getRingtoneName());
  }
}
