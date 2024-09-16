import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/app_localizations.dart';
import '../../../data/helper.dart';
import '../../../extensions/extensions.dart';
import '../../../modules/dashboard/controllers/dashboard_controller.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import '../../../app_style_config.dart';
import '../../../common/constants.dart';
import '../../../data/utils.dart';
import '../../../model/arguments.dart';
import '../../../routes/route_settings.dart';

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
  ChatInfoArguments get argument => NavUtils.arguments as ChatInfoArguments;

  @override
  void onInit(){
    super.onInit();
    getProfileDetails(argument.chatJid).then((value) {
      profile_(value);
      mute(profile.isMuted!);
      scrollController.addListener(_scrollListener);
      nameController.text = profile.nickName.checkNull();
      muteAble();
      getUserLastSeen();
    });
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
      LogMessage.d("change", value.toString());
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
    if (jid.isNotEmpty && profile.jid == jid && !profile.isGroupProfile.checkNull() && (!profile.isBlockedMe.checkNull() || !profile.isAdminBlocked.checkNull())) {
      debugPrint("userCameOnline : $jid");
      /*Future.delayed(const Duration(milliseconds: 3000), () {
        setChatStatus();
      });*/
      userPresenceStatus(getTranslated("online"));
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

  void onConnected() {
    LogMessage.d("networkConnected", 'true');
    Future.delayed(const Duration(milliseconds: 2000), () {
      getUserLastSeen();
    });
  }

  void onDisconnected() {
    LogMessage.d('networkDisconnected', 'false');
    getUserLastSeen();
  }

  reportChatOrUser() {
    Future.delayed(const Duration(milliseconds: 100), () {
      DialogUtils.showAlert(dialogStyle: AppStyleConfig.dialogStyle,
          title: getTranslated("reportUser").replaceFirst("%d", profile.getName()),
          message:getTranslated("last5Message"),
          actions: [
            TextButton(style: AppStyleConfig.dialogStyle.buttonStyle,
                onPressed: () {
                  NavUtils.back();
                  // DialogUtils.showLoading(message: "Reporting User");
                  Mirrorfly
                      .reportUserOrMessages(jid: profile.jid!, type: "chat", flyCallBack: (FlyResponse response) {
                    if(response.isSuccess){
                      toToast(getTranslated("reportSent"));
                    }else{
                      toToast(getTranslated("thereNoMessagesAvailable"));
                    }
                  });
                },
                child: Text(getTranslated("report").toUpperCase(), )),
            TextButton(style: AppStyleConfig.dialogStyle.buttonStyle,
                onPressed: () {
                  NavUtils.back();
                },
                child: Text(getTranslated("cancel").toUpperCase(), )),
          ]);
    });
  }

  gotoViewAllMedia(){
    debugPrint("to Media Page==>${profile.name} jid==>${profile.jid} isgroup==>${profile.isGroupProfile ?? false}");
    NavUtils.toNamed(Routes.viewMedia,arguments: ViewAllMediaArguments(chatJid: profile.jid.checkNull())/*{"name":profile.name,"jid":profile.jid,"isgroup":profile.isGroupProfile ?? false}*/);
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
