import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mirror_fly_demo/app/common/app_localizations.dart';
import 'package:mirror_fly_demo/app/modules/notification/notification_builder.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/app_theme.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/extensions/extensions.dart';
import 'package:mirror_fly_demo/app/data/pushnotification.dart';
import 'app/common/main_controller.dart';
import 'app/common/notification_service.dart';
import 'app/data/session_management.dart';
import 'app/model/reply_hash_map.dart';

import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'app/routes/route_settings.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  SessionManagement.onInit();
  debugPrint("#Mirrorfly Notification -> Handling a background message: ${message.messageId}");
  if (Platform.isAndroid) {
    Mirrorfly.onMissedCall.listen((event) {
      LogMessage.d("onMissedCall Background", event);
    });
    PushNotifications.onMessage(message);
  }
}

//check app opened from notification
NotificationAppLaunchDetails? notificationAppLaunchDetails;

MirrorflyNotificationAppLaunchDetails? appLaunchDetails;

//check is on going call
bool isOnGoingCall = false;
final navigatorKey = GlobalKey<NavigatorState>();
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint("#Mirrorfly Notification main function init");
  if (!kIsWeb) {
    await Firebase.initializeApp();
    if (Platform.isAndroid) {
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    }
  }

  final GoogleMapsFlutterPlatform mapsImplementation = GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    mapsImplementation.useAndroidViewSurface = true;
  }
  //check app opened from notification
  notificationAppLaunchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  await SessionManagement.onInit();
  Mirrorfly.initializeSDK(
      licenseKey: 'ckIjaccWBoMNvxdbql8LJ2dmKqT5bp', //ckIjaccWBoMNvxdbql8LJ2dmKqT5bp//2sdgNtr3sFBSM3bYRa7RKDPEiB38Xo
      iOSContainerID: 'group.com.mirrorfly.flutter', //group.com.mirrorfly.flutter
      chatHistoryEnable: true,
      enableDebugLog: true,
      flyCallback: (response) async {
        if (response.isSuccess) {
          LogMessage.d("onSuccess", response.message);
        } else {
          LogMessage.d("onFailure", response.errorMessage.toString());
        }
        //check is on going call
        isOnGoingCall = (await Mirrorfly.isOnGoingCall()).checkNull();

        ///
        /// This method will give response from Native Android, iOS will return empty by default.
        /// When the app is opened by clicking the notification. (Notification Types: Media Status update, MissedCall)
        /// This value will be set in Android Plugin side and response will be returned here.
        ///
        appLaunchDetails = await Mirrorfly.getAppLaunchedDetails();
        runApp(const MyApp());
      });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    ReplyHashMap.init();
    NotificationBuilder.cancelNotifications();
    Get.put<MainController>(MainController());
    super.initState();
    Future.delayed(const Duration(seconds: 1)).then((value) {
      PushNotifications.setupInteractedMessage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "MirrorFly",
      navigatorKey: navigatorKey,
      theme: MirrorFlyAppTheme.theme,
      debugShowCheckedModeBanner: false,
      locale: AppLocalizations.defaultLocale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: SessionManagement.getEnablePin() ? Routes.pin : getInitialRoute(),
      onGenerateRoute: mirrorFlyRoute,
      // getPages: AppPages.routes,
    );
  }
}

///
/// [getInitialRoute] Check how the App is launched
/// Types:
/// 1. App Icon
/// 2. Missed call notification
/// 3. Media Upload/Download Notification(only applicable for Android)
///
String getInitialRoute() {
  var didNotificationLaunchApp = notificationAppLaunchDetails?.didNotificationLaunchApp ?? false;
  var didNotificationLaunchResponse = notificationAppLaunchDetails?.notificationResponse?.payload;
  var didMissedCallNotificationLaunchApp = appLaunchDetails?.didMissedCallNotificationLaunchApp ?? false;
  var didMediaProgressNotificationLaunchApp = appLaunchDetails?.didMediaProgressNotificationLaunchApp ?? false;
  debugPrint("didMissedCallNotificationLaunchApp $didMissedCallNotificationLaunchApp");
  debugPrint("didMediaProgressNotificationLaunchApp $didMediaProgressNotificationLaunchApp");
  debugPrint("didNotificationLaunchApp $didNotificationLaunchApp");
  debugPrint("didNotificationLaunchResponse $didNotificationLaunchResponse");
  if (isOnGoingCall) {
    isOnGoingCall = false;
    return Routes.onGoingCallView;
  } else if ((didNotificationLaunchApp || didMediaProgressNotificationLaunchApp) && !SessionManagement.adminBlocked()) {
    if (didNotificationLaunchApp) {
      notificationAppLaunchDetails = null;
      var chatJid = didNotificationLaunchResponse != null ? didNotificationLaunchResponse.checkNull().split(",")[0] : "";
      var topicId = didNotificationLaunchResponse != null ? didNotificationLaunchResponse.checkNull().split(",")[1] : "";
      return "${Routes.chat}?jid=$chatJid&from_notification=$didNotificationLaunchApp&topicId=$topicId";
    } else {
      var chatJid = appLaunchDetails?.mediaProgressChatJid ?? "";
      appLaunchDetails = null;
      return "${Routes.chat}?jid=$chatJid&from_notification=$didMediaProgressNotificationLaunchApp";
    }
  }
  if (!SessionManagement.adminBlocked()) {
    if (SessionManagement.getLogin()) {
      if (SessionManagement.getName().checkNull().isNotEmpty && SessionManagement.getMobileNumber().checkNull().isNotEmpty) {
        if (Constants.enableContactSync) {
          // LogMessage.d("nonChatUsers", nonChatUsers.toString());
          LogMessage.d("SessionManagement.isContactSyncDone()", SessionManagement.isContactSyncDone().toString());
          if (!SessionManagement.isContactSyncDone() /*|| nonChatUsers.isEmpty*/) {
            return Routes.contactSync;
          } else {
            return "${Routes.dashboard}?fromMissedCall=$didMissedCallNotificationLaunchApp";
          }
        } else {
          LogMessage.d("SessionManagement.getLogin()", "${SessionManagement.getLogin()}");
          return "${Routes.dashboard}?fromMissedCall=$didMissedCallNotificationLaunchApp";
        }
      } else {
        return Routes.profile;
      }
    } else {
      return Routes.login;
    }
  } else {
    return Routes.adminBlocked;
  }
}
