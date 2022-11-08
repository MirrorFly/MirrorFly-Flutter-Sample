import 'dart:convert';

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

class DashboardController extends GetxController {
  var recentchats = <RecentChatData>[].obs;
  var calendar = DateTime.now();

  @override
  void onInit() {
    super.onInit();
    registerMsgListener();

    ever(recentchats, (callback) => _unreadcount());
  }

  @override
  void onClose() {
    super.onClose();
  }

  registerMsgListener() {
    PlatformRepo().listenMessageEvents();
    var onMessageStatusUpdated = PlatformRepo().onMessageReceived;
    onMessageStatusUpdated.listen((event) {
      debugPrint("myupdate" + event.toString());
      Log("onMessageStatusUpdated", event.toString());
      ChatMessageModel recentMsg = sendMessageModelFromJson(event);
      final index =
      recentchats.indexWhere((chat) => chat.jid == recentMsg.chatUserJid);
      debugPrint("myupdate index " + index.toString());
      if (index.isNegative) {
        /*var recent = RecentChatData();
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
        recent.unreadMessageCount = 0;*/
        getRecentChatofJid(recentMsg.chatUserJid).then((recent){
          if(recent!=null){
            recentchats.add(recent);
          }
        });
      } else {
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
        recent.unreadMessageCount = recentMsg.isMessageSentByMe
            ? recentchats.value[index].unreadMessageCount
            : recentchats.value[index].unreadMessageCount!=null ?
        recentchats.value[index].unreadMessageCount! + 1 : recentchats.value[index].unreadMessageCount;
        recentchats.removeAt(index);
        recentchats.insert(0, recent);
      }
      recentchats.refresh();
    });
  }

  Future<RecentChatData?> getRecentChatofJid(String jid) async{
    var value = await PlatformRepo().getRecentChatOf(jid);
    Log("rchat", value.toString());
    if (value != null) {
      var data = RecentChatData.fromJson(json.decode(value));
      return data;
    }else {
      return null;
    }
  }

  getRecentChatlist() {
    print("recent chats");
    PlatformRepo().getRecentChats().then((value) {
      var data = recentChatFromJson(value);
      recentchats.value.clear();
      recentchats
          .addAll(data.data!);
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
    final DateTime date1 = timestamp == null
        ? now
        : DateTime.fromMillisecondsSinceEpoch(timestamp);
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
    var currentYear = DateTime.now().year;
    calendar = DateTime.fromMicrosecondsSinceEpoch(convertedTime);
    var time = (currentYear == calendar.year)
        ? DateFormat("dd-MMM").format(calendar)
        : DateFormat("yyyy/MM/dd").format(calendar);
    return (equalsWithYesterday(calendar, Constants.TODAY))
        ? hourTime
        : (equalsWithYesterday(calendar, Constants.YESTERDAY))
            ? Constants.YESTERDAY_UPPER
            : time;
  }

  String manipulateMessageTime(BuildContext context, DateTime messageDate) {
    var format = MediaQuery.of(context).alwaysUse24HourFormat ? 24 : 12;
    var hours = calendar.hour; //calendar[Calendar.HOUR]
    calendar = messageDate;
    var dateHourFormat = setDateHourFormat(format, hours);
    return DateFormat(dateHourFormat).format(messageDate);
  }

  String setDateHourFormat(int format, int hours) {
    var dateHourFormat = (format == 12)
        ? (hours < 10)
            ? "hh:mm aa"
            : "h:mm aa"
        : (hours < 10)
            ? "HH:mm"
            : "H:mm";
    return dateHourFormat;
  }

  bool equalsWithYesterday(DateTime srcDate, String day) {
    // Time part has
    // discarded
    var yesterday = (day == Constants.YESTERDAY)
        ? calendar.subtract(Duration(days: 1))
        : DateTime.now();
    return yesterday.difference(calendar).inDays == 0;
  }
  
  final _unreadcount = 0.obs;
  int get unreadcount => _unreadcount.value;
  set unreadcount(int val) => _unreadcount.value = val;
  
  unReadCount(){
    _unreadcount(0);
    recentchats.forEach((p0){
      if(p0.unreadMessageCount!=null){
        _unreadcount((p0.unreadMessageCount!+unreadcount));
      }
    });
  }

}
