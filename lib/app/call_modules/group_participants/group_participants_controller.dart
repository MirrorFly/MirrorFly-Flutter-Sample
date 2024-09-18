import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/constants.dart';
import '../../common/de_bouncer.dart';
import '../../common/main_controller.dart';
import '../../data/helper.dart';
import '../../data/permissions.dart';
import '../../data/session_management.dart';
import '../../extensions/extensions.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';

import '../../app_style_config.dart';
import '../../common/app_localizations.dart';
import '../../data/utils.dart';
import '../../model/arguments.dart';
import '../../routes/route_settings.dart';

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
    groupId(NavUtils.arguments["groupId"]);
    callType(NavUtils.arguments["callType"]);
    getGroupMembers();
  }

  @override
  void onClose() {
    super.onClose();
    searchQuery.dispose();
  }

  void getGroupMembers() {
    Mirrorfly.getGroupMembersList(jid: groupId.value.checkNull(), fetchFromServer: false, flyCallBack: (FlyResponse response) {
      LogMessage.d("getGroupMembersList", response.toString());
      if (response.isSuccess &&response.hasData) {
        var list = profileFromJson(response.data);
        var withoutMe = list.where((element) => element.jid != SessionManagement.getUserJID()).toList();
        mainUserList(withoutMe);
        usersList(withoutMe);
      }
    });
  }

  //Search Start Here
  bool get isClearVisible =>
      _search.value && lastInputValue.value.isNotEmpty /*&& !isForward.value && isCreateGroup.value*/;
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
        // chatItem: chatItem,
        chatTap: () {
          NavUtils.back();
          onListItemPressed(profile.value);
        },
        infoTap: () {
          NavUtils.back();
          if (profile.value.isGroupProfile ?? false) {
            NavUtils.toNamed(Routes.groupInfo, arguments: profile.value.jid.checkNull());
          } else {
            NavUtils.toNamed(Routes.chatInfo, arguments: ChatInfoArguments(chatJid:profile.value.jid.checkNull()));
          }
        },
        profile: profile,
        availableFeatures: availableFeatures);
  }

  onListItemPressed(ProfileDetails item) {
    if (item.isBlocked.checkNull()) {
      unBlock(item);
    } else {
      validateForCall(item);
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
          child: Text(getTranslated("yes").toUpperCase(), )),
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
        LogMessage.d('value.isBlockedMe', value.isBlockedMe.toString());
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
        toToast(getTranslated("callMembersLimit").replaceFirst("%d", getMaxCallUsersCount.toString()));
      }
    }
    usersList.refresh();
  }

  makeCall() async {
    if (selectedUsersJIDList.isEmpty) {
      return;
    }
    if (!availableFeatures.value.isGroupCallAvailable.checkNull()) {
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
    if (callType.value == CallType.audio) {
      if (await AppPermission.askAudioCallPermissions()) {
        Mirrorfly.makeGroupVoiceCall(groupJid: groupId.value, toUserJidList: selectedUsersJIDList, flyCallBack: (FlyResponse response) {
          if (response.isSuccess) {
            NavUtils.offNamed(Routes.outGoingCallView,
                arguments: {"userJid": selectedUsersJIDList, "callType": CallType.audio});
          }
        });
      }
    } else if (callType.value == CallType.video) {
      if (await AppPermission.askVideoCallPermissions()) {
        Mirrorfly.makeGroupVideoCall(groupJid: groupId.value, toUserJidList: selectedUsersJIDList, flyCallBack: (FlyResponse response) {
          if (response.isSuccess) {
            NavUtils.offNamed(Routes.outGoingCallView,
                arguments: {"userJid": selectedUsersJIDList, "callType": CallType.video});
          }
        });
      }
    }
  }

  //Call Functions End Here
  var availableFeatures = Get.find<MainController>().availableFeature;
  void onAvailableFeaturesUpdated(AvailableFeatures features) {
    LogMessage.d("GroupParticipants", "onAvailableFeaturesUpdated ${features.toJson()}");
    availableFeatures(features);
  }
}
