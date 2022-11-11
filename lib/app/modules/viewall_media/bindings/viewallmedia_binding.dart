import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/modules/viewall_media/controllers/viewallmedia_controller.dart';

class ViewAllMediaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ViewAllMediaController());
  }
}