// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';


import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/data/session_management.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';
import 'package:mirror_fly_demo/app/model/chat_message_model.dart';

import '../common/constants.dart';
import '../common/notification_service.dart';
import '../modules/notification/notification_builder.dart';
import '../routes/app_pages.dart';

class PushNotifications {
  PushNotifications._();
  // static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static void init(){
    debugPrint("#Mirrorfly Notification -> init method");
    notificationPermission();

    FirebaseMessaging.onMessage.listen((message){
      debugPrint('#Mirrorfly Notification -> Got a message whilst in the foreground!');
      // onMessage(message);
    });
  }
  /// Create a [AndroidNotificationChannel] for heads up notifications
  // late AndroidNotificationChannel channel;

  static bool isFlutterLocalNotificationsInitialized = false;
  static Future<void> setupFlutterNotifications() async {
    if (isFlutterLocalNotificationsInitialized) {
      return;
    }
    /*channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
      'This channel is used for important notifications.', // description
      importance: Importance.high,
    );*/

    // flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    /*await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);*/

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    isFlutterLocalNotificationsInitialized = true;
  }
  static void getToken(){
    FirebaseMessaging.instance.getToken().then((value) {
      if(value!=null) {
        mirrorFlyLog("firebase_token", value);
        debugPrint("#Mirrorfly Notification -> firebase_token_1 $value");
        SessionManagement.setToken(value);
        Mirrorfly.updateFcmToken(firebaseToken: value, flyCallBack: (FlyResponse response) {
          LogMessage.d("updateFcmToken", response.isSuccess);
        });
      }
    }).catchError((er){
      mirrorFlyLog("FirebaseMessaging", er.toString());
    });
    FirebaseMessaging.instance.onTokenRefresh
        .listen((fcmToken) {
      mirrorFlyLog("onTokenRefresh", fcmToken.toString());
      SessionManagement.setToken(fcmToken);
      Mirrorfly.updateFcmToken(firebaseToken: fcmToken, flyCallBack: (FlyResponse response) {
        LogMessage.d("updateFcmToken", response.isSuccess);
      });
    }).onError((err) {
      // Error getting token.
      mirrorFlyLog("onTokenRefresh", err.toString());
    });
  }
  static void initInfo(){
    NotificationService().init();
    /*var androidInitialize = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitialize = const DarwinInitializationSettings();
    var initalizationSettings = InitializationSettings(android: androidInitialize,iOS: iosInitialize);
    flutterLocalNotificationsPlugin.initialize(initalizationSettings,onDidReceiveNotificationResponse: (NotificationResponse response){
      mirrorFlyLog("notificationresposne", response.payload.toString());
      try {
        if (response.payload != null && response.payload!.isNotEmpty) {
          //on notification click
        }
      }catch(e){
        mirrorFlyLog("error", e.toString());
        return;
      }
    });*/
  }
  // It is assumed that all messages contain a data field with the key 'type'
  static Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    debugPrint("#Mirrorfly Notification setupInteractedMessage $initialMessage");
    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      debugPrint("#Mirrorfly Notification setupInteractedMessage message opened from notification click terminated");
      // onMessage(initialMessage);
      debugPrint("#Mirrorfly Notification message received for ${initialMessage.data["to_user"]}");
      debugPrint("#Mirrorfly Notification message received for ${initialMessage.data}");
      Get.offAllNamed("${AppPages.chat}?jid=${initialMessage.data["from_user"]}&from_notification=true");
    }else{
      debugPrint("#Mirrorfly Notification setupInteractedMessage else");
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message){
      debugPrint("#Mirrorfly Notification message opened from notification click background");
      Get.offAllNamed("${AppPages.chat}?jid=${message.data["from_user"]}&from_notification=true");

    });
  }

  static void onMessage(RemoteMessage message) {
    debugPrint('#Mirrorfly Notification ->  RemoteMessage ${message.toMap()}');
    debugPrint('#Mirrorfly Notification ->  Message data: ${message.data}');
    if (message.notification != null) {
      debugPrint('#Mirrorfly Notification ->  Message also contained a notification: ${message.notification}');
    }
    // If `onMessage` is triggered with a notification, construct our own
    // local notification to show to users using the created channel.
    showNotification(message);
  }

  static void notificationPermission() async{
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    if(Platform.isAndroid) {
      var permission = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()!.requestPermission();
      debugPrint("permission :$permission");
    }
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('#Mirrorfly Notification -> User granted permission');
      getToken();
      initInfo();
      SessionManagement.setBool(Constants.notificationPermissionAsked, true);
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint('#Mirrorfly Notification -> User granted provisional permission');
      getToken();
      initInfo();
      SessionManagement.setBool(Constants.notificationPermissionAsked, true);
    } else {
      debugPrint('User declined or has not accepted permission');
      SessionManagement.setBool(Constants.notificationPermissionAsked, true);
    }
  }

  static void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    // display a dialog with the notification details, tap ok to go to another page

  }

  static void showNotification(RemoteMessage remoteMessage) {
    var notificationData = remoteMessage.data;
    if(!remoteMessage.data.containsKey("message_id")){
      notificationData["message_id"]=remoteMessage.messageId;
    }
    if(notificationData.isNotEmpty && Platform.isAndroid) {
      WidgetsFlutterBinding.ensureInitialized();
      Mirrorfly.handleReceivedMessage(notificationData: notificationData, flyCallBack: (FlyResponse response) {
          mirrorFlyLog("#Mirrorfly Notification -> notification message", response.toString());
        if(response.isSuccess && response.hasData){
          var data = sendMessageModelFromJson(response.data);
          if(data.messageId.isNotEmpty) {
            NotificationBuilder.createNotification(data,autoCancel: false);
          }
        }
      });
    }
  }
}