import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../call_modules/call_utils.dart';
import '../../../common/app_localizations.dart';
import '../../../common/constants.dart';
import '../../../data/helper.dart';
import '../../../data/session_management.dart';
import '../../../extensions/extensions.dart';
import '../../../model/arguments.dart';
import '../../../modules/notification/notification_builder.dart';
import '../../../stylesheet/stylesheet.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';
import 'package:mirrorfly_plugin/model/call_log_model.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../app_style_config.dart';
import '../../../call_modules/meet_sheet_view.dart';
import '../../../common/de_bouncer.dart';
import '../../../common/main_controller.dart';
import '../../../data/permissions.dart';
import '../../../data/utils.dart';
import '../../../model/chat_message_model.dart';
import '../../../routes/route_settings.dart';

class DashboardController extends FullLifeCycleController
    with FullLifeCycleMixin, GetTickerProviderStateMixin {
  var availableFeatures = AvailableFeatures().obs;
  var chatLimit = 20;
  var recentChats = <RecentChatData>[].obs;
  var archivedChats = <RecentChatData>[].obs;
  var calendar = DateTime.now();
  var selectedChats = <String>[].obs;
  var selectedChatsPosition = <int>[].obs;
  var selected = false.obs;

  var profile_ = ProfileDetails().obs;

  ProfileDetails get profile => profile_.value;

  //action icon visibility handlers
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

  var archiveSettingEnabled = true.obs;

  ScrollController historyScrollController = ScrollController();

  RxBool isRecentHistoryLoading = false.obs;
  int recentChatPage = 1;

  TabController? tabController;

  RxInt currentTab = 0.obs;

  // Number of tabs
  static const tabsCount = 2;
  static const initialIndex = 0;

  // List with current scales for each tab's fab
  // Initialize with 1.0 for initial opened tab, 0.0 for others
  final tabScales =
      List.generate(tabsCount, (index) => index == initialIndex ? 1.0 : 0.0)
          .obs;

  var isLastPage = false.obs;
  late int pageNumber;
  var error = false.obs;
  var loading = true.obs;
  var totalPages = 0;

  var selectedLog = false.obs;
  var selectedCallLogs = <String>[].obs;
  var selectedCallLogsPosition = <int>[].obs;

  //final _unreadCallCount = 0.obs;

  //String get unreadCallCountString => returnFormattedCount(_unreadCallCount.value);

  //set unreadCount(int val) => _unreadCount.value = val;

  var unreadCallCount = Get.find<MainController>().unreadCallCount;

  String get unreadCallCountString =>
      returnFormattedCount(unreadCallCount.value);

  late DashboardViewArguments? arguments;

  @override
  void onInit() {
    arguments = NavUtils.arguments as DashboardViewArguments?;
    tabController = TabController(length: 2, vsync: this);
    if ((arguments?.didMissedCallNotificationLaunchApp).checkNull()) {
      tabController?.animateTo(1);
    }
    tabController?.animation?.addListener(() {
      LogMessage.d("DefaultTabController", "${tabController?.index}");

      // Current animation value. It ranges from 0 to (tabsCount - 1)
      final animationValue = tabController?.animation!.value;
      LogMessage.d("animationValue", "$animationValue");
      // Simple rounding gives us understanding of what tab is showing
      final currentTabIndex = animationValue?.round();
      LogMessage.d("currentTabIndex animation listener", "$currentTabIndex");
      currentTab(currentTabIndex);
      // currentOffset equals 0 when tabs are not swiped
      // currentOffset ranges from -0.5 to 0.5
      final currentOffset = currentTabIndex! - animationValue!;
      for (int i = 0; i < tabsCount; i++) {
        if (i == currentTabIndex) {
          // For current tab bringing currentOffset to range from 0.0 to 1.0
          tabScales[i] = (0.5 - currentOffset.abs()) / 0.5;
        } else {
          // For other tabs setting scale to 0.0
          tabScales[i] = 0.0;
        }
      }
    });
    //The above animation listener is called multiple time till the animation gets over, this listener is called minimal time when compared to above
    tabController?.addListener(() {
      LogMessage.d("currentTabIndex default listener", "$currentTab");
      clearAllChatSelection();
      if (currentTab.value == 1) {
        markAllUnreadMissedCallsAsRead();
      }
    });
    pageNumber = 1;
    getWebLoginDetails();
    Mirrorfly.syncCallLogs().then((isSuccess) {
      debugPrint("#MirrorflyCall syncCallLogs isSuccess $isSuccess");
    });
    super.onInit();
  }

  markAllUnreadMissedCallsAsRead() async {
    if (unreadCallCount.value > 0) {
      var result = await Mirrorfly.markAllUnreadMissedCallsAsRead();
      debugPrint("(markAllUnreadMissedCallsAsRead result $result");
      unreadCallCount(0);
    }
  }

  // unreadMissedCallCount() async {
  //   var unreadMissedCallCount = await Mirrorfly.getUnreadMissedCallCount();
  //   _unreadCallCount.value = unreadMissedCallCount!;
  //   debugPrint("unreadMissedCallCount $unreadMissedCallCount");
  // }

  @override
  void onReady() {
    super.onReady();
    getAvailableFeatures();
    debugPrint("DashboardController onReady");
    createTopic();
    recentChats.bindStream(recentChats.stream);
    ever(recentChats, (callback) => unReadCount());
    archivedChats.bindStream(archivedChats.stream);
    ever(archivedChats, (callback) => archivedChatCount());
    if (!Constants.enableTopic) {
      getRecentChatList();
    }
    getArchivedChatsList();
    // checkArchiveSetting();
    userlistScrollController.addListener(_scrollListener);
    historyScrollController.addListener(historyScrollListener);
    fetchCallLogList();
    callLogScrollController.addListener(_callLogScrollListener);
  }

  void getAvailableFeatures() {
    Mirrorfly.getAvailableFeatures().then((features) {
      debugPrint("getAvailableFeatures $features");
      var featureAvailable = availableFeaturesFromJson(features);
      availableFeatures(featureAvailable);
    });
  }

  infoPage(ProfileDetails profile) {
    if (profile.isGroupProfile ?? false) {
      NavUtils.toNamed(Routes.groupInfo, arguments: profile)?.then((value) {
        if (value != null) {
          // profile_(value as Profile);
          // isBlocked(profile.isBlocked);
          // checkAdminBlocked();
          // memberOfGroup();
          // Mirrorfly.setOnGoingChatUser(profile.jid!);
          // getChatHistory();
          // sendReadReceipt();
        }
      });
    } else {
      NavUtils.toNamed(Routes.chatInfo,
              arguments: ChatInfoArguments(chatJid: profile.jid.checkNull()))
          ?.then((value) {});
    }
  }

  checkArchiveSetting() {
    Mirrorfly.isArchivedSettingsEnabled()
        .then((value) => archiveSettingEnabled(value));
  }

  Future<RecentChatData?> getRecentChatOfJid(String jid) async {
    var value = await Mirrorfly.getRecentChatOf(jid: jid);
    // LogMessage.d("chat", value.toString());
    if (value.isNotEmpty) {
      var data = RecentChatData.fromJson(json.decode(value));
      return data;
    } else {
      return null;
    }
  }

  var recentChatLoading = true.obs;

  getRecentChatList() {
    recentChatPage = 1;
    callback(FlyResponse response) {
      if (response.isSuccess && response.hasData) {
        LogMessage.d("getRecentChatListHistory", response.data);
        var data = recentChatFromJson(response
            .data); //await compute(recentChatFromJson, value.toString());
        recentChats.clear();
        recentChats(data.data!);
        recentChats.refresh();
        isRecentHistoryLoading(false);
        recentChatLoading(false);
        getArchivedChatsList();
      } else {
        debugPrint("recent chat issue===> ${response.exception}");
        recentChatLoading(false);
      }
    }

    Constants.enableTopic
        ? Mirrorfly.getRecentChatListHistoryByTopic(
            firstSet: recentChatPage == 1,
            limit: chatLimit,
            topicId: topicId.value,
            flyCallback: callback)
        : Mirrorfly.getRecentChatListHistory(
            firstSet: recentChatPage == 1,
            limit: chatLimit,
            flyCallback: callback);
    /*LogMessage.d("", "recent chats");
    Mirrorfly.getRecentChatList().then((value) async {
      // String recentList = value.replaceAll('\n', '\\n');
      // debugPrint(recentList);
      var data = await compute(recentChatFromJson, value.toString());
      //recentChats.clear();
      recentChats(data.data!);
      recentChats.refresh();
      recentChatLoading(false);
    }).catchError((error) {
      debugPrint("recent chat issue===> $error");
      recentChatLoading(false);
    });*/
  }

  getArchivedChatsList() async {
    await Mirrorfly.getArchivedChatList(flyCallBack: (FlyResponse response) {
      LogMessage.d("archived", response.toString());
      if (response.isSuccess && response.hasData) {
        var data = recentChatFromJson(response.data);
        archivedChats(data.data!);
      }
    });
  }

  toChatPage(String jid) {
    if (jid.isNotEmpty) {
      ///Future delayed is added here, as the chat page is opened and closed by QA team rapidly and repeatedly.
      ///So to avoid the controller delete after new controller created with same jid, added this delay.
      Future.delayed(
          const Duration(milliseconds: 200),
          () => NavUtils.toNamed(Routes.chat,
              arguments: ChatViewArguments(
                  chatJid: jid,
                  topicId: topicId.value,
                  enableSwipeToReply: true)));
      // NavUtils.toNamed(Routes.chat, arguments: ChatViewArguments(chatJid: jid,topicId: topicId.value));
      // DialogUtils.progressLoading();
      /*getProfileDetails(jid).then((value) {
        if (value.jid != null) {
          DialogUtils.hideLoading();
          // recentChats.firstWhere((element) => element.jid==jid).isConversationUnRead=false;
          // debugPrint("Dashboard Profile===>$value");
          var profile = value;//profiledata(value.toString());
          NavUtils.toNamed(Routes.chat, arguments: profile);
        }
      });*/
      // SessionManagement.setChatJid(jid);
      // NavUtils.toNamed(Routes.chat);
    }
  }

  logout() {
    SessionManagement.clear();
    NavUtils.offAllNamed(Routes.login);
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
    return (equalsWithYesterday(calendar, getTranslated("today")))
        ? hourTime
        : (equalsWithYesterday(calendar, getTranslated("yesterday")))
            ? getTranslated("yesterday").toUpperCase()
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
    var yesterday = (day == getTranslated("yesterday"))
        ? calendar.subtract(const Duration(days: 1))
        : DateTime.now();
    return yesterday.difference(calendar).inDays == 0;
  }

  final _unreadCount = 0.obs;

  String get unreadCountString => returnFormattedCount(_unreadCount.value);

  set unreadCount(int val) => _unreadCount.value = val;

  unReadCount() {
    _unreadCount(0);
    recentPinnedCount(0);
    for (var p0 in recentChats) {
      if (p0.isConversationUnRead!) {
        _unreadCount(((p0.isConversationUnRead!)
            ? 1 + _unreadCount.value
            : 0 + _unreadCount.value));
      }
      if (p0.isChatPinned.checkNull()) {
        recentPinnedCount(recentPinnedCount.value + 1);
      }
    }
    /*LogMessage.d("recentPinned", recentChats.where((element) => (element.isChatPinned.checkNull()==true)).join(","));
    recentPinnedCount(recentChats.where((element) => (element.isChatPinned.checkNull()==true)).length);*/
  }

  final _archivedCount = 0.obs;

  String get archivedCount => returnFormattedCount(_archivedCount.value);

  archivedChatCount() {
    _archivedCount(0);
    for (var p0 in archivedChats) {
      if (p0.isConversationUnRead!) {
        _archivedCount(((p0.isConversationUnRead!)
            ? 1 + _archivedCount.value
            : 0 + _archivedCount.value));
      }
    }
  }

  Future<bool> updateRecentChat(
      {required String jid,
      bool changePosition = true,
      bool newInsertable = false}) async {
    //updateArchiveRecentChat(jid);
    var recent = await getRecentChatOfJid(jid);
    final index = recentChats.indexWhere((chat) => chat.jid == jid);
    debugPrint("dashboard index--> $index");
    LogMessage.d("updateRecentChat", recent?.toJson());
    if (recent != null) {
      if (!recent.isChatArchived.checkNull()) {
        if (index.isNegative && newInsertable) {
          LogMessage.d("updateRecentChat", "New Insert");
          recentChats.insert(0, recent);
        } else {
          if (recentChats[index].isChatPinned.checkNull() || !changePosition) {
            // recentChats.removeAt(index);
            // recentChats.insert(index, recent);
            recentChats.replaceRange(index, index + 1, [recent]);
          } else {
            var lastPinnedChat =
                recentChats.lastIndexWhere((element) => element.isChatPinned!);
            var nxtIndex = lastPinnedChat.isNegative ? 0 : (lastPinnedChat + 1);
            LogMessage.d("updateRecentChat", "next Index $nxtIndex");
            recentChats.removeAt(index);
            recentChats.insert(nxtIndex, recent);
            // recentChats.refresh();
          }
        }
      } else {
        LogMessage.d("updateRecentChat", "Archived $index");
        if (!index.isNegative) {
          recentChats.removeAt(index);
        }
      }
      checkArchiveList(recent);
    } else {
      LogMessage.d("updateRecentChat", "recent chat null insert index $index");
      if (!index.isNegative) {
        recentChats.removeAt(index);
      }
    }
    recentChats.refresh();
    return true;
  }

  updateArchiveRecentChat(String jid) {
    LogMessage.d("archived chat update", jid);
    getRecentChatOfJid(jid).then((recent) {
      final index = archivedChats.indexWhere((chat) => chat.jid == jid);
      if (recent != null) {
        //if(recent.isChatArchived.checkNull()) {
        if (index.isNegative) {
          archivedChats.insert(0, recent);
        } else {
          var lastPinnedChat =
              archivedChats.lastIndexWhere((element) => element.isChatPinned!);
          var nxtIndex = lastPinnedChat.isNegative ? 0 : (lastPinnedChat + 1);
          if (archivedChats[index].isChatPinned!) {
            archivedChats.removeAt(index);
            archivedChats.insert(index, recent);
          } else {
            archivedChats.removeAt(index);
            archivedChats.insert(nxtIndex, recent);
            archivedChats.refresh();
          }
        }
        /*}else{
          if (!index.isNegative) {
            archivedChats.removeAt(index);
          }
          checkArchiveList(recent);
        }*/
      } else {
        if (!index.isNegative) {
          archivedChats.removeAt(index);
        }
      }
      archivedChats.refresh();
    });
  }

  void checkArchiveList(RecentChatData recent) async {
    Mirrorfly.isArchivedSettingsEnabled().then((value) {
      if (value.checkNull()) {
        var archiveIndex =
            archivedChats.indexWhere((element) => recent.jid == element.jid);
        if (!archiveIndex.isNegative) {
          archivedChats.removeAt(archiveIndex);
          archivedChats.insert(0, recent);
        } else {
          if (recent.isChatArchived.checkNull()) {
            archivedChats.insert(0, recent);
          }
        }
      } else {
        var archiveIndex =
            archivedChats.indexWhere((element) => recent.jid == element.jid);
        if (!archiveIndex.isNegative) {
          archivedChats.removeAt(archiveIndex);
          /*var lastPinnedChat = recentChats.lastIndexWhere((element) =>
          element.isChatPinned!);
          var nxtIndex = lastPinnedChat.isNegative ? 0 : (lastPinnedChat + 1);
          LogMessage.d("lastPinnedChat", lastPinnedChat.toString());
          recentChats.insert(nxtIndex, recent);*/
        }
      }
    });
  }

// Commented this bcz this is not used any where
  /*Future<ChatMessageModel?> getMessageOfId(String mid) async {
    var value = await Mirrorfly.getMessageOfId(messageId: mid);
    // LogMessage.d("getMessageOfId recent", value.toString());
    if (value != null) {
      var data = ChatMessageModel.fromJson(json.decode(value.toString()));
      return data;
    } else {
      return null;
    }
  }*/

  webLogin() async {
    if (SessionManagement.getWebLogin()) {
      Future.delayed(const Duration(milliseconds: 100),
          () => NavUtils.toNamed(Routes.webLoginResult));
    } else {
      if (await AppUtils.isNetConnected()) {
        Future.delayed(const Duration(milliseconds: 100),
            () => NavUtils.toNamed(Routes.scanner));
      } else {
        toToast(getTranslated("noInternetConnection"));
      }
    }
  }

  var isSearching = false.obs;

  gotoSearch() {
    isSearching(true);
    // frmRecentChatList(recentChats);
    /*Future.delayed(const Duration(milliseconds: 100), () {
      NavUtils.toNamed(Routes.recentSearch, arguments: {"recents": recentChats});
    });*/
  }

  gotoCreateGroup() {
    Future.delayed(const Duration(milliseconds: 100),
        () => NavUtils.toNamed(Routes.createGroup));
  }

  gotoSettings() {
    Future.delayed(const Duration(milliseconds: 100),
        () => NavUtils.toNamed(Routes.settings));
  }

  chatInfo() {
    var chatIndex = recentChats.indexWhere((element) =>
        selectedChats.first == element.jid); //selectedChatsPosition[index];
    var item = recentChats[chatIndex];
    DialogUtils.progressLoading();
    clearAllChatSelection();
    getProfileDetails(item.jid.checkNull()).then((value) {
      if (value.jid != null) {
        DialogUtils.hideLoading();
        var profile = value; //profiledata(value.toString());
        if (item.isGroup!) {
          Future.delayed(const Duration(milliseconds: 100),
              () => NavUtils.toNamed(Routes.groupInfo, arguments: profile));
        } else {
          Future.delayed(
              const Duration(milliseconds: 100),
              () => NavUtils.toNamed(Routes.chatInfo,
                  arguments:
                      ChatInfoArguments(chatJid: profile.jid.checkNull())));
        }
      }
    });
  }

  isSelected(int index) => selectedChats.contains(recentChats[index].jid);

  selectOrRemoveChatfromList(int index) {
    if (selected.isTrue) {
      if (selectedChats.contains(recentChats[index].jid)) {
        selectedChats.remove(recentChats[index].jid.checkNull());
        selectedChatsPosition.remove(index);
      } else {
        selectedChats.add(recentChats[index].jid.checkNull());
        selectedChatsPosition.add(index);
      }
    }
    if (selectedChats.isEmpty) {
      clearAllChatSelection();
    } else {
      menuValidationForItem();
    }
  }

  clearAllChatSelection() {
    debugPrint("clear selection $currentTab");
    //Need to check the Codes below if condition for Calls tab, whether it is required or not
    if (currentTab.value == 1) {
      selectedCallLogs.clear();
      selectedCallLogsPosition.clear();
      selectedLog(false);
    }
    selected(false);
    selectedChats.clear();
    selectedChatsPosition.clear();
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

  menuValidationForPinIcon() {
    var checkListForPinIcon = <bool>[];
    var selected = recentChats.where((p0) => selectedChats.contains(p0.jid));
    for (var value in selected) {
      checkListForPinIcon.add(value.isChatPinned!);
    }
    if (checkListForPinIcon.contains(false)) {
      //pin able
      pin(true);
      unpin(false);
    } else {
      pin(false);
      unpin(true);
    }
    //return checkListForPinIcon.contains(false);//pin able
  }

  menuValidationForDeleteIcon() async {
    var selected = recentChats.where((p0) => selectedChats.contains(p0.jid));
    for (var item in selected) {
      var isMember = await Mirrorfly.isMemberOfGroup(
          groupJid: item.jid.checkNull(),
          userJid: SessionManagement.getUserJID().checkNull());
      if ((item.getChatType() == ChatType.groupChat) &&
          isMember! &&
          availableFeatures.value.isGroupChatAvailable.checkNull()) {
        delete(false);
        return;
        //return false;
      }
    }
    //return true;
    delete(true);
  }

  menuValidationForMuteUnMuteIcon() {
    var checkListForMuteUnMuteIcon = <bool>[];
    var selected = recentChats.where((p0) => selectedChats.contains(p0.jid));
    for (var value in selected) {
      if (!value.isBroadCast!) {
        checkListForMuteUnMuteIcon.add(value.isMuted.checkNull());
      }
    }
    if (checkListForMuteUnMuteIcon.contains(false)) {
      // Mute able
      mute(true);
      unmute(false);
    } else if (checkListForMuteUnMuteIcon.contains(true)) {
      mute(false);
      unmute(true);
    } else {
      mute(false);
      unmute(false);
    }
    //return checkListForMuteUnMuteIcon.contains(false);// Mute able
  }

  menuValidationForMarkReadUnReadIcon() {
    var checkListForReadUnReadIcon = <bool>[];
    var selected = recentChats.where((p0) => selectedChats.contains(p0.jid));
    for (var value in selected) {
      checkListForReadUnReadIcon.add(value.isConversationUnRead.checkNull());
    }
    if (!checkListForReadUnReadIcon.contains(true)) {
      //Mark as Read Able
      read(false);
      unread(true);
    } else {
      read(true);
      unread(false);
    }
    //return !checkListForReadUnReadIcon.contains(true);//Mark as Read Able
  }

  menuValidationForItem() {
    LogMessage.d("selectedChats", selectedChats.length.toString());
    archive(true);
    if (selectedChats.length == 1) {
      var item = recentChats
          .firstWhere((element) => selectedChats.first == element.jid);
      info(true);
      pin(!item.isChatPinned!);
      unpin(item.isChatPinned!);
      if (ChatType.broadcastChat != item.getChatType()) {
        unmute(item.isMuted!);
        mute(!item.isMuted!);
        shortcut(true);
      } else {
        unmute(false);
        mute(false);
        shortcut(false);
      }
      read(item.isConversationUnRead);
      unread(!item.isConversationUnRead!);
      delete(ChatType.groupChat != item.getChatType());
      if (item.getChatType() == ChatType.groupChat) {
        LogMessage.d("isGroup", item.isGroup!.toString());
        Mirrorfly.isMemberOfGroup(
                groupJid: item.jid.checkNull(),
                userJid: SessionManagement.getUserJID().checkNull())
            .then((value) => delete(!value!));
      }
    } else {
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
      menuValidationForDeleteIcon(); //.then((value) => delete(value));
    }
  }

  var recentPinnedCount = 0.obs;

  pinChats() {
    if (isSelectedPositionsValidForPin()) {
      LogMessage.d("pinChat", "isSelectedPositionsValidForPin");
      if (selectedChats.length == 1) {
        _itemPin(0);
        clearAllChatSelection();
        toToast(getTranslated("chatPinned"));
      } else {
        selected(false);
        for (var index = 0; index < selectedChats.length; index++) {
          var selectedChat = recentChats.indexWhere((p0) =>
              p0.jid == selectedChats[index] && p0.isChatPinned.checkNull());
          if (selectedChat.isNegative) {
            LogMessage.d(
                "pinChat", "$selectedChat selected chat is have to pinned");
            _itemPin(index);
          } else {
            LogMessage.d(
                "pinChat", "$selectedChat selected chat is already pinned");
          }
        }
        clearAllChatSelection();
        toToast(getTranslated("chatsPinned"));
      }
    } else {
      toToast(getTranslated("chatPinLimit"));
    }
  }

  bool isSelectedPositionsValidForPin() {
    var pinnedListPosition = selectedChats;
    var validPositions = 0; //selected non pinned items
    // LogMessage.d("selectedchats", pinnedListPosition.join(","));
    // LogMessage.d("recentPinnedCount", recentPinnedCount.toString());
    for (var value in pinnedListPosition) {
      var valid = recentChats
          .firstWhere((p0) => p0.jid == value); // check, is non pinned item
      if (!valid.isChatPinned.checkNull()) {
        validPositions = validPositions + 1;
      }
    }
    /*for (position in pinnedListPosition) {
      if (position >= recentPinnedCount) // check, is non pinned item
        validPositions++;
    }*/
    //LogMessage.d("validPositions", "$validPositions");
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

  unPinChats() {
    if (selectedChats.length == 1) {
      _itemUnPin(0);
      clearAllChatSelection();
      toToast(getTranslated("chatUnPinned"));
    } else {
      selected(false);
      selectedChats.asMap().forEach((key, value) {
        _itemUnPin(key);
      });
      clearAllChatSelection();
      toToast(getTranslated("chatsUnPinned"));
    }
    reArrangeRecentChats();
  }

  void reArrangeRecentChats() {
    try {
      recentChats
          .sort((a, b) => b.lastMessageTime!.compareTo(a.lastMessageTime!));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  muteChats() {
    /*if (selectedChats.length == 1) {
      _itemMute(0);
      clearAllChatSelection();
    } else {
      selected(false);
      selectedChats.asMap().forEach((key, value) {
        _itemMute(key);
      });
      clearAllChatSelection();
    }*/
    _itemMute();
    clearAllChatSelection();
  }

  unMuteChats() {
    /*if (selectedChats.length == 1) {
      _itemUnMute(0);
      clearAllChatSelection();
    } else {
      selected(false);
      selectedChats.asMap().forEach((key, value) {
        _itemUnMute(key);
      });
      clearAllChatSelection();
    }*/
    _itemUnMute();
    clearAllChatSelection();
  }

  markAsRead() {
    if (selectedChats.length == 1) {
      _itemUnMute();
      clearAllChatSelection();
      toToast(getTranslated("chatMarkedAsRead"));
    } else {
      selected(false);
      /*selectedChats.asMap().forEach((key, value) {
        _itemUnMute(key);
      });*/
      _itemMute();
      clearAllChatSelection();
      toToast(getTranslated("chatsMarkedAsRead"));
    }
  }

  archiveChats() async {
    if (await AppUtils.isNetConnected()) {
      var allChats = selectedChats.length == recentChats.length;
      if (selectedChats.length == 1) {
        _itemArchive(0);
        clearAllChatSelection();
        toToast(getTranslated("chatArchived"));
      } else {
        var count = selectedChats.length;
        selected(false);
        selectedChats.asMap().forEach((key, value) {
          _itemArchive(key);
        });
        clearAllChatSelection();
        toToast('$count ${getTranslated("chatsArchived")}');
      }
      if (allChats) {
        loadNextRecentChat();
      }
    } else {
      toToast(getTranslated("noInternetConnection"));
    }
  }

  deleteChats() {
    if (selectedChats.length == 1) {
      _itemDelete(0);
    } else {
      itemsDelete();
    }
  }

  _itemPin(int index) {
    Mirrorfly.updateRecentChatPinStatus(
        jid: selectedChats[index], pinStatus: true);
    var chatIndex = recentChats.indexWhere((element) =>
        selectedChats[index] == element.jid); //selectedChatsPosition[index];
    //recentChats[chatIndex].isChatPinned=(true);
    var change = recentChats[chatIndex];
    change.isChatPinned = true;
    recentChats.removeAt(chatIndex);
    recentChats.insert(0, change);
  }

  _itemUnPin(int index) {
    Mirrorfly.updateRecentChatPinStatus(
        jid: selectedChats[index], pinStatus: false);
    var chatIndex = recentChats.indexWhere((element) =>
        selectedChats[index] == element.jid); //selectedChatsPosition[index];
    //recentChats[chatIndex].isChatPinned=(false);
    var lastPinnedChat =
        recentChats.lastIndexWhere((element) => element.isChatPinned!);
    LogMessage.d("lastPinnedChat", lastPinnedChat.toString());
    var nxtIndex = lastPinnedChat.isNegative ? chatIndex : (lastPinnedChat);
    var change = recentChats[chatIndex];
    change.isChatPinned = false;
    recentChats.removeAt(chatIndex);
    recentChats.insert(nxtIndex, change);
  }

  _itemMute() {
    // Deprecated Method
    // Mirrorfly.updateChatMuteStatus(jid: selectedChats[index], muteStatus: true);
    // var chatIndex =
    //     recentChats.indexWhere((element) => selectedChats[index] == element.jid); //selectedChatsPosition[index];
    // recentChats[chatIndex].isMuted = (true);
    // New Method to Mute
    Mirrorfly.updateChatMuteStatusList(
        jidList: selectedChats.toList(), muteStatus: true);
    for (var jid in selectedChats) {
      var chatIndex = recentChats.indexWhere((element) => jid == element.jid);
      if (!chatIndex.isNegative) {
        recentChats[chatIndex].isMuted = true;
      }
    }
  }

  _itemUnMute() {
    // Deprecated Method
    // var chatIndex =
    //     recentChats.indexWhere((element) => selectedChats[index] == element.jid); //selectedChatsPosition[index];
    // recentChats[chatIndex].isMuted = (false);
    // Mirrorfly.updateChatMuteStatus(jid: selectedChats[index], muteStatus: false);
    // New Method to UnMute
    Mirrorfly.updateChatMuteStatusList(
        jidList: selectedChats.toList(), muteStatus: false);
    for (var jid in selectedChats) {
      var chatIndex = recentChats.indexWhere((element) => jid == element.jid);
      if (!chatIndex.isNegative) {
        recentChats[chatIndex].isMuted = false;
      }
    }
  }

  /*_itemRead(int index){
    var chatIndex = recentChats.indexWhere((element) => selectedChats[index] == element.jid);//selectedChatsPosition[index];
    recentChats[chatIndex].isMuted=(false);
    Mirrorfly.markAsRead(selectedChats[index]);
    updateUnReadChatCount();
  }*/

  itemsRead() async {
    if (await AppUtils.isNetConnected()) {
      selected(false);
      Mirrorfly.markConversationAsRead(jidList: selectedChats);
      var count = selectedChatsPosition.length;
      for (var element in selectedChatsPosition) {
        recentChats[element].isConversationUnRead = false;
        recentChats[element].unreadMessageCount = 0;
        var jid = recentChats[element].jid;
        NotificationBuilder.clearConversationOnNotification(jid.checkNull());
      }
      clearAllChatSelection();
      updateUnReadChatCount();
      toToast(count > 1
          ? getTranslated("chatsMarkedAsRead")
          : getTranslated("chatMarkedAsRead"));
    } else {
      toToast(getTranslated("noInternetConnection"));
    }
  }

  itemsUnRead() {
    selected(false);
    Mirrorfly.markConversationAsUnread(jidList: selectedChats);
    for (var element in selectedChatsPosition) {
      recentChats[element].isConversationUnRead = true;
    }
    toToast(selectedChats.length == 1
        ? getTranslated("chatMarkedAsUnRead")
        : getTranslated("chatsMarkedAsUnRead"));
    clearAllChatSelection();
    updateUnReadChatCount();
  }

  _itemArchive(int index) {
    Mirrorfly.setChatArchived(
        jid: selectedChats[index], isArchived: true, flyCallBack: (_) {});
    var chatIndex = recentChats.indexWhere((element) =>
        selectedChats[index] == element.jid); //selectedChatsPosition[index];
    recentChats[chatIndex].isChatArchived = (true);
    //getArchivedChatsList();
    if (archivedChats.isEmpty) {
      archivedChats([recentChats[chatIndex]]);
    } else {
      archivedChats.add(recentChats[chatIndex]);
    }
    recentChats.removeAt(chatIndex);
  }

  _itemDelete(int index) {
    if (!availableFeatures.value.isDeleteChatAvailable.checkNull()) {
      DialogUtils.showFeatureUnavailable();
      return;
    }
    var chatIndex = recentChats.indexWhere((element) =>
        selectedChats[index] == element.jid); //selectedChatsPosition[index];
    DialogUtils.showAlert(
        dialogStyle: AppStyleConfig.dialogStyle,
        message: getTranslated("deleteChatWith")
            .replaceFirst("%d", recentChats[chatIndex].getName()),
        actions: [
          TextButton(
              style: AppStyleConfig.dialogStyle.buttonStyle,
              onPressed: () {
                NavUtils.back();
              },
              child: Text(
                getTranslated("no"),
              )),
          TextButton(
              style: AppStyleConfig.dialogStyle.buttonStyle,
              onPressed: () {
                NavUtils.back();
                if (!availableFeatures.value.isDeleteChatAvailable
                    .checkNull()) {
                  DialogUtils.showFeatureUnavailable();
                  return;
                }
                Mirrorfly.deleteRecentChats(
                    jidList: [selectedChats[index]],
                    flyCallBack: (FlyResponse response) {
                      clearAllChatSelection();
                      recentChats.removeAt(chatIndex);
                      updateUnReadChatCount();
                    });
              },
              child: Text(
                getTranslated("yes"),
              )),
        ]);
  }

  itemsDelete() {
    DialogUtils.showAlert(
        dialogStyle: AppStyleConfig.dialogStyle,
        message: getTranslated("deleteSelectedChats")
            .replaceFirst("%d", "${selectedChatsPosition.length}"),
        actions: [
          TextButton(
              style: AppStyleConfig.dialogStyle.buttonStyle,
              onPressed: () {
                NavUtils.back();
              },
              child: Text(
                getTranslated("no"),
              )),
          TextButton(
              style: AppStyleConfig.dialogStyle.buttonStyle,
              onPressed: () async {
                NavUtils.back();
                Mirrorfly.deleteRecentChats(
                    jidList: selectedChats,
                    flyCallBack: (FlyResponse response) {
                      if (response.isSuccess) {
                        for (var chatItem in selectedChats) {
                          var chatIndex = recentChats
                              .indexWhere((element) => chatItem == element.jid);
                          recentChats.removeAt(chatIndex);
                        }
                        updateUnReadChatCount();
                        clearAllChatSelection();
                      }
                    });
              },
              child: Text(
                getTranslated("yes"),
              )),
        ]);
  }

  updateUnReadChatCount() {
    /*Mirrorfly.getUnreadMessagesCount().then((value){
      if(value!=null) {
        _unreadCount(value);
      }
    });*/
    unReadCount();
  }

  Future<void> onMessageReceived(chatMessageModel) async {
    LogMessage.d("dashboard controller", "onMessageReceived");

    updateRecentChat(jid: chatMessageModel.chatUserJid, newInsertable: true);
  }

  Future<void> onMessageDeleted({required String messageId}) async {
    final int indexToBeReplaced =
        recentChats.indexWhere((message) => message.lastMessageId == messageId);
    debugPrint(
        "#Dashboard onMessageDeleted index to replace $indexToBeReplaced");
    if (!indexToBeReplaced.isNegative) {
      recentChats[indexToBeReplaced].isLastMessageRecalledByUser = true;
      recentChats.refresh();
    }
  }

  Future<void> onMessageStatusUpdated(ChatMessageModel chatMessageModel) async {
    final index = recentChats.indexWhere(
        (message) => message.lastMessageId == chatMessageModel.messageId);
    debugPrint("Message Status Update index of search $index");
    if (!index.isNegative) {
      // updateRecentChat(chatMessageModel.chatUserJid);
      recentChats[index].lastMessageStatus =
          chatMessageModel.messageStatus.value;
      recentChats.refresh();
    }
  }

  void markConversationReadNotifyUI(String jid) {
    var index = recentChats.indexWhere((element) => element.jid == jid);
    if (!index.isNegative) {
      if (recentChats[index].isConversationUnRead.checkNull()) {
        recentChats[index].isConversationUnRead = false;
        recentChats[index].unreadMessageCount = 0;
        recentChats.refresh();
      }
    }
  }

  Future<void> chatMuteChangesNotifyUI(String jid) async {
    var index = recentChats.indexWhere((element) => element.jid == jid);
    if (!index.isNegative) {
      var isMuted = await Mirrorfly.isChatMuted(jid: jid);
      LogMessage.d("chatMuteChangesNotifyUI", "isMuted : $isMuted");
      recentChats[index].isMuted = isMuted;
      recentChats.refresh();
    } else {
      LogMessage.d("chatMuteChangesNotifyUI", "chat not available in the list");
    }
  }

  void onGroupProfileUpdated(groupJid) {
    LogMessage.d("super", groupJid.toString());
    updateRecentChat(jid: groupJid);
  }

  void onDeleteGroup(groupJid) {
    updateRecentChat(jid: groupJid);
  }

  void onGroupDeletedLocally(groupJid) {
    updateRecentChat(jid: groupJid);
  }

  var typingAndGoneStatus = <Triple>[].obs;

  String typingUser(String jid) {
    var index =
        typingAndGoneStatus.indexWhere((it) => it.singleOrgroupJid == jid);
    if (index.isNegative) {
      return "";
    } else {
      return typingAndGoneStatus[index].userId.isNotEmpty
          ? typingAndGoneStatus[index].userId
          : typingAndGoneStatus[index].singleOrgroupJid;
    }
  }

  void setTypingStatus(
      String singleOrgroupJid, String userId, String typingStatus) {
    LogMessage.d("setTypingStatus",
        "singleOrgroupJid : $singleOrgroupJid, userId : $userId, typingStatus: $typingStatus");
    var index = typingAndGoneStatus.indexWhere(
        (it) => it.singleOrgroupJid == singleOrgroupJid && it.userId == userId);
    if (typingStatus.toLowerCase() == Constants.composing) {
      if (index.isNegative) {
        typingAndGoneStatus.insert(0, Triple(singleOrgroupJid, userId, true));
      }
    } else {
      if (!index.isNegative) {
        typingAndGoneStatus.removeAt(index);
      }
    }
  }

  /* //Moved to Base Controller
  void onAdminBlockedUser(String jid, bool status) {
    LogMessage.d("dash onAdminBlockedUser", "$jid, $status");
    Get.find<MainController>().handleAdminBlockedUser(jid, status);
  }*/

  void userUpdatedHisProfile(String jid) {
    updateRecentChatAdapter(jid);
    updateRecentChatAdapterSearch(jid);
    updateProfileSearch(jid);
  }

  Future<void> updateRecentChatAdapter(String jid) async {
    if (jid.isNotEmpty) {
      var index = recentChats.indexWhere((element) =>
          element.jid == jid); // { it.jid ?: Constants.EMPTY_STRING == jid }
      debugPrint("updateRecentChatAdapter $index");
      if (!index.isNegative) {
        var recent = await getRecentChatOfJid(jid);
        var updatedIndex = recentChats.indexWhere((element) =>
            element.jid == jid); // { it.jid ?: Constants.EMPTY_STRING == jid }
        debugPrint(
            "updateRecentChatAdapter getRecentChatOfJid ${recent?.toJson().toString()}");
        if (recent != null) {
          recentChats[updatedIndex] = recent;
        }
      }
    }
  }

  //search
  // var frmRecentChatList = <RecentChatData>[].obs;
  var recentSearchList = <Rx<RecentSearch>>[].obs;
  var filteredRecentChatList = <RecentChatData>[].obs;
  RxList<ChatMessageModel> chatMessages = <ChatMessageModel>[].obs;
  final deBouncer = DeBouncer(milliseconds: 700);
  TextEditingController search = TextEditingController();
  var searchFocusNode = FocusNode();
  String lastInputValue = "";
  RxBool clearVisible = false.obs;
  final _mainuserList = <ProfileDetails>[];
  var userlistScrollController = ScrollController();
  var scrollable = (!Constants.enableContactSync).obs;
  var isPageLoading = false.obs;
  final _userList = <ProfileDetails>[].obs;

  set userList(List<ProfileDetails> value) => _userList.value = value;

  List<ProfileDetails> get userList => _userList;
  var callLogScrollController = ScrollController();
  var isCallLogPageLoading = false.obs;
  final _callLogList = <CallLogData>[].obs;

  set callLogList(List<CallLogData> value) => _callLogList.value = value;

  List<CallLogData> get callLogList => _callLogList;

  _callLogScrollListener() {
    // if (callLogScrollController.hasClients) {
    //   if (callLogScrollController.position.extentAfter <= 0 && isCallLogPageLoading.value == false) {
    //     if (scrollable.value) {
    //       //isPageLoading.value = true;
    //       print("getCallLogsList fetchCallLogList calling");
    //       fetchCallLogList();
    //     }
    //   }
    // }
    // print("getCallLogsList fetchCallLogList pixels ${callLogScrollController.position.pixels}");
    // print("getCallLogsList fetchCallLogList maxScrollExtent ${callLogScrollController.position.maxScrollExtent}");
    // print("getCallLogsList fetchCallLogList hasClients ${callLogScrollController.position.extentAfter <= 0}");

    // if (callLogScrollController.hasClients && callLogScrollController.position.pixels == callLogScrollController.position.maxScrollExtent) {
    if (callLogScrollController.hasClients &&
        callLogScrollController.position.extentAfter <= 0 &&
        callLogScrollController.position.pixels ==
            callLogScrollController.position.maxScrollExtent) {
      // print("getCallLogsList fetchCallLogList calling");

      callLogScrollController.removeListener(_scrollListener);

      if (!isLastPage.value && !loading.value) {
        pageNumber = pageNumber + 1;
        fetchCallLogList();
      }
    }
  }

  onChange(String inputValue, [int? value]) {
    LogMessage.d("onChange", "inputValue $inputValue");
    if (value == 0) {
      if (search.text.trim().isNotEmpty) {
        clearVisible(true);
      } else {
        clearVisible(false);
        recentChats.refresh();
      }
      if (lastInputValue != search.text.trim()) {
        lastInputValue = search.text.trim();
        searchLoading(true);
        // frmRecentChatList.clear();
        recentSearchList.clear();
        if (search.text.trim().isNotEmpty) {
          deBouncer.run(() {
            pageNum = 1;
            fetchRecentChatList();
            fetchMessageList();
            filterUserList();
          });
        } else {
          LogMessage.d("empty", "empty");
          // frmRecentChatList.addAll(recentChats);
        }
      }
      update();
    } else {
      clearVisible(search.text.isNotEmpty);
      if (search.text.trim().isNotEmpty) {
        callLogSearchLoading(true);
        deBouncer.run(() {
          filteredCallLog(search.text.trim());
        });
      } else {
        pageNumber = 1;
        _callLogList.clear();
        callLogList.clear();
        fetchCallLogList();
      }
    }
  }

  onClearPressed() {
    lastInputValue = "";
    filteredRecentChatList.clear();
    chatMessages.clear();
    userList.clear();
    search.clear();
    clearVisible(false);
    // frmRecentChatList(recentChats);
    _callLogList.clear();
    callLogList.clear();
    pageNumber = 1;
    fetchCallLogList();
  }

  var pageNum = 1;
  var searching = false;
  var searchLoading = false.obs;
  var callLogSearchLoading = false.obs;

  Future<void> filterUserList() async {
    if (await AppUtils.isNetConnected()) {
      searching = true;
      callback(FlyResponse response) {
        if (response.isSuccess) {
          if (response.hasData) {
            var list = userListFromJson(response.data);
            if (list.data != null) {
              if (!Constants.enableContactSync) {
                scrollable(list.data!.length == 20);

                list.data!.removeWhere((element) {
                  debugPrint(
                      "filter chat list--> ${!filteredRecentChatList.indexWhere((recentChatItem) => recentChatItem.jid == element.jid.checkNull()).isNegative}");
                  return !filteredRecentChatList
                      .indexWhere((recentChatItem) =>
                          recentChatItem.jid == element.jid.checkNull())
                      .isNegative;
                });
                _userList(list.data);
              } else {
                _userList(list.data!
                    .where((element) =>
                        (element.nickName.checkNull().toLowerCase().contains(
                            search.text.trim().toString().toLowerCase())) &&
                        !filteredRecentChatList
                            .indexWhere((recentChatItem) =>
                                recentChatItem.jid != element.jid.checkNull())
                            .isNegative)
                    .toList());
                // scrollable(false);
              }
            } else {
              scrollable(false);
            }
          }
          searching = false;
          searchLoading(false);
        } else {
          searching = false;
          searchLoading(false);
        }
      }

      (!Constants.enableContactSync)
          ? Mirrorfly.getUserList(
              page: pageNum,
              search: search.text.trim().toString(),
              metaDataUserList: Constants.metaDataUserList, //#metaData
              flyCallback: callback)
          : Mirrorfly.getRegisteredUsers(
              fetchFromServer: true, flyCallback: callback);
      /*future.then((value) {
        // Mirrorfly.getUserList(pageNum, search.text.trim().toString()).then((value) {
        if (value.isNotEmpty) {
          var list = userListFromJson(value);
          if (list.data != null) {
            if (!Constants.enableContactSync) {
              scrollable(list.data!.length == 20);

              list.data!.removeWhere((element) {
                debugPrint(
                    "filter chat list--> ${!filteredRecentChatList.indexWhere((recentChatItem) => recentChatItem.jid == element.jid.checkNull()).isNegative}");
                return !filteredRecentChatList.indexWhere((recentChatItem) => recentChatItem.jid == element.jid.checkNull()).isNegative;
              });
              _userList(list.data);
            } else {
              _userList(list.data!
                  .where((element) =>
                      (element.nickName.checkNull().toLowerCase().contains(search.text.trim().toString().toLowerCase())) &&
                      !filteredRecentChatList.indexWhere((recentChatItem) => recentChatItem.jid != element.jid.checkNull()).isNegative)
                  .toList());
              // scrollable(false);
            }
          } else {
            scrollable(false);
          }
        }
        searching = false;
        searchLoading(false);
      }).catchError((error) {
        debugPrint("issue===> $error");
        searching = false;
        searchLoading(false);
      });*/
    } else {
      toToast(getTranslated("noInternetConnection"));
    }
  }

  fetchRecentChatList() async {
    debugPrint("========fetchRecentChatList======");
    await Mirrorfly.getRecentChatListIncludingArchived().then((value) {
      var recentChatList = <RecentChatData>[];
      var js = json.decode(value);
      LogMessage.d("getRecentChatListIncludingArchived", js);
      var recentChatListWithArchived = recentChatDataListFromJson(value
          .toString()); //List<RecentChatData>.from(js.map((x) => RecentChatData.fromJson(x)));
      for (var recentChat in recentChatListWithArchived) {
        if (recentChat.profileName != null &&
            recentChat
                    .getName()
                    .toLowerCase()
                    .contains(search.text.trim().toString().toLowerCase()) ==
                true) {
          recentChatList.add(recentChat);
        }
      }
      filteredRecentChatList(recentChatList);
      update(filteredRecentChatList);
    });
    //fetchMessageList();
  }

  fetchMessageList() async {
    await Mirrorfly.searchConversation(
        searchKey: search.text.trim().toString(),
        flyCallBack: (FlyResponse response) {
          LogMessage.d("flutter search", response.toString());
          if (response.isSuccess && response.hasData) {
            var result = chatMessageModelFromJson(response.data);
            chatMessages(result);
            var mRecentSearchList = <Rx<RecentSearch>>[].obs;
            // var i = 0.obs;
            for (var message in result) {
              var searchMessageItem = RecentSearch(
                      jid: message.chatUserJid,
                      mid: message.messageId,
                      searchType: Constants.typeSearchMessage,
                      chatType: message.messageChatType.toString(),
                      isSearch: true)
                  .obs;
              mRecentSearchList.insert(0, searchMessageItem);
              // i++;
            }
          }
          /*var map = <Rx<int>, RxList<Rx<RecentSearch>>>{}; //{0,searchMessageItem};
      map.putIfAbsent(i, () => mRecentSearchList).obs;
      filteredMessageList(map);
      update();*/
        });
  }

  Future<Map<ProfileDetails?, ChatMessageModel?>?> getProfileAndMessage(
      String jid, String mid) async {
    var value =
        await getProfileDetails(jid); //Mirrorfly.getProfileLocal(jid, false);
    var value2 = await Mirrorfly.getMessageOfId(messageId: mid);
    if (value.jid != null && value2 != null) {
      var data = value; //profileDataFromJson(value);
      var data2 = sendMessageModelFromJson(value2);
      var map = <ProfileDetails?, ChatMessageModel?>{}; //{0,searchMessageItem};
      map.putIfAbsent(data, () => data2);
      return map;
    }
    return null;
  }

  void getBackFromSearch() {
    searchFocusNode.unfocus();
    onClearPressed();
    clearVisible(false);
    isSearching(false);
  }

  _scrollListener() {
    if (userlistScrollController.hasClients) {
      if (userlistScrollController.position.extentAfter <= 0 &&
          isPageLoading.value == false) {
        if (scrollable.value && !searching) {
          //isPageLoading.value = true;
          LogMessage.d("scroll", "end");
          pageNum++;
          getUsers();
        }
      }
    }
  }

  Future<void> getUsers() async {
    // print("getUsers calling $pageNum");
    if (await AppUtils.isNetConnected()) {
      searching = true;

      Mirrorfly.getUserList(
          page: pageNum,
          search: search.text.trim().toString(),
          metaDataUserList: Constants.metaDataUserList, //#metaData
          flyCallback: (FlyResponse response) {
            if (response.isSuccess) {
              if (response.hasData) {
                var list = userListFromJson(response.data);
                if (list.data != null) {
                  if (_mainuserList.isEmpty) {
                    _mainuserList.addAll(list.data!);
                  }
                  scrollable(list.data!.length == 20);
                  _userList.addAll(list.data!);
                  _userList.refresh();
                } else {
                  scrollable(false);
                }
              }
              searching = false;
            } else {
              searching = false;
            }
          });
      /*then((value) {
        if (value.isNotEmpty) {
          var list = userListFromJson(value);
          if (list.data != null) {
            if (_mainuserList.isEmpty) {
              _mainuserList.addAll(list.data!);
            }
            scrollable(list.data!.length == 20);
            _userList.addAll(list.data!);
            _userList.refresh();
          } else {
            scrollable(false);
          }
        }
        searching = false;
      }).catchError((error) {
        debugPrint("issue===> $error");
        searching = false;
      });*/
    } else {
      toToast(getTranslated("noInternetConnection"));
    }
  }

  Future<void> updateRecentChatAdapterSearch(String jid) async {
    if (jid.isNotEmpty) {
      var filterIndex =
          filteredRecentChatList.indexWhere((element) => element.jid == jid);
      if (!filterIndex.isNegative) {
        var recent = await getRecentChatOfJid(jid);
        if (recent != null) {
          var updateIndex = filteredRecentChatList
              .indexWhere((element) => element.jid == jid);
          filteredRecentChatList[updateIndex] = recent;
        }
      }
    }
  }

  void updateProfileSearch(String jid) {
    debugPrint("updateProfileSearch jid $jid");
    if (jid.isNotEmpty) {
      var userListIndex = _userList.indexWhere((element) => element.jid == jid);
      debugPrint("userListIndex $userListIndex");
      if (!userListIndex.isNegative) {
        getProfileDetails(jid).then((value) {
          debugPrint("get profile detail dashboard $value");
          profile_(value);
          var updateIndex =
              _userList.indexWhere((element) => element.jid == jid);
          _userList[updateIndex] = value;
        });
      }
    }
  }

  @override
  void onDetached() {}

  @override
  void onInactive() {}

  var hasPaused = false;

  @override
  void onPaused() {
    hasPaused = true;
  }

  @override
  void onResumed() {
    if (hasPaused) {
      hasPaused = false;
      LogMessage.d("updateRecentChatListHistory", "reload recent chat list");
      getRecentChatList();
      fetchCallLogList();
    }
    getArchivedChatsList();
    if (!KeyboardVisibilityController().isVisible) {
      if (searchFocusNode.hasFocus) {
        searchFocusNode.unfocus();
        Future.delayed(const Duration(milliseconds: 100), () {
          searchFocusNode.requestFocus();
        });
      }
    }
    checkContactSyncPermission();
    typingAndGoneStatus.clear();
    // fetchCallLogList();
  }

  void getProfileDetail(context, RecentChatData chatItem, int index) {
    getProfileDetails(chatItem.jid.checkNull()).then((value) {
      profile_(value);
      debugPrint("dashboard controller profile update received");
      showQuickProfilePopup(
          // chatItem: chatItem,
          chatTap: () {
            NavUtils.back();
            if (selected.value) {
              selectOrRemoveChatfromList(index);
            } else {
              toChatPage(chatItem.jid.checkNull());
            }
          },
          callTap: () {},
          videoTap: () {},
          infoTap: () {
            NavUtils.back();
            infoPage(value);
          },
          profile: profile_,
          availableFeatures: availableFeatures);
    });
  }

  Future<void> gotoContacts(
      {bool forCalls = false, String callType = ""}) async {
    if (!Constants.enableContactSync) {
      NavUtils.toNamed(Routes.contacts,
          arguments: ContactListArguments(
              topicId: topicId.value,
              forMakeCall: forCalls,
              callType: callType));
    } else {
      var contactPermissionHandle =
          await AppPermission.checkAndRequestPermissions(
              permissions: [Permission.contacts],
              permissionIcon: contactPermission,
              permissionContent: getTranslated("contactPermissionContent"),
              permissionPermanentlyDeniedContent:
                  getTranslated("contactPermissionDeniedContent"));
      if (contactPermissionHandle) {
        NavUtils.toNamed(Routes.contacts,
            arguments: ContactListArguments(
                topicId: topicId.value,
                forMakeCall: forCalls,
                callType: callType));
      }
    }
  }

  void onContactSyncComplete(bool result) {
    getRecentChatList();
    getArchivedChatsList();
    // filterUserlist();
    LogMessage.d('isSearching.value', isSearching.value.toString());
    if (isSearching.value) {
      lastInputValue = '';
      onChange(search.text.toString());
    }
  }

  void checkContactSyncPermission() {
    Permission.contacts.isGranted.then((value) {
      if (!value) {
        _userList.clear();
        _userList.refresh();
      }
    });
  }

  void userDeletedHisProfile(String jid) {
    userUpdatedHisProfile(jid);
  }

  ///Commenting this as this method is not used anywhere
  /*Future<String> getJidFromPhoneNumber(
      String mobileNumber, String countryCode) async {
    FlutterLibphonenumber().init();
    var formatNumberSync =
        FlutterLibphonenumber().formatNumberSync(mobileNumber);
    var parse = await FlutterLibphonenumber().parse(formatNumberSync);
    var format =
        await FlutterLibphonenumber().format(mobileNumber, countryCode);
    */ /*bool? isValid =
      await PhoneNumberUtil.isValidPhoneNumber(phoneNumber: mobileNumber, isoCode: countryCode);
  String? normalizedNumber = await PhoneNumberUtil.normalizePhoneNumber(
      phoneNumber: mobileNumber, isoCode: countryCode);
  RegionInfo regionInfo =
      await PhoneNumberUtil.getRegionInfo(phoneNumber: mobileNumber, isoCode: countryCode);
  String? carrierName =
      await PhoneNumberUtil.getNameForNumber(phoneNumber: mobileNumber, isoCode: countryCode);*/ /*
    debugPrint('formatNumberSync : $formatNumberSync');
    debugPrint(
        'parse : $parse'); //{country_code: 971, e164: +971503209773, national: 050 320 9773, type: mobile, international: +971 50 320 9773, national_number: 503209773, region_code: AE}
    debugPrint('format : $format'); //{formatted: +971 50 320 9773}
    // parse.then((value) => debugPrint('parse : $value'));
    // format.then((value) => debugPrint('format : $value'));

    // debugPrint('normalizedNumber : $normalizedNumber');
    // debugPrint('regionInfo.regionPrefix : ${regionInfo.regionPrefix}');
    // debugPrint('regionInfo.isoCode : ${regionInfo.isoCode}');
    // debugPrint('regionInfo.formattedPhoneNumber : ${regionInfo.formattedPhoneNumber}');
    // debugPrint('carrierName : $carrierName');

    */ /*phoneNumberUtil = PhoneNumberUtil.createInstance(context);
  if (mobileNumber.startsWith("*")) {
    LogMessage.d(TAG, "Invalid PhoneNumber:"+mobileNumber);
    return null;
  }
  try {
    Phonenumber.PhoneNumber phoneNumber = phoneNumberUtil.parse(mobileNumber.replaceAll("^0+", ""), countryCode);
    String unformattedPhoneNumber = phoneNumberUtil.format(phoneNumber,
        PhoneNumberUtil.PhoneNumberFormat.E164).replace("+", "");
    return unformattedPhoneNumber + "@" + Constants.getDomain();
  } catch (NumberParseException e) {
  LogMessage.d(TAG, e);
  }*/ /*
    return '';
  }*/

  historyScrollListener() {
    // LogMessage.d("historyScrollListener", historyScrollController.position.extentAfter.toString());
    // scrollController.position.pixels >=
    //     scrollController.position.maxScrollExtent - 200 //uncomment for data to be populated before certain items
    // if (historyScrollController.position.extentAfter <= 0.0) {
    //   // User has reached the bottom of the list
    //   // Show loading screen and load more data
    //   // loadMoreData();
    //
    // }
    if (historyScrollController.position.pixels ==
        historyScrollController.position.maxScrollExtent) {
      debugPrint("historyScrollController reached bottom");
      debugPrint("load next set of data");
      debugPrint("isRecentHistoryLoading $isRecentHistoryLoading");
      if (!isRecentHistoryLoading.value) {
        loadNextRecentChat();
      }
    }
    if (historyScrollController.position.pixels ==
        historyScrollController.position.minScrollExtent) {
      debugPrint("historyScrollController reached top");
    }
  }

  void loadNextRecentChat() {
    recentChatPage++;
    isRecentHistoryLoading(true);
    debugPrint("calling page no $recentChatPage");
    callback(FlyResponse response) {
      if (response.isSuccess && response.hasData) {
        debugPrint("getRecentChatListHistory next data ${response.data}");
        var data = recentChatFromJson(response
            .data); //await compute(recentChatFromJson, value.toString());
        LogMessage.d("getRecentChatListHistory", data.toJson());
        recentChats.addAll(data.data!);
        recentChats.refresh();
        isRecentHistoryLoading(false);
        getArchivedChatsList();
        chatLimit += chatLimit;
      } else {
        debugPrint("recent chat issue===> ${response.exception}");
        isRecentHistoryLoading(false);
      }
    }

    Constants.enableTopic
        ? Mirrorfly.getRecentChatListHistoryByTopic(
            firstSet: recentChatPage == 1,
            limit: chatLimit,
            topicId: topicId.value,
            flyCallback: callback)
        : Mirrorfly.getRecentChatListHistory(
            firstSet: recentChatPage == 1,
            limit: chatLimit,
            flyCallback: callback);
  }

  var topicId = Constants.topicId.obs;
  var topics = <Topics>[].obs;

  void createTopic() async {
    var topicId = Constants.topicId;
    LogMessage.d("topicId", topicId);
    if (topicId.isEmpty && Constants.enableTopic) {
      await Mirrorfly.createTopic(
          topicName: "Macbook Air",
          metaData: [
            TopicMetaData(key: "description", value: "Starting From ₹ 9720")
          ],
          flyCallBack: (FlyResponse response) {
            if (response.isSuccess) {
              //SessionManagement.setString("topicId", value);
            }
          });
    } else if (Constants.enableTopic) {
      // if(topicId.isNotEmpty) {
      //c47cdeec-32a0-4abb-a318-ab60048df577,a8f8877b-52c0-47cc-83d1-6e0292876daa,b7ba6a95-56f4-4354-a40c-b9a03b0cf470
      //Walkie Talkie,Macbook Pro,Macbook Air
      await Mirrorfly.getTopics(
          topicIds: [
            "c47cdeec-32a0-4abb-a318-ab60048df577",
            "a8f8877b-52c0-47cc-83d1-6e0292876daa",
            "b7ba6a95-56f4-4354-a40c-b9a03b0cf470"
          ],
          flyCallBack: (FlyResponse response) {
            if (response.isSuccess && response.hasData) {
              var topics = topicsFromJson(response.data.toString());
              this.topics(topics);
              //"a00251d7-d388-4f47-8672-553f8afc7e11","c640d387-8dfc-4252-b20a-d2901ebe3197","f5dc3456-cd2a-4e64-ad91-79373a867aa3","0075fe28-ec93-45c6-be3a-85004bf860a1","da757122-1a74-40ae-9c7d-0e4c2757e6bd","5d3788c1-78ef-4158-a92b-a48f092da0b9","4d83dfad-79a8-43fd-98b8-7eb8943dc8ca","0b290e7f-b05c-4859-a72d-100c48f73c8d","1ab018d1-1068-4988-8b28-fe1079e07ab2"
              LogMessage.d("getTopics by Id", response.data);
              LogMessage.d("getTopics [0] meta", "${topics[0].metaData}");
              if (topics.isNotEmpty) {
                if (topics[0].topicId != null) {
                  this.topicId(topics[0].topicId.checkNull());
                  getRecentChatList();
                }
              }
            }
          });
      // }
    }
  }

  void onAvailableFeaturesUpdated(AvailableFeatures features) {
    LogMessage.d(
        "DashboardView", "onAvailableFeaturesUpdated ${features.toJson()}");
    availableFeatures(features);
    if (selectedChats.isNotEmpty) {
      menuValidationForItem();
    }
  }

  void onTopicsTap(int index) {
    topicId(topics[index].topicId);
    getRecentChatList();
  }

  @override
  void onHidden() {}

  Future<void> fetchCallLogList() async {
    loading.value = true;
    Mirrorfly.getCallLogsList(
        currentPage: pageNumber,
        flyCallBack: (FlyResponse response) {
          loading.value = false;
          if (response.isSuccess && response.hasData) {
            var list = callLogListFromJson(response.data);
            totalPages = list.totalPages!;
            // print("getCallLogsList fetchCallLogList ===> total_pages $totalPages pageNumber $pageNumber list.data!.length ${list.data!.length} ");
            if (list.data != null) {
              _callLogList.addAll(list.data!);
              isLastPage.value = list.data!.isEmpty;
            }
          }
        });
  }

  void makeVideoCall(String? fromUser) async {
    if (!availableFeatures.value.isOneToOneCallAvailable.checkNull()) {
      DialogUtils.showFeatureUnavailable();
      return;
    }
    if ((await Mirrorfly.isOnGoingCall()).checkNull()) {
      debugPrint("#Mirrorfly Call You are on another call");
      toToast(getTranslated("msgOngoingCallAlert"));
      return;
    }
    if (await AppUtils.isNetConnected()) {
      if (await AppPermission.askVideoCallPermissions()) {
        Mirrorfly.makeVideoCall(
            toUserJid: fromUser.checkNull(),
            flyCallBack: (FlyResponse response) {
              if (response.isSuccess) {
                //setOnGoingUserGone();
                NavUtils.toNamed(Routes.outGoingCallView, arguments: {
                  "userJid": [fromUser],
                  "callType": CallType.video
                })?.then((value) => setOnGoingUserAvail());
              }
            });
      } else {
        LogMessage.d("askVideoCallPermissions", "false");
      }
    } else {
      toToast(getTranslated("noInternetConnection"));
    }
  }

  void setOnGoingUserAvail() {
    debugPrint("setOnGoingUserAvail");
  }

  void makeVoiceCall(String? toUser) async {
    debugPrint("#FLY CALL VOICE CALL CALLING");
    if (!availableFeatures.value.isOneToOneCallAvailable.checkNull()) {
      DialogUtils.showFeatureUnavailable();
      return;
    }
    if ((await Mirrorfly.isOnGoingCall()).checkNull()) {
      debugPrint("#Mirrorfly Call You are on another call");
      toToast(getTranslated("msgOngoingCallAlert"));
      return;
    }
    if (!(await AppUtils.isNetConnected())) {
      toToast(getTranslated("noInternetConnection"));
      return;
    }
    if (await AppPermission.askAudioCallPermissions()) {
      Mirrorfly.makeVoiceCall(
          toUserJid: toUser.checkNull(),
          flyCallBack: (FlyResponse response) {
            if (response.isSuccess) {
              debugPrint("#Mirrorfly Call userjid $toUser");
              //  setOnGoingUserGone();
              NavUtils.toNamed(Routes.outGoingCallView, arguments: {
                "userJid": [toUser],
                "callType": CallType.audio
              })?.then((value) => setOnGoingUserAvail());
            }
          });
    } else {
      debugPrint("permission not given");
    }
  }

  makeCall(List<String>? userList, String callType, CallLogData item) async {
    if (userList == null || userList.isEmpty) {
      return;
    }
    if ((await Mirrorfly.isOnGoingCall()).checkNull()) {
      debugPrint("#Mirrorfly Call You are on another call");
      toToast(getTranslated("msgOngoingCallAlert"));
      return;
    }
    if (!(await AppUtils.isNetConnected())) {
      toToast(getTranslated("noInternetConnection"));
      return;
    }
    if (!availableFeatures.value.isGroupCallAvailable.checkNull()) {
      DialogUtils.showFeatureUnavailable();
      return;
    }
    if (callType == CallType.video) {
      if (await AppPermission.askVideoCallPermissions()) {
        // NavUtils.back();
        Mirrorfly.makeGroupVideoCall(
            groupJid: item.groupId.checkNull(),
            toUserJidList: userList,
            flyCallBack: (FlyResponse response) {
              if (response.isSuccess) {
                NavUtils.toNamed(Routes.outGoingCallView, arguments: {
                  "userJid": userList,
                  "callType": CallType.video
                });
              }
            });
      }
    } else {
      if (await AppPermission.askAudioCallPermissions()) {
        // NavUtils.back();
        Mirrorfly.makeGroupVoiceCall(
            groupJid: item.groupId.checkNull(),
            toUserJidList: userList,
            flyCallBack: (FlyResponse response) {
              if (response.isSuccess) {
                NavUtils.toNamed(Routes.outGoingCallView, arguments: {
                  "userJid": userList,
                  "callType": CallType.audio
                });
              }
            });
      }
    }
  }

  void onCallLogUpdate(value) async {
    if (value) {
      if (search.text.trim().isNotEmpty) {
        filteredCallLog(search.text.trim());
      } else {
        var res = await Mirrorfly.getLocalCallLogs();
        var list = callLogListFromJson(res);
        _callLogList.clear();
        callLogList.clear();
        _callLogList.addAll(list.data!);
      }

      var unreadMissedCallCount = await Mirrorfly.getUnreadMissedCallCount();
      // print("unreadMissedCallCount from sdk $unreadMissedCallCount");
      unreadCallCount.value = unreadMissedCallCount ?? 0;
    } else {
      debugPrint("onCallLogUpdate : Failed");
    }
  }

  void filteredCallLog(String searchKey) async {
    Mirrorfly.getLocalCallLogs().then((callLogsResponse) async {
      List<CallLogData> callLogs = [];
      List<CallLogData> callLogsWithNickName = [];

      if (callLogsResponse.isNotEmpty) {
        _callLogList.clear();
        callLogList.clear();

        var list = callLogListFromJson(callLogsResponse);

        for (var callLog in list.data ?? []) {
          callLogsWithNickName
              .add(await setProfile(getEndUserJid(callLog), callLog));
        }

        var searchKeyWithoutSpace = searchKey.toLowerCase();
        for (var callLog in callLogsWithNickName) {
          if (callLog.nickName!
              .toLowerCase()
              .contains(searchKeyWithoutSpace.toLowerCase())) {
            callLogs.add(callLog);
          }
        }
        _callLogList(callLogs);
        callLogSearchLoading(false);
      } else {
        debugPrint("filteredCallLog : Failed");
      }
    });
  }

  String getEndUserJid(CallLogData callLog) {
    if (callLog.callMode == CallMode.groupCall) {
      if (callLog.groupId.checkNull().isEmpty) {
        return "";
      } else {
        return callLog.groupId!;
      }
    } else {
      if (callLog.callState == 0 || callLog.callState == 2) {
        return callLog.fromUser!;
      } else {
        return callLog.toUser!;
      }
    }
  }

  Future<CallLogData> setProfile(String endUserJid, CallLogData callLog) async {
    if (callLog.callMode == CallMode.groupCall) {
      if (callLog.groupId.checkNull().isEmpty) {
        var name =
            await CallUtils.getCallLogUserNames(callLog.userList!, callLog);
        callLog.nickName = name;
        return callLog;
      } else {
        var res = await Mirrorfly.getProfileDetails(jid: callLog.groupId!);
        var str = ProfileDetails.fromJson(json.decode(res.toString()));
        callLog.nickName = getName(str);
        return callLog;
      }
    } else {
      var res = await Mirrorfly.getProfileDetails(jid: endUserJid);
      var str = ProfileDetails.fromJson(json.decode(res.toString()));
      callLog.nickName = getName(str);
      return callLog;
    }
  }

  selectOrRemoveCallLogFromList(int index) {
    if (selectedLog.isTrue) {
      if (selectedCallLogs.contains(callLogList[index].roomId)) {
        selectedCallLogs.remove(callLogList[index].roomId.checkNull());
        selectedCallLogsPosition.remove(index);
      } else {
        selectedCallLogs.add(callLogList[index].roomId.checkNull());
        selectedCallLogsPosition.add(index);
      }
    }
    if (selectedCallLogs.isEmpty) {
      // clearAllChatSelection();
      delete(false);
      selected(false);
      selectedLog(false);
    } else {
      delete(true);
      selected(true);
    }
    if (delete.value) {
      clearVisible(false);
    } else {
      if (isSearching.value) {
        clearVisible(true);
      } else {
        clearVisible(false);
      }
    }
  }

  isLogSelected(int index) =>
      selectedCallLogs.contains(callLogList[index].roomId);

  deleteCallLog() {
    if (selectedCallLogs.length == 1) {
      _itemDeleteCallLog(0);
    } else {
      itemsDeleteCallLog();
    }
  }

  _itemDeleteCallLog(int index) {
    var logIndex = callLogList.indexWhere((element) =>
        selectedCallLogs[index] ==
        element.roomId); //selectedChatsPosition[index];
    DialogUtils.showAlert(
        dialogStyle: AppStyleConfig.dialogStyle,
        message: getTranslated("deleteCallLogConfirmation"),
        actions: [
          TextButton(
              style: AppStyleConfig.dialogStyle.buttonStyle,
              onPressed: () {
                NavUtils.back();
              },
              child: Text(
                getTranslated("cancel").toUpperCase(),
              )),
          TextButton(
              style: AppStyleConfig.dialogStyle.buttonStyle,
              onPressed: () {
                NavUtils.back();
                Mirrorfly.deleteCallLog(
                    jidList: selectedCallLogs,
                    isClearAll: false,
                    flyCallBack: (FlyResponse response) {
                      if (response.isSuccess) {
                        callLogList.removeAt(logIndex);
                        delete(false);
                        selected(false);
                        selectedCallLogs.clear();
                      } else {
                        toToast(getTranslated("errorOnCallLogDelete"));
                      }
                    });
              },
              child: Text(
                getTranslated("ok").toUpperCase(),
              )),
        ],
        barrierDismissible: true);
  }

  itemsDeleteCallLog() {
    DialogUtils.showAlert(
        dialogStyle: AppStyleConfig.dialogStyle,
        message: getTranslated("deleteSelectedCallLog"),
        actions: [
          TextButton(
              style: AppStyleConfig.dialogStyle.buttonStyle,
              onPressed: () {
                NavUtils.back();
              },
              child: Text(
                getTranslated("cancel").toUpperCase(),
              )),
          TextButton(
              style: AppStyleConfig.dialogStyle.buttonStyle,
              onPressed: () async {
                NavUtils.back();
                Mirrorfly.deleteCallLog(
                    jidList: selectedCallLogs,
                    isClearAll: false,
                    flyCallBack: (FlyResponse response) {
                      debugPrint("deleteCallLog ${response.toString()}");
                      if (response.isSuccess) {
                        for (var logItem in selectedCallLogs) {
                          var chatIndex = callLogList.indexWhere(
                              (element) => logItem == element.roomId);
                          callLogList.removeAt(chatIndex);
                        }
                        delete(false);
                        selected(false);
                        selectedCallLogs.clear();
                      } else {
                        toToast(getTranslated("errorOnCallLogDelete"));
                      }
                    });
              },
              child: Text(
                getTranslated("ok").toUpperCase(),
              )),
        ],
        barrierDismissible: true);
  }

  clearCallLog() {
    DialogUtils.showAlert(
        dialogStyle: AppStyleConfig.dialogStyle,
        message: getTranslated("deleteAllCallLog"),
        actions: [
          TextButton(
              style: AppStyleConfig.dialogStyle.buttonStyle,
              onPressed: () {
                NavUtils.back();
              },
              child: Text(
                getTranslated("cancel").toUpperCase(),
              )),
          TextButton(
              style: AppStyleConfig.dialogStyle.buttonStyle,
              onPressed: () {
                NavUtils.back();
                Mirrorfly.deleteCallLog(
                    jidList: selectedCallLogs,
                    isClearAll: true,
                    flyCallBack: (FlyResponse response) {
                      if (!response.isSuccess) {
                        toToast(getTranslated("errorOnCallLogDelete"));
                      }
                    });
                onCallLogsCleared();
              },
              child: Text(
                getTranslated("ok").toUpperCase(),
              )),
        ],
        barrierDismissible: true);
  }

  toCallInfo(CallLogData item) async {
    var result = await NavUtils.toNamed(Routes.callInfo, arguments: item);
    if (result != null) {
      var chatIndex =
          callLogList.indexWhere((element) => item.roomId == element.roomId);
      callLogList.removeAt(chatIndex);
    }
  }

  void onMessageEdited(ChatMessageModel editedChatMessage) {
    final index = recentChats.indexWhere(
        (message) => message.lastMessageId == editedChatMessage.messageId);
    debugPrint("Message Status Update index of search $index");
    if (!index.isNegative) {
      recentChats[index].lastMessageContent =
          editedChatMessage.messageTextContent;
      recentChats.refresh();
    }
    // else {
    //   updateRecentChat(jid: editedChatMessage.chatUserJid);
    // }
  }

  Future<void> showMeetBottomSheet(
      MeetBottomSheetStyle meetBottomSheetStyle) async {
    if (await AppUtils.isNetConnected()) {
      DialogUtils.bottomSheet(
        MeetSheetView(
          title: getTranslated("generateMeet"),
          description: getTranslated("meetDescription"),
          meetBottomSheetStyle: meetBottomSheetStyle,
        ),
        ignoreSafeArea: true,
        backgroundColor: Colors.white,
        barrierColor: Colors.black.withOpacity(0.5),
      );
    } else {
      toToast(getTranslated("noInternetConnection"));
    }
  }

  void onCallLogsCleared() {
    callLogList.clear();
    _callLogList.clear();
  }

  void getWebLoginDetails() {
    Mirrorfly.getWebLoginDetails().then((value) {
      if (value != null) {
        var list = webLoginFromJson(value);
        SessionManagement.setWebChatLogin(list.isNotEmpty);
      } else {
        SessionManagement.setWebChatLogin(false);
      }
    }).catchError((onError) {
      SessionManagement.setWebChatLogin(false);
    });
  }

  void onWebLogout(List<String> socketIdList) {
    getWebLoginDetails();
  }

  void updateArchiveChat() {
    getArchivedChatsList();
  }

  Future<void> deleteGroup(
      {required String groupJid, required String groupName}) async {
    LogMessage.d("Dashboard Controller deleteGroup",
        "groupJid -> $groupJid , groupName-> $groupName");

    var chatIndex =
        recentChats.indexWhere((element) => groupJid == element.jid);

    if (!chatIndex.isNegative) {
      LogMessage.d("Dashboard Controller", "chat found chatIndex-> $chatIndex");
      recentChats.removeAt(chatIndex);
    } else {
      LogMessage.d("Dashboard Controller deleteGroup",
          "Group is not found groupJid -> $groupJid , groupName-> $groupName");
    }
  }

  void onChatMuteStatusUpdated({bool? muteStatus, List<String>? jidList}) {
    LogMessage.d("DashboardController onChatMuteStatusUpdated",
        "muteStatus : $muteStatus, jidList: $jidList");
    if (muteStatus == null || jidList == null) return;
    recentChats.where((chat) => jidList.contains(chat.jid)).forEach((chat) {
      chat.isMuted = muteStatus;
    });
    recentChats.refresh();
  }
}

class MyController extends GetxController {
  var typingUserJid = <String>[].obs;
  var typingAndGoneStatus = <Triple>[].obs;

  String typingUser(String jid) {
    var index =
        typingAndGoneStatus.indexWhere((it) => it.singleOrgroupJid == jid);
    if (index.isNegative) {
      return "";
    } else {
      return typingAndGoneStatus[index].userId.isNotEmpty
          ? typingAndGoneStatus[index].userId
          : typingAndGoneStatus[index].singleOrgroupJid;
    }
  }

  void setTypingStatus(
      String singleOrgroupJid, String userId, String typingStatus) {
    var index = typingAndGoneStatus.indexWhere(
        (it) => it.singleOrgroupJid == singleOrgroupJid && it.userId == userId);
    if (typingStatus.toLowerCase() == Constants.composing) {
      if (index.isNegative) {
        typingAndGoneStatus.insert(0, Triple(singleOrgroupJid, userId, true));
        typingUserJid.insert(0, userId.isNotEmpty ? userId : singleOrgroupJid);
      }
    } else {
      if (!index.isNegative) {
        typingAndGoneStatus.removeAt(index);
        typingUserJid.removeAt(index);
      }
    }
  }
}
