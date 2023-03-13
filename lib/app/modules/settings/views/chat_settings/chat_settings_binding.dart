import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/modules/settings/views/chat_settings/chat_settings_controller.dart';

class ChatSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ChatSettingsController());
  }
}