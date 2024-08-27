import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/modules/settings/views/blocked/blocked_list_controller.dart';

class BlockedListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BlockedListController());
  }
}