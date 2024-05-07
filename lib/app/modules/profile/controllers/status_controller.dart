import 'dart:convert';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/extensions/extensions.dart';

import '../../../common/constants.dart';
import '../../../data/apputils.dart';
import '../../../data/helper.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

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

  onEmojiBackPressed(){
    var text = addStatusController.text;
    var cursorPosition = addStatusController.selection.base.offset;

    // If cursor is not set, then place it at the end of the textfield
    if (cursorPosition < 0) {
      addStatusController.selection = TextSelection(
        baseOffset: addStatusController.text.length,
        extentOffset: addStatusController.text.length,
      );
      cursorPosition = addStatusController.selection.base.offset;
    }

    if (cursorPosition >= 0) {
      final selection = addStatusController.value.selection;
      final newTextBeforeCursor =
      selection.textBefore(text).characters.skipLast(1).toString();
      LogMessage.d("newTextBeforeCursor", newTextBeforeCursor);
      addStatusController
        ..text = newTextBeforeCursor + selection.textAfter(text)
        ..selection = TextSelection.fromPosition(
            TextPosition(offset: newTextBeforeCursor.length));
    }
    count((139 - addStatusController.text.characters.length));
  }

  onEmojiSelected(Emoji emoji){
    if(addStatusController.text.characters.length < 139){
      final controller = addStatusController;
      final text = controller.text;
      final selection = controller.selection;
      final cursorPosition = controller.selection.base.offset;

      if (cursorPosition < 0) {
        controller.text += emoji.emoji;
        // widget.onEmojiSelected?.call(category, emoji);
        return;
      }

      final newText =
      text.replaceRange(selection.start, selection.end, emoji.emoji);
      final emojiLength = emoji.emoji.length;
      controller
        ..text = newText
        ..selection = selection.copyWith(
          baseOffset: selection.start + emojiLength,
          extentOffset: selection.start + emojiLength,
        );
    }
    count((139 - addStatusController.text.characters.length));
  }

  @override
  void onInit() {
    super.onInit();
    selectedStatus.value = Get.arguments['status'];
    addStatusController.text= selectedStatus.value;
    // onChanged();
    getStatusList();
    onChanged();
  }
  getStatusList(){
    loading.value=true;
    Mirrorfly.getProfileStatusList().then((value){
      LogMessage.d("myStatusList", value);
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
      Mirrorfly.setMyProfileStatus(status: statusText!, statusId: statusId!,flyCallBack: (response){
        if(response.isSuccess) {
          LogMessage.d("setMyProfileStatus flutter", response.toString());
          selectedStatus.value = statusText;
          addStatusController.text = statusText;
          var data = json.decode(response.data);
          toToast('Status update successfully');
          if(data['status']) {
            getStatusList();
          }
        }else{
          toToast(response.exception!.message.toString());
        }
        Helper.hideLoading();
      }).then((value){

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
        Mirrorfly.insertNewProfileStatus(status: addStatusController.text.trim().toString())
            .then((value) {
          selectedStatus.value = addStatusController.text.trim().toString();
          addStatusController.text = addStatusController.text.trim().toString();
          // var data = json.decode(value.toString());
          toToast('Status update successfully');
          Helper.hideLoading();
          if (value.checkNull()) {
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
          child: const Text("No",style: TextStyle(color: buttonBgColor))),
      TextButton(
          onPressed: () async {
            if (await AppUtils.isNetConnected()) {
              Get.back();
              Helper.showLoading(message: "Deleting Status");
              Mirrorfly.deleteProfileStatus(id: item.id!, status: item.status!, isCurrentStatus: item.isCurrentStatus!)
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
          child: const Text("Yes",style: TextStyle(color: buttonBgColor))),
    ]);
  }

  @override
  void onHidden() {

  }

  onBackPressed([String? result]) {
    debugPrint("result $result");
    showEmoji(false);
    addStatusController.text = selectedStatus.value;
    if(result != null){
      Get.back(result: result);
    }else {
      Get.back();
    }
  }
}