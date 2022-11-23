import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/model/recent_chat.dart';
import 'package:mirror_fly_demo/app/model/userListModel.dart';
import 'package:mirror_fly_demo/app/nativecall/fly_chat.dart';

import '../../../common/constants.dart';
import '../../../model/chatmessage_model.dart';
import '../../../model/check_model.dart';
import '../../../model/profile_model.dart';
import '../../../model/recent_search_model.dart';
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

  RxList<ChatMessage> chatMessages = <ChatMessage>[].obs;

  TextEditingController search = TextEditingController();

  @override
  void onInit() {
    super.onInit();
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
          if(getChatType(recent)!="groupchat") {
            var recentSearchItem = RecentSearch(
                jid: recent.jid,
                mid: recent.lastMessageId,
                searchType: Constants.typeSearchRecent,
                chatType: getChatType(recent),
                isSearch: true).obs;
            recentSearchList.add(recentSearchItem);
            update();
            jidList.add(recent.jid.toString());
          }
        }
        fetchContactList(jidList);
      chatCount(jidList.length);
      //});
    });
    ever(filteredMessageList, (callback){
      mirrorFlyLog("sfilteredMessageList", callback.entries.first.value.length.toString());
      for (var item in callback.entries){
        mirrorFlyLog("msgs", item.value.first.value.jid.toString());
      }
      messageCount(callback.entries.first.key.value);
      recentSearchList.addAll(callback.entries.first.value);
      update(recentSearchList);
    });

    ever(filteredContactList, (callback){
      mirrorFlyLog("sfilteredContactList", callback.toString());
      for (var profile in callback) {
        if (!profile.isAdminBlocked!) {
          var searchContactItem = RecentSearch(
              jid: profile.jid,
              mid: null,
              searchType: Constants.typeSearchContact,
              chatType: getProfileChatType(profile),
              isSearch: true).obs;
          recentSearchList.add(searchContactItem);
          update();
        }
      }
    });

    ever(recentSearchList,(callback){
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

  onChange(){
    frmRecentChatList.clear();
    recentSearchList.clear();
    if(search.text.isNotEmpty) {
      fetchRecentChatList();
    }else{
      mirrorFlyLog("empty", "empty");
      frmRecentChatList.addAll(mainRecentChatList);
    }
    update();
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

  fetchRecentChatList() async{
    await FlyChat.getRecentChatListIncludingArchived().then((value) {
      var recentChatList = <RecentChatData>[];
      var js = json.decode(value);
      var recentChatListWithArchived = List<RecentChatData>.from(js.map((x) => RecentChatData.fromJson(x)));
      for (var recentChat in recentChatListWithArchived) {
        if (recentChat.profileName != null &&
            recentChat.profileName!.toLowerCase().contains(search.text.trim().toString().toLowerCase()) ==
                true) {
          recentChatList.add(recentChat);
        }
      }
      filteredRecentChatList(recentChatList);
      update(filteredRecentChatList);
    });
    fetchMessageList();
  }

  fetchMessageList() async{
    await FlyChat
        .searchConversation(search.text.trim().toString())
        .then((value) {
      var result = chatMessageFromJson(value);
      chatMessages(result);
      var mRecentSearchList = <Rx<RecentSearch>>[].obs;
      var i = 0.obs;
      for (var message in result) {
        var searchMessageItem = RecentSearch(
            jid: message.chatUserJid,
            mid: message.messageId,
            searchType: Constants.typeSearchMessage,
            chatType: message.messageChatType.toString(),
            isSearch: true).obs;
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
    FlyChat.getRegisteredUsers().then((value) {
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

  Future<RecentChatData?> getRecentChatofJid(String jid) async{
    var value = await FlyChat.getRecentChatOf(jid);
    mirrorFlyLog("rchat", value.toString());
    if (value != null) {
      var data = RecentChatData.fromJson(json.decode(value));
      return data;
    }else {
      return null;
    }
  }

  Future<CheckModel?> getMessageOfId(String mid) async{
    var value = await FlyChat.getMessageOfId(mid);
    if (value != null) {
      var data = checkModelFromJson(value);
      return data;
    }else {
      return null;
    }
  }

  Future<ProfileData?> getProfile(String jid) async{
    await FlyChat.getProfileLocal(jid,false).then((value)async{
      if (value != null) {
        var data = profileDataFromJson(value);
        return data.data;
      }else {
        return null;
      }
    });
    return null;
  }
  Future<Map<ProfileData?,ChatMessage?>?> getProfileAndMessage(String jid , String mid) async{
    var value = await FlyChat.getProfileLocal(jid,false);
    var value2 = await FlyChat.getMessageOfId(mid);
    if (value != null && value2 !=null) {
      var data = profileDataFromJson(value);
      var data2 = chatMessageFrmJson(value2);
      var map = <ProfileData?,ChatMessage?>{}; //{0,searchMessageItem};
      map.putIfAbsent(data.data, () => data2);
      return map;
    }
    return null;
  }

  toChatPage(String jid){
    if(jid.isNotEmpty) {
      FlyChat.getProfileLocal(jid, false).then((value) {
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
          profile.lastSeenPrivacyFlag = "";
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

  /*String getSpannableString(String messageContent,RecentChatData message){
    var startIndex = messageContent.toLowerCase().indexOf(search.text.toString().toLowerCase());
    if (!startIndex.isNegative && !message.isMessageRecalled) {
      val stopIndex = startIndex + searchKey.length
      textToHighlight.setSpan(ForegroundColorSpan(Color.BLUE), startIndex, stopIndex, Spannable.SPAN_EXCLUSIVE_EXCLUSIVE)
    }

  }*/
}
