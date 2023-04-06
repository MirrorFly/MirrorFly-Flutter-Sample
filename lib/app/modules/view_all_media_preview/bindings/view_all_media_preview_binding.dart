import 'package:get/get.dart';

import '../controllers/view_all_media_preview_controller.dart';

class ViewAllMediaPreviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ViewAllMediaPreviewController>(
      () => ViewAllMediaPreviewController(),
    );
  }
}
