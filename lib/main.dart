import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_in_app_pip/flutter_in_app_pip.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mirror_fly_demo/app/modules/backup_restore/views/restore_view.dart';
import 'app/call_modules/ongoing_call/ongoingcall_view.dart';
import 'app/common/app_localizations.dart';
import 'app/modules/chat/views/chat_view.dart';
import 'app/modules/dashboard/views/dashboard_view.dart';
import 'app/modules/login/views/login_view.dart';
import 'app/modules/notification/notification_builder.dart';
import 'app/modules/profile/views/profile_view.dart';
import 'app/modules/settings/views/app_lock/pin_view.dart';
import 'app/routes/mirrorfly_navigation_observer.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import 'package:get/get.dart';
import 'app/common/app_theme.dart';
import 'app/common/constants.dart';
import 'app/extensions/extensions.dart';
import 'app/data/pushnotification.dart';
import 'app/common/main_controller.dart';
import 'app/common/notification_service.dart';
import 'app/data/session_management.dart';
import 'app/model/arguments.dart';
import 'app/model/reply_hash_map.dart';

import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'app/routes/route_settings.dart';

final navigatorKey = GlobalKey<NavigatorState>();


/*@pragma('vm:entry-point')
Future<void> pipMain() async {
  debugPrint("vm:entry-point : pipMain");
  WidgetsFlutterBinding.ensureInitialized();
  await SessionManagement.onInit();
  if (!kIsWeb) {
    await Firebase.initializeApp();
  }
  Get.put<MainController>(MainController());
  // final PiPStatusInfo? result = await FlPiP().isActive;
  // debugPrint(" FlPiP().isActive : ${result?.isCreateNewEngine}");
  runApp(ClipRRect(
    borderRadius: const BorderRadius.all(Radius.circular(13)),
    child: MaterialApp(
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
      navigatorObservers: [
        MirrorFlyNavigationObserver()
      ],
      home: PIPView(style: AppStyleConfig.ongoingCallPageStyle.pipViewStyle,),
    ),
  ));
  // main();
}*/


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

/// check app opened from notification
NotificationAppLaunchDetails? notificationAppLaunchDetails;

MirrorflyNotificationAppLaunchDetails? appLaunchDetails;

/// check is on going call
bool isOnGoingCall = false;

late ChatViewArguments chatViewArg;
late DashboardViewArguments dashboardViewArg;
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
  initializeSDK(Constants.useDeprecatedInit,builder: Constants.chatBuilder);
}

Future<void> initializeSDK(bool useOld, {required ChatBuilder builder}) async {
  if(useOld) {
    if(builder.domainBaseUrl.isEmpty || builder.licenseKey.isEmpty){
      throw(Exception("base url and licenseKey must need for use old method"));
    }
    await Mirrorfly.init(baseUrl: builder.domainBaseUrl,
        licenseKey: builder.licenseKey,
        iOSContainerID: builder.iOSContainerID,
        enableDebugLog: builder.enableDebugLog,
        enableMobileNumberLogin: builder.enableMobileNumberLogin,
        chatHistoryEnable: builder.chatHistoryEnable,
        storageFolderName: builder.storageFolderName,
        isTrialLicenceKey: builder.isTrialLicenceKey
    );

    /// check is on going call,
    /// When a call is received and disconnected before being attended,
    /// the VOIP push wakes the app, causing Mirrorfly.isOnGoingCall() to return true, and the value is stored.
    /// This leads to the call screen opening upon app launch, even though the SDK isn't reinitialized.
    /// This behavior is intended for redirecting to the ongoing call page after the app is terminated and reopened.
    /// However, on iOS, terminating the app disconnects the call, making this condition unnecessary. Therefore, it's set to false by default.

    isOnGoingCall = Platform.isAndroid ? (await Mirrorfly.isOnGoingCall()).checkNull() : false;

    ///
    /// This method will give response from Native Android, iOS will return empty by default.
    /// When the app is opened by clicking the notification. (Notification Types: Media Status update, MissedCall)
    /// This value will be set in Android Plugin side and response will be returned here.
    ///
    appLaunchDetails = await Mirrorfly.getAppLaunchedDetails();
    runApp(const MyApp());
  }else{
    if(builder.licenseKey.isEmpty){
      throw(Exception("licenseKey must need for use new method"));
    }
    Mirrorfly.initializeSDK(
        licenseKey: builder.licenseKey,
        iOSContainerID: builder.iOSContainerID,
        chatHistoryEnable: builder.chatHistoryEnable,
        enableDebugLog: builder.enableDebugLog,
        storageFolderName: builder.storageFolderName,
        enablePrivateStorage: Constants.enablePrivateStorage,
        enableMobileNumberLogin: builder.enableMobileNumberLogin,
        flyCallback: (response) async {
          if (response.isSuccess) {
            LogMessage.d("onSuccess", response.message);
            LogMessage.d("Mirrorfly.isPrivateStorageEnabled", Mirrorfly.isPrivateStorageEnabled.toString());
            Mirrorfly.isPrivateStorageEnabledOrNot().then((value) {
              LogMessage.d("Mirrorfly.isPrivateStorageEnabledOrNot", value.toString());
            });
          } else {
            LogMessage.d("onFailure", response.errorMessage.toString());
          }
          /// check is on going call,
          /// When a call is received and disconnected before being attended,
          /// the VOIP push wakes the app, causing Mirrorfly.isOnGoingCall() to return true, and the value is stored.
          /// This leads to the call screen opening upon app launch, even though the SDK isn't reinitialized.
          /// This behavior is intended for redirecting to the ongoing call page after the app is terminated and reopened.
          /// However, on iOS, terminating the app disconnects the call, making this condition unnecessary. Therefore, it's set to false by default.

          isOnGoingCall = Platform.isAndroid ? (await Mirrorfly.isOnGoingCall()).checkNull() : false;

          ///
          /// This method will give response from Native Android, iOS will return empty by default.
          /// When the app is opened by clicking the notification. (Notification Types: Media Status update, MissedCall)
          /// This value will be set in Android Plugin side and response will be returned here.
          ///
          appLaunchDetails = await Mirrorfly.getAppLaunchedDetails();
          runApp(const MyApp());
        });
  }
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
    return PiPMaterialApp(
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
      navigatorObservers: [
        MirrorFlyNavigationObserver()
      ],
      initialRoute: SessionManagement.getEnablePin() ? Routes.pin : getInitialRoute(),
      onGenerateInitialRoutes: (initialRoute) {
        switch (initialRoute){
          case Routes.login:
            return [MaterialPageRoute(
              settings: const RouteSettings(
                name: Routes.login,
              ),
              builder: (context) => const LoginView(),
            )];
          case Routes.pin:
            return [MaterialPageRoute(
              settings: const RouteSettings(
                name: Routes.pin, arguments: {"showBack": "false"}
              ),
              builder: (context) => const PinView(),
            )];
          case Routes.profile:
            return [MaterialPageRoute(
              settings: const RouteSettings(
                name: Routes.profile,
              ),
              builder: (context) => const ProfileView(),
            )];
          case Routes.restoreBackup:
            return [MaterialPageRoute(
              settings: const RouteSettings(
                name: Routes.restoreBackup,
              ),
              builder: (context) => const RestoreView(),
            )];
          case Routes.chat:
            return [MaterialPageRoute(
              settings: RouteSettings(
                name: Routes.chat,
                arguments: chatViewArg,
              ),
              builder: (context) => ChatView(),
            )];
          case Routes.dashboard:
            return [
              MaterialPageRoute(
                settings: RouteSettings(
                  name: Routes.dashboard,
                  arguments: dashboardViewArg,
                ),
                builder: (context) => const DashboardView(),
              )
            ];
          case Routes.onGoingCallView:
            return [
              MaterialPageRoute(
                settings: const RouteSettings(
                  name: Routes.onGoingCallView,
                ),
                builder: (context) => const OnGoingCallView(),
              )
            ];
          default:
            return [];
        }
      },
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
      chatViewArg = ChatViewArguments(chatJid: chatJid,topicId: topicId,didNotificationLaunchApp:didNotificationLaunchApp);
      // return "${Routes.chat}?jid=$chatJid&from_notification=$didNotificationLaunchApp&topicId=$topicId";
      return Routes.chat;
    } else {
      var chatJid = appLaunchDetails?.mediaProgressChatJid ?? "";
      appLaunchDetails = null;
      chatViewArg = ChatViewArguments(chatJid: chatJid,didNotificationLaunchApp:didMediaProgressNotificationLaunchApp);
      // return "${Routes.chat}?jid=$chatJid&from_notification=$didMediaProgressNotificationLaunchApp";
      return Routes.chat;
    }
  }
  if (!SessionManagement.adminBlocked()) {
    if (SessionManagement.getLogin()) {
      LogMessage.d("SessionManagement.getName()", SessionManagement.getName().toString());
      LogMessage.d("SessionManagement.getMobileNumber()", SessionManagement.getMobileNumber().toString());
      if (SessionManagement.getName().checkNull().isNotEmpty && SessionManagement.getMobileNumber().checkNull().isNotEmpty && (!Constants.isBackupFeatureEnabled || SessionManagement.getBackUpState().checkNull().isNotEmpty)) {
        if (Constants.enableContactSync) {
          // LogMessage.d("nonChatUsers", nonChatUsers.toString());
          LogMessage.d("SessionManagement.isContactSyncDone()", SessionManagement.isContactSyncDone().toString());
          if (!SessionManagement.isContactSyncDone() /*|| nonChatUsers.isEmpty*/) {
            return Routes.contactSync;
          } else {
            dashboardViewArg = DashboardViewArguments(didMissedCallNotificationLaunchApp: didMissedCallNotificationLaunchApp);
            // return "${Routes.dashboard}?fromMissedCall=$didMissedCallNotificationLaunchApp";
            return Routes.dashboard;
          }
        } else {
          LogMessage.d("SessionManagement.getLogin()", "${SessionManagement.getLogin()}");
          dashboardViewArg = DashboardViewArguments(didMissedCallNotificationLaunchApp: didMissedCallNotificationLaunchApp);
          // return "${Routes.dashboard}?fromMissedCall=$didMissedCallNotificationLaunchApp";
          return Routes.dashboard;
        }
      } else {

        if (Constants.isBackupFeatureEnabled && SessionManagement.getBackUpState().checkNull().isEmpty) {
          /// This condition handles the case where a number logs in and is redirected to the Chat Backup Page.
          /// If the app is closed before saving the backup state, reopening the app should show this to enter the backup state.
          return Routes.restoreBackup;
        }else if ((Constants.isBackupFeatureEnabled && SessionManagement.getBackUpState().checkNull().isNotEmpty) ||
            (!Constants.isBackupFeatureEnabled && SessionManagement.getBackUpState().checkNull().isEmpty)) {
          /// This condition handles the case where a new number logs in and is redirected to the Profile Page.
          /// If the app is closed before saving the profile, reopening the app would cause an error.
          /// This condition prevents that error from occurring.
          return Routes.profile;
        }else{
          SessionManagement.clear().then((value) {

          });
          return Routes.login;
        }
      }
    } else {
      return Routes.login;
    }
  } else {
    return Routes.adminBlocked;
  }
}