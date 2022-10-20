import 'dart:async';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';

class LocationController extends GetxController{
  Completer<GoogleMapController> mapcontroller = Completer();
  var address1="".obs;
  var address2="".obs;
  var location = LatLng(0, 0).obs;
  var kGoogle = CameraPosition(
    target: LatLng(20.42796133580664, 80.885749655962),
    zoom: 14.4746,
  ).obs;
  // on below line we have created the list of markers
  List<Marker> marker = <Marker>[
    Marker(
        markerId: MarkerId('1'),
        position: LatLng(20.42796133580664, 75.885749655962),
        infoWindow: InfoWindow(
          title: 'My Position',
        )
    ),
  ];

  @override
  void onInit() async{
    super.onInit();
    Geolocator.getLastKnownPosition().then((value){
      Log("Location", value.toString());
      if(value!=null) {
        location.value = LatLng(value.latitude, value.longitude);
        kGoogle.value =
            CameraPosition(target: LatLng(value.latitude, value.longitude));
        getAddress(value.latitude, value.longitude);
      }else{
        throw "lastknownlocation null";
      }
    }).catchError((er){
      Log("Location", er.toString());
    });
  }

  // created method for getting user current location
  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission().then((value){
    }).onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      Log("ERROR",error.toString());
    });
    return await Geolocator.getCurrentPosition();
  }

  Future<Placemark> getAddress(double lat,double lng)async{
    var addresses = await placemarkFromCoordinates(lat,lng);
    var first = addresses.first;
    addresses.forEach((element) {
      Log("addresslist ", element.toJson().toString());
    });
    Log("address", first.toJson().toString());
    address1.value=first.street.toString()+","+first.subLocality.toString();
    address2.value=first.subAdministrativeArea.toString()+","+first.administrativeArea.toString()+","+first.postalCode.toString();
    //print(' ${first.locality}, ${first.administrativeArea},${first.subLocality}, ${first.subAdministrativeArea},${first.street}, ${first.name},${first.thoroughfare}, ${first.subThoroughfare}');
    return first;
  }
}