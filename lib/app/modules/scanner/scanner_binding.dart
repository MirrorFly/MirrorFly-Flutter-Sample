import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/modules/scanner/scanner_controller.dart';

class ScannerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ScannerController());
  }
}