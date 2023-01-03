import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:flysdk/flysdk.dart';

import '../../../../data/apputils.dart';


class BlockedListController extends GetxController {
  final _blockedUsers = <Member>[].obs;
  set blockedUsers(value) => _blockedUsers.value = value;
  List<Member> get blockedUsers => _blockedUsers;

  @override
  void onInit(){
    super.onInit();
    getUsersIBlocked(false);
  }

  getUsersIBlocked(bool server){
    FlyChat.getUsersIBlocked(server).then((value){
      if(value!=null && value != ""){
        var list = memberFromJson(value);
        _blockedUsers(list);
      }else{
        _blockedUsers.clear();
      }
    });
  }
  unBlock(Member item){
    Helper.showAlert(message: "Unblock ${item.name}?", actions: [
      TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text("CANCEL")),
      TextButton(
          onPressed: () async {
            if(await AppUtils.isNetConnected()) {
              Get.back();
              Helper.progressLoading();
              FlyChat.unblockUser(item.jid.checkNull()).then((value) {
                Helper.hideLoading();
                if(value!=null && value) {
                  toToast("${item.name} Unblocked");
                  getUsersIBlocked(false);
                }
              }).catchError((error) {
                Helper.hideLoading();
                debugPrint(error);
              });
            }else{
              toToast(Constants.noInternetConnection);
            }

          },
          child: const Text("UNBLOCK")),
    ]);
  }
}