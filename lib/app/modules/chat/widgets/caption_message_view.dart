
import 'package:flutter/material.dart';
import '../../../extensions/extensions.dart';
import '../../../stylesheet/stylesheet.dart';

import '../../../common/app_localizations.dart';
import '../../../common/constants.dart';
import '../../../data/helper.dart';
import '../../../data/utils.dart';
import '../../../model/chat_message_model.dart';
import 'custom_text_view.dart';

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
          CustomTextView(
            key: const Key("message_view"),
            text: mediaMessage.mediaCaptionText.checkNull(),
            defaultTextStyle: textMessageViewStyle.textStyle,
            linkColor: textMessageViewStyle.urlMessageColor,
            mentionUserTextColor: textMessageViewStyle.mentionUserColor,
            searchQueryTextColor: textMessageViewStyle.highlightColor,
            searchQueryString: search,
            mentionUserIds: chatMessage.mentionedUsersIds ?? [],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              chatMessage.isMessageStarred.value
                  ? textMessageViewStyle.iconFavourites ?? AppUtils.svgIcon(icon:starSmallIcon)
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
