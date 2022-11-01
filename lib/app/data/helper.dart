
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Helper{
  static void showLoading([String? message]) {
    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 8),
              Text(message ?? 'Loading...'),
            ],
          ),
        ),
      ),
    );
  }

//hide loading
  static void hideLoading() {
    if (Get.isDialogOpen!) Get.back();
  }

  static void showAlert({String? title,required String message,List<Widget>? actions}) {
    Get.dialog(
      AlertDialog(
        title: title!=null ? Text(title, style: TextStyle(fontSize: 15),) : null,
        contentPadding: EdgeInsets.only(top: 20,right: 20,left: 20),
        content: Text(message),
        contentTextStyle: TextStyle(color: texthintcolor,fontWeight: FontWeight.w500),
        actions: actions,
      ),
    );
  }

  static String formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) +
        ' ' +
        suffixes[i];
  }

  static String getMapImageUri(double latitude, double longitude) {
    var key = Constants.GOOGLE_MAP_KEY;
    return ("https://maps.googleapis.com/maps/api/staticmap?center=" + latitude.toString() + "," + longitude.toString()
    + "&zoom=13&size=300x200&markers=color:red|" + latitude.toString() + "," + longitude.toString() + "&key="
    + key);
  }

  static int getColourCode(String name) {
    if (name != null && name == Constants.YOU) return 0Xff000000;
    var colorsArray = Constants.defaultColorList;
    var hashcode = name.hashCode;
    var rand =  hashcode % colorsArray.length;
    return colorsArray[(rand).abs()];
  }

  static Widget forMessageTypeIcon(String? MessageType) {
    switch (MessageType?.toUpperCase()) {
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

  static String forMessageTypeString(String? MessageType) {
    switch (MessageType?.toUpperCase()) {
      case Constants.MIMAGE:
        return "Image";
      case Constants.MAUDIO:
        return "Audio";
      case Constants.MVIDEO:
        return "Video";
      case Constants.MDOCUMENT:
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

extension StringParsing on String?{
  //check null
  String checkNull(){
    return this ?? "";
  }


}
