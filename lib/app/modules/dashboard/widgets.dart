import 'package:flutter/material.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';

import '../../common/constants.dart';
import '../../common/widgets.dart';
import '../../model/recent_chat.dart';

Widget searchHeader(String? type, String count, BuildContext context) {
  return Container(
    width: MediaQuery.of(context).size.width,
    padding: const EdgeInsets.all(8),
    color: dividerColor,
    child: Text.rich(TextSpan(text: type, children: [
      TextSpan(text: " ($count)", style: const TextStyle(fontWeight: FontWeight.bold))
    ])),
  );
}


Widget recentChatItem({required RecentChatData item, required BuildContext context,required Function() onTap,String spanTxt = "",bool isCheckBoxVisible = false,bool isChecked = false,Function(bool? value)? onchange}) {
  var titlestyle = const TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w700,
    fontFamily: 'sf_ui',
    color: textHintColor);
  return InkWell(
    onTap:onTap,
    child: Row(
      children: [
        Container(
            margin:
            const EdgeInsets.only(left: 19.0, top: 10, bottom: 10, right: 10),
            child: Stack(
              children: [
                ImageNetwork(
                  url: item.profileImage.toString(),
                  width: 48,
                  height: 48,
                  clipOval: true,
                  errorWidget: item.isGroup!
                      ? ClipOval(
                    child: Image.asset(
                      groupImg,
                      height: 48,
                      width: 48,
                      fit: BoxFit.cover,
                    ),
                  )
                      : ProfileTextImage(
                    text: item.profileName.checkNull().isEmpty
                        ? item.nickName.checkNull()
                        : item.profileName.checkNull(),
                  ),
                ),
                item.unreadMessageCount.toString() != "0"
                    ? Positioned(
                    right: 0,
                    child: CircleAvatar(
                      radius: 8,
                      child: Text(
                        item.unreadMessageCount.toString(),
                        style: const TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                            fontFamily: 'sf_ui'),
                      ),
                    ))
                    : const SizedBox(),
              ],
            )),
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          spanTxt.isEmpty ? Text(
                            item.profileName.toString(),
                            style: titlestyle,
                          ) : spannableText(item.profileName.checkNull(), spanTxt, titlestyle),
                          Row(
                            children: [
                              item.unreadMessageCount.toString() != "0"
                                  ? const Padding(
                                padding: EdgeInsets.only(right: 8.0),
                                child: CircleAvatar(
                                  radius: 4,
                                  backgroundColor: Colors.green,
                                ),
                              )
                                  : const SizedBox(),
                              Expanded(
                                child: Row(
                                  children: [
                                    forMessageTypeIcon(item.lastMessageType!),
                                    SizedBox(width: forMessageTypeString(item.lastMessageType!)!=null ? 3.0 : 0.0,),
                                    Expanded(
                                      child: Text(
                                        forMessageTypeString(item.lastMessageType!) ?? item.lastMessageContent.toString(),
                                        style: Theme.of(context).textTheme.titleSmall,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0, left: 8),
                      child: !isCheckBoxVisible ? Text(
                        getRecentChatTime(
                            context, item.lastMessageTime),
                        textAlign: TextAlign.end,
                        style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'sf_ui',
                            color: item.unreadMessageCount.toString() != "0"
                                ? buttonBgColor
                                : textColor),
                      ) :
                      Visibility(
                        visible: isCheckBoxVisible,
                        child: Checkbox(
                          value: isChecked,
                          onChanged: onchange,
                        ),
                      ),
                    )
                  ],
                ),
                const AppDivider(padding: EdgeInsets.only(top: 8),)
              ],
            ),
          ),
        )
      ],
    ),
  );
}

Widget spannableText(String text, String spannableText,TextStyle? style) {
  var startIndex = text.toLowerCase().indexOf(spannableText.toLowerCase());
  var endIndex = startIndex + spannableText.length;
  if (startIndex != -1 && endIndex != -1) {
    var startText = text.substring(0, startIndex);
    var colorText = text.substring(startIndex, endIndex);
    var endText = text.substring(endIndex, text.length);
    mirrorFlyLog("startText", startText);
    mirrorFlyLog("endText", endText);
    mirrorFlyLog("colorText", colorText);
    return Text.rich(TextSpan(
        text: startText,
        children: [
          TextSpan(text: colorText, style: const TextStyle(color: Colors.blue)),
          TextSpan(
              text: endText,
              style: style)
        ],
        style: style),maxLines: 1,overflow: TextOverflow.ellipsis,);
  } else {
    return Text(
        text,
        style: style, maxLines: 1,overflow: TextOverflow.ellipsis
    );
  }
}