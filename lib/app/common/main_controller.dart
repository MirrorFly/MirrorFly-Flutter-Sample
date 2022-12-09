import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/pushnotification.dart';
import 'package:mirror_fly_demo/app/data/session_management.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/permissions.dart';
import 'package:flysdk/flysdk.dart';

class MainController extends GetxController {
  var authToken = "".obs;
  Rx<String> uploadEndpoint = "".obs;
  var maxDuration = 100.obs;
  var currentPos = 0.obs;
  var isPlaying = false.obs;
  var audioPlayed = false.obs;
  AudioPlayer player = AudioPlayer();
  String currentPostLabel = "00:00";

  @override
  void onInit() {
    super.onInit();
    PushNotifications.init();
    getMediaEndpoint();
    uploadEndpoint(SessionManagement.getMediaEndPoint().checkNull());
    authToken(SessionManagement.getAuthToken().checkNull());
    getAuthToken();
  }

  getMediaEndpoint() async {
    if (SessionManagement
        .getMediaEndPoint()
        .checkNull()
        .isEmpty) {
      FlyChat.mediaEndPoint().then((value) {
        mirrorFlyLog("media_endpoint", value.toString());
        if(value!=null) {
          if (value.isNotEmpty) {
            uploadEndpoint(value);
            SessionManagement.setMediaEndPoint(value);
          } else {
            uploadEndpoint(SessionManagement.getMediaEndPoint().checkNull());
          }
        }
      });
    }
  }

  getAuthToken() async {
    if (SessionManagement
        .getUsername()
        .checkNull()
        .isNotEmpty &&
        SessionManagement
            .getPassword()
            .checkNull()
            .isNotEmpty) {
      await FlyChat.authToken().then((value) {
        mirrorFlyLog("RetryAuth", value.toString());
        if(value!=null) {
          if (value.isNotEmpty) {
            authToken(value);
            SessionManagement.setAuthToken(value);
          } else {
            authToken(SessionManagement.getAuthToken().checkNull());
          }
          update();
        }
      });
    }
  }



  Image imageFromBase64String(String base64String, BuildContext context,
      double? width, double? height) {
    var decodedBase64 = base64String.replaceAll("\n", "");
    Uint8List image = const Base64Decoder().convert(decodedBase64);
    return Image.memory(
      image,
      width: width ?? MediaQuery
          .of(context)
          .size
          .width * 0.60,
      height: height ?? MediaQuery
          .of(context)
          .size
          .height * 0.4,
      fit: BoxFit.cover,
    );
  }

  Widget getLocationImage(LocationChatMessage? locationChatMessage,
      double width, double height) {
    return InkWell(
        onTap: () async {
          String googleUrl =
              'https://www.google.com/maps/search/?api=1&query=${locationChatMessage
              .latitude}, ${locationChatMessage.longitude}';
          if (await canLaunchUrl(Uri.parse(googleUrl))) {
            await launchUrl(Uri.parse(googleUrl));
          } else {
            throw 'Could not open the map.';
          }
        },
        child: Image.network(
          Helper.getMapImageUri(
              locationChatMessage!.latitude, locationChatMessage.longitude),
          fit: BoxFit.fill,
          width: width,
          height: height,
        ));
  }

  checkFile(String mediaLocalStoragePath) {
    return mediaLocalStoragePath.isNotEmpty &&
        File(mediaLocalStoragePath).existsSync();
  }

  openDocument(String mediaLocalStoragePath, BuildContext context) async {
    // if (await askStoragePermission()) {
    if (mediaLocalStoragePath.isNotEmpty) {
      FlyChat.openFile(mediaLocalStoragePath).catchError((onError) {
        final scaffold = ScaffoldMessenger.of(context);
        scaffold.showSnackBar(
          SnackBar(
            content: const Text(
                'No supported application available to open this file format'),
            action: SnackBarAction(
                label: 'Ok', onPressed: scaffold.hideCurrentSnackBar),
          ),
        );
      });
    } else {
      debugPrint("media does not exist");
    }
    // }
  }

  downloadMedia(String messageId) async {
    if (await askStoragePermission()) {
      FlyChat.downloadMedia(messageId);
    }
  }

  Future<bool> askStoragePermission() async {
    final permission = await AppPermission.getStoragePermission();
    switch (permission) {
      case PermissionStatus.granted:
        return true;
      case PermissionStatus.permanentlyDenied:
        return false;
      default:
        debugPrint("Contact Permission default");
        return false;
    }
  }

  playAudio(String filePath) async {
    if (!isPlaying.value && !audioPlayed.value) {
      int result = await player.play(filePath, isLocal: true);
      if (result == 1) {

        isPlaying(true);
        audioPlayed(true);
      } else {
        mirrorFlyLog("", "Error while playing audio.");
      }
    } else if (audioPlayed.value && !isPlaying.value) {
      int result = await player.resume();
      if (result == 1) {

        isPlaying(true);
        audioPlayed(true);
      } else {
        mirrorFlyLog("", "Error on resume audio.");
      }
    } else {
      int result = await player.pause();
      if (result == 1) {

        isPlaying(false);
      } else {
        mirrorFlyLog("", "Error on pause audio.");
      }
    }
  }
}
