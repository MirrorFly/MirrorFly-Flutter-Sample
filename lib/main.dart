
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mirror_fly_demo/app/modules/notification/notification_builder.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/app_theme.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/common/main_controller.dart';
import 'package:mirror_fly_demo/app/common/extensions.dart';
import 'package:mirror_fly_demo/app/data/pushnotification.dart';
import 'package:mirror_fly_demo/app/modules/dashboard/bindings/dashboard_binding.dart';
import 'package:mirror_fly_demo/app/modules/login/bindings/login_binding.dart';
import 'app/common/notification_service.dart';
import 'app/data/session_management.dart';
import 'app/model/reply_hash_map.dart';
import 'app/modules/profile/bindings/profile_binding.dart';
import 'app/routes/app_pages.dart';

import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';




@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  SessionManagement.onInit();
  debugPrint("#Mirrorfly Notification -> Handling a background message: ${message.messageId}");
  if (Platform.isAndroid) {
    PushNotifications.onMessage(message);
  }
}
bool shouldUseFirebaseEmulator = false;
//check app opened from notification
NotificationAppLaunchDetails? notificationAppLaunchDetails;
//check is on going call
bool isOnGoingCall = false;
bool fromMissedCall = false;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint("#Mirrorfly Notification main function init");
  if (!kIsWeb) {
    await Firebase.initializeApp();
    if (Platform.isAndroid) {
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);
    }

  }

  final GoogleMapsFlutterPlatform mapsImplementation =
      GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    mapsImplementation.useAndroidViewSurface = true;
  }
  //check app opened from notification
  notificationAppLaunchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();


  if (shouldUseFirebaseEmulator) {
    await FirebaseAuth.instance.useAuthEmulator('localhost', 5050);
  }
  await SessionManagement.onInit();
  // Get.put<MainController>(MainController());
  Mirrorfly.initializeSDK(
      licenseKey: 'Your_License_Key_Here',
      iOSContainerID: 'group.com.mirrorfly.flutter',
      chatHistoryEnable: true,
      flyCallback: (response) async {
        if(response.isSuccess){
          LogMessage.d("onSuccess", response.message);
        }else{
          LogMessage.d("onFailure", response.errorMessage.toString());
        }
        //check is on going call
        isOnGoingCall = (await Mirrorfly.isOnGoingCall()).checkNull();
        fromMissedCall = (await Mirrorfly.appLaunchedFromMissedCall()).checkNull();
        runApp(const MyApp());
      }
  );

}

class MyApp extends StatefulWidget{
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1000)).then((value) {
      PushNotifications.setupInteractedMessage();
    });

  }
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "MirrorFly",
      theme: MirrorFlyAppTheme.theme,
      debugShowCheckedModeBanner: false,
      onInit: () {
        ReplyHashMap.init();
        NotificationBuilder.cancelNotifications();
        Get.put<MainController>(MainController());
      },
      //initialBinding: getBinding(),
      initialRoute: SessionManagement.getEnablePin() ? Routes.pin : getInitialRoute(),
      //initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}
Bindings? getBinding(){
  if(SessionManagement.getLogin()){
    if(SessionManagement.getName().checkNull().isNotEmpty && SessionManagement.getMobileNumber().checkNull().isNotEmpty){
      return DashboardBinding();
    }else{
      return ProfileBinding();
    }
  }else{
    return LoginBinding();
  }
}

String getInitialRoute() {
  var didNotificationLaunchApp = notificationAppLaunchDetails?.didNotificationLaunchApp ?? false;
  var didNotificationLaunchResponse = notificationAppLaunchDetails?.notificationResponse?.payload;
  debugPrint("didNotificationLaunchApp $didNotificationLaunchApp");
  debugPrint("didNotificationLaunchResponse $didNotificationLaunchResponse");
  if(isOnGoingCall){
    isOnGoingCall=false;
    return AppPages.onGoingCall;
  }else if(didNotificationLaunchApp){
    notificationAppLaunchDetails = null;
    var chatJid = didNotificationLaunchResponse !=null ? didNotificationLaunchResponse.checkNull().split(",")[0] : "";
    var topicId = didNotificationLaunchResponse !=null ? didNotificationLaunchResponse.checkNull().split(",")[1] : "";
    return "${AppPages.chat}?jid=$chatJid&from_notification=$didNotificationLaunchApp&topicId=$topicId";
  }
  if(!SessionManagement.adminBlocked()) {
    if (SessionManagement.getLogin()) {
      if (SessionManagement
          .getName()
          .checkNull()
          .isNotEmpty && SessionManagement
          .getMobileNumber()
          .checkNull()
          .isNotEmpty) {
        debugPrint("=====CHAT ID=====");
        debugPrint(SessionManagement.getChatJid());
        if (SessionManagement
            .getChatJid()
            .checkNull()
            .isEmpty) {
          if(Constants.enableContactSync) {
              // mirrorFlyLog("nonChatUsers", nonChatUsers.toString());
              mirrorFlyLog("SessionManagement.isContactSyncDone()", SessionManagement.isContactSyncDone().toString());
              if (!SessionManagement.isContactSyncDone() /*|| nonChatUsers.isEmpty*/) {
                return AppPages.contactSync;
              }else{
                return "${AppPages.dashboard}?fromMissedCall=$fromMissedCall";
              }
          }else{
            mirrorFlyLog("login", "${SessionManagement
                .getChatJid()
                .checkNull()
                .isEmpty}");
            mirrorFlyLog("SessionManagement.getLogin()", "${SessionManagement.getLogin()}");
            return "${AppPages.dashboard}?fromMissedCall=$fromMissedCall";
          }
        } else {
          return "${AppPages.chat}?jid=${SessionManagement.getChatJid()
              .checkNull()}&from_notification=true";
        }
      } else {
        return AppPages.profile;
      }
    } else {
      return AppPages.initial;
    }
  }else{
    return AppPages.adminBlocked;
  }
}

