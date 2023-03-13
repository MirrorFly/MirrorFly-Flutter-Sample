import 'package:get/get.dart';

import '../controllers/camera_pick_controller.dart';

class CameraPickBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CameraPickController>(
      () => CameraPickController(),
    );
  }
}
