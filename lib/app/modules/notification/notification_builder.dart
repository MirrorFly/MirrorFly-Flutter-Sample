import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/apputils.dart';
import 'package:mirror_fly_demo/app/data/session_management.dart';
import 'package:mirror_fly_demo/app/modules/notification/notification_utils.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../common/notification_service.dart';
import '../../data/helper.dart';
import '../../model/notification_message_model.dart';

class NotificationBuilder {
  NotificationBuilder._();
  static var chatNotifications = <int, NotificationModel>{};
  static var secureNotificationChannelId = 0;
  static var summaryId = 0;
  static var summaryChannelName = "Chat Summary";
  static var groupKeyMessage = "${Constants.packageName}.MESSAGE";
  static var defaultVibrate = 250;

  /// * Create notification when new chat message received
  /// * @parameter message Instance of ChatMessage in NotificationMessageModel
  static createNotification(ChatMessage message) async {
    int lastMessageTime = 0;
    var chatJid = message.chatUserJid;
    var lastMessageContent = StringBuffer();
    var notificationId = chatJid.hashCode;
    var messageId = message.messageId.hashCode;
    var profileDetails = await getProfileDetails(chatJid!);
    if (profileDetails.isMuted == true) {
      return;
    }
    var messagingStyle = MessagingStyleInformation(const Person(name: "Me"),messages: []);
    if (!chatNotifications.containsKey(notificationId)) {
      chatNotifications[notificationId] = NotificationModel(
          messagingStyle: messagingStyle, messages: [], unReadMessageCount: 0);
    }
    var notificationModel = chatNotifications[notificationId];
    var isMessageRecalled = message.isMessageRecalled.checkNull();

    if (notificationModel != null) {
      // notificationModel.messages?.forEach((element) { mirrorFlyLog("notificationModel", "${element.messageId}");});
      if (isMessageRecalled) { // if message was recalled then rebuild the message style
        List<ChatMessage> oldMessages = [];
        oldMessages.addAll(notificationModel.messages!);
        chatNotifications[notificationId]?.messages?.clear();
        mirrorFlyLog("oldMessages", oldMessages.length.toString());
        for (var chatMessage in oldMessages) {
          notificationModel.messages?.add(
              chatMessage.messageId == message.messageId
                  ? message
                  : chatMessage);
          await appendChatMessageInMessageStyle(lastMessageContent, messagingStyle,
              (chatMessage.messageId == message.messageId)
                  ? message
                  : chatMessage);
        }
        mirrorFlyLog("messagingStyle", messagingStyle.messages!.length.toString());
        notificationModel.messagingStyle = messagingStyle;
      } else {
        messagingStyle = notificationModel.messagingStyle!;
        notificationModel.messages?.add(message);
        await appendChatMessageInMessageStyle(
            lastMessageContent, messagingStyle, message);
      }

      setConversationTitleMessagingStyle(
          profileDetails, notificationModel.messages!.length, messagingStyle);
      lastMessageTime = (message.messageSentTime
          .toString()
          .length > 13) ? (message.messageSentTime / 1000).toInt() : message
          .messageSentTime;
    }
    displayMessageNotification(notificationId,messageId, profileDetails, messagingStyle,
        lastMessageContent.toString(), lastMessageTime);

    if(Platform.isAndroid){
      displaySummaryNotification(lastMessageContent);
    }
  }

   /// Append [ChatMessage] content to the provided [MessagingStyleInformation]
   /// * @parameter messageContent last message content to be updated
   /// * @parameter messagingStyle Unique message style of the conversation
   /// * @parameter message Instance on ChatMessage in NotificationMessageModel
  static appendChatMessageInMessageStyle(StringBuffer messageContent,
      MessagingStyleInformation messagingStyle, ChatMessage message) async {

    var contentBuilder = StringBuffer();
    contentBuilder.write(NotificationUtils.getMessageSummary(message));
    messageContent.write(contentBuilder);

    if(Platform.isAndroid) {
      var userProfile = await getProfileDetails(message.senderUserJid!);
      var name = userProfile.name ?? '';
      var userProfileImage = await getUserProfileImage(userProfile);
      if (userProfileImage != null) {
        var image = ByteArrayAndroidIcon(userProfileImage);
        messagingStyle.messages?.add(Message(
            contentBuilder.toString(), DateTime.fromMillisecondsSinceEpoch(message.messageSentTime), Person(
            name: name, icon: image)));
        mirrorFlyLog('image', 'not empty');
      } else {
        messagingStyle.messages?.add(Message(
            contentBuilder.toString(), DateTime.fromMillisecondsSinceEpoch(message.messageSentTime), Person(
            name: name,
            icon: const FlutterBitmapAssetAndroidIcon(profileImg))));
        mirrorFlyLog('image ', 'empty');
      }
      mirrorFlyLog("append messagingStyle", messagingStyle.messages.toString());
    }
  }

  /// get Profile Image using instance of Profile
  /// * @parameter profileDetails instance of Profile
  /// * return [Uint8List] of the profile image or profile name drawable
  static Future<Uint8List?> getUserProfileImage(Profile profileDetails) async {
    // AndroidBitmap? bitmapUserProfile;
    var imgUrl = profileDetails.image.checkNull();
    if (imgUrl.isNotEmpty) {
      // return const FlutterBitmapAssetAndroidIcon(profileImg);
      return await downloadAndShow(SessionManagement.getMediaEndPoint().checkNull()+imgUrl,profileDetails.name.checkNull());
    }else{
      if(getName(profileDetails).isNotEmpty) {
        var uInt = await profileTextImage(
            getName(profileDetails), const Size(50, 50));
        return uInt!;
      }else{
        return null;
      }
    }
  }

   /// * Set the title of the conversation to the provided [MessagingStyleInformation]
   /// * @parameter profileDetails ProfileDetails of the conversation
   /// * @parameter messagingStyle Unique messaging style of the conversation
   /// * @parameter messagesCount total unread messages count of the conversation
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

   /// * Create [Notification] and display chat message notification
   /// * @parameter notificationId Unique notification id of the conversation
   /// * @parameter profileDetails ProfileDetails of the conversation
   /// * @parameter messagingStyle Unique MessagingStyle of the conversation
   /// * @parameter lastMessageContent Last message of the conversation
   /// * @parameter lastMessageTime Time of the last message
  static displayMessageNotification(int notificationId,int messageId, Profile profileDetails,
      MessagingStyleInformation messagingStyle, String lastMessageContent,
      int lastMessageTime) async {
    var title = profileDetails.name.checkNull();
    var chatJid = profileDetails.jid.checkNull();

    if (Platform.isIOS) {
      notificationId = int.parse(lastMessageTime.toString().substring(lastMessageTime.toString().length - 5));
    }

    debugPrint("local notification id $notificationId");

    var channel = buildNotificationChannel(notificationId.toString(), null, false);

    chatNotifications[notificationId]?.unReadMessageCount =
        chatNotifications[notificationId]?.unReadMessageCount ?? 0 + 1;
    var unReadMessageCount = (chatNotifications.length == 1)
        ? getTotalUnReadMessageCount(notificationId)
        : chatNotifications[notificationId]?.unReadMessageCount ?? 1;
    mirrorFlyLog(
        "NotificationBuilder", "unReadMessageCount $unReadMessageCount");
    chatNotifications[notificationId]?.unReadMessageCount = unReadMessageCount;

    var notificationSounUri = SessionManagement.getNotificationUri();
    // var isVibrate = SessionManagement.getVibration();
    // var isRing = SessionManagement.getNotificationSound();
    debugPrint("notificationUri--> $notificationSounUri");
    debugPrint("notificationId--> $notificationId");
    debugPrint("messageId.hashCode--> ${messageId.hashCode}");
    var androidNotificationDetails = AndroidNotificationDetails(
        channel.id, channel.name, channelDescription: channel.description,
        importance: Importance.max,
        styleInformation: messagingStyle,
        autoCancel: true,
        icon: 'ic_notification_blue',
        color: buttonBgColor,
        groupKey: groupKeyMessage,
        number: unReadMessageCount,
        groupAlertBehavior: GroupAlertBehavior.all,
        category: AndroidNotificationCategory.message,
        priority: Priority.high,
        visibility: NotificationVisibility.public,
        largeIcon: const DrawableResourceAndroidBitmap('ic_notification_blue'),
        when: (lastMessageTime > 0) ? lastMessageTime : null,
        /*sound: isRing && notificationSounUri.checkNull().isNotEmpty ? UriAndroidNotificationSound(
            notificationSounUri!) : null,
        vibrationPattern: (isVibrate *//*|| getDeviceVibrateMode()*//*) ? getDefaultVibrate() : null,*/
        vibrationPattern: (SessionManagement.getVibration())
            ? getDefaultVibrate()
            : null,
        playSound: true);
    final String? notificationUri = SessionManagement.getNotificationUri();
    var iosNotificationDetail = DarwinNotificationDetails(
        categoryIdentifier: darwinNotificationCategoryPlain,
        sound: notificationUri,
        presentBadge: true,
        badgeNumber: unReadMessageCount,
        presentSound: true,
        presentAlert: true
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
        notificationId, title, lastMessageContent, notificationDetails,
        payload: chatJid);
  }
  
   // * Create [Notification] and display summary of the multiple chat conversations
   // * @param lastMessageContent Last message of the conversation
  static displaySummaryNotification(StringBuffer lastMessageContent) async {
    var summaryText = StringBuffer();
    final info = await PackageInfo.fromPlatform();
    var appTitle = info.appName;
    summaryText.write("${getMessagesCount()} messages from ${chatNotifications.length} chats");
    var inlineMessages = <String>[];
    chatNotifications.forEach((key, value) { inlineMessages.add("notificationInlineMessage");});
    var inboxStyle = InboxStyleInformation(inlineMessages,summaryText: summaryText.toString(),contentTitle: appTitle);

    var channel = buildNotificationChannel(Constants.emptyString, summaryChannelName, true);
    
    var notificationSounUri = SessionManagement.getNotificationUri();
    // var isVibrate = SessionManagement.getVibration();
    // var isRing = SessionManagement.getNotificationSound();
    debugPrint("notificationUri--> $notificationSounUri");
    var androidNotificationDetails = AndroidNotificationDetails(
        channel.id, channel.name, channelDescription: channel.description,
        importance: Importance.max,
        styleInformation: inboxStyle,
        autoCancel: true,
        icon: 'ic_notification_blue',
        color: buttonBgColor,
        groupKey: groupKeyMessage,
        number: chatNotifications.length,
        // groupAlertBehavior: GroupAlertBehavior.summary,
        setAsGroupSummary: true,
        category: AndroidNotificationCategory.message,
        priority: Priority.high,
        visibility: NotificationVisibility.public,
        largeIcon: const DrawableResourceAndroidBitmap('ic_notification_blue'),
        /*sound: isRing && notificationSounUri.checkNull().isNotEmpty ? UriAndroidNotificationSound(
            notificationSounUri!) : null,
        vibrationPattern: (isVibrate *//*|| getDeviceVibrateMode()*//*) ? getDefaultVibrate() : null,*/
        vibrationPattern: (SessionManagement.getVibration())
            ? getDefaultVibrate()
            : null,
        playSound: true);
    final String? notificationUri = SessionManagement.getNotificationUri();
    var iosNotificationDetail = DarwinNotificationDetails(
        categoryIdentifier: darwinNotificationCategoryPlain,
        sound: notificationUri,
        presentBadge: true,
        badgeNumber: chatNotifications.length,
        threadIdentifier: channel.id.toString(),
        presentSound: true,
        presentAlert: true
    );

    if(chatNotifications.isNotEmpty) {
      var notificationDetails = NotificationDetails(
          android: androidNotificationDetails,
          iOS: iosNotificationDetail);
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
          channel);
      await flutterLocalNotificationsPlugin.show(
        summaryId, appTitle, lastMessageContent.toString(),
          notificationDetails,payload: chatNotifications.values.first.messages?.first.chatUserJid);
    }
  }
  
   // * Get total unread messages count showing in the Push
   // * @return total unread messages count
  
  static int getMessagesCount() {
      var totalMessagesCount = 0;
      chatNotifications.forEach((key, value) {
        totalMessagesCount += value.messages!.length;
      });
    return totalMessagesCount;
  }
  
  static int getTotalUnReadMessageCount(int notificationId) {
    // return if (CallNotificationUtils.unReadCallCount == 0) FlyMessenger.getUnreadMessageCountExceptMutedChat() + CallLogManager.getUnreadMissedCallCount() else chatNotifications[notificationId]?.unReadMessageCount ?: 1
    return 0;
  }

  static Future<Uint8List?> downloadAndShow(String url, String fileName) async {
    // final Directory directory = await getApplicationDocumentsDirectory();
    // final String filePath = '${directory.path}/$fileName';
    mirrorFlyLog("url", url);
    if(!url.isURL) {
      return null;
    }
    final http.Response response = await http.get(Uri.parse(url),headers: {"Authorization": SessionManagement.getAuthToken().checkNull()});
    // final File file = File(filePath);
    // await file.writeAsBytes(response.bodyBytes);
    mirrorFlyLog("response.statusCode", response.statusCode.toString());
    mirrorFlyLog("response.headers", response.headers.toString());
    mirrorFlyLog("response.reasonPhrase", response.reasonPhrase.toString());
    if(response.statusCode==200) {
      return response.bodyBytes.buffer.asUint8List();
    }else{
      return null;
    }
  }

  ///  * Build notification channel with given notification ID.
  ///  * @parameter notificationId Unique notification id of the conversation
  ///  * @return AndroidNotificationChannel
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
      vibrationPattern: (isVibrate /*|| getDeviceVibrateMode()*/) ? getDefaultVibrate() : null,playSound: true);
    }else if(isVibrate){
      return AndroidNotificationChannel(
          channelId, channelName, importance: vibrateImportance,
          showBadge: true,
          sound: null,
          description: channelDescription,
          enableLights: true,
          ledColor: Colors.green,
          vibrationPattern: (isVibrate /*|| getDeviceVibrateMode()*/) ? getDefaultVibrate() : null,playSound: false);
    }else{
      return AndroidNotificationChannel(
          channelId, channelName, importance: ringImportance,
          description: channelDescription,
          enableLights: true,
          ledColor: Colors.green,playSound: true);
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
      channelId = chatChannelId.checkNull().isNotEmpty ? chatChannelId : randomNumberGenerator.nextInt(1000).toString();
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

  /// * get Uint8List from given profileTextImage
  /// * @parameter name is placed to profileTextImage
  /// * @parameter Size is instance of Size
  static Future<Uint8List?> profileTextImage(String name,Size size) async {
    final recorder = PictureRecorder();
    var canvas = Canvas(recorder);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    var text = AppUtils.getInitials(name);

    final circlePaint = Paint()
      ..color = Color(Helper.getColourCode(text))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, circlePaint);

    var textStyle = TextStyle(
      color: Colors.white,
      fontSize: radius / 1.5,
      fontWeight: FontWeight.bold,
    );

    var textSpan = TextSpan(
      text: text,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(); // Perform the layout

    final textOffset = Offset(
      center.dx - textPainter.width / 2,
      center.dy - textPainter.height / 2,
    );

    textPainter.paint(canvas, textOffset);
    final picture = recorder.endRecording();
    final image = await picture.toImage(
      size.width.toInt(),
      size.height.toInt(),
    );

    final byteData = await image.toByteData(format: ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }
}


class NotificationModel {
  MessagingStyleInformation? messagingStyle;
  List<ChatMessage>? messages;
  int? unReadMessageCount;

  NotificationModel(
      {this.messagingStyle, this.messages, this.unReadMessageCount});
}

