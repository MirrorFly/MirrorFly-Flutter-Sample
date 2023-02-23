import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/base_controller.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/common/received_notification.dart';
import 'package:mirror_fly_demo/app/data/pushnotification.dart';
import 'package:mirror_fly_demo/app/data/session_management.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/modules/chat/controllers/chat_controller.dart';
import 'package:mirror_fly_demo/app/routes/app_pages.dart';

import 'package:flysdk/flysdk.dart';

import '../modules/chatInfo/controllers/chat_info_controller.dart';
import 'notification_service.dart';

class MainController extends GetxController with BaseController
    /*with FullLifeCycleMixin */{
  var authToken = "".obs;
  Rx<String> uploadEndpoint = "".obs;
  var maxDuration = 100.obs;
  var currentPos = 0.obs;
  var isPlaying = false.obs;
  var audioPlayed = false.obs;
  AudioPlayer player = AudioPlayer();
  String currentPostLabel = "00:00";
  bool _notificationsEnabled = false;
  //network listener
  static StreamSubscription<InternetConnectionStatus>? listener;

  @override
  Future<void> onInit() async {
    super.onInit();
    PushNotifications.init();
    initListeners();
    getMediaEndpoint();
    uploadEndpoint(SessionManagement.getMediaEndPoint().checkNull());
    authToken(SessionManagement.getAuthToken().checkNull());
    getAuthToken();
    startNetworkListen();

    NotificationService notificationService = NotificationService();
    await notificationService.init();
    _isAndroidPermissionGranted();
    _requestPermissions();
    _configureDidReceiveLocalNotificationSubject();
    _configureSelectNotificationSubject();
  }


  Future<void> _isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      final bool granted = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.areNotificationsEnabled() ??
          false;

      // setState(() {
        _notificationsEnabled = granted;
        debugPrint("Notification Enabled--> $_notificationsEnabled");
      // });
    }
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      final bool? granted = await androidImplementation?.requestPermission();
      // setState(() {
        _notificationsEnabled = granted ?? false;
      // });
    }
  }

  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationStream.stream
        .listen((ReceivedNotification receivedNotification) async {
      await showDialog(
        context: Get.context!,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title!)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body!)
              : null,
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () async {

              },
              child: const Text('Ok'),
            )
          ],
        ),
      );
    });
  }

  void _configureSelectNotificationSubject() {
    selectNotificationStream.stream.listen((String? payload) async {
      // await Navigator.of(context).push(MaterialPageRoute<void>(
      //   builder: (BuildContext context) => SecondPage(payload),
      // ));
      debugPrint("opening chat page--> $payload");
      if(payload != null && payload.isNotEmpty){

        if (Get.isRegistered<ChatController>()) {
          FlyChat.getProfileDetails(payload, false).then((value) {
            if (value != null) {
              debugPrint("notification group info controller");
              var profile = profiledata(value.toString());
              // Get.toNamed(Routes.chat, arguments: profile);
              Get.back(result: profile);
            }
          });
        }else {
          Get.toNamed(Routes.chat,
              parameters: {'isFromStarred': 'true', "userJid": payload});
        }
      }
    });
  }

  @override
  void dispose() {
    didReceiveLocalNotificationStream.close();
    selectNotificationStream.close();
    super.dispose();
  }


  getMediaEndpoint() async {
    if (SessionManagement
        .getMediaEndPoint()
        .checkNull()
        .isEmpty) {
      FlyChat.mediaEndPoint().then((value) {
        mirrorFlyLog("media_endpoint", value.toString());
        if(value!=null) {
          if (value.isNotEmpty) {
            uploadEndpoint(value);
            SessionManagement.setMediaEndPoint(value);
          } else {
            uploadEndpoint(SessionManagement.getMediaEndPoint().checkNull());
          }
        }
      });
    }
  }

  getAuthToken() async {
    if (SessionManagement
        .getUsername()
        .checkNull()
        .isNotEmpty &&
        SessionManagement
            .getPassword()
            .checkNull()
            .isNotEmpty) {
      await FlyChat.authToken().then((value) {
        mirrorFlyLog("RetryAuth", value.toString());
        if(value!=null) {
          if (value.isNotEmpty) {
            authToken(value);
            SessionManagement.setAuthToken(value);
          } else {
            authToken(SessionManagement.getAuthToken().checkNull());
          }
          update();
        }
      });
    }
  }

  handleAdminBlockedUser(String jid, bool status){
    if(SessionManagement.getUserJID().checkNull()==jid){
      if(status) {
        //show Admin Blocked Activity
        SessionManagement.setAdminBlocked(status);
        Get.toNamed(Routes.adminBlocked);
      }
    }
  }

  handleAdminBlockedUserFromRegister(){

  }

  void startNetworkListen() {
    final InternetConnectionChecker customInstance =
    InternetConnectionChecker.createInstance(
      checkTimeout: const Duration(seconds: 1),
      checkInterval: const Duration(seconds: 1),

    );
    listener = customInstance.onStatusChange.listen(
          (InternetConnectionStatus status) {
        switch (status) {
          case InternetConnectionStatus.connected:
            mirrorFlyLog("network",'Data connection is available.');
            if (Get.isRegistered<ChatController>()) {
              Get.find<ChatController>().networkConnected();
            }
            if (Get.isRegistered<ChatInfoController>()) {
              Get.find<ChatInfoController>().networkConnected();
            }
            break;
          case InternetConnectionStatus.disconnected:
            mirrorFlyLog("network",'You are disconnected from the internet.');
            if (Get.isRegistered<ChatController>()) {
              Get.find<ChatController>().networkDisconnected();
            }
            if (Get.isRegistered<ChatInfoController>()) {
              Get.find<ChatInfoController>().networkDisconnected();
            }
            break;
        }
      },
    );
  }

  @override
  void onClose() {
    listener?.cancel();
    super.onClose();
  }


}
