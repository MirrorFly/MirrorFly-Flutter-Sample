import 'package:geolocator/geolocator.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';

class Permission {

  Future<bool> getLocationPermission() async{
    var permission = await Geolocator.requestPermission();
    Log(permission.name, permission.index.toString());
    return permission.index==2 || permission.index==3;
  }
}