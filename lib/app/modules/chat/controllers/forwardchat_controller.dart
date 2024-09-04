import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/constants.dart';
import '../../../data/helper.dart';
import '../../../data/session_management.dart';
import '../../../extensions/extensions.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../app_style_config.dart';
import '../../../common/app_localizations.dart';
import '../../../common/de_bouncer.dart';
import '../../../common/main_controller.dart';
import '../../../data/utils.dart';

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

  late final BuildContext buildContext;

  init(List<String> messageId, BuildContext context) {
    buildContext = context;
    var messageIds = messageId;
    forwardMessageIds.addAll(messageIds);
    userlistScrollController.addListener(_scrollListener);
    getRecentChatList();
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
          LogMessage.d("scroll", "end");
          pageNum++;
          getUsers(bottom: true);
        }
      }
    }
  }

  void getRecentChatList() {
    Mirrorfly.getRecentChatList(flyCallBack: (FlyResponse response) {
      if(response.isSuccess && response.hasData) {
        var data = recentChatFromJson(response.data);
        if (data.data != null) {
          if (_mainrecentChats.isEmpty) {
            _mainrecentChats.addAll(data.data!);
          }
          var list = data.data!.take(3).toList();
          _recentChats(list);
        }
      }
      getAllGroups();
      getUsers();
    });
  }

  void getAllGroups() {
    Mirrorfly.getAllGroups(flyCallBack: (FlyResponse response) {
      if (response.isSuccess && response.hasData) {
        LogMessage.d("getAllGroups", response);
        var list = profileFromJson(response.data);
        for (var group in list) {
          if(recentChats.indexWhere((element) => element.jid == group.jid).isNegative){
            _maingroupList.add(group);
            _groupList.add(group);
          }
        }
      }
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
          if (response.hasData) {
            var list = userListFromJson(response.data);
            if (list.data != null) {
              for (var user in list.data!) {
                if(recentChats.indexWhere((element) => element.jid == user.jid).isNegative){
                  _mainuserList.add(user);
                  _userList.add(user);
                }
              }
              /*if (_mainuserList.isEmpty) {
                _mainuserList.addAll(list.data!);
              }
              _userList.addAll(list.data!);
              _userList.refresh();*/
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
          ? Mirrorfly.getUserList(page: pageNum, search: searchQuery.text.trim().toString(),
          metaDataUserList: Constants.metaDataUserList, //#metaData
          flyCallback: callback)
          : Mirrorfly.getRegisteredUsers(fetchFromServer: false,flyCallback: callback);
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
      toToast(getTranslated("noInternetConnection"));
    }
  }

  void onSearchPressed() {
    _isSearchVisible(false);
  }

  void filterRecentChat() {
    _recentChats.clear();
    var y = 0;
    for (var recentChat in _mainrecentChats) {
      if (recentChat.profileName != null &&
          recentChat.profileName!
                  .toLowerCase()
                  .contains(searchQuery.text.trim().toString().toLowerCase()) ==
              true) {
        if(y<3) {// only add 3 items in recent chat list
          _recentChats.add(recentChat);
          _recentChats.refresh();
          y++;
        }else{
          break;
        }
      }
    }
    filterGroupChat();
    filterUserList();
  }

  void filterGroupChat() {
    _groupList.clear();
    for (var group in _maingroupList) {
      if (group.name != null &&
          group.name!
                  .toLowerCase()
                  .contains(searchQuery.text.trim().toString().toLowerCase()) ==
              true) {
        // add only when group not available in recent chat list
        if(_recentChats.indexWhere((element) => element.jid == group.jid).isNegative) {
          _groupList.add(group);
          _groupList.refresh();
        }
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
          if (response.hasData) {
            var list = userListFromJson(response.data);
            if (list.data != null) {
              list.data?.forEach((user) {
                // add only when user not available in recent chat list
                if(_recentChats.indexWhere((element) => element.jid == user.jid).isNegative) {
                  if (!Constants.enableContactSync) {
                    _userList.add(user);
                  } else {
                    var filter = user.nickName.checkNull().toLowerCase().contains(searchQuery.text.trim().toString().toLowerCase());
                    if(filter) {
                      _userList.add(user);
                    }
                  }
                }
              });
              scrollable((_userList.length == 20 && !Constants.enableContactSync));
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
          ? Mirrorfly.getUserList(page: pageNum, search: searchQuery.text.trim().toString(),
          metaDataUserList: Constants.metaDataUserList, //#metaData
          flyCallback: callback)
          : Mirrorfly.getRegisteredUsers(fetchFromServer: false,flyCallback: callback);
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
      toToast(getTranslated("noInternetConnection"));
    }
  }

  bool isChecked(String jid) => selectedJids.contains(jid);

  Future<void> onItemSelect(String jid, String name,bool isBlocked,bool isGroup) async {
    if(isGroup.checkNull() && !availableFeatures.value.isGroupChatAvailable.checkNull()){
      DialogUtils.showFeatureUnavailable();
      return;
    }
    if(isGroup.checkNull() && !(await Mirrorfly.isMemberOfGroup(groupJid: jid, userJid: SessionManagement.getUserJID().checkNull())).checkNull()){
      toToast(getTranslated("youAreNoLonger"));
      return;
    }
    if(isBlocked.checkNull()){
      unBlock(jid,name);
    }else{
      onItemClicked(jid,name);
    }
  }

  unBlock(String jid, String name,){
    DialogUtils.showAlert(dialogStyle: AppStyleConfig.dialogStyle,message: getTranslated("unBlockUser").replaceFirst("%d", name), actions: [
      TextButton(style: AppStyleConfig.dialogStyle.buttonStyle,
          onPressed: () {
            NavUtils.back();
          },
          child: Text(getTranslated("no").toUpperCase(), )),
      TextButton(style: AppStyleConfig.dialogStyle.buttonStyle,
          onPressed: () async {
            AppUtils.isNetConnected().then((isConnected) {
              if (isConnected) {
                NavUtils.back();
                Mirrorfly.unblockUser(userJid: jid.checkNull(), flyCallBack: (FlyResponse response) {
                  if (response.isSuccess && response.hasData) {
                  toToast(getTranslated("hasUnBlocked").replaceFirst("%d", name));
                    userUpdatedHisProfile(jid);
                  }
                });
              } else {
              toToast(getTranslated("noInternetConnection"));
              }
            });
          },
          child: Text(getTranslated("yes").toUpperCase(), )),
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
        toToast(getTranslated("onlyForwardLimit"));
      }
    }

    _recentChats.refresh();
    _groupList.refresh();
    _userList.refresh();
  }

  final deBouncer = DeBouncer(milliseconds: 700);
  String lastInputValue = "";

  void onSearch(String search) {
    LogMessage.d("search", "onSearch");
    if (lastInputValue != searchQuery.text.toString().trim()) {
      lastInputValue = searchQuery.text.toString().trim();
      if (searchQuery.text.toString().trim().isNotEmpty) {
        debugPrint("cleared not");
        deBouncer.run(() {
          pageNum = 1;
          filterRecentChat();
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
    _recentChats(_mainrecentChats.take(3).toList());
    _groupList(_maingroupList);
    _userList(_mainuserList);
  }

  forwardMessages() {
    AppUtils.isNetConnected().then((isConnected) {
      if (isConnected) {
        Mirrorfly.isBusyStatusEnabled().then((isSuccess) async {
          if (!isSuccess){
            if (forwardMessageIds.isNotEmpty && selectedJids.isNotEmpty) {
          DialogUtils.showLoading(message: getTranslated("forwardMessage"),dialogStyle: AppStyleConfig.dialogStyle);
              // Future.delayed(const Duration(milliseconds: 1000), () async {
                await Mirrorfly.forwardMessagesToMultipleUsers(
                    messageIds: forwardMessageIds, userList: selectedJids, flyCallBack: (FlyResponse response) {
                  // debugPrint("to chat profile ==> ${selectedUsersList[0].toJson().toString()}");
                  updateLastMessage(selectedJids);
                  DialogUtils.hideLoading();
                  NavUtils.back();
                });
              // });
            }
          }else{
            //show busy status popup
            // var messageObject = MessageObject(toJid: profile.jid.toString(),replyMessageId: (isReplying.value) ? replyChatMessage.messageId : "", messageType: Constants.mText,textMessage: messageController.text);
            // showBusyStatusAlert(disableBusyChatAndSend());
          }
        });
      } else {
      toToast(getTranslated("noInternetConnection"));
      }
    });
  }

  void updateLastMessage(List<String> chatJid){
    //below method is used when message is not sent and onMessageStatusUpdate listener will not trigger till the message status was updated so notify the ui in dashboard
    for (var element in chatJid) {
      Get.find<MainController>().onUpdateLastMessageUI(element);
    }
  }

  Future<String> getParticipantsNameAsCsv(String jid) async {
    var groupParticipantsName = "";
    await Mirrorfly.getGroupMembersList(jid: jid, fetchFromServer: false, flyCallBack: (FlyResponse response) {
      if (response.isSuccess && response.hasData) {
        var str = <String>[];
        var groupsMembersProfileList = memberFromJson(response.data);
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
