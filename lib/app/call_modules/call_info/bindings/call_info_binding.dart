import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/call_modules/call_info/controllers/call_info_controller.dart';

class CallInfoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CallInfoController>(
          () => CallInfoController(),
    );
  }
}