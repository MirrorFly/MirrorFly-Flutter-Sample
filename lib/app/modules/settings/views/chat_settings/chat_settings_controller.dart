import 'package:flysdk/flysdk.dart';
import 'package:get/get.dart';

class ChatSettingsController extends GetxController {

  final _archiveEnabled = false.obs;
  bool get archiveEnabled => _archiveEnabled.value;

  @override
  void onInit(){
    super.onInit();
    getArchivedSettingsEnabled();
  }
  Future<void> getArchivedSettingsEnabled() async {
    await FlyChat.isArchivedSettingsEnabled().then((value) => _archiveEnabled(value));

  }

  void enableArchive(){
    FlyChat.enableDisableArchivedSettings(!archiveEnabled);
    _archiveEnabled(!archiveEnabled);
  }
}