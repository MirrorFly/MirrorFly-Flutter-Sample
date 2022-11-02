import 'package:get/get.dart';

import '../controllers/message_info_controller.dart';

class MessageInfoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MessageInfoController>(
      () => MessageInfoController(),
    );
  }
}
