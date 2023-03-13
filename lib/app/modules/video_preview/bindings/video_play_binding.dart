import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/modules/video_preview/controllers/video_play_controller.dart';


class VideoPlayBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VideoPlayController>(
          () => VideoPlayController(),
    );
  }
}
