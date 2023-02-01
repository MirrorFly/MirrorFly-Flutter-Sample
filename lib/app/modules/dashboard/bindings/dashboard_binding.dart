import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/modules/dashboard/controllers/dashboard_controller.dart';


class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(
          () => DashboardController(),
    );
  }
}
