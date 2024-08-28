
import 'package:flutter/material.dart';
import '../../../extensions/extensions.dart';
import '../../../stylesheet/stylesheet.dart';

import '../../../common/app_localizations.dart';
import '../../../common/constants.dart';
import '../../../data/helper.dart';
import '../../../data/utils.dart';
import '../../../model/chat_message_model.dart';
import '../../dashboard/widgets.dart';
import 'chat_widgets.dart';

class CaptionMessageView extends StatelessWidget {
  const CaptionMessageView({super.key, required this.mediaMessage,
  required this.chatMessage, required this.context, this.search = "", this.textMessageViewStyle = const TextMessageViewStyle()});

  final MediaChatMessage mediaMessage;
  final ChatMessageModel chatMessage;
  final BuildContext context;
  final String search;
  final TextMessageViewStyle textMessageViewStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          search.isEmpty
              ? textMessageSpannableText(
              mediaMessage.mediaCaptionText.checkNull(),textMessageViewStyle.textStyle,textMessageViewStyle.urlMessageColor)
              : chatSpannedText(
            mediaMessage.mediaCaptionText.checkNull(),
            search,textMessageViewStyle.textStyle,spanColor: textMessageViewStyle.highlightColor,
            urlColor: textMessageViewStyle.urlMessageColor
            // const TextStyle(fontSize: 14, color: textHintColor),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              chatMessage.isMessageStarred.value
                  ? AppUtils.svgIcon(icon:starSmallIcon)
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
                style: textMessageViewStyle.timeTextStyle,),
                const SizedBox(width: 5,),
              ],
              Text(
                getChatTime(context, chatMessage.messageSentTime.toInt()),
                style: textMessageViewStyle.timeTextStyle,
                // style: TextStyle(
                //     fontSize: 12,
                //     color: chatMessage.isMessageSentByMe
                //         ? durationTextColor
                //         : textHintColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
