import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/data/session_management.dart';
import 'package:mirror_fly_demo/app/model/chat_message_model.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';
import 'package:permission_handler/permission_handler.dart';

extension RecentChatParsing on RecentChatData {
  String getChatType() {
    return (isGroup.checkNull())
        ? Constants.typeGroupChat
        : (isBroadCast.checkNull())
        ? Constants.typeBroadcastChat
        : Constants.typeChat;
  }

  bool isDeletedContact() {
    return contactType == "deleted_contact";
  }

  bool isItSavedContact() {
    return contactType == 'live_contact';
  }

  bool isUnknownContact() {
    return !isDeletedContact() && !isItSavedContact() && !isGroup.checkNull();
  }

  bool isEmailContact() => !isGroup.checkNull() && isGroupInOfflineMode.checkNull(); // for email contact isGroupInOfflineMode will be true

  String getName() {
    if (!Constants.enableContactSync) {
      /*return item.name.toString().checkNull().isEmpty
        ? item.nickName.toString()
        : item.name.toString();*/
      return profileName.checkNull().isEmpty
          ? nickName.checkNull().isNotEmpty
          ? nickName.checkNull()
          : getMobileNumberFromJid(jid.checkNull())
          : profileName.checkNull();
    } else {
      if (jid.checkNull() == SessionManagement.getUserJID()) {
        return Constants.you;
      } else if (isDeletedContact()) {
        mirrorFlyLog('isDeletedContact', isDeletedContact().toString());
        return Constants.deletedUser;
      } else if (isUnknownContact() || nickName.checkNull().isEmpty) {
        mirrorFlyLog('isUnknownContact', jid.toString());
        return getMobileNumberFromJid(jid.checkNull());
      } else {
        mirrorFlyLog('nickName', nickName.toString());
        return nickName.checkNull();
      }
    }
  }
}


extension ProfileParesing on ProfileDetails {
  String getUsername() {
    var value = Mirrorfly.getProfileDetails(jid: jid.checkNull());
    var str = ProfileDetails.fromJson(json.decode(value.toString()));
    return str.getName(); //str.name.checkNull();
  }

  Future<ProfileDetails> getProfileDetails() async {
    var value = await Mirrorfly.getProfileDetails(jid: jid.checkNull());
    var str = ProfileDetails.fromJson(json.decode(value.toString()));
    return str;
  }

  bool isDeletedContact() {
    return contactType == "deleted_contact";
  }

  String getChatType() {
    return (isGroupProfile ?? false) ? Constants.typeGroupChat : Constants.typeChat;
  }

  bool isItSavedContact() {
    return contactType == 'live_contact';
  }

  bool isUnknownContact() {
    return !isDeletedContact() && !isItSavedContact() && !isGroupProfile.checkNull();
  }

  bool isEmailContact() => !isGroupProfile.checkNull() && isGroupInOfflineMode.checkNull(); // for email contact isGroupInOfflineMode will be true

  String getName() {
    if (!Constants.enableContactSync) {
      if (jid.checkNull() == SessionManagement.getUserJID()) {
        return Constants.you;
      }
      /*return item.name.toString().checkNull().isEmpty
        ? item.nickName.toString()
        : item.name.toString();*/
      return name.checkNull().isEmpty
          ? (nickName.checkNull().isEmpty ? getMobileNumberFromJid(jid.checkNull()) : nickName.checkNull())
          : name.checkNull();
    } else {
      if (jid.checkNull() == SessionManagement.getUserJID()) {
        return Constants.you;
      } else if (isDeletedContact()) {
        mirrorFlyLog('isDeletedContact', isDeletedContact().toString());
        return Constants.deletedUser;
      } else if (isUnknownContact() || nickName.checkNull().isEmpty) {
        mirrorFlyLog('isUnknownContact', jid.toString());
        return getMobileNumberFromJid(jid.checkNull());
      } else {
        mirrorFlyLog('nickName', nickName.toString());
        return nickName.checkNull().isEmpty
            ? (name.checkNull().isEmpty ? getMobileNumberFromJid(jid.checkNull()) : name.checkNull())
            : nickName.checkNull();//#FLUTTER-1300
      }
    }
  }
}

extension ChatmessageParsing on ChatMessageModel {
  bool isMediaDownloaded() {
    return isMediaMessage() && (mediaChatMessage?.mediaDownloadStatus.value == Constants.mediaDownloaded);
  }

  bool isMediaUploaded() {
    return isMediaMessage() && (mediaChatMessage?.mediaUploadStatus.value == Constants.mediaUploaded);
  }

  bool isMediaMessage() => (isAudioMessage() || isVideoMessage() || isImageMessage() || isFileMessage());

  bool isTextMessage() => messageType == Constants.mText;

  bool isAudioMessage() => messageType == Constants.mAudio;

  bool isImageMessage() => messageType == Constants.mImage;

  bool isVideoMessage() => messageType == Constants.mVideo;

  bool isFileMessage() => messageType == Constants.mDocument;

  bool isNotificationMessage() => messageType.toUpperCase() == Constants.mNotification;
}


extension FileFormatter on num {
  String readableFileSize({bool base1024 = true}) {
    final base = base1024 ? 1024 : 1000;
    if (this <= 0) return "0";
    final units = ["bytes", "KB", "MB", "GB", "TB"];
    int digitGroups = (log(this) / log(base)).round();
    return "${NumberFormat("#,##0.#").format(this / pow(base, digitGroups))} ${units[digitGroups]}";
  }
}

extension StringParsing on String? {
  //check null
  String checkNull() {
    return this ?? "";
  }

  bool toBool() {
    return this != null ? this!.toLowerCase() == "true" : false;
  }

  int checkIndexes(String searchedKey) {
    var i = -1;
    if (i == -1 || i < searchedKey.length) {
      while (this!.contains(searchedKey, i + 1)) {
        i = this!.indexOf(searchedKey, i + 1);

        if (i == 0 || (i > 0 && (RegExp("[^A-Za-z0-9 ]").hasMatch(this!.split("")[i]) || this!.split("")[i] == " "))) {
          return i;
        }
        i++;
      }
    }
    return -1;
  }

  bool startsWithTextInWords(String text) {
    return !this!.toLowerCase().contains(text.toLowerCase()) ? false : this!.toLowerCase().startsWith(text.toLowerCase());
    //checkIndexes(text)>-1;
    /*return when {
      this.indexOf(text, ignoreCase = true) <= -1 -> false
      else -> return this.checkIndexes(text) > -1
    }*/
  }
}

extension BooleanParsing on bool? {
  //check null
  bool checkNull() {
    return this ?? false;
  }
}

extension ScrollControllerExtension on ScrollController {
  void scrollTo({required int index, required Duration duration, Curve? curve}) {
    var offset = getOffset(GlobalKey(debugLabel: "CHATITEM_$index"));
    LogMessage.d("ScrollTo", offset);
    animateTo(
      offset,
      duration: duration,
      curve: Curves.linear,
    );
  }

  void jumpsTo({required double index}){
    jumpTo(index);
  }

  double getOffset(GlobalKey key){
    final box = key.currentContext?.findRenderObject() as RenderBox;
    final boxHeight = box.size.height;
    Offset boxPosition = box.localToGlobal(Offset.zero);
    double boxY = (boxPosition.dy - boxHeight / 2);
    return boxY;
  }

  bool get isAttached => hasClients;
}

/// this an extension of List of [Permission]
extension PermissionExtension on List<Permission>{
  /// This [status] is used to Check and returns Map of [PermissionStatus].
  Future<Map<String,PermissionStatus>> status() async {
    var permissionStatusList = <String,PermissionStatus>{};
    await Future.forEach(this, (Permission permission) async {
      var status = await permission.status;
      permissionStatusList.putIfAbsent(permission.toString(), () => status);
    });
    return permissionStatusList;
  }

  /// This [permanentlyDeniedPermissions] is used to Check and returns Map of [PermissionStatus.permanentlyDenied].
  Future<Map<String,PermissionStatus>> permanentlyDeniedPermissions() async {
    var permissionStatusList = <String,PermissionStatus>{};
    await Future.forEach(this, (Permission permission) async {
      var status = await permission.status;
      if(status == PermissionStatus.permanentlyDenied) {
        permissionStatusList.putIfAbsent(permission.toString(), () => status);
      }
    });
    return permissionStatusList;
  }

  /// This [deniedPermissions] is used to Check and returns Map of [PermissionStatus.denied].
  Future<Map<String,PermissionStatus>> deniedPermissions() async {
    var permissionStatusList = <String,PermissionStatus>{};
    await Future.forEach(this, (Permission permission) async {
      var status = await permission.status;
      if(status == PermissionStatus.denied) {
        permissionStatusList.putIfAbsent(permission.toString(), () => status);
      }
    });
    return permissionStatusList;
  }

  /// This [grantedPermissions] is used to Check and returns Map of [PermissionStatus.granted].
  Future<Map<String,PermissionStatus>> grantedPermissions() async {
    var permissionStatusList = <String,PermissionStatus>{};
    await Future.forEach(this, (Permission permission) async {
      var status = await permission.status;
      if(status == PermissionStatus.granted) {
        permissionStatusList.putIfAbsent(permission.toString(), () => status);
      }
    });
    return permissionStatusList;
  }

  /// This [shouldShowRationale] is used to Check available rationale and returns List of [bool].
  Future<List<bool>> shouldShowRationale() async {
    var permissionStatusList = <bool>[];
    await Future.forEach(this, (Permission permission) async {
      var show = await permission.shouldShowRequestRationale;
      LogMessage.d("shouldShowRationale", "${permission.toString()} : $show");
      permissionStatusList.add(show);
    });
    return permissionStatusList;
  }

}