// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class PushNotifications {
  PushNotifications._();
  // static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static void init(){
    // notificationPermission();
    getToken();
    // initInfo();
    // FirebaseMessaging.onMessage.listen((message){
    //   debugPrint('Got a message whilst in the foreground!');
    //   onMessage(message);
    // });
  }
  static void getToken(){
    // FirebaseMessaging.instance.getToken().then((value) {
    //   if(value!=null) {
    //     mirrorFlyLog("firebase_token", value);
    //     SessionManagement.setToken(value);
    //   }
    // }).catchError((er){
    //   mirrorFlyLog("FirebaseMessaging", er.toString());
    // });
  }
  // static void initInfo(){
  //   var androidInitialize = const AndroidInitializationSettings('@mipmap/ic_launcher');
  //   var iosInitialize = const DarwinInitializationSettings();
  //   var initalizationSettings = InitializationSettings(android: androidInitialize,iOS: iosInitialize);
  //   flutterLocalNotificationsPlugin.initialize(initalizationSettings,onDidReceiveNotificationResponse: (NotificationResponse response){
  //     mirrorFlyLog("notificationresposne", response.payload.toString());
  //     try {
  //       if (response.payload != null && response.payload!.isNotEmpty) {
  //         //on notification click
  //       }
  //     }catch(e){
  //       mirrorFlyLog("error", e.toString());
  //       return;
  //     }
  //   });
  // }
  // It is assumed that all messages contain a data field with the key 'type'
  static Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    // RemoteMessage? initialMessage =
    // await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    // if (initialMessage != null) {
    //   onMessage(initialMessage);
    // }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    // FirebaseMessaging.onMessageOpenedApp.listen(onMessage);
  }

  // static Future<void> onMessage(RemoteMessage message) async {
  //   debugPrint('RemoteMessage ${message.data}');
  //   debugPrint('Message data: ${message.data}');
  //   if (message.notification != null) {
  //     debugPrint('Message also contained a notification: ${message.notification}');
  //   }
  //   // If `onMessage` is triggered with a notification, construct our own
  //   // local notification to show to users using the created channel.
  //   showNotification(message);
  // }

  // static void notificationPermission() async{
  //   FirebaseMessaging messaging = FirebaseMessaging.instance;
  //  var permission = await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
  //       AndroidFlutterLocalNotificationsPlugin>()!.requestPermission();
  //   NotificationSettings settings = await messaging.requestPermission(
  //     alert: true,
  //     announcement: false,
  //     badge: true,
  //     carPlay: false,
  //     criticalAlert: false,
  //     provisional: false,
  //     sound: true,
  //   );
  //
  //   if (settings.authorizationStatus == AuthorizationStatus.authorized) {
  //     debugPrint('User granted permission');
  //   } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
  //     debugPrint('User granted provisional permission');
  //   } else {
  //     debugPrint('User declined or has not accepted permission');
  //   }
  //   debugPrint("permission :$permission");
  // }

  static void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    // display a dialog with the notification details, tap ok to go to another page

  }

  // static void showNotification(RemoteMessage remoteMessage) async {
  //   /*Map<String,String> data = {};
  //   data["message_id"]="40e6e723-b4fc-469f-a072-0afe1d797a47";
  //   data["message_time"]="1669639607745126";
  //   data["to_jid"]="9638527410@xmpp-uikit-dev.contus.us";
  //   data["user_jid"]="919894940560@xmpp-uikit-dev.contus.us";
  //   data["message_content"]="Text";
  //   data["push_from"]="MirrorFly";
  //   data["type"]="text";
  //   data["title"]="Text";
  //   data["sent_from"]="919894940560@xmpp-uikit-dev.contus.us";
  //   data["chat_type"]="chat";
  //   var notificationData = data;*/
  //   var notificationData = remoteMessage.data;
  //   if(notificationData.isNotEmpty) {
  //     WidgetsFlutterBinding.ensureInitialized();
  //     //await const MethodChannel('handleReceivedMessage').invokeMethod("handleReceivedMessage",notificationData).then((value){
  //       //mirrorFlyLog("notification message", value.toString());
  //       /*var data = json.decode(value.toString());
  //       var groupJid = data["groupJid"].toString();
  //       var titleContent = data["titleContent"].toString();
  //       var chatMessage = data["chatMessage"].toString();
  //       var cancel = data["cancel"].toString();*/
  //       /* var channel = AndroidNotificationChannel("id", "name", description: "");
  //       var bigtextstyleinfo = BigTextStyleInformation(
  //           message.body.toString(), htmlFormatBigText: true,
  //           contentTitle: message.title,
  //           htmlFormatContentTitle: true);
  //       var androidnotificationdetails = AndroidNotificationDetails(
  //           channel.id, channel.name, channelDescription: channel.description,
  //           importance: Importance.high,
  //           styleInformation: bigtextstyleinfo,
  //           priority: Priority.high,
  //           playSound: true);
  //       var notificationDetails = NotificationDetails(
  //           android: androidnotificationdetails,
  //           iOS: const DarwinNotificationDetails());
  //       await flutterLocalNotificationsPlugin
  //           .resolvePlatformSpecificImplementation<
  //           AndroidFlutterLocalNotificationsPlugin>()
  //           ?.createNotificationChannel(
  //           channel);
  //       await flutterLocalNotificationsPlugin.show(
  //           0, message.title, message.body, notificationDetails,
  //           payload: "chatpage");*/
  //     //});
  //   }
  // }
}