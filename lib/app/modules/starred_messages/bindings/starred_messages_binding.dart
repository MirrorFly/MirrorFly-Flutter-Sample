import 'package:get/get.dart';

import '../controllers/starred_messages_controller.dart';

class StarredMessagesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StarredMessagesController>(
      () => StarredMessagesController(),
    );
  }
}
