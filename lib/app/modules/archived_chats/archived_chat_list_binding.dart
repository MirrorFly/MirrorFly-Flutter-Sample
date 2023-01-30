import 'package:get/get.dart';

import 'archived_chat_list_controller.dart';

class ArchivedChatListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ArchivedChatListController());
  }
}