import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:flysdk/flysdk.dart';
import 'package:mirror_fly_demo/app/data/session_management.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../common/de_bouncer.dart';
import '../../../data/apputils.dart';
import '../../../data/permissions.dart';
import '../../../routes/app_pages.dart';

class ContactController extends FullLifeCycleController
    with FullLifeCycleMixin {
  ScrollController scrollController = ScrollController();
  var pageNum = 1;
  var isPageLoading = false.obs;
  var scrollable = SessionManagement.isTrailLicence().obs;
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
  Future<void> onInit() async {
    super.onInit();
    isForward(Get.arguments["forward"]);
    if (isForward.value) {
      isCreateGroup(false);
      forwardMessageIds.addAll(Get.arguments["messageIds"]);
    } else {
      isCreateGroup(Get.arguments["group"]);
      groupJid(Get.arguments["groupJid"]);
    }
    scrollController.addListener(_scrollListener);
    //searchQuery.addListener(_searchListener);
    if (await AppUtils.isNetConnected()) {
      isPageLoading(true);
      fetchUsers(false);
    } else {
      toToast(Constants.noInternetConnection);
    }
    //FlyChat.syncContacts(true);
    //FlyChat.getRegisteredUsers(true).then((value) => mirrorFlyLog("registeredUsers", value.toString()));
  }

  void userUpdatedHisProfile(String jid) {
    updateProfile(jid);
  }

  Future<void> updateProfile(String jid) async {
    if (jid.isNotEmpty) {
      var userListIndex = usersList.indexWhere((element) => element.jid == jid);
      var mainListIndex =
          mainUsersList.indexWhere((element) => element.jid == jid);
      getProfileDetails(jid).then((value) {
        if (!userListIndex.isNegative) {
          usersList[userListIndex] = value;
        }
        if (!mainListIndex.isNegative) {
          mainUsersList[mainListIndex] = value;
        }
      });
    }
  }

  //Add participants
  final _search = false.obs;

  set search(bool value) => _search.value = value;

  bool get search => _search.value;

  void onSearchPressed() {
    if (_search.value) {
      _search(false);
    } else {
      _search(true);
    }
  }

  bool get isCreateVisible => isCreateGroup.value;

  bool get isSearchVisible => !_search.value;

  bool get isClearVisible =>
      _search.value && !isForward.value && isCreateGroup.value;

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

  @override
  void onClose() {
    super.onClose();
    searchQuery.dispose();
  }

  final deBouncer = DeBouncer(milliseconds: 700);
  String lastInputValue = "";

  searchListener(String text) async {
    debugPrint("searching .. ");
    if (lastInputValue != searchQuery.text.trim()) {
      lastInputValue = searchQuery.text.trim();
      if (searchQuery.text.trim().isEmpty) {
        _searchText = "";
        pageNum = 1;
      } else {
        isPageLoading(true);
        _searchText = searchQuery.text.trim();
        pageNum = 1;
      }
      if (SessionManagement.isTrailLicence()) {
        deBouncer.run(() {
          fetchUsers(true);
        });
      } else {
        fetchUsers(true);
      }
    }
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
    scrollable(SessionManagement.isTrailLicence());
  }

  fetchUsers(bool fromSearch) async {
    if(!SessionManagement.isTrailLicence()){
      var granted = await Permission.contacts.isGranted;
      if(!granted){
        isPageLoading(false);
        return;
      }
    }
    if (await AppUtils.isNetConnected()) {
      var future = (SessionManagement.isTrailLicence())
          ? FlyChat.getUserList(pageNum, _searchText)
          : FlyChat.getRegisteredUsers(true);
      future.then((data) async {
        //FlyChat.getUserList(pageNum, _searchText).then((data) async {
        mirrorFlyLog("userlist", data);
        var item = userListFromJson(data);
        var list = <Profile>[];

        if (groupJid.value.checkNull().isNotEmpty) {
          await Future.forEach(item.data!, (it) async {
            await FlyChat.isMemberOfGroup(
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
            if (SessionManagement.isTrailLicence()) {
              usersList(list);
              pageNum = pageNum + 1;
              scrollable.value = list.length == 20;
            } else {
              var userlist = mainUsersList.where((p0) => getName(p0)
                  .toString()
                  .toLowerCase()
                  .contains(_searchText.trim().toLowerCase()));
              usersList(userlist.toList());
              scrollable(false);
              /*for (var userDetail in mainUsersList) {
                  if (userDetail.name.toString().toLowerCase().contains(_searchText.trim().toLowerCase())) {
                    usersList.add(userDetail);
                  }
                }*/
            }
          } else {
            if (SessionManagement.isTrailLicence()) {
              usersList.addAll(list);
              pageNum = pageNum + 1;
              scrollable.value = list.length == 20;
            } else {
              usersList(list);
              scrollable(false);
            }
          }
          isPageLoading.value = false;
          usersList.refresh();
        } else {
          list.addAll(item.data!);
          if (!SessionManagement.isTrailLicence() && fromSearch) {
            var userlist = mainUsersList.where((p0) => getName(p0)
                .toString()
                .toLowerCase()
                .contains(_searchText.trim().toLowerCase()));
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
            if (SessionManagement.isTrailLicence()) {
              usersList(list);
              pageNum = pageNum + 1;
              scrollable.value = list.length == 20;
            } else {
              var userlist = mainUsersList.where((p0) => getName(p0)
                  .toString()
                  .toLowerCase()
                  .contains(_searchText.trim().toLowerCase()));
              usersList(userlist.toList());
              scrollable(false);
              /*for (var userDetail in mainUsersList) {
                  if (userDetail.name.toString().toLowerCase().contains(_searchText.trim().toLowerCase())) {
                    usersList.add(userDetail);
                  }
                }*/
            }
          } else {
            if (SessionManagement.isTrailLicence()) {
              usersList.addAll(list);
              pageNum = pageNum + 1;
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
      });
    } else {
      toToast(Constants.noInternetConnection);
    }
  }

  Future<List<Profile>> removeGroupMembers(List<Profile> items) async {
    var list = <Profile>[];
    for (var it in items) {
      var value = await FlyChat.isMemberOfGroup(
          groupJid.value.checkNull(), it.jid.checkNull());
      mirrorFlyLog("item", value.toString());
      if (value == null || !value) {
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

  forwardMessages() async {
    if (await AppUtils.isNetConnected()) {
      FlyChat.forwardMessagesToMultipleUsers(
              forwardMessageIds, selectedUsersJIDList)
          .then((value) {
        debugPrint(
            "to chat profile ==> ${selectedUsersList[0].toJson().toString()}");
        Get.back(result: selectedUsersList[0]);
      });
    } else {
      toToast(Constants.noInternetConnection);
    }
  }

  onListItemPressed(Profile item) {
    if (isForward.value || isCreateGroup.value) {
      if (item.isBlocked.checkNull()) {
        unBlock(item);
      } else {
        contactSelected(item);
      }
    } else {
      mirrorFlyLog("Contact Profile", item.toJson().toString());
      Get.offNamed(Routes.chat, arguments: item);
    }
  }

  unBlock(Profile item) {
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
              FlyChat.unblockUser(item.jid.checkNull()).then((value) {
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

  backToCreateGroup() async {
    if (await AppUtils.isNetConnected()) {
      /*if (selectedUsersJIDList.length >= Constants.minGroupMembers) {
        Get.back(result: selectedUsersJIDList);
      } else {
        toToast("Add at least two contacts");
      }*/
      if (groupJid.value.isEmpty) {
        if (selectedUsersJIDList.length >= Constants.minGroupMembers) {
          Get.back(result: selectedUsersJIDList);
        } else {
          toToast("Add at least two contacts");
        }
      } else {
        if (selectedUsersJIDList.isNotEmpty) {
          Get.back(result: selectedUsersJIDList);
        } else {
          toToast("Add at least two contacts");
        }
      }
    } else {
      toToast(Constants.noInternetConnection);
    }
    /*if(groupJid.value.isEmpty) {
      if (selectedUsersJIDList.length >= Constants.minGroupMembers) {
        Get.back(result: selectedUsersJIDList);
      } else {
        toToast("Add at least two contacts");
      }
    }else{
      if (selectedUsersJIDList.length >= Constants.minGroupMembers) {
        Get.back(result: selectedUsersJIDList);
      } else {
        toToast("Add at least two contacts");
      }
    }*/
  }

  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  var progressSpinner = false.obs;

  refreshContacts() async {
    mirrorFlyLog('Contact Sync', "[Contact Sync] refreshContacts()");
    if (await AppUtils.isNetConnected()) {
      if(!await FlyChat.contactSyncStateValue()) {
        var contactPermissionHandle = await AppPermission.checkPermission(
            Permission.contacts, contactPermission,
            Constants.contactSyncPermission);
        if (contactPermissionHandle) {
          progressSpinner(true);
            FlyChat.syncContacts(!SessionManagement.isInitialContactSyncDone())
                .then((value) {
              progressSpinner(false);
              // viewModel.onContactSyncFinished(success)
              // viewModel.isContactSyncSuccess.value = true
              _first = true;
              fetchUsers(_searchText.isNotEmpty);
            });
        } /* else {
      MediaPermissions.requestContactsReadPermission(
      this,
      permissionAlertDialog,
      contactPermissionLauncher,
      null)
      val email = Utils.returnEmptyStringIfNull(SharedPreferenceManager.getString(Constants.EMAIL))
      if (ChatUtils.isContusUser(email))
      EmailContactSyncService.start()
      }*/
      } else {
        progressSpinner(true);
        mirrorFlyLog('Contact Sync',
            "[Contact Sync] Contact syncing is already in progress");
      }
    } else {
      toToast(Constants.noInternetConnection);
      // viewModel.onContactSyncFinished(false);
    }
  }

  void onContactSyncComplete(bool result) {
    progressSpinner(false);
    _first = true;
    fetchUsers(_searchText.isNotEmpty);
  }

  @override
  void onDetached() {}

  @override
  void onInactive() {}

  @override
  void onPaused() {}

  @override
  Future<void> onResumed() async {
    if (!SessionManagement.isTrailLicence()) {
      var status = await Permission.contacts.isGranted;
      if(status) {
        refreshContacts();
      }else{
        usersList.clear();
        usersList.refresh();
      }
    }
  }
}
