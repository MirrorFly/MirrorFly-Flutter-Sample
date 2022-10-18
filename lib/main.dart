
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/common/apptheme.dart';
import 'package:mirror_fly_demo/app/common/main_controller.dart';
import 'package:mirror_fly_demo/app/modules/dashboard/bindings/dashboard_binding.dart';
import 'package:mirror_fly_demo/app/modules/login/bindings/login_binding.dart';

import 'app/data/SessionManagement.dart';
import 'app/routes/app_pages.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await SessionManagement.onInit();
  Get.put<MainController>(MainController());
  runApp(const MyApp());
  configLoading();
}
void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.rotatingCircle
    ..loadingStyle = EasyLoadingStyle.light
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.blue
    ..backgroundColor = Colors.white
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.black
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = true
    ..dismissOnTap = false;
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "MirrorFly",
      theme: apptheme.theme,
      builder: EasyLoading.init(),
      debugShowCheckedModeBanner: false,
      initialBinding: SessionManagement().getLogin() ? DashboardBinding() : LoginBinding(),
      initialRoute: SessionManagement().getLogin() ? AppPages.DASHBOARD : AppPages.INITIAL,
      //initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});
//
//   @override
//   State<MyApp> createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//
//   static const mirrorfly_method_channel = MethodChannel('contus.mirrorfly/mirrorfly_sdk');
//
//   @override
//   void initState() {
//     super.initState();
//     initSDKState();
//   }
//
//   // Platform messages are asynchronous, so we initialize in an async method.
//   Future<void> initSDKState() async {
//     String? sdkInit;
//     try {
//       debugPrint("MethodChannel call===> SDK INIT");
//       sdkInit = await mirrorfly_method_channel.invokeMethod('sdk_init');
//       debugPrint("Result ==> $sdkInit");
//     }on PlatformException {
//       sdkInit = "Failed to Initialize SDK";
//       debugPrint("Result ===> Platform Exception");
//     } on Exception catch(error){
//       sdkInit = 'Failed to Initialize SDK';
//       debugPrint("Result ==> $error");
//     }
//
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       title: "MirrorFly",
//       debugShowCheckedModeBanner: false,
//       initialRoute: AppPages.INITIAL,
//       getPages: AppPages.routes,
//     );
//   }
// }

