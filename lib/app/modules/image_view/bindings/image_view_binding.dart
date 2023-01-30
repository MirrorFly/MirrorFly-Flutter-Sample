import 'package:get/get.dart';

import '../controllers/image_view_controller.dart';

class ImageViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ImageViewController>(
      () => ImageViewController(),
    );
  }
}
