import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';

import '../../../common/constants.dart';
import '../../../data/apputils.dart';
import '../../../data/helper.dart';
import 'package:fly_chat/flysdk.dart';

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
    count(139 - addStatusController.text.characters.length);
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
        statusList.clear();
        statusList.value = statusDataFromJson(value);
        statusList.refresh();

      }
    }).catchError((onError){
      loading.value=false;
    });
  }

  updateStatus([String? statusText, String? statusId]) async {
    debugPrint("updating item details--> $statusId");
    if(await AppUtils.isNetConnected()) {
      Helper.showLoading();
      FlyChat.setMyProfileStatus(statusText!, statusId).then((value){
        selectedStatus.value= statusText;
        addStatusController.text= statusText;
        var data = json.decode(value.toString());
        toToast('Status update successfully');
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

  insertStatus() async{
    if(await AppUtils.isNetConnected()){
      Helper.showLoading();
        FlyChat.insertNewProfileStatus(addStatusController.text.trim().toString())
            .then((value) {
          selectedStatus.value = addStatusController.text.trim().toString();
          addStatusController.text = addStatusController.text.trim().toString();
          var data = json.decode(value.toString());
          toToast('Status update successfully');
          Helper.hideLoading();
          if (data['status']) {
            getStatusList();
          }
        }).catchError((er) {
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

  void deleteStatus(StatusData item) {
    debugPrint("item delete status-->${item.isCurrentStatus}");
    debugPrint("item delete status-->${item.id}");
    debugPrint("item delete status-->${item.status}");
    if(!item.isCurrentStatus!){
      Helper.showButtonAlert(actions: [
        ListTile(
          contentPadding: const EdgeInsets.only(left: 10),
          title: const Text("Delete",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal)),

          onTap: () {
            Get.back();
            statusDeleteConfirmation(item);
          },
        ),
      ]);
    }
  }

  void statusDeleteConfirmation(StatusData item) {
    Helper.showAlert(message: "Do you want to delete the status?", actions: [
      TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text("No")),
      TextButton(
          onPressed: () async {
            if (await AppUtils.isNetConnected()) {
              Get.back();
              Helper.showLoading(message: "Deleting Status");
              FlyChat.deleteProfileStatus(item.id!, item.status!, item.isCurrentStatus!)
                  .then((value) {
                statusList.remove(item);
                Helper.hideLoading();
              }).catchError((error) {
                Helper.hideLoading();
                toToast("Unable to delete the Busy Status");
              });
            } else {
              toToast(Constants.noInternetConnection);
            }
          },
          child: const Text("Yes")),
    ]);
  }
}