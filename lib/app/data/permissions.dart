import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import '../common/app_localizations.dart';
import '../common/constants.dart';
import '../data/session_management.dart';
import '../data/utils.dart';
import '../extensions/extensions.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';
import 'package:permission_handler/permission_handler.dart';

import '../app_style_config.dart';
import '../stylesheet/stylesheet.dart';

class AppPermission {
  AppPermission._();

  static Future<bool> getStoragePermission({String? permissionContent, String? deniedContent}) async {
    var sdkVersion = 0;
    if (Platform.isAndroid) {
      var sdk = await DeviceInfoPlugin().androidInfo;
      sdkVersion = sdk.version.sdkInt;
    } else {
      sdkVersion = 0;
    }
    if (sdkVersion < 33 && Platform.isAndroid) {
      final permission = await Permission.storage.status;
      if (permission != PermissionStatus.granted &&
          permission != PermissionStatus.permanentlyDenied) {
        const newPermission = Permission.storage;
        var deniedPopupValue = await mirrorFlyPermissionDialog(
            icon: filePermission, content: permissionContent ?? getTranslated("filePermissionContent"),dialogStyle: AppStyleConfig.dialogStyle);
        if (deniedPopupValue) {
          var newp = await newPermission.request();
          if (newp.isGranted) {
            return true;
          } else {
            var popupValue = await customPermissionDialog(
                icon: filePermission,
                content: deniedContent ?? getPermissionAlertMessage("storage"),dialogStyle: AppStyleConfig.dialogStyle);
            if (popupValue) {
              openAppSettings();
              return false;
            } else {
              return false;
            }
          }
        } else {
          return newPermission.status.isGranted;
        }
      } else {
        return permission.isGranted;
      }
    } else if (Platform.isIOS) {
      final photos = await Permission.photos.status;
      final storage = await Permission.storage.status;

      const newPermission = [
        Permission.photos,
        Permission.storage,
        // Permission.audio
      ];
      if ((photos != PermissionStatus.granted &&
              photos != PermissionStatus.permanentlyDenied) ||
          (storage != PermissionStatus.granted &&
              storage != PermissionStatus.permanentlyDenied)) {
        LogMessage.d("showing mirrorfly popup", "");
        var deniedPopupValue = await mirrorFlyPermissionDialog(
            icon: filePermission, content: permissionContent ?? getTranslated("filePermissionContent"),dialogStyle: AppStyleConfig.dialogStyle);
        if (deniedPopupValue) {
          var newp = await newPermission.request();
          PermissionStatus? photo = newp[Permission.photos];
          PermissionStatus? storage = newp[Permission.storage];
          // var audio = await newPermission[2].isGranted;
          if (photo!.isGranted && storage!.isGranted) {
            return true;
          } else if (photo.isPermanentlyDenied ||
              storage!.isPermanentlyDenied) {
            var popupValue = await customPermissionDialog(
                icon: filePermission,
                content: deniedContent ?? getPermissionAlertMessage("storage"),dialogStyle: AppStyleConfig.dialogStyle);
            if (popupValue) {
              openAppSettings();
              return false;
            } else {
              return false;
            }
          } else {
            return false;
          }
        } else {
          return false; //PermissionStatus.denied;
        }
      } else {
        LogMessage.d("showing mirrorfly popup",
            "${photos.isGranted} ${storage.isGranted}");
        return (photos.isGranted && storage.isGranted);
        // ? photos
        // : photos;
      }
    } else {
      return getAndroid13Permission();
    }
  }

  static Future<bool> getAndroid13Permission() async {
    final photos = await Permission.photos.status;
    final videos = await Permission.videos.status;
    final mediaLibrary = await Permission.mediaLibrary.status;
    // final audio = await Permission.audio.status;
    const newPermission = [
      Permission.photos,
      Permission.videos,
      Permission.mediaLibrary,
      // Permission.audio
    ];
    if ((photos != PermissionStatus.granted &&
            photos != PermissionStatus.permanentlyDenied) ||
        (videos != PermissionStatus.granted &&
            videos != PermissionStatus.permanentlyDenied) ||
        (mediaLibrary != PermissionStatus.granted &&
            mediaLibrary != PermissionStatus.permanentlyDenied)) {
      LogMessage.d("showing mirrorfly popup", "");
      var deniedPopupValue = await mirrorFlyPermissionDialog(
          icon: filePermission, content: getTranslated("filePermissionContent"),dialogStyle: AppStyleConfig.dialogStyle);
      if (deniedPopupValue) {
        var newp = await newPermission.request();
        PermissionStatus? photo = newp[Permission.photos];
        PermissionStatus? video = newp[Permission.videos];
        PermissionStatus? mediaLibrary = newp[Permission.mediaLibrary];
        // var audio = await newPermission[2].isGranted;
        if (photo!.isGranted && video!.isGranted && mediaLibrary!.isGranted) {
          return true;
        } else if (photo.isPermanentlyDenied ||
            video!.isPermanentlyDenied ||
            mediaLibrary!.isPermanentlyDenied) {
          var popupValue = await customPermissionDialog(
              icon: filePermission,
              content: getPermissionAlertMessage("storage"),dialogStyle: AppStyleConfig.dialogStyle);
          if (popupValue) {
            openAppSettings();
            return false;
          } else {
            return false;
          }
        } else {
          return false;
        }
      } else {
        return false; //PermissionStatus.denied;
      }
    } else {
      LogMessage.d("showing mirrorfly popup",
          "${photos.isGranted} ${videos.isGranted} ${mediaLibrary.isGranted}");
      return (photos.isGranted && videos.isGranted && mediaLibrary.isGranted);
      // ? photos
      // : photos;
    }
  }

  static Future<bool> askNotificationPermission() async {
    var permissions = <Permission>[];
    final notification = await Permission.notification.status; //NOTIFICATION
    if (!notification.isGranted ||
        (Platform.isAndroid &&
            await Permission.notification.shouldShowRequestRationale)) {
      permissions.add(Permission.notification);
    }
    LogMessage.d("notification", notification.isGranted);
    if (!notification.isGranted) {
      var shouldShowRequestRationale = (Platform.isAndroid &&
          (await Permission.notification.shouldShowRequestRationale));
      LogMessage.d("shouldShowRequestRationale notification",
          shouldShowRequestRationale);
      LogMessage.d(
          "SessionManagement.getBool(Constants.notificationPermissionAsked) notification",
          (SessionManagement.getBool(Constants.notificationPermissionAsked)));
      var alreadyAsked =
          (SessionManagement.getBool(Constants.notificationPermissionAsked));
      LogMessage.d("alreadyAsked notification", alreadyAsked);
      var dialogContent2 = getTranslated("notificationPermissionMessageContent");
      if (shouldShowRequestRationale) {
        LogMessage.d("shouldShowRequestRationale", shouldShowRequestRationale);
        return requestNotificationPermissions(
            icon: notificationAlertPermission,
            title: getTranslated("notificationPermissionTitle"),
            message: getTranslated("notificationPermissionMessageContent"),
            permissions: permissions,
            showFromRational: true);
      } else if (alreadyAsked) {
        LogMessage.d("alreadyAsked", alreadyAsked);
        var popupValue = await customPermissionDialog(
            icon: notificationAlertPermission,
            content:
                dialogContent2,dialogStyle: AppStyleConfig.dialogStyle); //getPermissionAlertMessage("audio_call"));
        if (popupValue) {
          openAppSettings();
          return false;
        } else {
          return false;
        }
      } else {
        if (permissions.isNotEmpty) {
          return requestNotificationPermissions(
              icon: notificationAlertPermission,
              title: getTranslated("notificationPermissionTitle"),
              message: getTranslated("notificationPermissionMessageContent"),
              permissions: permissions,
              showFromRational: true);
        } else {
          var popupValue = await customPermissionDialog(
              icon: notificationAlertPermission,
              content:
                  dialogContent2,dialogStyle: AppStyleConfig.dialogStyle); //getPermissionAlertMessage("audio_call"));
          if (popupValue) {
            openAppSettings();
            return false;
          } else {
            return false;
          }
        }
      }
    } else {
      return true;
    }
  }

  static Future<bool> requestNotificationPermissions(
      {required String icon,
      required String title,
      required String message,
      required List<Permission> permissions,
      bool showFromRational = false}) async {
    var deniedPopupValue = await notificationPermissionDialog(
        icon: icon,
        title: title,
        message: message); //Constants.audioCallPermission);
    if (deniedPopupValue) {
      LogMessage.d("deniedPopupValue", deniedPopupValue);
      var newp = await permissions.request();
      PermissionStatus? notification_ = newp[Permission.notification];
      if (notification_ != null) {
        LogMessage.d("notification_", notification_.isPermanentlyDenied);
        SessionManagement.setBool(Constants.notificationPermissionAsked, true);
      }
      return (notification_?.isGranted ?? true);
    } else {
      return false;
    }
  }

  static Future<bool> askAudioCallPermissions() async {
    final microphone = await Permission.microphone.status; //RECORD_AUDIO
    final phone = await Permission.phone.status; //READ_PHONE_STATE
    final bluetoothConnect =
        await Permission.bluetoothConnect.status; //BLUETOOTH_CONNECT
    final notification = await Permission.notification.status; //NOTIFICATION
    var permissions = <Permission>[];
    if (Platform.isAndroid &&
        (!phone.isGranted ||
            (await Permission.phone
                .shouldShowRequestRationale) /*&& !SessionManagement.getBool(Constants.readPhoneStatePermissionAsked)*/)) {
      permissions.add(Permission.phone);
    }
    if (!microphone.isGranted ||
        (await Permission.microphone
            .shouldShowRequestRationale) /*&& !SessionManagement.getBool(Constants.audioRecordPermissionAsked)*/) {
      permissions.add(Permission.microphone);
    }
    if (Platform.isAndroid &&
        (!bluetoothConnect.isGranted ||
            (await Permission.bluetoothConnect
                .shouldShowRequestRationale) /*&& !SessionManagement.getBool(Constants.bluetoothPermissionAsked)*/)) {
      permissions.add(Permission.bluetoothConnect);
    }
    if (Platform.isAndroid &&
        (!notification.isGranted ||
            (await Permission.notification
                .shouldShowRequestRationale) /*&& !SessionManagement.getBool(Constants.notificationPermissionAsked)*/)) {
      permissions.add(Permission.notification);
    }
    LogMessage.d("phone", phone.isGranted);
    LogMessage.d(
        "microphone isPermanentlyDenied", microphone.isPermanentlyDenied);
    LogMessage.d("microphone", microphone.isGranted);
    LogMessage.d("bluetoothConnect", bluetoothConnect.isGranted);
    LogMessage.d("notification", notification.isGranted);
    if ((!microphone.isGranted) ||
        (Platform.isAndroid ? !phone.isGranted : false) ||
        (Platform.isAndroid ? !bluetoothConnect.isGranted : false) ||
        (Platform.isAndroid ? !notification.isGranted : false)) {
      var shouldShowRequestRationale =
          ((await Permission.microphone.shouldShowRequestRationale) ||
              (await Permission.phone.shouldShowRequestRationale) ||
              (await Permission.bluetoothConnect.shouldShowRequestRationale) ||
              (await Permission.notification.shouldShowRequestRationale));
      LogMessage.d(
          "shouldShowRequestRationale audio", shouldShowRequestRationale);
      LogMessage.d(
          "SessionManagement.getBool(Constants.audioRecordPermissionAsked) audio",
          (SessionManagement.getBool(Constants.audioRecordPermissionAsked)));
      LogMessage.d("permissions audio", (permissions.toString()));
      var alreadyAsked =
          ((SessionManagement.getBool(Constants.audioRecordPermissionAsked) ||
                  (Platform.isAndroid &&
                      SessionManagement.getBool(
                          Constants.readPhoneStatePermissionAsked)) ||
                  (Platform.isAndroid &&
                      SessionManagement.getBool(
                          Constants.bluetoothPermissionAsked))) &&
              (Platform.isAndroid &&
                  SessionManagement.getBool(
                      Constants.notificationPermissionAsked)));
      LogMessage.d("alreadyAsked audio", alreadyAsked);
      var permissionName = getPermissionDisplayName(permissions);
      LogMessage.d("permissionName", permissionName);
      var dialogContent =
          getTranslated("callPermissionContent").replaceAll("%d", permissionName);
      var dialogContent2 =
          getTranslated("callPermissionDeniedContent").replaceAll("%d", permissionName);
      if (shouldShowRequestRationale) {
        LogMessage.d("shouldShowRequestRationale", shouldShowRequestRationale);
        return requestAudioCallPermissions(
            content: dialogContent,
            permissions: permissions,
            showFromRational: true);
      } else if (alreadyAsked) {
        LogMessage.d("alreadyAsked", alreadyAsked);
        var popupValue = await customPermissionDialog(
            icon: audioPermission,
            content:
                dialogContent2,dialogStyle: AppStyleConfig.dialogStyle); //getPermissionAlertMessage("audio_call"));
        if (popupValue) {
          openAppSettings();
          return false;
        } else {
          return false;
        }
      } else {
        if (permissions.isNotEmpty) {
          return requestAudioCallPermissions(
              content: dialogContent, permissions: permissions);
        } else {
          var popupValue = await customPermissionDialog(
              icon: audioPermission,
              content:
                  dialogContent2,dialogStyle: AppStyleConfig.dialogStyle); //getPermissionAlertMessage("audio_call"));
          if (popupValue) {
            openAppSettings();
            return false;
          } else {
            return false;
          }
        }
      }
    } else {
      return true;
    }
  }

  static Future<bool> requestAudioCallPermissions(
      {required String content,
      required List<Permission> permissions,
      bool showFromRational = false}) async {
    var deniedPopupValue = await mirrorFlyPermissionDialog(
        icon: audioPermission,
        content: content,dialogStyle: AppStyleConfig.dialogStyle); //Constants.audioCallPermission);
    if (deniedPopupValue) {
      LogMessage.d("deniedPopupValue", deniedPopupValue);
      var newp = await permissions.request();
      PermissionStatus? microphone_ = newp[Permission.microphone];
      PermissionStatus? phone_ = newp[Permission.phone];
      PermissionStatus? bluetoothConnect_ = newp[Permission.bluetoothConnect];
      PermissionStatus? notification_ = newp[Permission.notification];
      if (microphone_ != null) {
        LogMessage.d("microphone_", microphone_.isPermanentlyDenied);
        SessionManagement.setBool(Constants.audioRecordPermissionAsked, true);
      }
      if (phone_ != null) {
        LogMessage.d("phone_", phone_.isPermanentlyDenied);
        SessionManagement.setBool(
            Constants.readPhoneStatePermissionAsked, true);
      }
      if (bluetoothConnect_ != null) {
        LogMessage.d(
            "bluetoothConnect_", bluetoothConnect_.isPermanentlyDenied);
        SessionManagement.setBool(Constants.bluetoothPermissionAsked, true);
      }
      if (notification_ != null) {
        LogMessage.d("notification_", notification_.isPermanentlyDenied);
        SessionManagement.setBool(Constants.notificationPermissionAsked, true);
      }
      return (microphone_?.isGranted ?? true) &&
          (phone_?.isGranted ?? true) &&
          (bluetoothConnect_?.isGranted ?? true) &&
          (notification_?.isGranted ?? true);
    } else {
      return false;
    }
  }

  static Future<bool> askVideoCallPermissions() async {
    if (Platform.isAndroid) {
      final microphone = await Permission.microphone.status; //RECORD_AUDIO
      final phone = await Permission.phone.status; //READ_PHONE_STATE
      final bluetoothConnect =
          await Permission.bluetoothConnect.status; //BLUETOOTH_CONNECT
      final camera = await Permission.camera.status; //CAMERA
      final notification = await Permission.notification.status; //NOTIFICATION
      var permissions = <Permission>[];
      if (!phone.isGranted ||
          (await Permission.phone
              .shouldShowRequestRationale) /*&& !SessionManagement.getBool(Constants.readPhoneStatePermissionAsked)*/) {
        permissions.add(Permission.phone);
      }
      if (!microphone.isGranted ||
          (await Permission.microphone
              .shouldShowRequestRationale) /*&& !SessionManagement.getBool(Constants.audioRecordPermissionAsked)*/) {
        permissions.add(Permission.microphone);
      }
      if (!camera.isGranted ||
          (await Permission.camera
              .shouldShowRequestRationale) /*&& !SessionManagement.getBool(Constants.cameraPermissionAsked)*/) {
        permissions.add(Permission.camera);
      }
      if (!bluetoothConnect.isGranted ||
          (await Permission.bluetoothConnect
              .shouldShowRequestRationale) /*&& !SessionManagement.getBool(Constants.bluetoothPermissionAsked)*/) {
        permissions.add(Permission.bluetoothConnect);
      }
      if (!notification.isGranted ||
          (await Permission.notification
              .shouldShowRequestRationale) /*&& !SessionManagement.getBool(Constants.notificationPermissionAsked)*/) {
        permissions.add(Permission.notification);
      }
      if ((microphone != PermissionStatus.granted) ||
          (phone != PermissionStatus.granted) ||
          (camera != PermissionStatus.granted) ||
          (bluetoothConnect != PermissionStatus.granted) ||
          (notification != PermissionStatus.granted)) {
        var shouldShowRequestRationale = ((await Permission
                .camera.shouldShowRequestRationale) ||
            (await Permission.microphone.shouldShowRequestRationale) ||
            (await Permission.phone.shouldShowRequestRationale) ||
            (await Permission.bluetoothConnect.shouldShowRequestRationale) ||
            (await Permission.notification.shouldShowRequestRationale));
        LogMessage.d(
            "shouldShowRequestRationale video", shouldShowRequestRationale);
        LogMessage.d(
            "SessionManagement.getBool(Constants.cameraPermissionAsked) video",
            SessionManagement.getBool(Constants.cameraPermissionAsked));
        var alreadyAsked = ((SessionManagement.getBool(
                    Constants.cameraPermissionAsked) ||
                SessionManagement.getBool(
                    Constants.audioRecordPermissionAsked) ||
                SessionManagement.getBool(
                    Constants.readPhoneStatePermissionAsked) ||
                SessionManagement.getBool(
                    Constants.bluetoothPermissionAsked)) &&
            SessionManagement.getBool(Constants.notificationPermissionAsked));
        LogMessage.d("alreadyAsked video", alreadyAsked);
        var permissionName = getPermissionDisplayName(permissions);
        LogMessage.d("permissionName", permissionName);
        var dialogContent =
            getTranslated("callPermissionContent").replaceAll("%d", permissionName);
        var dialogContent2 =
            getTranslated("callPermissionDeniedContent").replaceAll("%d", permissionName);
        if (shouldShowRequestRationale) {
          return requestVideoCallPermissions(
              content: dialogContent, permissions: permissions);
        } else if (alreadyAsked) {
          var popupValue = await customPermissionDialog(
              icon: recordAudioVideoPermission,
              content:
                  dialogContent2,dialogStyle: AppStyleConfig.dialogStyle); //getPermissionAlertMessage("video_call"));
          if (popupValue) {
            openAppSettings();
            return false;
          } else {
            return false;
          }
        } else {
          if (permissions.isNotEmpty) {
            return requestVideoCallPermissions(
                content: dialogContent, permissions: permissions);
          } else {
            var popupValue = await customPermissionDialog(
                icon: recordAudioVideoPermission,
                content:
                    dialogContent2,dialogStyle: AppStyleConfig.dialogStyle); //getPermissionAlertMessage("video_call"));
            if (popupValue) {
              openAppSettings();
              return false;
            } else {
              return false;
            }
          }
        }
      } else {
        return true;
      }
    } else {
      return _askiOSVideoCallPermissions();
    }
  }

  static Future<bool> requestVideoCallPermissions(
      {required String content,
      required List<Permission> permissions,
      bool showFromRational = false}) async {
    var deniedPopupValue = await mirrorFlyPermissionDialog(
        icon: recordAudioVideoPermission,
        content: content,dialogStyle: AppStyleConfig.dialogStyle); //Constants.videoCallPermission);
    if (deniedPopupValue) {
      var newp = await permissions.request();
      PermissionStatus? microphone_ = newp[Permission.microphone];
      PermissionStatus? phone_ = newp[Permission.phone];
      PermissionStatus? camera_ = newp[Permission.camera];
      PermissionStatus? bluetoothConnect_ = newp[Permission.bluetoothConnect];
      PermissionStatus? notification_ = newp[Permission.notification];
      if (camera_ != null /*&& camera_.isPermanentlyDenied*/) {
        SessionManagement.setBool(Constants.cameraPermissionAsked, true);
      }
      if (microphone_ != null /*&&microphone_.isPermanentlyDenied*/) {
        SessionManagement.setBool(Constants.audioRecordPermissionAsked, true);
      }
      if (phone_ != null /*&& phone_.isPermanentlyDenied*/) {
        SessionManagement.setBool(
            Constants.readPhoneStatePermissionAsked, true);
      }
      if (bluetoothConnect_ !=
          null /*&&bluetoothConnect_.isPermanentlyDenied*/) {
        SessionManagement.setBool(Constants.bluetoothPermissionAsked, true);
      }
      if (notification_ != null /*&&notification_.isPermanentlyDenied*/) {
        SessionManagement.setBool(Constants.notificationPermissionAsked, true);
      }
      return (camera_?.isGranted ?? true) &&
          (microphone_?.isGranted ?? true) &&
          (phone_?.isGranted ?? true) &&
          (bluetoothConnect_?.isGranted ?? true) &&
          (notification_?.isGranted ?? true);
    } else {
      return false;
    }
  }

  static Future<bool> _askiOSVideoCallPermissions() async {
    final microphone = await Permission.microphone.status; //RECORD_AUDIO
    final camera = await Permission.camera.status;
    const newPermission = [
      Permission.microphone,
      Permission.camera,
    ];
    if ((microphone != PermissionStatus.granted &&
            microphone != PermissionStatus.permanentlyDenied) ||
        (camera != PermissionStatus.granted &&
            camera != PermissionStatus.permanentlyDenied)) {
      var permissionPopupValue = await mirrorFlyPermissionDialog(
          icon: recordAudioVideoPermission,
          content: getTranslated("videoCallPermissionContent"),dialogStyle: AppStyleConfig.dialogStyle);
      if (permissionPopupValue) {
        var newp = await newPermission.request();
        PermissionStatus? speech_ = newp[Permission.microphone];
        PermissionStatus? camera_ = newp[Permission.camera];
        return (speech_!.isGranted && camera_!.isGranted);
      } else {
        return false;
      }
    } else if ((microphone == PermissionStatus.permanentlyDenied) ||
        (camera == PermissionStatus.permanentlyDenied)) {
      var popupValue = await customPermissionDialog(
          icon: audioPermission,
          content: getPermissionAlertMessage("audio_call"),dialogStyle: AppStyleConfig.dialogStyle);
      if (popupValue) {
        openAppSettings();
        return false;
      } else {
        return false;
      }
    } else {
      return (microphone.isGranted && camera.isGranted);
    }
  }

  static Future<PermissionStatus> getManageStoragePermission() async {
    final permission = await Permission.manageExternalStorage.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      final newPermission = await Permission.manageExternalStorage.request();
      return newPermission;
    } else {
      return permission;
    }
  }

  static Future<PermissionStatus> requestPermission(
      Permission permission) async {
    var status1 = await permission.status;
    LogMessage.d('status', status1.toString());
    savePermissionAsked(permission);
    if (status1 == PermissionStatus.denied &&
        status1 != PermissionStatus.permanentlyDenied) {
      LogMessage.d('permission.request', status1.toString());
      final status = await permission.request();
      return status;
    }
    return status1;
  }

  static Future<bool> checkPermission(Permission permission,
      String permissionIcon, String permissionContent) async {
    var status = await permission.status;
    debugPrint("checkPermission $permission status $status");
    if (status == PermissionStatus.granted) {
      debugPrint("permission granted opening");
      return true;
    } else if (status == PermissionStatus.denied ||
        (Platform.isAndroid && await permission.shouldShowRequestRationale)) {
      LogMessage.d('denied', 'permission');
      var popupValue = await customPermissionDialog(
          icon: permissionIcon, content: permissionContent,dialogStyle: AppStyleConfig.dialogStyle);
      if (popupValue) {
        var newp = await AppPermission.requestPermission(permission);
        return newp.isGranted;
      } else {
        return false;
      }
    } else if (status == PermissionStatus.denied) {
      LogMessage.d('denied', 'permission');
      var popupValue = await customPermissionDialog(
          icon: permissionIcon, content: permissionContent,dialogStyle: AppStyleConfig.dialogStyle);
      if (popupValue) {
        // return AppPermission.requestPermission(permission);/*.then((value) {
        var newp = await AppPermission.requestPermission(permission);
        /*if(newp.isPermanentlyDenied) {
          // savePermissionAsked(permission);
          var deniedPopupValue = await customPermissionDialog(
              icon: permissionIcon,
              content: getPermissionAlertMessage(
                  permission.toString().replaceAll("Permission.", "")));
          if (deniedPopupValue) {
            openAppSettings();
            return false;
          } else {
            return false;
          }
        }else{
          return newp.isGranted;
        }*/
        return newp.isGranted;
      } else {
        return false;
      }
    } else {
      var deniedPopupValue = await customPermissionDialog(
          icon: permissionIcon,
          content: getPermissionAlertMessage(
              permission.toString().replaceAll("Permission.", "")),dialogStyle: AppStyleConfig.dialogStyle);
      if (deniedPopupValue) {
        openAppSettings();
        return false;
      } else {
        return false;
      }
    }
  }

  /// This [checkAndRequestPermissions] is used to Check and Request List of Permission .
  ///
  /// * [permissions] list of [Permission] to check and request
  /// * [permissionIcon] that shows in the popup before asking permission, used in [customPermissionDialog]
  /// * [permissionContent] that shows in the popup before asking permission, used in [customPermissionDialog]
  /// * [permissionPermanentlyDeniedContent] that shows in the popup when the permission is [PermissionStatus.permanentlyDenied], used in [customPermissionDialog]
  ///
  static Future<bool> checkAndRequestPermissions(
      {required List<Permission> permissions,
      required String permissionIcon,
      required String permissionContent,
      required String permissionPermanentlyDeniedContent}) async {
    var permissionStatusList = await permissions.status();
    var hasDeniedPermission = permissionStatusList.values
        .where((element) => element.isDenied)
        .isNotEmpty;
    var permanentlyDeniedPermission = permissionStatusList.values
        .where((element) => element.isPermanentlyDenied);
    var hasPermanentlyDeniedPermission = permanentlyDeniedPermission.isNotEmpty;
    LogMessage.d("checkAndRequestPermissions",
        "hasDeniedPermission : $hasDeniedPermission ,hasPermanentlyDeniedPermission : $hasPermanentlyDeniedPermission");
    if (hasDeniedPermission) {
      // Permissions are denied, check if rationale should be shown
      var permissionRationaleList = await permissions.shouldShowRationale();
      // bool shouldShowRationale = await Permission.camera.shouldShowRequestRationale || await Permission.microphone.shouldShowRequestRationale;
      var hasShowRationale =
          permissionRationaleList.where((element) => element==true).isNotEmpty;
      LogMessage.d(
          "checkAndRequestPermissions", "hasShowRationale : $hasShowRationale");
      if (Platform.isAndroid && hasShowRationale) {
        // Show rationale dialog explaining why the permissions are needed
        var popupValue = await customPermissionDialog(
            icon: permissionIcon, content: permissionContent,dialogStyle: AppStyleConfig.dialogStyle);
        if (popupValue) {
          var afterAskRationale = await permissions.request();
          var hasGrantedPermissionAfterAsk = afterAskRationale.values
              .where((element) => element.isGranted);
          LogMessage.d("checkAndRequestPermissions",
              "rationale hasGrantedPermissionAfterAsk : $hasGrantedPermissionAfterAsk hasPermanentlyDeniedPermission : $hasPermanentlyDeniedPermission");
          if (hasPermanentlyDeniedPermission) {
            return await showPermanentlyDeniedPopup(
                permissions: permissions,
                permissionIcon: permissionIcon,
                permissionPermanentlyDeniedContent: permissionPermanentlyDeniedContent);
          } else {
            return (hasGrantedPermissionAfterAsk.length >= permissions.length);
          }
        }
        return popupValue;
      } else {
        // Request permissions without showing rationale
        var popupValue = await customPermissionDialog(
            icon: permissionIcon, content: permissionContent,dialogStyle: AppStyleConfig.dialogStyle);
        if (popupValue) {
          var afterAsk = await permissions.request();
          var hasGrantedPermissionAfterAsk = afterAsk.values
              .where((element) => element.isGranted);
          LogMessage.d("checkAndRequestPermissions",
              "hasGrantedPermissionAfterAsk : $hasGrantedPermissionAfterAsk hasPermanentlyDeniedPermission : $hasPermanentlyDeniedPermission");
          if (hasPermanentlyDeniedPermission) {
            return await showPermanentlyDeniedPopup(
                permissions: permissions,
                permissionIcon: permissionIcon,
                permissionPermanentlyDeniedContent:
                    permissionPermanentlyDeniedContent);
          } else {
            return (hasGrantedPermissionAfterAsk.length >= permissions.length);
          }
        } else {
          //user clicked not now in popup
          return popupValue;
        }
      }
    } else if (hasPermanentlyDeniedPermission) {
      return await showPermanentlyDeniedPopup(
          permissions: permissions,
          permissionIcon: permissionIcon,
          permissionPermanentlyDeniedContent:
              permissionPermanentlyDeniedContent);
    } else {
      // Permissions are already granted, proceed with your logic
      return true;
    }
  }

  static Future<bool> showPermanentlyDeniedPopup(
      {required List<Permission> permissions,
      required String permissionIcon,
      required String permissionPermanentlyDeniedContent}) async {
    // var permissionStatusList = await permissions.permanentlyDeniedPermissions();
    // var strings = permissionStatusList.keys.toList().join(",");
    // Permissions are permanently denied, navigate to app settings page
    var popupValue = await customPermissionDialog(
        icon: permissionIcon, content: permissionPermanentlyDeniedContent,dialogStyle: AppStyleConfig.dialogStyle);
    if (popupValue) {
      openAppSettings();
    }
    return false;
  }

  static Future<List<Permission>> getGalleryAccessPermissions() async {
    var permissions = <Permission>[];
    var sdkVersion = 0;
    if (Platform.isAndroid) {
      var sdk = await DeviceInfoPlugin().androidInfo;
      sdkVersion = sdk.version.sdkInt;
    } else {
      sdkVersion = 0;
    }
    if (Platform.isIOS) {
      permissions.addAll([Permission.photos,Permission.storage]);
    }else if (sdkVersion < 33 && Platform.isAndroid) {
      permissions.add(Permission.storage);
    } else{
      ///[Permission.photos] for Android 33+ gallery access
      ///[Permission.videos] for Android 33+ gallery access
      permissions.addAll([Permission.photos, Permission.videos]);
    }
    LogMessage.d("getGalleryAccessPermissions", permissions.join(","));
    return permissions;
  }

  static String getPermissionAlertMessage(String permission) {
    var permissionAlertMessage = "";
    var permissionName = permission;

    switch (permissionName.toLowerCase()) {
      case "camera":
        permissionAlertMessage = getTranslated("cameraPermissionDeniedContent");
        break;
      case "microphone":
        permissionAlertMessage = getTranslated("microPhonePermissionDeniedContent");
        break;
      case "storage":
        permissionAlertMessage = getTranslated("storagePermissionDeniedContent");
        break;
      case "contacts":
        permissionAlertMessage = getTranslated("contactPermissionDeniedContent");
        break;
      case "location":
        permissionAlertMessage = getTranslated("locationPermissionDeniedContent");
        break;
      case "audio_call":
        permissionAlertMessage = getTranslated("audioCallPermissionDeniedContent");
        break;
      case "video_call":
        permissionAlertMessage = getTranslated("videoCallPermissionDeniedContent");
        break;
      default:
        permissionAlertMessage = getTranslated("permissionContent").replaceFirst("%d", permissionName.toUpperCase()).replaceFirst("%", permissionName.toUpperCase());
            // "MirrorFly need the ${permissionName.toUpperCase()} Permission. But they have been permanently denied. Please continue to app settings, select \"Permissions\", and enable \"${permissionName.toUpperCase()}\"";
    }
    return permissionAlertMessage;
  }

  static Future<bool> notificationPermissionDialog(
      {required String icon,
      required String title,
      required String message}) async {
    return await DialogUtils.createDialog(AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            return;
          }
          NavUtils.back(result: false);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 35.0),
              child: Center(
                  child: CircleAvatar(
                backgroundColor: buttonBgColor,
                radius: 30,
                child: AppUtils.svgIcon(icon:notificationAlertPermission),
              )),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                title,
                style: const TextStyle(fontSize: 14, color: textHintColor),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: textColor,
                ),
              ),
            ),
            Container(
              color: notificationAlertBg,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () {
                        NavUtils.back(result: false);
                        // notNowBtn();
                      },
                      child: Text(
                        getTranslated("notNow").toUpperCase(),
                        style: const TextStyle(
                          color: buttonBgColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      )),
                  TextButton(
                      onPressed: () {
                        NavUtils.back(result: true);
                        // continueBtn();
                      },
                      child: Text(getTranslated("turnOn").toUpperCase(),
                          style: const TextStyle(
                            color: buttonBgColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'sf_ui',
                          )))
                ],
              ),
            )
          ],
        ),
      ),
    ));
  }

  static Future<bool> mirrorFlyPermissionDialog(
      {required String icon, required String content,DialogStyle dialogStyle = const DialogStyle()}) async {
    return await DialogUtils.createDialog(AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            return;
          }
          NavUtils.back(result: false);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 35.0),
              decoration: dialogStyle.headerContainerDecoration,
              // color: buttonBgColor,
              child: Center(child: AppUtils.svgIcon(icon:icon,colorFilter: ColorFilter.mode(dialogStyle.iconColor, BlendMode.srcIn),)),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                content,
                style: dialogStyle.contentTextStyle,
                // style: const TextStyle(fontSize: 14, color: textColor),
              ),
            )
          ],
        ),
      ),
      actions: [
        TextButton(
          style: dialogStyle.buttonStyle,
            onPressed: () {
              NavUtils.back(result: false);
              // notNowBtn();
            },
            child: Text(
              getTranslated("notNow").toUpperCase(),
              // style: const TextStyle(color: buttonBgColor),
            )),
        TextButton(
            style: dialogStyle.buttonStyle,
            onPressed: () {
              NavUtils.back(result: true);
              // continueBtn();
            },
            child: Text(
              getTranslated("continue").toUpperCase(),
              // style: const TextStyle(color: buttonBgColor),
            ))
      ],
    ));
  }

  static Future<bool> customPermissionDialog(
      {required String icon, required String content,DialogStyle dialogStyle = const DialogStyle()}) async {
    return await DialogUtils.createDialog(AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            return;
          }
          NavUtils.back(result: false);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 35.0),
              decoration: dialogStyle.headerContainerDecoration,
              child: Center(child: AppUtils.svgIcon(icon:icon,colorFilter: ColorFilter.mode(dialogStyle.iconColor, BlendMode.srcIn),)),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                content,
                style: dialogStyle.contentTextStyle,
                // style: const TextStyle(fontSize: 14, color: textColor),
              ),
            )
          ],
        ),
      ),
      actions: [
        TextButton(
            style: dialogStyle.buttonStyle,
            onPressed: () {
              NavUtils.back(result: false);
              // notNowBtn();
            },
            child: Text(
              getTranslated("notNow").toUpperCase(),
              // style: const TextStyle(color: buttonBgColor),
            )),
        TextButton(
            style: dialogStyle.buttonStyle,
            onPressed: () {
              NavUtils.back(result: true);
              // continueBtn();
            },
            child: Text(
              getTranslated("continue").toUpperCase(),
              // style: const TextStyle(color: buttonBgColor),
            ))
      ],
    ));
  }

  static void savePermissionAsked(Permission permission) {
    if (permission == Permission.camera) {
      SessionManagement.setBool(Constants.cameraPermissionAsked, true);
    } else if (permission == Permission.microphone) {
      SessionManagement.setBool(Constants.audioRecordPermissionAsked, true);
    } else if (permission == Permission.phone) {
      SessionManagement.setBool(Constants.readPhoneStatePermissionAsked, true);
    } else if (permission == Permission.bluetoothConnect) {
      SessionManagement.setBool(Constants.bluetoothPermissionAsked, true);
    } else if (permission == Permission.notification) {
      SessionManagement.setBool(Constants.notificationPermissionAsked, true);
    }
  }

  static String getTextForGivenPermission(Permission permission) {
    if (Permission.camera.value == permission.value) {
      return getTranslated("cameraPermissionName");
    } else if (Permission.microphone.value == permission.value) {
      return getTranslated("microphonePermissionName");
    } else if (Permission.bluetoothConnect.value == permission.value) {
      return getTranslated("nearByPermissionName");
    } else if (Permission.notification.value == permission.value) {
      return getTranslated("notificationPermissionName");
    } else if (Permission.phone.value == permission.value) {
      return getTranslated("phonePermissionName");
    }
    return "";
  }

  static String getPermissionDisplayName(List<Permission> permissions) {
    var permissionNames = permissions.map((e) => getTextForGivenPermission(e));
    LogMessage.d("permissionNames", permissionNames.join(", "));
    return permissionNames.length == 2
        ? permissionNames.join(" & ")
        : permissionNames.join(", ");
  }
}
