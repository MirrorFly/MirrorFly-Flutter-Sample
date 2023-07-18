import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';

// import 'package:grouped_list/grouped_list.dart';
import 'package:marquee/marquee.dart';
import 'package:mirror_fly_demo/app/common/widgets.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';

import 'package:mirror_fly_demo/app/routes/app_pages.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:swipe_to/swipe_to.dart';

import '../../../common/constants.dart';
import '../../../model/chat_message_model.dart';
import '../../../widgets/custom_action_bar_icons.dart';
import '../../../widgets/lottie_animation.dart';
import '../chat_widgets.dart';
import '../controllers/chat_controller.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.screenHeight = MediaQuery.of(context).size.height;
    controller.screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: getAppBar(),
        body: SafeArea(
          child: Container(
            width: controller.screenWidth,
            height: controller.screenHeight,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/logos/chat_bg.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: WillPopScope(
              onWillPop: () {
                mirrorFlyLog("viewInsets",
                    MediaQuery.of(context).viewInsets.bottom.toString());
                if (controller.showEmoji.value) {
                  controller.showEmoji(false);
                } else if (MediaQuery.of(context).viewInsets.bottom > 0.0) {
                  //FocusManager.instance.primaryFocus?.unfocus();
                  controller.focusNode.unfocus();
                } else if (controller.nJid != null) {
                  // controller.saveUnsentMessage();
                  Get.offAllNamed(Routes.dashboard);
                  return Future.value(true);
                } else if (controller.isSelected.value) {
                  controller.clearAllChatSelection();
                } else {
                  return Future.value(true);
                }
                return Future.value(false);
              },
              child: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(child: Obx(() {
                        return controller.chatLoading.value
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : chatListView(controller.chatList);
                      })),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Obx(() {
                          return Container(
                            color: Colors.white,
                            child: controller.isBlocked.value
                                ? userBlocked()
                                : controller.isMemberOfGroup
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Obx(() {
                                            if (controller.isReplying.value) {
                                              return ReplyingMessageHeader(
                                                chatMessage:
                                                    controller.replyChatMessage,
                                                onCancel: () => controller
                                                    .cancelReplyMessage(),
                                                onClick: () {
                                                  controller.navigateToMessage(
                                                      controller
                                                          .replyChatMessage);
                                                },
                                              );
                                            } else {
                                              return const SizedBox.shrink();
                                            }
                                          }),
                                          const Divider(
                                            height: 1,
                                            thickness: 0.29,
                                            color: textBlackColor,
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          IntrinsicHeight(
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                Flexible(
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10),
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 10,
                                                            right: 10,
                                                            bottom: 10),
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: textColor,
                                                      ),
                                                      borderRadius:
                                                          const BorderRadius
                                                                  .all(
                                                              Radius.circular(
                                                                  40)),
                                                      color: Colors.white,
                                                    ),
                                                    child: Obx(() {
                                                      return messageTypingView(
                                                          context);
                                                    }),
                                                  ),
                                                ),
                                                Obx(() {
                                                  return controller
                                                          .isUserTyping.value
                                                      ? InkWell(
                                                          onTap: () {
                                                            controller
                                                                        .isAudioRecording
                                                                        .value ==
                                                                    Constants
                                                                        .audioRecordDone
                                                                ? controller
                                                                    .sendRecordedAudioMessage()
                                                                : controller
                                                                    .sendMessage(
                                                                        controller
                                                                            .profile);
                                                          },
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    left: 8.0,
                                                                    right: 8.0,
                                                                    bottom: 8),
                                                            child: SvgPicture.asset(
                                                                'assets/logos/send.svg'),
                                                          ))
                                                      : const SizedBox.shrink();
                                                }),
                                                Obx(() {
                                                  return controller
                                                              .isAudioRecording
                                                              .value ==
                                                          Constants
                                                              .audioRecording
                                                      ? InkWell(
                                                          onTap: () {
                                                            controller
                                                                .stopRecording();
                                                          },
                                                          child: const Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    bottom:
                                                                        8.0),
                                                            child:
                                                                LottieAnimation(
                                                              lottieJson:
                                                                  audioJson1,
                                                              showRepeat: true,
                                                              width: 54,
                                                              height: 54,
                                                            ),
                                                          ))
                                                      : const SizedBox.shrink();
                                                }),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                              ],
                                            ),
                                          ),
                                          emojiLayout(),
                                        ],
                                      )
                                    : userNoLonger(),
                          );
                        }),
                      ),
                    ],
                  ),
                  Obx(() {
                    return Visibility(
                      visible: controller.showHideRedirectToLatest.value,
                      child: Positioned(
                        bottom: controller.isReplying.value ? 160 : 100,
                        right: 0,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            controller.unreadCount.value != 0
                                ? CircleAvatar(
                                    radius: 8,
                                    child: Text(
                                      returnFormattedCount(
                                          controller.unreadCount.value),
                                      style: const TextStyle(
                                          fontSize: 9,
                                          color: Colors.white,
                                          fontFamily: 'sf_ui'),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                            IconButton(
                              icon: Image.asset(
                                redirectLastMessage,
                                width: 32,
                                height: 32,
                              ),
                              onPressed: () {
                                //scroll to end
                                controller.scrollToEnd();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  if (!controller.isTrail)
                    Obx(() {
                      return !controller.profile.isItSavedContact.checkNull()
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(
                                  width: 8,
                                ),
                                buttonNotSavedContact(
                                    text: 'Add',
                                    onClick: () {
                                      controller.saveContact();
                                    }),
                                const SizedBox(
                                  width: 8,
                                ),
                                buttonNotSavedContact(
                                    text:
                                        controller.profile.isBlocked.checkNull()
                                            ? 'UnBlock'
                                            : 'Block',
                                    onClick: () {
                                      if (controller.profile.isBlocked
                                          .checkNull()) {
                                        controller.unBlockUser();
                                      } else {
                                        controller.blockUser();
                                      }
                                    }),
                                const SizedBox(
                                  width: 8,
                                ),
                              ],
                            )
                          : const SizedBox.shrink();
                    })
                  else
                    const SizedBox.shrink()
                ],
              ),
            ),
          ),
        ));
  }

  Widget buttonNotSavedContact(
          {required String text, required Function()? onClick}) =>
      Expanded(
        child: InkWell(
          onTap: onClick,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            padding: const EdgeInsets.all(8.0),
            color: Colors.grey,
            child: Text(
              text,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );

  messageTypingView(BuildContext context) {
    return Row(
      children: <Widget>[
        controller.isAudioRecording.value == Constants.audioRecording ||
                controller.isAudioRecording.value == Constants.audioRecordDone
            ? Text(controller.timerInit.value,
                style: const TextStyle(color: buttonBgColor))
            : const SizedBox.shrink(),
        controller.isAudioRecording.value == Constants.audioRecordInitial
            ? InkWell(
                onTap: () {
                  controller.showHideEmoji(context);
                },
                child: controller.showEmoji.value
                    ? const Icon(
                        Icons.keyboard,
                        color: iconColor,
                      )
                    : SvgPicture.asset(smileIcon))
            : const SizedBox.shrink(),
        controller.isAudioRecording.value == Constants.audioRecordDelete
            ? const Padding(
                padding: EdgeInsets.all(13.0),
                child: LottieAnimation(
                  lottieJson: deleteDustbin,
                  showRepeat: false,
                  width: 25,
                  height: 25,
                ),
              )
            : const SizedBox.shrink(),
        const SizedBox(
          width: 10,
        ),
        controller.isAudioRecording.value == Constants.audioRecording
            ? Expanded(
                child: Dismissible(
                  key: UniqueKey(),
                  dismissThresholds: const {
                    DismissDirection.endToStart: 0.1,
                  },
                  confirmDismiss: (DismissDirection direction) async {
                    if (direction == DismissDirection.endToStart) {
                      controller.cancelRecording();
                      return true;
                    }
                    return false;
                  },
                  onUpdate: (details) {
                    mirrorFlyLog("dismiss", details.progress.toString());
                    if (details.progress > 0.5) {
                      controller.cancelRecording();
                    }
                  },
                  direction: DismissDirection.endToStart,
                  child: const Padding(
                    padding: EdgeInsets.only(right: 15.0),
                    child: SizedBox(
                        height: 50,
                        child: Align(
                            alignment: Alignment.centerRight,
                            child: Text('< Slide to Cancel',
                                textAlign: TextAlign.end))),
                  ),
                ),
              )
            : const SizedBox.shrink(),
        controller.isAudioRecording.value == Constants.audioRecordDone
            ? Expanded(
                child: InkWell(
                  onTap: () {
                    controller.deleteRecording();
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(17.0),
                    child: Text(
                      'Cancel',
                      textAlign: TextAlign.end,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
        controller.isAudioRecording.value == Constants.audioRecordInitial
            ? Expanded(
                child: TextField(
                  onChanged: (text) {
                    controller.isTyping(text);
                  },
                  style: const TextStyle(fontWeight: FontWeight.w400),
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                  maxLines: 5,
                  enabled: controller.isAudioRecording.value ==
                          Constants.audioRecordInitial
                      ? true
                      : false,
                  controller: controller.messageController,
                  focusNode: controller.focusNode,
                  decoration: const InputDecoration(
                      hintText: "Start Typing...", border: InputBorder.none),
                ),
              )
            : const SizedBox.shrink(),
        controller.isAudioRecording.value == Constants.audioRecordInitial
            ? IconButton(
                onPressed: () {
                  controller.showAttachmentsView(context);
                },
                icon: SvgPicture.asset('assets/logos/attach.svg'),
              )
            : const SizedBox.shrink(),
        controller.isAudioRecording.value == Constants.audioRecordInitial
            ? IconButton(
                onPressed: () {
                  controller.startRecording();
                },
                icon: SvgPicture.asset('assets/logos/mic.svg'),
              )
            : const SizedBox.shrink(),
        const SizedBox(
          width: 5,
        ),
      ],
    );
  }

  Widget userBlocked() {
    return Column(
      children: [
        const Divider(
          height: 1,
          thickness: 0.29,
          color: textBlackColor,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 15.0, bottom: 15.0, left: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "You have blocked ",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(
                width: 5,
              ),
              Flexible(
                child: Text(
                  getName(controller.profile),
                  //controller.profile.name.checkNull(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              InkWell(
                child: const Text(
                  'UNBLOCK',
                  style: TextStyle(
                      decoration: TextDecoration.underline, color: Colors.blue),
                ),
                onTap: () => controller.unBlockUser(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget userNoLonger() {
    return Column(
      children: const [
        Divider(
          height: 1,
          thickness: 0.29,
          color: textBlackColor,
        ),
        Padding(
          padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
          child: Text(
            "You can't send messages to this group because you're no longer a participant.",
            style: TextStyle(
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget emojiLayout() {
    return Obx(() {
      if (controller.showEmoji.value) {
        return SizedBox(
          height: 250,
          child: EmojiPicker(
            onBackspacePressed: () {
              controller.isTyping();
              // Do something when the user taps the backspace button (optional)
            },
            onEmojiSelected: (cat, emoji) {
              controller.isTyping();
            },
            textEditingController: controller.messageController,
            config: Config(
              columns: 7,
              emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
              verticalSpacing: 0,
              horizontalSpacing: 0,
              gridPadding: EdgeInsets.zero,
              initCategory: Category.RECENT,
              bgColor: const Color(0xFFF2F2F2),
              indicatorColor: Colors.blue,
              iconColor: Colors.grey,
              iconColorSelected: Colors.blue,
              backspaceColor: Colors.blue,
              skinToneDialogBgColor: Colors.white,
              skinToneIndicatorColor: Colors.grey,
              enableSkinTones: true,
              // showRecentsTab: true,
              recentsLimit: 28,
              tabIndicatorAnimDuration: kTabScrollDuration,
              categoryIcons: const CategoryIcons(),
              buttonMode: ButtonMode.CUPERTINO,
            ),
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  Widget chatListView(List<ChatMessageModel> chatList) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollEndNotification) {
            controller.loadNextChatHistory();
          }
          return false;
        },
        child: ScrollablePositionedList.builder(
          itemScrollController: controller.newScrollController,
          itemPositionsListener: controller.newitemPositionsListener,
          itemCount: chatList.length,
          shrinkWrap: true,
          reverse: true,
          itemBuilder: (context, pos) {
              var index= pos;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Visibility(
                      visible: (controller.loadNextData.value && pos==chatList.length-1) ,//|| (controller.loadPreviousData.value && pos==chatList.length-1) ,
                      child: const Center(
                        child: CircularProgressIndicator()
                      )),
                  groupedDateMessage(index, chatList) != null
                      ? NotificationMessageView(
                          chatMessage: groupedDateMessage(index, chatList))
                      : const SizedBox.shrink(),
                  (chatList[index].messageType.toUpperCase() !=
                          Constants.mNotification)
                      ? SwipeTo(
                          key: ValueKey(chatList[index].messageId),
                          onRightSwipe: () {
                            if (!chatList[index].isMessageRecalled.value &&
                                !chatList[index].isMessageDeleted &&
                                chatList[index]
                                        .messageStatus
                                        .value
                                        .checkNull()
                                        .toString() !=
                                    "N") {
                              controller
                                  .handleReplyChatMessage(chatList[index]);
                            }
                          },
                          animationDuration: const Duration(milliseconds: 300),
                          offsetDx: 0.2,
                          child: GestureDetector(
                            onLongPress: () {
                              debugPrint("LongPressed");
                              FocusManager.instance.primaryFocus?.unfocus();
                              if (!controller.isSelected.value) {
                                controller.isSelected(true);
                                controller.addChatSelection(chatList[index]);
                              }
                            },
                            onTap: () {
                              debugPrint("On Tap");
                              if (controller.isSelected.value) {
                                controller.isSelected.value
                                    ? controller.selectedChatList
                                            .contains(chatList[index])
                                        ? controller
                                            .clearChatSelection(chatList[index])
                                        : controller
                                            .addChatSelection(chatList[index])
                                    : null;
                                controller.getMessageActions();
                              } else {
                                var replyChat =
                                    chatList[index].replyParentChatMessage;
                                if (replyChat != null) {
                                  debugPrint("reply tap ");
                                  var chat = chatList.indexWhere((element) =>
                                      element.messageId == replyChat.messageId);
                                  if (!chat.isNegative) {
                                    controller.navigateToMessage(chatList[chat],
                                        index: chat);
                                  }
                                }
                              }
                            },
                            onDoubleTap: () {
                              controller.translateMessage(index);
                            },
                            child: Obx(() {
                              return Container(
                                key: Key(chatList[index].messageId),
                                color: chatList[index].isSelected.value
                                    ? chatReplyContainerColor
                                    : Colors.transparent,
                                margin: const EdgeInsets.only(
                                    left: 14, right: 14, top: 5, bottom: 10),
                                child: Align(
                                  alignment: (chatList[index].isMessageSentByMe
                                      ? Alignment.bottomRight
                                      : Alignment.bottomLeft),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Visibility(
                                        visible: chatList[index]
                                                .isMessageSentByMe &&
                                            controller.forwardMessageVisibility(
                                                chatList[index]),
                                        child: IconButton(
                                            onPressed: () {
                                              controller.forwardSingleMessage(
                                                  chatList[index].messageId);
                                            },
                                            icon:
                                                SvgPicture.asset(forwardMedia)),
                                      ),
                                      Container(
                                        constraints: BoxConstraints(
                                            maxWidth:
                                                controller.screenWidth * 0.75),
                                        decoration: BoxDecoration(
                                            borderRadius: chatList[index]
                                                    .isMessageSentByMe
                                                ? const BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(10),
                                                    topRight:
                                                        Radius.circular(10),
                                                    bottomLeft:
                                                        Radius.circular(10))
                                                : const BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(10),
                                                    topRight:
                                                        Radius.circular(10),
                                                    bottomRight:
                                                        Radius.circular(10)),
                                            color: (chatList[index]
                                                    .isMessageSentByMe
                                                ? chatSentBgColor
                                                : Colors.white),
                                            border: chatList[index]
                                                    .isMessageSentByMe
                                                ? Border.all(
                                                    color: chatSentBgColor)
                                                : Border.all(
                                                    color: chatBorderColor)),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SenderHeader(
                                                isGroupProfile: controller
                                                    .profile.isGroupProfile,
                                                chatList: chatList,
                                                index: index),
                                            chatList[index].isThisAReplyMessage ? chatList[index].replyParentChatMessage == null
                                                ? messageNotAvailableWidget(chatList[index])
                                                : ReplyMessageHeader(
                                                    chatMessage:
                                                        chatList[index]) : const SizedBox.shrink(),
                                            Obx(() {
                                              return MessageContent(
                                                  chatList: chatList,
                                                  index: index,
                                                  onPlayAudio: () {
                                                    if (controller
                                                            .isAudioRecording
                                                            .value ==
                                                        Constants
                                                            .audioRecording) {
                                                      controller
                                                          .stopRecording();
                                                    }
                                                    controller.playAudio(
                                                        chatList[index]);
                                                  },
                                                  onSeekbarChange:
                                                      (double value) {
                                                    controller.onSeekbarChange(
                                                        value, chatList[index]);
                                                  },
                                                  isSelected: controller
                                                      .isSelected.value);
                                            })
                                          ],
                                        ),
                                      ),
                                      Visibility(
                                        visible: !chatList[index]
                                                .isMessageSentByMe &&
                                            controller.forwardMessageVisibility(
                                                chatList[index]),
                                        child: IconButton(
                                            onPressed: () {
                                              controller.forwardSingleMessage(
                                                  chatList[index].messageId);
                                            },
                                            icon:
                                                SvgPicture.asset(forwardMedia)),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        )
                      : NotificationMessageView(
                          chatMessage: chatList[index].messageTextContent),
                  Visibility(
                      visible: (controller.loadPreviousData.value && pos==0) ,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      )),
                ],
              );
          },
        ),
      ),
    );
  }

  selectedAppBar() {
    return AppBar(
      // leadingWidth: 25,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          controller.clearAllChatSelection();
        },
      ),
      title: Text(controller.selectedChatList.length.toString()),
      actions: [
        CustomActionBarIcons(
            availableWidth: controller.screenWidth / 2, // half the screen width
            actionWidth: 48, // default for IconButtons
            actions: [
              // controller.getOptionStatus('Reply')
              CustomAction(
                visibleWidget: IconButton(
                  onPressed: () {
                    controller
                        .handleReplyChatMessage(controller.selectedChatList[0]);
                    controller
                        .clearChatSelection(controller.selectedChatList[0]);
                  },
                  icon: SvgPicture.asset(replyIcon),
                  tooltip: 'Reply',
                ),
                overflowWidget: const Text("Reply"),
                showAsAction: controller.canBeReplied.value
                    ? ShowAsAction.always
                    : ShowAsAction.gone,
                keyValue: 'Reply',
                onItemClick: () {
                  controller.closeKeyBoard();
                  controller
                      .handleReplyChatMessage(controller.selectedChatList[0]);
                  controller.clearChatSelection(controller.selectedChatList[0]);
                },
              ),
              CustomAction(
                visibleWidget: IconButton(
                  onPressed: () {
                    controller.checkBusyStatusForForward();
                  },
                  icon: SvgPicture.asset(forwardIcon),
                  tooltip: 'Forward',
                ),
                overflowWidget: const Text("Forward"),
                showAsAction: controller.canBeForwarded.value
                    ? ShowAsAction.always
                    : ShowAsAction.gone,
                keyValue: 'Forward',
                onItemClick: () {
                  controller.closeKeyBoard();
                  controller.checkBusyStatusForForward();
                },
              ),
              /*controller.getOptionStatus('Favourite')
                  ?
                  : customEmptyAction(),*/
              CustomAction(
                visibleWidget: IconButton(
                  onPressed: () {
                    controller.favouriteMessage();
                  },
                  // icon: controller.getOptionStatus('Favourite') ? const Icon(Icons.star_border_outlined)
                  // icon: controller.selectedChatList[0].isMessageStarred
                  icon: SvgPicture.asset(favouriteIcon),
                  tooltip: 'Favourite',
                ),
                overflowWidget: const Text("Favourite"),
                showAsAction: controller.canBeStarred.value
                    ? ShowAsAction.always
                    : ShowAsAction.gone,
                keyValue: 'favourite',
                onItemClick: () {
                  controller.closeKeyBoard();
                  controller.favouriteMessage();
                },
              ),
              CustomAction(
                visibleWidget: IconButton(
                  onPressed: () {
                    controller.favouriteMessage();
                  },
                  // icon: controller.getOptionStatus('Favourite') ? const Icon(Icons.star_border_outlined)
                  // icon: controller.selectedChatList[0].isMessageStarred
                  icon: SvgPicture.asset(unFavouriteIcon),
                  tooltip: 'unFavourite',
                ),
                overflowWidget: const Text("unFavourite"),
                showAsAction: controller.canBeUnStarred.value
                    ? ShowAsAction.always
                    : ShowAsAction.gone,
                keyValue: 'favourite',
                onItemClick: () {
                  controller.closeKeyBoard();
                  controller.favouriteMessage();
                },
              ),
              CustomAction(
                visibleWidget: IconButton(
                  onPressed: () {
                    controller.deleteMessages();
                  },
                  icon: SvgPicture.asset(deleteIcon),
                  tooltip: 'Delete',
                ),
                overflowWidget: const Text("Delete"),
                showAsAction: ShowAsAction.always,
                keyValue: 'Delete',
                onItemClick: () {
                  controller.closeKeyBoard();
                  controller.deleteMessages();
                },
              ),
              /*controller.getOptionStatus('Report')
                  ?
                  : customEmptyAction(),*/
              CustomAction(
                visibleWidget: IconButton(
                    onPressed: () {
                      controller.reportChatOrUser();
                    },
                    icon: const Icon(Icons.report_problem_rounded)),
                overflowWidget: const Text("Report"),
                showAsAction: controller.canShowReport.value
                    ? ShowAsAction.never
                    : ShowAsAction.gone,
                keyValue: 'Report',
                onItemClick: () {
                  controller.closeKeyBoard();
                  controller.reportChatOrUser();
                },
              ),
              /*controller.selectedChatList.length > 1 ||
                      controller.selectedChatList[0].messageType !=
                          Constants.mText
                  ? customEmptyAction()
                  : ,*/
              CustomAction(
                visibleWidget: IconButton(
                  onPressed: () {
                    controller.closeKeyBoard();
                    controller.copyTextMessages();
                  },
                  icon: SvgPicture.asset(
                    copyIcon,
                    fit: BoxFit.contain,
                  ),
                  tooltip: 'Copy',
                ),
                overflowWidget: const Text("Copy"),
                showAsAction: controller.canBeCopied.value
                    ? ShowAsAction.never
                    : ShowAsAction.gone,
                keyValue: 'Copy',
                onItemClick: () {
                  controller.closeKeyBoard();
                  controller.copyTextMessages();
                },
              ),
              /*controller.getOptionStatus('Message Info')
                  ?
                  : customEmptyAction(),*/
              CustomAction(
                visibleWidget: IconButton(
                  onPressed: () {
                    // Get.back();
                    controller.messageInfo();
                  },
                  icon: SvgPicture.asset(
                    infoIcon,
                    fit: BoxFit.contain,
                  ),
                  tooltip: 'Message Info',
                ),
                overflowWidget: const Text("Message Info"),
                showAsAction: controller.canShowInfo.value
                    ? ShowAsAction.never
                    : ShowAsAction.gone,
                keyValue: 'MessageInfo',
                onItemClick: () {
                  controller.closeKeyBoard();
                  controller.messageInfo();
                },
              ),
              /*controller.getOptionStatus('Share')
                  ?
                  : customEmptyAction(),*/
              CustomAction(
                visibleWidget: IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset(shareIcon),
                  tooltip: 'Share',
                ),
                overflowWidget: const Text("Share"),
                showAsAction: controller.canBeShared.value
                    ? ShowAsAction.never
                    : ShowAsAction.gone,
                keyValue: 'Share',
                onItemClick: () {
                  controller.closeKeyBoard();
                  controller.share();
                },
              ),
            ]),
      ],
    );
  }

  chatAppBar() {
    return Obx(() {
      return AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 80,
        leading: InkWell(
          onTap: () {
            if (controller.showEmoji.value) {
              controller.showEmoji(false);
            } else if (controller.nJid != null) {
              Get.offAllNamed(Routes.dashboard);
            } else {
              Get.back();
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 10,
              ),
              const Icon(Icons.arrow_back),
              const SizedBox(
                width: 10,
              ),
              ImageNetwork(
                url: controller.profile.image.checkNull(),
                width: 35,
                height: 35,
                clipOval: true,
                isGroup: controller.profile.isGroupProfile.checkNull(),
                errorWidget: controller.profile.isGroupProfile ?? false
                    ? ClipOval(
                        child: Image.asset(
                          groupImg,
                          height: 35,
                          width: 35,
                          fit: BoxFit.cover,
                        ),
                      )
                    : ProfileTextImage(
                        text: getName(controller.profile),
                        /*controller.profile.name.checkNull().isEmpty
                            ? controller.profile.nickName.checkNull().isEmpty
                                ? controller.profile.mobileNumber.checkNull()
                                : controller.profile.nickName.checkNull()
                            : controller.profile.name.checkNull(),*/
                        radius: 18,
                      ),
                blocked: controller.profile.isBlockedMe.checkNull() ||
                    controller.profile.isAdminBlocked.checkNull(),
                unknown: (!controller.profile.isItSavedContact.checkNull() ||
                    controller.profile.isDeletedContact()),
              ),
            ],
          ),
        ),
        title: SizedBox(
          width: (controller.screenWidth) / 1.9,
          child: InkWell(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  getName(controller.profile),
                  /*controller.profile.name.checkNull().isEmpty
                      ? controller.profile.nickName.checkNull()
                      : controller.profile.name.checkNull(),*/
                  overflow: TextOverflow.fade,
                ),
                Obx(() {
                  return controller.groupParticipantsName.isNotEmpty
                      ? SizedBox(
                          width: (controller.screenWidth) * 0.90,
                          height: 15,
                          child: Marquee(
                              text:
                                  "${controller.groupParticipantsName}       ",
                              style: const TextStyle(fontSize: 12)))
                      : controller.subtitle.isNotEmpty
                          ? Text(
                              controller.subtitle,
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.fade,
                            )
                          : const SizedBox();
                })
              ],
            ),
            onTap: () {
              mirrorFlyLog("title clicked",
                  controller.profile.isGroupProfile.toString());
              controller.infoPage();
            },
          ),
        ),
        actions: [
          CustomActionBarIcons(
            availableWidth: controller.screenWidth / 2, // half the screen width
            actionWidth: 48, // default for IconButtons
            actions: [
              CustomAction(
                visibleWidget: IconButton(
                  onPressed: () {
                    controller.clearUserChatHistory();
                  },
                  icon: const Icon(Icons.cancel),
                ),
                overflowWidget: const Text("Clear Chat"),
                showAsAction: ShowAsAction.never,
                keyValue: 'Clear Chat',
                onItemClick: () {
                  controller.closeKeyBoard();
                  debugPrint("Clear chat tap");
                  controller.clearUserChatHistory();
                },
              ),
              CustomAction(
                visibleWidget: IconButton(
                  onPressed: () {
                    controller.reportChatOrUser();
                  },
                  icon: const Icon(Icons.report_problem_rounded),
                ),
                overflowWidget: const Text("Report"),
                showAsAction: ShowAsAction.never,
                keyValue: 'Report',
                onItemClick: () {
                  controller.closeKeyBoard();
                  controller.reportChatOrUser();
                },
              ),
              controller.isBlocked.value
                  ? CustomAction(
                      visibleWidget: IconButton(
                        onPressed: () {
                          // Get.back();
                          controller.unBlockUser();
                        },
                        icon: const Icon(Icons.block),
                      ),
                      overflowWidget: const Text("Unblock"),
                      showAsAction: ShowAsAction.never,
                      keyValue: 'Unblock',
                      onItemClick: () {
                        debugPrint('onItemClick unblock');
                        controller.unBlockUser();
                      },
                    )
                  : CustomAction(
                      visibleWidget: IconButton(
                        onPressed: () {
                          // Get.back();
                          controller.blockUser();
                        },
                        icon: const Icon(Icons.block),
                      ),
                      overflowWidget: const Text("Block"),
                      showAsAction: controller.profile.isGroupProfile ?? false
                          ? ShowAsAction.gone
                          : ShowAsAction.never,
                      keyValue: 'Block',
                      onItemClick: () {
                        controller.closeKeyBoard();
                        controller.blockUser();
                      },
                    ),
              CustomAction(
                visibleWidget: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.search),
                ),
                overflowWidget: const Text("Search"),
                showAsAction: ShowAsAction.never,
                keyValue: 'Search',
                onItemClick: () {
                  controller.closeKeyBoard();
                  controller.gotoSearch();
                },
              ),
              CustomAction(
                visibleWidget: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.email_outlined),
                ),
                overflowWidget: GestureDetector(
                  onTap: () {
                    controller.closeKeyBoard();
                    controller.exportChat();
                  },
                  child: const Text("Email Chat"),
                ),
                showAsAction: ShowAsAction.never,
                keyValue: 'EmailChat',
                onItemClick: () {
                  controller.closeKeyBoard();
                  controller.exportChat();
                },
              ),
              CustomAction(
                visibleWidget: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.shortcut),
                ),
                overflowWidget: const Text("Add Chat Shortcut"),
                showAsAction: ShowAsAction.never,
                keyValue: 'Shortcut',
                onItemClick: () {
                  controller.closeKeyBoard();
                },
              ),
              /*CustomAction(
                visibleWidget: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.call),
                ),
                overflowWidget: const Text("Call"),
                showAsAction: ShowAsAction.always,
                keyValue: 'Shortcut',
                onItemClick: () {
                  controller.makeVoiceCall();
                },
              ),*/
            ],
          ),
        ],
      );
    });
  }

  getAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(55.0),
      child: Obx(() {
        return Container(
          child: controller.isSelected.value ? selectedAppBar() : chatAppBar(),
        );
      }),
    );
  }

  customEmptyAction() {
    return CustomAction(
        visibleWidget: const SizedBox.shrink(),
        overflowWidget: const SizedBox.shrink(),
        showAsAction: ShowAsAction.always,
        keyValue: 'Empty',
        onItemClick: () {});
  }
}
