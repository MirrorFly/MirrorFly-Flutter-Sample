import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/constants.dart';
import '../../common/main_controller.dart';
import '../../data/session_management.dart';
import '../../extensions/extensions.dart';
import '../../modules/dashboard/controllers/dashboard_controller.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';

import '../../app_style_config.dart';
import '../../common/app_localizations.dart';
import '../../data/helper.dart';
import '../../data/utils.dart';
import '../../model/arguments.dart';
import '../../model/chat_message_model.dart';
import '../../routes/route_settings.dart';

class ArchivedChatListController extends GetxController {
  DashboardController dashboardController = Get.find<DashboardController>();
  RxList<RecentChatData> archivedChats = Get.find<DashboardController>().archivedChats;

  //RxList<RecentChatData> archivedChats = <RecentChatData>[].obs;

  @override
  void onInit() {
    super.onInit();
    //archivedChats(dashboardController.archivedChats);
    getArchivedSettingsEnabled();
  }

  final archiveEnabled = true.obs;
  Future<void> getArchivedSettingsEnabled() async {
    await Mirrorfly.isArchivedSettingsEnabled().then((value) => archiveEnabled(value));
  }

  getArchivedChatsList() async {
    await Mirrorfly.getArchivedChatList(flyCallBack: (FlyResponse response) {
      LogMessage.d("archived response", response.toString());
      if (response.isSuccess && response.hasData) {
        var data = recentChatFromJson(response.data);
        archivedChats(data.data!);
      } else {
        debugPrint("Archive list is empty");
      }
    });
  }

  var selected = false.obs;
  var selectedChats = <String>[].obs;
  var selectedChatsPosition = <int>[].obs;

  isSelected(int index) => selectedChats.contains(archivedChats[index].jid);

  selectOrRemoveChatFromList(int index) {
    if (selected.isTrue) {
      if (selectedChats.contains(archivedChats[index].jid)) {
        selectedChats.remove(archivedChats[index].jid.checkNull());
        selectedChatsPosition.remove(index);
      } else {
        selectedChats.add(archivedChats[index].jid.checkNull());
        selectedChatsPosition.add(index);
      }
    }
    if (selectedChats.isEmpty) {
      clearAllChatSelection();
    } else {
      menuValidationForItem();
    }
  }

  menuValidationForItem() {
    // delete(false);
    if (selectedChats.length == 1) {
      var item = archivedChats.firstWhere((element) => selectedChats.first == element.jid);
      // delete(Constants.typeGroupChat != item.getChatType());
      menuValidationForDeleteIcon();
      if ((ChatType.broadcastChat != item.getChatType() && !archiveEnabled.value)) {
        unMute(item.isMuted!);
        mute(!item.isMuted!);
        // shortcut(true);
        debugPrint("item.isMuted! ${item.isMuted!}");
      } else {
        unMute(false);
        mute(false);
        // shortcut(false);
      }
    } else {
      menuValidationForDeleteIcon();
      if (!archiveEnabled.value) {
        menuValidationForMuteUnMuteIcon();
      }
    }
  }

  clearAllChatSelection() {
    selected(false);
    selectedChats.clear();
    selectedChatsPosition.clear();
    update();
  }

  var typingAndGoneStatus = <Triple>[].obs;

  String typingUser(String jid) {
    var index = typingAndGoneStatus.indexWhere((it) => it.singleOrgroupJid == jid);
    if (index.isNegative) {
      return "";
    } else {
      return typingAndGoneStatus[index].userId.isNotEmpty
          ? typingAndGoneStatus[index].userId
          : typingAndGoneStatus[index].singleOrgroupJid;
    }
  }

  void setTypingStatus(String singleOrgroupJid, String userId, String typingStatus) {
    var index = typingAndGoneStatus.indexWhere((it) => it.singleOrgroupJid == singleOrgroupJid && it.userId == userId);
    if (typingStatus.toLowerCase() == Constants.composing) {
      if (index.isNegative) {
        typingAndGoneStatus.insert(0, Triple(singleOrgroupJid, userId, true));
      }
    } else {
      if (!index.isNegative) {
        typingAndGoneStatus.removeAt(index);
      }
    }
  }

  toChatPage(String jid) {
    if (jid.isNotEmpty) {
      NavUtils.toNamed(Routes.chat, arguments:ChatViewArguments(chatJid: jid));
      // DialogUtils.progressLoading();
      /*getProfileDetails(jid).then((value) {
        if (value.jid != null) {
          DialogUtils.hideLoading();
          var profile = value;//profiledata(value.toString());
          NavUtils.toNamed(Routes.chat, arguments: profile);
        }
      });*/
      // SessionManagement.setChatJid(jid);
      // NavUtils.toNamed(Routes.chat);
    }
  }

  _itemUnArchive(int index) {
    Mirrorfly.setChatArchived(jid: selectedChats[index], isArchived: false, flyCallBack: (_) {
      updateRecentChatListHistory();
    });
    var chatIndex =
        archivedChats.indexWhere((element) => selectedChats[index] == element.jid); //selectedChatsPosition[index];
    archivedChats[chatIndex].isChatArchived = (false);
    archivedChats.removeAt(chatIndex);
  }

  Future<void> unArchiveSelectedChats() async {
    if (await AppUtils.isNetConnected()) {
      if (selectedChats.length == 1) {
        _itemUnArchive(0);
        clearAllChatSelection();
        toToast(getTranslated("chatHasBeenUnArchived"));
      } else {
        selected(false);
        var count = selectedChats.length;
        selectedChats.asMap().forEach((key, value) {
          _itemUnArchive(key);
        });
        clearAllChatSelection();
        toToast("$count ${getTranslated("chatsHasBeenUnArchived")}");
      }
    } else {
      toToast(getTranslated("noInternetConnection"));
    }
  }

  void checkArchiveList(RecentChatData recent) async {
    Mirrorfly.isArchivedSettingsEnabled().then((value) {
      if (value.checkNull()) {
        var archiveIndex = archivedChats.indexWhere((element) => recent.jid == element.jid);
        LogMessage.d("checkArchiveList", "$archiveIndex");
        if (!archiveIndex.isNegative) {
          archivedChats.removeAt(archiveIndex);
          archivedChats.insert(0, recent);
          archivedChats.refresh();
        } else {
          archivedChats.insert(0, recent);
          archivedChats.refresh();
        }
      } else {
        var archiveIndex = archivedChats.indexWhere((element) => recent.jid == element.jid);
        if (!archiveIndex.isNegative) {
          archivedChats.removeAt(archiveIndex);
          /*var lastPinnedChat = dashboardController.recentChats.lastIndexWhere((element) =>
          element.isChatPinned!);
          var nxtIndex = lastPinnedChat.isNegative ? 0 : (lastPinnedChat + 1);
          LogMessage.d("lastPinnedChat", lastPinnedChat.toString());
          dashboardController.recentChats.insert(nxtIndex, recent);*/
        }
      }
    });
  }


  Future<void> onMessageReceived(ChatMessageModel chatMessage) async {
    updateArchiveRecentChat(chatMessage.chatUserJid);
  }

  Future<void> onMessageStatusUpdated(ChatMessageModel chatMessageModel) async {
    // mirrorFlyLog("MESSAGE STATUS UPDATED", event);
    updateArchiveRecentChat(chatMessageModel.chatUserJid);
  }


  Future<RecentChatData?> getRecentChatOfJid(String jid) async {
    var value = await Mirrorfly.getRecentChatOf(jid: jid);
    LogMessage.d("chat", value.toString());
    if (value.isNotEmpty) {
      var data = recentChatDataFromJson(value);
      return data;
    } else {
      return null;
    }
  }

  Future<bool> updateArchiveRecentChat(String jid) async {
    LogMessage.d("checkArchiveList", jid);
    var recent = await getRecentChatOfJid(jid);
    final index = archivedChats.indexWhere((chat) => chat.jid == jid);
    if (recent != null) {
      checkArchiveList(recent);
    } else {
      if (!index.isNegative) {
        archivedChats.removeAt(index);
      }
    }
    archivedChats.refresh();
    return true;
  }

  var delete = false.obs;

  menuValidationForDeleteIcon() async {
    var selected = archivedChats.where((p0) => selectedChats.contains(p0.jid));
    for (var item in selected) {
      var isMember = await Mirrorfly.isMemberOfGroup(groupJid: item.jid.checkNull(), userJid: SessionManagement.getUserJID().checkNull());
      if ((item.getChatType() == ChatType.groupChat) && isMember!) {
        delete(false);
        return;
        //return false;
      }
    }
    delete(true);
    //return true;
  }

  var mute = false.obs;
  var unMute = false.obs;
  menuValidationForMuteUnMuteIcon() {
    var checkListForMuteUnMuteIcon = <bool>[];
    var selected = archivedChats.where((p0) => selectedChats.contains(p0.jid));
    for (var value in selected) {
      if (!value.isBroadCast!) {
        checkListForMuteUnMuteIcon.add(value.isMuted.checkNull());
      }
    }
    if (checkListForMuteUnMuteIcon.contains(false)) {
      // Mute able
      mute(true);
      unMute(false);
    } else if (checkListForMuteUnMuteIcon.contains(true)) {
      mute(false);
      unMute(true);
    } else {
      mute(false);
      unMute(false);
    }
    //return checkListForMuteUnMuteIcon.contains(false);// Mute able
  }

  muteChats() {
    if (selectedChats.length == 1) {
      _itemMute(0);
      clearAllChatSelection();
    } else {
      selected(false);
      selectedChats.asMap().forEach((key, value) {
        _itemMute(key);
      });
      clearAllChatSelection();
    }
  }

  unMuteChats() {
    if (selectedChats.length == 1) {
      _itemUnMute(0);
      clearAllChatSelection();
    } else {
      selected(false);
      selectedChats.asMap().forEach((key, value) {
        _itemUnMute(key);
      });
      clearAllChatSelection();
    }
  }

  _itemMute(int index) {
    Mirrorfly.updateChatMuteStatus(jid: selectedChats[index], muteStatus: true);
    var chatIndex =
        archivedChats.indexWhere((element) => selectedChats[index] == element.jid); //selectedChatsPosition[index];
    archivedChats[chatIndex].isMuted = (true);
  }

  _itemUnMute(int index) {
    var chatIndex =
        archivedChats.indexWhere((element) => selectedChats[index] == element.jid); //selectedChatsPosition[index];
    archivedChats[chatIndex].isMuted = (false);
    Mirrorfly.updateChatMuteStatus(jid: selectedChats[index], muteStatus: false);
  }

  deleteChats() {
    String? profile = '';
    profile = archivedChats.firstWhere((element) => selectedChats.first == element.jid).profileName;
    DialogUtils.showAlert(dialogStyle: AppStyleConfig.dialogStyle,
        title:
            selectedChats.length == 1 ? getTranslated("deleteChatWith").replaceFirst("%d", "$profile") : getTranslated("deleteSelectedChats").replaceFirst("%d", "${selectedChats.length}"),
        actions: [
          TextButton(style: AppStyleConfig.dialogStyle.buttonStyle,
              onPressed: () {
                NavUtils.back();
              },
              child: Text(getTranslated("no").toUpperCase(), )),
          TextButton(style: AppStyleConfig.dialogStyle.buttonStyle,
              onPressed: () {
                NavUtils.back();
                if (selectedChats.length == 1) {
                  _itemDelete(0);
                } else {
                  itemsDelete();
                }
              },
              child: Text(getTranslated("yes").toUpperCase(), )),
        ],
        message: '');
  }

  _itemDelete(int index) {
    var chatIndex =
        archivedChats.indexWhere((element) => selectedChats[index] == element.jid); //selectedChatsPosition[index];
    archivedChats.removeAt(chatIndex);
    Mirrorfly.deleteRecentChats(jidList: [selectedChats[index]], flyCallBack: (_) {  });
    //Mirrorfly.updateArchiveUnArchiveChat(selectedChats[index], false);
    clearAllChatSelection();
  }

  itemsDelete() {
    // debugPrint('selectedChatsPosition : ${selectedChatsPosition.join(',')}');
    Mirrorfly.deleteRecentChats(jidList: selectedChats, flyCallBack: (_) {});
    for (var element in selectedChats) {
      archivedChats.removeWhere((e) => e.jid == element);
    }
    clearAllChatSelection();
  }

  void userUpdatedHisProfile(String jid) {
    updateRecentChatAdapter(jid);
  }

  Future<void> updateRecentChatAdapter(String jid) async {
    if (jid.isNotEmpty) {
      var index =
          archivedChats.indexWhere((element) => element.jid == jid); // { it.jid ?: Constants.EMPTY_STRING == jid }
      if (!index.isNegative) {
        var recent = await getRecentChatOfJid(jid);
        if (recent != null) {
          var updateIndex =
          archivedChats.indexWhere((element) => element.jid == jid);
          archivedChats[updateIndex] = recent;
        }
      }
    }
  }

  void userDeletedHisProfile(String jid) {
    userUpdatedHisProfile(jid);
    updateProfile(jid);
  }

  var profile_ = ProfileDetails().obs;
  void getProfileDetail(context, RecentChatData chatItem, int index) {
    getProfileDetails(chatItem.jid.checkNull()).then((value) {
      profile_(value);
      debugPrint("dashboard controller profile update received");
      showQuickProfilePopup(
          // chatItem: chatItem,
          chatTap: () {
            NavUtils.back();
            toChatPage(chatItem.jid.checkNull());
          },
          infoTap: () {
            NavUtils.back();
            infoPage(value);
          },
          profile: profile_,
          availableFeatures: availableFeatures);
    });
  }

  void updateProfile(String jid) {
    if (profile_.value.jid != null && profile_.value.jid.toString() == jid.toString()) {
      getProfileDetails(jid).then((value) {
        debugPrint("get profile detail archived $value");
        profile_(value);
      });
    }
  }

  infoPage(ProfileDetails profile) {
    if (profile.isGroupProfile ?? false) {
      NavUtils.toNamed(Routes.groupInfo, arguments: profile)?.then((value) {
        if (value != null) {
          // profile_(value as Profile);
          // isBlocked(profile.isBlocked);
          // checkAdminBlocked();
          // memberOfGroup();
          // Mirrorfly.setOnGoingChatUser(profile.jid!);
          // getChatHistory();
          // sendReadReceipt();
        }
      });
    } else {
      NavUtils.toNamed(Routes.chatInfo, arguments: ChatInfoArguments(chatJid:profile.jid.checkNull()))?.then((value) {});
    }
  }

  var availableFeatures = Get.find<MainController>().availableFeature;
  void onAvailableFeaturesUpdated(AvailableFeatures features) {
    LogMessage.d("ArchivedChat", "onAvailableFeaturesUpdated ${features.toJson()}");
    availableFeatures(features);
  }

  void onMessageEdited(ChatMessageModel editedChatMessage) {
    updateArchiveRecentChat(editedChatMessage.chatUserJid);
  }

  void updateRecentChatListHistory(){
    if (Get.isRegistered<MainController>()) {
      Get.find<MainController>().updateRecentChatListHistory();
    }
  }
}
