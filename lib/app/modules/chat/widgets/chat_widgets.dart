
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../data/utils.dart';
import '../../../extensions/extensions.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';

import '../../../common/app_localizations.dart';
import '../../../common/constants.dart';
import '../../../model/chat_message_model.dart';
import '../../dashboard/widgets.dart';

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

Widget getLocationImage(LocationChatMessage? locationChatMessage, double width, double height,
    {bool isSelected = false}) {
  return InkWell(
      onTap: isSelected
          ? null
          : () async {
        Uri googleUrl = MessageUtils.getMapLaunchUri(locationChatMessage!.latitude,locationChatMessage.longitude);
        AppUtils.launchWeb(googleUrl);
      },
      child: FutureBuilder(
        future: Mirrorfly.getValueFromManifestOrInfoPlist(androidManifestKey: "com.google.android.geo.API_THUMP_KEY", iOSPlistKey: "API_THUMP_KEY"),
        builder: (context,snap) {
          return CachedNetworkImage(
            imageUrl: AppUtils.getMapImageUrl(locationChatMessage!.latitude,locationChatMessage.longitude,snap.data.checkNull()),
            fit: BoxFit.fill,
            width: width,
            height: height,
          );
        }
      ));
}

Widget chatSpannedText(String text, String spannableText, TextStyle? style,
    {int? maxLines,Color spanColor = Colors.orange,Color urlColor = Colors.blue}) {
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
                text: colorText, style: TextStyle(color: spanColor)),
            TextSpan(text: endText)
          ],
          style: style),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  } else {
    return textMessageSpannableText(text,style,urlColor,
        maxLines: maxLines);
  }
}



