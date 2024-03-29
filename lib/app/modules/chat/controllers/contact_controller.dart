import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/common/main_controller.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/common/extensions.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';
import 'package:mirror_fly_demo/app/data/session_management.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../common/de_bouncer.dart';
import '../../../data/apputils.dart';
import '../../../data/permissions.dart';
import '../../../routes/app_pages.dart';

class ContactController extends FullLifeCycleController with FullLifeCycleMixin {
  ScrollController scrollController = ScrollController();
  var pageNum = 1;
  var isPageLoading = false.obs;
  var scrollable = (!Constants.enableContactSync).obs;
  var usersList = <ProfileDetails>[].obs;
  var mainUsersList = List<ProfileDetails>.empty(growable: true).obs;
  var selectedUsersList = List<ProfileDetails>.empty(growable: true).obs;
  var selectedUsersJIDList = List<String>.empty(growable: true).obs;
  var forwardMessageIds = List<String>.empty(growable: true).obs;
  final TextEditingController searchQuery = TextEditingController();
  var _searchText = "";
  var _first = true;

  var isForward = false.obs;
  var isMakeCall = false.obs;
  var callType = "".obs;
  var isCreateGroup = false.obs;
  var groupJid = "".obs;

  var topicId = "";
  var getMaxCallUsersCount = 8;

  @override
  Future<void> onInit() async {
    super.onInit();
    getMaxCallUsersCount = (await Mirrorfly.getMaxCallUsersCount()) ?? 8;
    debugPrint("Get.parameters['topicId'] ${Get.parameters['topicId']}");
    if (Get.parameters['topicId'] != null) {
      topicId = Get.parameters['topicId'].toString();
    }
    isMakeCall(Get.arguments["is_make_call"]);
    callType(Get.arguments["call_type"]);
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
    if (await AppUtils.isNetConnected() || Constants.enableContactSync) {
      isPageLoading(true);
      fetchUsers(false);
    } else {
      toToast(Constants.noInternetConnection);
    }
    //Mirrorfly.syncContacts(true);
    //Mirrorfly.getRegisteredUsers(true).then((value) => mirrorFlyLog("registeredUsers", value.toString()));
    progressSpinner(Constants.enableContactSync && await Mirrorfly.contactSyncStateValue());
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
      _search.value && lastInputValue.value.isNotEmpty /*&& !isForward.value && isCreateGroup.value*/;

  bool get isMenuVisible => !_search.value && !isForward.value;

  bool get isCheckBoxVisible => isCreateGroup.value || isForward.value || isMakeCall.value;

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

  @override
  void onClose() {
    super.onClose();
    searchQuery.dispose();
  }

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
      if (!Constants.enableContactSync) {
        deBouncer.run(() {
          fetchUsers(true);
        });
      } else {
        fetchUsers(true);
      }
    }
  }

  clearSearch() {
    searchQuery.clear();
    _searchText = "";
    lastInputValue('');
    pageNum = 1;
    usersList(mainUsersList);
    scrollable(!Constants.enableContactSync);
  }

  backFromSearch() {
    _search.value = false;
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
  }

  fetchUsers(bool fromSearch, {bool server = false}) async {
    if (Constants.enableContactSync) {
      var granted = await Permission.contacts.isGranted;
      if (!granted) {
        isPageLoading(false);
        return;
      }
    }
    if (await AppUtils.isNetConnected() || Constants.enableContactSync) {
      callback(FlyResponse response) async {
        if (response.isSuccess && response.hasData) {
          var data = response.data;
          mirrorFlyLog("userlist", data);
          var item = userListFromJson(data);
          var list = <ProfileDetails>[];

          if (groupJid.value.checkNull().isNotEmpty) {
            await Future.forEach(item.data!, (it) async {
              await Mirrorfly.isMemberOfGroup(groupJid: groupJid.value.checkNull(), userJid: it.jid.checkNull()).then((value) {
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
            list.addAll(item.data!);
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
          ? Mirrorfly.getUserList(page: pageNum, search: _searchText, flyCallback: callback)
          : Mirrorfly.getRegisteredUsers(fetchFromServer: false, flyCallback: callback);
      /*future.then((data) async {
        //Mirrorfly.getUserList(pageNum, _searchText).then((data) async {
        mirrorFlyLog("userlist", data);
        var item = userListFromJson(data);
        var list = <ProfileDetails>[];

        if (groupJid.value.checkNull().isNotEmpty) {
          await Future.forEach(item.data!, (it) async {
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
              var userlist = mainUsersList.where((p0) => getName(p0).toString().toLowerCase().contains(_searchText.trim().toLowerCase()));
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
          list.addAll(item.data!);
          if (Constants.enableContactSync && fromSearch) {
            var userlist = mainUsersList.where((p0) => getName(p0).toString().toLowerCase().contains(_searchText.trim().toLowerCase()));
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
              var userlist = mainUsersList.where((p0) => getName(p0).toString().toLowerCase().contains(_searchText.trim().toLowerCase()));
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
      }).catchError((error) {
        debugPrint("Get User list error--> $error");
        toToast(error.toString());
      });*/
    } else {
      toToast(Constants.noInternetConnection);
    }
  }

  Future<List<ProfileDetails>> removeGroupMembers(List<ProfileDetails> items) async {
    var list = <ProfileDetails>[];
    for (var it in items) {
      var value = await Mirrorfly.isMemberOfGroup(groupJid: groupJid.value.checkNull(),userJid: it.jid.checkNull());
      mirrorFlyLog("item", value.toString());
      if (value == null || !value) {
        list.add(it);
      }
    }
    return list;
  }

  get users => usersList;

  contactSelected(ProfileDetails item) {
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
      Mirrorfly.forwardMessagesToMultipleUsers(messageIds: forwardMessageIds,userList: selectedUsersJIDList, flyCallBack: (FlyResponse response) {
        debugPrint("to chat profile ==> ${selectedUsersList[0].toJson().toString()}");
        Get.back(result: selectedUsersList[0]);
      });
    } else {
      toToast(Constants.noInternetConnection);
    }
  }

  onListItemPressed(ProfileDetails item) {
    if (isForward.value || isCreateGroup.value) {
      if (item.isBlocked.checkNull()) {
        unBlock(item);
      } else {
        contactSelected(item);
      }
    } else {
      if (isMakeCall.value) {
        if (item.isBlocked.checkNull()) {
          unBlock(item);
        } else {
          validateForCall(item);
        }
      } else {
        mirrorFlyLog("Contact Profile", item.toJson().toString());
        Get.toNamed(Routes.chat, arguments: item, parameters: {"topicId": topicId});
      }
    }
  }

  unBlock(ProfileDetails item) {
    Helper.showAlert(message: "Unblock ${getName(item)}?", actions: [
      TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text("NO",style: TextStyle(color: buttonBgColor))),
      TextButton(
          onPressed: () async {
            if (await AppUtils.isNetConnected()) {
              Get.back();
              Helper.progressLoading();
              Mirrorfly.unblockUser(userJid: item.jid.checkNull(), flyCallBack: (FlyResponse response) {
                Helper.hideLoading();
                if (response.isSuccess) {
                  toToast("${getName(item)} has been Unblocked");
                  userUpdatedHisProfile(item.jid.checkNull());
                }
              }).then((value) {

              }).catchError((error) {
                Helper.hideLoading();
                debugPrint(error);
              });
            } else {
              toToast(Constants.noInternetConnection);
            }
          },
          child: const Text("YES",style: TextStyle(color: buttonBgColor))),
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
          toToast("Select any contacts");
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

  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  var progressSpinner = false.obs;

  refreshContacts(bool isNetworkToastNeeded) async {
    if (Constants.enableContactSync) {
      mirrorFlyLog('Contact Sync', "[Contact Sync] refreshContacts()");
      if (await AppUtils.isNetConnected()) {
        if (!await Mirrorfly.contactSyncStateValue()) {
          var contactPermissionHandle = await AppPermission.checkPermission(
              Permission.contacts, contactPermission, Constants.contactSyncPermission);
          if (contactPermissionHandle) {
            progressSpinner(true);
            Mirrorfly.syncContacts(isFirstTime: !SessionManagement.isInitialContactSyncDone(), flyCallBack: (_) {  }).then((value) {
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
          mirrorFlyLog('Contact Sync', "[Contact Sync] Contact syncing is already in progress");
        }
      } else {
        if (isNetworkToastNeeded) {
          toToast(Constants.noInternetConnection);
        }
        // viewModel.onContactSyncFinished(false);
      }
    }
  }

  void onContactSyncComplete(bool result) {
    progressSpinner(false);
    _first = true;
    fetchUsers(_searchText.isNotEmpty, server: result);
  }

  @override
  void onDetached() {}

  @override
  void onInactive() {}

  @override
  void onPaused() {}

  FocusNode searchFocus = FocusNode();

  @override
  Future<void> onResumed() async {
    if (Constants.enableContactSync) {
      var status = await Permission.contacts.isGranted;
      if (status) {
        refreshContacts(false);
      } else {
        usersList.clear();
        usersList.refresh();
      }
    }
    if (search) {
      if (!KeyboardVisibilityController().isVisible) {
        if (searchFocus.hasFocus) {
          searchFocus.unfocus();
          Future.delayed(const Duration(milliseconds: 100), () {
            searchFocus.requestFocus();
          });
        }
      }
    }
  }

  void userDeletedHisProfile(String jid) {
    userUpdatedHisProfile(jid);
  }

  showProfilePopup(Rx<ProfileDetails> profile) {
    showQuickProfilePopup(
        context: Get.context,
        // chatItem: chatItem,
        chatTap: () {
          Get.back();
          onListItemPressed(profile.value);
        },
        infoTap: () {
          Get.back();
          if (profile.value.isGroupProfile ?? false) {
            Get.toNamed(Routes.groupInfo, arguments: profile.value);
          } else {
            Get.toNamed(Routes.chatInfo, arguments: profile.value);
          }
        },
        profile: profile,
        availableFeatures: availableFeatures);
  }

  void userBlockedMe(String jid) {
    userUpdatedHisProfile(jid);
  }

  void unblockedThisUser(String jid) {
    userUpdatedHisProfile(jid);
  }

  @override
  void onHidden() {}

  var groupCallMembersCount = 1.obs; //initially its 1 because me also added into call
  void validateForCall(ProfileDetails item) {
    if (isMakeCall.value) {
      if (selectedUsersJIDList.contains(item.jid)) {
        selectedUsersList.remove(item);
        selectedUsersJIDList.remove(item.jid);
        //item.isSelected = false;
        groupCallMembersCount(groupCallMembersCount.value - 1);
      } else {
        if (getMaxCallUsersCount > groupCallMembersCount.value) {
          selectedUsersList.add(item);
          selectedUsersJIDList.add(item.jid!);
          groupCallMembersCount(groupCallMembersCount.value + 1);
        } else {
          toToast(Constants.callMembersLimit.replaceFirst("%d", getMaxCallUsersCount.toString()));
        }
        //item.isSelected = true;
      }
      usersList.refresh();
    }
  }

  makeCall() async {
    if (selectedUsersJIDList.isEmpty) {
      return;
    }
    var isOneToOneCall = selectedUsersJIDList.length == 1;
    var isGroupCall = selectedUsersJIDList.length > 1;
    if ((isGroupCall && !availableFeatures.value.isGroupCallAvailable.checkNull()) ||
        (isOneToOneCall && !availableFeatures.value.isOneToOneCallAvailable.checkNull())) {
      Helper.showFeatureUnavailable();
      return;
    }
    if ((await Mirrorfly.isOnGoingCall()).checkNull()) {
      debugPrint("#Mirrorfly Call You are on another call");
      toToast(Constants.msgOngoingCallAlert);
      return;
    }
    if (!(await AppUtils.isNetConnected())) {
      toToast(Constants.noInternetConnection);
      return;
    }
    if (callType.value == CallType.audio) {
      if (await AppPermission.askAudioCallPermissions()) {
        if (isOneToOneCall) {
          Mirrorfly.makeVoiceCall(toUserJid: selectedUsersJIDList[0], flyCallBack: (FlyResponse response) {
            if (response.isSuccess) {
              Get.offNamed(Routes.outGoingCallView, arguments: {
                "userJid": [selectedUsersJIDList[0]],
                "callType": CallType.audio
              });
            }
          });
        } else {
          Mirrorfly.makeGroupVoiceCall(toUserJidList: selectedUsersJIDList, flyCallBack: (FlyResponse response) {
            if (response.isSuccess) {
              Get.offNamed(Routes.outGoingCallView,
                  arguments: {"userJid": selectedUsersJIDList, "callType": CallType.audio});
            }
          });
        }
      }
    } else if (callType.value == CallType.video) {
      if (await AppPermission.askVideoCallPermissions()) {
        if (isOneToOneCall) {
          Mirrorfly.makeVideoCall(toUserJid: selectedUsersJIDList[0], flyCallBack: (FlyResponse response) {
            if (response.isSuccess) {
              Get.offNamed(Routes.outGoingCallView, arguments: {
                "userJid": [selectedUsersJIDList[0]],
                "callType": CallType.video
              });
            }
          });
        } else {
          Mirrorfly.makeGroupVideoCall(toUserJidList: selectedUsersJIDList, flyCallBack: (FlyResponse response) {
            if (response.isSuccess) {
              Get.offNamed(Routes.outGoingCallView,
                  arguments: {"userJid": selectedUsersJIDList, "callType": CallType.video});
            }
          });
        }
      }
    }
  }

  var availableFeatures = Get.find<MainController>().availableFeature;

  void onAvailableFeaturesUpdated(AvailableFeatures features) {
    LogMessage.d("Contact", "onAvailableFeaturesUpdated ${features.toJson()}");
    availableFeatures(features);
  }
}
