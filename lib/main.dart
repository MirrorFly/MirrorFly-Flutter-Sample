import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/common/apptheme.dart';
import 'package:mirror_fly_demo/app/common/main_controller.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/modules/dashboard/bindings/dashboard_binding.dart';
import 'package:mirror_fly_demo/app/modules/login/bindings/login_binding.dart';
import 'app/data/SessionManagement.dart';
import 'app/modules/profile/bindings/profile_binding.dart';
import 'app/routes/app_pages.dart';

import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

bool shouldUseFirebaseEmulator = false;
Future<void> main() async {
// Require Hybrid Composition mode on Android.
  final GoogleMapsFlutterPlatform mapsImplementation =
      GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    mapsImplementation.useAndroidViewSurface = true;
  }
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await Firebase.initializeApp();
  }

  if (shouldUseFirebaseEmulator) {
    await FirebaseAuth.instance.useAuthEmulator('localhost', 5050);
  }
  await SessionManagement.onInit();
  Get.put<MainController>(MainController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "MirrorFly",
      theme: Apptheme.theme,
      builder: EasyLoading.init(),
      debugShowCheckedModeBanner: false,
      initialBinding: getBinding(),
      initialRoute: getIntialRoute(),
      //initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}
Bindings? getBinding(){
  if(SessionManagement().getLogin()){
    if(SessionManagement().getName().checkNull().isNotEmpty && SessionManagement().getMobileNumber().checkNull().isNotEmpty){
      return DashboardBinding();
    }else{
      return ProfileBinding();
    }
  }else{
    return LoginBinding();
  }
}

String getIntialRoute(){
  if(SessionManagement().getLogin()){
    if(SessionManagement().getName().checkNull().isNotEmpty && SessionManagement().getMobileNumber().checkNull().isNotEmpty){
      return AppPages.DASHBOARD;
    }else{
      return AppPages.PROFILE;
    }
  }else{
    return AppPages.INITIAL;
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

