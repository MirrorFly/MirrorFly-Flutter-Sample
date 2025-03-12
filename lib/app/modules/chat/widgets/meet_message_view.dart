import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mirror_fly_demo/app/modules/chat/widgets/custom_text_view.dart';
import '../../../extensions/extensions.dart';
import '../../../stylesheet/stylesheet.dart';

import '../../../common/app_localizations.dart';
import '../../../common/constants.dart';
import '../../../data/helper.dart';
import '../../../data/utils.dart';
import '../../../model/chat_message_model.dart';
import '../../../routes/route_settings.dart';

class MeetMessageView extends StatelessWidget {
  const MeetMessageView(
      {Key? key,
      required this.chatMessage,
      this.search = "",
      this.textMessageViewStyle = const TextMessageViewStyle()})
      : super(key: key);
  final ChatMessageModel chatMessage;
  final String search;
  final TextMessageViewStyle textMessageViewStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () async {
            if(await AppUtils.isNetConnected()) {
              var link = MessageUtils.getCallLinkFromMessage(chatMessage.meetChatMessage?.link ?? "");
              if (link.isNotEmpty) {
                NavUtils.toNamed(Routes.joinCallPreview, arguments: {
                  "callLinkId": link.replaceAll(Constants.webChatLogin, "")
                });
              }
            }else{
              toToast(getTranslated("noInternetConnection"));
            }
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 9, 5, 2),
            child: Row(
              mainAxisSize: chatMessage.replyParentChatMessage == null
                  ? MainAxisSize.min
                  : MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                    child: CustomTextView(
                      key: Key("message_view+${chatMessage.messageId}"),
                  text: chatMessage.meetChatMessage?.link ?? "",
                  defaultTextStyle: textMessageViewStyle.textStyle,
                  linkColor: textMessageViewStyle.urlMessageColor,
                  mentionUserTextColor: textMessageViewStyle.mentionUserColor,
                  searchQueryTextColor: textMessageViewStyle.highlightColor,
                  mentionedMeBgColor: textMessageViewStyle.mentionedMeBgColor,
                  searchQueryString: search,
                )),
                const SizedBox(
                  width: 60,
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 5.0),
          child: MeetLinkView(
            message: chatMessage.meetChatMessage?.link ??"",
            timestamp: chatMessage.meetChatMessage?.scheduledDateTime ?? 0,
            callLinkViewStyle: textMessageViewStyle.callLinkViewStyle,
          ),
        ),
        InkWell(
          onTap: () async {
            if (await AppUtils.isNetConnected()) {
              var link = chatMessage.meetChatMessage!.link.checkNull();
              if (link.isNotEmpty) {
                NavUtils.toNamed(Routes.joinCallPreview, arguments: {
                  "callLinkId": link.replaceAll(Constants.webChatLogin, "")
                });
              }
            } else {
              toToast(getTranslated("noInternetConnection"));
            }
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 4.0, bottom: 2),
            child: Row(
              mainAxisSize: chatMessage.replyParentChatMessage == null
                  ? MainAxisSize.min
                  : MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: AppUtils.assetIcon(
                    assetName: mirrorflySmall,
                    width: 24,
                  ),
                ),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    getTranslated("joinVideoMeet"),style:textMessageViewStyle.scheduleTextStyle,
                  ),
                )),
                chatMessage.isMessageStarred.value
                    ? Padding(
                      padding: const EdgeInsets.only(bottom:4.0),
                      child: AppUtils.svgIcon(icon: starSmallIcon),
                    )
                    : const Offstage(),
                const SizedBox(
                  width: 5,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: MessageUtils.getMessageIndicatorIcon(
                      chatMessage.messageStatus.value,
                      chatMessage.isMessageSentByMe,
                      chatMessage.messageType,
                      chatMessage.isMessageRecalled.value),
                ),
                const SizedBox(
                  width: 5,
                ),
                if (chatMessage.isMessageEdited.value) ...[
                  Text(
                    getTranslated(
                        "edited"), //style: const TextStyle(fontSize: 11)
                    style: textMessageViewStyle.timeTextStyle,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                ],
                Text(
                  getChatTime(context, chatMessage.messageSentTime.toInt()),
                  style: textMessageViewStyle.timeTextStyle,
                  /*style: TextStyle(
                      fontSize: 11,
                      color: chatMessage.isMessageSentByMe
                          ? durationTextColor
                          : textHintColor),*/
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class MeetLinkView extends StatelessWidget {
  const MeetLinkView(
      {super.key,
      required this.message,
      required this.callLinkViewStyle,
      required this.timestamp});
  final String message;

  final int timestamp;
  final CallLinkViewStyle callLinkViewStyle;

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    String formattedDate = DateFormat("MMM d, yyyy h:mm a").format(dateTime);
    return GestureDetector(
      onTap: () async {
        if (await AppUtils.isNetConnected()) {
          if (message.isNotEmpty) {
            NavUtils.toNamed(Routes.joinCallPreview, arguments: {
              "callLinkId": message.replaceAll(Constants.webChatLogin, "")
            });
          }
        } else {
          toToast(getTranslated("noInternetConnection"));
        }
      },
      child: Container(
        decoration: callLinkViewStyle.decoration,
        child: ListTile(
          minTileHeight: 60,
          title: Text(
            getTranslated("scheduleOn"),
            style: callLinkViewStyle.textStyle.copyWith(color:callLinkViewStyle.scheduleTileColor,fontSize: 14,),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              formattedDate.replaceAll("AM", "am").replaceAll("PM", "pm"),
              style: callLinkViewStyle.textStyle.copyWith(color:callLinkViewStyle.scheduleDateTimeColor,fontSize: 12,),
            ),
          ),
          trailing: AppUtils.svgIcon(
              icon: videoCamera,
              width: 30,
              colorFilter: ColorFilter.mode(
                  callLinkViewStyle.scheduleIconColor, BlendMode.srcIn)),
        ),
      ),
    );
  }
}
