import 'dart:async';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';

class NetworkManager extends GetxController{

  static RxBool isConnected =false.obs;
  static StreamSubscription<InternetConnectionStatus>? listener;

  @override
  Future<void> onInit() async {
    // Check internet connection with singleton (no custom values allowed)
    listener = InternetConnectionChecker().onStatusChange.listen(
          (InternetConnectionStatus status) {
        switch (status) {
          case InternetConnectionStatus.connected:
            mirrorFlyLog("network",'Data connection is available.');
            break;
          case InternetConnectionStatus.disconnected:
            mirrorFlyLog("network",'You are disconnected from the internet.');
            break;
        }
      },
    );
    /*// Create customized instance which can be registered via dependency injection
    final InternetConnectionChecker customInstance =
    InternetConnectionChecker.createInstance(
      checkTimeout: const Duration(seconds: 1),
      checkInterval: const Duration(seconds: 1),

    );

    // Check internet connection with created instance
    await execute(customInstance);*/
    super.onInit();
  }

  @override
  void onClose() {
   listener?.cancel();
    super.onClose();
  }

  static Future<bool> isNetConnected() async {
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    return isConnected;
  }
}