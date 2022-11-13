import 'package:get/get.dart';

import '../controllers/delete_account_reason_controller.dart';

class DeleteAccountReasonBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeleteAccountReasonController>(
      () => DeleteAccountReasonController(),
    );
  }
}
