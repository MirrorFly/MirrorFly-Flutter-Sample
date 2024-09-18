import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/utils.dart';
import '../../../extensions/extensions.dart';
import '../../../modules/chat/controllers/chat_controller.dart';
import '../../../stylesheet/stylesheet.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:swipe_to/swipe_to.dart';

import '../../../common/constants.dart';
import '../../../model/chat_message_model.dart';
import '../widgets/chat_widgets.dart';
import '../widgets/message_content.dart';
import '../widgets/notification_message_view.dart';
import '../widgets/reply_message_widgets.dart';
import '../widgets/sender_header.dart';

class ChatListView extends StatefulWidget {
  final ChatController chatController;
  final List<ChatMessageModel> chatList;
  final SenderChatBubbleStyle senderChatStyle;
  final ReceiverChatBubbleStyle receiverChatStyle;
  final NotificationMessageViewStyle notificationMessageViewStyle;
  final Color chatSelectedColor;

  const ChatListView({super.key, required this.chatController, required this.chatList,required this.senderChatStyle,required this.receiverChatStyle, required this.chatSelectedColor, required this.notificationMessageViewStyle});

  @override
  State<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  @override
  Widget build(BuildContext context) {
    // super.build(context);
    debugPrint("ChatListView build view");
    return Align(
      alignment: Alignment.bottomCenter,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification) {
            widget.chatController.loadNextChatHistory();
          }
          return false;
        },
        child: Obx(() {
          return ScrollablePositionedList.separated(
            separatorBuilder: (context, index) {
              var string = AppUtils.groupedDateMessage(index, widget.chatList); //Date Labels
              return string != null ? NotificationMessageView(chatMessage: string) : const Offstage();
            },
            itemScrollController: widget.chatController.newScrollController,
            itemPositionsListener: widget.chatController.newItemPositionsListener,
            itemCount: widget.chatList.length,
            shrinkWrap: true,
            reverse: true,
            itemBuilder: (context, pos) {
              final index = pos;
              // LogMessage.d("ScrollablePositionedList", "build $index ${widget.chatList[index].messageId}");
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(() {
                    // LogMessage.d("ScrollablePositionedList inside AutomaticKeepAlive", "build $index");
                    return widget.chatController.showLoadingPrevious.value && index == widget.chatList.length - 1
                        ? const Center(child: CircularProgressIndicator())
                        : const Offstage();
                  }),
                  (widget.chatList[index].messageType.toUpperCase() != Constants.mNotification)
                      ? SwipeTo(
                          onRightSwipe: (widget.chatController.arguments?.enableSwipeToReply).checkNull() ? (DragUpdateDetails dragUpdateDetails) {
                            if (!widget.chatList[index].isMessageRecalled.value &&
                                !widget.chatList[index].isMessageDeleted &&
                                widget.chatList[index].messageStatus.value.checkNull().toString() != "N") {
                              widget.chatController.handleReplyChatMessage(widget.chatList[index]);
                            }
                          } : null,
                          animationDuration: const Duration(milliseconds: 300),
                          offsetDx: 0.2,
                          child: GestureDetector(
                            onLongPress: (widget.chatController.arguments?.disableAppBar).checkNull() ? null : () {
                              debugPrint("LongPressed");
                              FocusManager.instance.primaryFocus?.unfocus();
                              if (!widget.chatController.isSelected.value) {
                                widget.chatController.isSelected(true);
                                widget.chatController.addChatSelection(widget.chatList[index]);
                              }
                            },
                            onTap: () {
                              debugPrint("On Tap");
                              FocusManager.instance.primaryFocus?.unfocus();
                              if (widget.chatController.isSelected.value) {
                                widget.chatController.isSelected.value
                                    ? widget.chatController.selectedChatList.contains(widget.chatList[index])
                                        ? widget.chatController.clearChatSelection(widget.chatList[index])
                                        : widget.chatController.addChatSelection(widget.chatList[index])
                                    : null;
                                widget.chatController.getMessageActions();
                              } else {
                                var replyChat = widget.chatList[index].replyParentChatMessage;
                                if (replyChat != null) {
                                  debugPrint("reply tap ");
                                  var chat = widget.chatList.indexWhere((element) => element.messageId == replyChat.messageId);
                                  if (!chat.isNegative) {
                                    widget.chatController.navigateToMessage(widget.chatList[chat], index: chat);
                                  }
                                }
                              }
                            },
                            onDoubleTap: () {
                              widget.chatController.translateMessage(index);
                            },
                            child: Obx(() {
                              // LogMessage.d("Container", "build ${widget.chatList[index].messageId}");
                              return Container(
                                key: ValueKey(widget.chatList[index].messageId),
                                color: widget.chatList[index].isSelected.value ? widget.chatSelectedColor : Colors.transparent,
                                margin: const EdgeInsets.only(left: 14, right: 14, top: 5, bottom: 10),
                                child: Align(
                                  alignment: (widget.chatList[index].isMessageSentByMe ? Alignment.bottomRight : Alignment.bottomLeft),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Visibility(
                                        visible: widget.chatList[index].isMessageSentByMe && widget.chatController.forwardMessageVisibility(widget.chatList[index]),
                                        child: IconButton(
                                            onPressed: () {
                                              widget.chatController.forwardSingleMessage(widget.chatList[index].messageId);
                                            },
                                            icon: AppUtils.svgIcon(icon:forwardMedia)),
                                      ),
                                      Container(
                                        constraints: BoxConstraints(maxWidth: NavUtils.width * 0.75),
                                        decoration: widget.chatList[index].isMessageSentByMe ? widget.senderChatStyle.decoration : widget.receiverChatStyle.decoration,
                                        /*decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10)),
                                            color: (widget.chatList[index].isMessageSentByMe ? chatSentBgColor : Colors.white),
                                            border: widget.chatList[index].isMessageSentByMe
                                                ? Border.all(color: chatSentBgColor)
                                                : Border.all(color: chatBorderColor)),*/
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            if (widget.chatController.profile.isGroupProfile.checkNull()) ...[
                                              SenderHeader(
                                                  isGroupProfile: widget.chatController.profile.isGroupProfile,
                                                  chatList: widget.chatList,
                                                  index: index,textStyle: widget.receiverChatStyle.participantNameTextStyle,),
                                            ],
                                            widget.chatList[index].isThisAReplyMessage
                                                ? widget.chatList[index].replyParentChatMessage == null
                                                    ? messageNotAvailableWidget(widget.chatList[index])
                                                    : ReplyMessageHeader(chatMessage: widget.chatList[index],replyHeaderMessageViewStyle: widget.chatList[index].isMessageSentByMe ? widget.senderChatStyle.replyHeaderMessageViewStyle : widget.receiverChatStyle.replyHeaderMessageViewStyle,)
                                                : const Offstage(),
                                            MessageContent(
                                                chatList: widget.chatList,
                                                index: index,
                                                onPlayAudio: () {
                                                  if (widget.chatController.isAudioRecording.value == Constants.audioRecording) {
                                                    widget.chatController.stopRecording();
                                                  }
                                                  // widget.chatController.playAudio(widget.chatList[index]);
                                                },
                                                onSeekbarChange: (double value) {
                                                  // widget.chatController.onSeekbarChange(value, widget.chatList[index]);
                                                },
                                                isSelected: widget.chatController.isSelected.value,
                                            senderChatBubbleStyle: widget.senderChatStyle,
                                                receiverChatBubbleStyle: widget.receiverChatStyle,
                                            notificationMessageViewStyle: widget.notificationMessageViewStyle,)
                                          ],
                                        ),
                                      ),
                                      if (!widget.chatList[index].isMessageSentByMe &&
                                          widget.chatController.forwardMessageVisibility(widget.chatList[index])) ...[
                                        IconButton(
                                            onPressed: () {
                                              widget.chatController.forwardSingleMessage(widget.chatList[index].messageId);
                                            },
                                            icon: AppUtils.svgIcon(icon:forwardMedia))
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        )
                      : NotificationMessageView(chatMessage: widget.chatList[index].messageTextContent),
                  Obx(() {
                    return widget.chatController.showLoadingNext.value && index == 0
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : const Offstage();
                  }),
                ],
              );
            },
          );
        }),
      ),
    );
  }
  //
  // @override
  // bool get wantKeepAlive => true;
}


