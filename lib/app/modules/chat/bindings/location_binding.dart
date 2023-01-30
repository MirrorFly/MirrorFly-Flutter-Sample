import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/modules/chat/controllers/location_controller.dart';

class LocationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LocationController>(
          () => LocationController(),
    );
  }
}
