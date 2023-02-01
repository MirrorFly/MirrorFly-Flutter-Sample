import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/modules/settings/views/chat_settings/language/language_controller.dart';


class LanguageListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LanguageController>(
      () => LanguageController(),
    );
  }
}
