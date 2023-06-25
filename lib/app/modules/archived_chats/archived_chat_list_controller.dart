import 'package:flutter/material.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/modules/dashboard/controllers/dashboard_controller.dart';

import '../../data/apputils.dart';
import '../../data/helper.dart';
import '../../model/chat_message_model.dart';
import '../../routes/app_pages.dart';

class ArchivedChatListController extends GetxController {
  DashboardController dashboardController = Get.find<DashboardController>();
  RxList<RecentChatData> archivedChats =
      Get.find<DashboardController>().archivedChats;

  //RxList<RecentChatData> archivedChats = <RecentChatData>[].obs;

  @override
  void onInit(){
    super.onInit();
    //archivedChats(dashboardController.archivedChats);
    getArchivedSettingsEnabled();
  }
  final archiveEnabled = true.obs;
  Future<void> getArchivedSettingsEnabled() async {
    await Mirrorfly.isArchivedSettingsEnabled().then((value) => archiveEnabled(value));
  }

  getArchivedChatsList() async {
    await Mirrorfly.getArchivedChatList().then((value) {
      mirrorFlyLog("archived response", value.toString());
      if(value != null) {
        var data = recentChatFromJson(value);
        archivedChats(data.data!);
      }else{
        debugPrint("Archive list is empty");
      }
    }).catchError((error) {
      debugPrint("issue===> $error");
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
      var item = archivedChats
          .firstWhere((element) => selectedChats.first == element.jid);
      // delete(Constants.typeGroupChat != item.getChatType());
      menuValidationForDeleteIcon();
      if ((Constants.typeBroadcastChat != item.getChatType()&& !archiveEnabled.value)) {
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
      if(!archiveEnabled.value) {
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
    var index =
        typingAndGoneStatus.indexWhere((it) => it.singleOrgroupJid == jid);
    if (index.isNegative) {
      return "";
    } else {
      return typingAndGoneStatus[index].userId.isNotEmpty
          ? typingAndGoneStatus[index].userId
          : typingAndGoneStatus[index].singleOrgroupJid;
    }
  }

  void setTypingStatus(
      String singleOrgroupJid, String userId, String typingStatus) {
    var index = typingAndGoneStatus.indexWhere(
        (it) => it.singleOrgroupJid == singleOrgroupJid && it.userId == userId);
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
      // Helper.progressLoading();
      getProfileDetails(jid).then((value) {
        if (value.jid != null) {
          Helper.hideLoading();
          var profile = value;//profiledata(value.toString());
          Get.toNamed(Routes.chat, arguments: profile);
        }
      });
      // SessionManagement.setChatJid(jid);
      // Get.toNamed(Routes.chat);
    }
  }

  _itemUnArchive(int index) {
    Mirrorfly.updateArchiveUnArchiveChat(selectedChats[index], false);
    var chatIndex = archivedChats.indexWhere((element) =>
        selectedChats[index] == element.jid); //selectedChatsPosition[index];
    archivedChats[chatIndex].isChatArchived = (false);
    archivedChats.removeAt(chatIndex);
  }

  Future<void> unArchiveSelectedChats() async {
    if (await AppUtils.isNetConnected()) {
      if (selectedChats.length == 1) {
        _itemUnArchive(0);
        clearAllChatSelection();
        toToast("1 chat has been unarchived");
      } else {
        selected(false);
        var count = selectedChats.length;
        selectedChats.asMap().forEach((key, value) {
          _itemUnArchive(key);
        });
        clearAllChatSelection();
        toToast("$count chats has been unarchived");
      }
    } else {
      toToast(Constants.noInternetConnection);
    }
  }

  void checkArchiveList(RecentChatData recent) async {
    Mirrorfly.isArchivedSettingsEnabled().then((value) {
      if (value.checkNull()) {
        var archiveIndex =
            archivedChats.indexWhere((element) => recent.jid == element.jid);
        mirrorFlyLog("checkArchiveList", "$archiveIndex");
        if (!archiveIndex.isNegative) {
          archivedChats.removeAt(archiveIndex);
          archivedChats.insert(0, recent);
          archivedChats.refresh();
        } else {
          archivedChats.insert(0, recent);
          archivedChats.refresh();
        }
      } else {
        var archiveIndex =
            archivedChats.indexWhere((element) => recent.jid == element.jid);
        if (!archiveIndex.isNegative) {
          archivedChats.removeAt(archiveIndex);
          /*var lastPinnedChat = dashboardController.recentChats.lastIndexWhere((element) =>
          element.isChatPinned!);
          var nxtIndex = lastPinnedChat.isNegative ? 0 : (lastPinnedChat + 1);
          mirrorFlyLog("lastPinnedChat", lastPinnedChat.toString());
          dashboardController.recentChats.insert(nxtIndex, recent);*/
        }
      }
    });
  }

  void onMessageReceived(ChatMessageModel chatMessage) {
    updateArchiveRecentChat(chatMessage.chatUserJid);
  }

  void onMessageStatusUpdated(ChatMessageModel chatMessageModel) {
    // mirrorFlyLog("MESSAGE STATUS UPDATED", event);
    updateArchiveRecentChat(chatMessageModel.chatUserJid);
  }

  Future<RecentChatData?> getRecentChatOfJid(String jid) async {
    var value = await Mirrorfly.getRecentChatOf(jid);
    mirrorFlyLog("chat", value.toString());
    if (value != null) {
      var data = recentChatDataFromJson(value);
      return data;
    } else {
      return null;
    }
  }

  updateArchiveRecentChat(String jid) {
    mirrorFlyLog("checkArchiveList", jid);
    getRecentChatOfJid(jid).then((recent) {
      final index = archivedChats.indexWhere((chat) => chat.jid == jid);
      if (recent != null) {
        /*if(!recent.isChatArchived.checkNull()) {
          if (index.isNegative) {
            archivedChats.insert(0, recent);
          } else {
            var lastPinnedChat = archivedChats.lastIndexWhere((element) =>
            element.isChatPinned!);
            var nxtIndex = lastPinnedChat.isNegative ? 0 : (lastPinnedChat + 1);
            if (archivedChats[index].isChatPinned!) {
              archivedChats.removeAt(index);
              archivedChats.insert(index, recent);
            } else {
              archivedChats.removeAt(index);
              archivedChats.insert(nxtIndex, recent);
              archivedChats.refresh();
            }
          }
        }else{
          if (!index.isNegative) {
            archivedChats.removeAt(index);
          }
          checkArchiveList(recent);
        }*/
        checkArchiveList(recent);
      } else {
        if (!index.isNegative) {
          archivedChats.removeAt(index);
        }
      }
      archivedChats.refresh();
    });
  }

  var delete = false.obs;

  menuValidationForDeleteIcon() async {
    var selected = archivedChats.where((p0) => selectedChats.contains(p0.jid));
    for (var item in selected) {
      var isMember = await Mirrorfly.isMemberOfGroup(item.jid.checkNull(), null);
      if ((item.getChatType() == Constants.typeGroupChat) && isMember!) {
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
    Mirrorfly.updateChatMuteStatus(selectedChats[index], true);
    var chatIndex = archivedChats.indexWhere((element) =>
    selectedChats[index] == element.jid); //selectedChatsPosition[index];
    archivedChats[chatIndex].isMuted = (true);
  }

  _itemUnMute(int index) {
    var chatIndex = archivedChats.indexWhere((element) =>
    selectedChats[index] == element.jid); //selectedChatsPosition[index];
    archivedChats[chatIndex].isMuted = (false);
    Mirrorfly.updateChatMuteStatus(selectedChats[index], false);
  }

  deleteChats() {
    String? profile = '';
    profile = archivedChats
        .firstWhere((element) => selectedChats.first == element.jid)
        .profileName;
    Helper.showAlert(
        title: selectedChats.length == 1
            ? "Delete chat with $profile?"
            : "Delete ${selectedChats.length} selected chats?",
        actions: [
          TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text("NO")),
          TextButton(
              onPressed: () {
                Get.back();
                if (selectedChats.length == 1) {
                  _itemDelete(0);
                } else {
                  itemsDelete();
                }
              },
              child: const Text("YES")),
        ],
        message: '');
  }

  _itemDelete(int index) {
    var chatIndex = archivedChats.indexWhere((element) =>
        selectedChats[index] == element.jid); //selectedChatsPosition[index];
    archivedChats.removeAt(chatIndex);
    Mirrorfly.deleteRecentChat(selectedChats[index]);
    //Mirrorfly.updateArchiveUnArchiveChat(selectedChats[index], false);
    clearAllChatSelection();
  }

  itemsDelete() {
    // debugPrint('selectedChatsPosition : ${selectedChatsPosition.join(',')}');
    Mirrorfly.deleteRecentChats(selectedChats);
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
      var index = archivedChats.indexWhere((element) =>
          element.jid == jid); // { it.jid ?: Constants.EMPTY_STRING == jid }
      if (!index.isNegative) {
        var recent = await getRecentChatOfJid(jid);
        if (recent != null) {
          archivedChats[index] = recent;
        }
      }
    }
  }

  void userDeletedHisProfile(String jid) {
    userUpdatedHisProfile(jid);
    updateProfile(jid);
  }
  var profile_ = Profile().obs;
  void getProfileDetail(context, RecentChatData chatItem, int index) {
    getProfileDetails(chatItem.jid.checkNull()).then((value) {
      profile_(value);
      debugPrint("dashboard controller profile update received");
      showQuickProfilePopup(
          context: context,
          // chatItem: chatItem,
          chatTap: () {
            Get.back();
            toChatPage(chatItem.jid.checkNull());
          },
          callTap: () {},
          videoTap: () {},
          infoTap: () {
            Get.back();
            infoPage(value);
          },
          profile: profile_);
    });
  }
  void updateProfile(String jid){
    if(profile_.value.jid != null && profile_.value.jid.toString()==jid.toString()) {
      getProfileDetails(jid).then((value) {
        debugPrint("get profile detail archived $value");
        profile_(value);
      });
    }
  }
  infoPage(Profile profile) {
    if (profile.isGroupProfile ?? false) {
      Get.toNamed(Routes.groupInfo, arguments: profile)?.then((value) {
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
      Get.toNamed(Routes.chatInfo, arguments: profile)?.then((value) {});
    }
  }
}
