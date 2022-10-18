import 'package:get/get.dart';

import '../controllers/video_preview_controller.dart';

class VideoPreviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VideoPreviewController>(
      () => VideoPreviewController(),
    );
  }
}
