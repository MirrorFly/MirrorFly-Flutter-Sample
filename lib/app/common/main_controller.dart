import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badge/flutter_app_badge.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:is_lock_screen2/is_lock_screen2.dart';
// import 'package:is_lock_screen/is_lock_screen.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';
import 'package:permission_handler/permission_handler.dart';

import '../base_controller.dart';
import '../common/constants.dart';
import '../data/pushnotification.dart';
import '../data/session_management.dart';
import '../data/utils.dart';
import '../extensions/extensions.dart';
import '../model/arguments.dart';
import '../modules/archived_chats/archived_chat_list_controller.dart';
import '../modules/dashboard/controllers/dashboard_controller.dart';
import '../modules/notification/notification_builder.dart';
import '../routes/route_settings.dart';
import 'notification_service.dart';

class MainController extends FullLifeCycleController with FullLifeCycleMixin /*with FullLifeCycleMixin */ {
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
    BaseController.initListeners();
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

      _notificationsEnabled = granted;
      debugPrint("Notification Enabled--> $_notificationsEnabled");
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

      final bool? granted = await androidImplementation?.requestNotificationsPermission();
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
        if(SessionManagement.getCurrentChatJID().checkNull() == chatJid){
          NotificationBuilder.cancelNotifications();
         return;
        }
        if (NavUtils.isOverlayOpen || NavUtils.currentRoute == Routes.chat) {
          LogMessage.d("#Mirrorfly Notification ->","already chat page");
          if (NavUtils.currentRoute == Routes.forwardChat ||
              NavUtils.currentRoute == Routes.chatInfo ||
              NavUtils.currentRoute == Routes.groupInfo ||
              NavUtils.currentRoute == Routes.messageInfo) {
            NavUtils.back();
          }
          if (NavUtils.currentRoute.contains("from_notification=true")) {
            LogMessage.d("#Mirrorfly Notification -> previously app opened from notification", "so we have to maintain that");
            NavUtils.offAllNamed(Routes.chat,arguments: ChatViewArguments(chatJid: chatJid,topicId: topicId,didNotificationLaunchApp: true));
            // NavUtils.offAllNamed("${Routes.chat}?jid=$chatJid&from_notification=true&topicId=$topicId");
          } else {
            if(NavUtils.isOverlayOpen){
              LogMessage.d("#Mirrorfly Notification ->" , "isOverlayOpen dismissing");

              NavUtils.back();
            }
            LogMessage.d("#Mirrorfly Notification ->" , "Calling off named");


            NavUtils.offNamed(Routes.chat, arguments: ChatViewArguments(chatJid: chatJid,topicId: topicId), preventDuplicates: false);
            // NavUtils.back();
            /*Below 400 milliseconds the controller is not deleted and creating the issue in the Scrolled Positioned list issue,
             so we are waiting for 500 considering Android Platform*/
           /* Future.delayed(const Duration(milliseconds: 500),(){
              NavUtils.toNamed(Routes.chat, arguments: ChatViewArguments(chatJid: chatJid,topicId: topicId));
            });*/
          }
        } else {
          debugPrint("not chat page");
          NavUtils.toNamed(Routes.chat, arguments: ChatViewArguments(chatJid: chatJid,topicId: topicId));
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
    final connectionChecker = InternetConnectionChecker();

    listener = connectionChecker.onStatusChange.listen(
      (InternetConnectionStatus status) {
        switch (status) {
          case InternetConnectionStatus.connected:
            LogMessage.d("network", 'Data connection is available.');
            networkConnected();
            break;
          case InternetConnectionStatus.disconnected:
            LogMessage.d("network", 'You are disconnected from the internet.');
            networkDisconnected();
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

  var hasPaused = false;
  @override
  void onPaused() async {
    hasPaused = true;
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
    if(hasPaused) {
      hasPaused = false;
      if (Constants.enableContactSync) {
        syncContacts();
      }
      unreadMissedCallCount();
    }
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
          BaseController.onContactSyncComplete(true);
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
    try {
      var unreadMissedCallCount = await Mirrorfly.getUnreadMissedCallCount();
      unreadCallCount.value = unreadMissedCallCount ?? 0;
      debugPrint("unreadMissedCallCount $unreadMissedCallCount");
    }catch(e){
      debugPrint("unreadMissedCallCount $e");
    }
  }

  void _setBadgeCount(int count) {
    FlutterAppBadge.count(count);
  }

  void _removeBadge() {
    FlutterAppBadge.count(0);
  }

  void onMessageDeleteNotifyUI({required String chatJid, bool changePosition = true}) {
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().updateRecentChat(jid: chatJid, changePosition: changePosition);
    }
  }

  void onUpdateLastMessageUI(String chatJid){
    if (Get.isRegistered<ArchivedChatListController>()) {
      Get.find<ArchivedChatListController>().updateArchiveRecentChat(chatJid);
    }
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().updateRecentChat(jid: chatJid, newInsertable: true);
    }
  }

  void updateRecentChatListHistory(){
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().getRecentChatList();
    }
  }

  void clearAllConvRecentChatUI() {
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().getRecentChatList();
    }
  }

  void markConversationReadNotifyUI(String jid) {
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().markConversationReadNotifyUI(jid);
    }
  }
}
