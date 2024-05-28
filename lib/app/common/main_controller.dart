import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:is_lock_screen/is_lock_screen.dart';
import 'package:mirror_fly_demo/app/base_controller.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/pushnotification.dart';
import 'package:mirror_fly_demo/app/data/session_management.dart';
import 'package:mirror_fly_demo/app/extensions/extensions.dart';
import 'package:mirror_fly_demo/app/modules/chat/controllers/chat_controller.dart';
import 'package:mirror_fly_demo/app/modules/contact_sync/controllers/contact_sync_controller.dart';
import 'package:mirror_fly_demo/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:mirror_fly_demo/app/modules/notification/notification_builder.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';
import 'package:permission_handler/permission_handler.dart';

import '../data/utils.dart';
import '../modules/chatInfo/controllers/chat_info_controller.dart';
import '../routes/route_settings.dart';
import 'notification_service.dart';

class MainController extends FullLifeCycleController with BaseController, FullLifeCycleMixin /*with FullLifeCycleMixin */ {
  var currentAuthToken = "".obs;
  var googleMapKey = "";
  Rx<String> mediaEndpoint = "".obs;
  var maxDuration = 100.obs;
  var currentPos = 0.obs;
  var isPlaying = false.obs;
  var audioPlayed = false.obs;
  AudioPlayer player = AudioPlayer();
  String currentPostLabel = "00:00";
  bool _notificationsEnabled = false;

  //network listener
  static StreamSubscription<InternetConnectionStatus>? listener;

  var availableFeature = AvailableFeatures().obs;

  final unreadCallCount = 0.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    /*Mirrorfly.isOnGoingCall().then((value){
      if(value.checkNull()){
        NavUtils.toNamed(Routes.onGoingCallView);
      }
    });*/
    Mirrorfly.getValueFromManifestOrInfoPlist(androidManifestKey: "com.google.android.geo.API_THUMP_KEY", iOSPlistKey: "API_THUMP_KEY").then((value) {
      googleMapKey = value;
      LogMessage.d("com.google.android.geo.API_THUMP_KEY", googleMapKey);
    });
    //presentPinPage();
    debugPrint("#Mirrorfly Notification -> Main Controller push init");
    PushNotifications.init();
    initListeners();
    mediaEndpoint(SessionManagement.getMediaEndPoint().checkNull());
    getMediaEndpoint();
    currentAuthToken(SessionManagement.getAuthToken().checkNull());
    getCurrentAuthToken();
    //getAuthToken();
    startNetworkListen();

    getAvailableFeatures();

    NotificationService notificationService = NotificationService();
    await notificationService.init();
    _isAndroidPermissionGranted();
    _requestPermissions();
    // _configureDidReceiveLocalNotificationSubject();
    _configureSelectNotificationSubject();
    unreadMissedCallCount();
    _removeBadge();
  }

  Future<void> _isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      final bool granted = await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
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
      await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      final bool? granted = await androidImplementation?.requestPermission();
      // setState(() {
      _notificationsEnabled = granted ?? false;
      // });
    }
  }

  void _configureSelectNotificationSubject() {
    selectNotificationStream.stream.listen((String? payload) async {
      // await Navigator.of(context).push(MaterialPageRoute<void>(
      //   builder: (BuildContext context) => SecondPage(payload),
      // ));
      LogMessage.d("#Mirrorfly Notification -> opening chat page--> ","$payload ${NavUtils.currentRoute}");
      if (payload != null && payload.isNotEmpty && payload.toString() != Constants.callNotificationId.toString()) {
        var chatJid = payload.checkNull().split(",")[0];
        var topicId = payload.checkNull().split(",")[1];
        if (Get.isRegistered<ChatController>()) {
          LogMessage.d("#Mirrorfly Notification ->","already chat page");
          if (NavUtils.currentRoute == Routes.forwardChat ||
              NavUtils.currentRoute == Routes.chatInfo ||
              NavUtils.currentRoute == Routes.groupInfo ||
              NavUtils.currentRoute == Routes.messageInfo) {
            NavUtils.back();
          }
          if (NavUtils.currentRoute.contains("from_notification=true")) {
            LogMessage.d("#Mirrorfly Notification -> previously app opened from notification", "so we have to maintain that");
            NavUtils.offAllNamed("${Routes.chat}?jid=$chatJid&from_notification=true&topicId=$topicId");
          } else {
            if(Get.isOverlaysOpen){
              NavUtils.back();
            }
            NavUtils.offNamed(Routes.chat, arguments: {"chatJid": chatJid, "topicId": topicId});
          }
        } else {
          debugPrint("not chat page");
          NavUtils.toNamed(Routes.chat, arguments: {"chatJid": chatJid, "topicId": topicId});
        }
      } else {
        if (Get.isRegistered<DashboardController>()) {
          Get.find<DashboardController>().tabController?.animateTo(1);
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
    await Mirrorfly.mediaEndPoint().then((value) {
      LogMessage.d("media_endpoint", value.toString());
      if (value != null) {
        if (value.isNotEmpty) {
          mediaEndpoint(value);
          SessionManagement.setMediaEndPoint(value);
        } else {
          mediaEndpoint(SessionManagement.getMediaEndPoint().checkNull());
        }
      }
    });
  }

  getCurrentAuthToken() async {
    await Mirrorfly.getCurrentAuthToken().then((value) {
      LogMessage.d("getCurrentAuthToken", value.toString());
      if (value.isNotEmpty) {
        currentAuthToken(value);
        SessionManagement.setAuthToken(value);
      } else {
        currentAuthToken(SessionManagement.getAuthToken().checkNull());
      }
    });
  }

  handleAdminBlockedUser(String jid, bool status) {
    if (SessionManagement.getUserJID().checkNull() == jid) {
      if (status) {
        //show Admin Blocked Activity
        SessionManagement.setAdminBlocked(status);
        NavUtils.toNamed(Routes.adminBlocked);
      }
    }
  }

  handleAdminBlockedUserFromRegister() {}

  void startNetworkListen() {
    final InternetConnectionChecker customInstance = InternetConnectionChecker.createInstance(
      checkTimeout: const Duration(seconds: 1),
      checkInterval: const Duration(seconds: 1),
    );
    listener = customInstance.onStatusChange.listen(
      (InternetConnectionStatus status) {
        switch (status) {
          case InternetConnectionStatus.connected:
            LogMessage.d("network", 'Data connection is available.');
            networkConnected();
            if (Get.isRegistered<ChatController>()) {
              Get.find<ChatController>().networkConnected();
            }
            if (Get.isRegistered<ChatInfoController>()) {
              Get.find<ChatInfoController>().networkConnected();
            }
            if (Get.isRegistered<ContactSyncController>()) {
              Get.find<ContactSyncController>().networkConnected();
            }
            break;
          case InternetConnectionStatus.disconnected:
            LogMessage.d("network", 'You are disconnected from the internet.');
            networkDisconnected();
            if (Get.isRegistered<ChatController>()) {
              Get.find<ChatController>().networkDisconnected();
            }
            if (Get.isRegistered<ChatInfoController>()) {
              Get.find<ChatInfoController>().networkDisconnected();
            }
            if (Get.isRegistered<ContactSyncController>()) {
              Get.find<ContactSyncController>().networkDisconnected();
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

  @override
  void onDetached() {
    LogMessage.d('LifeCycle', 'onDetached');
  }

  @override
  void onInactive() {
    LogMessage.d('LifeCycle', 'onInactive');
  }

  bool fromLockScreen = false;

  @override
  void onPaused() async {
    LogMessage.d('LifeCycle', 'onPaused');
    var unReadMessageCount = await Mirrorfly.getUnreadMessageCountExceptMutedChat();
    debugPrint('mainController unReadMessageCount onPaused ${unReadMessageCount.toString()}');
    _setBadgeCount(unReadMessageCount ?? 0);
    fromLockScreen = await isLockScreen() ?? false;
    LogMessage.d('isLockScreen', '$fromLockScreen');
    SessionManagement.setAppSessionNow();
  }

  @override
  void onResumed() {
    LogMessage.d('LifeCycle', 'onResumed');
    NotificationBuilder.cancelNotifications();
    checkShouldShowPin();
    if (Constants.enableContactSync) {
      syncContacts();
    }
    unreadMissedCallCount();
  }

  void syncContacts() async {
    if(await Permission.contacts.isGranted) {
      if (await AppUtils.isNetConnected() &&
          !await Mirrorfly.contactSyncStateValue()) {
        final permission = await Permission.contacts.status;
        if (permission == PermissionStatus.granted) {
          if(SessionManagement.getLogin()) {
            Mirrorfly.syncContacts(isFirstTime: !SessionManagement.isInitialContactSyncDone(), flyCallBack: (_) {});
          }
        }
      }
    }else{
      if(SessionManagement.isInitialContactSyncDone()) {
        Mirrorfly.revokeContactSync(flyCallBack: (FlyResponse response) {
          onContactSyncComplete(true);
          LogMessage.d("checkContactPermission isSuccess", response.isSuccess.toString());
        });
      }
    }
  }

  void networkDisconnected() {}

  void networkConnected() {
    if (Constants.enableContactSync) {
      syncContacts();
    }
  }

  /*
  *This function used to check time out session for app lock
  */
  void checkShouldShowPin() {
    var lastSession = SessionManagement.appLastSession();
    var lastPinChangedAt = SessionManagement.lastPinChangedAt();
    var sessionDifference = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(lastSession,isUtc: true));
    var lockSessionDifference = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(lastPinChangedAt,isUtc: true));
    debugPrint('sessionDifference seconds ${sessionDifference.inSeconds}');
    debugPrint('lockSessionDifference days ${lockSessionDifference.inDays}');
    if (Constants.pinAlert <= lockSessionDifference.inDays && Constants.pinExpiry >= lockSessionDifference.inDays) {
      //Alert Day
      debugPrint('Alert Day');
    } else if (Constants.pinExpiry < lockSessionDifference.inDays) {
      //Already Expired day
      debugPrint('Already Expired');
      presentPinPage();
    } else {
      //if 30 days not completed
      debugPrint('Not Expired');
      if (Constants.sessionLockTime <= sessionDifference.inSeconds || fromLockScreen) {
        //Show Pin if App Lock Enabled
        debugPrint('Show Pin');
        presentPinPage();
      }
    }
    fromLockScreen = false;
  }

  void presentPinPage() {
    if ((SessionManagement.getEnablePin() || SessionManagement.getEnableBio()) && NavUtils.currentRoute != Routes.pin) {
      NavUtils.toNamed(
        Routes.pin,
      );
    }
  }

  void getAvailableFeatures() {
    Mirrorfly.getAvailableFeatures().then((features) {
      debugPrint("getAvailableFeatures $features");
      var featureAvailable = availableFeaturesFromJson(features);
      availableFeature(featureAvailable);
    });
  }

  void onAvailableFeatures(AvailableFeatures features) {
    availableFeature(features);
  }

  @override
  void onHidden() {
    LogMessage.d('LifeCycle', 'onHidden');
  }

  unreadMissedCallCount() async {
    var unreadMissedCallCount = await Mirrorfly.getUnreadMissedCallCount();
    unreadCallCount.value = unreadMissedCallCount ?? 0;
    debugPrint("unreadMissedCallCount $unreadMissedCallCount");
  }

  void _setBadgeCount(int count) {
    FlutterAppBadger.updateBadgeCount(count);
  }

  void _removeBadge() {
    FlutterAppBadger.removeBadge();
  }
}
