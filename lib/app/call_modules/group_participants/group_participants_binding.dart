import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/call_modules/group_participants/group_participants_controller.dart';

class GroupParticipantsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GroupParticipantsController());
  }
}