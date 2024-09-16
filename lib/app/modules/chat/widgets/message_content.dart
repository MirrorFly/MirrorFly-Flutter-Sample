import 'package:flutter/material.dart';
import '../../../stylesheet/stylesheet.dart';

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
    required this.onSeekbarChange, this.senderChatBubbleStyle = const SenderChatBubbleStyle(), this.receiverChatBubbleStyle = const ReceiverChatBubbleStyle(),
  this.notificationMessageViewStyle = const NotificationMessageViewStyle()})
      : super(key: key);
  final List<ChatMessageModel> chatList;
  final int index;
  final Function() onPlayAudio;
  final Function(double) onSeekbarChange;
  final String search;
  final bool isSelected;
  final SenderChatBubbleStyle senderChatBubbleStyle;
  final ReceiverChatBubbleStyle receiverChatBubbleStyle;
  final NotificationMessageViewStyle notificationMessageViewStyle;

  @override
  Widget build(BuildContext context) {
    // LogMessage.d("MessageContent", "build ${chatList[index].messageId}");
    var chatMessage = chatList[index];
    //LogMessage.d("message==>", json.encode(chatMessage));
    // debugPrint("Message Type===> ${chatMessage.messageType}");
    if (chatList[index].isMessageRecalled.value) {
      return RecalledMessageView(
        chatMessage: chatMessage,
        textMessageViewStyle: chatList[index].isMessageSentByMe ? senderChatBubbleStyle.textMessageViewStyle : receiverChatBubbleStyle.textMessageViewStyle,
      );
    } else {
      if (chatList[index].messageType.toUpperCase() == Constants.mText ||
          chatList[index].messageType.toUpperCase() == Constants.mAutoText) {
        return TextMessageView(
          chatMessage: chatMessage,
          search: search,
          textMessageViewStyle: chatList[index].isMessageSentByMe ? senderChatBubbleStyle.textMessageViewStyle : receiverChatBubbleStyle.textMessageViewStyle,
        );
      } else if (chatList[index].messageType.toUpperCase() ==
          Constants.mNotification) {
        return NotificationMessageView(
            chatMessage: chatMessage.messageTextContent,notificationMessageViewStyle: notificationMessageViewStyle,);
      } else if (chatList[index].messageType.toUpperCase() ==
          Constants.mLocation) {
        if (chatList[index].locationChatMessage == null) {
          return const Offstage();
        }
        return LocationMessageView(
          chatMessage: chatMessage,
          isSelected: isSelected,
          locationMessageViewStyle: chatList[index].isMessageSentByMe ? senderChatBubbleStyle.locationMessageViewStyle : receiverChatBubbleStyle.locationMessageViewStyle,
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
          contactMessageViewStyle: chatList[index].isMessageSentByMe ? senderChatBubbleStyle.contactMessageViewStyle : receiverChatBubbleStyle.contactMessageViewStyle,
          decoration: chatList[index].isMessageSentByMe ? senderChatBubbleStyle.decoration : receiverChatBubbleStyle.decoration,
        );
      } else {
        if (chatList[index].mediaChatMessage == null) {
          return const Offstage();
        } else {
          if (chatList[index].messageType.toUpperCase() == Constants.mImage) {
            return ImageMessageView(
                chatMessage: chatMessage,
                search: search,
                isSelected: isSelected,
            imageMessageViewStyle: chatList[index].isMessageSentByMe ? senderChatBubbleStyle.imageMessageViewStyle : receiverChatBubbleStyle.imageMessageViewStyle,);
          } else if (chatList[index].messageType.toUpperCase() ==
              Constants.mVideo) {
            return VideoMessageView(
                chatMessage: chatMessage,
                search: search,
                isSelected: isSelected,
            videoMessageViewStyle: chatList[index].isMessageSentByMe ? senderChatBubbleStyle.videoMessageViewStyle : receiverChatBubbleStyle.videoMessageViewStyle,);
          } else if (chatList[index].messageType.toUpperCase() ==
              Constants.mDocument ||
              chatList[index].messageType.toUpperCase() == Constants.mFile) {
            return DocumentMessageView(
              chatMessage: chatMessage,
              search: search,
              docMessageViewStyle: chatList[index].isMessageSentByMe ? senderChatBubbleStyle.docMessageViewStyle : receiverChatBubbleStyle.docMessageViewStyle,
              decoration: chatList[index].isMessageSentByMe ? senderChatBubbleStyle.decoration : receiverChatBubbleStyle.decoration,
            );
          } else if (chatList[index].messageType.toUpperCase() ==
              Constants.mAudio) {
            return AudioMessageView(
              chatMessage: chatMessage,
              onPlayAudio: onPlayAudio,
              onSeekbarChange: onSeekbarChange,
              audioMessageViewStyle: chatList[index].isMessageSentByMe ? senderChatBubbleStyle.audioMessageViewStyle : receiverChatBubbleStyle.audioMessageViewStyle,
              decoration: chatList[index].isMessageSentByMe ? senderChatBubbleStyle.decoration : receiverChatBubbleStyle.decoration,
            );
          } else {
            return const Offstage();
          }
        }
      }
    }
  }
}