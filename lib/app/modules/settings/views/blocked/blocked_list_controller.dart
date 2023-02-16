
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
        list.sort((a, b) => a.name.checkNull().toString().toLowerCase().compareTo(b.name.checkNull().toString().toLowerCase()));
        _blockedUsers(list);
      }else{
        _blockedUsers.clear();
      }
    });
  }
  void userUpdatedHisProfile(jid) {
    if (jid.isNotEmpty) {
      /* //This function is not working in UI kit so commented
      getProfileDetails(jid).then((value) {
        var index = _blockedUsers.indexWhere((element) => element.jid == jid);
        if(!index.isNegative) {
          _blockedUsers[index].name = value.name;
          _blockedUsers[index].nickName = value.nickName;
          _blockedUsers[index].email = value.email;
          _blockedUsers[index].image = value.image;
          _blockedUsers[index].isBlocked = value.isBlocked;
          _blockedUsers[index].mobileNumber = value.mobileNumber;
          _blockedUsers[index].status = value.status;
        }
      });*/

    }

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
                  toToast("${item.name} has been Unblocked");
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