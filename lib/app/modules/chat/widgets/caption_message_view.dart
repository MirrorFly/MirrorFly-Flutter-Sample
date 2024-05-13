
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mirror_fly_demo/app/extensions/extensions.dart';

import '../../../common/app_localizations.dart';
import '../../../common/constants.dart';
import '../../../data/helper.dart';
import '../../../data/utils.dart';
import '../../../model/chat_message_model.dart';
import '../../dashboard/widgets.dart';
import 'chat_widgets.dart';

class CaptionMessageView extends StatelessWidget {
  const CaptionMessageView({super.key, required this.mediaMessage,
  required this.chatMessage, required this.context, this.search = ""});

  final MediaChatMessage mediaMessage;
  final ChatMessageModel chatMessage;
  final BuildContext context;
  final String search;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          search.isEmpty
              ? textMessageSpannableText(
              mediaMessage.mediaCaptionText.checkNull())
              : chatSpannedText(
            mediaMessage.mediaCaptionText.checkNull(),
            search,
            const TextStyle(fontSize: 14, color: textHintColor),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
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
                Text(getTranslated("edited"), style: const TextStyle(
                    fontSize: 11)),
                const SizedBox(width: 5,),
              ],
              Text(
                getChatTime(context, chatMessage.messageSentTime.toInt()),
                style: TextStyle(
                    fontSize: 12,
                    color: chatMessage.isMessageSentByMe
                        ? durationTextColor
                        : textHintColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
