import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/common/extensions.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../common/de_bouncer.dart';
import '../../../common/main_controller.dart';
import '../../../data/apputils.dart';

class ForwardChatController extends GetxController {
  //main list
  final _mainrecentChats = <RecentChatData>[];
  final _maingroupList = <ProfileDetails>[];
  final _mainuserList = <ProfileDetails>[];

  final _recentChats = <RecentChatData>[].obs;

  set recentChats(List<RecentChatData> value) => _recentChats.value = value;

  List<RecentChatData> get recentChats => _recentChats.take(3).toList();

  final _groupList = <ProfileDetails>[].obs;

  set groupList(List<ProfileDetails> value) => _groupList.value = value;

  List<ProfileDetails> get groupList => _groupList.take(6).toList();

  var userlistScrollController = ScrollController();
  var scrollable = (!Constants.enableContactSync).obs;
  var isPageLoading = false.obs;
  final _userList = <ProfileDetails>[].obs;

  set userList(List<ProfileDetails> value) => _userList.value = value;

  List<ProfileDetails> get userList => _userList;

  final _search = false.obs;

  set search(value) => _search.value = value;

  bool get search => _search.value;

  final _isSearchVisible = true.obs;

  set isSearchVisible(value) => _isSearchVisible.value = value;

  bool get isSearchVisible => _isSearchVisible.value;

  var selectedJids = <String>[].obs;
  var selectedNames = <String>[].obs;

  var forwardMessageIds = <String>[];

  @override
  void onInit() {
    super.onInit();
    var messageIds = Get.arguments["messageIds"] as List<String>;
    forwardMessageIds.addAll(messageIds);
    userlistScrollController.addListener(_scrollListener);
    getRecentChatList();
    getAllGroups();
    getUsers();

    _recentChats.bindStream(_recentChats.stream);
    ever(_recentChats, (callback) {
      removeGroupItem();
    });
    _groupList.bindStream(_groupList.stream);
    ever(_groupList, (callback) {
      removeGroupItem();
    });
    _userList.bindStream(_userList.stream);
    ever(_userList, (callback) {
      removeUserItem();
    });
  }

  removeGroupItem() {
    if (recentChats.isNotEmpty && groupList.isNotEmpty) {
      for (var element in recentChats) {
        var groupIndex = groupList.indexWhere((it) => it.jid == element.jid);
        if (!groupIndex.isNegative) {
          _groupList.removeAt(groupIndex);
          _groupList.refresh();
        }
      }
    }
  }

  removeUserItem() {
    if (recentChats.isNotEmpty && userList.isNotEmpty) {
      for (var element in recentChats) {
        var index = userList.indexWhere((it) => it.jid == element.jid);
        if (!index.isNegative) {
          _userList.removeAt(index);
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
          getUsers(bottom: true);
        }
      }
    }
  }

  void getRecentChatList() {
    Mirrorfly.getRecentChatList().then((value) {
      var data = recentChatFromJson(value);
      if (_mainrecentChats.isEmpty) {
        _mainrecentChats.addAll(data.data!);
      }
      _recentChats(data.data!);
    }).catchError((error) {
      debugPrint("issue===> $error");
    });
  }

  void getAllGroups() {
    Mirrorfly.getAllGroups().then((value) {
      if (value != null) {
        var list = profileFromJson(value);
        if (_maingroupList.isEmpty) {
          _maingroupList.addAll(list);
        }
        _groupList(list);
      }
    }).catchError((error) {
      debugPrint("issue===> $error");
    });
  }

  @override
  void onClose() {
    super.onClose();
    searchQuery.dispose();
  }

  var pageNum = 1;
  var searchQuery = TextEditingController(text: '');
  var searching = false;
  var searchLoading = false.obs;
  var contactLoading = false.obs;

  Future<void> getUsers({bool bottom = false}) async {
    if (await AppUtils.isNetConnected()) {
      if(!bottom)contactLoading(true);
      searching = true;
      callback (FlyResponse response){
        if(response.isSuccess){
          if (response.data.isNotEmpty) {
            var list = userListFromJson(response.data);
            if (list.data != null) {
              if (_mainuserList.isEmpty) {
                _mainuserList.addAll(list.data!);
              }
              _userList.addAll(list.data!);
              _userList.refresh();
            }
          }
          searching = false;
          contactLoading(false);
        }else{
          searching = false;
          contactLoading(false);
        }
      }
      (!Constants.enableContactSync)
          ? Mirrorfly.getUserList(pageNum, searchQuery.text.trim().toString(),flyCallback: callback)
          : Mirrorfly.getRegisteredUsers(false,flyCallback: callback);
      /*future
      // Mirrorfly.getUserList(pageNum, searchQuery.text.trim().toString())
          .then((value) {
        if (value.isNotEmpty) {
          var list = userListFromJson(value);
          if (list.data != null) {
            if (_mainuserList.isEmpty) {
              _mainuserList.addAll(list.data!);
            }
            _userList.addAll(list.data!);
            _userList.refresh();
          }
        }
        searching = false;
        contactLoading(false);
      }).catchError((error) {
        debugPrint("issue===> $error");
        searching = false;
        contactLoading(false);
      });*/
    } else {
      toToast(Constants.noInternetConnection);
    }
  }

  void onSearchPressed() {
    _isSearchVisible(false);
  }

  void filterRecentChat() {
    _recentChats.clear();
    for (var recentChat in _mainrecentChats) {
      if (recentChat.profileName != null &&
          recentChat.profileName!
                  .toLowerCase()
                  .contains(searchQuery.text.trim().toString().toLowerCase()) ==
              true) {
        _recentChats.add(recentChat);
        _recentChats.refresh();
      }
    }
  }

  void filterGroupChat() {
    _groupList.clear();
    for (var group in _maingroupList) {
      if (group.name != null &&
          group.name!
                  .toLowerCase()
                  .contains(searchQuery.text.trim().toString().toLowerCase()) ==
              true) {
        _groupList.add(group);
        _groupList.refresh();
      }
    }
  }

  Future<void> filterUserList() async {
    if (await AppUtils.isNetConnected()) {
      _userList.clear();
      searching = true;
      searchLoading(true);
      callback(FlyResponse response){
        if(response.isSuccess){
          if (response.data.isNotEmpty) {
            var list = userListFromJson(response.data);
            if (list.data != null) {
              scrollable((list.data!.length == 20 && !Constants.enableContactSync));
              if(!Constants.enableContactSync) {
                _userList(list.data);
              }else{
                _userList(list.data!.where((element) => element.nickName.checkNull().toLowerCase().contains(searchQuery.text.trim().toString().toLowerCase())).toList());
              }
            } else {
              scrollable(false);
            }
          }
          searching = false;
          searchLoading(false);
        }else{
          searching = false;
          searchLoading(false);
        }
      }
      (!Constants.enableContactSync)
          ? Mirrorfly.getUserList(pageNum, searchQuery.text.trim().toString(),flyCallback: callback)
          : Mirrorfly.getRegisteredUsers(false,flyCallback: callback);
      /*future
      // Mirrorfly.getUserList(pageNum, searchQuery.text.trim().toString())
          .then((value) {
        if (value.isNotEmpty) {
          var list = userListFromJson(value);
          if (list.data != null) {
            scrollable((list.data!.length == 20 && !Constants.enableContactSync));
            if(!Constants.enableContactSync) {
              _userList(list.data);
            }else{
              _userList(list.data!.where((element) => element.nickName.checkNull().toLowerCase().contains(searchQuery.text.trim().toString().toLowerCase())).toList());
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
      toToast(Constants.noInternetConnection);
    }
  }

  bool isChecked(String jid) => selectedJids.contains(jid);

  Future<void> onItemSelect(String jid, String name,bool isBlocked,bool isGroup) async {
    if(isGroup.checkNull() && !availableFeatures.value.isGroupChatAvailable.checkNull()){
      Helper.showFeatureUnavailable();
      return;
    }
    if(isGroup.checkNull() && !(await Mirrorfly.isMemberOfGroup(jid, null)).checkNull()){
      toToast("You're no longer a participant in this group");
      return;
    }
    if(isBlocked.checkNull()){
      unBlock(jid,name);
    }else{
      onItemClicked(jid,name);
    }
  }

  unBlock(String jid, String name,){
    Helper.showAlert(message: "Unblock $name?", actions: [
      TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text("NO")),
      TextButton(
          onPressed: () async {
            if(await AppUtils.isNetConnected()) {
              Get.back();
              // Helper.progressLoading();
              Mirrorfly.unblockUser(jid.checkNull()).then((value) {
                // Helper.hideLoading();
                if(value!=null && value.checkNull()) {
                  toToast("$name has been Unblocked");
                  userUpdatedHisProfile(jid);
                }
              }).catchError((error) {
                // Helper.hideLoading();
                debugPrint(error.toString());
              });
            }else{
              toToast(Constants.noInternetConnection);
            }

          },
          child: const Text("YES")),
    ]);
  }

  void onItemClicked(String jid, String name) {
    if (selectedJids.contains(jid)) {
      selectedJids.removeAt(selectedJids.indexOf(jid));
      selectedNames.removeAt(selectedNames.indexOf(name));
    } else {
      if (selectedJids.length < 5) {
        selectedJids.add(jid);
        selectedNames.add(name);
      } else {
        toToast("You can only forward with upto 5 users or groups");
      }
    }

    _recentChats.refresh();
    _groupList.refresh();
    _userList.refresh();
  }

  final deBouncer = DeBouncer(milliseconds: 700);
  String lastInputValue = "";

  void onSearch(String search) {
    mirrorFlyLog("search", "onSearch");
    if (lastInputValue != searchQuery.text.toString().trim()) {
      lastInputValue = searchQuery.text.toString().trim();
      if (searchQuery.text.toString().trim().isNotEmpty) {
        debugPrint("cleared not");
        deBouncer.run(() {
          pageNum = 1;
          filterRecentChat();
          filterGroupChat();
          filterUserList();
        });
      } else {
        debugPrint("cleared");
        _recentChats.refresh();
        _groupList.refresh();
        _userList.refresh();
      }
    }
  }

  void backFromSearch() {
    pageNum = 1;
    searchQuery.clear();
    _isSearchVisible(true);
    scrollable((_mainuserList.length == 20 && !Constants.enableContactSync));
    _recentChats(_mainrecentChats);
    _groupList(_maingroupList);
    _userList(_mainuserList);
  }

  forwardMessages() async {
    if (await AppUtils.isNetConnected()) {
      var busyStatus = await Mirrorfly.isBusyStatusEnabled();
      if (!busyStatus.checkNull()) {
        if (forwardMessageIds.isNotEmpty && selectedJids.isNotEmpty) {
          Mirrorfly.forwardMessagesToMultipleUsers(
                  forwardMessageIds, selectedJids)
              .then((values) {
            // debugPrint("to chat profile ==> ${selectedUsersList[0].toJson().toString()}");
            getProfileDetails(selectedJids.last)
                .then((value) {
              if (value.jid != null) {
                // var str = profiledata(value.toString());
                Get.back(result: value);
              }
            });
          }).catchError((onError){
            onError as PlatformException;
            if(onError.message!=null) {
              toToast(onError.message!);
              Get.back(result: null);
            }
          });
        }
      } else {
        //show busy status popup
        // var messageObject = MessageObject(toJid: profile.jid.toString(),replyMessageId: (isReplying.value) ? replyChatMessage.messageId : "", messageType: Constants.mText,textMessage: messageController.text);
        //showBusyStatusAlert(disableBusyChatAndSend());
      }
    } else {
      toToast(Constants.noInternetConnection);
    }
  }

  Future<String> getParticipantsNameAsCsv(String jid) async {
    var groupParticipantsName = "";
    await Mirrorfly.getGroupMembersList(jid, false).then((value) {
      if (value.isNotEmpty) {
        var str = <String>[];
        var groupsMembersProfileList = memberFromJson(value);
        for (var it in groupsMembersProfileList) {
          //if (it.jid.checkNull() != SessionManagement.getUserJID().checkNull()) {
          str.add(it.name.checkNull());
          //}
        }
        return groupParticipantsName = (str.join(","));
      }
    });
    return groupParticipantsName;
  }

  void userUpdatedHisProfile(String jid) {
    if (jid.toString().isNotEmpty) {
      updateRecentChatAdapter(jid);
      updateProfile(jid);
    }
  }

  Future<void> updateRecentChatAdapter(String jid) async {
    var index = _recentChats.indexWhere((element) =>
        element.jid == jid); // { it.jid ?: Constants.EMPTY_STRING == jid }
    var mainIndex = _mainrecentChats.indexWhere((element) =>
        element.jid == jid); // { it.jid ?: Constants.EMPTY_STRING == jid }
    if (jid.isNotEmpty) {
      var recent = await getRecentChatOfJid(jid);
      if (recent != null) {
        if (!index.isNegative) {
          _recentChats[index] = recent;
        }
        if (!mainIndex.isNegative) {
          _mainrecentChats[mainIndex] = recent;
        }
      }
    }
  }

  Future<void> updateProfile(String jid) async {
    var maingroupListIndex =
        _maingroupList.indexWhere((element) => element.jid == jid);
    var mainuserListIndex =
        _mainuserList.indexWhere((element) => element.jid == jid);
    var groupListIndex =
        _groupList.indexWhere((element) => element.jid == jid);
    var userListIndex = _userList.indexWhere((element) => element.jid == jid);
    getProfileDetails(jid).then((value) {
      if (!maingroupListIndex.isNegative) {
        _maingroupList[maingroupListIndex] = value;
      }
      if (!mainuserListIndex.isNegative) {
        _mainuserList[mainuserListIndex] = value;
      }
      if (!groupListIndex.isNegative) {
        _groupList[groupListIndex] = value;
      }
      if (!userListIndex.isNegative) {
        _userList[userListIndex] = value;
      }
    });
  }

  void onContactSyncComplete(bool result) {
    getRecentChatList();
    getAllGroups();
    getUsers();
    if (searchQuery.text.toString().trim().isNotEmpty) {
      lastInputValue='';
      onSearch(searchQuery.text.toString());
    }
  }

  void checkContactSyncPermission() {
    Permission.contacts.isGranted.then((value) {
      if(!value){
        _mainuserList.clear();
        _userList.clear();
        _userList.refresh();
      }
    });
  }

  void userDeletedHisProfile(String jid) {
    userUpdatedHisProfile(jid);
  }

  var availableFeatures = Get.find<MainController>().availableFeature;
  void onAvailableFeaturesUpdated(AvailableFeatures features) {
    LogMessage.d("Forward", "onAvailableFeaturesUpdated ${features.toJson()}");
    availableFeatures(features);
  }
}
