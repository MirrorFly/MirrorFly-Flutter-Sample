import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/modules/contact_sync/controllers/contact_sync_controller.dart';

class ContactSyncBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ContactSyncController());
  }
}