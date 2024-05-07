
import 'package:flutter/material.dart';

import '../../../common/app_localizations.dart';
import '../../../common/constants.dart';
import '../../../data/helper.dart';
import '../../../model/chat_message_model.dart';

class RecalledMessageView extends StatelessWidget {
  const RecalledMessageView({Key? key, required this.chatMessage})
      : super(key: key);
  final ChatMessageModel chatMessage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisSize: chatMessage.replyParentChatMessage == null
            ? MainAxisSize.min
            : MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Row(
              children: [
                Image.asset(
                  disabledIcon,
                  width: 15,
                  height: 15,
                ),
                const SizedBox(width: 10),
                Text(
                  chatMessage.isMessageSentByMe
                      ? getTranslated("youDeletedThisMessage")
                      : getTranslated("thisMessageWasDeleted"),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Row(
            children: [
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