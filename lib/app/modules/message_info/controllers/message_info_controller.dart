import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:flysdk/flysdk.dart';

class MessageInfoController extends GetxController {
  //TODO: Implement MessageInfoController

  var messageID = Get.arguments["messageID"];
  var chatMessage = Get.arguments["chatMessage"] as ChatMessageModel;
  var readTime = ''.obs;
  var deliveredTime = ''.obs;


  var calendar = DateTime.now();

  @override
  void onInit() {
    super.onInit();
    debugPrint("Message Info $messageID");
    FlyChat.getMessageStatusOfASingleChatMessage(messageID).then((value) {
      var response = json.decode(value);
      readTime(response["seenTime"]);
      deliveredTime(response["deliveredTime"]);
    });
  }

  String getChatTime(BuildContext context, int? epochTime) {
    if (epochTime == null) return "";
    if (epochTime == 0) return "";
    var convertedTime = epochTime; // / 1000;
    //messageDate.time = convertedTime
    var hourTime = manipulateMessageTime(
        context, DateTime.fromMicrosecondsSinceEpoch(convertedTime));
    var currentYear = DateTime.now().year;
    calendar = DateTime.fromMicrosecondsSinceEpoch(convertedTime);
    var time = (currentYear == calendar.year)
        ? DateFormat("dd-MMM-yyyy").format(calendar)
        : DateFormat("yyyy/MM/dd").format(calendar);
    return "$time at $hourTime";
  }

  String manipulateMessageTime(BuildContext context, DateTime messageDate) {
    var format = MediaQuery.of(context).alwaysUse24HourFormat ? 24 : 12;
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
}
