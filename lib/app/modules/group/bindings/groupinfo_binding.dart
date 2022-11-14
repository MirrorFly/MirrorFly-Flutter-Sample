import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/modules/group/controllers/groupcreation_controller.dart';
import 'package:mirror_fly_demo/app/modules/group/controllers/group_info_controller.dart';

class GroupInfoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GroupInfoController());
  }
}