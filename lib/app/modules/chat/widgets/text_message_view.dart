import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mirror_fly_demo/app/stylesheet/stylesheet.dart';

import '../../../common/app_localizations.dart';
import '../../../common/constants.dart';
import '../../../data/helper.dart';
import '../../../data/utils.dart';
import '../../../model/chat_message_model.dart';
import '../../dashboard/widgets.dart';
import 'chat_widgets.dart';

class TextMessageView extends StatelessWidget {
  const TextMessageView({
    Key? key,
    required this.chatMessage,
    this.search = "",
    this.textMessageViewStyle = const TextMessageViewStyle()
  }) : super(key: key);
  final ChatMessageModel chatMessage;
  final String search;
  final TextMessageViewStyle textMessageViewStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 9, 5, 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: chatMessage.replyParentChatMessage == null
                ? MainAxisSize.min
                : MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flexible(
                child: search.isEmpty
                    ? textMessageSpannableText(chatMessage.messageTextContent ?? "",textMessageViewStyle.textStyle,textMessageViewStyle.urlMessageColor)
                    : chatSpannedText(
                  chatMessage.messageTextContent ?? "",
                  search,
                  textMessageViewStyle.textStyle,
                    spanColor:textMessageViewStyle.highlightColor,urlColor: textMessageViewStyle.urlMessageColor
                  //const TextStyle(fontSize: 14, color: textHintColor),
                ),
              ),
              const SizedBox(width: 60,),
            ],
          ),
          Row(
            mainAxisSize: chatMessage.replyParentChatMessage == null
                ? MainAxisSize.min
                : MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              chatMessage.isMessageStarred.value
                  ? SvgPicture.asset(starSmallIcon)
                  : const Offstage(),
              const SizedBox(
                width: 5,
              ),
              MessageUtils.getMessageIndicatorIcon(
                  chatMessage.messageStatus.value,
                  chatMessage.isMessageSentByMe,
                  chatMessage.messageType,
                  chatMessage.isMessageRecalled.value),
              const SizedBox(
                width: 5,
              ),
              if (chatMessage.isMessageEdited.value) ... [
                Text(getTranslated("edited"), //style: const TextStyle(fontSize: 11)
                  style: textMessageViewStyle.timeTextStyle,
                ),
                const SizedBox(width: 5,),
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
        ],
      ),
    );
  }
}