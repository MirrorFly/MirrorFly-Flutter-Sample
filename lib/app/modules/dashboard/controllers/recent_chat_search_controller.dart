import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flysdk/flysdk.dart';

import '../../../common/constants.dart';
import '../../../common/de_bouncer.dart';
import '../../../data/apputils.dart';
import '../../../data/helper.dart';
import '../../../routes/app_pages.dart';

class RecentChatSearchController extends GetxController {
  var filteredRecentChatList = <RecentChatData>[].obs;
  var filteredMessageList = <Rx<int>, RxList<Rx<RecentSearch>>>{}.obs;
  var filteredContactList = <Profile>[].obs;
  var recentSearchList = <Rx<RecentSearch>>[].obs;
  var chatCount = 0.obs;
  var messageCount = 0.obs;

  var mainRecentChatList = <Rx<RecentChatData>>[].obs;
  var frmRecentChatList = <Rx<RecentChatData>>[].obs;
  List<RecentChatData> data = Get.arguments["recents"];

  RxList<ChatMessageModel> chatMessages = <ChatMessageModel>[].obs;

  TextEditingController search = TextEditingController();

  final _mainuserList = <Profile>[];
  var userlistScrollController = ScrollController();
  var scrollable = true.obs;
  var isPageLoading = false.obs;
  final _userList = <Profile>[].obs;

  set userList(List<Profile> value) => _userList.value = value;

  List<Profile> get userList => _userList.value;

  var focusNode = FocusNode();
  var focus = true;

  @override
  void onInit() {
    super.onInit();
    focusNode.addListener(() {
      mirrorFlyLog("focus", focusNode.hasFocus.toString());
      if (!focusNode.hasFocus) {
        focus = false;
      }
    });
    userlistScrollController.addListener(_scrollListener);
    for (var element in data) {
      mainRecentChatList.add(element.obs);
      frmRecentChatList.add(element.obs);
    }
    filteredRecentChatList.bindStream(filteredRecentChatList.stream);
    filteredMessageList.bindStream(filteredMessageList.stream);
    filteredContactList.bindStream(filteredContactList.stream);
    recentSearchList.bindStream(recentSearchList.stream);
    ever(filteredRecentChatList, (callback) {
      mirrorFlyLog("sfilteredRecentChatList", callback.toString());
      //filteredRecentChatList.stream.listen((list) {
      var jidList = <String>[];
      for (var recent in callback) {
        //if(getChatType(recent)!="groupchat") {
        var recentSearchItem = RecentSearch(
                jid: recent.jid,
                mid: recent.lastMessageId,
                searchType: Constants.typeSearchRecent,
                chatType: getChatType(recent),
                isSearch: true)
            .obs;
        recentSearchList.add(recentSearchItem);
        update();
        jidList.add(recent.jid.toString());
        //}
      }
      //fetchContactList(jidList);
      chatCount(jidList.length);
      //});
    });
    ever(filteredMessageList, (callback) {
      mirrorFlyLog("sfilteredMessageList",
          callback.entries.first.value.length.toString());
      /*for (var item in callback.entries){
        mirrorFlyLog("msgs", item.value.first.value.jid.toString());
      }*/
      messageCount(callback.entries.first.key.value);
      recentSearchList.addAll(callback.entries.first.value);
      update(recentSearchList);
    });

    ever(filteredContactList, (callback) {
      mirrorFlyLog("sfilteredContactList", callback.toString());
      for (var profile in callback) {
        if (!profile.isAdminBlocked!) {
          var searchContactItem = RecentSearch(
                  jid: profile.jid,
                  mid: null,
                  searchType: Constants.typeSearchContact,
                  chatType: getProfileChatType(profile),
                  isSearch: true)
              .obs;
          recentSearchList.add(searchContactItem);
          update();
        }
      }
    });

    ever(recentSearchList, (callback) {
      mirrorFlyLog("searched", callback.toString());
      update(recentSearchList);
    });

    /*filteredMessageList.stream.listen((list) {
      messageCount(list.entries.first.key);
      recentSearchList.value.addAll(list.entries.first.value);
      recentSearchList.refresh();
    });
    filteredContactList.stream.listen((list) {
      for (var profile in list) {
        if (!profile.isAdminBlocked!) {
          var searchContactItem = RecentSearch(
              jid: profile.jid,
              mid: null,
              searchType: Constants.TYPE_SEARCH_CONTACT,
              chatType: getProfileChatType(profile),
              isSearch: true);
          recentSearchList.value.add(searchContactItem);
        }
      }
      recentSearchList.refresh();
    });
    recentSearchList.stream.listen((event) {
      Log("searched", event.toString());
    });*/
  }

  final deBouncer = DeBouncer(milliseconds: 700);
  String lastInputValue = "";
  RxBool clearVisible = false.obs;

  onChange(String inputValue) {
    if (search.text.trim().isNotEmpty) {
      clearVisible(true);
    } else {
      clearVisible(false);
    }
    if (lastInputValue != search.text.trim()) {
      lastInputValue = search.text.trim();
      searchLoading(true);
      frmRecentChatList.clear();
      recentSearchList.clear();
      if (search.text.trim().isNotEmpty) {
        deBouncer.run(() {
          pageNum = 1;
          fetchRecentChatList();
          fetchMessageList();
          filterUserlist();
        });
      } else {
        mirrorFlyLog("empty", "empty");
        frmRecentChatList.addAll(mainRecentChatList);
      }
    }

    update();
  }

  onClearPressed() {
    filteredRecentChatList.clear();
    chatMessages.clear();
    userList.clear();
    search.clear();
    frmRecentChatList.addAll(mainRecentChatList);
  }

  String getChatType(RecentChatData recent) {
    return recent.isGroup!
        ? "groupchat"
        : recent.isBroadCast!
            ? "broadcast"
            : "chat";
  }

  String getProfileChatType(Profile profile) {
    return profile.isGroupProfile! ? "groupchat" : "chat";
  }

  fetchRecentChatList() async {
    debugPrint("========fetchRecentChatList======");
    await FlyChat.getRecentChatListIncludingArchived().then((value) {
      var recentChatList = <RecentChatData>[];
      var js = json.decode(value);
      var recentChatListWithArchived =
          List<RecentChatData>.from(js.map((x) => RecentChatData.fromJson(x)));
      for (var recentChat in recentChatListWithArchived) {
        if (recentChat.profileName != null &&
            recentChat.profileName!
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
    await FlyChat.searchConversation(search.text.trim().toString())
        .then((value) {
      var result = chatMessageModelFromJson(value);
      chatMessages(result);
      var mRecentSearchList = <Rx<RecentSearch>>[].obs;
      var i = 0.obs;
      for (var message in result) {
        var searchMessageItem = RecentSearch(
                jid: message.chatUserJid,
                mid: message.messageId,
                searchType: Constants.typeSearchMessage,
                chatType: message.messageChatType.toString(),
                isSearch: true)
            .obs;
        mRecentSearchList.insert(0, searchMessageItem);
        i++;
      }
      var map = <Rx<int>, RxList<Rx<RecentSearch>>>{}; //{0,searchMessageItem};
      map.putIfAbsent(i, () => mRecentSearchList).obs;
      filteredMessageList(map);
      update();
    });
  }

  fetchContactList(List<String> jidList) {
    FlyChat.getRegisteredUsers(true).then((value) {
      var profileDetails = userListFromJson(value).data;
      if (profileDetails != null) {
        var filterProfileList = profileDetails.where((it) =>
            !jidList.contains(it.jid) &&
            it.name!.contains(search.text.trim().toString()) == true);
        filterProfileList.toList().sort((a, b) {
          return a.name!.toLowerCase().compareTo(b.name!.toLowerCase());
        });
        filteredContactList(filterProfileList.toList());
        update(filteredContactList);
      }
    });
  }

  Future<RecentChatData?> getRecentChatofJid(String jid) async {
    var value = await FlyChat.getRecentChatOf(jid);
    mirrorFlyLog("rchat", value.toString());
    if (value != null) {
      var data = RecentChatData.fromJson(json.decode(value));
      return data;
    } else {
      return null;
    }
  }

  Future<CheckModel?> getMessageOfId(String mid) async {
    var value = await FlyChat.getMessageOfId(mid);
    if (value != null) {
      var data = checkModelFromJson(value);
      return data;
    } else {
      return null;
    }
  }

  Future<ProfileData?> getProfile(String jid) async {
    await FlyChat.getProfileLocal(jid, false).then((value) async {
      if (value != null) {
        var data = profileDataFromJson(value);
        return data.data;
      } else {
        return null;
      }
    });
    return null;
  }

  Future<Map<ProfileData?, ChatMessageModel?>?> getProfileAndMessage(
      String jid, String mid) async {
    var value = await FlyChat.getProfileLocal(jid, false);
    var value2 = await FlyChat.getMessageOfId(mid);
    if (value != null && value2 != null) {
      var data = profileDataFromJson(value);
      var data2 = sendMessageModelFromJson(value2);
      var map = <ProfileData?, ChatMessageModel?>{}; //{0,searchMessageItem};
      map.putIfAbsent(data.data, () => data2);
      return map;
    }
    return null;
  }

  toChatPage(String jid) {
    if (jid.isNotEmpty) {
      FlyChat.getProfileDetails(jid, false).then((value) {
        if (value != null) {
          var profile = profiledata(value.toString());
          Get.toNamed(Routes.chat, arguments: profile);
        }
      });
      // SessionManagement.setChatJid(jid);
      // Get.toNamed(Routes.chat);
    }
  }

  /*String getSpannableString(String messageContent,RecentChatData message){
    var startIndex = messageContent.toLowerCase().indexOf(search.text.toString().toLowerCase());
    if (!startIndex.isNegative && !message.isMessageRecalled) {
      val stopIndex = startIndex + searchKey.length
      textToHighlight.setSpan(ForegroundColorSpan(Color.BLUE), startIndex, stopIndex, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE)
    }

  }*/

  _scrollListener() {
    if (userlistScrollController.hasClients) {
      if (userlistScrollController.position.extentAfter <= 0 &&
          isPageLoading.value == false) {
        if (scrollable.value && !searching) {
          //isPageLoading.value = true;
          mirrorFlyLog("scroll", "end");
          pageNum++;
          getUsers();
        }
      }
    }
  }

  var pageNum = 1;
  var searching = false;
  var searchLoading = false.obs;

  Future<void> filterUserlist() async {
    if (await AppUtils.isNetConnected()) {
      searching = true;
      FlyChat.getUserList(pageNum, search.text.trim().toString()).then((value) {
        if (value != null) {
          var list = userListFromJson(value);
          if (list.data != null) {
            scrollable(list.data!.length == 20);
            _userList(list.data);
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
      });
    } else {
      toToast(Constants.noInternetConnection);
    }
  }

  Future<void> getUsers() async {
    if (await AppUtils.isNetConnected()) {
      searching = true;
      FlyChat.getUserList(pageNum, search.text.trim().toString()).then((value) {
        if (value != null) {
          var list = userListFromJson(value);
          if (list.data != null) {
            if (_mainuserList.isEmpty) {
              _mainuserList.addAll(list.data!);
            }
            scrollable(list.data!.length == 20);
            _userList.value.addAll(list.data!);
            _userList.refresh();
          } else {
            scrollable(false);
          }
        }
        searching = false;
      }).catchError((error) {
        debugPrint("issue===> $error");
        searching = false;
      });
    } else {
      toToast(Constants.noInternetConnection);
    }
  }

  void userUpdatedHisProfile(jid) {
    updateRecentChatAdapter(jid);
    updateProfile(jid);
  }

  Future<void> updateRecentChatAdapter(String jid) async {
    if (jid.isNotEmpty) {
      var mainIndex = mainRecentChatList.indexWhere((element) =>
          element.value.jid ==
          jid); // { it.jid ?: Constants.EMPTY_STRING == jid }
      var filterIndex = filteredRecentChatList.indexWhere((element) =>
          element.jid == jid); // { it.jid ?: Constants.EMPTY_STRING == jid }
      var frmIndex = frmRecentChatList.indexWhere((element) =>
          element.value.jid ==
          jid); // { it.jid ?: Constants.EMPTY_STRING == jid }
      var recent = await getRecentChatOfJid(jid);
      if (recent != null) {
        if (!mainIndex.isNegative) {
          mainRecentChatList[mainIndex] = recent.obs;
        }
        if (!filterIndex.isNegative) {
          filteredRecentChatList[filterIndex] = recent;
        }
        if (!frmIndex.isNegative) {
          frmRecentChatList[frmIndex] = recent.obs;
        }
      }
    }
  }

  Future<void> updateProfile(String jid) async {
    if (jid.isNotEmpty) {
      var userListIndex = _userList.indexWhere((element) => element.jid == jid);
      getProfileDetails(jid).then((value) {
        if (!userListIndex.isNegative) {
          _userList[userListIndex] = value;
        }
      });
    }
  }
}
