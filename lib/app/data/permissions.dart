import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/session_management.dart';
import 'package:mirrorfly_plugin/logmessage.dart';
import 'package:permission_handler/permission_handler.dart';

import 'helper.dart';

class AppPermission {
  AppPermission._();

  /*static Future<bool> getLocationPermission() async{
    var permission = await Geolocator.requestPermission();
    mirrorFlyLog(permission.name, permission.index.toString());
    return permission.index==2 || permission.index==3;
  }*/

  static Future<bool> getStoragePermission() async {
    var sdkVersion = 0;
    if (Platform.isAndroid) {
      var sdk = await DeviceInfoPlugin().androidInfo;
      sdkVersion = sdk.version.sdkInt;
    } else {
      sdkVersion = 0;
    }
    if (sdkVersion < 33) {
      final permission = await Permission.storage.status;
      if (permission != PermissionStatus.granted &&
          permission != PermissionStatus.permanentlyDenied) {
        const newPermission = Permission.storage;
        var deniedPopupValue = await mirrorFlyPermissionDialog(
            icon: filePermission,
            content: Constants.filePermission);
        if (deniedPopupValue) {
          var newp = await newPermission.request();
          if (newp.isGranted) {
            return true;
          } else {
            var popupValue = await customPermissionDialog(
                icon: filePermission,
                content: getPermissionAlertMessage("storage"));
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
      mirrorFlyLog("showing mirrorfly popup", "");
      var deniedPopupValue = await mirrorFlyPermissionDialog(
          icon: filePermission,
          content: Constants.filePermission);
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
              content: getPermissionAlertMessage("storage"));
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
      mirrorFlyLog("showing mirrorfly popup",
          "${photos.isGranted} ${videos.isGranted} ${mediaLibrary.isGranted}");
      return (photos.isGranted && videos.isGranted && mediaLibrary.isGranted);
      // ? photos
      // : photos;
    }
  }

  static Future<bool> askAudioCallPermissions() async {
    final microphone = await Permission.microphone.status; //RECORD_AUDIO
    final phone = await Permission.phone.status; //READ_PHONE_STATE
    final bluetoothConnect = await Permission.bluetoothConnect.status; //BLUETOOTH_CONNECT
    var permissions = <Permission>[];
    if(!microphone.isGranted && !SessionManagement.getBool(Constants.audioRecordPermissionAsked)){
      permissions.add(Permission.microphone);
    }
    if(!phone.isGranted && !SessionManagement.getBool(Constants.readPhoneStatePermissionAsked) && Platform.isAndroid){
      permissions.add(Permission.phone);
    }
    if(!bluetoothConnect.isGranted && !SessionManagement.getBool(Constants.bluetoothPermissionAsked) && Platform.isAndroid){
      permissions.add(Permission.bluetoothConnect);
    }
    LogMessage.d("microphone", microphone.isGranted);
    LogMessage.d("phone", phone.isGranted);
    LogMessage.d("bluetoothConnect", bluetoothConnect.isGranted);
    if ((!microphone.isGranted) ||
        (Platform.isAndroid ? !phone.isGranted : false) ||
        (Platform.isAndroid ? !bluetoothConnect.isGranted : false)) {
      var shouldShowRequestRationale = ((await Permission.microphone.shouldShowRequestRationale)
          || (await Permission.phone.shouldShowRequestRationale) ||
          (await Permission.bluetoothConnect.shouldShowRequestRationale));
      LogMessage.d("shouldShowRequestRationale audio", shouldShowRequestRationale);
      LogMessage.d("SessionManagement.getBool(Constants.audioRecordPermissionAsked) audio", (SessionManagement.getBool(Constants.audioRecordPermissionAsked)));
      LogMessage.d("permissions audio", (permissions.toString()));
      var alreadyAsked = (SessionManagement.getBool(Constants.audioRecordPermissionAsked)
          && SessionManagement.getBool(Constants.readPhoneStatePermissionAsked) &&
          SessionManagement.getBool(Constants.bluetoothPermissionAsked));
      LogMessage.d("alreadyAsked audio", alreadyAsked);

      if (shouldShowRequestRationale) {
        return requestAudioCallPermissions(permissions: permissions,showFromRational: true);
      } else if (alreadyAsked) {
        var popupValue = await customPermissionDialog(
            icon: audioPermission,
            content: getPermissionAlertMessage("audio_call"));
        if (popupValue) {
          openAppSettings();
          return false;
        } else {
          return false;
        }
      } else {
        if(permissions.isNotEmpty) {
          return requestAudioCallPermissions(permissions: permissions);
        }else{
          var popupValue = await customPermissionDialog(
              icon: audioPermission,
              content: getPermissionAlertMessage("audio_call"));
          if (popupValue) {
            openAppSettings();
            return false;
          } else {
            return false;
          }
        }
      }
    }else{
      return true;
    }
  }

  static Future<bool> requestAudioCallPermissions({required List<Permission> permissions,bool showFromRational = false}) async {
    var deniedPopupValue = await mirrorFlyPermissionDialog(
        icon: audioPermission,
        content: Constants.audioCallPermission);
    if (deniedPopupValue) {
      var newp = await permissions.request();
      PermissionStatus? microphone_ = newp[Permission.microphone];
      PermissionStatus? phone_ = newp[Permission.phone];
      PermissionStatus? bluetoothConnect_ = newp[Permission.bluetoothConnect];
      if(microphone_!=null && microphone_.isPermanentlyDenied) {
        LogMessage.d("microphone_", microphone_.isPermanentlyDenied);
        SessionManagement.setBool(Constants.audioRecordPermissionAsked, true);
      }
      if(phone_!=null && phone_.isPermanentlyDenied) {
        LogMessage.d("phone_", phone_.isPermanentlyDenied);
        SessionManagement.setBool(Constants.readPhoneStatePermissionAsked, true);
      }
      if(bluetoothConnect_!=null && bluetoothConnect_.isPermanentlyDenied) {
        LogMessage.d("bluetoothConnect_", bluetoothConnect_.isPermanentlyDenied);
        SessionManagement.setBool(Constants.bluetoothPermissionAsked, true);
      }
      return (microphone_?.isGranted ?? true) && (phone_?.isGranted ?? true) && (bluetoothConnect_?.isGranted ?? true);
    }else{
      return false;
    }
  }

  static Future<bool> askVideoCallPermissions() async {
    final microphone = await Permission.microphone.status; //RECORD_AUDIO
    final phone = await Permission.phone.status; //READ_PHONE_STATE
    final bluetoothConnect =
    await Permission.bluetoothConnect.status; //BLUETOOTH_CONNECT
    final camera = await Permission.camera.status; //CAMERA
    var permissions = <Permission>[];
    if(!camera.isGranted && !SessionManagement.getBool(Constants.cameraPermissionAsked)){
      permissions.add(Permission.camera);
    }
    if(!microphone.isGranted && !SessionManagement.getBool(Constants.audioRecordPermissionAsked)){
      permissions.add(Permission.microphone);
    }
    if(!phone.isGranted && !SessionManagement.getBool(Constants.readPhoneStatePermissionAsked)){
      permissions.add(Permission.phone);
    }
    if(!bluetoothConnect.isGranted && !SessionManagement.getBool(Constants.bluetoothPermissionAsked)){
      permissions.add(Permission.bluetoothConnect);
    }
    if ((microphone != PermissionStatus.granted) || (phone != PermissionStatus.granted) || (camera != PermissionStatus.granted) || (bluetoothConnect != PermissionStatus.granted)) {
      var shouldShowRequestRationale = ((await Permission.camera.shouldShowRequestRationale) ||
          (await Permission.microphone.shouldShowRequestRationale)
          || (await Permission.phone.shouldShowRequestRationale) ||
          (await Permission.bluetoothConnect.shouldShowRequestRationale));
      LogMessage.d("shouldShowRequestRationale video", shouldShowRequestRationale);
      LogMessage.d("SessionManagement.getBool(Constants.cameraPermissionAsked) video", SessionManagement.getBool(Constants.cameraPermissionAsked));
      var alreadyAsked = (SessionManagement.getBool(Constants.cameraPermissionAsked) &&
          SessionManagement.getBool(Constants.audioRecordPermissionAsked)
          && SessionManagement.getBool(Constants.readPhoneStatePermissionAsked) &&
          SessionManagement.getBool(Constants.bluetoothPermissionAsked));
      LogMessage.d("alreadyAsked video", alreadyAsked);
      if (shouldShowRequestRationale) {
        return requestVideoCallPermissions(permissions: permissions);
      } else if (alreadyAsked) {
        var popupValue = await customPermissionDialog(
            icon: recordAudioVideoPermission,
            content: getPermissionAlertMessage("video_call"));
        if (popupValue) {
          openAppSettings();
          return false;
        } else {
          return false;
        }
      } else {
        if(permissions.isNotEmpty) {
          return requestVideoCallPermissions(permissions: permissions);
        }else{
          var popupValue = await customPermissionDialog(
              icon: recordAudioVideoPermission,
              content: getPermissionAlertMessage("video_call"));
          if (popupValue) {
            openAppSettings();
            return false;
          } else {
            return false;
          }
        }
      }
    }else{
      return true;
    }
  }

  static Future<bool> requestVideoCallPermissions({required List<Permission> permissions, bool showFromRational = false}) async {
    var deniedPopupValue = await mirrorFlyPermissionDialog(
        icon: recordAudioVideoPermission,
        content: Constants.videoCallPermission);
    if (deniedPopupValue) {
      var newp = await permissions.request();
      PermissionStatus? microphone_ = newp[Permission.microphone];
      PermissionStatus? phone_ = newp[Permission.phone];
      PermissionStatus? camera_ = newp[Permission.camera];
      PermissionStatus? bluetoothConnect_ = newp[Permission.bluetoothConnect];
      if(camera_!=null && camera_.isPermanentlyDenied) {
        SessionManagement.setBool(Constants.cameraPermissionAsked, true);
      }
      if(microphone_!=null &&microphone_.isPermanentlyDenied) {
        SessionManagement.setBool(Constants.audioRecordPermissionAsked, true);
      }
      if(phone_!=null && phone_.isPermanentlyDenied) {
        SessionManagement.setBool(Constants.readPhoneStatePermissionAsked, true);
      }
      if(bluetoothConnect_!=null &&bluetoothConnect_.isPermanentlyDenied) {
        SessionManagement.setBool(Constants.bluetoothPermissionAsked, true);
      }
      return (camera_?.isGranted ?? true) && (microphone_?.isGranted ?? true) && (phone_?.isGranted ?? true) && (bluetoothConnect_?.isGranted ?? true);
    }else{
      return false;
    }
  }
  static Future<bool> askiOSVideoCallPermissions() async {
    final microphone = await Permission.microphone.status;//RECORD_AUDIO
    final camera = await Permission.camera.status;
    const newPermission = [
      Permission.microphone,
      Permission.camera,
    ];
    if((microphone != PermissionStatus.granted && microphone != PermissionStatus.permanentlyDenied) || (camera != PermissionStatus.granted && camera != PermissionStatus.permanentlyDenied)){
      var permissionPopupValue = await mirrorFlyPermissionDialog(
          icon: recordAudioVideoPermission,
          content: Constants.videoCallPermission);
      if (permissionPopupValue) {
        var newp = await newPermission.request();
        PermissionStatus? speech_ = newp[Permission.microphone];
        PermissionStatus? camera_ = newp[Permission.camera];
        return (speech_!.isGranted &&camera_!.isGranted);
      }else{
        toToast("Need Camera and Microphone Permission to Make Video Call");
        return false;
      }
    }else if ((microphone == PermissionStatus.permanentlyDenied) || (camera == PermissionStatus.permanentlyDenied)){
      var popupValue = await customPermissionDialog(
          icon: audioPermission,
          content: getPermissionAlertMessage("audio_call"));
      if (popupValue) {
        openAppSettings();
        return false;
      } else {
        return false;
      }
    } else{
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

  static Future<PermissionStatus> requestPermission(Permission permission) async {
    var status1 = await permission.status;
    mirrorFlyLog('status', status1.toString());
    if (status1 == PermissionStatus.denied &&
        status1 != PermissionStatus.permanentlyDenied) {
      mirrorFlyLog('permission.request', status1.toString());
      final status = await permission.request();
      return status;
    }
    return status1;
  }

  static Future<bool> checkPermission(Permission permission,
      String permissionIcon, String permissionContent) async {
    var status = await permission.status;
    if (status == PermissionStatus.granted) {
      debugPrint("permission granted opening");
      return true;
    } else if (status == PermissionStatus.permanentlyDenied) {
      mirrorFlyLog('permanentlyDenied', 'permission');
      savePermanentlyDenied(permission);
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
    } else {
      mirrorFlyLog('denied', 'permission');
      var popupValue = await customPermissionDialog(
          icon: permissionIcon, content: permissionContent);
      if (popupValue) {
        // return AppPermission.requestPermission(permission);/*.then((value) {
        var newp = await AppPermission.requestPermission(permission);
        if(newp.isPermanentlyDenied) {
          savePermanentlyDenied(permission);
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
        }
      } else {
        return false;
      }
    }
  }

  static String getPermissionAlertMessage(String permission) {
    var permissionAlertMessage = "";
    var permissionName = permission;

    switch (permissionName.toLowerCase()) {
      case "camera":
        permissionAlertMessage = Constants.cameraPermissionDenied;
        break;
      case "microphone":
        permissionAlertMessage = Constants.microPhonePermissionDenied;
        break;
      case "storage":
        permissionAlertMessage = Constants.storagePermissionDenied;
        break;
      case "contacts":
        permissionAlertMessage = Constants.contactPermissionDenied;
        break;
      case "location":
        permissionAlertMessage = Constants.locationPermissionDenied;
        break;
      case "audio_call":
        permissionAlertMessage = Constants.audioCallPermissionDenied;
        break;
      case "video_call":
        permissionAlertMessage = Constants.videoCallPermissionDenied;
        break;
      default:
        permissionAlertMessage =
            "MirrorFly need the ${permissionName.toUpperCase()} Permission. But they have been permanently denied. Please continue to app settings, select \"Permissions\", and enable \"${permissionName.toUpperCase()}\"";
    }
    return permissionAlertMessage;
  }

  static permissionDeniedDialog({required String content}) {
    Helper.showAlert(message: content, title: "Permission Denied", actions: [
      TextButton(
          onPressed: () {
            Get.back();
            openAppSettings();
          },
          child: const Text("OK")),
    ]);
  }

  static Future<bool> mirrorFlyPermissionDialog(
      {required String icon,
      required String content}) async {
    return await Get.dialog(AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: WillPopScope(
        onWillPop: () {
          Get.back(result: false);
          return Future.value(false); },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 35.0),
              color: buttonBgColor,
              child: Center(child: SvgPicture.asset(icon)),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                content,
                style: const TextStyle(fontSize: 14, color: textColor),
              ),
            )
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () {
              Get.back(result: false);
              // notNowBtn();
            },
            child: const Text(
              "NOT NOW",
              style: TextStyle(color: buttonBgColor),
            )),
        TextButton(
            onPressed: () {
              Get.back(result: true);
              // continueBtn();
            },
            child: const Text(
              "CONTINUE",
              style: TextStyle(color: buttonBgColor),
            ))
      ],
    ));
  }

  static Future<bool> customPermissionDialog(
      {required String icon,
      required String content}) async {
    return await Get.dialog(AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: WillPopScope(
        onWillPop: () {
          Get.back(result: false);
          return Future.value(true);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 35.0),
              color: buttonBgColor,
              child: Center(child: SvgPicture.asset(icon)),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                content,
                style: const TextStyle(fontSize: 14, color: textColor),
              ),
            )
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () {
              Get.back(result: false);
              // notNowBtn();
            },
            child: const Text(
              "NOT NOW",
              style: TextStyle(color: buttonBgColor),
            )),
        TextButton(
            onPressed: () {
              Get.back(result: true);
              // continueBtn();
            },
            child: const Text(
              "CONTINUE",
              style: TextStyle(color: buttonBgColor),
            ))
      ],
    ));
  }

  static void savePermanentlyDenied(Permission permission) {
    if(permission == Permission.camera){
      SessionManagement.setBool(Constants.cameraPermissionAsked, true);
    }else if(permission == Permission.microphone){
      SessionManagement.setBool(Constants.audioRecordPermissionAsked, true);
    }else if(permission == Permission.phone){
      SessionManagement.setBool(Constants.readPhoneStatePermissionAsked, true);
    }else if(permission == Permission.bluetoothConnect){
      SessionManagement.setBool(Constants.bluetoothPermissionAsked, true);
    }
  }
}
