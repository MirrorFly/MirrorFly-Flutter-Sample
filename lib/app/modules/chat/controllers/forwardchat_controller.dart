import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:flysdk/flysdk.dart';

import '../../../common/de_bouncer.dart';
import '../../../data/apputils.dart';

class ForwardChatController extends GetxController {

  //main list
  final _mainrecentChats = <RecentChatData>[];
  final _maingroupList = <Profile>[];
  final _mainuserList = <Profile>[];

  final _recentChats = <RecentChatData>[].obs;
  set recentChats(List<RecentChatData> value) => _recentChats.value = value;
  List<RecentChatData> get recentChats => _recentChats.value.take(3).toList();

  final _groupList = <Profile>[].obs;
  set groupList(List<Profile> value) => _groupList.value = value;
  List<Profile> get groupList => _groupList.value.take(6).toList();

  var userlistScrollController = ScrollController();
  var scrollable =true.obs;
  var isPageLoading =false.obs;
  final _userList = <Profile>[].obs;
  set userList(List<Profile> value) => _userList.value = value;
  List<Profile> get userList => _userList.value;

  final _search = false.obs;
  set search(value) => _search.value = value;
  bool get search => _search.value;

  final _isSearchVisible = true.obs;
  set isSearchVisible(value) => _isSearchVisible.value = value;
  bool get isSearchVisible => _isSearchVisible.value;

  var selectedJids = <String>[].obs;
  var selectedNames = <String>[].obs;

  var forwardMessageIds =<String>[];
  @override
  void onInit(){
    super.onInit();
    var messageIds = Get.arguments["messageIds"] as List<String>;
    forwardMessageIds.addAll(messageIds);
    userlistScrollController.addListener(_scrollListener);
    getRecentChatList();
    getAllgroups();
    getUsers();

    _recentChats.bindStream(_recentChats.stream);
    ever(_recentChats, (callback){
      removeGroupItem();
    });
    _groupList.bindStream(_groupList.stream);
    ever(_groupList, (callback){
      removeGroupItem();
    });
    _userList.bindStream(_userList.stream);
    ever(_userList, (callback){
      removeUserItem();
    });

  }
  removeGroupItem(){
    if(recentChats.isNotEmpty && groupList.isNotEmpty) {
      for (var element in recentChats) {
        var groupIndex = groupList.indexWhere((it) => it.jid == element.jid);
        if (!groupIndex.isNegative) {
          _groupList.value.removeAt(groupIndex);
          _groupList.refresh();
        }
      }
    }
  }
  removeUserItem(){
    if(recentChats.isNotEmpty && userList.isNotEmpty) {
      for (var element in recentChats) {
        var index = userList.indexWhere((it) => it.jid == element.jid);
        if (!index.isNegative) {
          _userList.value.removeAt(index);
          _userList.refresh();
        }
      }
    }
  }
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

  void getRecentChatList() {
    FlyChat.getRecentChatList().then((value) {
      var data = recentChatFromJson(value);
      if(_mainrecentChats.isEmpty){
        _mainrecentChats.addAll(data.data!);
      }
      _recentChats(data.data!);
    }).catchError((error) {
      debugPrint("issue===> $error");
    });
  }

  void getAllgroups() {
    FlyChat.getAllGroups().then((value){
      if(value!=null){
        var list = profileFromJson(value);
        if(_maingroupList.isEmpty){
          _maingroupList.addAll(list);
        }
        _groupList(list);
      }
    }).catchError((error) {
      debugPrint("issue===> $error");
    });
  }

  var pageNum = 1;
  var searchQuery = TextEditingController();
  var searching = false;
  var searchLoading = false.obs;
  Future<void> getUsers() async {
    if(await AppUtils.isNetConnected()) {
      searching=true;
      FlyChat.getUserList(pageNum, searchQuery.text.toString()).then((value){
        if(value!=null){
          var list = userListFromJson(value);
          if(list.data !=null) {
            if(_mainuserList.isEmpty){
              _mainuserList.addAll(list.data!);
            }
            _userList.value.addAll(list.data!);
            _userList.refresh();
          }
        }
        searching=false;
      }).catchError((error) {
        debugPrint("issue===> $error");
        searching=false;
      });
    }else{
      toToast(Constants.noInternetConnection);
    }

  }

  void onSearchPressed(){
    _isSearchVisible(false);
  }

  void filterRecentchat(){
    _recentChats.value.clear();
    for (var recentChat in _mainrecentChats) {
      if (recentChat.profileName != null &&
          recentChat.profileName!.toLowerCase().contains(searchQuery.text.trim().toString().toLowerCase()) ==
              true) {
        _recentChats.value.add(recentChat);
        _recentChats.refresh();
      }
    }
  }

  void filterGroupchat(){
    _groupList.value.clear();
    for (var group in _maingroupList) {
      if (group.name != null &&
          group.name!.toLowerCase().contains(searchQuery.text.trim().toString().toLowerCase()) ==
              true) {
        _groupList.value.add(group);
        _groupList.refresh();
      }
    }
  }

  Future<void> filterUserlist() async {
    if(await AppUtils.isNetConnected()) {
      _userList.clear();
      searching=true;
      searchLoading(true);
      FlyChat.getUserList(pageNum, searchQuery.text.toString()).then((value){
        if(value!=null){
          var list = userListFromJson(value);
          if(list.data !=null) {
            scrollable(list.data!.length==20);
            _userList(list.data);
          }else{
            scrollable(false);
          }
        }
        searching=false;
        searchLoading(false);
      }).catchError((error) {
        debugPrint("issue===> $error");
        searching=false;
        searchLoading(false);
      });
    }else{
      toToast(Constants.noInternetConnection);
    }

  }

  bool isChecked(String jid) => selectedJids.value.contains(jid);

  void onItemClicked(String jid,String name){

      if (selectedJids.value.contains(jid)) {
        selectedJids.value.removeAt(selectedJids.indexOf(jid));
        selectedNames.value.removeAt(selectedNames.indexOf(name));
      } else {
        if(selectedJids.value.length<5) {
          selectedJids.value.add(jid);
          selectedNames.value.add(name);
        }else{
          toToast("You can only forward with upto 5 users or groups");
        }
      }

    _recentChats.refresh();
    _groupList.refresh();
    _userList.refresh();

  }

  final deBouncer = DeBouncer(milliseconds: 700);
  String lastInputValue = "";
  void onSearch(String search){
    if (lastInputValue != search) {
      lastInputValue = search;
      if (searchQuery.text
          .toString()
          .trim()
          .isNotEmpty) {
        deBouncer.run(() {
          pageNum = 1;
          filterRecentchat();
          filterGroupchat();
          filterUserlist();
        });
      }
    }
  }

  void backFromSearch(){
    pageNum=1;
    searchQuery.clear();
    _isSearchVisible(true);
    scrollable(_mainuserList.length==20);
    _recentChats(_mainrecentChats);
    _groupList(_maingroupList);
    _userList(_mainuserList);
  }

  forwardMessages() async {
    if(await AppUtils.isNetConnected()) {
      var busyStatus = await FlyChat.isBusyStatusEnabled();
      if(!busyStatus.checkNull()) {
        if(forwardMessageIds.isNotEmpty && selectedJids.value.isNotEmpty) {
          FlyChat.forwardMessagesToMultipleUsers(forwardMessageIds, selectedJids.value)
              .then((values) {
            // debugPrint("to chat profile ==> ${selectedUsersList[0].toJson().toString()}");
            FlyChat.getProfileDetails(selectedJids.value.last, false).then((value) {
              if (value != null) {
                var str = profiledata(value.toString());
                Get.back(result: str);
              }
            });
          });
        }
      }else{
        //show busy status popup
        //var messageObject = MessageObject(toJid: profile.jid.toString(),replyMessageId: (isReplying.value) ? replyChatMessage.messageId : "", messageType: Constants.mText,textMessage: messageController.text);
        //showBusyStatusAlert(disableBusyChatAndSend());
      }

    }else{
      toToast(Constants.noInternetConnection);
    }

  }

  Future<String> getParticipantsNameAsCsv(String jid) async{
    var groupParticipantsName ="";
    await FlyChat.getGroupMembersList(jid, false).then((value) {
      if (value != null) {
        var str = <String>[];
        var groupsMembersProfileList = memberFromJson(value);
        for (var it in groupsMembersProfileList) {
          //if (it.jid.checkNull() != SessionManagement.getUserJID().checkNull()) {
            str.add(it.name.checkNull());
          //}
        }
        return groupParticipantsName=(str.join(","));
      }
    });
    return groupParticipantsName;
  }
}