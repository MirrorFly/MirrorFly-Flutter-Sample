import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../common/app_localizations.dart';
import '../../common/constants.dart';
import '../../data/helper.dart';
import '../../model/chat_message_model.dart';
import '../dashboard/widgets.dart';

Widget messageNotAvailableWidget(ChatMessageModel chatMessage) {
  return Container(
    padding: const EdgeInsets.all(12),
    margin: const EdgeInsets.all(2),
    decoration: BoxDecoration(
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      color: chatMessage.isMessageSentByMe
          ? chatReplyContainerColor
          : chatReplySenderColor,
    ),
    child: Text(getTranslated("messageUnavailable"), maxLines: 2, overflow: TextOverflow.ellipsis,),
  );
}

Widget imageFromBase64String(String base64String, BuildContext context, double? width, double? height) {
  LogMessage.d("imageFromBase64String", "final");
  final decodedBase64 = base64String.replaceAll("\n", "");
  final Uint8List image = const Base64Decoder().convert(decodedBase64);
  return Image.memory(
    image,
    key: ValueKey<String>(base64String),
    width: width ?? Get.width * 0.60,
    height: height ?? Get.height * 0.4,
    fit: BoxFit.cover,
    gaplessPlayback: true,
    cacheHeight: (height ?? Get.height * 0.4).toInt(),
    cacheWidth:  (width ?? Get.width * 0.60).toInt(),
  );
}

Widget getLocationImage(LocationChatMessage? locationChatMessage, double width, double height,
    {bool isSelected = false}) {
  return InkWell(
      onTap: isSelected
          ? null
          : () async {
        String googleUrl =
            'https://www.google.com/maps/search/?api=1&query=${locationChatMessage!.latitude}, ${locationChatMessage
            .longitude}';
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


Widget documentIcon(String mediaFileName, double size) {
  debugPrint("mediaFileName--> $mediaFileName");
  return SvgPicture.asset(getDocAsset(mediaFileName),
      width: size, height: size);
}


getMessageIndicator(String? messageStatus, bool isSender, String messageType, bool isRecalled) {
  // debugPrint("Message Status ==>");
  // debugPrint("Message Status ==> $messageStatus");
  if (messageType.toUpperCase() != Constants.mNotification) {
    if (isSender && !isRecalled) {
      if (messageStatus == 'A') {
        return SvgPicture.asset(acknowledgedIcon);
      } else if (messageStatus == 'D') {
        return SvgPicture.asset(deliveredIcon);
      } else if (messageStatus == 'S') {
        return SvgPicture.asset(seenIcon);
      } else if (messageStatus == 'N') {
        return SvgPicture.asset(unSendIcon);
      } else {
        return const Offstage();
      }
    } else {
      return const Offstage();
    }
  } else {
    return const Offstage();
  }
}

Widget chatSpannedText(String text, String spannableText, TextStyle? style,
    {int? maxLines}) {
  var startIndex = text.toLowerCase().contains(spannableText.toLowerCase())
      ? text.toLowerCase().indexOf(spannableText.toLowerCase())
      : -1;
  var endIndex = startIndex + spannableText.length;
  if (startIndex != -1 && endIndex != -1) {
    var startText = text.substring(0, startIndex);
    var colorText = text.substring(startIndex, endIndex);
    var endText = text.substring(endIndex, text.length);
    return Text.rich(
      TextSpan(
          text: startText,
          children: [
            TextSpan(
                text: colorText, style: const TextStyle(color: Colors.orange)),
            TextSpan(text: endText)
          ],
          style: style),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  } else {
    return textMessageSpannableText(text,
        maxLines: maxLines);
  }
}


/// Checks the current header id with previous header id
/// @param position Position of the current item
/// @return boolean True if header changed, else false
bool isDateChanged(int position, List<ChatMessageModel> mChatData) {
  // try {
  var prePosition = position + 1;
  var size = mChatData.length - 1;
  if (position == size) {
    return true;
  } else {
    if (prePosition <= size && position <= size) {
      var currentHeaderId = mChatData[position].messageSentTime.toInt();
      var previousHeaderId = mChatData[prePosition].messageSentTime.toInt();
      return currentHeaderId != previousHeaderId;
    }
  }
  return false;
}

String? groupedDateMessage(int index, List<ChatMessageModel> chatList) {
  if(index.isNegative){
    return null;
  }
  if (index == chatList.length - 1) {
    return addDateHeaderMessage(chatList.last);
  } else {
    return (isDateChanged(index, chatList) &&
        (addDateHeaderMessage(chatList[index + 1]) !=
            addDateHeaderMessage(chatList[index])))
        ? addDateHeaderMessage(chatList[index])
        : null;
  }
}

String addDateHeaderMessage(ChatMessageModel item) {
  var calendar = DateTime.now();
  var messageDate = getDateFromTimestamp(item.messageSentTime, "MMMM dd, yyyy");
  var monthNumber = calendar.month - 1;
  var month = getMonthForInt(monthNumber);
  var yesterdayDate = DateTime
      .now()
      .subtract(const Duration(days: 1))
      .day;
  var today = "$month ${checkTwoDigitsForDate(calendar.day)}, ${calendar.year}";
  var yesterday =
      "$month ${checkTwoDigitsForDate(yesterdayDate)}, ${calendar.year}";
  if (messageDate.toString() == (today).toString()) {
    return getTranslated("today");
  } else if (messageDate == yesterday) {
    return getTranslated("yesterday");
  } else if (!messageDate.contains("1970")) {
    return messageDate;
  }
  return "";
}

/// This method will return date as 2 digit format, if its a single digit date.
String checkTwoDigitsForDate(int date) {
  if (date
      .toString()
      .length != 2) {
    return "0$date";
  } else {
    return date.toString();
  }
}

/// This method will get the int value and returns it as a complete Month Name. [0 -> 11 implies Jan -> Dec]
String getMonthForInt(int num) {
  var month = "";
  var dateFormatSymbols = DateFormat().dateSymbols.STANDALONEMONTHS;
  var months = dateFormatSymbols;
  if (num <= 11) {
    month = months[num];
  }
  return month;
}
