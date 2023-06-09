import 'package:get/get.dart';

import 'call_controller.dart';

class OutGoingCallBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CallController());
  }
}