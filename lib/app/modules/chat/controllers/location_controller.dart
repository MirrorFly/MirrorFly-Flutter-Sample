import 'dart:async';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mirrorfly_plugin/logmessage.dart';

class LocationController extends GetxController{
  Completer<GoogleMapController> completer = Completer();
  late GoogleMapController controller;
  var address1="".obs;
  var address2="".obs;
  var location = const LatLng(0, 0).obs;
  var kGoogle = const CameraPosition(
    target: LatLng(20.42796133580664, 80.885749655962),
    zoom: 14.4746,
  ).obs;
  // on below line we have created the list of markers

  Rx<Marker> marker = const Marker(
        markerId: MarkerId('1'),
        position: LatLng(20.42796133580664, 75.885749655962),
    ).obs;

  onMapCreated(GoogleMapController googleMapController){
    completer.complete(googleMapController);
    controller = googleMapController;
    getLocation();
    LogMessage.d("onMapCreated", googleMapController.getVisibleRegion().toString());
  }

  @override
  void onClose(){
    super.onClose();
    controller.dispose();
  }

  onCameraMove(CameraPosition position){
    LogMessage.d("onCameraMove", position.toString());
  }
  onTap(LatLng latLng){
      setLocation(latLng);
  }
  getLocation(){
    Geolocator.getLastKnownPosition().then((value){
      LogMessage.d("Location", value.toString());
      if(value!=null) {
        setLocation(LatLng(value.latitude, value.longitude));
      }else{
        throw "last known location null";
      }
    }).catchError((er){
      LogMessage.d("Location", er.toString());
      Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best).then((value) {
        // if (value != null) {
          setLocation(LatLng(value.latitude, value.longitude));
        // } else {
        //   throw "current location null";
        // }
      }).catchError((er){

      });
    });
  }

  setLocation(LatLng position){
    //var position = LatLng(value.latitude, value.longitude);
    Marker updatedMarker = marker.value.copyWith(
      positionParam: position,
    );
    marker(updatedMarker);
    location(position);
    kGoogle(CameraPosition(target: position,zoom: 17.0));
    getAddress(position.latitude, position.longitude);
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        kGoogle.value,
      ),
    );
    update();
  }
  // created method for getting user current location
  Future<Position> getUserCurrentLocation() async {
    await Geolocator.requestPermission().then((value){
    }).onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      LogMessage.d("ERROR",error.toString());
    });
    return await Geolocator.getCurrentPosition();
  }

  Future<Placemark> getAddress(double lat,double lng)async{
    var addresses = await placemarkFromCoordinates(lat,lng);
    var first = addresses.first;
    for (var element in addresses) {
      LogMessage.d("address-list ", element.toJson().toString());
    }
    LogMessage.d("address", first.toJson().toString());
    address1.value="${first.street},${first.subLocality}";
    address2.value="${first.subAdministrativeArea},${first.administrativeArea},${first.postalCode}";
    //print(' ${first.locality}, ${first.administrativeArea},${first.subLocality}, ${first.subAdministrativeArea},${first.street}, ${first.name},${first.thoroughfare}, ${first.subThoroughfare}');
    return first;
  }
}