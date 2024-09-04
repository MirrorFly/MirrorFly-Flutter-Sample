import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../call_modules/outgoing_call/call_controller.dart';
import '../../common/main_controller.dart';
import '../../data/helper.dart';
import '../../extensions/extensions.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../app_style_config.dart';
import '../../common/app_localizations.dart';
import '../../common/constants.dart';
import '../../common/de_bouncer.dart';
import '../../data/session_management.dart';
import '../../data/utils.dart';

class AddParticipantsController extends GetxController with GetTickerProviderStateMixin {
  var callList = Get.find<CallController>().callList; //List<CallUserList>.empty(growable: true).obs;
  var groupId = Get.find<CallController>().groupId;

  ScrollController scrollController = ScrollController();
  var pageNum = 1;
  var isPageLoading = false.obs;
  var scrollable = (!Constants.enableContactSync).obs;
  var usersList = <ProfileDetails>[].obs;
  var mainUsersList = List<ProfileDetails>.empty(growable: true).obs;
  var selectedUsersList = List<ProfileDetails>.empty(growable: true).obs;
  var selectedUsersJIDList = List<String>.empty(growable: true).obs;

  var currentTab = 0.obs;
  bool get isCheckBoxVisible => true;
  TabController? tabController;
  var getMaxCallUsersCount = 8;
  @override
  Future<void> onInit() async {
    super.onInit();
    getCallLink();
    groupId(await Mirrorfly.getCallGroupJid());
    tabController = TabController(length: 2, vsync: this);
    getMaxCallUsersCount = (await Mirrorfly.getMaxCallUsersCount()) ?? 8;
    // callList = Get.find<CallController>().callList;
    scrollController.addListener(_scrollListener);
    tabController?.animation?.addListener(() {
      LogMessage.d("DefaultTabController", "${tabController?.index}");

      // Current animation value. It ranges from 0 to (tabsCount - 1)
      final animationValue = tabController?.animation!.value;
      LogMessage.d("animationValue", "$animationValue");
      // Simple rounding gives us understanding of what tab is showing
      final currentTabIndex = animationValue?.round();
      LogMessage.d("currentTabIndex", "$currentTabIndex");
      currentTab(currentTabIndex);
      if (currentTabIndex == 0) {
        getBackFromSearch();
      }
      // currentOffset equals 0 when tabs are not swiped
      // currentOffset ranges from -0.5 to 0.5
      // final currentOffset = currentTabIndex! - animationValue!;
      // for (int i = 0; i < tabsCount; i++) {
      //   if (i == currentTabIndex) {
      // //     // For current tab bringing currentOffset to range from 0.0 to 1.0
      //     tabScales[i] = (0.5 - currentOffset.abs()) / 0.5;
      //   } else {
      // //     // For other tabs setting scale to 0.0
      //     tabScales[i] = 0.0;
      //   }
      // }
    });
    if (groupId.isEmpty) {
      if (await AppUtils.isNetConnected() || Constants.enableContactSync) {
        isPageLoading(true);
        fetchUsers(false);
      } else {
        toToast(getTranslated("noInternetConnection"));
      }
    } else {
      getGroupMembers();
    }
  }

  ///get ongoing call link
  var meetLink = "".obs;
  void getCallLink(){
    Mirrorfly.getCallLink().then((value){
      meetLink(value);
    });
  }

  void onSearchPressed() {
    if (isSearching.value) {
      isSearching(false);
    } else {
      isSearching(true);
    }
  }

  var selected = false.obs;
  var isSearching = false.obs;
  var searchFocusNode = FocusNode();
  var searchQuery = TextEditingController();
  final deBouncer = DeBouncer(milliseconds: 700);
  RxString lastInputValue = "".obs;

  searchListener(String text) async {
    debugPrint("searching .. ");
    if (lastInputValue.value != searchQuery.text.trim()) {
      lastInputValue(searchQuery.text.trim());
      if (searchQuery.text.trim().isEmpty) {
        _searchText = "";
        pageNum = 1;
      } else {
        isPageLoading(true);
        _searchText = searchQuery.text.trim();
        pageNum = 1;
      }
      if (groupId.isEmpty) {
        if (!Constants.enableContactSync) {
          deBouncer.run(() {
            fetchUsers(true);
          });
        } else {
          fetchUsers(true);
        }
      } else {
        filterGroupMembers();
      }
    }
  }

  void filterGroupMembers() {
    var filteredList =
        mainUsersList.where((item) => item.getName().toLowerCase().contains(_searchText.trim())).toList();
    usersList(filteredList);
  }

  clearSearch() {
    searchQuery.clear();
    _searchText = "";
    lastInputValue('');
    pageNum = 1;
    usersList(mainUsersList);
    scrollable(!Constants.enableContactSync);
  }

  getBackFromSearch() {
    if (isSearching.value) {
      isSearching(false);
      searchQuery.clear();
      _searchText = "";
      lastInputValue('');
      //if(!_IsSearching){
      //isPageLoading.value=true;
      pageNum = 1;
      //fetchUsers(true);
      //}
      usersList(mainUsersList);
      scrollable(!Constants.enableContactSync);
      selectedUsersJIDList.clear();
      debugPrint("Clearing the selectedUsersList");
      selectedUsersList.clear();
      groupCallMembersCount(0);
    }
  }

  _scrollListener() {
    if (scrollController.hasClients) {
      if (scrollController.position.extentAfter <= 0 && isPageLoading.value == false) {
        if (scrollable.value) {
          //isPageLoading.value = true;
          LogMessage.d("usersList.length ${usersList.length} ~/ 20", (usersList.length ~/ 20));
          pageNum = (usersList.length ~/ 20) + 1;
          fetchUsers(false);
        }
      }
    }
  }

  onListItemPressed(ProfileDetails item) {
    if (item.isBlocked.checkNull()) {
      unBlock(item);
    } else {
      contactSelected(item);
    }
  }

  unBlock(ProfileDetails item) {
    DialogUtils.showAlert(dialogStyle: AppStyleConfig.dialogStyle,message: getTranslated("unBlockUser").replaceFirst("%d", getName(item)), actions: [
      TextButton(style: AppStyleConfig.dialogStyle.buttonStyle,
          onPressed: () {
            NavUtils.back();
          },
          child: Text(getTranslated("no").toUpperCase(), )),
      TextButton(style: AppStyleConfig.dialogStyle.buttonStyle,
          onPressed: () async {
            if (await AppUtils.isNetConnected()) {
              NavUtils.back();
              DialogUtils.progressLoading();
              Mirrorfly.unblockUser(userJid: item.jid.checkNull(), flyCallBack: (FlyResponse response) {
                DialogUtils.hideLoading();
                if (response.isSuccess && response.hasData) {
                  toToast(getTranslated("hasUnBlocked").replaceFirst("%d", getName(item)));
                  userUpdatedHisProfile(item.jid.checkNull());
                }
              });
            } else {
              toToast(getTranslated("noInternetConnection"));
            }
          },
          child: Text(getTranslated("yes").toUpperCase())),
    ]);
  }

  contactSelected(ProfileDetails item) {
    if (callList.indexWhere((element) => element.userJid.toString() == item.jid.toString()).isNegative) {
      if (selectedUsersJIDList.contains(item.jid)) {
        selectedUsersList.removeWhere((user) => user.jid == item.jid);
        selectedUsersJIDList.remove(item.jid);
        //item.isSelected = false;
        groupCallMembersCount(groupCallMembersCount.value - 1);
      } else {
        if (callList.length != getMaxCallUsersCount) {
          if (getMaxCallUsersCount > (selectedUsersList.length + callList.length)) {
            selectedUsersList.add(item);
            selectedUsersJIDList.add(item.jid!);
            groupCallMembersCount(groupCallMembersCount.value + 1);
          } else {
            toToast(getTranslated("youCanSelectForCall").replaceFirst("%d", (groupCallMembersCount.value).toString()));
          }
        } else {
          toToast(getTranslated("callMembersLimit").replaceFirst("%d", getMaxCallUsersCount.toString()));
        }
        //item.isSelected = true;
      }
      usersList.refresh();
    } else {
      toToast(getTranslated("userAlreadyAddedInCall"));
    }
  }

  void onContactSyncComplete(bool result) {
    // progressSpinner(false);
    _first = true;
    fetchUsers(_searchText.isNotEmpty, server: result);
  }

  void userDeletedHisProfile(String jid) {
    userUpdatedHisProfile(jid);
  }

  void userBlockedMe(String jid) {
    userUpdatedHisProfile(jid);
  }

  void unblockedThisUser(String jid) {
    userUpdatedHisProfile(jid);
  }

  void userUpdatedHisProfile(String jid) {
    updateProfile(jid);
  }

  Future<void> updateProfile(String jid) async {
    if (jid.isNotEmpty) {
      getProfileDetails(jid).then((value) {
        var userListIndex = usersList.indexWhere((element) => element.jid == jid);
        var mainListIndex = mainUsersList.indexWhere((element) => element.jid == jid);
        LogMessage.d('value.isBlockedMe', value.isBlockedMe.toString());
        if (!userListIndex.isNegative) {
          usersList[userListIndex] = value;
          usersList.refresh();
        }
        if (!mainListIndex.isNegative) {
          mainUsersList[mainListIndex] = value;
          mainUsersList.refresh();
        }
      });
    }
  }

  void onUserInvite(String callMode, String userJid, String callType) {
    removeSelectedPartcipants();
  }

  void removeSelectedPartcipants() {
    Mirrorfly.getInvitedUsersList().then((value) async {
      LogMessage.d("callController", " getInvitedUsersList $value");
      if (value.isNotEmpty) {
        var userJids = value;
        for (var jid in userJids) {
          selectedUsersList.removeWhere((user) => user.jid == jid);
          selectedUsersJIDList.remove(jid);
        }
        usersList.refresh();
        groupCallMembersCount(selectedUsersJIDList.length);
      }
    });
  }

  var groupCallMembersCount = 0.obs;
  var callType = CallType.audio.obs;
  makeCall() async {
    if (selectedUsersJIDList.isEmpty) {
      return;
    }
    if (!availableFeatures.value.isGroupCallAvailable.checkNull()) {
      DialogUtils.showFeatureUnavailable();
      return;
    }
    if (!(await AppUtils.isNetConnected())) {
      toToast(getTranslated("noInternetConnection"));
      return;
    }
    if (callList.length != getMaxCallUsersCount) {
      Mirrorfly.inviteUsersToOngoingCall(jidList: selectedUsersJIDList,flyCallback: (FlyResponse response){
        LogMessage.d("inviteUsersToOngoingCall", response.toString());
        if(response.isSuccess){
          NavUtils.back();
        }else{
          toToast(getErrorDetails(response));
        }
      });
    } else {
      toToast(getTranslated("callMembersLimit").replaceFirst("%d", getMaxCallUsersCount.toString()));
    }
  }

  var _searchText = "";
  var _first = true;
  var groupJid = "".obs;
  fetchUsers(bool fromSearch, {bool server = false}) async {
    if (Constants.enableContactSync) {
      var granted = await Permission.contacts.isGranted;
      if (!granted) {
        isPageLoading(false);
        return;
      }
    }
    var callConnectedUserList = <String>[];
    for (var value1 in callList) {
      callConnectedUserList.add(value1.userJid?.value ?? '');
    }
    if (await AppUtils.isNetConnected() || Constants.enableContactSync) {
      callback(FlyResponse response) async {
        if (response.isSuccess && response.hasData) {
          var data = response.data;
          LogMessage.d("userlist", data);
          var item = userListFromJson(data);
          var items = getFilteredList(callConnectedUserList, item.data);
          var list = <ProfileDetails>[];

          if (groupJid.value.checkNull().isNotEmpty) {
            await Future.forEach(items, (it) async {
              await Mirrorfly.isMemberOfGroup(groupJid: groupJid.value.checkNull(), userJid: it.jid.checkNull()).then((value) {
                LogMessage.d("item", value.toString());
                if (value == null || !value) {
                  list.add(it);
                }
              });
            });
            if (_first) {
              _first = false;
              mainUsersList(list);
            }
            if (fromSearch) {
              if (!Constants.enableContactSync) {
                usersList(list);
                // if(usersList.length==20) pageNum += 1;
                scrollable.value = list.length == 20;
              } else {
                var userlist = mainUsersList
                    .where((p0) => getName(p0).toString().toLowerCase().contains(_searchText.trim().toLowerCase()));
                usersList(userlist.toList());
                scrollable(false);
                /*for (var userDetail in mainUsersList) {
                  if (userDetail.name.toString().toLowerCase().contains(_searchText.trim().toLowerCase())) {
                    usersList.add(userDetail);
                  }
                }*/
              }
            } else {
              if (!Constants.enableContactSync) {
                usersList.addAll(list);
                // if(usersList.length==20) pageNum += 1;
                scrollable.value = list.length == 20;
              } else {
                usersList(list);
                scrollable(false);
              }
            }
            isPageLoading.value = false;
            usersList.refresh();
          } else {
            list.addAll(items);
            if (Constants.enableContactSync && fromSearch) {
              var userlist = mainUsersList
                  .where((p0) => getName(p0).toString().toLowerCase().contains(_searchText.trim().toLowerCase()));
              usersList(userlist.toList());
              /*for (var userDetail in mainUsersList) {
              if (userDetail.name.toString().toLowerCase().contains(_searchText.trim().toLowerCase())) {
                usersList.add(userDetail);
              }
            }*/
            }
            if (_first) {
              _first = false;
              mainUsersList(list);
            }
            if (fromSearch) {
              if (!Constants.enableContactSync) {
                usersList(list);
                // if(usersList.length==20) pageNum += 1;
                scrollable.value = list.length == 20;
              } else {
                var userlist = mainUsersList
                    .where((p0) => getName(p0).toString().toLowerCase().contains(_searchText.trim().toLowerCase()));
                usersList(userlist.toList());
                scrollable(false);
                /*for (var userDetail in mainUsersList) {
                  if (userDetail.name.toString().toLowerCase().contains(_searchText.trim().toLowerCase())) {
                    usersList.add(userDetail);
                  }
                }*/
              }
            } else {
              if (!Constants.enableContactSync) {
                usersList.addAll(list);
                // if(usersList.length==20) pageNum += 1;
                scrollable.value = list.length == 20;
              } else {
                usersList(list);
                scrollable(false);
              }
            }
            isPageLoading.value = false;
            usersList.refresh();
          }
        } else {
          toToast(response.exception!.message.toString());
        }
      }

      (!Constants.enableContactSync)
          ? Mirrorfly.getUserList(page: pageNum, search: _searchText,
          metaDataUserList: Constants.metaDataUserList, //#metaData
          flyCallback: callback)
          : Mirrorfly.getRegisteredUsers(fetchFromServer: false, flyCallback: callback);
      /*future.then((data) async {
        //Mirrorfly.getUserList(pageNum, _searchText).then((data) async {
        LogMessage.d("userlist", data);
        var item = userListFromJson(data);
        var items = getFilteredList(callConnectedUserList,item.data);
        var list = <ProfileDetails>[];

        if (groupJid.value.checkNull().isNotEmpty) {
          await Future.forEach(items, (it) async {
            await Mirrorfly.isMemberOfGroup(
                groupJid.value.checkNull(), it.jid.checkNull())
                .then((value) {
              LogMessage.d("item", value.toString());
              if (value == null || !value) {
                list.add(it);
              }
            });
          });
          if (_first) {
            _first = false;
            mainUsersList(list);
          }
          if (fromSearch) {
            if (!Constants.enableContactSync) {
              usersList(list);
              // if(usersList.length==20) pageNum += 1;
              scrollable.value = list.length == 20;
            } else {
              var userlist = mainUsersList.where((p0) => getName(p0)
                  .toString()
                  .toLowerCase()
                  .contains(_searchText.trim().toLowerCase()));
              usersList(userlist.toList());
              scrollable(false);
              */ /*for (var userDetail in mainUsersList) {
                  if (userDetail.name.toString().toLowerCase().contains(_searchText.trim().toLowerCase())) {
                    usersList.add(userDetail);
                  }
                }*/ /*
            }
          } else {
            if (!Constants.enableContactSync) {
              usersList.addAll(list);
              // if(usersList.length==20) pageNum += 1;
              scrollable.value = list.length == 20;
            } else {
              usersList(list);
              scrollable(false);
            }
          }
          isPageLoading.value = false;
          usersList.refresh();
        } else {
          list.addAll(items);
          if (Constants.enableContactSync && fromSearch) {
            var userlist = mainUsersList.where((p0) => getName(p0)
                .toString()
                .toLowerCase()
                .contains(_searchText.trim().toLowerCase()));
            usersList(userlist.toList());
            */ /*for (var userDetail in mainUsersList) {
              if (userDetail.name.toString().toLowerCase().contains(_searchText.trim().toLowerCase())) {
                usersList.add(userDetail);
              }
            }*/ /*
          }
          if (_first) {
            _first = false;
            mainUsersList(list);
          }
          if (fromSearch) {
            if (!Constants.enableContactSync) {
              usersList(list);
              // if(usersList.length==20) pageNum += 1;
              scrollable.value = list.length == 20;
            } else {
              var userlist = mainUsersList.where((p0) => getName(p0)
                  .toString()
                  .toLowerCase()
                  .contains(_searchText.trim().toLowerCase()));
              usersList(userlist.toList());
              scrollable(false);
              */ /*for (var userDetail in mainUsersList) {
                  if (userDetail.name.toString().toLowerCase().contains(_searchText.trim().toLowerCase())) {
                    usersList.add(userDetail);
                  }
                }*/ /*
            }
          } else {
            if (!Constants.enableContactSync) {
              usersList.addAll(list);
              // if(usersList.length==20) pageNum += 1;
              scrollable.value = list.length == 20;
            } else {
              usersList(list);
              scrollable(false);
            }
          }
          isPageLoading.value = false;
          usersList.refresh();
        }
      }).catchError((error) {
        debugPrint("Get User list error--> $error");
        toToast(error.toString());
      });*/
    } else {
      toToast(getTranslated("noInternetConnection"));
    }
  }

  void getGroupMembers() {
    if (groupId.isNotEmpty) {
      Mirrorfly.getGroupMembersList(jid: groupId.value.checkNull(), flyCallBack: (FlyResponse response) {
        LogMessage.d("getGroupMembersList", response.toString());
        if (response.isSuccess && response.hasData) {
          var list = profileFromJson(response.data);
          var callConnectedUserList = List<String>.from(callList.map((element) => element.userJid?.value));
          var filteredList = getFilteredList(callConnectedUserList, list);
          mainUsersList(filteredList);
          usersList(filteredList);
        }
      });
    }
  }

  List<ProfileDetails> getFilteredList(List<String> callConnectedUserList, List<ProfileDetails>? usersList) {
    return (usersList
            ?.where((element) =>
                !callConnectedUserList.contains(element.jid) && element.jid != SessionManagement.getUserJID())
            .toList()) ??
        [];
  }

  var availableFeatures = Get.find<MainController>().availableFeature;
  void onAvailableFeaturesUpdated(AvailableFeatures features) {
    LogMessage.d("GroupParticipants", "onAvailableFeaturesUpdated ${features.toJson()}");
    availableFeatures(features);
  }
}
