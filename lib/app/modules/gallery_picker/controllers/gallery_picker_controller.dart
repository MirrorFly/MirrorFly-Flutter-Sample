import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../modules/gallery_picker/src/presentation/pages/gallery_media_picker_controller.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import '../../../data/utils.dart';
import '../src/data/models/picked_asset_model.dart';

class GalleryPickerController extends GetxController {
  var provider = GalleryMediaPickerController();
  var pickedFile = <PickedAssetModel>[].obs;
  var userName = NavUtils.arguments['userName'];
  var textMessage = NavUtils.arguments['caption'];
  var mentionedUsersIds = NavUtils.arguments['mentionedUsersIds'] as List<String>;
  var profile = NavUtils.arguments['profile'] as ProfileDetails;
  var userJid = NavUtils.arguments['userJid'];
  var maxPickImages = 10;

  var captionMessage = <String>[].obs;
  var captionMessageMentions = <List<String>>[];

  @override
  void onInit() {
    super.onInit();
    if(textMessage != null) {
      captionMessage.add(textMessage);
    }
    if(mentionedUsersIds.isNotEmpty) {
      captionMessageMentions.add(mentionedUsersIds);
    }
    pickedFile.clear();
    debugPrint("gallery picker controller --> $textMessage");
  }


   addFile(List<PickedAssetModel> paths) {
     pickedFile(paths);
     captionMessage.add("");
     captionMessageMentions.add([]);
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
