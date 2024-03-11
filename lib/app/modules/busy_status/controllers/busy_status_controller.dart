import 'dart:convert';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../../common/constants.dart';
import '../../../data/apputils.dart';
import '../../../data/helper.dart';
import '../../settings/views/chat_settings/chat_settings_controller.dart';

class BusyStatusController extends FullLifeCycleController with FullLifeCycleMixin {
  final busyStatus = "".obs;
  var busyStatusList = List<StatusData>.empty(growable: true).obs;
  var selectedStatus = "".obs;
  var loading = false.obs;

  var addStatusController = TextEditingController();
  FocusNode focusNode = FocusNode();
  var showEmoji = false.obs;
  var count = 139.obs;

  onChanged() {
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
    if(Get.arguments!=null) {
      selectedStatus.value = Get.arguments['status'];
      addStatusController.text = selectedStatus.value;
    }
    onChanged();
    getMyBusyStatus();
    getMyBusyStatusList();
  }

  void getMyBusyStatus() {
    Mirrorfly.getMyBusyStatus().then((value) {
      var userBusyStatus = json.decode(value);
      debugPrint("Busy Status ${userBusyStatus["status"]}");
      busyStatus(userBusyStatus["status"]);
    });
  }

  void getMyBusyStatusList() {
    loading.value = true;
    Mirrorfly.getBusyStatusList().then((value) {
      debugPrint("status list $value");
      loading.value = false;
      if (value != null) {
        busyStatusList(statusDataFromJson(value));
        busyStatusList.refresh();
      }
    }).catchError((onError) {
      loading.value = false;
    });
  }

  void updateBusyStatus(int position, String status) {
    for (var statusItem in busyStatusList) {
      if (statusItem.status == status) {
        statusItem.isCurrentStatus = true;
        busyStatus(statusItem.status);
      } else {
        statusItem.isCurrentStatus = false;
      }
    }
    busyStatusList.refresh();

    setCurrentStatus(status);
  }

  void deleteBusyStatus(StatusData item) {

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
            busyDeleteConfirmation(item);
          },
        ),
      ]);
    }
  }

  insertBusyStatus(String newBusyStatus) {
    for (var statusItem in busyStatusList) {
      if (statusItem.status == newBusyStatus) {
        statusItem.isCurrentStatus = true;
        busyStatus(statusItem.status);
        busyStatusList.refresh();
        setCurrentStatus(newBusyStatus);
        return;
      }
    }

    Mirrorfly.insertBusyStatus(busyStatus: newBusyStatus).then((value) {
      busyStatus(newBusyStatus);
      setCurrentStatus(newBusyStatus);
    });
  }

  validateAndFinish() async {
    if (addStatusController.text.trim().isNotEmpty) {
      //FLUTTER-567
      // if (await AppUtils.isNetConnected()) {
        Get.back(result: addStatusController.text.trim().toString());
      // } else {
      //   toToast(Constants.noInternetConnection);
      //   Get.back();
      // }
    } else {
      toToast("Status cannot be empty");
    }
  }

  void setCurrentStatus(String status) {
    Mirrorfly.setMyBusyStatus(busyStatus: status, flyCallBack: (FlyResponse response) {
      debugPrint("status value $response");
      var settingController = Get.find<ChatSettingsController>();
      settingController.busyStatus(status);
      getMyBusyStatusList();
    });
  }

  void busyDeleteConfirmation(StatusData item) {
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
              Helper.showLoading(message: "Deleting Busy Status");
              Mirrorfly.deleteBusyStatus(id:
                  item.id!, status: item.status!, isCurrentStatus: item.isCurrentStatus!)
                  .then((value) {
                    busyStatusList.remove(item);
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

  void showHideEmoji(BuildContext context) {
    if (!showEmoji.value) {
      focusNode.unfocus();
    }else{
      focusNode.requestFocus();
      return;
    }
    Future.delayed(const Duration(milliseconds: 100), () {
      showEmoji(!showEmoji.value);
    });
  }

  @override
  void onHidden() {

  }
}
