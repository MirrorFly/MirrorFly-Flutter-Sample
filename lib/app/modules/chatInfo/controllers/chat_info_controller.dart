import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/common/extensions.dart';
import 'package:mirror_fly_demo/app/modules/dashboard/controllers/dashboard_controller.dart';
import '../../../common/constants.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';
import '../../../routes/app_pages.dart';

class ChatInfoController extends GetxController {
  var profile_ = ProfileDetails().obs;
  ProfileDetails get profile => profile_.value;
  var mute = false.obs;
  var nameController = TextEditingController();

  ScrollController scrollController = ScrollController();

  var silverBarHeight = 20.0;
  final _isSliverAppBarExpanded = true.obs;
  set isSliverAppBarExpanded(value) => _isSliverAppBarExpanded.value = value;
  bool get isSliverAppBarExpanded => _isSliverAppBarExpanded.value;

  final muteable = false.obs;
  var userPresenceStatus = ''.obs;

  @override
  void onInit() {
    super.onInit();
    profile_((Get.arguments as ProfileDetails));
    mute(profile.isMuted!);
    scrollController.addListener(_scrollListener);
    nameController.text = profile.nickName.checkNull();
    muteAble();
    getUserLastSeen();
  }

  muteAble() async {
    muteable(await Mirrorfly.isChatUnArchived(jid: profile.jid.checkNull()));
  }

  _scrollListener() {
    if (scrollController.hasClients) {
      _isSliverAppBarExpanded(
          scrollController.offset < (silverBarHeight - kToolbarHeight));
    }
  }

  void userUpdatedHisProfile(jid) {
    if (jid.isNotEmpty && jid == profile.jid) {
      getProfileDetails(jid).then((value) {
        profile_(value);
        mute(profile.isMuted!);
        nameController.text = profile.nickName.checkNull();
      });
    }

  }

  onToggleChange(bool value) async {
    if(muteable.value) {
      mirrorFlyLog("change", value.toString());
      mute(value);
      Mirrorfly.updateChatMuteStatus(jid: profile.jid.checkNull(), muteStatus: value);
      notifyDashboardUI();
    }
  }

  getUserLastSeen(){
    if(!profile.isBlockedMe.checkNull() || !profile.isAdminBlocked.checkNull()) {
      Mirrorfly.getUserLastSeenTime(jid: profile.jid.toString(), flyCallBack: (FlyResponse response) {
        if(response.isSuccess && response.hasData) {
          LogMessage.d("getUserLastSeenTime", response);
          var lastSeen = convertSecondToLastSeen(response.data);
          userPresenceStatus(lastSeen.toString());
        }else{
          userPresenceStatus("");
        }
      });
    }else{
      userPresenceStatus("");
    }
  }


  void userCameOnline(jid) {
    debugPrint("userCameOnline : $jid");
    if(jid.isNotEmpty && profile.jid == jid && !profile.isGroupProfile.checkNull()) {
      debugPrint("userCameOnline jid match: $jid");
      Future.delayed(const Duration(milliseconds: 3000),(){
        getUserLastSeen();
      });
    }
  }

  void userWentOffline(jid) {
    if(jid.isNotEmpty && profile.jid==jid && !profile.isGroupProfile.checkNull()) {
      debugPrint("userWentOffline : $jid");
      Future.delayed(const Duration(milliseconds: 3000),(){
        getUserLastSeen();
      });
    }
  }

  void networkConnected() {
    mirrorFlyLog("networkConnected", 'true');
    Future.delayed(const Duration(milliseconds: 2000), () {
      getUserLastSeen();
    });
  }

  void networkDisconnected() {
    mirrorFlyLog('networkDisconnected', 'false');
    getUserLastSeen();
  }

  reportChatOrUser() {
    Future.delayed(const Duration(milliseconds: 100), () {
      Helper.showAlert(
          title: "Report ${profile.name}?",
          message:
              "The last 5 messages from this contact will be forwarded to admin. This Contact will not be notified.",
          actions: [
            TextButton(
                onPressed: () {
                  Get.back();
                  // Helper.showLoading(message: "Reporting User");
                  Mirrorfly
                      .reportUserOrMessages(jid: profile.jid!, type: "chat", flyCallBack: (FlyResponse response) {
                    if(response.isSuccess){
                      toToast("Report sent");
                    }else{
                      toToast("There are no messages available");
                    }
                  });
                },
                child: const Text("REPORT",style: TextStyle(color: buttonBgColor))),
            TextButton(
                onPressed: () {
                  Get.back();
                },
                child: const Text("CANCEL",style: TextStyle(color: buttonBgColor))),
          ]);
    });
  }

  gotoViewAllMedia(){
    debugPrint("to Media Page==>${profile.name} jid==>${profile.jid} isgroup==>${profile.isGroupProfile ?? false}");
    Get.toNamed(Routes.viewMedia,arguments: {"name":profile.name,"jid":profile.jid,"isgroup":profile.isGroupProfile ?? false});
  }

  void onContactSyncComplete(bool result) {
    userUpdatedHisProfile(profile.jid);
  }

  void userDeletedHisProfile(String jid) {
    userUpdatedHisProfile(jid);
  }

  void unblockedThisUser(String jid) {
    userUpdatedHisProfile(jid);
  }

  void userBlockedMe(String jid) {
    userUpdatedHisProfile(jid);
  }

  void notifyDashboardUI(){
    if(Get.isRegistered<DashboardController>()){
      Get.find<DashboardController>().chatMuteChangesNotifyUI(profile.jid.checkNull());
    }
  }
}
