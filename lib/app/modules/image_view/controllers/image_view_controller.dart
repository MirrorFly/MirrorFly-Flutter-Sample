import 'package:get/get.dart';

class ImageViewController extends GetxController {
  //TODO: Implement ImageViewController

  var image_name = ''.obs;
  var imagepath = ''.obs;
  @override
  void onInit() {
    super.onInit();
    image_name(Get.arguments['imageName']);
    imagepath(Get.arguments['imagePath']);
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

}
