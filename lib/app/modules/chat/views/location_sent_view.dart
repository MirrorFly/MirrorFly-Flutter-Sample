
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';

import '../controllers/location_controller.dart';

class LocationSentView extends GetView<LocationController>{
  LocationSentView({Key? key}) : super(key: key);
  var controller = Get.put<LocationController>(LocationController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: const Text('User Location'),
    automaticallyImplyLeading: true,
        ),
      body:SafeArea(
        child: Obx(
          ()=> Column(
            children: [
              Expanded(
                child:GoogleMap(
                  markers: {controller.marker.value},
                    // on below line setting camera position
                    initialCameraPosition: controller.kGoogle.value,
                    // on below line we are setting markers on the map
                    //markers: Set<Marker>.of(controller.marker),
                    // on below line specifying map type.
                    mapType: MapType.normal,
                    // on below line setting user location enabled.
                    //myLocationEnabled: true,
                    // on below line setting compass enabled.
                    //compassEnabled: true,
                    // on below line specifying controller on map complete.
                    zoomControlsEnabled: false,
                    onMapCreated: (GoogleMapController mapController)=>controller.onMapCreated(mapController),
                    onCameraMove: (CameraPosition position)=>controller.onCameraMove(position),
                  onTap: (latLng)=>controller.onTap(latLng),
                  ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Obx(
                        ()=>controller.address1.value.isNotEmpty ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Send this Location',style: TextStyle(color: buttonbgcolor,fontSize: 14,fontWeight: FontWeight.normal),),
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(controller.address1.value,style: const TextStyle(color: texthintcolor,fontSize: 16,fontWeight: FontWeight.w700),),
                            ),
                            Text(controller.address2.value,style: const TextStyle(color: textcolor,fontSize: 14,fontWeight: FontWeight.normal),),
                          ],
                        ) : const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: FloatingActionButton.small(onPressed: (){
                      if(controller.location.value.latitude!=0){
                        //sent Location Message
                        Get.back(result: controller.location.value);
                      }
                    },
                      backgroundColor: buttonbgcolor,
                    child: const Icon(Icons.arrow_forward_rounded,color: Colors.white,size: 18,),),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}