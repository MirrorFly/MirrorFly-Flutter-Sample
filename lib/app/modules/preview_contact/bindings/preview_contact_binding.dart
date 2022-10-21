import 'package:get/get.dart';

import '../controllers/preview_contact_controller.dart';

class PreviewContactBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PreviewContactController>(
      () => PreviewContactController(),
    );
  }
}
