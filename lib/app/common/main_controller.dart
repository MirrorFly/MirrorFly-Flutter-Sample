import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:fl_pip/fl_pip.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badge/flutter_app_badge.dart';
import 'package:flutter_in_app_pip/flutter_in_app_pip.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mirror_fly_demo/app/call_modules/pip_view/pip_view_controller.dart';
import 'package:mirror_fly_demo/app/common/de_bouncer.dart';
import 'package:mirror_fly_demo/app/data/permissions.dart';
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

class MainController extends FullLifeCycleController
    with FullLifeCycleMixin /*with FullLifeCycleMixin */ {
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

    //presentPinPage();
    debugPrint("#Mirrorfly Notification -> Main Controller push init");
    PushNotifications.init();
    BaseController.initListeners();

    startNetworkListen();
  }

  @override
  Future<void> onReady() async {
    super.onReady();

    debugPrint("#Mirrorfly Notification -> Main Controller push onResume");
    Mirrorfly.getValueFromManifestOrInfoPlist(
            androidManifestKey: "com.google.android.geo.API_THUMP_KEY",
            iOSPlistKey: "API_THUMP_KEY")
        .then((value) {
      googleMapKey = value;
      LogMessage.d("com.google.android.geo.API_THUMP_KEY", googleMapKey);
    }).catchError((e) {
      LogMessage.d("API_THUMP_KEY not found", e);
    });
    mediaEndpoint(SessionManagement.getMediaEndPoint().checkNull());
    getMediaEndpoint();
    currentAuthToken(SessionManagement.getAuthToken().checkNull());
    getCurrentAuthToken();
    //getAuthToken();

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
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.areNotificationsEnabled() ??
          false;

      _notificationsEnabled = granted;
      debugPrint("Notification Enabled--> $_notificationsEnabled");
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
    } else if (Platform.isAndroid &&
        !(await Permission.notification.status.isGranted)) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? granted =
          await androidImplementation?.requestNotificationsPermission();
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
      LogMessage.d("#Mirrorfly Notification -> opening chat page--> ",
          "$payload ${NavUtils.currentRoute}");
      if (payload != null &&
          payload.isNotEmpty &&
          payload.toString() != Constants.callNotificationId.toString()) {
        var chatJid = payload.checkNull().split(",")[0];
        var topicId = payload.checkNull().split(",")[1];
        if (SessionManagement.getCurrentChatJID().checkNull() == chatJid) {
          NotificationBuilder.cancelNotifications();
          return;
        }
        if (NavUtils.isOverlayOpen || NavUtils.currentRoute == Routes.chat) {
          LogMessage.d("#Mirrorfly Notification ->", "already chat page");
          if (NavUtils.currentRoute == Routes.forwardChat ||
              NavUtils.currentRoute == Routes.chatInfo ||
              NavUtils.currentRoute == Routes.groupInfo ||
              NavUtils.currentRoute == Routes.messageInfo) {
            NavUtils.back();
          }
          if (NavUtils.currentRoute.contains("from_notification=true")) {
            LogMessage.d(
                "#Mirrorfly Notification -> previously app opened from notification",
                "so we have to maintain that");
            NavUtils.offAllNamed(Routes.chat,
                arguments: ChatViewArguments(
                    chatJid: chatJid,
                    topicId: topicId,
                    didNotificationLaunchApp: true));
            // NavUtils.offAllNamed("${Routes.chat}?jid=$chatJid&from_notification=true&topicId=$topicId");
          } else {
            if (NavUtils.isOverlayOpen) {
              LogMessage.d(
                  "#Mirrorfly Notification ->", "isOverlayOpen dismissing");

              NavUtils.back();
            }
            LogMessage.d("#Mirrorfly Notification ->", "Calling off named");

            NavUtils.offNamed(Routes.chat,
                arguments:
                    ChatViewArguments(chatJid: chatJid, topicId: topicId),
                preventDuplicates: false);
            // NavUtils.back();
            /*Below 400 milliseconds the controller is not deleted and creating the issue in the Scrolled Positioned list issue,
             so we are waiting for 500 considering Android Platform*/
            /* Future.delayed(const Duration(milliseconds: 500),(){
              NavUtils.toNamed(Routes.chat, arguments: ChatViewArguments(chatJid: chatJid,topicId: topicId));
            });*/
          }
        } else {
          debugPrint("not chat page");
          if (NavUtils.currentRoute == Routes.forwardChat ||
              NavUtils.currentRoute == Routes.chatInfo ||
              NavUtils.currentRoute == Routes.groupInfo ||
              NavUtils.currentRoute == Routes.messageInfo) {
            debugPrint("chat info page");
            NavUtils.popUntil((route) => !(route.navigator?.canPop() ?? false));
            Future.delayed(const Duration(milliseconds: 500), () {
              NavUtils.toNamed(Routes.chat,
                  arguments:
                      ChatViewArguments(chatJid: chatJid, topicId: topicId));
            });
          } else {
            NavUtils.toNamed(Routes.chat,
                arguments:
                    ChatViewArguments(chatJid: chatJid, topicId: topicId));
          }
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

  final deBouncer = DeBouncer(milliseconds: 600);

  @override
  void onInactive() {
    LogMessage.d('LifeCycle', 'onInactive');
    // deBouncerncer.cancel();
    // deBouncer.run((){
    //   goingInActive();
    // });
    goingInActive();
    // enterOrExitPIPMode();
  }

  void enterOrExitPIPMode() async {
    LogMessage.d("PIPView",
        "hasHidden : $hasHidden , AppPermission.isShowing ${AppPermission.isShowing}");
    if (Platform.isAndroid && !hasHidden && !AppPermission.isShowing) {
      LogMessage.d("PIPView", PictureInPicture.isActive);
      if ((await Mirrorfly.isOnGoingCall()).checkNull() &&
          PictureInPicture.isActive) {
        LogMessage.d(
            "PIPView", "stopPiP ${NavUtils.currentRoute} toNamed pipView");
        FlPiP()
            .enable(
                ios: const FlPiPiOSConfig(),
                android: const FlPiPAndroidConfig())
            .then((onValue) {
          if (onValue) {
            PictureInPicture.stopPiP();
            NavUtils.toNamed(Routes.pipView);
          }
        });
      } else if (NavUtils.currentRoute == Routes.onGoingCallView) {
        LogMessage.d("PIPView", "offNamed ${NavUtils.currentRoute} to pipView");
        FlPiP()
            .enable(
                ios: const FlPiPiOSConfig(),
                android: const FlPiPAndroidConfig())
            .then((onValue) {
          LogMessage.d("PIPView", " FlPiP enable $onValue");
          if (onValue) {
            NavUtils.offNamed(Routes.pipView);
          }
        });
      }
    }
  }

  Future<void> updatePIPView() async {
    if (Platform.isAndroid) {
      LogMessage.d("PIPView", NavUtils.currentRoute);
      if (NavUtils.currentRoute == Routes.pipView) {
        if ((await Mirrorfly.isOnGoingCall()).checkNull()) {
          LogMessage.d("PIPView", "offNamed onGoingCallView");
          NavUtils.offNamed(Routes.onGoingCallView);
        } else {
          //Assume call ended so closing the pip view
          LogMessage.d(
              "PIPView", "Assuming call ended so closing the pip view");
          NavUtils.back();
        }
      }
    }
  }

  bool fromLockScreen = false;

  var hasPaused = false;

  @override
  void onPaused() async {
    hasPaused = true;
    LogMessage.d('LifeCycle', 'onPaused');
    fromLockScreen = await Mirrorfly.isLockScreen();
    var unReadMessageCount =
        await Mirrorfly.getUnreadMessageCountExceptMutedChat();
    debugPrint(
        'mainController unReadMessageCount onPaused ${unReadMessageCount.toString()}');
    _setBadgeCount(unReadMessageCount ?? 0);
    fromLockScreen = await Mirrorfly.isLockScreen();
    LogMessage.d('isLockScreen', '$fromLockScreen');
    SessionManagement.setAppSessionNow();
  }

  // While going Background
  // onInactive
  // onHidden
  // onPaused

  // While going Foreground
  // onHidden
  // onInactive
  // onResumed

  // While going Notification drawer
  // onInactive

  // While back from Notification drawer
  // onResumed

  // While Call Received
  // onInactive
  // onHidden
  // onPaused

  // After Accepted the call
  // onHidden
  // onInactive
  // onResumed
  // onInactive
  // onResumed
  // onInactive
  // onResumed

  @override
  void onResumed() {
    hasHidden = false;
    _leaveHintTimer?.cancel();
    isUserLeavingApp = false;
    LogMessage.d('LifeCycle', 'onResumed');
    NotificationBuilder.cancelNotifications();
    if (hasPaused) {
      hasPaused = false;
      checkShouldShowPin();
      if (Constants.enableContactSync) {
        syncContacts();
      }
      unreadMissedCallCount();
    }
    // enterOrExitPIPMode();
    updatePIPView();
  }

  void syncContacts() async {
    if (await Permission.contacts.isGranted) {
      if (await AppUtils.isNetConnected() &&
          !await Mirrorfly.contactSyncStateValue()) {
        final permission = await Permission.contacts.status;
        if (permission == PermissionStatus.granted) {
          if (SessionManagement.getLogin()) {
            Mirrorfly.syncContacts(
                isFirstTime: !SessionManagement.isInitialContactSyncDone(),
                flyCallBack: (_) {});
          }
        }
      }
    } else {
      if (SessionManagement.isInitialContactSyncDone()) {
        Mirrorfly.revokeContactSync(flyCallBack: (FlyResponse response) {
          BaseController.onContactSyncComplete(true);
          LogMessage.d("checkContactPermission isSuccess",
              response.isSuccess.toString());
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
    var sessionDifference = DateTime.now().difference(
        DateTime.fromMillisecondsSinceEpoch(lastSession, isUtc: true));
    var lockSessionDifference = DateTime.now().difference(
        DateTime.fromMillisecondsSinceEpoch(lastPinChangedAt, isUtc: true));
    debugPrint('sessionDifference seconds ${sessionDifference.inSeconds}');
    debugPrint('lockSessionDifference days ${lockSessionDifference.inDays}');
    if (Constants.pinAlert <= lockSessionDifference.inDays &&
        Constants.pinExpiry >= lockSessionDifference.inDays) {
      //Alert Day
      debugPrint('Alert Day');
    } else if (Constants.pinExpiry < lockSessionDifference.inDays) {
      //Already Expired day
      debugPrint('Already Expired');
      presentPinPage();
    } else {
      //if 30 days not completed
      debugPrint('Not Expired');
      if (Constants.sessionLockTime <= sessionDifference.inSeconds ||
          fromLockScreen) {
        //Show Pin if App Lock Enabled
        debugPrint('Show Pin');
        presentPinPage();
      }
    }
    fromLockScreen = false;
  }

  void presentPinPage() {
    if ((SessionManagement.getEnablePin() ||
            SessionManagement.getEnableBio()) &&
        NavUtils.currentRoute != Routes.pin) {
      NavUtils.toNamed(Routes.pin, arguments: {"showBack": "false"});
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

  var hasHidden = false;

  @override
  void onHidden() {
    LogMessage.d('LifeCycle', 'onHidden');
    hasHidden = true;
  }

  unreadMissedCallCount() async {
    try {
      var unreadMissedCallCount = await Mirrorfly.getUnreadMissedCallCount();
      unreadCallCount.value = unreadMissedCallCount ?? 0;
      debugPrint("unreadMissedCallCount $unreadMissedCallCount");
    } catch (e) {
      debugPrint("unreadMissedCallCount $e");
    }
  }

  void _setBadgeCount(int count) {
    FlutterAppBadge.count(count);
  }

  void _removeBadge() {
    FlutterAppBadge.count(0);
  }

  void onMessageDeleteNotifyUI(
      {required String chatJid, bool changePosition = true}) {
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>()
          .updateRecentChat(jid: chatJid, changePosition: changePosition);
    }
  }

  void onUpdateLastMessageUI(String chatJid) {
    if (Get.isRegistered<ArchivedChatListController>()) {
      Get.find<ArchivedChatListController>().updateArchiveRecentChat(chatJid);
    }
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>()
          .updateRecentChat(jid: chatJid, newInsertable: true);
    }
  }

  void updateRecentChatListHistory() {
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

  Timer? _leaveHintTimer;
  bool isUserLeavingApp = false;

  void goingInActive() {
    _leaveHintTimer = Timer(const Duration(milliseconds: 300), () {
      if (!isUserLeavingApp) return;
      onUserLeaveHint();
    });
    isUserLeavingApp = true;
  }

  void onUserLeaveHint() {
    LogMessage.d('LifeCycle', 'onUserLeaveHint');
    debugPrint("User is leaving the app (onUserLeaveHint equivalent)");
    if (Get.isRegistered<PipViewController>(tag: "pipView")) {
      Get.find<PipViewController>(tag: "pipView").hideOptions();
    }
    if (Get.isRegistered<PipViewController>()) {
      Get.find<PipViewController>().hideOptions();
    }
    enterOrExitPIPMode();
  }
}
