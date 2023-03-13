import 'package:get/get.dart';

import 'datausage_controller.dart';


class DataUsageListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DataUsageController>(
      () => DataUsageController(),
    );
  }
}
