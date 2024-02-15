import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/call_modules/outgoing_call/call_controller.dart';
import 'package:mirror_fly_demo/app/common/main_controller.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/common/extensions.dart';

import 'package:mirrorfly_plugin/mirrorflychat.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../common/constants.dart';
import '../../common/de_bouncer.dart';
import '../../data/apputils.dart';
import '../../data/session_management.dart';

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
        toToast(Constants.noInternetConnection);
      }
    } else {
      getGroupMembers();
    }
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
    Helper.showAlert(message: "Unblock ${getName(item)}?", actions: [
      TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text("NO")),
      TextButton(
          onPressed: () async {
            if (await AppUtils.isNetConnected()) {
              Get.back();
              Helper.progressLoading();
              Mirrorfly.unblockUser(item.jid.checkNull()).then((value) {
                Helper.hideLoading();
                if (value != null && value) {
                  toToast("${getName(item)} has been Unblocked");
                  userUpdatedHisProfile(item.jid.checkNull());
                }
              }).catchError((error) {
                Helper.hideLoading();
                debugPrint(error);
              });
            } else {
              toToast(Constants.noInternetConnection);
            }
          },
          child: const Text("YES")),
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
            toToast(Constants.callMembersLimit6.replaceFirst("%d", (groupCallMembersCount.value).toString()));
          }
        } else {
          toToast(Constants.callMembersLimit.replaceFirst("%d", getMaxCallUsersCount.toString()));
        }
        //item.isSelected = true;
      }
      usersList.refresh();
    } else {
      toToast("User Already Added");
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
        mirrorFlyLog('value.isBlockedMe', value.isBlockedMe.toString());
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
      Helper.showFeatureUnavailable();
      return;
    }
    if (!(await AppUtils.isNetConnected())) {
      toToast(Constants.noInternetConnection);
      return;
    }
    if (callList.length != getMaxCallUsersCount) {
      if (await AppUtils.isNetConnected()) {
        Mirrorfly.inviteUsersToOngoingCall(jidList: selectedUsersJIDList);
        Get.back();
      } else {
        toToast(Constants.noInternetConnection);
      }
    } else {
      toToast(Constants.callMembersLimit.replaceFirst("%d", getMaxCallUsersCount.toString()));
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
        if (response.isSuccess && response.data.isNotEmpty) {
          var data = response.data;
          mirrorFlyLog("userlist", data);
          var item = userListFromJson(data);
          var items = getFilteredList(callConnectedUserList, item.data);
          var list = <ProfileDetails>[];

          if (groupJid.value.checkNull().isNotEmpty) {
            await Future.forEach(items, (it) async {
              await Mirrorfly.isMemberOfGroup(groupJid.value.checkNull(), it.jid.checkNull()).then((value) {
                mirrorFlyLog("item", value.toString());
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
          ? Mirrorfly.getUserList(pageNum, _searchText, flyCallback: callback)
          : Mirrorfly.getRegisteredUsers(false, flyCallback: callback);
      /*future.then((data) async {
        //Mirrorfly.getUserList(pageNum, _searchText).then((data) async {
        mirrorFlyLog("userlist", data);
        var item = userListFromJson(data);
        var items = getFilteredList(callConnectedUserList,item.data);
        var list = <ProfileDetails>[];

        if (groupJid.value.checkNull().isNotEmpty) {
          await Future.forEach(items, (it) async {
            await Mirrorfly.isMemberOfGroup(
                groupJid.value.checkNull(), it.jid.checkNull())
                .then((value) {
              mirrorFlyLog("item", value.toString());
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
      toToast(Constants.noInternetConnection);
    }
  }

  void getGroupMembers() {
    if (groupId.isNotEmpty) {
      Mirrorfly.getGroupMembersList(groupId.value.checkNull(), null).then((value) {
        mirrorFlyLog("getGroupMembersList", value);
        if (value.isNotEmpty) {
          var list = profileFromJson(value);
          var callConnectedUserList = List<String>.from(callList.map((element) => element.userJid));
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
