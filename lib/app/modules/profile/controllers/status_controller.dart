import 'dart:convert';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import '../../../extensions/extensions.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import '../../../app_style_config.dart';
import '../../../common/app_localizations.dart';
import '../../../common/constants.dart';
import '../../../data/utils.dart';

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
        count((139 - addStatusController.text.characters.length));
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
    selectedStatus.value = NavUtils.arguments['status'];
    addStatusController.text= selectedStatus.value;
    // onChanged();
    getStatusList();
    onChanged();

    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        showEmoji(false);
      }
    });
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
      DialogUtils.showLoading(dialogStyle: AppStyleConfig.dialogStyle);
      Mirrorfly.setMyProfileStatus(status: statusText!, statusId: statusId!,flyCallBack: (response){
        if(response.isSuccess) {
          LogMessage.d("setMyProfileStatus flutter", response.toString());
          selectedStatus.value = statusText;
          addStatusController.text = statusText;
          onChanged();
          var data = json.decode(response.data);
          toToast(getTranslated("statusUpdated"));
          if(data['status']) {
            getStatusList();
          }
        }else{
          toToast(response.exception!.message.toString());
        }
        DialogUtils.hideLoading();
      }).then((value){

      }).catchError((er){
        toToast(er);
      });
    }else{
      toToast(getTranslated("noInternetConnection"));
    }
  }

  insertStatus() async{
    if(await AppUtils.isNetConnected()){
      DialogUtils.showLoading(dialogStyle: AppStyleConfig.dialogStyle);
        Mirrorfly.insertNewProfileStatus(status: addStatusController.text.trim().toString())
            .then((value) {
          selectedStatus.value = addStatusController.text.trim().toString();
          addStatusController.text = addStatusController.text.trim().toString();
          // var data = json.decode(value.toString());
          toToast(getTranslated("statusUpdated"));
          DialogUtils.hideLoading();
          if (value.checkNull()) {
            getStatusList();
          }
        }).catchError((er) {
          toToast(er);
        });
    }else{
      toToast(getTranslated("noInternetConnection"));
    }
  }

  validateAndFinish()async{
    if(addStatusController.text.trim().isNotEmpty) {
      if(await AppUtils.isNetConnected()) {
        NavUtils.back(result: addStatusController.text
            .trim().toString());
      }else{
        toToast(getTranslated("noInternetConnection"));
        NavUtils.back();
      }
    }else{
      toToast(getTranslated("statusCantEmpty"));
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
      DialogUtils.showButtonAlert(actions: [
        ListTile(
          contentPadding: const EdgeInsets.only(left: 10),
          title: Text(getTranslated("delete"),
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal)),

          onTap: () {
            NavUtils.back();
            statusDeleteConfirmation(item);
          },
        ),
      ]);
    }
  }

  void statusDeleteConfirmation(StatusData item) {
    DialogUtils.showAlert(dialogStyle: AppStyleConfig.dialogStyle,message: getTranslated("deleteStatus"), actions: [
      TextButton(style: AppStyleConfig.dialogStyle.buttonStyle,
          onPressed: () {
            NavUtils.back();
          },
          child: Text(getTranslated("no"), )),
      TextButton(style: AppStyleConfig.dialogStyle.buttonStyle,
          onPressed: () async {
            if (await AppUtils.isNetConnected()) {
              NavUtils.back();
              DialogUtils.showLoading(message: getTranslated("deletingStatus"),dialogStyle: AppStyleConfig.dialogStyle);
              Mirrorfly.deleteProfileStatus(id: item.id!, status: item.status!, isCurrentStatus: item.isCurrentStatus!)
                  .then((value) {
                statusList.remove(item);
                DialogUtils.hideLoading();
              }).catchError((error) {
                DialogUtils.hideLoading();
                toToast(getTranslated("unableDeleteBusyStatus"));
              });
            } else {
              toToast(getTranslated("noInternetConnection"));
            }
          },
          child: Text(getTranslated("yes"), )),
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
      NavUtils.back(result: result);
    }else {
      NavUtils.back();
    }
  }
}