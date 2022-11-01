import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Helper {
  static void showLoading({String? message, bool dismissable = false}) {
    Get.dialog(
      Dialog(
        child: WillPopScope(
          onWillPop: () async {
            return Future.value(dismissable);
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

  static void progressLoading({bool dismissable = false}) {
    Get.dialog(
        AlertDialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          content: WillPopScope(
            onWillPop: () async => Future.value(dismissable),
            child: Container(
              width: 60,
              height: 60,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ),
        barrierDismissible: dismissable,
        barrierColor: Colors.transparent);
  }

  static void showAlert({String? title,required String message,List<Widget>? actions}) {
    Get.dialog(
      AlertDialog(
        title: title!=null ? Text(title) : null,
        contentPadding: EdgeInsets.only(top: 20,right: 20,left: 20),
        content: Text(message),
        contentTextStyle: TextStyle(color: texthintcolor,fontWeight: FontWeight.w500),
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
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) +
        ' ' +
        suffixes[i];
  }

  static String getMapImageUri(double latitude, double longitude) {
    var key = Constants.GOOGLE_MAP_KEY;
    return ("https://maps.googleapis.com/maps/api/staticmap?center=" +
        latitude.toString() +
        "," +
        longitude.toString() +
        "&zoom=13&size=300x200&markers=color:red|" +
        latitude.toString() +
        "," +
        longitude.toString() +
        "&key=" +
        key);
  }

  static int getColourCode(String name) {
    if (name != null && name == Constants.YOU) return 0Xff000000;
    var colorsArray = Constants.defaultColorList;
    var hashcode = name.hashCode;
    var rand = hashcode % colorsArray.length;
    return colorsArray[(rand).abs()];
  }
}

extension StringParsing on String? {
  //check null
  String checkNull() {
    return this ?? "";
  }
}
