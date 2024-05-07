import 'package:flutter/material.dart';
import 'package:mirrorfly_plugin/logmessage.dart';

import '../../../common/constants.dart';
import '../../../model/chat_message_model.dart';
import 'audio_message_view.dart';
import 'contact_message_view.dart';
import 'document_message_view.dart';
import 'image_message_view.dart';
import 'location_message_view.dart';
import 'notification_message_view.dart';
import 'recalled_message_view.dart';
import 'text_message_view.dart';
import 'video_message_view.dart';

class MessageContent extends StatelessWidget {
  const MessageContent({Key? key,
    required this.chatList,
    required this.index,
    this.search = "",
    this.isSelected = false,
    required this.onPlayAudio,
    required this.onSeekbarChange})
      : super(key: key);
  final List<ChatMessageModel> chatList;
  final int index;
  final Function() onPlayAudio;
  final Function(double) onSeekbarChange;
  final String search;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    LogMessage.d("MessageContent", "build ${chatList[index].messageId}");
    var chatMessage = chatList[index];
    //LogMessage.d("message==>", json.encode(chatMessage));
    // debugPrint("Message Type===> ${chatMessage.messageType}");
    if (chatList[index].isMessageRecalled.value) {
      return RecalledMessageView(
        chatMessage: chatMessage,
      );
    } else {
      if (chatList[index].messageType.toUpperCase() == Constants.mText ||
          chatList[index].messageType.toUpperCase() == Constants.mAutoText) {
        return TextMessageView(
          chatMessage: chatMessage,
          search: search,
        );
      } else if (chatList[index].messageType.toUpperCase() ==
          Constants.mNotification) {
        return NotificationMessageView(
            chatMessage: chatMessage.messageTextContent);
      } else if (chatList[index].messageType.toUpperCase() ==
          Constants.mLocation) {
        if (chatList[index].locationChatMessage == null) {
          return const Offstage();
        }
        return LocationMessageView(
          chatMessage: chatMessage,
          isSelected: isSelected,
        );
      } else if (chatList[index].messageType.toUpperCase() ==
          Constants.mContact) {
        if (chatList[index].contactChatMessage == null) {
          return const Offstage();
        }
        return ContactMessageView(
          chatMessage: chatMessage,
          search: search,
          isSelected: isSelected,
        );
      } else {
        if (chatList[index].mediaChatMessage == null) {
          return const Offstage();
        } else {
          if (chatList[index].messageType.toUpperCase() == Constants.mImage) {
            return ImageMessageView(
                chatMessage: chatMessage,
                search: search,
                isSelected: isSelected);
          } else if (chatList[index].messageType.toUpperCase() ==
              Constants.mVideo) {
            return VideoMessageView(
                chatMessage: chatMessage,
                search: search,
                isSelected: isSelected);
          } else if (chatList[index].messageType.toUpperCase() ==
              Constants.mDocument ||
              chatList[index].messageType.toUpperCase() == Constants.mFile) {
            return DocumentMessageView(
              chatMessage: chatMessage,
              search: search,
            );
          } else if (chatList[index].messageType.toUpperCase() ==
              Constants.mAudio) {
            return AudioMessageView(
              chatMessage: chatMessage,
              onPlayAudio: onPlayAudio,
              onSeekbarChange: onSeekbarChange,
            );
          } else {
            return const Offstage();
          }
        }
      }
    }
  }
}