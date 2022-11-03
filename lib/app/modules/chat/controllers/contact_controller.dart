import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/model/chatMessageModel.dart';
import 'package:mirror_fly_demo/app/nativecall/platformRepo.dart';

import '../../../model/userlistModel.dart';
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
  var search = false.obs;
  var _searchText = "";
  var _first = true;

  var isForward = false.obs;

  @override
  void onInit() {
    super.onInit();
    isForward(Get.arguments["forward"]);
    if (isForward.value) {
      forwardMessageIds.addAll(Get.arguments["messageIds"]);
    }
    scrollController.addListener(_scrollListener);
    //searchQuery.addListener(_searchListener);
    fetchUsers(false);
  }

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
    search.value = false;
    searchQuery.text = "";
    _searchText = "";
    //if(!_IsSearching){
    //isPageLoading.value=true;
    pageNum = 1;
    //fetchUsers(true);
    //}
    usersList(mainUsersList);
  }

  fetchUsers(bool fromSearch) {
    PlatformRepo().getUsers(pageNum, _searchText).then((data) {
      var item = userListFromJson(data);
      fromSearch ? usersList(item.data) : usersList.addAll(item.data!);
      pageNum = pageNum + 1;
      isPageLoading.value = false;
      scrollable.value = item.data!.length == 20;
      usersList.refresh();
      if (_first) {
        _first = false;
        mainUsersList(item.data!);
      }
    })
        .catchError((error) {
      Fluttertoast.showToast(
          msg: error.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          fontSize: 16.0);
    });
  }

  get users => usersList;

  String imagePath(String? imgUrl) {
    if (imgUrl == null || imgUrl == "") {
      return "";
    }
    PlatformRepo().imagePath(imgUrl).then((value) {
      return value ?? "";
    });
    return "";
  }

  contactSelected(Profile item) {
    if (selectedUsersList.contains(item)) {
      selectedUsersList.remove(item);
      selectedUsersJIDList.remove(item.jid);
      item.isSelected = false;
    } else {
      selectedUsersList.add(item);
      selectedUsersJIDList.add(item.jid!);
      item.isSelected = true;
    }
    usersList.refresh();
  }

  forwardMessages() {
    PlatformRepo()
        .forwardMessage(forwardMessageIds, selectedUsersJIDList)
        .then((value) {
      debugPrint(
          "to chat profile ==> ${selectedUsersList[0].toJson().toString()}");
      Get.back(result: selectedUsersList[0]);
      // Future.delayed(const Duration(milliseconds: 100), (){
      // Get.off(Routes.CHAT,
      //     arguments: selectedUsersList[0]);
      // });
      // });
    });
  }
}
