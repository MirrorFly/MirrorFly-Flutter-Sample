import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/basecontroller.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/SessionManagement.dart';
import 'package:mirror_fly_demo/app/model/recentchat.dart';
import 'package:mirror_fly_demo/app/model/userlistModel.dart';
import 'package:mirror_fly_demo/app/nativecall/platformRepo.dart';
import 'package:intl/intl.dart';

import '../../../common/lifecycleEventHandler.dart';
import '../../../model/chatMessageModel.dart';
import '../../../model/checkModel.dart';
import '../../../model/profileModel.dart';
import '../../../routes/app_pages.dart';

class DashboardController extends BaseController {
  var recentchats = <RecentChatData>[].obs;
  var calendar = DateTime.now();

  @override
  void onInit() {
    super.onInit();
    //getRecentChatlist();
    recentchats.bindStream(recentchats.stream);
    ever(recentchats, (callback) => unReadCount());
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
    Log("","recent chats");
    PlatformRepo().getRecentChats().then((value) {
      var data = recentChatFromJson(value);
      recentchats.value.clear();
      recentchats
          .addAll(data.data!);
    }).catchError((error) {
      debugPrint("issue===> $error");
    });
  }

  toChatPage(String jid) {
    if(jid.isNotEmpty) {
      PlatformRepo().getProfileLocal(jid, false).then((value) {
        if(value!=null){
          var datas = profileDataFromJson(value);
          var data = datas.data!;
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
        _unreadcount(((p0.unreadMessageCount!>0) ? 1+unreadcount : 0 +unreadcount));
      }
    });
  }

  updateRecentChat(String jid){
    final index = recentchats.indexWhere((chat) => chat.jid == jid);
    debugPrint("myupdate index " + index.toString());
    getRecentChatofJid(jid).then((recent){
      if(recent!=null){
        if (index.isNegative) {
          recentchats.add(recent);
        } else {
          recentchats.removeAt(index);
          recentchats.insert(0, recent);
        }
      }else{
        if (!index.isNegative) {
          recentchats.removeAt(index);
        }
      }
      recentchats.refresh();
    });
  }

  Future<ChatMessageModel?> getMessageOfId(String mid) async{
    var value = await PlatformRepo().getMessageOfId(mid);
    Log("getMessageOfId recent", value.toString());
    if(value!=null) {
      var data = ChatMessageModel.fromJson(json.decode(value.toString()));
      return data;
    }else{
      return null;
    }
  }

  webLogin(){
    if(SessionManagement().getWebLogin()){
      Future.delayed(const Duration(milliseconds: 100),
              () => Get.toNamed(Routes.WEBLOGINRESULT));
    }else{
      Future.delayed(const Duration(milliseconds: 100),
              () => Get.toNamed(Routes.SCANNER));
    }
  }

  @override
  void onMessageReceived(event){
    super.onMessageReceived(event);
    updateRecentChat(event);
  }

  @override
  void onGroupProfileFetched(groupJid){
    super.onGroupProfileFetched(groupJid);
  }
  @override
  void onNewGroupCreated(groupJid){
    super.onNewGroupCreated(groupJid);
  }

  void onGroupProfileUpdated(groupJid){
    super.onGroupProfileUpdated(groupJid);
    Log("super", groupJid.toString());
    updateRecentChat(groupJid);
  }

  @override
  void onNewMemberAddedToGroup(event){
    super.onNewMemberAddedToGroup(event);

  }
  @override
  void onMemberRemovedFromGroup(event){
    super.onMemberRemovedFromGroup(event);
  }
  @override
  void onFetchingGroupMembersCompleted(event){
    super.onFetchingGroupMembersCompleted(event);
  }
  @override
  void onDeleteGroup(groupJid){
    super.onDeleteGroup(groupJid);
    updateRecentChat(groupJid);
  }
  @override
  void onFetchingGroupListCompleted(event){
    super.onFetchingGroupListCompleted(event);
  }
  @override
  void onMemberMadeAsAdmin(event){
    super.onMemberMadeAsAdmin(event);
  }
  @override
  void onMemberRemovedAsAdmin(event){
    super.onMemberRemovedAsAdmin(event);
  }
  @override
  void onLeftFromGroup({required String groupJid,required String userJid}){
    super.onLeftFromGroup(groupJid: groupJid, userJid: userJid);
  }
  @override
  void onGroupNotificationMessage(event){
    super.onGroupNotificationMessage(event);
  }
  @override
  void onGroupDeletedLocally(groupJid){
    super.onGroupDeletedLocally(groupJid);
    updateRecentChat(groupJid);
  }

}
