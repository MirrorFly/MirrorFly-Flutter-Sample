import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/session_management.dart';
import 'package:mirror_fly_demo/app/modules/notification/notification_utils.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';
import 'package:path_provider/path_provider.dart';

import '../../common/notification_service.dart';
import '../../data/helper.dart';
import '../../model/notification_message_model.dart';

class NotificationBuilder {
  static var chatNotifications = <int, NotificationModel>{};
  static var secureNotificationChannelId = 0;
  static var defaultVibrate = 250;

  /*
  * Create notification when new chat message received
  * @param message Instance of ChatMessage in NotificationMessageModel
  * */
  static createNotification(ChatMessage message) async {
    var lastMessageTime = 0;
    var chatJid = message.chatUserJid;
    var lastMessageContent = StringBuffer();
    var notificationId = chatJid.hashCode;
    var profileDetails = await getProfileDetails(chatJid!);
    if (profileDetails.isMuted == true) {
      return;
    }
    var messagingStyle = MessagingStyleInformation(const Person(name: "Me"));
    if (chatNotifications.containsKey(notificationId)) {
      chatNotifications[notificationId] = NotificationModel(
          messagingStyle: messagingStyle, messages: [], unReadMessageCount: 0);
    }
    var notificationModel = chatNotifications[notificationId];
    var isMessageRecalled = message.isMessageRecalled ?? false;

    if (notificationModel != null) {
      if (isMessageRecalled) { // if message was recalled then rebuild the message style
        var oldMessages = notificationModel.messages!;
        notificationModel.messages?.clear();
        oldMessages.forEach((chatMessage) {
          notificationModel.messages?.add(
              chatMessage.messageId == message.messageId
                  ? message
                  : chatMessage);
          appendChatMessageInMessageStyle(lastMessageContent, messagingStyle,
              (chatMessage.messageId == message.messageId)
                  ? message
                  : chatMessage);
        });
        notificationModel.messagingStyle = messagingStyle;
      } else {
        messagingStyle = notificationModel.messagingStyle!;
        notificationModel.messages?.add(message);
        appendChatMessageInMessageStyle(
            lastMessageContent, messagingStyle, message);
      }

      setConversationTitleMessagingStyle(
          profileDetails, notificationModel.messages!.length, messagingStyle);
      lastMessageTime = (message.messageSentTime
          .toString()
          .length > 13) ? message.messageSentTime / 1000 : message
          .messageSentTime;
    }
    displayMessageNotification(notificationId, profileDetails, messagingStyle,
        lastMessageContent.toString(), lastMessageTime);
  }

  /*
  * Append [ChatMessage] content to the provided [MessagingStyleInformation]
  * @param messageContent last message content to be updated
  * @param messagingStyle Unique message style of the conversation
  * @param message Instance on ChatMessage in NotificationMessageModel
  * */
  static appendChatMessageInMessageStyle(StringBuffer messageContent,
      MessagingStyleInformation messagingStyle, ChatMessage message) async {
    var userProfile = await getProfileDetails(message.senderUserJid!);
    var name = userProfile.name ?? '';
    var contentBuilder = StringBuffer();
    contentBuilder.write(NotificationUtils.getMessageSummary(message));
    messageContent.write(contentBuilder);

    // var userProfileImage;
    if (userProfile.image != null) {
      messagingStyle.messages?.add(Message(
          contentBuilder.toString(), message.messageSentTime, Person(
          name: name, icon: const FlutterBitmapAssetAndroidIcon(profileImg))));
    } else {
      messagingStyle.messages?.add(Message(
          contentBuilder.toString(), message.messageSentTime, Person(
          name: name,
          icon: const DrawableResourceAndroidIcon(
              'ic_notification_blue.png'))));
    }
  }

  static getUserProfileImage(Profile profileDetails) {
    // AndroidBitmap? bitmapUserProfile;
    var imgUrl = profileDetails.image ?? '';
    try {
      if (imgUrl.isNotEmpty) {

      }
    } catch (e) {

    }
  }

  /*
   * Set the title of the conversation to the provided [MessagingStyleInformation]
   * @param profileDetails ProfileDetails of the conversation
   * @param messagingStyle Unique messaging style of the conversation
   * @param messagesCount total unread messages count of the conversation
   */
  static void setConversationTitleMessagingStyle(Profile profileDetails,
      int messageCount, MessagingStyleInformation messagingStyle) {
    var title = profileDetails.name ?? '';
    if (messageCount > 1) {
      var appendMessageLable = " messages)";
      String modifiedTitle;
      if (profileDetails.isGroupProfile ?? false) {
        modifiedTitle = "$title ($messageCount$appendMessageLable";
        var newMessageStyle = MessagingStyleInformation(
            messagingStyle.person, groupConversation: true,
            conversationTitle: modifiedTitle);
        messagingStyle = newMessageStyle;
      } else if (chatNotifications.length <= 1) {
        modifiedTitle = " ($messageCount$appendMessageLable";
        var newMessageStyle = MessagingStyleInformation(
            messagingStyle.person, conversationTitle: modifiedTitle);
        messagingStyle = newMessageStyle;
      }
    } else if (profileDetails.isGroupProfile.checkNull()) {
      var newMessageStyle = MessagingStyleInformation(
          messagingStyle.person, groupConversation: true,
          conversationTitle: title);
      messagingStyle = newMessageStyle;
    }
  }

  static Int64List getDefaultVibrate(){
    var vibrationPattern = Int64List(5);
    vibrationPattern[0] = defaultVibrate;
    vibrationPattern[1] = defaultVibrate;
    vibrationPattern[2] = defaultVibrate;
    vibrationPattern[3] = defaultVibrate;
    vibrationPattern[4] = defaultVibrate;
    return vibrationPattern;
  }

  /*
   * Create [Notification] and display chat message notification
   * @param notificationId Unique notification id of the conversation
   * @param profileDetails ProfileDetails of the conversation
   * @param messagingStyle Unique MessagingStyle of the conversation
   * @param lastMessageContent Last message of the conversation
   * @param lastMessageTime Time of the last message
   */
  static displayMessageNotification(int notificationId, Profile profileDetails,
      MessagingStyleInformation messagingStyle, String lastMessageContent,
      int lastMessageTime) async {
    var title = profileDetails.name.checkNull();
    var chatJid = profileDetails.jid.checkNull();

    // var requesId = DateTime.now();

    var channel = buildNotificationChannel(notificationId.toString(), null, false);

    chatNotifications[notificationId]!.unReadMessageCount =
        chatNotifications[notificationId]!.unReadMessageCount! + 1;
    var unReadMessageCount = (chatNotifications.length == 1)
        ? getTotalUnReadMessageCount(notificationId)
        : chatNotifications[notificationId]?.unReadMessageCount ?? 1;
    mirrorFlyLog(
        "NotificationBuilder", "unReadMessageCount $unReadMessageCount");
    chatNotifications[notificationId]!.unReadMessageCount = unReadMessageCount;


    var androidNotificationDetails = AndroidNotificationDetails(
        channel.id, channel.name, channelDescription: channel.description,
        importance: Importance.high,
        styleInformation: messagingStyle,
        autoCancel: true,
        icon: 'ic_notification_blue',
        color: buttonBgColor,
        groupKey: "${Constants.packageName}.MESSAGE",
        number: unReadMessageCount,
        groupAlertBehavior: GroupAlertBehavior.summary,
        category: AndroidNotificationCategory.message,
        priority: Priority.high,
        visibility: NotificationVisibility.public,
        // largeIcon: Fi,
        when: (lastMessageTime > 0) ? lastMessageTime : null,
        vibrationPattern: (SessionManagement.getVibration())
            ? getDefaultVibrate()
            : null,
        playSound: true);
    var iosNotificationDetail = DarwinNotificationDetails(
        presentBadge: true,
        badgeNumber: unReadMessageCount,
        presentSound: true
    );

    var notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: iosNotificationDetail);
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
        channel);
    await flutterLocalNotificationsPlugin.show(
        0, title, lastMessageContent, notificationDetails,
        payload: chatJid);
  }

  static int getTotalUnReadMessageCount(int notificationId) {
    // return if (CallNotificationUtils.unReadCallCount == 0) FlyMessenger.getUnreadMessageCountExceptMutedChat() + CallLogManager.getUnreadMissedCallCount() else chatNotifications[notificationId]?.unReadMessageCount ?: 1
    return 0;
  }

  Future<String> downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  /**
   * Build notification channel with given notification ID.
   * @param notificationId Unique notification id of the conversation
   * @return AndroidNotificationChannel
   */
  static AndroidNotificationChannel buildNotificationChannel(
      String chatChannelId, String? chatChannelName,
      bool isSummaryNotification) {
    // AndroidNotificationChannel createdChannel;
    var notificationSounUri = SessionManagement.getNotificationUri();
    var isVibrate = SessionManagement.getVibration();
    var isRing = SessionManagement.getNotificationSound();
    var channelName = chatChannelName ?? "App Notifications";
    var channelId = getNotificationChannelId(
        isSummaryNotification, chatChannelId);
    var vibrateImportance = (isVibrate) ? Importance.high : Importance.low;
    var channelDescription = "Notification behaviours for the group chat messages";
    var ringImportance = (isRing) ? Importance.high : Importance.low;
    if (isRing) {
      return AndroidNotificationChannel(
        channelId, channelName, importance: ringImportance,
        showBadge: true,
        sound: notificationSounUri != null ? UriAndroidNotificationSound(
            notificationSounUri) : null,
      description: channelDescription,
      enableLights: true,
      ledColor: Colors.green,
      vibrationPattern: (isVibrate /*|| getDeviceVibrateMode()*/) ? getDefaultVibrate() : null);
    }else if(isVibrate){
      return AndroidNotificationChannel(
          channelId, channelName, importance: vibrateImportance,
          showBadge: true,
          sound: null,
          description: channelDescription,
          enableLights: true,
          ledColor: Colors.green,
          vibrationPattern: (isVibrate /*|| getDeviceVibrateMode()*/) ? getDefaultVibrate() : null);
    }else{
      return AndroidNotificationChannel(
          channelId, channelName, importance: ringImportance,
          sound: null,
          description: channelDescription,
          enableLights: true,
          ledColor: Colors.green);
    }
  }

  static String getNotificationChannelId(bool isSummaryNotification,
      String chatChannelId) {
    var channelId = "";
    var randomNumberGenerator = Random();
    if (isSummaryNotification) {
      var summaryChannelId = randomNumberGenerator.nextInt(1000).toString();
      SessionManagement.setSummaryChannelId(summaryChannelId);
      channelId = summaryChannelId;
    } else {
      channelId = randomNumberGenerator.nextInt(1000).toString();
    }
    return channelId;
  }

  static cancelNotifications(){
    chatNotifications.clear();
    secureNotificationChannelId = 0;
    flutterLocalNotificationsPlugin.cancelAll();
  }

  static cancelNotification(int id){
    flutterLocalNotificationsPlugin.cancel(id);
  }
}


class NotificationModel {
  MessagingStyleInformation? messagingStyle;
  List<ChatMessage>? messages;
  int? unReadMessageCount;

  NotificationModel(
      {this.messagingStyle, this.messages, this.unReadMessageCount});
}