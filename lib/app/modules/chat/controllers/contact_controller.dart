import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/nativecall/fly_chat.dart';

import '../../../model/userListModel.dart';
import '../../../routes/app_pages.dart';

class ContactController extends GetxController {
  ScrollController scrollController = ScrollController();
  var pageNum = 1;
  var isPageLoading = true.obs;
  var scrollable = true.obs;
  var usersList = <Profile>[].obs;
  var mainUsersList = List<Profile>.empty(growable: true).obs;
  var selectedUsersList = List<Profile>.empty(growable: true).obs;
  var selectedUsersJIDList = List<String>.empty(growable: true).obs;
  var forwardMessageIds = List<String>.empty(growable: true).obs;
  final TextEditingController searchQuery = TextEditingController();
  var _searchText = "";
  var _first = true;

  var isForward = false.obs;
  var isCreateGroup = false.obs;
  var groupJid = "".obs;

  @override
  void onInit() {
    super.onInit();
    isForward(Get.arguments["forward"]);
    if (isForward.value) {
      isCreateGroup(false);
      forwardMessageIds.addAll(Get.arguments["messageIds"]);
    }else {
      isCreateGroup(Get.arguments["group"]);
      groupJid(Get.arguments["groupJid"]);
    }
    scrollController.addListener(_scrollListener);
    //searchQuery.addListener(_searchListener);
    fetchUsers(false);
  }

  //Add participants
  final _search = false.obs;
  set search(bool value) => _search.value=value;
  bool get search => _search.value;

  void onSearchPressed(){
    if (_search.value) {
      _search(false);
    } else {
      _search(true);
    }
  }

  bool get isCreateVisible => isCreateGroup.value;
  bool get isSearchVisible => !_search.value;
  bool get isClearVisible => _search.value && !isForward.value && isCreateGroup.value;
  bool get isMenuVisible => !_search.value && !isForward.value;
  bool get isCheckBoxVisible => isCreateGroup.value || isForward.value;

  _scrollListener() {
    if (scrollController.hasClients) {
      if (scrollController.position.extentAfter <= 0 &&
          isPageLoading.value == false) {
        if (scrollable.value) {
          //isPageLoading.value = true;
          fetchUsers(false);
        }
      }
    }
  }

  searchListener(String text) async {
    debugPrint("searching .. ");
    if (text.isEmpty) {
      _searchText = "";
      pageNum = 1;
    }
    else {
      isPageLoading(true);
      _searchText = text;
      pageNum = 1;
    }
    fetchUsers(true);
  }

  backFromSearch() {
    _search.value = false;
    searchQuery.clear();
    _searchText = "";
    //if(!_IsSearching){
    //isPageLoading.value=true;
    pageNum = 1;
    //fetchUsers(true);
    //}
    usersList(mainUsersList);
    scrollable(true);
  }

  fetchUsers(bool fromSearch) {
    FlyChat.getUsers(pageNum, _searchText).then((data) async {
      var item = userListFromJson(data);
      var list = <Profile>[];

      if(groupJid.value.checkNull().isNotEmpty){
        await Future.forEach(item.data!, (it) async {
          await FlyChat.isMemberOfGroup(groupJid.value.checkNull(), it.jid.checkNull()).then((value){
            mirrorFlyLog("item", value.toString());
            if(value==null || !value){
              list.add(it);
            }
          });
        });
        fromSearch ? usersList(list) : usersList.addAll(list);
        pageNum = pageNum + 1;
        isPageLoading.value = false;
        scrollable.value = list.length == 20;
        usersList.refresh();
        if (_first) {
          _first = false;
          mainUsersList(list);
        }
      }else{
        list.addAll(item.data!);
        fromSearch ? usersList(list) : usersList.addAll(list);
        pageNum = pageNum + 1;
        isPageLoading.value = false;
        scrollable.value = list.length == 20;
        usersList.refresh();
        if (_first) {
          _first = false;
          mainUsersList(list);
        }
      }

    }).catchError((error) {
      toToast(error.toString());
    });
  }

  Future<List<Profile>> removeGroupMembers(List<Profile> items) async {
    var list = <Profile>[];
    for (var it in items) {
      var value = await FlyChat.isMemberOfGroup(groupJid.value.checkNull(), it.jid.checkNull());
      mirrorFlyLog("item", value.toString());
      if(value==null || !value){
        list.add(it);
      }
    }
    return list;
  }

  get users => usersList;

  String imagePath(String? imgUrl) {
    if (imgUrl == null || imgUrl == "") {
      return "";
    }
    FlyChat.imagePath(imgUrl).then((value) {
      return value ?? "";
    });
    return "";
  }

  contactSelected(Profile item) {
    if (selectedUsersList.contains(item)) {
      selectedUsersList.remove(item);
      selectedUsersJIDList.remove(item.jid);
      //item.isSelected = false;
    } else {
      selectedUsersList.add(item);
      selectedUsersJIDList.add(item.jid!);
      //item.isSelected = true;
    }
    usersList.refresh();
  }

  forwardMessages() {
    FlyChat
        .forwardMessagesToMultipleUsers(forwardMessageIds, selectedUsersJIDList)
        .then((value) {
      debugPrint(
          "to chat profile ==> ${selectedUsersList[0].toJson().toString()}");
      Get.back(result: selectedUsersList[0]);
    });
  }

  onListItemPressed(Profile item){
    if (isForward.value|| isCreateGroup.value) {
      contactSelected(item);
    }else{
      Get.offNamed(Routes.CHAT, arguments: item);
    }
  }

  backToCreateGroup(){
    if(groupJid.value.isEmpty) {
      if (selectedUsersJIDList.length >= Constants.minGroupMembers) {
        Get.back(result: selectedUsersJIDList);
      } else {
        toToast("Add at least two contacts");
      }
    }else{
      if(selectedUsersJIDList.isNotEmpty){
        Get.back(result: selectedUsersJIDList);
      }else{
        Get.back();
      }
    }
  }
}
