import 'package:get/get.dart';

import '../controllers/busy_status_controller.dart';

class BusyStatusBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BusyStatusController>(
      () => BusyStatusController(),
    );
  }
}
