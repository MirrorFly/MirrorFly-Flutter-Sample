import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/modules/dashboard/controllers/recent_chat_search_controller.dart';


class RecentSearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RecentChatSearchController>(
          () => RecentChatSearchController(),
    );
  }
}
