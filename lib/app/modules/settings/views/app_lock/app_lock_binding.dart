import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/modules/settings/views/app_lock/app_lock_controller.dart';

class AppLockBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AppLockController());
  }
}