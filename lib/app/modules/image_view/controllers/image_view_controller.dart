import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/data/SessionManagement.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';

class ImageViewController extends GetxController {
  var image_name = ''.obs;
  var imagepath = ''.obs;
  var imageurl = ''.obs;
  @override
  void onInit() {
    super.onInit();
    image_name(Get.arguments['imageName']);
    imagepath(Get.arguments['imagePath']);
    if(Get.arguments['imageurl'].toString().startsWith("http")) {
      imageurl(Get.arguments['imageurl']);
    }else {
      imageurl(SessionManagement().getMediaEndPoint().checkNull() +
          Get.arguments['imageurl'].toString());
    }
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
