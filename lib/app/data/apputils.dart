import 'dart:io';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/extensions/extensions.dart';
import 'package:mirror_fly_demo/app/model/chat_message_model.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';
import 'package:tuple/tuple.dart';

class AppUtils{
  AppUtils._();
  static Future<bool> isNetConnected() async {
    final bool isConnected = await InternetConnectionChecker().hasConnection;
    return isConnected;
  }

  /// * Build initials with given name.
  /// * @parameter Name instance of Profile name
  /// * return initials of the name.
  static String getInitials(String name){
      String string = "";
      // debugPrint("str.characters.length ${str}");
      if (name.characters.length >= 2) {
        if (name.trim().contains(" ")) {
          var st = name.trim().split(" ");
          string = st[0].characters.take(1).toUpperCase().toString() +
              st[1].characters.take(1).toUpperCase().toString();
        } else {
          string = name.characters.take(2).toUpperCase().toString();
        }
      } else {
        string = name;
      }
      return string;
  }

  static Tuple2<StringBuffer,bool> getActualMemberName(StringBuffer string){
    // LogMessage.d("getActualMemberName","${string} string length ${string.length} characters ${string.toString().characters.length}");
    return (string.toString().characters.length > Constants.maxNameLength) ?
    Tuple2(
      StringBuffer("${string.toString().characters.take(Constants.maxNameLength)}..."),
      false
    )
    :
    Tuple2(string, true);
  }

  static Future<Tuple2<String, ProfileDetails>> getNameAndProfileDetails(String jid) async {
    var profileDetails = await getProfileDetails(jid);
    var name = profileDetails.getName();
    return Tuple2(name, profileDetails);
  }

  static Map getExceptionMap(String code,String message){
    var map = {};
    map["code"]=code;
    map["message"]=message;
    return map;
  }

  static String returnEmptyStringIfNull(dynamic value) {
    return value ?? '';
  }

  static bool isMediaFileAvailable(MessageType msgType, ChatMessageModel message) {
    bool mediaExist = false;
    if (msgType == MessageType.audio ||
        msgType == MessageType.video ||
        msgType == MessageType.image ||
        msgType == MessageType.document) {
      final downloadedMediaValue = returnEmptyStringIfNull(
          message.mediaChatMessage?.mediaDownloadStatus);
      final uploadedMediaValue = returnEmptyStringIfNull(
          message.mediaChatMessage?.mediaUploadStatus);
      if (MediaDownloadStatus.mediaDownloaded.value.toString() == downloadedMediaValue ||
          MediaUploadStatus.mediaUploaded.value.toString() == uploadedMediaValue) {
        mediaExist = true;
      }
    }
    return mediaExist;
  }

  static bool isMediaFileNotAvailable(bool isMediaFileAvailable, ChatMessageModel message) {
    return !isMediaFileAvailable && message.isMediaMessage();
  }

  static bool isMediaExists(String? filePath) {
    if(filePath == null || filePath.isEmpty) {
      return false;
    }
    File file = File(filePath);
    return file.existsSync();
  }

  /// Get Width and Height from file
  ///
  /// @param filePath of the media
  static Future<Tuple2<int, int>> getImageDimensions(String filePath) async {
    try {
      // Open the file
      File file = File(filePath);
      if (!file.existsSync()) {
        return const Tuple2(Constants.mobileImageMaxWidth, Constants.mobileImageMaxHeight);
      }

      // Read metadata
      final bytes = await file.readAsBytes();
      final image = await decodeImageFromList(bytes);

      // Get dimensions
      final int width = image.width;
      final int height = image.height;
      debugPrint('Image dimensions: $width x $height');
      return Tuple2(width,height);
    } catch (e) {
      debugPrint('Error: $e');
      return const Tuple2(Constants.mobileImageMaxWidth, Constants.mobileImageMaxHeight);
    }
  }

  /// Get Width and Height for Mobile
  ///
  /// @param originalWidth original width of media
  /// @param originalHeight original height of media
  static Tuple2<int, int> getMobileWidthAndHeight(int? originalWidth, int? originalHeight) {
    if (originalWidth == null || originalHeight == null) {
      return const Tuple2(Constants.mobileImageMaxWidth, Constants.mobileImageMaxHeight);
    }

    var newWidth = originalWidth;
    var newHeight = originalHeight;

    // First check if we need to scale width
    if (originalWidth > Constants.mobileImageMaxWidth) {
      //scale width to fit
      newWidth = Constants.mobileImageMaxWidth;
      //scale height to maintain aspect ratio
      newHeight = (newWidth * originalHeight / originalWidth).round();
    }

    // then check if we need to scale even with the new height
    if (newHeight > Constants.mobileImageMaxHeight) {
      //scale height to fit instead
      newHeight = Constants.mobileImageMaxHeight;
      //scale width to maintain aspect ratio
      newWidth = (newHeight * originalWidth / originalHeight).round();
    }

    return Tuple2(
      newWidth > Constants.mobileImageMinWidth ? newWidth : Constants.mobileImageMinWidth,
      newHeight > Constants.mobileImageMinHeight ? newHeight : Constants.mobileImageMinHeight,
    );
  }
}