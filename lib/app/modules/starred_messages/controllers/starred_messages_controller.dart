
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mirror_fly_demo/app/nativecall/platformRepo.dart';

import '../../../model/chatMessageModel.dart';

class StarredMessagesController extends GetxController {

  var starredChatList = List<ChatMessageModel>.empty(growable: true).obs;
  double height = 0.0;
  double width = 0.0;
  var isSelected = false.obs;

  var calendar = DateTime.now();

  @override
  void onInit() {
    super.onInit();
    getFavouriteMessages();
  }

  getFavouriteMessages() {
    PlatformRepo().getFavouriteMessages().then((value){
      List<ChatMessageModel> chatMessageModel = chatMessageModelFromJson(value);
      starredChatList(chatMessageModel);
    });
  }

  String getChatTime(context, int? epochTime) {
    if (epochTime == null) return "";
    if (epochTime == 0) return "";
    var convertedTime = epochTime; // / 1000;
    //messageDate.time = convertedTime
    // var hourTime = manipulateMessageTime(
    //     context, DateTime.fromMicrosecondsSinceEpoch(convertedTime));
    var currentYear = DateTime.now().year;
    calendar = DateTime.fromMicrosecondsSinceEpoch(convertedTime);
    var time = (currentYear == calendar.year)
        ? DateFormat("dd-MMM-yyyy").format(calendar)
        : DateFormat("yyyy/MM/dd").format(calendar);
    return time;
  }
  String manipulateMessageTime(context, DateTime messageDate) {
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
}
