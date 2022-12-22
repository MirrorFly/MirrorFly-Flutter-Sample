import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:permission_handler/permission_handler.dart';

class AppPermission {
  AppPermission._();
  /*static Future<bool> getLocationPermission() async{
    var permission = await Geolocator.requestPermission();
    mirrorFlyLog(permission.name, permission.index.toString());
    return permission.index==2 || permission.index==3;
  }*/
  static Future<PermissionStatus> getLocationPermission() async {
    final permission = await Permission.location.status;
    if(permission != PermissionStatus.granted && permission != PermissionStatus.permanentlyDenied){
      const newPermission = Permission.location;
      mirrorflyPermissionDialog(notnowBtn: (){
        return false;
      }, continueBtn: () async {
        newPermission.request();
      }, icon: locationPinPermission, content: Constants.locationPermission);
      return newPermission.status;
    }else{
      return permission;
    }
  }
  static Future<PermissionStatus> getContactPermission() async {
    final permission = await Permission.contacts.status;
    if(permission != PermissionStatus.granted && permission != PermissionStatus.permanentlyDenied){
      const newPermission = Permission.contacts;
      mirrorflyPermissionDialog(notnowBtn: (){
        return false;
      }, continueBtn: () async {
        newPermission.request();
      }, icon: locationPinPermission, content: Constants.locationPermission);
      return newPermission.status;
    }else{
      return permission;
    }
  }
  static Future<PermissionStatus> getStoragePermission() async {
    final permission = await Permission.storage.status;
    if(permission != PermissionStatus.granted && permission != PermissionStatus.permanentlyDenied){
      const newPermission = Permission.storage;
      mirrorflyPermissionDialog(notnowBtn: (){
        return false;
      }, continueBtn: () async {
        newPermission.request();
      }, icon: filePermission, content: Constants.filePermission);
      return newPermission.status;
    }else{
      return permission;
    }
  }

  static Future<PermissionStatus> getManageStoragePermission() async {
    final permission = await Permission.manageExternalStorage.status;
    if(permission != PermissionStatus.granted && permission != PermissionStatus.permanentlyDenied){
      final newPermission = await Permission.manageExternalStorage.request();
      return newPermission;
    }else{
      return permission;
    }
  }

  static Future<PermissionStatus> getCameraPermission() async {
    final permission = await Permission.camera.status;
    if(permission != PermissionStatus.granted && permission != PermissionStatus.permanentlyDenied){
      const newPermission = Permission.camera;
      mirrorflyPermissionDialog(notnowBtn: (){
        return false;
      }, continueBtn: () async {
        newPermission.request();
      }, icon: cameraPermission, content: Constants.cameraPermission);
      return newPermission.status;
    }else{
      return permission;
    }
  }

  static Future<PermissionStatus> getAudioPermission() async {
    final permission = await Permission.microphone.status;
    if(permission != PermissionStatus.granted && permission != PermissionStatus.permanentlyDenied){
      const newPermission = Permission.microphone;
      mirrorflyPermissionDialog(notnowBtn: (){
        return false;
      }, continueBtn: () async {
        newPermission.request();
      }, icon: audioPermission, content: Constants.audioPermission);
      return newPermission.status;
    }else{
      return permission;
    }
  }

  static Future<bool> askFileCameraAudioPermission() async {
      var filePermission = Permission.storage;
      var camerapermission = Permission.camera;
      var audioPermission = Permission.microphone;
      if(await filePermission.isGranted==false || await camerapermission.isGranted==false || await audioPermission.isGranted==false) {
        mirrorflyPermissionDialog(notnowBtn: (){
          return false;
        }, continueBtn: () async {
          if (await requestPermission(filePermission) &&
              await requestPermission(camerapermission) &&
              await requestPermission(audioPermission)) {
            return true;
          } else {
            return false;
          }
        }, icon: cameraPermission, content: Constants.cameraPermission);

      }else{
        return true;
      }
    return false;
  }
  static Future<bool> requestPermission(Permission permission) async {
    var status = await permission.status;
    if(status!=PermissionStatus.granted && status != PermissionStatus.permanentlyDenied) {
      final status = await permission.request();
      return status.isGranted;
    }
    return status.isGranted;
  }

  static mirrorflyPermissionDialog(
      {required Function() notnowBtn,
      required Function() continueBtn,
      required String icon,
      required String content}){
    Get.dialog(
        AlertDialog(
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
                child: Text(content,style: const TextStyle(fontSize: 14,color: textColor),),
              )
            ],
          ),
          actions: [
            TextButton(onPressed: (){
              Get.back();
              notnowBtn();
            }, child: const Text("NOT NOW",style: TextStyle(color: buttonBgColor),)),
            TextButton(onPressed: (){
              Get.back();
              continueBtn();
            }, child: const Text("CONTINUE",style: TextStyle(color: buttonBgColor),))
          ],
        ));
  }
}