import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/extensions.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/common/de_bouncer.dart';
import 'package:mirror_fly_demo/app/data/apputils.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/data/permissions.dart';
import 'package:mirror_fly_demo/app/data/session_management.dart';
import 'package:mirror_fly_demo/app/routes/app_pages.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';

class GroupParticipantsController extends GetxController {
  var usersList = <ProfileDetails>[].obs;
  var mainUserList = <ProfileDetails>[].obs;
  var selectedUsersList = List<ProfileDetails>.empty(growable: true).obs;
  var selectedUsersJIDList = List<String>.empty(growable: true).obs;


  var groupId = "".obs;
  var callType = "".obs;
  @override
  Future<void> onInit() async {
    super.onInit();
    getMaxCallUsersCount = (await Mirrorfly.getMaxCallUsersCount()) ?? 8;
    groupId(Get.arguments["groupId"]);
    callType(Get.arguments["callType"]);
    getGroupMembers();
  }

  @override
  void onClose() {
    super.onClose();
    searchQuery.dispose();
  }

  void getGroupMembers() {
    Mirrorfly.getGroupMembersList(groupId.value.checkNull(), false).then((value) {
      mirrorFlyLog("getGroupMembersList", value);
      if (value.isNotEmpty) {
        var list = profileFromJson(value);
        var withoutMe = list.where((element) => element.jid != SessionManagement.getUserJID()).toList();
        mainUserList(withoutMe);
        usersList(withoutMe);
      }
    });
  }

  //Search Start Here
  bool get isClearVisible => _search.value && lastInputValue.value.isNotEmpty /*&& !isForward.value && isCreateGroup.value*/;
  bool get isSearchVisible => !_search.value;
  FocusNode searchFocus = FocusNode();

  final _search = false.obs;
  set search(bool value) => _search.value = value;
  bool get search => _search.value;

  var _searchText = "";

  final TextEditingController searchQuery = TextEditingController();

  void onSearchPressed() {
    if (_search.value) {
      _search(false);
    } else {
      _search(true);
    }
  }

  final deBouncer = DeBouncer(milliseconds: 700);
  RxString lastInputValue = "".obs;

  searchListener(String text) async {
    debugPrint("searching .. ");
    if (lastInputValue.value != searchQuery.text.trim()) {
      lastInputValue(searchQuery.text.trim());
      if (searchQuery.text.trim().isEmpty) {
        _searchText = "";
      } else {
        _searchText = searchQuery.text.trim();
      }
      filterGroupMembers();
    }
  }

  void filterGroupMembers() {
    var filteredList = mainUserList.where((item) => item.getName().toLowerCase().contains(_searchText.trim())).toList();
    usersList(filteredList);
  }

  clearSearch() {
    searchQuery.clear();
    _searchText = "";
    lastInputValue('');
    usersList(mainUserList);
  }

  backFromSearch() {
    _search.value = false;
    searchQuery.clear();
    _searchText = "";
    lastInputValue('');
    usersList(mainUserList);
  }

  //Search End Here

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
        profile: profile);
  }

  onListItemPressed(ProfileDetails item) {
    if (item.isBlocked.checkNull()) {
      unBlock(item);
    } else {
      validateForCall(item);
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

  void userUpdatedHisProfile(String jid) {
    updateProfile(jid);
  }

  Future<void> updateProfile(String jid) async {
    if (jid.isNotEmpty) {
      getProfileDetails(jid).then((value) {
        var userListIndex = usersList.indexWhere((element) => element.jid == jid);
        var mainUserListIndex = mainUserList.indexWhere((element) => element.jid == jid);
        mirrorFlyLog('value.isBlockedMe', value.isBlockedMe.toString());
        if (!userListIndex.isNegative) {
          usersList[userListIndex] = value;
          usersList.refresh();
        }
        if (!mainUserListIndex.isNegative) {
          mainUserList[userListIndex] = value;
          mainUserList.refresh();
        }
      });
    }
  }

  //Call Functions Start Here
  var getMaxCallUsersCount = 8;
  var groupCallMembersCount = 1.obs; //initially its 1 because me also added into call
  void validateForCall(ProfileDetails item) {
    if (selectedUsersJIDList.contains(item.jid)) {
      selectedUsersList.remove(item);
      selectedUsersJIDList.remove(item.jid);
      groupCallMembersCount(groupCallMembersCount.value - 1);
    } else {
      if (getMaxCallUsersCount > groupCallMembersCount.value) {
        selectedUsersList.add(item);
        selectedUsersJIDList.add(item.jid!);
        groupCallMembersCount(groupCallMembersCount.value + 1);
      } else {
        toToast(Constants.callMembersLimit.replaceFirst("%d", getMaxCallUsersCount.toString()));
      }
    }
    usersList.refresh();
  }

  makeCall() async {
    if (selectedUsersJIDList.isNotEmpty) {
      if (await AppUtils.isNetConnected()) {
        if (callType.value == CallType.audio) {
          if (await AppPermission.askAudioCallPermissions()) {
            Mirrorfly.makeGroupVoiceCall(groupJid: groupId.value, jidList: selectedUsersJIDList).then((value) {
              if (value) {
                Get.offNamed(Routes.outGoingCallView,
                    arguments: {"userJid": selectedUsersJIDList, "callType": CallType.audio});
              }
            });
          }
        } else if (callType.value == CallType.video) {
          if (await AppPermission.askVideoCallPermissions()) {
            Mirrorfly.makeGroupVideoCall(groupJid: groupId.value, jidList: selectedUsersJIDList).then((value) {
              if (value) {
                Get.offNamed(Routes.outGoingCallView,
                    arguments: {"userJid": selectedUsersJIDList, "callType": CallType.video});
              }
            });
          }
        }
      } else {
        toToast(Constants.noInternetConnection);
      }
    }else{
      LogMessage.d("makeCall", selectedUsersJIDList);
    }
  }

  //Call Functions End Here
}
