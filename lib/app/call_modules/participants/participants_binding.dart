import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/call_modules/participants/add_participants_controller.dart';


class ParticipantsBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut(() => CallController());
    Get.lazyPut<AddParticipantsController>(
          () => AddParticipantsController(),
    );
  }
}