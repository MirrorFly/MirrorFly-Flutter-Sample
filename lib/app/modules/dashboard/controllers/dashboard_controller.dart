import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/SessionManagement.dart';
import 'package:mirror_fly_demo/app/model/recentchat.dart';
import 'package:mirror_fly_demo/app/model/userlistModel.dart';
import 'package:mirror_fly_demo/app/nativecall/platformRepo.dart';
import 'package:intl/intl.dart';

import '../../../common/lifecycleEventHandler.dart';
import '../../../model/chatMessageModel.dart';
import '../../../routes/app_pages.dart';

class DashboardController extends GetxController with WidgetsBindingObserver{
  var recentchats = List<RecentChatData>.empty(growable: true).obs;
  var calendar = DateTime.now();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    getRecentChatlist();
    registerMsgListener();
    WidgetsBinding.instance.addObserver(
        LifecycleEventHandler(resumeCallBack: () async { debugPrint("ONRESUME"); }, suspendingCallBack: () async { debugPrint("ONSUSPEND"); }, pauseCallBack: () async { debugPrint("ONRESUME"); })
    );
  }



  @override
  void onClose() {
    super.onClose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print('state = $state');
  }
  registerMsgListener() {
    PlatformRepo().listenMessageEvents();
    // var onMessageReceived = PlatformRepo().onMessageReceived;
    var onMessageStatusUpdated = PlatformRepo().onMediaStatusUpdated;
    // onMessageReceived.listen((event) async {
    //   debugPrint("myreceived" + event.toString());
    //   Log("onMessageReceived", event.toString());
    //   ChatMessageModel recentMsg = sendMessageModelFromJson(event);
      /*final index = recentchats.indexWhere((chat) => chat.jid == recentMsg.chatUserJid);
      var recent = RecentChatData();
      recent.contactType = recentMsg.contactType;
      recent.isAdminBlocked = recentchats.value[index].isAdminBlocked;
      recent.isBlocked = recentchats.value[index].isBlocked;
      recent.isBlockedMe = recentchats.value[index].isBlockedMe;
      recent.isBroadCast = recentchats.value[index].isBroadCast;
      recent.isChatArchived = recentchats.value[index].isChatArchived;
      recent.isChatPinned = recentchats.value[index].isChatPinned;
      recent.isConversationUnRead = recentchats.value[index].isConversationUnRead;
      recent.isGroup = recentchats.value[index].isGroup;
      recent.isGroupInOfflineMode = recentchats.value[index].isGroupInOfflineMode;
      recent.isItSavedContact = recentMsg.isItSavedContact;
      recent.isLastMessageRecalledByUser = recentchats.value[index].isLastMessageRecalledByUser;
      recent.isLastMessageSentByMe = recentchats.value[index].isLastMessageSentByMe;
      recent.isMuted = recentchats.value[index].isMuted;
      recent.isSelected = recentchats.value[index].isSelected;
      recent.jid = recentchats.value[index].jid;
      recent.lastMessageContent = recentMsg.messageTextContent;
      recent.lastMessageId = recentMsg.messageId;
      recent.lastMessageStatus = recentMsg.messageStatus.status;
      recent.lastMessageTime = recentMsg.messageSentTime;
      recent.lastMessageType = recentMsg.messageType;
      recent.nickName = recentchats.value[index].nickName;
      recent.profileImage = recentchats.value[index].profileImage;
      recent.profileName = recentchats.value[index].profileName;
      recent.unreadMessageCount = recentchats.value[index].unreadMessageCount;
      recentchats.value[index]=recent;*/
    // });
    onMessageStatusUpdated.listen((event) {
      debugPrint("myupdate" + event.toString());
      Log("onMessageStatusUpdated", event.toString());
      ChatMessageModel recentMsg = sendMessageModelFromJson(event);
      final index = recentchats.indexWhere((chat) =>
      chat.jid == recentMsg.chatUserJid);
      debugPrint("myupdate index " + index.toString());
      if(index.isNegative){
        var recent = RecentChatData();
        recent.contactType = recentMsg.contactType;
        recent.isLastMessageSentByMe = recentMsg.isMessageSentByMe;
        recent.isItSavedContact = recentMsg.isItSavedContact;
        recent.isLastMessageSentByMe = recentMsg.isMessageSentByMe;
        recent.jid = recentMsg.senderUserJid;
        recent.profileName = recentMsg.senderUserName;
        recent.nickName = recentMsg.senderNickName;
        recent.lastMessageContent = recentMsg.messageTextContent;
        recent.lastMessageId = recentMsg.messageId;
        recent.lastMessageStatus = recentMsg.messageStatus.status;
        recent.lastMessageTime = recentMsg.messageSentTime;
        recent.lastMessageType = recentMsg.messageType;
        recent.unreadMessageCount=0;
        recentchats.add(recent);
      }else {
        var recent = recentchats.value[index];
        //var recent = RecentChatData();
        recent.contactType = recentMsg.contactType;
        // recent.isAdminBlocked = recentchats.value[index].isAdminBlocked;
        // recent.isBlocked = recentchats.value[index].isBlocked;
        // recent.isBlockedMe = recentchats.value[index].isBlockedMe;
        // recent.isBroadCast = recentchats.value[index].isBroadCast;
        // recent.isChatArchived = recentchats.value[index].isChatArchived;
        // recent.isChatPinned = recentchats.value[index].isChatPinned;
        // recent.nickName = recentchats.value[index].nickName;
        // recent.profileImage = recentchats.value[index].profileImage;
        // recent.profileName = recentchats.value[index].profileName;
        // recent.isConversationUnRead =
        //     recentchats.value[index].isConversationUnRead;
        // recent.isGroup = recentchats.value[index].isGroup;
        // recent.isGroupInOfflineMode =
        //     recentchats.value[index].isGroupInOfflineMode;
        // recent.isLastMessageRecalledByUser =
        //     recentchats.value[index].isLastMessageRecalledByUser;
        // recent.isMuted = recentchats.value[index].isMuted;
        // recent.isSelected = recentchats.value[index].isSelected;
        recent.isItSavedContact = recentMsg.isItSavedContact;
        recent.isLastMessageSentByMe = recentMsg.isMessageSentByMe;
        recent.jid = recentMsg.senderUserJid;
        recent.lastMessageContent = recentMsg.messageTextContent;
        recent.lastMessageId = recentMsg.messageId;
        recent.lastMessageStatus = recentMsg.messageStatus.status;
        recent.lastMessageTime = recentMsg.messageSentTime;
        recent.lastMessageType = recentMsg.messageType;
        recent.unreadMessageCount = recentMsg.isMessageSentByMe ? recentchats.value[index].unreadMessageCount :  recentchats.value[index].unreadMessageCount ?? recentchats.value[index].unreadMessageCount!+1 ;
        recentchats.removeAt(index);
        recentchats.insert(0, recent);
      }
      recentchats.refresh();
    });
  }

  getRecentChatlist() {
    print("recent chats");
    PlatformRepo().getRecentChats().then((value) {
      var data = recentChatFromJson(value);
      recentchats.value = (data.data!);
    }).catchError((error) {
      debugPrint("issue===> $error");
      Fluttertoast.showToast(
          msg: error.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          fontSize: 16.0);
    });
  }

  Profile toChatPage(RecentChatData data) {
    var profile = Profile();
    profile.contactType = data.contactType;
    profile.email = "";
    profile.groupCreatedTime = "";
    profile.image = data.profileImage;
    profile.imagePrivacyFlag = "";
    profile.isAdminBlocked = data.isAdminBlocked;
    profile.isBlocked = data.isBlocked;
    profile.isBlockedMe = data.isBlockedMe;
    profile.isGroupAdmin = false;
    profile.isGroupInOfflineMode = data.isGroupInOfflineMode;
    profile.isGroupProfile = false;
    profile.isItSavedContact = data.isItSavedContact;
    profile.isMuted = data.isMuted;
    profile.isSelected = data.isSelected;
    profile.jid = data.jid;
    profile.lastSeenPrivacyFlag = "";
    profile.mobileNUmberPrivacyFlag = "";
    profile.mobileNumber = "";
    profile.name = data.profileName;
    profile.nickName = data.nickName;
    profile.status = "";
    return profile;
  }

  String gettime(int? timestamp) {
    DateTime now = DateTime.now();
    final DateTime date1 = timestamp == null ? now : DateTime
        .fromMillisecondsSinceEpoch(timestamp);
    String formattedDate = DateFormat('hh:mm a').format(date1); //yyyy-MM-dd –
    return formattedDate;
  }

  logout() {
    SessionManagement.clear();
    Get.offAllNamed(Routes.LOGIN);
  }

  String getRecentChatTime(BuildContext context, int? epochTime) {
    if (epochTime == null) return "";
    if (epochTime == 0) return "";
    var convertedTime = epochTime; // / 1000;
    //messageDate.time = convertedTime
    var hourTime = manipulateMessageTime(
        context, DateTime.fromMicrosecondsSinceEpoch(convertedTime));
    var currentYear = DateTime
        .now()
        .year;
    calendar = DateTime.fromMicrosecondsSinceEpoch(convertedTime);
    var time = (currentYear == calendar.year) ? DateFormat("dd-MMM").format(
        calendar) : DateFormat("yyyy/MM/dd").format(calendar);
    return (equalsWithYesterday(calendar, Constants.TODAY))
        ? hourTime
        : (equalsWithYesterday(calendar, Constants.YESTERDAY)) ? Constants
        .YESTERDAY_UPPER : time;
  }

  String manipulateMessageTime(BuildContext context, DateTime messageDate) {
    var format = MediaQuery
        .of(context)
        .alwaysUse24HourFormat ? 24 : 12;
    var hours = calendar.hour; //calendar[Calendar.HOUR]
    calendar = messageDate;
    var dateHourFormat = setDateHourFormat(format, hours);
    return DateFormat(dateHourFormat).format(messageDate);
  }

  String setDateHourFormat(int format, int hours) {
    var dateHourFormat = (format == 12)
        ? (hours < 10) ? "hh:mm aa" : "h:mm aa"
        : (hours < 10) ? "HH:mm" : "H:mm";
    return dateHourFormat;
  }

  bool equalsWithYesterday(DateTime srcDate, String day) {
    // Time part has
    // discarded
    var yesterday = (day == Constants.YESTERDAY) ? calendar.subtract(
        Duration(days: 1)) : DateTime.now();
    return yesterday
        .difference(calendar)
        .inDays == 0;
  }

}
