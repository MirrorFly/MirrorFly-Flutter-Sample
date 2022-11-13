import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';

import '../../../common/constants.dart';
import '../../../model/userlistModel.dart';
import '../../../nativecall/platformRepo.dart';

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

  @override
  void onInit() {
    super.onInit();
    profile_((Get.arguments as Profile));
    mute(profile.isMuted!);
    scrollController.addListener(_scrollListener);
    nameController.text = profile.nickName.checkNull();
  }

  _scrollListener() {
    if (scrollController.hasClients) {
      _isSliverAppBarExpanded(
          scrollController.offset < (silverBarHeight - kToolbarHeight));
    }
  }

  onToggleChange(bool value) {
    Log("change", value.toString());
    mute(value);
    PlatformRepo().groupMute(profile.jid.checkNull(), value);
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
                  PlatformRepo()
                      .reportChatOrUser(profile.jid!, "chat", "")
                      .then((value) {
                    Helper.hideLoading();
                    Future.delayed(const Duration(milliseconds: 500), () {
                      toToast("Report Success");
                    });

                    debugPrint(value);
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
}
