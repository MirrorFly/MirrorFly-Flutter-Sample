import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/base_controller.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/data/session_management.dart';

import 'package:flysdk/flysdk.dart';
import 'package:intl/intl.dart';

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
  @override
  void onInit() {
    super.onInit();
    recentChats.bindStream(recentChats.stream);
    ever(recentChats, (callback) => unReadCount());
    ever(archivedChats, (callback) => archivedChatCount());
    getArchivedChatsList();
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
      recentChats.addAll(data.data!);
    }).catchError((error) {
      debugPrint("issue===> $error");
    });
  }

  getArchivedChatsList() {
    FlyChat.getArchivedChatList().then((value) {
      var data = recentChatFromJson(value);
      archivedChats.clear();
      archivedChats.addAll(data.data!);
    }).catchError((error) {
      debugPrint("issue===> $error");
    });
  }

  toChatPage(String jid) async {
    if(jid.isNotEmpty) {
      Helper.progressLoading();
      var value = await FlyChat.getProfileDetails(jid, false);//.then((value) {
        if(value!=null){
          Helper.hideLoading();
          var profile =  profiledata(value.toString());
          Get.toNamed(Routes.chat, arguments: profile);
        }
      //});
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
    for (var p0 in recentChats) {
      if(p0.isConversationUnRead!){
        _unreadCount(((p0.isConversationUnRead!) ? 1+_unreadCount.value : 0 +_unreadCount.value));
      }
    }
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
    debugPrint("my update index $index");
    getRecentChatOfJid(jid).then((recent){
      if(recent!=null){
        if (index.isNegative) {
          recentChats.add(recent);
        } else {
          var lastPinnedChat = recentChats.lastIndexWhere((element) => element.isChatPinned!);
          var nxtIndex = lastPinnedChat.isNegative ? 0 : (lastPinnedChat+1);
          mirrorFlyLog("lastPinnedChat", lastPinnedChat.toString());
          if(recentChats[index].isChatPinned!){
            recentChats.removeAt(index);
            recentChats.insert(index, recent);
          }else {
            recentChats.removeAt(index);
            recentChats.insert(nxtIndex, recent);
          }
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
        FlyChat.isMemberOfGroup(item.jid.checkNull(),null).then((value) => delete(value));
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
  pinChats(){
    if(selectedChats.length==1){
      _itemPin(0);
      clearAllChatSelection();
    }else{
      selected(false);
      for (var index =0;index<selectedChats.length;index++) {
        _itemPin(index);
      }
      clearAllChatSelection();
    }
  }

  unPinChats(){
    if(selectedChats.length==1){
      _itemUnPin(0);
      clearAllChatSelection();
    }else{
      selected(false);
      selectedChats.asMap().forEach((key, value) {_itemUnPin(key);});
      clearAllChatSelection();
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
    }else{
      selected(false);
      selectedChats.asMap().forEach((key, value) {_itemUnMute(key);});
      clearAllChatSelection();
    }
  }

  archiveChats(){
    if(selectedChats.length==1){
      _itemArchive(0);
      clearAllChatSelection();
    }else{
      selected(false);
      selectedChats.asMap().forEach((key, value) {_itemArchive(key);});
      clearAllChatSelection();
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
    var chatIndex = recentChats.indexWhere((element) => selectedChats[index] == element.jid);//selectedChatsPosition[index];
    //recentChats[chatIndex].isChatPinned=(true);
    var change = recentChats[chatIndex];
    change.isChatPinned=true;
    recentChats.removeAt(chatIndex);
    recentChats.insert(0, change);
    FlyChat.updateRecentChatPinStatus(selectedChats[index], true);
  }

  _itemUnPin(int index){
    var chatIndex = recentChats.indexWhere((element) => selectedChats[index] == element.jid);//selectedChatsPosition[index];
    //recentChats[chatIndex].isChatPinned=(false);
    var lastPinnedChat = recentChats.lastIndexWhere((element) => element.isChatPinned!);
    mirrorFlyLog("lastPinnedChat", lastPinnedChat.toString());
    var nxtIndex = lastPinnedChat.isNegative ? chatIndex : (lastPinnedChat);
    var change = recentChats[chatIndex];
    change.isChatPinned=false;
    recentChats.removeAt(chatIndex);
    recentChats.insert(nxtIndex, change);
    FlyChat.updateRecentChatPinStatus(selectedChats[index], false);
  }

  _itemMute(int index){
    var chatIndex = recentChats.indexWhere((element) => selectedChats[index] == element.jid);//selectedChatsPosition[index];
    recentChats[chatIndex].isMuted=(true);
    FlyChat.updateChatMuteStatus(selectedChats[index], true);
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

  itemsRead(){
    selected(false);
    FlyChat.markConversationAsRead(selectedChats);
    for (var element in selectedChatsPosition) {
      recentChats[element].unreadMessageCount=0;
    }
    clearAllChatSelection();
    updateUnReadChatCount();
  }

  itemsUnRead(){
    selected(false);
    FlyChat.markConversationAsUnread(selectedChats);
    for (var element in selectedChatsPosition) {
      recentChats[element].unreadMessageCount=1;
    }
    clearAllChatSelection();
    updateUnReadChatCount();
  }

  _itemArchive(int index){
    var chatIndex = recentChats.indexWhere((element) => selectedChats[index] == element.jid);//selectedChatsPosition[index];
    recentChats[chatIndex].isChatArchived=(true);
    recentChats.removeAt(chatIndex);
    FlyChat.updateArchiveUnArchiveChat(selectedChats[index], true);
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
