import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/modules/chat/controllers/forwardchat_controller.dart';

class ForwardChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ForwardChatController());
  }
}