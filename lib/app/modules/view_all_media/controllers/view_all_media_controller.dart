import 'dart:convert';
import 'dart:io' as io;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:flysdk/flysdk.dart';

import '../../../common/constants.dart';
import '../../../routes/app_pages.dart';


class ViewAllMediaController extends GetxController {
  final _medialist = <String, List<MessageItem>>{}.obs;
  set medialist(Map<String,List<MessageItem>> value) => _medialist.value = value;
  Map<String,List<MessageItem>> get medialistdata => _medialist;

  final _docslist = <String, List<MessageItem>>{}.obs;
  set docslist(Map<String, List<MessageItem>> value) => _docslist.value = value;
  Map<String, List<MessageItem>> get docslistdata => _docslist;

  final _linklist = <String, List<MessageItem>>{}.obs;
  set linklist(Map<String, List<MessageItem>> value) => _linklist.value = value;
  Map<String, List<MessageItem>> get linklistdata => _linklist;

  var name = Get.arguments["name"] as String;
  var jid = Get.arguments["jid"] as String;
  var isGroup = Get.arguments["isgroup"] as bool;

  @override
  void onInit() {
    super.onInit();
    getMediaMessages();
    getDocsMessages();
    getLinkMessages();

    _medialist.bindStream(_medialist.stream);
    ever(_medialist, (callback) {
      mirrorFlyLog("media list", medialistdata.length.toString());
    });
    _docslist.bindStream(_docslist.stream);
    ever(_docslist, (callback) {
      mirrorFlyLog("docs list", docslistdata.length.toString());
    });
    _linklist.bindStream(_linklist.stream);
    ever(_linklist, (callback) {
      mirrorFlyLog("link list", linklistdata.length.toString());
    });
  }

  getMediaMessages() {
    FlyChat.getMediaMessages(jid).then((value) async {
      if (value != null) {
        var data = chatMessageModelFromJson(value);
        if (data.isNotEmpty) {
          _medialist(await getMapGroupedMediaList(data, true));
        }
      }
    });
  }

  //getDocsMessages
  getDocsMessages() {
    FlyChat.getDocsMessages(jid).then((value) async {
      if (value != null) {
        var data = chatMessageModelFromJson(value);
        if (data.isNotEmpty) {
          _docslist(await getMapGroupedMediaList(data, false));
        }
      }
    });
  }

  //getLinkMessages
  getLinkMessages() {
    FlyChat.getLinkMessages(jid).then((value) async {
      if (value != null) {
        var data = chatMessageModelFromJson(value);
        if (data.isNotEmpty) {
          _linklist(await getMapGroupedMediaList(data, false, true));
        }
      }
    });
  }

  Future<Map<String,List<MessageItem>>> getMapGroupedMediaList(
      List<ChatMessageModel> mediaMessages, bool isMedia,
      [bool isLinkMedia = false]) async {
    var calendarInstance = DateTime.now();
    var currentYear = calendarInstance.year;
    var currentMonth = calendarInstance.month;
    var currentDay = calendarInstance.day;
    var dateSymbols = DateFormat().dateSymbols.STANDALONEMONTHS;
    int year;
    int month;
    int day;
    //var viewAllMediaList = <GroupedMedia>[];
    Map<String,List<MessageItem>> mapMediaList = {};
    var previousCategoryType = 10;
    var messages = <MessageItem>[];
    for (var chatMessage in mediaMessages) {
      var date = chatMessage.messageSentTime;
      var calendar = DateTime.fromMicrosecondsSinceEpoch(date);
      year = calendar.year;
      month = calendar.month;
      day = calendar.day;

      var category = getCategoryName(
          dateSymbols, currentDay, currentMonth, currentYear, day, month, year);

      if (isLinkMedia) {
        if (previousCategoryType != category.key) {
          messages=[];
        }
        previousCategoryType = category.key;
        mapMediaList[category.value]=getMapMessageWithURLList(messages,chatMessage);
      } else {
        if (!chatMessage.isMessageRecalled &&
            (chatMessage.isMediaDownloaded() ||
                chatMessage.isMediaUploaded()) &&
            await isMediaAvailable(chatMessage, isMedia)) {
          if (previousCategoryType != category.key) {
            messages=[];
          }
          messages.add(MessageItem(chatMessage));
          mapMediaList[category.value]=messages;
          previousCategoryType = category.key;
        }
      }
    }
    return mapMediaList;//viewAllMediaList;
  }

  List<MessageItem> getMapMessageWithURLList(List<MessageItem> messageList,ChatMessageModel message) {
    var textContent = "";
    if (message.isTextMessage()) {
      textContent = message.messageTextContent!;
    } else if (message.isImageMessage()) {
      textContent = message.mediaChatMessage!.mediaCaptionText;
    } else {
      textContent = Constants.emptyString;
    }
    if (textContent.isNotEmpty) {
      getUrlAndHostList(textContent).forEach((it) {
        var map = {};
        map["host"] = it.key;
        map["url"] = it.value;
        messageList.add(MessageItem(message, map));
        mirrorFlyLog("link msg", map.toString());
      });
    }
    return messageList;
  }

  List<MapEntry<String, String>> getUrlAndHostList(String text) {
    var urls = <MapEntry<String, String>>[];
    var splitString = text.split("\\s+");
    for (var string in splitString) {
      try {
        var item = Uri.parse(string);
        urls.add(MapEntry(item.host, item.toString()));
      } catch (ignored) {
        //No Implementation needed
      }
    }
    mirrorFlyLog("urls", urls.toString());
    return urls;
  }

  Future<bool> isMediaAvailable(
      ChatMessageModel chatMessage, bool isMedia) async {
    var mediaExist = await isMediaExists(
        chatMessage.mediaChatMessage!.mediaLocalStoragePath);
    return (!isMedia || mediaExist);
  }

  Future<bool> isMediaExists(String filePath) async {
    return await io.File(filePath).exists();
  }

  MapEntry<int, String> getCategoryName(
      List<String> dateSymbols,
      int currentDay,
      int currentMonth,
      int currentYear,
      int day,
      int month,
      int year) {
    if ((currentYear - year) == 1) {
      if (currentMonth < month) {
        return MapEntry(4, dateSymbols[month]);
      }
    } else if ((currentYear > year)) {
      return MapEntry(5, year.toString());
    } else if ((currentMonth - month) == 1) {
      if (day > currentDay) {
        return const MapEntry(3, "Last Month");
      } else {
        return MapEntry(4, dateSymbols[month]);
      }
    } else if (currentMonth > month) {
      return MapEntry(4, dateSymbols[month]);
    } else if ((currentDay - day) > 7) {
      return const MapEntry(2, "Last Month");
    } else if ((currentDay - day) > 2) {
      return const MapEntry(1, "Last Week");
    }
    return const MapEntry(0, "Recent");
  }

  Image imageFromBase64String(String base64String,
      double? width, double? height) {
    var decodedBase64 = base64String.replaceAll("\n", "");
    Uint8List image = const Base64Decoder().convert(decodedBase64);
    return Image.memory(
      image,
      width: width,
      height: height,
      fit: BoxFit.cover,
    );
  }

  openFile(String path){
    FlyChat.openFile(path).catchError((onError) {
      Get.snackbar("","No supported application available to open this file format").show();
    });
  }

  openImage(String path){
    Get.toNamed(Routes.IMAGE_VIEW, arguments: {
      "imagePath": path,
      "imageName": "Sent Media"
    });
  }

}
