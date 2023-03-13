import 'package:get/get.dart';

import '../controllers/gallery_picker_controller.dart';

class GalleryPickerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GalleryPickerController>(
      () => GalleryPickerController(),
    );
  }
}
