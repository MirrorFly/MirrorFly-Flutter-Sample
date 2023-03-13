import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/modules/profile/controllers/status_controller.dart';

class StatusListBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut<StatusListController>(
          () => StatusListController(),
    );
  }

}