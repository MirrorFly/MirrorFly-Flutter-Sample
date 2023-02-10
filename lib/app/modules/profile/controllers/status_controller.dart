import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';

import '../../../common/constants.dart';
import '../../../data/apputils.dart';
import '../../../data/helper.dart';
import 'package:flysdk/flysdk.dart';

class StatusListController extends FullLifeCycleController with FullLifeCycleMixin{
  var statusList = List<StatusData>.empty(growable: true).obs;
  var selectedStatus = "".obs;
  var loading =false.obs;

  //add new status
  var addStatusController = TextEditingController();
  FocusNode focusNode = FocusNode();
  var showEmoji = false.obs;
  var count= 139.obs;

  onChanged(){
    count(139 - addStatusController.text.length);
  }

  @override
  void onInit() {
    super.onInit();
    selectedStatus.value = Get.arguments['status'];
    addStatusController.text=selectedStatus.value;
    onChanged();
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

  @override
  void onDetached() {
  }

  @override
  void onInactive() {
  }

  @override
  void onPaused() {
  }

  @override
  void onResumed() {
    if(!KeyboardVisibilityController().isVisible) {
      if (focusNode.hasFocus) {
        focusNode.unfocus();
        Future.delayed(const Duration(milliseconds: 100), () {
          focusNode.requestFocus();
        });
      }
    }
  }
}