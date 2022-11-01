import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/SessionManagement.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/model/countryModel.dart';

import '../nativecall/platformRepo.dart';

class MainController extends GetxController {
  var AUTHTOKEN = "".obs;
  var calendar = DateTime.now();

  @override
  void onInit() {
    super.onInit();
    AUTHTOKEN(SessionManagement().getauthToken().checkNull());
    getAuthToken();
  }

  getAuthToken() async {
    if(SessionManagement().getUsername().checkNull().isNotEmpty&& SessionManagement().getPassword().checkNull().isNotEmpty) {
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
    var currentYear = DateTime.now().year;
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

  bool equalsWithYesterday(DateTime srcDate, String day) {
    // Time part has
    // discarded
    var yesterday = (day == Constants.YESTERDAY)
        ? calendar.subtract(Duration(days: 1))
        : DateTime.now();
    return yesterday.difference(calendar).inDays == 0;
  }
}
