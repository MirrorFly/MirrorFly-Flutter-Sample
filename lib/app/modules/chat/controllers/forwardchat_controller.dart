import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meta/meta.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/nativecall/fly_chat.dart';

import '../../../common/de_bouncer.dart';
import '../../../model/recent_chat.dart';
import '../../../model/userListModel.dart';

class ForwardChatController extends GetxController {

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
  @override
  void onInit(){
    super.onInit();
    var messageIds = Get.arguments["messageIds"] as List<String>;
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

    });

  }
  removeGroupItem(){
    if(recentChats.isNotEmpty && groupList.isNotEmpty) {
      for (var element in recentChats) {
        if (groupList.isNotEmpty) {
          var groupIndex = groupList.indexWhere((it) => it.jid == element.jid);
          if (!groupIndex.isNegative) {
            _groupList.value.removeAt(groupIndex);
            _groupList.refresh();
          }
        }
      }
    }
  }
  _scrollListener() {
    if (userlistScrollController.hasClients) {
      if (userlistScrollController.position.extentAfter <= 0 &&
          isPageLoading.value == false) {
        if (scrollable.value) {
          //isPageLoading.value = true;
          Log("scroll", "end");
          //getUsers();
        }
      }
    }
  }

  void getRecentChatList() {
    FlyChat.getRecentChatList().then((value) {
      var data = recentChatFromJson(value);
      _recentChats(data.data!);
    }).catchError((error) {
      debugPrint("issue===> $error");
    });
  }

  void getAllgroups() {
    FlyChat.getAllGroups().then((value){
      if(value!=null){
        var list = profileFromJson(value);
        _groupList(list);
      }
    }).catchError((error) {
      debugPrint("issue===> $error");
    });
  }

  var pageNum = 1;
  var searchQuery = TextEditingController();
  void getUsers() {
    FlyChat.getUsers(pageNum, searchQuery.text.toString()).then((value){
      if(value!=null){
        var list = userListFromJson(value);
        _userList(list.data);
      }
    }).catchError((error) {
      debugPrint("issue===> $error");
    });
  }

  void onSearchPressed(){

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

    deBouncer.run(() {

    });
  }

  void backFromSearch(){

  }
}