import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/SessionManagement.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/model/countryModel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/contact_utils.dart';
import '../model/chatMessageModel.dart';
import '../nativecall/platformRepo.dart';

class MainController extends GetxController {
  var AUTHTOKEN = "".obs;
  Rx<String> UPLOAD_ENDPOINT = "".obs;
  var calendar = DateTime.now();
  var maxDuration = 100.obs;
  var currentPos = 0.obs;
  var isPlaying = false.obs;
  var audioPlayed = false.obs;
  AudioPlayer player = AudioPlayer();
  String currentPostLabel = "00:00";

  @override
  void onInit() {
    super.onInit();
    getMedia_endpoint();
    UPLOAD_ENDPOINT(SessionManagement().getMediaEndPoint().checkNull());
    AUTHTOKEN(SessionManagement().getauthToken().checkNull());
    getAuthToken();
  }

  getMedia_endpoint() async {
    if (SessionManagement()
        .getMediaEndPoint()
        .checkNull()
        .isEmpty) {
      PlatformRepo().media_endpoint().then((value) {
        Log("media_endpoint", value);
        if (value.isNotEmpty) {
          UPLOAD_ENDPOINT(value);
          SessionManagement.setMediaEndPoint(value);
        } else {
          UPLOAD_ENDPOINT(SessionManagement().getMediaEndPoint().checkNull());
        }
      });
    }
  }

  getAuthToken() async {
    if (SessionManagement()
        .getUsername()
        .checkNull()
        .isNotEmpty &&
        SessionManagement()
            .getPassword()
            .checkNull()
            .isNotEmpty) {
      await PlatformRepo().authtoken().then((value) {
        Log("RetryAuth", value);
        if (value.isNotEmpty) {
          AUTHTOKEN(value);
          SessionManagement.setAuthtoken(value);
        } else {
          AUTHTOKEN(SessionManagement().getauthToken().checkNull());
        }
        update();
      });
    }
  }

  String getRecentChatTime(BuildContext context, int? epochTime) {
    if (epochTime == null) return "";
    if (epochTime == 0) return "";
    var convertedTime = epochTime; // / 1000;
    //messageDate.time = convertedTime
    var hourTime = manipulateMessageTime(
        context, DateTime.fromMicrosecondsSinceEpoch(convertedTime));
    var currentYear = DateTime
        .now()
        .year;
    calendar = DateTime.fromMicrosecondsSinceEpoch(convertedTime);
    var time = (currentYear == calendar.year)
        ? DateFormat("dd-MMM").format(calendar)
        : DateFormat("yyyy/MM/dd").format(calendar);
    return (equalsWithYesterday(calendar, Constants.TODAY))
        ? hourTime
        : (equalsWithYesterday(calendar, Constants.YESTERDAY))
        ? Constants.YESTERDAY_UPPER
        : time;
  }

  String manipulateMessageTime(BuildContext context, DateTime messageDate) {
    var format = MediaQuery
        .of(context)
        .alwaysUse24HourFormat ? 24 : 12;
    var hours = calendar.hour; //calendar[Calendar.HOUR]
    calendar = messageDate;
    var dateHourFormat = setDateHourFormat(format, hours);
    return DateFormat(dateHourFormat).format(messageDate);
  }

  String setDateHourFormat(int format, int hours) {
    var dateHourFormat = (format == 12)
        ? (hours < 10)
        ? "hh:mm aa"
        : "h:mm aa"
        : (hours < 10)
        ? "HH:mm"
        : "H:mm";
    return dateHourFormat;
  }

  bool equalsWithYesterday(DateTime srcDate, String day) {
    // Time part has
    // discarded
    var yesterday = (day == Constants.YESTERDAY)
        ? calendar.subtract(Duration(days: 1))
        : DateTime.now();
    return yesterday
        .difference(calendar)
        .inDays == 0;
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

  String getChatTime(BuildContext context, int? epochTime) {
    if (epochTime == null) return "";
    if (epochTime == 0) return "";
    var convertedTime = epochTime;
    var hourTime = manipulateMessageTime(
        context, DateTime.fromMicrosecondsSinceEpoch(convertedTime));
    calendar = DateTime.fromMicrosecondsSinceEpoch(convertedTime);
    return hourTime;
  }

  openDocument(String mediaLocalStoragePath, BuildContext context) async {
    // if (await askStoragePermission()) {
    if (mediaLocalStoragePath.isNotEmpty) {
      PlatformRepo().openFile(mediaLocalStoragePath).catchError((onError) {
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
      debugPrint("media doesnot exist");
    }
    // }
  }

  downloadMedia(String messageId) async {
    if (await askStoragePermission()) {
      PlatformRepo().mediaDownload(messageId);
    }
  }

  Future<bool> askStoragePermission() async {
    final permission = await ContactUtils.getStoragePermission();
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
        //play success

        isPlaying(true);
        audioPlayed(true);
      } else {
        Log("", "Error while playing audio.");
      }
    } else if (audioPlayed.value && !isPlaying.value) {
      int result = await player.resume();
      if (result == 1) {
        //resume success

        isPlaying(true);
        audioPlayed(true);
      } else {
        Log("", "Error on resume audio.");
      }
    } else {
      int result = await player.pause();
      if (result == 1) {
        //pause success

        isPlaying(false);
      } else {
        Log("", "Error on pause audio.");
      }
    }
  }
}
