import 'package:get/get.dart';

import '../controllers/call_timeout_controller.dart';

class CallTimeoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CallTimeoutController>(
      () => CallTimeoutController(),
    );
  }
}
