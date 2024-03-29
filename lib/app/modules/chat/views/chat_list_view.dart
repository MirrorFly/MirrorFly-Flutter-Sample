import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/extensions.dart';
import 'package:mirror_fly_demo/app/modules/chat/controllers/chat_controller.dart';
import 'package:mirrorfly_plugin/logmessage.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:swipe_to/swipe_to.dart';

import '../../../common/constants.dart';
import '../../../model/chat_message_model.dart';
import '../chat_widgets.dart';

class ChatListView extends StatefulWidget {
  final ChatController chatController;
  final List<ChatMessageModel> chatList;
  const ChatListView({super.key, required this.chatController, required this.chatList});

  @override
  State<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  @override
  Widget build(BuildContext context) {
    // super.build(context);
    return Align(
      alignment: Alignment.bottomCenter,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification) {
            widget.chatController.loadNextChatHistory();
          }
          return false;
        },
        child: ScrollablePositionedList.separated(
          separatorBuilder: (context, index) {
            var string = groupedDateMessage(index, widget.chatList); //Date Labels
            return string != null ? NotificationMessageView(chatMessage: string) : const Offstage();
          },
          itemScrollController: widget.chatController.newScrollController,
          itemPositionsListener: widget.chatController.newitemPositionsListener,
          itemCount: widget.chatList.length,
          shrinkWrap: true,
          reverse: true,
          itemBuilder: (context, pos) {
            final index = pos;
            LogMessage.d("ScrollablePositionedList", "build $index ${widget.chatList[index].messageId}");
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(() {
                  return Visibility(
                      visible: (widget.chatController.showLoadingPrevious.value && index == widget.chatList.length - 1),
                      //|| (controller.loadPreviousData.value && pos==chatList.length-1) ,
                      child: const Center(child: CircularProgressIndicator()));
                }),
                (widget.chatList[index].messageType.toUpperCase() != Constants.mNotification)
                    ? SwipeTo(
                        key: ValueKey(widget.chatList[index].messageId),
                        onRightSwipe: (DragUpdateDetails dragUpdateDetails) {
                          if (!widget.chatList[index].isMessageRecalled.value &&
                              !widget.chatList[index].isMessageDeleted &&
                              widget.chatList[index].messageStatus.value.checkNull().toString() != "N") {
                            widget.chatController.handleReplyChatMessage(widget.chatList[index]);
                          }
                        },
                        animationDuration: const Duration(milliseconds: 300),
                        offsetDx: 0.2,
                        child: GestureDetector(
                          onLongPress: () {
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
                            LogMessage.d("Container", "build ${widget.chatList[index].messageId}");
                            return Container(
                              key: Key(widget.chatList[index].messageId),
                              color: widget.chatList[index].isSelected.value ? chatReplyContainerColor : Colors.transparent,
                              margin: const EdgeInsets.only(left: 14, right: 14, top: 5, bottom: 10),
                              child: Align(
                                alignment: (widget.chatList[index].isMessageSentByMe ? Alignment.bottomRight : Alignment.bottomLeft),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Visibility(
                                      visible: widget.chatList[index].isMessageSentByMe &&
                                          widget.chatController.forwardMessageVisibility(widget.chatList[index]),
                                      child: IconButton(
                                          onPressed: () {
                                            widget.chatController.forwardSingleMessage(widget.chatList[index].messageId);
                                          },
                                          icon: SvgPicture.asset(forwardMedia)),
                                    ),
                                    Container(
                                      constraints: BoxConstraints(maxWidth: Get.width * 0.75),
                                      decoration: BoxDecoration(
                                          borderRadius: widget.chatList[index].isMessageSentByMe
                                              ? const BorderRadius.only(
                                                  topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10))
                                              : const BorderRadius.only(
                                                  topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
                                          color: (widget.chatList[index].isMessageSentByMe ? chatSentBgColor : Colors.white),
                                          border: widget.chatList[index].isMessageSentByMe
                                              ? Border.all(color: chatSentBgColor)
                                              : Border.all(color: chatBorderColor)),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SenderHeader(
                                              isGroupProfile: widget.chatController.profile.isGroupProfile,
                                              chatList: widget.chatList,
                                              index: index),
                                          widget.chatList[index].isThisAReplyMessage
                                              ? widget.chatList[index].replyParentChatMessage == null
                                                  ? messageNotAvailableWidget(widget.chatList[index])
                                                  : ReplyMessageHeader(chatMessage: widget.chatList[index])
                                              : const SizedBox.shrink(),
                                          MessageContent(
                                              chatList: widget.chatList,
                                              index: index,
                                              onPlayAudio: () {
                                                if (widget.chatController.isAudioRecording.value == Constants.audioRecording) {
                                                  widget.chatController.stopRecording();
                                                }
                                                widget.chatController.playAudio(widget.chatList[index]);
                                              },
                                              onSeekbarChange: (double value) {
                                                widget.chatController.onSeekbarChange(value, widget.chatList[index]);
                                              },
                                              isSelected: widget.chatController.isSelected.value)
                                        ],
                                      ),
                                    ),
                                    Visibility(
                                      visible: !widget.chatList[index].isMessageSentByMe &&
                                          widget.chatController.forwardMessageVisibility(widget.chatList[index]),
                                      child: IconButton(
                                          onPressed: () {
                                            widget.chatController.forwardSingleMessage(widget.chatList[index].messageId);
                                          },
                                          icon: SvgPicture.asset(forwardMedia)),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      )
                    : NotificationMessageView(chatMessage: widget.chatList[index].messageTextContent),
                Obx(() {
                  return Visibility(
                      visible: (widget.chatController.showLoadingNext.value && index == 0),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ));
                }),
              ],
            );
          },
        ),
      ),
    );
  }

/*  @override
  bool get wantKeepAlive => true;*/
}

// Widget chatListView(List<ChatMessageModel> chatList) {
//
// }
