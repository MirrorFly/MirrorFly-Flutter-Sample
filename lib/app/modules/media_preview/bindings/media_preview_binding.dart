import 'package:get/get.dart';

import '../controllers/media_preview_controller.dart';

class MediaPreviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MediaPreviewController>(
      () => MediaPreviewController(),
    );
  }
}
