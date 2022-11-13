import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/modules/settings/views/applock/applock_controller.dart';

class AppLockBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AppLockController());
  }
}