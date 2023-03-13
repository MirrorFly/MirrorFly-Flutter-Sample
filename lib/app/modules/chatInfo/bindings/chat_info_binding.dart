import 'package:get/get.dart';

import '../controllers/chat_info_controller.dart';

class ChatInfoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatInfoController>(
      () => ChatInfoController(),
    );
  }
}
