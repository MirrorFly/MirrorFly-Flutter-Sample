import 'package:get/get.dart';

import '../controllers/local_contact_controller.dart';

class LocalContactBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LocalContactController>(
      () => LocalContactController(),
    );
  }
}
