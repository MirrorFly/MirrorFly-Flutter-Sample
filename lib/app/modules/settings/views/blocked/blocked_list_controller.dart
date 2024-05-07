
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/extensions/extensions.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import '../../../../data/apputils.dart';


class BlockedListController extends GetxController {
  final _blockedUsers = <ProfileDetails>[].obs;
  set blockedUsers(value) => _blockedUsers.value = value;
  List<ProfileDetails> get blockedUsers => _blockedUsers;

  @override
  void onInit(){
    super.onInit();
    getUsersIBlocked();
  }

  getUsersIBlocked([bool? server]) async {
    Mirrorfly.getUsersIBlocked(fetchFromServer: server ?? await AppUtils.isNetConnected(), flyCallBack: (FlyResponse response) {
      if(response.isSuccess && response.hasData){
        LogMessage.d("getUsersIBlocked", response.toString());
        var list = profileFromJson(response.data);
        list.sort((a, b) => getMemberName(a).checkNull().toString().toLowerCase().compareTo(getMemberName(b).checkNull().toString().toLowerCase()));
        _blockedUsers(list);
      }else{
        _blockedUsers.clear();
      }
    });
  }
  void userUpdatedHisProfile(String jid) {
    if (jid.isNotEmpty) {
       //This function is not working in UI kit so commented
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
          _blockedUsers.refresh();
        }
      });
    }

  }
  unBlock(ProfileDetails item){
    Helper.showAlert(message: "Unblock ${getMemberName(item)}?", actions: [
      TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text("NO",style: TextStyle(color: buttonBgColor))),
      TextButton(
          onPressed: () async {
            if(await AppUtils.isNetConnected()) {
              Get.back();
              Helper.progressLoading();
              Mirrorfly.unblockUser(userJid: item.jid.checkNull(), flyCallBack: (FlyResponse response) {
                Helper.hideLoading();
                if(response.isSuccess) {
                  toToast("${getMemberName(item)} has been Unblocked");
                  getUsersIBlocked(false);
                }
              },);
            }else{
              toToast(Constants.noInternetConnection);
            }

          },
          child: const Text("YES",style: TextStyle(color: buttonBgColor))),
    ]);
  }

  void userDeletedHisProfile(String jid) {
    userUpdatedHisProfile(jid);
  }
}