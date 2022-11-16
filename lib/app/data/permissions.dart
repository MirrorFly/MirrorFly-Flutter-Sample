import 'package:geolocator/geolocator.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:permission_handler/permission_handler.dart';

class AppPermission {

  Future<bool> getLocationPermission() async{
    var permission = await Geolocator.requestPermission();
    Log(permission.name, permission.index.toString());
    return permission.index==2 || permission.index==3;
  }
  static Future<PermissionStatus> getContactPermission() async {
    final permission = await Permission.contacts.status;
    if(permission != PermissionStatus.granted && permission != PermissionStatus.permanentlyDenied){
      final newPermission = await Permission.contacts.request();
      return newPermission;
    }else{
      return permission;
    }
  }
  static Future<PermissionStatus> getStoragePermission() async {
    final permission = await Permission.storage.status;
    if(permission != PermissionStatus.granted && permission != PermissionStatus.permanentlyDenied){
      final newPermission = await Permission.storage.request();
      return newPermission;
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
}