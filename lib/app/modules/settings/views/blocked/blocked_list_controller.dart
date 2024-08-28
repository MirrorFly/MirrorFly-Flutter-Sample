
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../common/constants.dart';
import '../../../../data/helper.dart';
import '../../../../extensions/extensions.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import '../../../../app_style_config.dart';
import '../../../../common/app_localizations.dart';
import '../../../../data/utils.dart';


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
    DialogUtils.showAlert(dialogStyle: AppStyleConfig.dialogStyle,message: "Unblock ${getMemberName(item)}?", actions: [
      TextButton(style: AppStyleConfig.dialogStyle.buttonStyle,
          onPressed: () {
            NavUtils.back();
          },
          child: const Text("NO", )),
      TextButton(style: AppStyleConfig.dialogStyle.buttonStyle,
          onPressed: () async {
            if(await AppUtils.isNetConnected()) {
              NavUtils.back();
              DialogUtils.progressLoading();
              Mirrorfly.unblockUser(userJid: item.jid.checkNull(), flyCallBack: (FlyResponse response) {
                DialogUtils.hideLoading();
                if(response.isSuccess) {
                  toToast("${getMemberName(item)} has been Unblocked");
                  getUsersIBlocked(false);
                }
              },);
            }else{
              toToast(getTranslated("noInternetConnection"));
            }

          },
          child: const Text("YES", )),
    ]);
  }

  void userDeletedHisProfile(String jid) {
    userUpdatedHisProfile(jid);
  }
}