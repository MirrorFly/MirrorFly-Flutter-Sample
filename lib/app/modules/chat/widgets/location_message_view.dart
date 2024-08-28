import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../stylesheet/stylesheet.dart';

import '../../../common/constants.dart';
import '../../../data/helper.dart';
import '../../../data/utils.dart';
import '../../../model/chat_message_model.dart';
import 'chat_widgets.dart';

class LocationMessageView extends StatelessWidget {
  const LocationMessageView({Key? key, required this.chatMessage, required this.isSelected,
  this.locationMessageViewStyle = const LocationMessageViewStyle(),})
      : super(key: key);
  final ChatMessageModel chatMessage;
  final bool isSelected;
  final LocationMessageViewStyle locationMessageViewStyle;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: locationMessageViewStyle.locationBorderRadius,
            child: getLocationImage(chatMessage.locationChatMessage, 200, 171,
                isSelected: isSelected),
          ),
          Positioned(
            bottom: 8,
            right: 10,
            child: Row(
              mainAxisSize: MainAxisSize.min,
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
                  width: 4,
                ),
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
          ),
        ],
      ),
    );
  }
}