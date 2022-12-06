import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';

import '../../../common/constants.dart';
import 'package:flysdk/flysdk.dart';
import '../../../routes/app_pages.dart';

class ChatInfoController extends GetxController {
  //TODO: Implement ChatInfoController
  var profile_ = Profile().obs;
  Profile get profile => profile_.value;
  var mute = false.obs;
  var nameController = TextEditingController();

  ScrollController scrollController = ScrollController();

  var silverBarHeight = 20.0;
  final _isSliverAppBarExpanded = true.obs;
  set isSliverAppBarExpanded(value) => _isSliverAppBarExpanded.value = value;
  bool get isSliverAppBarExpanded => _isSliverAppBarExpanded.value;

  final muteable = false.obs;

  @override
  void onInit() {
    super.onInit();
    profile_((Get.arguments as Profile));
    mute(profile.isMuted!);
    scrollController.addListener(_scrollListener);
    nameController.text = profile.nickName.checkNull();
    muteAble();
  }

  muteAble() async {
    muteable(await FlyChat.isUserUnArchived(profile.jid.checkNull()));
  }

  _scrollListener() {
    if (scrollController.hasClients) {
      _isSliverAppBarExpanded(
          scrollController.offset < (silverBarHeight - kToolbarHeight));
    }
  }

  onToggleChange(bool value) {
    if(muteable.value) {
      mirrorFlyLog("change", value.toString());
      mute(value);
      FlyChat.updateChatMuteStatus(profile.jid.checkNull(), value);
    }
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
                  Helper.showLoading(message: "Reporting User");
                  FlyChat
                      .reportUserOrMessages(profile.jid!, "chat", "")
                      .then((value) {
                    Helper.hideLoading();
                    Future.delayed(const Duration(milliseconds: 500), () {
                      toToast("Report Success");
                    });

                    // debugPrint(value.toString());
                  }).catchError((onError) {
                    debugPrint(onError.toString());
                  });
                },
                child: const Text("REPORT")),
            TextButton(
                onPressed: () {
                  Get.back();
                },
                child: const Text("CANCEL")),
          ]);
    });
  }

  gotoViewAllMedia(){
    Get.toNamed(Routes.viewMedia,arguments: {"name":profile.name,"jid":profile.jid,"isgroup":profile.isGroupProfile});
  }
}
