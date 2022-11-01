import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/model/statusModel.dart';

import '../../../common/constants.dart';
import '../../../data/helper.dart';
import '../../../nativecall/platformRepo.dart';

class StatusListController extends GetxController{
  var statuslist = List<StatusData>.empty(growable: true).obs;
  var selectedStatus = "".obs;
  var loading =false.obs;

  //add new status
  var addstatuscontroller = TextEditingController();
  FocusNode focusNode = FocusNode();
  var showEmoji = false.obs;
  var count= 121.obs;

  onChanged(){
    count.value = (121 - addstatuscontroller.text.length);
    //addstatuscontroller.selection = TextSelection.collapsed(offset: addstatuscontroller.text.length);
  }

  @override
  void onInit() {
    super.onInit();
    selectedStatus.value = Get.arguments['status'];
    addstatuscontroller.text=selectedStatus.value;
    getStatusList();
    onChanged();
  }
  getStatusList(){
    loading.value=true;
    PlatformRepo().getStatusList().then((value){
      loading.value=false;
      if(value!=null){
        statuslist.value = statusDataFromJson(value);
        statuslist.refresh();
        /*statuslist.forEach((element) {
          if (element.status==addstatuscontroller.text.toString()) {
            selectedStatus.value = element.status;
          }
        });*/
      }
    }).catchError((onError){
      loading.value=false;
    });
  }

  updateStatus([String? text]){
    Helper.showLoading();
    PlatformRepo().updateProfileStatus(text ?? addstatuscontroller.text.trim().toString()).then((value){
      selectedStatus.value=text ?? addstatuscontroller.text.trim().toString();
      addstatuscontroller.text=text ?? addstatuscontroller.text.trim().toString();
      var data = json.decode(value.toString());
      toToast(data['message'].toString());
      Helper.hideLoading();
      if(data['status']) {
        getStatusList();
      }
    }).catchError((er){
      toToast(er);
    });
  }
}