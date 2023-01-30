import 'package:get/get.dart';

import '../src/data/models/picked_asset_model.dart';

class GalleryPickerController extends GetxController {

  List<PickedAssetModel> pickedFile = [];
  var userName = Get.arguments['userName'];

  @override
  void onInit() {
    super.onInit();
    pickedFile.clear();
  }


}
