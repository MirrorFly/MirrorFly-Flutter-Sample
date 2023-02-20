import 'package:get/get.dart';

import '../src/data/models/picked_asset_model.dart';

class GalleryPickerController extends GetxController {

  var pickedFile = <PickedAssetModel>[].obs;
  var userName = Get.arguments['userName'];
  var maxPickImages = 10;

  @override
  void onInit() {
    super.onInit();
    pickedFile.clear();
  }


   addFile(List<PickedAssetModel> paths) {
     pickedFile.clear();
     pickedFile.addAll(paths);
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
