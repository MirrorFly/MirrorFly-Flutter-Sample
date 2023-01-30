import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../common/constants.dart';
import '../../../data/apputils.dart';
import '../../../data/helper.dart';
import 'package:flysdk/flysdk.dart';

class StatusListController extends GetxController{
  var statusList = List<StatusData>.empty(growable: true).obs;
  var selectedStatus = "".obs;
  var loading =false.obs;

  //add new status
  var addStatusController = TextEditingController();
  FocusNode focusNode = FocusNode();
  var showEmoji = false.obs;
  var count= 121.obs;

  onChanged(){
    count.value = (121 - addStatusController.text.length);
  }

  @override
  void onInit() {
    super.onInit();
    selectedStatus.value = Get.arguments['status'];
    addStatusController.text=selectedStatus.value;
    getStatusList();
    onChanged();
  }
  getStatusList(){
    loading.value=true;
    FlyChat.getProfileStatusList().then((value){
      loading.value=false;
      if(value!=null){
        statusList.value = statusDataFromJson(value);
        statusList.refresh();

      }
    }).catchError((onError){
      loading.value=false;
    });
  }

  updateStatus([String? text]) async {
    if(await AppUtils.isNetConnected()) {
      Helper.showLoading();
      FlyChat.setMyProfileStatus(text ?? addStatusController.text.trim().toString()).then((value){
        selectedStatus.value=text ?? addStatusController.text.trim().toString();
        addStatusController.text=text ?? addStatusController.text.trim().toString();
        var data = json.decode(value.toString());
        toToast(data['message'].toString());
        Helper.hideLoading();
        if(data['status']) {
          getStatusList();
        }
      }).catchError((er){
        toToast(er);
      });
    }else{
      toToast(Constants.noInternetConnection);
    }
  }

  validateAndFinish()async{
    if(addStatusController.text.trim().isNotEmpty) {
      if(await AppUtils.isNetConnected()) {
        Get.back(result: addStatusController.text
            .trim().toString());
      }else{
        toToast(Constants.noInternetConnection);
        Get.back();
      }
    }else{
      toToast("Status cannot be empty");
    }
  }
}