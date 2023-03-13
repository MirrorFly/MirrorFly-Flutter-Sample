import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/modules/settings/controllers/settings_controller.dart';

class SettingsBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(
          () => SettingsController(),
    );
  }

}