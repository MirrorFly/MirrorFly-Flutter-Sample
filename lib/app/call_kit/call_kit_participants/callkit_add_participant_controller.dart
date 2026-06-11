import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/call_kit/callkit_logger.dart';
import 'package:mirror_fly_demo/app/call_kit/callkit_outgoing_call_controller.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';
import '../../call_modules/call_utils.dart';
import '../../common/main_controller.dart';
import '../../data/helper.dart';
import '../../extensions/extensions.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../app_style_config.dart';
import '../../common/app_localizations.dart';
import '../../common/constants.dart';
import '../../common/de_bouncer.dart';
import '../../data/session_management.dart';
import '../../data/utils.dart';

class CallKitAddParticipantsController extends GetxController
    with GetTickerProviderStateMixin {

  List<String> usersInCurrentCall = [];
  var groupId =
      CallUtils.getGroupJidFromGroupId(Get.find<CallKitOutgoingCallController>().groupId.toString()).obs;

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
  var getMaxCallUsersCount = Constants.useMirrorFlyCallKit
      ? Constants.maxCallUsersLimitForMirrorFlyCallKit : 8;
  var joinViaLink = false;
  var meet = false;
  var callList = <FlyCallParticipant>[].obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    if (NavUtils.arguments != null) {
      joinViaLink = NavUtils.arguments?["joinViaLink"] ?? false;
      meet = NavUtils.arguments?["meet"] ?? false;
      callList = NavUtils.arguments?["callList"] ?? <FlyCallParticipant>[];

      callkitLogger.info("Received arguments → joinViaLink: $joinViaLink, meet: $meet, callList length: ${callList.length}"
          ", callList users: ${callList.map((e) => e.toJson()).toList()}");
    }
    callkitLogger.info("CallKitAddParticipantsController groupId: ${groupId.value}, joinViaLink: $joinViaLink, meet: $meet");
    getCallLink();
    // groupId(await Mirrorfly.getCallGroupJid());

    debugPrint("CallKitAddParticipantsController → callList json ${callList.map((e) => e.toJson()).toList()}");

    getMaxCallUsersCount = Constants.useMirrorFlyCallKit
        ? Constants.maxCallUsersLimitForMirrorFlyCallKit :  8;

    // callList = Get.find<CallController>().callList;
    scrollController.addListener(_scrollListener);

    if (!joinViaLink && !meet) {
      if (groupId.value.isEmpty) {
        if (await AppUtils.isNetConnected() || Constants.enableContactSync) {
          isPageLoading(true);
          fetchUsers(false);
        } else {
          toToast(getTranslated("noInternetConnection"));
        }
      } else {
        getGroupMembers();
      }
    } else {
      LogMessage.d("addParticipants",
          "joinViaLink $joinViaLink so no need to load users");
    }
    await _isUserAlreadyInCall();
  }

  void intiTab() {
    tabController = TabController(length: 2, vsync: this);
    // Future.delayed(const Duration(seconds: 1),(){
    tabController?.addListener(() {
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
    // });
  }

  @override
  void dispose() {
    tabController?.dispose();
    super.dispose();
  }

  ///get ongoing call link
  var meetLink = "".obs;

  void getCallLink() async{
    final GetCallJoinLinkResponse response = await MirrorFlyCallKit.getCallJoinLink();
    if (response.isSuccess && response.callId.isNotEmpty) {
      callkitLogger.info("Get Call Link Success: ${response.callId}");
      meetLink(response.callId);

      final InitializeJoinLinkResponse initResponse = await MirrorFlyCallKit.initializeJoinViaLink(callLink: response.callId);
      if (initResponse.isSuccess) {
        callkitLogger.info(
            "Initialize Join Via Link Success: ${initResponse}");
      } else {
        callkitLogger.info(
            "Initialize Join Via Link Error: ${initResponse.errorMessage}");
      }
    } else {
      callkitLogger.info("Get Call Link Error: ${response.errorMessage}");
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
      if (groupId.value.isEmpty) {
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
    var filteredList = mainUsersList
        .where(
            (item) => item.getName().toLowerCase().contains(_searchText.trim()))
        .toList();
    usersList(filteredList);
    isPageLoading(false);
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
    if (scrollController.hasClients && !joinViaLink && !meet) {
      if (scrollController.position.extentAfter <= 0 &&
          isPageLoading.value == false) {
        if (scrollable.value) {
          //isPageLoading.value = true;
          LogMessage.d("usersList.length ${usersList.length} ~/ 20",
              (usersList.length ~/ 20));
          pageNum = (usersList.length ~/ 20) + 1;
          fetchUsers(false);
        }
      }
    }
  }

  onListItemPressed(ProfileDetails item, {bool ignorePress = false}) {
    callkitLogger.info("onListItemPressed → item: ${item.jid}, ignorePress: $ignorePress");

    if (ignorePress == true) {
      callkitLogger.info("onListItemPressed → Press ignored for ${item.jid}");
      return;
    }
    
    if (item.isBlocked.checkNull()) {
      unBlock(item);
    } else {
      contactSelected(item);
    }
  }

  unBlock(ProfileDetails item) {
    DialogUtils.showAlert(
        dialogStyle: AppStyleConfig.dialogStyle,
        message: getTranslated("unBlockUser").replaceFirst("%d", getName(item)),
        actions: [
          TextButton(
              style: AppStyleConfig.dialogStyle.buttonStyle,
              onPressed: () {
                NavUtils.back();
              },
              child: Text(
                getTranslated("no").toUpperCase(),
              )),
          TextButton(
              style: AppStyleConfig.dialogStyle.buttonStyle,
              onPressed: () async {
                if (await AppUtils.isNetConnected()) {
                  NavUtils.back();
                  DialogUtils.progressLoading();
                  Mirrorfly.unblockUser(
                      userJid: item.jid.checkNull(),
                      flyCallBack: (FlyResponse response) {
                        DialogUtils.hideLoading();
                        if (response.isSuccess && response.hasData) {
                          toToast(getTranslated("hasUnBlocked")
                              .replaceFirst("%d", getName(item)));
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
    if (callList
        .indexWhere(
            (element) => element.identity == item.jid.toString())
        .isNegative) {
      if (selectedUsersJIDList.contains(item.jid)) {
        selectedUsersList.removeWhere((user) => user.jid == item.jid);
        selectedUsersJIDList.remove(item.jid);
        //item.isSelected = false;
        groupCallMembersCount(groupCallMembersCount.value - 1);
      } else {
        if (callList.length != getMaxCallUsersCount) {
          if (getMaxCallUsersCount >
              (selectedUsersList.length + callList.length)) {
            selectedUsersList.add(item);
            selectedUsersJIDList.add(item.jid!);
            groupCallMembersCount(groupCallMembersCount.value + 1);
          } else {
            toToast(getTranslated("youCanSelectForCall")
                .replaceFirst("%d", (groupCallMembersCount.value).toString()));
          }
        } else {
          toToast(getTranslated("callMembersLimit")
              .replaceFirst("%d", getMaxCallUsersCount.toString()));
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
        var userListIndex =
        usersList.indexWhere((element) => element.jid == jid);
        var mainListIndex =
        mainUsersList.indexWhere((element) => element.jid == jid);
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

  // void onUserInvite(String callMode, String userJid, String callType) {
  //   removeSelectedPartcipants();
  // }
  //
  // void removeSelectedPartcipants() {
  //   Mirrorfly.getInvitedUsersList().then((value) async {
  //     LogMessage.d("callController", " getInvitedUsersList $value");
  //     if (value.isNotEmpty) {
  //       var userJids = value;
  //       for (var jid in userJids) {
  //         selectedUsersList.removeWhere((user) => user.jid == jid);
  //         selectedUsersJIDList.remove(jid);
  //       }
  //       usersList.refresh();
  //       groupCallMembersCount(selectedUsersJIDList.length);
  //     }
  //   });
  // }

  var groupCallMembersCount = 0.obs;
  var callType = CallType.audio.obs;

  makeCall() async {
    if (selectedUsersJIDList.isEmpty) {
      return;
    }
    final List<String> normalizedJid = selectedUsersJIDList
        .map((e) => CallUtils.getIdFromJidList(e))
        .toList();
    if (!availableFeatures.value.isGroupCallAvailable.checkNull()) {
      DialogUtils.showFeatureUnavailable();
      return;
    }
    if (!(await AppUtils.isNetConnected())) {
      toToast(getTranslated("noInternetConnection"));
      return;
    }
    if (callList.value.length != getMaxCallUsersCount) {
      MirrorFlyCallKit.inviteParticipants(inviteUserList: normalizedJid, flyResult: (res) async {
        callkitLogger.info("[MirrorFly][OutgoingCallController] inviteParticipants result: $res");
        if (res.isSuccess) {
          NavUtils.back(result:normalizedJid);
          // callerList.value = await getCurrentCallParticipants();
        }
      });
    } else {
      toToast(getTranslated("callMembersLimit")
          .replaceFirst("%d", getMaxCallUsersCount.toString()));
    }
  }

  var _searchText = "";
  var _first = true;
  var groupJid = "".obs;

  fetchUsers(bool fromSearch, {bool server = false}) async {
    const String tag = "fetchUsers";

    callkitLogger.info("$tag → START | fromSearch=$fromSearch server=$server");

    if (Constants.enableContactSync) {
      callkitLogger.info("$tag → Contact sync enabled, checking permission");

      var granted = await Permission.contacts.isGranted;
      callkitLogger.info("$tag → Contact permission granted=$granted");

      if (!granted) {
        callkitLogger.info("$tag → Permission denied, stopping execution");
        isPageLoading(false);
        return;
      }
    }

    callkitLogger.info("$tag → Preparing connected user list");

    var callConnectedUserList = <String>[];
    for (var value1 in callList) {
      callConnectedUserList.add(value1.identity);
    }

    callkitLogger.info(
        "$tag → Connected users count=${callConnectedUserList.length}");

    final bool hasInternet =
        await AppUtils.isNetConnected() || Constants.enableContactSync;

    callkitLogger.info("$tag → Network available=$hasInternet");

    if (!hasInternet) {
      callkitLogger.info("$tag → No internet, showing toast");
      toToast(getTranslated("noInternetConnection"));
      return;
    }

    callkitLogger.info("$tag → Starting API call");

    callback(FlyResponse response) async {
      callkitLogger.info(
          "$tag → API callback received | success=${response.isSuccess} hasData=${response.hasData}");

      if (response.isSuccess && response.hasData) {
        var data = response.data;
        callkitLogger.info("$tag → Raw response data received");

        var item = userListFromJson(data);
        callkitLogger.info(
            "$tag → Parsed users count=${item.data?.length}");

        var items = getFilteredList(callConnectedUserList, item.data);
        callkitLogger.info(
            "$tag → Filtered users count=${items.length}");

        var list = <ProfileDetails>[];
        callkitLogger.info("$tag → Group Value, checking members : ${groupJid.value}");
        if (groupJid.value.isNotEmpty) {
          callkitLogger.info("$tag → Group JID found, checking members");

          await Future.forEach(items, (it) async {
            callkitLogger.info(
                "$tag → Checking group membership for ${it.jid}");

            await Mirrorfly.isMemberOfGroup(
              groupJid: groupJid.value.checkNull(),
              userJid: it.jid.checkNull(),
            ).then((value) {
              callkitLogger.info(
                  "$tag → isMemberOfGroup result for ${it.jid} = $value");

              if (value == null || !value) {
                list.add(it);
              }
            });
          });

          callkitLogger.info(
              "$tag → Users after group filtering=${list.length}");

          if (_first) {
            callkitLogger.info("$tag → First load, updating mainUsersList");
            _first = false;
            mainUsersList(list);
          }

        } else {
          callkitLogger.info("$tag → No group JID, skipping group filter");
          list.addAll(items);

          if (_first) {
            callkitLogger.info("$tag → First load, updating mainUsersList");
            _first = false;
            mainUsersList(list);
          }
        }

        callkitLogger.info(
            "$tag → Processing fromSearch=$fromSearch contactSync=${Constants.enableContactSync}");

        if (fromSearch) {
          if (!Constants.enableContactSync) {
            callkitLogger.info("$tag → Search without contact sync");
            usersList(list);
            scrollable.value = list.length == 20;
          } else {
            callkitLogger.info("$tag → Search with contact sync");

            var userlist = mainUsersList.where((p0) =>
                getName(p0)
                    .toLowerCase()
                    .contains(_searchText.trim().toLowerCase()));

            usersList(userlist.toList());
            scrollable(false);
          }
        } else {
          if (!Constants.enableContactSync) {
            callkitLogger.info("$tag → Pagination mode");
            usersList.addAll(list);
            scrollable.value = list.length == 20;
          } else {
            callkitLogger.info("$tag → Full list replace");
            usersList(list);
            scrollable(false);
          }
        }

        isPageLoading.value = false;
        usersList.refresh();

        callkitLogger.info(
            "$tag → UI updated | usersList=${usersList.length}");
      } else {
        callkitLogger.info(
            "$tag → API failure | error=${response.exception?.message}");
        toToast(response.exception!.message.toString());
      }
    };

    if (!Constants.enableContactSync && groupId.isEmpty) {
      callkitLogger.info(
          "$tag → Calling getUserList | page=$pageNum search=$_searchText");

      Mirrorfly.getUserList(
        page: pageNum,
        search: _searchText,
        metaDataUserList: Constants.metaDataUserList,
        flyCallback: callback,
      );
    } else if (!Constants.enableContactSync && groupId.isNotEmpty) {
      callkitLogger.info("$tag → Calling getGroupMembersList");
      Mirrorfly.getGroupMembersList(
          jid: groupId.value.toString(),
          flyCallBack: (FlyResponse response) {
            LogMessage.d("getGroupMembersList", response.toString());
            if (response.isSuccess && response.hasData) {
              var list = profileFromJson(response.data);
              var callConnectedUserList = List<String>.from(
                  callList.map((element) => element.identity));
              var filteredList = getFilteredList(callConnectedUserList, list);
              mainUsersList(filteredList);
              usersList(filteredList);
            }
          });
    } else {
      callkitLogger.info("$tag → Calling getRegisteredUsers");

      Mirrorfly.getRegisteredUsers(
        fetchFromServer: false,
        flyCallback: callback,
      );
    }
  }

  void getGroupMembers() {
    if (groupId.value.isNotEmpty) {
      Mirrorfly.getGroupMembersList(
          jid: groupId.value.toString(),
          flyCallBack: (FlyResponse response) {
            LogMessage.d("getGroupMembersList", response.toString());
            if (response.isSuccess && response.hasData) {
              var list = profileFromJson(response.data);
              var callConnectedUserList = List<String>.from(
                  callList.map((element) => element.identity));
              var filteredList = getFilteredList(callConnectedUserList, list);
              mainUsersList(filteredList);
              usersList(filteredList);
            }
          });
    }
  }

  List<ProfileDetails> getFilteredList(
      List<String> callConnectedUserList, List<ProfileDetails>? usersList) {
    return (usersList
        ?.where((element) =>
    !callConnectedUserList.contains(element.jid) &&
        element.jid != SessionManagement.getUserJID())
        .toList()) ??
        [];
  }

  var availableFeatures = Get.find<MainController>().availableFeature;

  void onAvailableFeaturesUpdated(AvailableFeatures features) {
    LogMessage.d(
        "GroupParticipants", "onAvailableFeaturesUpdated ${features.toJson()}");
    availableFeatures(features);
  }

  String getLinkToShow({required String fullLink}) {
    callkitLogger.info("getLinkToShow → "
        "fullLink=$fullLink "
        "joinViaLink=$joinViaLink "
        "meetLink=${meetLink.value}");

    if (!Constants.useMirrorFlyCallKit) {
      return fullLink;
    }

    const String subStringIdentifier = "call/";
    final int index = fullLink.indexOf(subStringIdentifier);
    if (index == -1) {
      return fullLink;
    }

    final String extracted = fullLink.substring(index + subStringIdentifier.length);
    callkitLogger.info("getLinkToShow → extracted=$extracted");

    return extracted;
  }

  /// To know the user is already in current call or not
  Future<void> _isUserAlreadyInCall() async {
    callkitLogger.info("isUserAlreadyInCall → Checking if user is already in call");

    for (FlyCallParticipant user in callList) {
      callkitLogger.info("isUserAlreadyInCall → Checking user: ${user.identity}");

      final String userId = user.identity;
      if (userId.isEmpty) {
        callkitLogger.info("isUserAlreadyInCall → Invalid userId provided");
        usersInCurrentCall = [];
      }

      final List<FlyCallParticipant> flyCallParticipants = MirrorFlyCallKit.getCurrentCallParticipants();
      if (flyCallParticipants.isEmpty) {
        callkitLogger.info(
            "isUserAlreadyInCall → No participants found, user is not in call");
        usersInCurrentCall = [];
      }

      if (flyCallParticipants.any((p) => p.identity == userId)) {
        callkitLogger.info(
            "isUserAlreadyInCall → User $userId is already in call");
        usersInCurrentCall.add(userId);
      } else {
        callkitLogger.info("isUserAlreadyInCall → User $userId is not in call");
        usersInCurrentCall = [];
      }
    }
  }

  void isVideoMuted({required bool isVideoMuted, required String userId}) {
    callkitLogger.info("#CallKitAddParticipantsController → isVideoMuted: $isVideoMuted, for user: $userId");
    callList.firstWhereOrNull((e) => e.identity == userId)?.copyWith(isVideoMuted: isVideoMuted);

  }

  void isAudioMuted({required bool isAudioMuted, required String userId}) {
    callkitLogger.info("#CallKitAddParticipantsController → isAudioMuted: $isAudioMuted, for user: $userId");
    callList.firstWhereOrNull((e) => e.identity == userId)?.copyWith(isAudioMuted: isAudioMuted);
  }
}
