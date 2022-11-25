import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/base_controller.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/session_management.dart';

import 'package:flysdk/flysdk.dart';
import 'package:intl/intl.dart';

import 'package:flysdk/flysdk.dart';

import '../../../routes/app_pages.dart';

class DashboardController extends GetxController with GetTickerProviderStateMixin, BaseController {
  var recentChats = <RecentChatData>[].obs;
  var calendar = DateTime.now();

  @override
  void onInit() {
    super.onInit();
    recentChats.bindStream(recentChats.stream);
    ever(recentChats, (callback) => unReadCount());
  }

  Future<RecentChatData?> getRecentChatOfJid(String jid) async{
    var value = await FlyChat.getRecentChatOf(jid);
    mirrorFlyLog("chat", value.toString());
    if (value != null) {
      var data = RecentChatData.fromJson(json.decode(value));
      return data;
    }else {
      return null;
    }
  }

  getRecentChatList() {
    mirrorFlyLog("","recent chats");
    FlyChat.getRecentChatList().then((value) {
      var data = recentChatFromJson(value);
      recentChats.clear();
      recentChats
          .addAll(data.data!);
    }).catchError((error) {
      debugPrint("issue===> $error");
    });
  }

  toChatPage(String jid) {
    if(jid.isNotEmpty) {
      FlyChat.getProfileLocal(jid, false).then((value) {
        if(value!=null){
          var profileData = profileDataFromJson(value);
          var data = profileData.data!;
          var profile = Profile();
          profile.contactType = "";
          profile.email = data.email;
          profile.groupCreatedTime = "";
          profile.image = data.image;
          profile.imagePrivacyFlag = "";
          profile.isAdminBlocked = data.isAdminBlocked;
          profile.isBlocked = data.isBlocked;
          profile.isBlockedMe = data.isBlockedMe;
          profile.isGroupAdmin = data.isGroupAdmin;
          profile.isGroupInOfflineMode = data.isGroupInOfflineMode;
          profile.isGroupProfile = data.isGroupProfile;
          profile.isItSavedContact = data.isItSavedContact;
          profile.isMuted = data.isMuted;
          profile.isSelected = data.isSelected;
          profile.jid = data.jid;
          profile.lastSeenPrivacyFlag ="";
          profile.mobileNUmberPrivacyFlag = "";
          profile.mobileNumber = data.mobileNumber;
          profile.name = data.name;
          profile.nickName = data.nickName;
          profile.status = data.status;
          Get.toNamed(Routes.CHAT, arguments: profile);
        }
      });
    }
  }

  String getTime(int? timestamp) {
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
    return (equalsWithYesterday(calendar, Constants.today))
        ? hourTime
        : (equalsWithYesterday(calendar, Constants.yesterday))
            ? Constants.yesterdayUpper
            : time;
  }

  String manipulateMessageTime(BuildContext context, DateTime messageDate) {
    var format = MediaQuery.of(context).alwaysUse24HourFormat ? 24 : 12;
    var hours = calendar.hour;
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
    var yesterday = (day == Constants.yesterday)
        ? calendar.subtract(const Duration(days: 1))
        : DateTime.now();
    return yesterday.difference(calendar).inDays == 0;
  }
  
  final _unreadCount = 0.obs;
  int get unreadCount => _unreadCount.value;
  set unreadCount(int val) => _unreadCount.value = val;
  
  unReadCount(){
    _unreadCount(0);
    for (var p0 in recentChats) {
      if(p0.unreadMessageCount!=null){
        _unreadCount(((p0.unreadMessageCount!>0) ? 1+unreadCount : 0 +unreadCount));
      }
    }
  }

  updateRecentChat(String jid){
    final index = recentChats.indexWhere((chat) => chat.jid == jid);
    debugPrint("my update index $index");
    getRecentChatOfJid(jid).then((recent){
      if(recent!=null){
        if (index.isNegative) {
          recentChats.add(recent);
        } else {
          recentChats.removeAt(index);
          recentChats.insert(0, recent);
        }
      }else{
        if (!index.isNegative) {
          recentChats.removeAt(index);
        }
      }
      recentChats.refresh();
    });
  }

  Future<ChatMessageModel?> getMessageOfId(String mid) async{
    var value = await FlyChat.getMessageOfId(mid);
    mirrorFlyLog("getMessageOfId recent", value.toString());
    if(value!=null) {
      var data = ChatMessageModel.fromJson(json.decode(value.toString()));
      return data;
    }else{
      return null;
    }
  }

  webLogin(){
    if(SessionManagement.getWebLogin()){
      Future.delayed(const Duration(milliseconds: 100),
              () => Get.toNamed(Routes.WEBLOGINRESULT));
    }else{
      Future.delayed(const Duration(milliseconds: 100),
              () => Get.toNamed(Routes.SCANNER));
    }
  }

  @override
  void onMessageReceived(chatMessage){
    mirrorFlyLog("dashboard controller", "onMessageReceived");
    super.onMessageReceived(chatMessage);
    ChatMessageModel chatMessageModel = sendMessageModelFromJson(chatMessage);
    updateRecentChat(chatMessageModel.senderUserJid);
  }


  @override
  void onGroupProfileUpdated(groupJid){
    super.onGroupProfileUpdated(groupJid);
    mirrorFlyLog("super", groupJid.toString());
    updateRecentChat(groupJid);
  }

  @override
  void onDeleteGroup(groupJid){
    super.onDeleteGroup(groupJid);
    updateRecentChat(groupJid);
  }
  @override
  void onGroupDeletedLocally(groupJid){
    super.onGroupDeletedLocally(groupJid);
    updateRecentChat(groupJid);
  }

}
