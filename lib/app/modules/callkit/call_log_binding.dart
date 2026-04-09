import 'package:get/get.dart';
import 'call_log_controller.dart';

class CallLogBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CallLogController>(() => CallLogController());
  }
}
