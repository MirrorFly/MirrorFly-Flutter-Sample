import 'package:flysdk/flysdk.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/modules/dashboard/controllers/dashboard_controller.dart';

import '../../data/apputils.dart';
import '../../data/helper.dart';
import '../../routes/app_pages.dart';

class ArchivedChatListController extends GetxController {
  DashboardController dashboardController = Get.find<DashboardController>();
  RxList<RecentChatData> archivedChats =
      Get.find<DashboardController>().archivedChats;

  //RxList<RecentChatData> archivedChats = <RecentChatData>[].obs;

  /*@override
  void onInit(){
    super.onInit();
    archivedChats(dashboardController.archivedChats);
  }*/

  var selected = false.obs;
  var selectedChats = <String>[].obs;

  isSelected(int index) => selectedChats.contains(archivedChats[index].jid);

  selectOrRemoveChatfromList(int index) {
    if (selected.isTrue) {
      if (selectedChats.contains(archivedChats[index].jid)) {
        selectedChats.remove(archivedChats[index].jid.checkNull());
        //selectedChatsPosition.remove(index);
      } else {
        selectedChats.add(archivedChats[index].jid.checkNull());
        //selectedChatsPosition.add(index);
      }
    }
    if (selectedChats.isEmpty) {
      clearAllChatSelection();
    } else {
      //menuValidationForItem();
    }
  }

  clearAllChatSelection() {
    selected(false);
    selectedChats.clear();
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

  toChatPage(String jid) async {
    if (jid.isNotEmpty) {
      // Helper.progressLoading();
      await FlyChat.getProfileDetails(jid, false).then((value) {
        if (value != null) {
          Helper.hideLoading();
          var profile = profiledata(value.toString());
          Get.toNamed(Routes.chat, arguments: profile);
        }
      });
      // SessionManagement.setChatJid(jid);
      // Get.toNamed(Routes.chat);
    }
  }

  _itemUnArchive(int index) {
    FlyChat.updateArchiveUnArchiveChat(selectedChats[index], false);
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
    await FlyChat.isArchivedSettingsEnabled().then((value){
      if(value.checkNull()){
        var archiveIndex = archivedChats.indexWhere((element) => recent.jid==element.jid);
        if(!archiveIndex.isNegative){
          archivedChats.removeAt(archiveIndex);
          archivedChats.insert(0, recent);
        }else{
          archivedChats.insert(0,recent);
        }
      }else{
        var archiveIndex = archivedChats.indexWhere((element) => recent.jid==element.jid);
        if(!archiveIndex.isNegative){
          archivedChats.removeAt(archiveIndex);
          var lastPinnedChat = dashboardController.recentChats.lastIndexWhere((element) =>
          element.isChatPinned!);
          var nxtIndex = lastPinnedChat.isNegative ? 0 : (lastPinnedChat + 1);
          mirrorFlyLog("lastPinnedChat", lastPinnedChat.toString());
          dashboardController.recentChats.insert(nxtIndex, recent);
        }
      }
    });

  }
}
