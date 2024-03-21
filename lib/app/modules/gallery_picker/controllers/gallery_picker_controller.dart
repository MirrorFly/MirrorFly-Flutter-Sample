import 'package:flutter/material.dart';
import 'package:mirror_fly_demo/app/modules/gallery_picker/src/presentation/pages/gallery_media_picker_controller.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';
import 'package:get/get.dart';

import '../src/data/models/picked_asset_model.dart';

class GalleryPickerController extends GetxController {
  var provider = GalleryMediaPickerController();
  var pickedFile = <PickedAssetModel>[].obs;
  var userName = Get.arguments['userName'];
  var textMessage = Get.arguments['caption'];
  var profile = Get.arguments['profile'] as ProfileDetails;
  var maxPickImages = 10;

  @override
  void onInit() {
    super.onInit();
    pickedFile.clear();
    debugPrint("gallery picker controller --> $textMessage");
  }


   addFile(List<PickedAssetModel> paths) {
     pickedFile(paths);
     pickedFile.refresh();
   }
   // addFile(List<PickedAssetModel> paths) {
   //  debugPrint("list size--> ${paths.length}");
   //  debugPrint("file name--> ${paths[0].file?.path}");
   //  for(var filePath in paths){
   //    if(pickedFile.contains(filePath)){
   //      debugPrint("picked file remove");
   //      pickedFile.remove(filePath);
   //    }else{
   //      debugPrint("picked file add");
   //      pickedFile.add(filePath);
   //    }
   //  }
   // }

}
