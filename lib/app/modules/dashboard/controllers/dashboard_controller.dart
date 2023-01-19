import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/base_controller.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/common/main_controller.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/data/session_management.dart';

import 'package:flysdk/flysdk.dart';
import 'package:intl/intl.dart';
import 'package:mirror_fly_demo/app/modules/archived_chats/archived_chat_list_controller.dart';

import '../../../data/apputils.dart';
import '../../../routes/app_pages.dart';

class DashboardController extends GetxController with GetTickerProviderStateMixin, BaseController {
  var recentChats = <RecentChatData>[].obs;
  var archivedChats = <RecentChatData>[].obs;
  var calendar = DateTime.now();
  var selectedChats = <String>[].obs;
  var selectedChatsPosition = <int>[].obs;
  var selected = false.obs;

  //action icon visibles
  var archive = false.obs;
  var pin = false.obs;
  var unpin = false.obs;
  var mute = false.obs;
  var unmute = false.obs;
  var read = false.obs;
  var unread = false.obs;
  var delete = false.obs;
  var info = false.obs;
  var shortcut = false.obs;

  var archiveSettingEnabled = false.obs;
  @override
  void onInit() {
    super.onInit();
    recentChats.bindStream(recentChats.stream);
    ever(recentChats, (callback) => unReadCount());
    archivedChats.bindStream(archivedChats.stream);
    ever(archivedChats, (callback) => archivedChatCount());
    getArchivedChatsList();
    checkArchiveSetting();
  }

  checkArchiveSetting(){
    FlyChat.isArchivedSettingsEnabled().then((value) => archiveSettingEnabled(value));
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
    FlyChat.getRecentChatList().then((value) async {
      // String recentList = value.replaceAll('\n', '\\n');
      // debugPrint(recentList);
      var data = await compute(recentChatFromJson,value.toString());
      //recentChats.clear();
      recentChats(data.data!);
      recentChats.refresh();
    }).catchError((error) {
      debugPrint("recent chat issue===> $error");
    });
  }

  getArchivedChatsList() async {
    await FlyChat.getArchivedChatList().then((value) {
      mirrorFlyLog("archived", value.toString());
      var data = recentChatFromJson(value);
      archivedChats(data.data!);
    }).catchError((error) {
      debugPrint("issue===> $error");
    });
  }

  toChatPage(String jid) async {
    if(jid.isNotEmpty) {
      // Helper.progressLoading();
      await FlyChat.getProfileDetails(jid, false).then((value) {
        if(value!=null){
          Helper.hideLoading();
          debugPrint("Dashboard Profile===>$value");
          var profile =  profiledata(value.toString());
          Get.toNamed(Routes.chat, arguments: profile);
        }
      });
      // SessionManagement.setChatJid(jid);
      // Get.toNamed(Routes.chat);
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
    Get.offAllNamed(Routes.login);
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
  String get unreadCountString => returnFormattedCount(_unreadCount.value);
  set unreadCount(int val) => _unreadCount.value = val;
  
  unReadCount(){
    _unreadCount(0);
    recentPinnedCount(0);
    for (var p0 in recentChats) {
      if(p0.isConversationUnRead!){
        _unreadCount(((p0.isConversationUnRead!) ? 1+_unreadCount.value : 0 +_unreadCount.value));
      }
      if(p0.isChatPinned.checkNull()){
        recentPinnedCount(recentPinnedCount.value+1);
      }
    }
    /*mirrorFlyLog("recentPinned", recentChats.where((element) => (element.isChatPinned.checkNull()==true)).join(","));
    recentPinnedCount(recentChats.where((element) => (element.isChatPinned.checkNull()==true)).length);*/
  }

  final _archivedCount = 0.obs;
  String get archivedCount => returnFormattedCount(_archivedCount.value);
  archivedChatCount(){
    _archivedCount(0);
    for (var p0 in archivedChats) {
      if(p0.isConversationUnRead!){
        _archivedCount(((p0.isConversationUnRead!) ? 1+_archivedCount.value : 0 +_archivedCount.value));
      }
    }
  }

  updateRecentChat(String jid){
    final index = recentChats.indexWhere((chat) => chat.jid == jid);
    getRecentChatOfJid(jid).then((recent){
      if(recent!=null){
        if(!recent.isChatArchived.checkNull()) {
          if (index.isNegative) {
            recentChats.insert(0, recent);
          } else {
            var lastPinnedChat = recentChats.lastIndexWhere((element) =>
            element.isChatPinned!);
            var nxtIndex = lastPinnedChat.isNegative ? 0 : (lastPinnedChat + 1);
            if (recentChats[index].isChatPinned!) {
              recentChats.removeAt(index);
              recentChats.insert(index, recent);
            } else {
              recentChats.removeAt(index);
              recentChats.insert(nxtIndex, recent);
              recentChats.refresh();
            }
          }
        }else{
          if (!index.isNegative) {
            recentChats.removeAt(index);
          }
          if(Get.isRegistered<ArchivedChatListController>()) {
            Get.find<ArchivedChatListController>().checkArchiveList(recent);
          }
          checkArchiveList(recent);
        }
      }else{
        if (!index.isNegative) {
          recentChats.removeAt(index);
        }
      }
      recentChats.refresh();
    });
  }

  void checkArchiveList(RecentChatData recent) async {
    await FlyChat.isArchivedSettingsEnabled().then((value){
      if(value.checkNull()){
        var archiveIndex = archivedChats.indexWhere((element) => recent.jid==element.jid);
        if(!archiveIndex.isNegative){
          archivedChats.removeAt(archiveIndex);
          archivedChats.insert(0, recent);
        }else{
          archivedChats.insert(0,recent);
        }
      }else{
        var archiveIndex = archivedChats.indexWhere((element) => recent.jid==element.jid);
        if(!archiveIndex.isNegative){
          archivedChats.removeAt(archiveIndex);
          var lastPinnedChat = recentChats.lastIndexWhere((element) =>
          element.isChatPinned!);
          var nxtIndex = lastPinnedChat.isNegative ? 0 : (lastPinnedChat + 1);
          mirrorFlyLog("lastPinnedChat", lastPinnedChat.toString());
          recentChats.insert(nxtIndex, recent);
        }
      }
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
              () => Get.toNamed(Routes.webLoginResult));
    }else{
      Future.delayed(const Duration(milliseconds: 100),
              () => Get.toNamed(Routes.scanner));
    }
  }

  gotoSearch(){
    Future.delayed(const Duration(milliseconds: 100), ()
    {
      Get.toNamed(Routes.recentSearch,
          arguments: {
            "recents": recentChats
          });
    });
  }

  gotoCreateGroup(){
    Future.delayed(
        const Duration(milliseconds: 100),
            () => Get.toNamed(Routes.createGroup));
  }

  gotoSettings(){
    Future.delayed(
        const Duration(milliseconds: 100),
            () => Get.toNamed(Routes.settings));
  }

  chatInfo() async {
    var chatIndex = recentChats.indexWhere((element) => selectedChats.first == element.jid);//selectedChatsPosition[index];
    var item = recentChats[chatIndex];
    Helper.progressLoading();
    clearAllChatSelection();
    await FlyChat.getProfileDetails(item.jid.checkNull(), false).then((value) {
      if (value != null) {
        Helper.hideLoading();
        var profile =  profiledata(value.toString());
        if(item.isGroup!){
          Future.delayed(const Duration(milliseconds: 100),
                  () => Get.toNamed(Routes.groupInfo,arguments: profile));
        }else{
          Future.delayed(const Duration(milliseconds: 100),
                  () => Get.toNamed(Routes.chatInfo,arguments: profile));
        }
      }
    });
  }

  isSelected(int index) => selectedChats.contains(recentChats[index].jid);

  selectOrRemoveChatfromList(int index){
    if(selected.isTrue) {
      if (selectedChats.contains(recentChats[index].jid)) {
        selectedChats.remove(recentChats[index].jid.checkNull());
        selectedChatsPosition.remove(index);
      } else {
        selectedChats.add(recentChats[index].jid.checkNull());
        selectedChatsPosition.add(index);
      }
    }
    if(selectedChats.isEmpty){
      clearAllChatSelection();
    }else{
      menuValidationForItem();
    }
  }

  clearAllChatSelection(){
    selected(false);
    selectedChats.clear();
    archive(false);
    pin(false);
    unpin(false);
    mute(false);
    unmute(false);
    read(false);
    unread(false);
    delete(false);
    info(false);
    shortcut(false);
    update();
  }

  menuValidationForPinIcon(){
    var checkListForPinIcon = <bool>[];
    var selected = recentChats.where((p0) => selectedChats.contains(p0.jid));
    for (var value in selected) {
      checkListForPinIcon.add(value.isChatPinned!);
    }
    if(checkListForPinIcon.contains(false)){//pin able
      pin(true);
      unpin(false);
    }else{
      pin(false);
      unpin(true);
    }
    //return checkListForPinIcon.contains(false);//pin able
  }

  menuValidationForDeleteIcon() async {
    var selected = recentChats.where((p0) => selectedChats.contains(p0.jid));
    delete(true);
    for (var item in selected) {
      var isMember = await FlyChat.isMemberOfGroup(item.jid.checkNull(),null);
      if((item.getChatType() == Constants.typeGroupChat) && isMember!){
        delete(false);
        return;
        //return false;
      }
    }
    //return true;
  }

  menuValidationForMuteUnMuteIcon(){
    var checkListForMuteUnMuteIcon = <bool>[];
    var selected = recentChats.where((p0) => selectedChats.contains(p0.jid));
    for (var value in selected) {
      if(!value.isBroadCast!) {
        checkListForMuteUnMuteIcon.add(value.isMuted.checkNull());
      }
    }
    if(checkListForMuteUnMuteIcon.contains(false)){// Mute able
      mute(true);
      unmute(false);
    }else if (checkListForMuteUnMuteIcon.contains(true)){
      mute(false);
      unmute(true);
    }else{
      mute(false);
      unmute(false);
    }
    //return checkListForMuteUnMuteIcon.contains(false);// Mute able
  }

  menuValidationForMarkReadUnReadIcon(){
    var checkListForReadUnReadIcon = <bool>[];
    var selected = recentChats.where((p0) => selectedChats.contains(p0.jid));
    for (var value in selected) {
      checkListForReadUnReadIcon.add(value.isConversationUnRead.checkNull());
    }
    if(!checkListForReadUnReadIcon.contains(true)){//Mark as Read Able
      read(false);
      unread(true);
    }else{
      read(true);
      unread(false);
    }
    //return !checkListForReadUnReadIcon.contains(true);//Mark as Read Able
  }

  menuValidationForItem() {
    mirrorFlyLog("selectedChats", selectedChats.length.toString());
    archive(true);
    if(selectedChats.length==1){
      var item = recentChats.firstWhere((element) => selectedChats.first ==element.jid);
      info(true);
      pin(!item.isChatPinned!);
      unpin(item.isChatPinned!);
      if(Constants.typeBroadcastChat!= item.getChatType()){
        unmute(item.isMuted!);
        mute(!item.isMuted!);
        shortcut(true);
      }else{
        unmute(false);
        mute(false);
        shortcut(false);
      }
      read(item.isConversationUnRead);
      unread(!item.isConversationUnRead!);
      delete(Constants.typeGroupChat!= item.getChatType());
      if(item.getChatType() == Constants.typeGroupChat){
        mirrorFlyLog("isGroup", item.isGroup!.toString());
        FlyChat.isMemberOfGroup(item.jid.checkNull(),null).then((value) => delete(!value!));
      }
    }else {
      info(false);
      menuValidationForPinIcon();
      /*var pinValid = menuValidationForPinIcon();
      pin(pinValid);
      unpin(!pinValid);*/
      menuValidationForMuteUnMuteIcon();
      /*var muteValid = menuValidationForMuteUnMuteIcon();
      mute(muteValid);
      unmute(!muteValid);*/
      menuValidationForMarkReadUnReadIcon();
      /*var readValid = menuValidationForMarkReadUnReadIcon();
      read(readValid);
      unread(!readValid);*/
      menuValidationForDeleteIcon();//.then((value) => delete(value));
    }

  }

  var recentPinnedCount = 0.obs;
  pinChats(){
    if(isSelectedPositionsValidForPin()) {
      mirrorFlyLog("pinChat", "isSelectedPositionsValidForPin");
      if (selectedChats.length == 1) {
        _itemPin(0);
        clearAllChatSelection();
        toToast("Chat pinned");
      } else {
        selected(false);
        for (var index = 0; index < selectedChats.length; index++) {
          var selectedChat = recentChats.indexWhere((p0) => p0.jid==selectedChats[index] && p0.isChatPinned.checkNull());
          if(selectedChat.isNegative) {
            mirrorFlyLog("pinChat", "$selectedChat selected chat is have to pinned");
            _itemPin(index);
          }else{
            mirrorFlyLog("pinChat", "$selectedChat selected chat is already pinned");
          }
        }
        clearAllChatSelection();
        toToast("Chats pinned");
      }
    }else{
      toToast("You can only pin upto 3 chats");
    }
  }

  bool isSelectedPositionsValidForPin(){
    var pinnedListPosition = selectedChats;
    var validPositions = 0; //selected non pinned items
    mirrorFlyLog("selectedchats", pinnedListPosition.join(","));
    mirrorFlyLog("recentPinnedCount", recentPinnedCount.toString());
    for (var value in pinnedListPosition) {
      var valid = recentChats.firstWhere((p0) => p0.jid == value);// check, is non pinned item
      if(!valid.isChatPinned.checkNull()){
         validPositions= validPositions+1;
      }
    }
    /*for (position in pinnedListPosition) {
      if (position >= recentPinnedCount) // check, is non pinned item
        validPositions++;
    }*/
    //mirrorFlyLog("validPositions", "$validPositions");
    var count = recentPinnedCount.value + validPositions;
    if (count <= 3) {
      return true;
    }
    var count2 = recentPinnedCount.value + pinnedListPosition.length;
    if (count2 <= 3) {
      return true;
    }
    return false;
  }

  unPinChats(){
    if(selectedChats.length==1){
      _itemUnPin(0);
      clearAllChatSelection();
      toToast("Chat unpinned");
    }else{
      selected(false);
      selectedChats.asMap().forEach((key, value) {_itemUnPin(key);});
      clearAllChatSelection();
      toToast("Chats unpinned");
    }
  }

  muteChats(){
    if(selectedChats.length==1){
      _itemMute(0);
      clearAllChatSelection();
    }else{
      selected(false);
      selectedChats.asMap().forEach((key, value) {_itemMute(key);});
      clearAllChatSelection();
    }
  }

  unMuteChats(){
    if(selectedChats.length==1){
      _itemUnMute(0);
      clearAllChatSelection();
    }else{
      selected(false);
      selectedChats.asMap().forEach((key, value) {_itemUnMute(key);});
      clearAllChatSelection();
    }
  }

  markAsRead(){
    if(selectedChats.length==1){
      _itemUnMute(0);
      clearAllChatSelection();
      toToast("Chat marked as read");
    }else{
      selected(false);
      selectedChats.asMap().forEach((key, value) {_itemUnMute(key);});
      clearAllChatSelection();
      toToast("Chats marked as read");
    }
  }

  archiveChats() async {
    if(await AppUtils.isNetConnected()) {
      if(selectedChats.length==1){
        _itemArchive(0);
        clearAllChatSelection();
      }else{
        selected(false);
        selectedChats.asMap().forEach((key, value) {_itemArchive(key);});
        clearAllChatSelection();
      }
    }else{
      toToast(Constants.noInternetConnection);
    }
  }

  deleteChats(){
    if(selectedChats.length==1){
      _itemDelete(0);
      clearAllChatSelection();
    }else{
      itemsDelete();
      clearAllChatSelection();
    }
  }

  _itemPin(int index){
    FlyChat.updateRecentChatPinStatus(selectedChats[index], true);
    var chatIndex = recentChats.indexWhere((element) => selectedChats[index] == element.jid);//selectedChatsPosition[index];
    //recentChats[chatIndex].isChatPinned=(true);
    var change = recentChats[chatIndex];
    change.isChatPinned=true;
    recentChats.removeAt(chatIndex);
    recentChats.insert(0, change);
  }

  _itemUnPin(int index){
    FlyChat.updateRecentChatPinStatus(selectedChats[index], false);
    var chatIndex = recentChats.indexWhere((element) => selectedChats[index] == element.jid);//selectedChatsPosition[index];
    //recentChats[chatIndex].isChatPinned=(false);
    var lastPinnedChat = recentChats.lastIndexWhere((element) => element.isChatPinned!);
    mirrorFlyLog("lastPinnedChat", lastPinnedChat.toString());
    var nxtIndex = lastPinnedChat.isNegative ? chatIndex : (lastPinnedChat);
    var change = recentChats[chatIndex];
    change.isChatPinned=false;
    recentChats.removeAt(chatIndex);
    recentChats.insert(nxtIndex, change);
  }

  _itemMute(int index){
    FlyChat.updateChatMuteStatus(selectedChats[index], true);
    var chatIndex = recentChats.indexWhere((element) => selectedChats[index] == element.jid);//selectedChatsPosition[index];
    recentChats[chatIndex].isMuted=(true);
  }

  _itemUnMute(int index){
    var chatIndex = recentChats.indexWhere((element) => selectedChats[index] == element.jid);//selectedChatsPosition[index];
    recentChats[chatIndex].isMuted=(false);
    FlyChat.updateChatMuteStatus(selectedChats[index], false);
  }

  /*_itemRead(int index){
    var chatIndex = recentChats.indexWhere((element) => selectedChats[index] == element.jid);//selectedChatsPosition[index];
    recentChats[chatIndex].isMuted=(false);
    FlyChat.markAsRead(selectedChats[index]);
    updateUnReadChatCount();
  }*/

  itemsRead() async {
    if(await AppUtils.isNetConnected()) {
      selected(false);
      FlyChat.markConversationAsRead(selectedChats);
      for (var element in selectedChatsPosition) {
        recentChats[element].isConversationUnRead=false;
        recentChats[element].unreadMessageCount=0;
      }
      clearAllChatSelection();
      updateUnReadChatCount();
    }else{
      toToast(Constants.noInternetConnection);
    }

  }

  itemsUnRead(){
    selected(false);
    FlyChat.markConversationAsUnread(selectedChats);
    for (var element in selectedChatsPosition) {
      recentChats[element].isConversationUnRead=true;
    }
    toToast("Chat${selectedChats.length==1 ? "" : "s"} marked as unread");
    clearAllChatSelection();
    updateUnReadChatCount();
  }

  _itemArchive(int index){
    FlyChat.updateArchiveUnArchiveChat(selectedChats[index], true);
    var chatIndex = recentChats.indexWhere((element) => selectedChats[index] == element.jid);//selectedChatsPosition[index];
    recentChats[chatIndex].isChatArchived=(true);
    //getArchivedChatsList();
    if(archivedChats.isEmpty){
      archivedChats([recentChats[chatIndex]]);
    }else {
      archivedChats.add(recentChats[chatIndex]);
    }
    recentChats.removeAt(chatIndex);
  }

  _itemDelete(int index){
    var chatIndex = recentChats.indexWhere((element) => selectedChats[index] == element.jid);//selectedChatsPosition[index];
    recentChats.removeAt(chatIndex);
    FlyChat.deleteRecentChat(selectedChats[index]);
  }

  itemsDelete(){
    selected(false);
    FlyChat.deleteRecentChats(selectedChats);
    for (var element in selectedChatsPosition) {
      recentChats.removeAt(element);
    }
    clearAllChatSelection();
    updateUnReadChatCount();
  }

  updateUnReadChatCount(){
    /*FlyChat.getUnreadMessagesCount().then((value){
      if(value!=null) {
        _unreadCount(value);
      }
    });*/
    unReadCount();
  }
  
  @override
  void onMessageReceived(chatMessage){
    mirrorFlyLog("dashboard controller", "onMessageReceived");
    super.onMessageReceived(chatMessage);
    ChatMessageModel chatMessageModel = sendMessageModelFromJson(chatMessage);
    updateRecentChat(chatMessageModel.chatUserJid);
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

  var typingAndGoneStatus = <Triple>[].obs;
  String typingUser(String jid){
    var index = typingAndGoneStatus.indexWhere((it) => it.singleOrgroupJid ==jid);
    if(index.isNegative) {
      return "";
    }else {
      return typingAndGoneStatus[index].userId.isNotEmpty ? typingAndGoneStatus[index].userId : typingAndGoneStatus[index].singleOrgroupJid;
    }
  }
  @override
  void setTypingStatus(String singleOrgroupJid, String userId, String typingStatus) {
    super.setTypingStatus(singleOrgroupJid, userId, typingStatus);
    var index = typingAndGoneStatus.indexWhere((it) => it.singleOrgroupJid ==singleOrgroupJid && it.userId == userId);
    if(typingStatus.toLowerCase() == Constants.composing){
      if(index.isNegative){
        typingAndGoneStatus.insert(0, Triple(singleOrgroupJid, userId, true));
      }
    }else{
      if(!index.isNegative){
        typingAndGoneStatus.removeAt(index);
      }
    }
    if(Get.isRegistered<ArchivedChatListController>()){
      Get.find<ArchivedChatListController>().setTypingStatus(singleOrgroupJid,userId,typingStatus);
    }
  }
  @override
  void onAdminBlockedUser(String jid, bool status) {
    super.onAdminBlockedUser(jid,status);
    mirrorFlyLog("dash onAdminBlockedUser", "$jid, $status");
    Get.find<MainController>().handleAdminBlockedUser(jid,status);
  }
}
