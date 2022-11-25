import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:flysdk/flysdk.dart';

import '../../../common/de_bouncer.dart';
import '../../../model/group_members_model.dart';
import '../../../model/recent_chat.dart';
import '../../../model/userListModel.dart';

class ForwardChatController extends GetxController {

  //main list
  final _main_recentChats = <RecentChatData>[];
  final _main_groupList = <Profile>[];
  final _main_userList = <Profile>[];

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
  var focusnode = FocusNode();
  var focus =true;

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

    focusnode.addListener(() {
      if(!focusnode.hasFocus){
        focus=false;
      }
    });
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
      if(_main_recentChats.isEmpty){
        _main_recentChats.addAll(data.data!);
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
        if(_main_groupList.isEmpty){
          _main_groupList.addAll(list);
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
  void getUsers() {
    searching=true;
    FlyChat.getUserList(pageNum, searchQuery.text.toString()).then((value){
      if(value!=null){
        var list = userListFromJson(value);
        if(list.data !=null) {
          if(_main_userList.isEmpty){
            _main_userList.addAll(list.data!);
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
  }

  void onSearchPressed(){
    _isSearchVisible(false);
  }

  void filterRecentchat(){
    _recentChats.value.clear();
    for (var recentChat in _main_recentChats) {
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
    for (var group in _main_groupList) {
      if (group.name != null &&
          group.name!.toLowerCase().contains(searchQuery.text.trim().toString().toLowerCase()) ==
              true) {
        _groupList.value.add(group);
        _groupList.refresh();
      }
    }
  }

  void filterUserlist(){
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
  void onSearch(String search){
    if(focus) {
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
    scrollable(_main_userList.length==20);
    _recentChats(_main_recentChats);
    _groupList(_main_groupList);
    _userList(_main_userList);
  }

  forwardMessages() {
    if(forwardMessageIds.isNotEmpty && selectedJids.value.isNotEmpty) {
      FlyChat.forwardMessagesToMultipleUsers(forwardMessageIds, selectedJids.value)
          .then((value) {
        // debugPrint("to chat profile ==> ${selectedUsersList[0].toJson().toString()}");
        FlyChat.getProfileDetails(selectedJids.value.last, false).then((value) {
          if (value != null) {
            var str = profiledata(value.toString());
            Get.back(result: str);
          }
        });
      });
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