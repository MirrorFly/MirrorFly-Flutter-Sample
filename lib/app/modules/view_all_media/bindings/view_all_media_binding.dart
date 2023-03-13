import 'package:get/get.dart';

import '../controllers/view_all_media_controller.dart';

class ViewAllMediaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ViewAllMediaController());
  }
}