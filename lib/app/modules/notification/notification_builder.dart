import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/session_management.dart';
import 'package:mirror_fly_demo/app/modules/notification/notification_utils.dart';
import 'package:mirrorfly_plugin/logmessage.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';

import '../../common/notification_service.dart';
import '../../data/helper.dart';
import '../../model/notification_message_model.dart';

class NotificationBuilder {
  NotificationBuilder._();
  static var secureNotificationChannelId = 0;
  static var summaryId = 0;
  static var summaryChannelName = "Chat Summary";
  static var groupKeyMessage = "${Constants.packageName}.MESSAGE";
  static var defaultVibrate = 250;

  /// * Create notification when new chat message received
  /// * @parameter message Instance of ChatMessage in NotificationMessageModel
  static createNotification(ChatMessage message,{autoCancel = true}) async {
    int lastMessageTime = 0;
    var chatJid = message.chatUserJid;
    var lastMessageContent = StringBuffer();
    var notificationId = chatJid.hashCode;
    var messageId = message.messageId.hashCode;
    var profileDetails = await getProfileDetails(chatJid!);
    if (profileDetails.isMuted == true) {
      return;
    }
    // var isMessageRecalled = message.isMessageRecalled.checkNull();
    debugPrint("inside if notification");
    lastMessageContent.write(NotificationUtils.getMessageSummary(message));
    lastMessageTime = (message.messageSentTime.toString().length > 13)
        ? (message.messageSentTime / 1000).toInt()
        : message.messageSentTime;
    await displayMessageNotification(
        notificationId,
        messageId,
        profileDetails,
        lastMessageContent.toString(),
        lastMessageTime,
        message.senderUserJid!,autoCancel);

  }


  static Int64List getDefaultVibrate() {
    var vibrationPattern = Int64List(5);
    vibrationPattern[0] = defaultVibrate;
    vibrationPattern[1] = defaultVibrate;
    vibrationPattern[2] = defaultVibrate;
    vibrationPattern[3] = defaultVibrate;
    vibrationPattern[4] = defaultVibrate;
    return vibrationPattern;
  }

  /// * Create [Notification] and display chat message notification
  /// * @parameter notificationId Unique notification id of the conversation
  /// * @parameter profileDetails ProfileDetails of the conversation
  /// * @parameter messagingStyle Unique MessagingStyle of the conversation
  /// * @parameter lastMessageContent Last message of the conversation
  /// * @parameter lastMessageTime Time of the last message
  static displayMessageNotification(
      int notificationId,
      int messageId,
      Profile profileDetails,
      String lastMessageContent,
      int lastMessageTime,
      String senderChatJID,bool autoCancel) async {
    var title = profileDetails.getName().checkNull();
    var chatJid = profileDetails.jid.checkNull();

    debugPrint("notificationId $notificationId");
    debugPrint("notificationId $chatJid");
    // if (Platform.isIOS) {
      debugPrint("lastMessageTime $lastMessageTime");
      notificationId = (Platform.isIOS) ? int.parse(lastMessageTime.toString().substring(lastMessageTime.toString().length - 5)) : messageId;
      debugPrint("ios notification id $notificationId");
      var isGroup = profileDetails.isGroupProfile ?? false;

      var userProfile = await getProfileDetails(senderChatJID);
      var name = userProfile.name ?? '';

      title = isGroup ? "$name @ $title" : title;
    //}

    debugPrint("local notification id $notificationId");
    var channel =
        buildNotificationChannel(notificationId.toString(), null, false);

    var notificationSounUri = SessionManagement.getNotificationUri();
    // var isVibrate = SessionManagement.getVibration();
    // var isRing = SessionManagement.getNotificationSound();
    debugPrint("notificationUri--> $notificationSounUri");
    debugPrint("notificationId--> $notificationId");
    debugPrint("messageId.hashCode--> ${messageId.hashCode}");
    var unReadMessageCount = await Mirrorfly.getUnreadMessageCountExceptMutedChat();
    var androidNotificationDetails = AndroidNotificationDetails(
        channel.id, channel.name,
        channelDescription: channel.description,
        importance: Importance.max,
        autoCancel: true,
        icon: 'ic_notification_blue',
        color: buttonBgColor,
        groupKey: groupKeyMessage,
        number: unReadMessageCount,
        groupAlertBehavior: GroupAlertBehavior.all,
        category: AndroidNotificationCategory.message,
        priority: Priority.high,
        visibility: NotificationVisibility.public,
        when: (lastMessageTime > 0) ? lastMessageTime : null,
        /*sound: isRing && notificationSounUri.checkNull().isNotEmpty ? UriAndroidNotificationSound(
            notificationSounUri!) : null,
        vibrationPattern: (isVibrate */ /*|| getDeviceVibrateMode()*/ /*) ? getDefaultVibrate() : null,*/
        vibrationPattern:
            (SessionManagement.getVibration()) ? getDefaultVibrate() : null,
        playSound: true);
    final String? notificationUri = SessionManagement.getNotificationUri();
    var iosNotificationDetail = DarwinNotificationDetails(
        categoryIdentifier: darwinNotificationCategoryPlain,
        sound: notificationUri,
        presentBadge: true,
        presentSound: true,
        presentAlert: true);

    var notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: iosNotificationDetail);
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await flutterLocalNotificationsPlugin.show(
        notificationId, title, lastMessageContent, notificationDetails,
        payload: chatJid);

    ///Cancelling the notification shown for iOS, inorder to remove from notification tray.
    ///For Push Notification from Server, will be handled at Notification service extension.
    if(autoCancel){
      Future.delayed(const Duration(seconds: 5)).then((value) async {
        await flutterLocalNotificationsPlugin.cancel(notificationId);
      });
    }
  }

  ///  * Build notification channel with given notification ID.
  ///  * @parameter notificationId Unique notification id of the conversation
  ///  * @return AndroidNotificationChannel
  static AndroidNotificationChannel buildNotificationChannel(
      String chatChannelId,
      String? chatChannelName,
      bool isSummaryNotification) {
    // AndroidNotificationChannel createdChannel;
    var notificationSoundUri = SessionManagement.getNotificationUri();
    var isVibrate = SessionManagement.getVibration();
    var isRing = SessionManagement.getNotificationSound();
    var channelName = chatChannelName ?? "App Notifications";
    var channelId =
        getNotificationChannelId(isSummaryNotification, chatChannelId);
    var vibrateImportance = (isVibrate) ? Importance.high : Importance.low;
    var channelDescription =
        "Notification behaviours for the group chat messages";
    var ringImportance = (isRing) ? Importance.high : Importance.low;
    if (isRing) {
      return AndroidNotificationChannel(channelId, channelName,
          importance: ringImportance,
          showBadge: true,
          sound: notificationSoundUri != null
              ? UriAndroidNotificationSound(notificationSoundUri)
              : null,
          description: channelDescription,
          enableLights: true,
          ledColor: Colors.green,
          vibrationPattern: (isVibrate /*|| getDeviceVibrateMode()*/)
              ? getDefaultVibrate()
              : null,
          playSound: true);
    } else if (isVibrate) {
      return AndroidNotificationChannel(channelId, channelName,
          importance: vibrateImportance,
          showBadge: true,
          sound: null,
          description: channelDescription,
          enableLights: true,
          ledColor: Colors.green,
          vibrationPattern: (isVibrate /*|| getDeviceVibrateMode()*/)
              ? getDefaultVibrate()
              : null,
          playSound: false);
    } else {
      return AndroidNotificationChannel(channelId, channelName,
          importance: ringImportance,
          description: channelDescription,
          enableLights: true,
          ledColor: Colors.green,
          playSound: true);
    }
  }

  static String getNotificationChannelId(
      bool isSummaryNotification, String chatChannelId) {
    var channelId = "";
    var randomNumberGenerator = Random();
    if (isSummaryNotification) {
      var summaryChannelId = randomNumberGenerator.nextInt(1000).toString();
      SessionManagement.setSummaryChannelId(summaryChannelId);
      channelId = summaryChannelId;
    } else {
      channelId = chatChannelId.checkNull().isNotEmpty
          ? chatChannelId
          : randomNumberGenerator.nextInt(1000).toString();
    }
    return channelId;
  }

  static cancelNotifications() async {
    LogMessage.d("cancelNotification", "All");
    secureNotificationChannelId = 0;
    flutterLocalNotificationsPlugin.cancelAll();
    var barNotifications =
        await flutterLocalNotificationsPlugin.getActiveNotifications();
    for (var y in barNotifications) {
      flutterLocalNotificationsPlugin.cancel(y.id!);
    }
  }

  ///[id] indicates notification id
  ///in [Android] chat jid hashcode as Notification id (Code line 34)
  static cancelNotification(int id) {
    LogMessage.d("cancelNotification", id);
    flutterLocalNotificationsPlugin.cancel(id);
  }

  static Future<void> clearConversationOnNotification(String jid) async {
    var id = jid.hashCode;
    var barNotifications =
        await flutterLocalNotificationsPlugin.getActiveNotifications();
    for (var notification in barNotifications) {
      if (notification.id == id) {
        flutterLocalNotificationsPlugin.cancel(notification.id!);
      }
    }
  }
}
