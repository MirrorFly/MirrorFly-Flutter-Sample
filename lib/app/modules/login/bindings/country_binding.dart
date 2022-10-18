import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/modules/login/controllers/country_controller.dart';


class CountryListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CountryController>(
      () => CountryController(),
    );
  }
}
