import 'dart:convert';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart';

import '../../../app_style_config.dart';
import '../../../common/app_localizations.dart';
import '../../../common/constants.dart';
import '../../../data/utils.dart';
import '../../settings/views/chat_settings/chat_settings_controller.dart';

class BusyStatusController extends GetxController with WidgetsBindingObserver {
  final busyStatus = "".obs;
  var busyStatusList = List<StatusData>.empty(growable: true).obs;
  var selectedStatus = "".obs;
  var loading = false.obs;

  var addStatusController = TextEditingController();
  FocusNode focusNode = FocusNode();
  var showEmoji = false.obs;
  var count = 139.obs;

  void init(String? status) {
    WidgetsBinding.instance.addObserver(this);
    if (status != null) {
      selectedStatus.value = status;
      addStatusController.text = selectedStatus.value;
    }
    onChanged();
    getMyBusyStatus();
    getMyBusyStatusList();
  }

  void close() {
    WidgetsBinding.instance.removeObserver(this);
  }

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

  void deleteBusyStatus(StatusData item, BuildContext context) {

    if(!item.isCurrentStatus!){
      DialogUtils.showButtonAlert(actions: [
        ListTile(
          contentPadding: const EdgeInsets.only(left: 10),
          title: Text(getTranslated("delete"),
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal)),

          onTap: () {
            Navigator.pop(context);
            busyDeleteConfirmation(item, context);
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

  validateAndFinish(BuildContext context) async {
    if (addStatusController.text.trim().isNotEmpty) {
      Navigator.pop(context, addStatusController.text.trim().toString());
    } else {
      toToast(getTranslated("statusNotEmpty"));
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

  void busyDeleteConfirmation(StatusData item, BuildContext context) {
    DialogUtils.showAlert(dialogStyle: AppStyleConfig.dialogStyle,message: getTranslated("deleteStatus"), actions: [
      TextButton(style: AppStyleConfig.dialogStyle.buttonStyle,
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(getTranslated("no") )),
      TextButton(style: AppStyleConfig.dialogStyle.buttonStyle,
          onPressed: () {
            AppUtils.isNetConnected().then((isConnected) {
              if (isConnected) {
                Navigator.pop(context);
                DialogUtils.showLoading(message: "Deleting Busy Status",dialogStyle: AppStyleConfig.dialogStyle);
                Mirrorfly.deleteBusyStatus(id:
                item.id!, status: item.status!, isCurrentStatus: item.isCurrentStatus!)
                    .then((value) {
                  busyStatusList.remove(item);
                  DialogUtils.hideLoading();
                }).catchError((error) {
                  DialogUtils.hideLoading();
                toToast(getTranslated("unableDeleteBusyStatus"));
                });
              } else {
              toToast(getTranslated("noInternetConnection"));
              }
            });
          },
          child: Text(getTranslated("yes"), )),
    ]);
  }

  showHideEmoji(BuildContext context){
    if (!showEmoji.value) {
      focusNode.unfocus();
      Future.delayed(const Duration(milliseconds: 500), () {
        showEmoji(!showEmoji.value);
      });
    }else{
      showEmoji(!showEmoji.value);
      focusNode.requestFocus();
    }

  }

}
