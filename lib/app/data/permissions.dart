import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:permission_handler/permission_handler.dart';

import 'helper.dart';

class AppPermission {
  AppPermission._();
  /*static Future<bool> getLocationPermission() async{
    var permission = await Geolocator.requestPermission();
    mirrorFlyLog(permission.name, permission.index.toString());
    return permission.index==2 || permission.index==3;
  }*/



  static Future<PermissionStatus> getContactPermission() async {
    final permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      const newPermission = Permission.contacts;
      mirrorFlyPermissionDialog(
          notNowBtn: () {
            return false;
          },
          continueBtn: () async {
            newPermission.request();
          },
          icon: contactPermission,
          content: Constants.contactPermission);
      return newPermission.status;
    } else {
      return permission;
    }
  }

  static Future<PermissionStatus> getStoragePermission() async {
    var sdkVersion=0;
    if (Platform.isAndroid) {
      var sdk =  await DeviceInfoPlugin().androidInfo;
      sdkVersion=sdk.version.sdkInt;
    } else {
      sdkVersion = 0;
    }
    if (sdkVersion < 33) {
      final permission = await Permission.storage.status;
      if (permission != PermissionStatus.granted &&
          permission != PermissionStatus.permanentlyDenied) {
        const newPermission = Permission.storage;
        mirrorFlyPermissionDialog(
            notNowBtn: () {
              return false;
            },
            continueBtn: () async {
              newPermission.request();
            },
            icon: filePermission,
            content: Constants.filePermission);
        return newPermission.status;
      } else {
        return permission;
      }
    } else {
      return getAndroid13Permission();
    }
  }

  static Future<PermissionStatus> getAndroid13Permission() async {
    final photos = await Permission.photos.status;
    final videos = await Permission.videos.status;
    // final audio = await Permission.audio.status;
    const newPermission = [
      Permission.photos,
      Permission.videos,
      // Permission.audio
    ];
    if ((photos != PermissionStatus.granted &&
        photos != PermissionStatus.permanentlyDenied) ||
        (videos != PermissionStatus.granted &&
            videos != PermissionStatus.permanentlyDenied)) {
      mirrorFlyPermissionDialog(
          notNowBtn: () {
            return false;
          },
          continueBtn: () async {
            newPermission.request();
          },
          icon: filePermission,
          content: Constants.filePermission);
      var photo = await newPermission[0].status.isGranted;
      var video = await newPermission[1].isGranted;
      // var audio = await newPermission[2].isGranted;
      return (photo && video)
          ? PermissionStatus.granted
          : PermissionStatus.denied;
    } else {
      return (photos.isGranted && videos.isGranted)
          ? PermissionStatus.granted
          : PermissionStatus.denied;
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

  static Future<PermissionStatus> getCameraPermission() async {
    final permission = await Permission.camera.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      const newPermission = Permission.camera;
      mirrorFlyPermissionDialog(
          notNowBtn: () {
            return false;
          },
          continueBtn: () async {
            newPermission.request();
          },
          icon: cameraPermission,
          content: Constants.cameraPermission);
      return newPermission.status;
    } else {
      return permission;
    }
  }

  static Future<PermissionStatus> getAudioPermission() async {
    final permission = await Permission.microphone.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.permanentlyDenied) {
      const newPermission = Permission.microphone;
      mirrorFlyPermissionDialog(
          notNowBtn: () {
            return false;
          },
          continueBtn: () async {
            newPermission.request();
          },
          icon: audioPermission,
          content: Constants.audioPermission);
      return newPermission.status;
    } else {
      return permission;
    }
  }

  static Future<bool> askFileCameraAudioPermission() async {
    var filePermission = Permission.storage;
    var camerapermission = Permission.camera;
    var audioPermission = Permission.microphone;
    if (await filePermission.isGranted == false ||
        await camerapermission.isGranted == false ||
        await audioPermission.isGranted == false) {
      mirrorFlyPermissionDialog(
          notNowBtn: () {
            return false;
          },
          continueBtn: () async {
            if (await requestPermission(filePermission) &&
                await requestPermission(camerapermission) &&
                await requestPermission(audioPermission)) {
              return true;
            } else {
              return false;
            }
          },
          icon: cameraPermission,
          content: Constants.cameraPermission);
    } else {
      return true;
    }
    return false;
  }

  static Future<bool> requestPermission(Permission permission) async {
    var status1 = await permission.status;
    mirrorFlyLog('status', status1.toString());
    if (status1 == PermissionStatus.denied &&
        status1 != PermissionStatus.permanentlyDenied) {
      mirrorFlyLog('permission.request', status1.toString());
      final status = await permission.request();
      return status.isGranted;
    }
    return status1.isGranted;
  }

  static Future<bool> checkPermission(Permission permission, String permissionIcon, String permissionContent) async {
    var status = await permission.status;
    if (status == PermissionStatus.granted) {
      debugPrint("permission granted opening");
      return true;
    }else if(status == PermissionStatus.permanentlyDenied){
      mirrorFlyLog('permanentlyDenied', 'permission');
      var permissionAlertMessage = "";
      var permissionName = "$permission";
      permissionName = permissionName.replaceAll("Permission.", "");

      switch (permissionName.toLowerCase()){
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
        default:
          permissionAlertMessage = "MirrorFly need the ${permissionName.toUpperCase()} Permission. But they have been permanently denied. Please continue to app settings, select \"Permissions\", and enable \"${permissionName.toUpperCase()}\"";
      }

      var deniedPopupValue = await customPermissionDialog(icon: permissionIcon,
          content: permissionAlertMessage);
      if(deniedPopupValue){
        openAppSettings();
        return false;
      }else{
        return false;
      }
    }else{
      mirrorFlyLog('denied', 'permission');
      var popupValue = await customPermissionDialog(icon: permissionIcon,
          content: permissionContent);
      if(popupValue){
        return AppPermission.requestPermission(permission);/*.then((value) {
          if(value){
            return true;
          }else{
            return false;
          }
        });*/
      }else{
        return false;
      }
    }
  }

  static permissionDeniedDialog({required String content}){
    Helper.showAlert(
        message:
        content,
        title: "Permission Denied",
        actions: [
          TextButton(
              onPressed: () {
                Get.back();
                openAppSettings();
              },
              child: const Text("OK")),
        ]);
  }
  static mirrorFlyPermissionDialog(
      {required Function() notNowBtn,
      required Function() continueBtn,
      required String icon,
      required String content}) {
    Get.dialog(AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: Column(
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
      actions: [
        TextButton(
            onPressed: () {
              Get.back(result: "no");
              notNowBtn();
            },
            child: const Text(
              "NOT NOW",
              style: TextStyle(color: buttonBgColor),
            )),
        TextButton(
            onPressed: () {
              Get.back(result: "yes");
              continueBtn();
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
      content: Column(
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
}
