import 'package:flutter/material.dart';
import '../../../extensions/extensions.dart';
import 'package:mirrorfly_plugin/message_params.dart';

import '../../../data/utils.dart';
import '../../../model/chat_message_model.dart';

/// [SenderHeader] This widget is used for displaying the UserName in the Message Widgets.
class SenderHeader extends StatelessWidget {
  const SenderHeader(
      {Key? key,
      required this.isGroupProfile,
      required this.chatList,
      required this.index,
      required this.textStyle})
      : super(key: key);
  final bool? isGroupProfile;
  final List<ChatMessageModel> chatList;
  final int index;
  final TextStyle? textStyle;

  bool isSenderChanged(List<ChatMessageModel> messageList, int position) {
    var preposition = position + 1;
    if (!preposition.isNegative) {
      var currentMessage = messageList[position];
      var previousMessage = messageList[preposition];
      if (currentMessage.isMessageSentByMe !=
              previousMessage.isMessageSentByMe ||
          previousMessage.messageType.toUpperCase() ==
              MessageType.isNotification ||
          (currentMessage.messageChatType == ChatType.groupChat &&
              currentMessage.isThisAReplyMessage)) {
        return true;
      }
      var currentSenderJid = currentMessage.senderUserJid.checkNull();
      var previousSenderJid = previousMessage.senderUserJid.checkNull();
      return previousSenderJid != currentSenderJid;
    } else {
      return false;
    }
  }

  bool isMessageDateEqual(List<ChatMessageModel> messageList, int position) {
    var previousMessage = getPreviousMessage(messageList, position);
    return previousMessage != null && checkIsNotNotification(previousMessage);
  }

  ChatMessageModel? getPreviousMessage(
      List<ChatMessageModel> messageList, int position) {
    return (position > 0) ? messageList[position + 1] : null;
  }

  bool checkIsNotNotification(ChatMessageModel messageItem) {
    var msgType = messageItem.messageType;
    return msgType.toUpperCase() != MessageType.isNotification;
  }

  @override
  Widget build(BuildContext context) {
    // LogMessage.d("index", index.toString());
    return Visibility(
      visible: isGroupProfile ?? false
          ? (index == chatList.length - 1 ||
                  isSenderChanged(chatList, index)) &&
              !chatList[index].isMessageSentByMe
          : false,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0, right: 8.0, left: 8.0),
        child: Text(
          chatList[index].senderUserName.checkNull(),
          style: textStyle?.copyWith(
              color: Color(MessageUtils.getColourCode(
                  chatList[index].senderUserName.checkNull()))),
          /*style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(MessageUtils.getColourCode(
                  chatList[index].senderUserName.checkNull()))),*/
        ),
      ),
    );
  }
}
