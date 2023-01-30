import 'dart:convert';

import 'package:flysdk/flysdk.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../../common/constants.dart';
import '../../../data/apputils.dart';
import '../../settings/views/chat_settings/chat_settings_controller.dart';


class BusyStatusController extends GetxController {
  final busyStatus = "".obs;
  var busyStatusList = List<StatusData>.empty(growable: true).obs;
  var selectedStatus = "".obs;
  var loading =false.obs;


  var addStatusController = TextEditingController();
  FocusNode focusNode = FocusNode();
  var showEmoji = false.obs;
  var count= 130.obs;


  onChanged(){
    count.value = (130 - addStatusController.text.length);
  }


  @override
  void onInit() {
    super.onInit();
    getMyBusyStatus();
    getMyBusyStatusList();
  }

  void getMyBusyStatus() {
    FlyChat.getMyBusyStatus().then((value) {
      var userBusyStatus = json.decode(value);
      debugPrint("Busy Status ${userBusyStatus["status"]}");
      busyStatus(userBusyStatus["status"]);
    });
  }

  void getMyBusyStatusList() {
    loading.value = true;
    FlyChat.getBusyStatusList().then((value) {
      debugPrint("status list $value");
      loading.value=false;
      if(value != null){
        busyStatusList(statusDataFromJson(value));
        busyStatusList.refresh();
      }
    }).catchError((onError){
      loading.value=false;
    });
  }

  void updateBusyStatus(int position, String status) {
   for (var statusItem in busyStatusList) {
     if(statusItem.status == status){
       statusItem.isCurrentStatus = true;
       busyStatus(statusItem.status);
     }else{
       statusItem.isCurrentStatus = false;
     }
   }
   busyStatusList.refresh();

   setCurrentStatus(status);

  }

  void deleteBusyStatus(StatusData item) {

  }

  insertBusyStatus(String newBusyStatus){
    for (var statusItem in busyStatusList) {
      if(statusItem.status == newBusyStatus){
        statusItem.isCurrentStatus = true;
        busyStatus(statusItem.status);
        busyStatusList.refresh();
        setCurrentStatus(newBusyStatus);
        return;
      }
    }

    FlyChat.insertBusyStatus(newBusyStatus).then((value) {
      setCurrentStatus(newBusyStatus);
      getMyBusyStatusList();
    });
  }

  validateAndFinish() async{
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

  void setCurrentStatus(String status) {
    FlyChat.setMyBusyStatus(status).then((value) {
      debugPrint("status value $value");
      var settingController = Get.find<ChatSettingsController>();
      settingController.busyStatus(status);
    });
  }
}
