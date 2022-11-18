
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/model/chatMessageModel.dart';
import 'package:mirror_fly_demo/app/model/group_members_model.dart';
import 'package:mirror_fly_demo/app/nativecall/platformRepo.dart';

import '../model/userListModel.dart';

class Helper {
  static void showLoading({String? message, bool dismiss = false}) {
    Get.dialog(
      Dialog(
        child: WillPopScope(
          onWillPop: () async {
            return Future.value(dismiss);
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 16),
                Text(message ?? 'Loading...'),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static void progressLoading({bool dismiss = false}) {
    Get.dialog(
        AlertDialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          content: WillPopScope(
            onWillPop: () async => Future.value(dismiss),
            child: const SizedBox(
              width: 60,
              height: 60,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ),
        barrierDismissible: dismiss,
        barrierColor: Colors.transparent);
  }

  static void showAlert({String? title,required String message,List<Widget>? actions,Widget? content}) {
    Get.dialog(
      AlertDialog(
        title: title!=null ? Text(title) : const Text(""),
        contentPadding: title!=null ? const EdgeInsets.only(top: 15,right: 25,left: 25,bottom: 15) :
        const EdgeInsets.only(top: 0,right: 25,left: 25,bottom: 15),
        content: content ?? Text(message),
        contentTextStyle: const TextStyle(color: texthintcolor,fontWeight: FontWeight.w500),
        actions: actions,
      ),
    );
  }

//hide loading
  static void hideLoading() {
    if (Get.isDialogOpen!) {
      Get.back(canPop: true,);
    }
  }

  static String formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  static String getMapImageUri(double latitude, double longitude) {
    var key = Constants.GOOGLE_MAP_KEY;
    return ("https://maps.googleapis.com/maps/api/staticmap?center=$latitude,$longitude&zoom=13&size=300x200&markers=color:red|$latitude,$longitude&key=$key");
  }

  static int getColourCode(String name) {
    if (name == Constants.YOU) return 0Xff000000;
    var colorsArray = Constants.defaultColorList;
    var hashcode = name.hashCode;
    var rand = hashcode % colorsArray.length;
    return colorsArray[(rand).abs()];
  }

  static Widget forMessageTypeIcon(String? messageType) {
    Log("iconfor", messageType.toString());
    switch (messageType?.toUpperCase()) {
      case Constants.MIMAGE:
        return SvgPicture.asset(
          Mimageicon,
          fit: BoxFit.contain,
        );
      case Constants.MAUDIO:
        return SvgPicture.asset(
          Maudioicon,
          fit: BoxFit.contain,
        );
      case Constants.MVIDEO:
        return SvgPicture.asset(
          Mvideoicon,
          fit: BoxFit.contain,
        );
      case Constants.MDOCUMENT:
        return SvgPicture.asset(
          Mdocumenticon,
          fit: BoxFit.contain,
        );
      case Constants.MFILE:
        return SvgPicture.asset(
          Mdocumenticon,
          fit: BoxFit.contain,
        );
      case Constants.MCONTACT:
        return SvgPicture.asset(
          Mcontacticon,
          fit: BoxFit.contain,
        );
      case Constants.MLOCATION:
        return SvgPicture.asset(
          Mlocationicon,
          fit: BoxFit.contain,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  static String forMessageTypeString(String? messageType) {
    switch (messageType?.toUpperCase()) {
      case Constants.MIMAGE:
        return "Image";
      case Constants.MAUDIO:
        return "Audio";
      case Constants.MVIDEO:
        return "Video";
      case Constants.MDOCUMENT:
        return "Document";
      case Constants.MFILE:
        return "Document";
      case Constants.MCONTACT:
        return "Contact";
      case Constants.MLOCATION:
        return "Location";
      default:
        return "";
    }
  }
  static String capitalize(String str) {
    return "${str[0].toUpperCase()}${str.substring(1).toLowerCase()}";
  }

}


String getFileSizeText(String fileSizeInBytes) {
  var fileSizeBuilder ="";
  var fileSize = int.parse(fileSizeInBytes);
  if (fileSize > 1073741824) {
    fileSizeBuilder = (getRoundedFileSize(fileSize / 1073741824)).toString()+(" ")+("GB");
  } else if (fileSize > 1048576) {
    fileSizeBuilder = (getRoundedFileSize(fileSize / 1048576)).toString()+(" ")+("MB");
  } else if (fileSize > 1024) {
    fileSizeBuilder = (getRoundedFileSize(fileSize / 1024)).toString()+(" ")+("KB");
  } else {
    fileSizeBuilder = (fileSizeInBytes).toString()+(" ")+("bytes");
  }
  return fileSizeBuilder.toString();
}
double getRoundedFileSize(double unscaledValue) {
  //return BigDecimal.valueOf(unscaledValue).setScale(2, RoundingMode.HALF_UP).toDouble()
  return  unscaledValue.roundToDouble();
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

String getDateFromTimestamp(int convertedTime,String format){
  var calendar = DateTime.fromMicrosecondsSinceEpoch(convertedTime);
  return DateFormat(format).format(calendar);
}

extension StringParsing on String? {
  //check null
  String checkNull() {
    return this ?? "";
  }
  int checkIndexes(String searchedKey) {
    var i = -1;
    if(i==-1 || i<searchedKey.length) {
      while (this!.contains(searchedKey, i + 1)) {
        i = this!.indexOf(searchedKey, i + 1);

        if (i == 0 ||
            (i > 0 && (RegExp("[^A-Za-z0-9 ]").hasMatch(this!.split("")[i])
                || this!.split("")[i] == " "))) {
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

extension MemberParsing on Member{

  String getUsername(){
    var value = PlatformRepo().getProfileDetails(jid.checkNull(), false);
    var str = Profile.fromJson(json.decode(value.toString()));
    return str.name.checkNull();
  }
  Future<Profile> getProfileDetails() async {
    var value = await PlatformRepo().getProfileDetails(jid.checkNull(), false);
    var str = Profile.fromJson(json.decode(value.toString()));
    return str;
  }
}

extension ProfileParesing on Profile{
  bool isDeletedContact(){
    return contactType =="deleted_contact";
  }
}

extension ChatmessageParsing on ChatMessageModel{
  bool isMediaDownloaded() {
      return isMediaMessage() && (mediaChatMessage?.mediaDownloadStatus == Constants.MEDIA_DOWNLOADED);
  }
  bool isMediaUploaded() {
    return isMediaMessage() && (mediaChatMessage?.mediaUploadStatus == Constants.MEDIA_UPLOADED);
  }
  bool isMediaMessage() => (isAudioMessage() || isVideoMessage() || isImageMessage() || isFileMessage());
  bool isTextMessage() => messageType == Constants.MTEXT;
  bool isAudioMessage() => messageType == Constants.MAUDIO;
  bool isImageMessage() => messageType == Constants.MIMAGE;
  bool isVideoMessage() => messageType == Constants.MVIDEO;
  bool isFileMessage() => messageType == Constants.MDOCUMENT;
  bool isNotificationMessage() => messageType == Constants.MNOTIFICATION;
}

InkWell listItem(
    {Widget? leading, required Widget title, Widget? trailing, required Function() onTap}) {
  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          leading != null ? Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: leading) : const SizedBox(),
          Expanded(
            child: title,
          ),
          trailing ?? const SizedBox()
        ],
      ),
    ),
  );
}