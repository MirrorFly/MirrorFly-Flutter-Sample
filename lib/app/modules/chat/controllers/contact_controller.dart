import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import '../../../common/constants.dart';
import '../../../common/main_controller.dart';
import '../../../data/helper.dart';
import '../../../data/session_management.dart';
import '../../../extensions/extensions.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../app_style_config.dart';
import '../../../common/app_localizations.dart';
import '../../../common/de_bouncer.dart';
import '../../../data/permissions.dart';
import '../../../data/utils.dart';
import '../../../model/arguments.dart';
import '../../../routes/route_settings.dart';

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



  var getMaxCallUsersCount = 8;
  ContactListArguments get arguments => NavUtils.arguments as ContactListArguments;

  @override
  void dispose(){
    super.dispose();
    Get.delete<ContactController>();
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    getMaxCallUsersCount = (await Mirrorfly.getMaxCallUsersCount()) ?? 8;
    scrollController.addListener(_scrollListener);
    if (await AppUtils.isNetConnected() || Constants.enableContactSync) {
      isPageLoading(true);
      fetchUsers(false);
    } else {
      toToast(getTranslated("noInternetConnection"));
    }
    //Mirrorfly.syncContacts(true);
    //Mirrorfly.getRegisteredUsers(true).then((value) => LogMessage.d("registeredUsers", value.toString()));
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

  bool get isSearchVisible => !_search.value;

  bool get isClearVisible =>
      _search.value && lastInputValue.value.isNotEmpty /*&& !isForward.value && isCreateGroup.value*/;

  bool get isMenuVisible => !_search.value /*&& !isForward.value*/;

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
    scrollable(!Constants.enableContactSync && mainUsersList.length == 20);
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
          LogMessage.d("userlist", data);
          var item = userListFromJson(data);
          var list = <ProfileDetails>[];

          if (arguments.groupJid.isNotEmpty) {
            await Future.forEach(item.data!, (it) async {
              await Mirrorfly.isMemberOfGroup(groupJid: arguments.groupJid, userJid: it.jid.checkNull()).then((value) {
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
                scrollable(list.length == 20);
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
                scrollable(list.length == 20);
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
                scrollable(list.length == 20);
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
                scrollable(list.length == 20);
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
        var list = <ProfileDetails>[];

        if (groupJid.value.checkNull().isNotEmpty) {
          await Future.forEach(item.data!, (it) async {
            await Mirrorfly.isMemberOfGroup(groupJid.value.checkNull(), it.jid.checkNull()).then((value) {
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
      toToast(getTranslated("noInternetConnection"));
    }
  }

  Future<List<ProfileDetails>> removeGroupMembers(List<ProfileDetails> items) async {
    var list = <ProfileDetails>[];
    for (var it in items) {
      var value = await Mirrorfly.isMemberOfGroup(groupJid: arguments.groupJid,userJid: it.jid.checkNull());
      LogMessage.d("item", value.toString());
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
        NavUtils.offAllNamed(Routes.chat,arguments: ChatViewArguments(chatJid: selectedUsersList[0].jid.checkNull()),predicate: (Route<dynamic> route)=>route.settings.name!.startsWith(Routes.dashboard));
      });
    } else {
      toToast(getTranslated("noInternetConnection"));
    }
  }

  onListItemPressed(ProfileDetails item) {
    if (arguments.forGroup) {
      if (item.isBlocked.checkNull()) {
        unBlock(item);
      } else {
        contactSelected(item);
      }
    } else {
      LogMessage.d("arguments.forMakeCall", arguments.forMakeCall);
      if (arguments.forMakeCall) {
        if (item.isBlocked.checkNull()) {
          unBlock(item);
        } else {
          validateForCall(item);
        }
      } else {
        LogMessage.d("Contact Profile", item.toJson().toString());
        NavUtils.toNamed(Routes.chat, arguments: ChatViewArguments(chatJid: item.jid.checkNull(),topicId: arguments.topicId));
      }
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
            AppUtils.isNetConnected().then((isConnected) {
              if (isConnected) {
                NavUtils.back();
                DialogUtils.progressLoading();
                Mirrorfly.unblockUser(userJid: item.jid.checkNull(), flyCallBack: (FlyResponse response) {
                  DialogUtils.hideLoading();
                  if (response.isSuccess) {
                  toToast(getTranslated("hasUnBlocked").replaceFirst("%d", getName(item)));
                    userUpdatedHisProfile(item.jid.checkNull());
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

  backToCreateGroup() {
    searchFocus.unfocus();
    AppUtils.isNetConnected().then((isConnected) {
      if (isConnected) {
        if (arguments.groupJid.isEmpty) {
          if (selectedUsersJIDList.length >= Constants.minGroupMembers) {
            // Navigator.pop(buildContext, selectedUsersJIDList);
            NavUtils.back(result: selectedUsersJIDList);
          } else {
            toToast(getTranslated("addAtLeastTwoContact"));
          }
        } else {
          if (selectedUsersJIDList.isNotEmpty) {
            // Navigator.pop(buildContext, selectedUsersJIDList);
            NavUtils.back(result: selectedUsersJIDList);
          } else {
            toToast(getTranslated("selectAnyContact"));
          }
        }
      } else {
        toToast(getTranslated("noInternetConnection"));
      }
    });
  }

  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  var progressSpinner = false.obs;

  refreshContacts(bool isNetworkToastNeeded) async {
    if (Constants.enableContactSync) {
      LogMessage.d('Contact Sync', "[Contact Sync] refreshContacts()");
      if (await AppUtils.isNetConnected()) {
        if (!await Mirrorfly.contactSyncStateValue()) {
          var contactPermissionHandle = await AppPermission.checkPermission(
              Permission.contacts, contactPermission, getTranslated("contactSyncPermissionContent"));
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
          LogMessage.d('Contact Sync', "[Contact Sync] Contact syncing is already in progress");
        }
      } else {
        if (isNetworkToastNeeded) {
          toToast(getTranslated("noInternetConnection"));
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
        // chatItem: chatItem,
        chatTap: () {
          NavUtils.back();
          onListItemPressed(profile.value);
        },
        infoTap: () {
          NavUtils.back();
          if (profile.value.isGroupProfile ?? false) {
            NavUtils.toNamed(Routes.groupInfo, arguments: profile.value);
          } else {
            NavUtils.toNamed(Routes.chatInfo, arguments:ChatInfoArguments(chatJid:(profile.value.jid.checkNull())));
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
    if (arguments.forMakeCall) {
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
          toToast(getTranslated("callMembersLimit").replaceFirst("%d", getMaxCallUsersCount.toString()));
        }
        //item.isSelected = true;
      }
      usersList.refresh();
    }
  }

  void makeCall() async {
    if (selectedUsersJIDList.isEmpty) {
      return;
    }
    var isOneToOneCall = selectedUsersJIDList.length == 1;
    var isGroupCall = selectedUsersJIDList.length > 1;
    if ((isGroupCall && !availableFeatures.value.isGroupCallAvailable.checkNull()) ||
        (isOneToOneCall && !availableFeatures.value.isOneToOneCallAvailable.checkNull())) {
      DialogUtils.showFeatureUnavailable();
      return;
    }
    if ((await Mirrorfly.isOnGoingCall()).checkNull()) {
      debugPrint("#Mirrorfly Call You are on another call");
      toToast(getTranslated("msgOngoingCallAlert"));
      return;
    }
    if (!(await AppUtils.isNetConnected())) {
      toToast(getTranslated("noInternetConnection"));
      return;
    }
    if (arguments.callType == CallType.audio) {
      if (await AppPermission.askAudioCallPermissions()) {
        if (isOneToOneCall) {
          Mirrorfly.makeVoiceCall(toUserJid: selectedUsersJIDList[0], flyCallBack: (FlyResponse response) {
            if (response.isSuccess) {
              NavUtils.toNamed(Routes.outGoingCallView, arguments: {
                "userJid": [selectedUsersJIDList[0]],
                "callType": CallType.audio
              });
            }else{
              DialogUtils.showAlert(dialogStyle: AppStyleConfig.dialogStyle,message: getErrorDetails(response));
            }
          });
        } else {
          Mirrorfly.makeGroupVoiceCall(toUserJidList: selectedUsersJIDList, flyCallBack: (FlyResponse response) {
            if (response.isSuccess) {
              NavUtils.toNamed(Routes.outGoingCallView,
                  arguments: {"userJid": selectedUsersJIDList, "callType": CallType.audio});
            }else{
              DialogUtils.showAlert(dialogStyle: AppStyleConfig.dialogStyle,message: getErrorDetails(response));
            }
          });
        }
      }
    } else if (arguments.callType == CallType.video) {
      if (await AppPermission.askVideoCallPermissions()) {
        if (isOneToOneCall) {
          Mirrorfly.makeVideoCall(toUserJid: selectedUsersJIDList[0], flyCallBack: (FlyResponse response) {
            if (response.isSuccess) {
              NavUtils.toNamed(Routes.outGoingCallView, arguments: {
                "userJid": [selectedUsersJIDList[0]],
                "callType": CallType.video
              });
            }else{
              DialogUtils.showAlert(dialogStyle: AppStyleConfig.dialogStyle,message: getErrorDetails(response));
            }
          });
        } else {
          Mirrorfly.makeGroupVideoCall(toUserJidList: selectedUsersJIDList, flyCallBack: (FlyResponse response) {
            if (response.isSuccess) {
              NavUtils.toNamed(Routes.outGoingCallView,
                  arguments: {"userJid": selectedUsersJIDList, "callType": CallType.video});
            }else{
              DialogUtils.showAlert(dialogStyle: AppStyleConfig.dialogStyle,message: getErrorDetails(response));
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
