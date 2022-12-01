import 'dart:convert';
import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:marquee/marquee.dart';
import 'package:mirror_fly_demo/app/common/widgets.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/data/permissions.dart';

import 'package:mirror_fly_demo/app/routes/app_pages.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/constants.dart';
import '../../../widgets/custom_action_bar_icons.dart';
import '../../../widgets/lottie_animation.dart';
import '../controllers/chat_controller.dart';
import 'package:flysdk/flysdk.dart';
import 'dart:math' as math;


class ChatView extends GetView<ChatController> {
  ChatView({Key? key}) : super(key: key);

  final ImagePicker _picker = ImagePicker();

  late final dynamic _pickImageError;

  @override
  Widget build(BuildContext context) {
    controller.screenHeight = MediaQuery.of(context).size.height;
    controller.screenWidth = MediaQuery.of(context).size.width;
    return KeyboardDismisser(
      child: Scaffold(
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
                  mirrorFlyLog("viewInsets", MediaQuery.of(context).viewInsets.bottom.toString());
                  if (controller.showEmoji.value) {
                    controller.showEmoji(false);
                  } else if (MediaQuery.of(context).viewInsets.bottom > 0.0) {
                    //FocusManager.instance.primaryFocus?.unfocus();
                    controller.focusNode.unfocus();
                  } else {
                    //Get.offAllNamed(Routes.DASHBOARD);
                    //Get.back();
                    return Future.value(true);
                  }
                  return Future.value(false);
                },
                child: Column(
                  children: [
                    Expanded(
                      child:
                        Obx(() {
                          return chatListView(controller.chatList);
                        })
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Obx(() {
                        return Container(
                          color: Colors.white,
                          child: controller.isBlocked.value
                              ? userBlocked()
                              : !controller.isMemberOfGroup
                                  ? userNoLonger()
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        replyMessageHeader(context),
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
                                                  margin: const EdgeInsets.only(
                                                      left: 10,
                                                      right: 10,
                                                      bottom: 10),
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: textColor,
                                                    ),
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                40)),
                                                    color: Colors.white,
                                                  ),
                                                  child: Obx(() {
                                                    return Row(
                                                      // mainAxisAlignment: MainAxisAlignment.end,
                                                      children: <Widget>[
                                                        controller.isAudioRecording
                                                                        .value ==
                                                                    Constants
                                                                        .audioRecording ||
                                                                controller
                                                                        .isAudioRecording
                                                                        .value ==
                                                                    Constants
                                                                        .audioRecordDone
                                                            ? Text(
                                                                controller
                                                                    .timerInit
                                                                    .value,
                                                                style: const TextStyle(
                                                                    color:
                                                                        buttonBgColor))
                                                            : const SizedBox
                                                                .shrink(),
                                                        controller.isAudioRecording
                                                                    .value ==
                                                                Constants
                                                                    .audioRecordInitial
                                                            ? InkWell(
                                                                onTap: () {
                                                                  if (!controller
                                                                      .showEmoji
                                                                      .value) {
                                                                    FocusScope.of(
                                                                            context)
                                                                        .unfocus();
                                                                    controller
                                                                        .focusNode
                                                                        .canRequestFocus = false;
                                                                  }
                                                                  Future.delayed(
                                                                      const Duration(
                                                                          milliseconds:
                                                                              500),
                                                                      () {
                                                                    controller.showEmoji(!controller
                                                                        .showEmoji
                                                                        .value);
                                                                  });
                                                                },
                                                                child: SvgPicture
                                                                    .asset(
                                                                        'assets/logos/smile.svg'))
                                                            : const SizedBox
                                                                .shrink(),
                                                        controller.isAudioRecording
                                                                    .value ==
                                                                Constants
                                                                    .audioRecordDelete
                                                            ? const Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            13.0),
                                                                child:
                                                                    LottieAnimation(
                                                                  lottieJson:
                                                                      deleteDustbin,
                                                                  showRepeat:
                                                                      false,
                                                                  width: 25,
                                                                  height: 25,
                                                                ),
                                                              )
                                                            : const SizedBox
                                                                .shrink(),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        controller.isAudioRecording
                                                                    .value ==
                                                                Constants
                                                                    .audioRecording
                                                            ? Expanded(
                                                                child:
                                                                    Dismissible(
                                                                  key:
                                                                      UniqueKey(),
                                                                      dismissThresholds: const {
                                                                        DismissDirection.endToStart: 0.1,
                                                                      },
                                                                  // movementDuration: const Duration(milliseconds: 150),
                                                    // dragStartBehavior: DragStartBehavior.down,
                                                    // crossAxisEndOffset: 0.5,
                                                    //                   behavior: HitTestBehavior.,
                                                                  confirmDismiss:
                                                                      (DismissDirection
                                                                          direction) async {
                                                                    if (direction ==
                                                                        DismissDirection
                                                                            .endToStart) {
                                                                      controller
                                                                          .cancelRecording();
                                                                      return true;
                                                                    }
                                                                    return false;
                                                                  },
                                                                      onUpdate: (details){
                                                                    mirrorFlyLog("dismiss", details.progress.toString());
                                                                    if(details.progress>0.5){
                                                                      controller
                                                                          .cancelRecording();
                                                                    }
                                                                      },
                                                                  direction:
                                                                      DismissDirection
                                                                          .endToStart,
                                                                      child: const Padding(padding: EdgeInsets.only(right: 15.0),
                                                                      child: SizedBox(
                                                                        height: 50,
                                                                          child: Align(alignment: Alignment.centerRight,
                                                                              child: Text('< Slide to Cancel', textAlign: TextAlign.end))),
                                                                  ),
                                                                ),
                                                              )
                                                            : const SizedBox
                                                                .shrink(),
                                                        controller.isAudioRecording
                                                                    .value ==
                                                                Constants
                                                                    .audioRecordDone
                                                            ? Expanded(
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    controller
                                                                        .deleteRecording();
                                                                  },
                                                                  child:
                                                                      const Padding(padding: EdgeInsets.all(17.0),
                                                                        child: Text('Cancel', textAlign: TextAlign.end, style: TextStyle(color: Colors.red),
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
                                                            : const SizedBox
                                                                .shrink(),
                                                        controller.isAudioRecording
                                                                    .value ==
                                                                Constants
                                                                    .audioRecordInitial
                                                            ? Expanded(
                                                                child: SizedBox(
                                                                  height: 50,
                                                                  child:
                                                                      TextField(
                                                                    onChanged:
                                                                        (text) {
                                                                      controller
                                                                          .isTyping(
                                                                              text);
                                                                    },
                                                                    keyboardType:
                                                                        TextInputType
                                                                            .multiline,
                                                                    minLines: 1,
                                                                    maxLines: 4,
                                                                    enabled: controller.isAudioRecording.value ==
                                                                            Constants.audioRecordInitial
                                                                        ? true
                                                                        : false,
                                                                    controller:
                                                                        controller
                                                                            .messageController,
                                                                    focusNode:
                                                                        controller
                                                                            .focusNode,
                                                                    decoration: const InputDecoration(
                                                                        hintText:
                                                                            "Start Typing...",
                                                                        border:
                                                                            InputBorder.none),
                                                                  ),
                                                                ),
                                                              )
                                                            : const SizedBox
                                                                .shrink(),
                                                        controller.isAudioRecording
                                                                    .value ==
                                                                Constants
                                                                    .audioRecordInitial
                                                            ? IconButton(
                                                                onPressed:
                                                                    () async {
                                                                  if (await controller.askStoragePermission()) {
                                                                    showModalBottomSheet(
                                                                        backgroundColor: Colors.transparent,
                                                                        context: context,
                                                                        builder: (builder) => bottomSheet(context));
                                                                  }
                                                                },
                                                                icon: SvgPicture
                                                                    .asset(
                                                                        'assets/logos/attach.svg'),
                                                              )
                                                            : const SizedBox
                                                                .shrink(),
                                                        controller.isAudioRecording
                                                                    .value ==
                                                                Constants
                                                                    .audioRecordInitial
                                                            ? IconButton(
                                                                onPressed:
                                                                    () async {
                                                                  if (await controller
                                                                      .askStoragePermission()) {
                                                                    controller
                                                                        .startRecording();
                                                                  }
                                                                },
                                                                icon: SvgPicture
                                                                    .asset(
                                                                        'assets/logos/mic.svg'),
                                                              )
                                                            : const SizedBox
                                                                .shrink(),
                                                        const SizedBox(
                                                          width: 5,
                                                        ),
                                                      ],
                                                    );
                                                  }),
                                                ),
                                              ),
                                              Obx(() {
                                                return controller
                                                        .isUserTyping.value
                                                    ? InkWell(
                                                        onTap: () {
                                                          controller.isAudioRecording
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
                                                        Constants.audioRecording
                                                    ? InkWell(
                                                        onTap: () {
                                                          controller
                                                              .stopRecording();
                                                        },
                                                        child: const Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  bottom: 8.0),
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
                                    ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          )),
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
          padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "You have blocked ${controller.profile.name}.",
                style: const TextStyle(fontSize: 15),
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
            onEmojiSelected: (cat,emoji){
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
              showRecentsTab: true,
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
      child: ListView.builder(
        controller: controller.scrollController,
        itemCount: chatList.length,
        shrinkWrap: true,
        reverse: false,
        itemBuilder: (context, index) {
          // int reversedIndex = chatList.length - 1 - index;
          if (chatList[index].messageType != Constants.mNotification) {
            return SwipeTo(
              key: ValueKey(chatList[index].messageId),
              onRightSwipe: () {
                var swipeList = controller.chatList.toList();
                controller.handleReplyChatMessage(swipeList[index]);
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
                  controller.isSelected.value
                      ? controller.selectedChatList.contains(chatList[index])
                          ? controller.clearChatSelection(chatList[index])
                          : controller.addChatSelection(chatList[index])
                      : null;
                },
                child: Obx(() {
                  return Container(
                    key: Key(chatList[index].messageId),
                    color: controller.isSelected.value &&
                            chatList[index].isSelected &&
                            controller.selectedChatList.isNotEmpty
                        ? chatReplyContainerColor
                        : Colors.transparent,
                    margin: const EdgeInsets.only(
                        left: 14, right: 14, top: 5, bottom: 10),
                    child: Align(
                      alignment: (chatList[index].isMessageSentByMe
                          ? Alignment.bottomRight
                          : Alignment.bottomLeft),
                      child: Container(
                        constraints:
                            BoxConstraints(maxWidth: controller.screenWidth * 0.75),
                        decoration: BoxDecoration(
                            borderRadius: chatList[index].isMessageSentByMe
                                ? const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomLeft: Radius.circular(10))
                                : const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                    bottomRight: Radius.circular(10)),
                            color: (chatList[index].isMessageSentByMe
                                ? chatSentBgColor
                                : Colors.white),
                            border: chatList[index].isMessageSentByMe
                                ? Border.all(color: chatSentBgColor)
                                : Border.all(color: chatBorderColor)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            getMessageHeader(chatList[index], context),
                            sender(chatList, index),
                            getMessageContent(index, context, chatList),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          } else {
            return Center(
              child: Container(
                margin: const EdgeInsets.all(4),
                padding:
                    const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
                decoration: const BoxDecoration(
                    color: notificationTextBgColor,
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                child: Text(chatList[index].messageTextContent ?? "",
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: notificationTextColor)),
              ),
            );
          }
        },
      ),
    );
  }

  Widget sender(List<ChatMessageModel> chatList, int index) {
    return Visibility(
      visible: controller.profile.isGroupProfile!
          ? (index == 0 ||
                  isSenderChanged(chatList, index) ||
                  !isMessageDateEqual(chatList, index)) &&
              !chatList[index].isMessageSentByMe
          : false,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0, right: 8.0, left: 8.0),
        child: Text(
          chatList[index].senderNickName.checkNull(),
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(Helper.getColourCode(
                  chatList[index].senderNickName.checkNull()))),
        ),
      ),
    );
  }

  bool isSenderChanged(List<ChatMessageModel> messageList, int position) {
    var preposition = position - 1;
    if (!preposition.isNegative) {
      var currentMessage = messageList[position];
      var previousMessage = messageList[position - 1];
      if (currentMessage.isMessageSentByMe !=
              previousMessage.isMessageSentByMe ||
          previousMessage.messageType == Constants.msgTypeNotification ||
          (currentMessage.messageChatType == Constants.typeGroupChat &&
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

  bool checkIsNotNotification(ChatMessageModel messageItem) {
    var msgType = messageItem.messageType;
    return msgType != Constants.mNotification;
  }

  ChatMessageModel? getPreviousMessage(
      List<ChatMessageModel> messageList, int position) {
    return (position > 0) ? messageList[position - 1] : null;
  }

  getMessageIndicator(
      String? messageStatus, bool isSender, String messageType) {
    // debugPrint("Message Type ==> $messageType");
    if (isSender) {
      if (messageStatus == 'A') {
        return SvgPicture.asset('assets/logos/acknowledged.svg');
      } else if (messageStatus == 'D') {
        return SvgPicture.asset('assets/logos/delivered.svg');
      } else if (messageStatus == 'S') {
        return SvgPicture.asset('assets/logos/seen.svg');
      } else {
        return const Icon(
          Icons.access_time_filled,
          size: 10,
          color: Colors.red,
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  getMessageContent(
      int index, BuildContext context, List<ChatMessageModel> chatList) {
    debugPrint(json.encode(chatList[index]));
    if (chatList[index].isMessageRecalled) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisSize: chatList[index].replyParentChatMessage == null
              ? MainAxisSize.min
              : MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                Image.asset(
                  disabledIcon,
                  width: 15,
                  height: 15,
                ),
                const SizedBox(width: 10),
                Text(
                  chatList[index].isMessageSentByMe
                      ? "You deleted this message"
                      : "This message was deleted",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(
              width: 10,
            ),
            Row(
              children: [
                Text(
                  controller.getChatTime(
                      context, chatList[index].messageSentTime),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      if (chatList[index].messageType == Constants.mText) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisSize: chatList[index].replyParentChatMessage == null
                ? MainAxisSize.min
                : MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  chatList[index].messageTextContent ?? "",
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Row(
                children: [
                  chatList[index].isMessageStarred
                      ? const Icon(
                          Icons.star,
                          size: 13,
                        )
                      : const SizedBox.shrink(),
                  const SizedBox(
                    width: 5,
                  ),
                  getMessageIndicator(
                      chatList[index].messageStatus.status,
                      chatList[index].isMessageSentByMe,
                      chatList[index].messageType),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    controller.getChatTime(
                        context, chatList[index].messageSentTime),
                    style: const TextStyle(fontSize: 11, color: chatTimeColor),
                  ),
                ],
              ),
            ],
          ),
        );
      } else if (chatList[index].messageType == Constants.mNotification) {
        return Center(
          child: Container(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(40)),
                color: chatReplyContainerColor),
            padding: const EdgeInsets.only(
                left: 15.0, right: 15.0, top: 8.0, bottom: 8.0),
            // child: Text(chatList[index].messageTextContent!,
            child: Text(chatList[index].messageTextContent ?? "",
                style: const TextStyle(fontSize: 12)),
          ),
        );
      } else if (chatList[index].messageType == Constants.mImage) {
        if(chatList[index].mediaChatMessage == null){
          return const SizedBox.shrink();
        }
        var chatMessage = chatList[index].mediaChatMessage!;
        //mediaLocalStoragePath
        //mediaThumbImage
        return Padding(
          padding: const EdgeInsets.all(2.0),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: getImage(
                    chatMessage.mediaLocalStoragePath,
                    chatMessage.mediaThumbImage,
                    context,
                    chatMessage.mediaFileName),
              ),
              Positioned(
                  top: (controller.screenHeight * 0.4) / 2.5,
                  left: (controller.screenWidth * 0.6) / 3,
                  child: InkWell(
                      onTap: () {
                        handleMediaUploadDownload(
                            chatMessage.mediaDownloadStatus, chatList[index]);
                      },
                      child: getImageOverlay(chatList, index, context))),
              Positioned(
                bottom: 8,
                right: 10,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    chatList[index].isMessageStarred
                        ? const Icon(
                            Icons.star,
                            size: 13,
                          )
                        : const SizedBox.shrink(),
                    const SizedBox(
                      width: 5,
                    ),
                    getMessageIndicator(
                        chatList[index].messageStatus.status,
                        chatList[index].isMessageSentByMe,
                        chatList[index].messageType),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      controller.getChatTime(
                          context, chatList[index].messageSentTime),
                      style: const TextStyle(fontSize: 11, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      } else if (chatList[index].messageType == Constants.mVideo) {
        if(chatList[index].mediaChatMessage == null){
          return const SizedBox.shrink();
        }
        var chatMessage = chatList[index].mediaChatMessage!;
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              InkWell(
                onTap: () {
                  if (controller.checkFile(chatMessage.mediaLocalStoragePath) &&
                      (chatMessage.mediaDownloadStatus ==
                              Constants.mediaDownloaded ||
                          chatMessage.mediaDownloadStatus ==
                              Constants.mediaUploaded)) {
                    Get.toNamed(Routes.VIDEO_PLAY, arguments: {
                      "filePath": chatMessage.mediaLocalStoragePath,
                    });
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: controller.imageFromBase64String(
                      chatMessage.mediaThumbImage, context, null, null),
                ),
              ),
              Positioned(
                  top: (controller.screenHeight * 0.4) / 2.6,
                  left: (controller.screenWidth * 0.6) / 2.9,
                  child: InkWell(
                      onTap: () {
                        handleMediaUploadDownload(
                            chatMessage.mediaDownloadStatus, chatList[index]);
                      },
                      child: getImageOverlay(chatList, index, context))),
              Positioned(
                bottom: 8,
                right: 10,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    chatList[index].isMessageStarred
                        ? const Icon(
                            Icons.star,
                            size: 13,
                          )
                        : const SizedBox.shrink(),
                    const SizedBox(
                      width: 5,
                    ),
                    getMessageIndicator(
                        chatList[index].messageStatus.status,
                        chatList[index].isMessageSentByMe,
                        chatList[index].messageType),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      controller.getChatTime(
                          context, chatList[index].messageSentTime),
                      style: const TextStyle(fontSize: 11, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      } else if (chatList[index].messageType == Constants.mDocument) {
        if(chatList[index].mediaChatMessage == null){
          return const SizedBox.shrink();
        }
        return InkWell(
          onTap: () {
            controller.openDocument(
                chatList[index].mediaChatMessage!.mediaLocalStoragePath,
                context);
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: chatReplySenderColor,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              color: Colors.white,
            ),
            width: controller.screenWidth * 0.60,
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0),
                  child: Row(
                    children: [
                      getImageHolder(
                          chatList[index].mediaChatMessage!.mediaFileName),
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(
                          child: Text(
                        chatList[index].mediaChatMessage!.mediaFileName,
                        maxLines: 2,
                      )),
                      const Spacer(),
                      InkWell(
                        onTap: () {
                          handleMediaUploadDownload(
                              chatList[index]
                                  .mediaChatMessage!
                                  .mediaDownloadStatus,
                              chatList[index]);
                        },
                        child: getImageOverlay(chatList, index, context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      chatList[index].isMessageStarred
                          ? const Icon(
                              Icons.star,
                              size: 13,
                            )
                          : const SizedBox.shrink(),
                      const SizedBox(
                        width: 5,
                      ),
                      getMessageIndicator(
                          chatList[index].messageStatus.status,
                          chatList[index].isMessageSentByMe,
                          chatList[index].messageType),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        controller.getChatTime(
                            context, chatList[index].messageSentTime),
                        style:
                            const TextStyle(fontSize: 11, color: chatTimeColor),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
              ],
            ),
          ),
        );
      } else if (chatList[index].messageType == Constants.mContact) {
        if(chatList[index].contactChatMessage == null){
          return const SizedBox.shrink();
        }
        return InkWell(
          onTap: () {
            Get.toNamed(Routes.PREVIEW_CONTACT, arguments: {
              "contactList":
                  chatList[index].contactChatMessage!.contactPhoneNumbers,
              "contactName": chatList[index].contactChatMessage!.contactName,
              "from": "chat"
            });
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: chatReplySenderColor,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              color: Colors.white,
            ),
            width: controller.screenWidth * 0.60,
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0),
                  child: Row(
                    children: [
                      Image.asset(
                        profileImage,
                        width: 35,
                        height: 35,
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      Expanded(
                          child: Text(
                        chatList[index].contactChatMessage!.contactName,
                        maxLines: 2,
                      )),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      chatList[index].isMessageStarred
                          ? const Icon(
                              Icons.star,
                              size: 13,
                            )
                          : const SizedBox.shrink(),
                      const SizedBox(
                        width: 5,
                      ),
                      getMessageIndicator(
                          chatList[index].messageStatus.status,
                          chatList[index].isMessageSentByMe,
                          chatList[index].messageType),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        controller.getChatTime(
                            context, chatList[index].messageSentTime),
                        style:
                            const TextStyle(fontSize: 11, color: chatTimeColor),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
              ],
            ),
          ),
        );
      } else if (chatList[index].messageType == Constants.mAudio) {
        if(chatList[index].mediaChatMessage == null){
          return const SizedBox.shrink();
        }
        var chatMessage = chatList[index];
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: chatReplySenderColor,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            color: Colors.white,
          ),
          width: controller.screenWidth * 0.60,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10)),
                  color: chatReplySenderColor,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SvgPicture.asset(
                            audioMicBg,
                            width: 28,
                            height: 28,
                            fit: BoxFit.contain,
                          ),
                          SvgPicture.asset(
                            audioMic1,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                      // getAudioFeedButton(chatMessage),
                      const SizedBox(
                        width: 10,
                      ),
                      InkWell(
                        onTap: () {
                          handleMediaUploadDownload(
                              chatMessage.mediaChatMessage!.mediaDownloadStatus,
                              chatList[index]);
                        },
                        child: getImageOverlay(chatList, index, context),
                      ),

                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: SizedBox(
                          // width: 168,
                          child: SliderTheme(
                            data: SliderThemeData(
                              thumbColor: audioColorDark,
                              overlayShape: SliderComponentShape.noOverlay,
                              thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 5),
                            ),
                            child: Slider(
                              value: double.parse(
                                  controller.currentPos.value.toString()),
                              min: 0,
                              activeColor: audioColorDark,
                              inactiveColor: audioColor,
                              max: double.parse(
                                  controller.maxDuration.value.toString()),
                              divisions: controller.maxDuration.value,
                              onChanged: (double value) async {

                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    chatList[index].isMessageStarred
                        ? const Icon(
                            Icons.star,
                            size: 13,
                          )
                        : const SizedBox.shrink(),
                    const SizedBox(
                      width: 5,
                    ),
                    getMessageIndicator(
                        chatList[index].messageStatus.status,
                        chatList[index].isMessageSentByMe,
                        chatList[index].messageType),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      controller.getChatTime(
                          context, chatList[index].messageSentTime),
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 5,
              ),
            ],
          ),
        );
      } else if (chatList[index].messageType.toUpperCase() ==
          Constants.mLocation) {
        if(chatList[index].locationChatMessage == null){
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.all(2.0),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: getLocationImage(
                    chatList[index].locationChatMessage, 200, 171),
              ),
              Positioned(
                bottom: 8,
                right: 10,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    chatList[index].isMessageStarred
                        ? const Icon(
                            Icons.star,
                            size: 13,
                          )
                        : const SizedBox.shrink(),
                    const SizedBox(
                      width: 5,
                    ),
                    getMessageIndicator(
                        chatList[index].messageStatus.status,
                        chatList[index].isMessageSentByMe,
                        chatList[index].messageType),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      controller.getChatTime(
                          context, chatList[index].messageSentTime),
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    }
  }

  Widget getLocationImage(
      LocationChatMessage? locationChatMessage, double width, double height) {
    return InkWell(
        onTap: () async {
          //Redirect to Google maps App
          String googleUrl =
              'https://www.google.com/maps/search/?api=1&query=${locationChatMessage.latitude}, ${locationChatMessage.longitude}';
          if (await canLaunchUrl(Uri.parse(googleUrl))) {
            await launchUrl(Uri.parse(googleUrl));
          } else {
            throw 'Could not open the map.';
          }
        },
        child: Image.network(
          Helper.getMapImageUri(
              locationChatMessage!.latitude, locationChatMessage.longitude),
          fit: BoxFit.fill,
          width: width,
          height: height,
        ));
  }

  Widget bottomSheet(BuildContext context) {
    return Container(
      height: 270,
      width: controller.screenWidth,
      margin: const EdgeInsets.only(bottom: 40),
      child: Card(
        color: bottomSheetColor,
        margin: const EdgeInsets.all(18.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconCreation(documentImg, "Document", () {
                    Get.back();
                    controller.documentPickUpload();
                  }),
                  const SizedBox(
                    width: 50,
                  ),
                  iconCreation(cameraImg, "Camera", () async {
                    Get.back();

                    final XFile? photo =
                        await _picker.pickImage(source: ImageSource.camera);
                    if(photo!=null) {
                      Get.toNamed(Routes.IMAGEPREVIEW, arguments: {
                        "filePath": photo.path,
                        "userName": controller.profile.name!
                      });
                    }
                  }),
                  const SizedBox(
                    width: 50,
                  ),
                  iconCreation(galleryImg, "Gallery", () async {
                    try {
                      Get.back();
                      controller.imagePicker();
                    } catch (e) {
                      _pickImageError = e;
                      debugPrint(_pickImageError);
                    }
                  }),
                ],
              ),
              const SizedBox(
                height: 35,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconCreation(audioImg, "Audio", () {
                    Get.back();
                    controller.pickAudio();
                  }),
                  const SizedBox(
                    width: 50,
                  ),
                  iconCreation(contactImg, "Contact", () async {
                    if (await controller.askContactsPermission()) {
                      Get.back();
                      Get.toNamed(Routes.LOCAL_CONTACT);
                    } else {
                      debugPrint("Permission Denied");
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text('Permission Denied'),
                        action: SnackBarAction(
                            label: 'Ok',
                            onPressed: ScaffoldMessenger.of(context)
                                .hideCurrentSnackBar),
                      ));
                    }
                  }),
                  const SizedBox(
                    width: 50,
                  ),
                  iconCreation(locationImg, "Location", () {
                    AppPermission().getLocationPermission().then((bool value) {
                      mirrorFlyLog("Location permission", value.toString());
                      if (value) {
                        Get.back();
                        Get.toNamed(Routes.LOCATIONSENT)?.then((value) {
                          if (value != null) {
                            value as LatLng;
                            controller.sendLocationMessage(controller.profile,
                                value.latitude, value.longitude);
                          }
                        });
                      }
                    });
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget iconCreation(String iconPath, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          SvgPicture.asset(iconPath),
          const SizedBox(
            height: 5,
          ),
          Text(
            text,
            style: const TextStyle(fontSize: 12, color: Colors.white),
          )
        ],
      ),
    );
  }

  getImageOverlay(
      List<ChatMessageModel> chatList, int index, BuildContext context) {
    var chatMessage = chatList[index];

    if (controller
            .checkFile(chatMessage.mediaChatMessage!.mediaLocalStoragePath) &&
        chatMessage.messageStatus.status != 'N') {
      if (chatMessage.messageType == 'VIDEO') {
        return SizedBox(
          width: 80,
          height: 50,
          child: Center(
              child: SvgPicture.asset(
            videoPlay,
            fit: BoxFit.contain,
          )),
        );
      } else if (chatMessage.messageType == 'AUDIO') {
        debugPrint("===============================");
        debugPrint(chatMessage.mediaChatMessage!.isPlaying.toString());
        return chatMessage.mediaChatMessage!.isPlaying
            ? const Icon(Icons.pause)
            : const Icon(Icons.play_arrow_sharp);
      } else {
        return const SizedBox.shrink();
      }
    } else {
      switch (chatMessage.isMessageSentByMe
          ? chatMessage.mediaChatMessage!.mediaUploadStatus
          : chatMessage.mediaChatMessage!.mediaDownloadStatus) {
        case Constants.mediaDownloaded:
        case Constants.mediaUploaded:
          return const SizedBox.shrink();

        case Constants.mediaDownloadedNotAvailable:
        case Constants.mediaNotDownloaded:
          return getFileInfo(
              chatMessage.mediaChatMessage!.mediaDownloadStatus,
              chatMessage.mediaChatMessage!.mediaFileSize,
              Icons.download_sharp,
              chatMessage.messageType);
        case Constants.mediaUploadedNotAvailable:
          return getFileInfo(
              chatMessage.mediaChatMessage!.mediaDownloadStatus,
              chatMessage.mediaChatMessage!.mediaFileSize,
              Icons.upload_sharp,
              chatMessage.messageType);

        case Constants.mediaNotUploaded:
        case Constants.mediaDownloading:
        case Constants.mediaUploading:
          if (chatMessage.messageType == 'AUDIO' ||
              chatMessage.messageType == 'DOCUMENT') {
            return InkWell(
                onTap: () {
                  debugPrint(chatMessage.messageId);
                },
                child: SizedBox(width: 30, height: 30, child: uploadingView()));
          } else {
            return SizedBox(
              height: 40,
              width: 80,
              child: uploadingView(),
            );
          }
      }
    }
  }

  getFileInfo(int mediaDownloadStatus, int mediaFileSize, IconData iconData,
      String messageType) {
    return messageType == 'AUDIO' || messageType == 'DOCUMENT'
        ? Icon(
            iconData,
            color: audioColorDark,
          )
        : Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: textColor,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              color: Colors.black38,
            ),
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Row(
              children: [
                Icon(
                  iconData,
                  color: Colors.white,
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  Helper.formatBytes(mediaFileSize, 0),
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ));
  }

  getImage(String mediaLocalStoragePath, String mediaThumbImage,
      BuildContext context, String mediaFileName) {
    if (controller.checkFile(mediaLocalStoragePath)) {
      return InkWell(
          onTap: () {
            Get.toNamed(Routes.IMAGE_VIEW, arguments: {
              'imageName': mediaFileName,
              'imagePath': mediaLocalStoragePath
            });
          },
          child: Image(image: FileImage(File(mediaLocalStoragePath)),loadingBuilder:(context, child, loadingProgress) {
            if (loadingProgress == null) {
              return FutureBuilder(
                builder: (context,d) {
                  return child;
                }
              );
            }
            return const Center(
                child: CircularProgressIndicator());
          },
            width: controller.screenWidth * 0.60,
            height: controller.screenHeight * 0.4,
            fit: BoxFit.cover,) /*Image.file(
            File(mediaLocalStoragePath),
            width: controller.screenWidth * 0.60,
            height: controller.screenHeight * 0.4,
            fit: BoxFit.cover,
          )*/);
    } else {
      return controller.imageFromBase64String(
          mediaThumbImage, context, null, null);
    }
  }

  uploadingView() {
    return Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: textColor,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(2)),
          color: audioBgColor,
        ),
        child: Stack(alignment: Alignment.center,
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                downloading,
                fit: BoxFit.contain,
              ),
              const Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: 2,
                  child: LinearProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                    backgroundColor: audioBgColor,
                    // minHeight: 1,
                  ),
                ),
              ),
            ]));
  }

  handleMediaUploadDownload(
      int mediaDownloadStatus, ChatMessageModel chatList) {
    switch (chatList.isMessageSentByMe
        ? chatList.mediaChatMessage?.mediaUploadStatus
        : mediaDownloadStatus) {
      case Constants.mediaDownloaded:
      case Constants.mediaUploaded:
        if (chatList.messageType == 'VIDEO') {
          if (controller.checkFile(
                  chatList.mediaChatMessage!.mediaLocalStoragePath) &&
              (chatList.mediaChatMessage!.mediaDownloadStatus ==
                      Constants.mediaDownloaded ||
                  chatList.mediaChatMessage!.mediaDownloadStatus ==
                      Constants.mediaUploaded ||
                  chatList.isMessageSentByMe)) {
            Get.toNamed(Routes.VIDEO_PLAY, arguments: {
              "filePath": chatList.mediaChatMessage!.mediaLocalStoragePath,
            });
          }
        }
        if (chatList.messageType == 'AUDIO') {
          if (controller.checkFile(
                  chatList.mediaChatMessage!.mediaLocalStoragePath) &&
              (chatList.mediaChatMessage!.mediaDownloadStatus ==
                      Constants.mediaDownloaded ||
                  chatList.mediaChatMessage!.mediaDownloadStatus ==
                      Constants.mediaUploaded ||
                  chatList.isMessageSentByMe)) {
            // debugPrint("audio click1");
            chatList.mediaChatMessage!.isPlaying = controller.isPlaying.value;
            // controller.playAudio(chatList.mediaChatMessage!);
            playAudio(chatList.mediaChatMessage!.mediaLocalStoragePath,
                chatList.mediaChatMessage!.mediaFileName);
          } else {
            debugPrint("condition failed");
          }
        }
        break;

      case Constants.mediaDownloadedNotAvailable:
      case Constants.mediaNotDownloaded:
        //download
        debugPrint("Download");
        debugPrint(chatList.messageId);
        chatList.mediaChatMessage!.mediaDownloadStatus =
            Constants.mediaDownloading;
        controller.downloadMedia(chatList.messageId);
        break;
      case Constants.mediaUploadedNotAvailable:
        //upload
        break;
      case Constants.mediaNotUploaded:
      case Constants.mediaDownloading:
      case Constants.mediaUploading:
        return uploadingView();
      // break;
    }
  }

  getAudioFeedButton(ChatMessageModel chatMessage) {}

  getImageHolder(String mediaFileName) {
    String result = mediaFileName.split('.').last;
    debugPrint("File Type ==> $result");
    switch (result) {
      case Constants.pdf:
        return SvgPicture.asset(
          pdfImage,
          width: 30,
          height: 30,
        );
      case Constants.ppt:
        return SvgPicture.asset(
          pptImage,
          width: 30,
          height: 30,
        );
      case Constants.xls:
        return SvgPicture.asset(
          xlsImage,
          width: 30,
          height: 30,
        );
      case Constants.xlsx:
        return SvgPicture.asset(
          xlsxImage,
          width: 30,
          height: 30,
        );
      case Constants.doc:
      case Constants.docx:
        return SvgPicture.asset(
          docImage,
          width: 30,
          height: 30,
        );
      case Constants.apk:
        return SvgPicture.asset(
          apkImage,
          width: 30,
          height: 30,
        );
      default:
        return SvgPicture.asset(
          docImage,
          width: 30,
          height: 30,
        );
    }
  }

  playAudio(String filePath, String mediaFileName) {
    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            // mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  controller.playAudio(filePath);
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset(
                      audioMicBg,
                      width: 50,
                      height: 50,
                      fit: BoxFit.contain,
                    ),
                    Obx(() {
                      return controller.isPlaying.value
                          ? const Icon(Icons.pause)
                          : const Icon(Icons.play_arrow);
                    }),
                  ],
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      mediaFileName,
                      maxLines: 2,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      // width: 168,
                      child: SliderTheme(
                        data: SliderThemeData(
                          thumbColor: audioColorDark,
                          overlayShape: SliderComponentShape.noOverlay,
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 5),
                        ),
                        child: Obx(() {
                          return Slider(
                            value:
                                double.parse(controller.currentPos.toString()),
                            min: 0,
                            activeColor: audioColorDark,
                            inactiveColor: audioColor,
                            max: double.parse(
                                controller.maxDuration.value.toString()),
                            divisions: controller.maxDuration.value,
                            label: controller.currentPostLabel,
                            onChanged: (double value) async {

                            },
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget replyMessageHeader(BuildContext context) {
    return Obx(() {
      if (controller.isReplying.value) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: chatSentBgColor,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: chatReplyContainerColor,
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0, left: 15.0),
                        child: getReplyTitle(
                            controller.replyChatMessage.isMessageSentByMe,
                            controller.replyChatMessage.senderNickName),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding:
                            const EdgeInsets.only(bottom: 15.0, left: 15.0),
                        child: getReplyMessage(
                            controller.replyChatMessage.messageType,
                            controller.replyChatMessage.messageTextContent,
                            controller.replyChatMessage.contactChatMessage
                                ?.contactName,
                            controller.replyChatMessage.mediaChatMessage
                                ?.mediaFileName),
                      ),
                    ],
                  ),
                ),
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    getReplyImageHolder(
                        context,
                        controller.replyChatMessage.messageType,
                        controller
                            .replyChatMessage.mediaChatMessage?.mediaThumbImage,
                        controller.replyChatMessage.locationChatMessage,
                        70),
                    GestureDetector(
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 10,
                            child: Icon(Icons.close,
                                size: 15, color: Colors.black)),
                      ),
                      onTap: () => controller.cancelReplyMessage(),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  getReplyTitle(bool isMessageSentByMe, String senderNickName) {
    return isMessageSentByMe
        ? const Text(
            'You',
            style: TextStyle(fontWeight: FontWeight.bold),
          )
        : Text(senderNickName,
            style: const TextStyle(fontWeight: FontWeight.bold));
  }

  getReplyMessage(String messageType, String? messageTextContent,
      String? contactName, String? mediaFileName) {
    debugPrint(messageType);
    switch (messageType) {
      case Constants.mText:
        return Row(
          children: [
            Helper.forMessageTypeIcon(Constants.mText),
            Text(messageTextContent!),
          ],
        );
      case Constants.mImage:
        return Row(
          children: [
            Helper.forMessageTypeIcon(Constants.mImage),
            const SizedBox(
              width: 10,
            ),
            Text(Helper.capitalize(Constants.mImage)),
          ],
        );
      case Constants.mVideo:
        return Row(
          children: [
            Helper.forMessageTypeIcon(Constants.mVideo),
            const SizedBox(
              width: 10,
            ),
            Text(Helper.capitalize(Constants.mVideo)),
          ],
        );
      case Constants.mAudio:
        return Row(
          children: [
            Helper.forMessageTypeIcon(Constants.mAudio),
            const SizedBox(
              width: 10,
            ),
            // Text(controller.replyChatMessage.mediaChatMessage!.mediaDuration),
            // SizedBox(
            //   width: 10,
            // ),
            Text(Helper.capitalize(Constants.mAudio)),
          ],
        );
      case Constants.mContact:
        return Row(
          children: [
            Helper.forMessageTypeIcon(Constants.mContact),
            const SizedBox(
              width: 10,
            ),
            Text("${Helper.capitalize(Constants.mContact)} :"),
            const SizedBox(
              width: 5,
            ),
            SizedBox(
                width: 120,
                child: Text(
                  contactName!,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                )),
          ],
        );
      case Constants.mLocation:
        return Row(
          children: [
            Helper.forMessageTypeIcon(Constants.mLocation),
            const SizedBox(
              width: 10,
            ),
            Text(Helper.capitalize(Constants.mLocation)),
          ],
        );
      case Constants.mDocument:
        return Row(
          children: [
            Helper.forMessageTypeIcon(Constants.mDocument),
            const SizedBox(
              width: 10,
            ),
            Text(mediaFileName!),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  getReplyImageHolder(
      BuildContext context,
      String messageType,
      String? mediaThumbImage,
      LocationChatMessage? locationChatMessage,
      double size) {
    switch (messageType) {
      case Constants.mImage:
        return ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: controller.imageFromBase64String(
              mediaThumbImage!, context, size, size),
        );
      case Constants.mLocation:
        return getLocationImage(locationChatMessage, size, size);
      case Constants.mVideo:
        return ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: controller.imageFromBase64String(
              mediaThumbImage!, context, size, size),
        );
      default:
        return SizedBox(
          height: size,
        );
    }
  }

  getMessageHeader(ChatMessageModel chatList, BuildContext context) {
    if (chatList.replyParentChatMessage == null) {
      return const SizedBox.shrink();
    } else {
      return Container(
        padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          color: chatList.isMessageSentByMe
              ? chatReplyContainerColor
              : chatReplySenderColor,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  getReplyTitle(
                      chatList.replyParentChatMessage!.isMessageSentByMe,
                      chatList.replyParentChatMessage!.senderUserName),
                  const SizedBox(height: 5),
                  getReplyMessage(
                      chatList.replyParentChatMessage!.messageType,
                      chatList.replyParentChatMessage?.messageTextContent,
                      chatList.replyParentChatMessage?.contactChatMessage
                          ?.contactName,
                      chatList.replyParentChatMessage?.mediaChatMessage
                          ?.mediaFileName),
                ],
              ),
            ),
            getReplyImageHolder(
                context,
                chatList.replyParentChatMessage!.messageType,
                chatList
                    .replyParentChatMessage?.mediaChatMessage?.mediaThumbImage,
                chatList.replyParentChatMessage?.locationChatMessage,
                55),
          ],
        ),
      );
    }
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
              controller.getOptionStatus('Reply')
                  ? CustomAction(
                      visibleWidget: IconButton(
                          onPressed: () {
                            controller.handleReplyChatMessage(
                                controller.selectedChatList[0]);
                            controller.clearChatSelection(
                                controller.selectedChatList[0]);
                          },
                          icon: SvgPicture.asset(replyIcon)),
                      overflowWidget: const Text("Reply"),
                      showAsAction: ShowAsAction.always,
                      keyValue: 'Reply',
                      onItemClick: () {
                        controller.closeKeyBoard();
                        controller.handleReplyChatMessage(
                            controller.selectedChatList[0]);
                        controller
                            .clearChatSelection(controller.selectedChatList[0]);
                      },
                    )
                  : customEmptyAction(),
              CustomAction(
                visibleWidget: IconButton(
                    onPressed: () {
                      controller.forwardMessage();
                    },
                    icon: SvgPicture.asset(forwardIcon)),
                overflowWidget: const Text("Forward"),
                showAsAction: ShowAsAction.always,
                keyValue: 'Forward',
                onItemClick: () {
                  controller.closeKeyBoard();
                  controller.forwardMessage();
                },
              ),
              controller.getOptionStatus('Favourite')
                  ? CustomAction(
                      visibleWidget: IconButton(
                          onPressed: () {
                            controller.favouriteMessage();
                          },
                          // icon: controller.getOptionStatus('Favourite') ? const Icon(Icons.star_border_outlined)
                          icon: controller.selectedChatList[0].isMessageStarred
                              ? SvgPicture.asset(unFavouriteIcon)
                              : SvgPicture.asset(favouriteIcon)),
                      overflowWidget: const Text("Favourite"),
                      showAsAction: ShowAsAction.always,
                      keyValue: 'favourite',
                      onItemClick: () {
                        controller.closeKeyBoard();
                        controller.favouriteMessage();
                      },
                    )
                  : customEmptyAction(),
              CustomAction(
                visibleWidget: IconButton(
                    onPressed: () {
                      controller.deleteMessages();
                    },
                    icon: SvgPicture.asset(deleteIcon)),
                overflowWidget: const Text("Delete"),
                showAsAction: ShowAsAction.always,
                keyValue: 'Delete',
                onItemClick: () {
                  controller.closeKeyBoard();
                  controller.deleteMessages();
                },
              ),
              controller.getOptionStatus('Report')
                  ? CustomAction(
                      visibleWidget: IconButton(
                          onPressed: () {
                            controller.reportChatOrUser();
                          },
                          icon: const Icon(Icons.report_problem_rounded)),
                      overflowWidget: const Text("Report"),
                      showAsAction: ShowAsAction.never,
                      keyValue: 'Report',
                      onItemClick: () {
                        controller.closeKeyBoard();
                        controller.reportChatOrUser();
                      },
                    )
                  : customEmptyAction(),
              controller.selectedChatList.length > 1 ||
                      controller.selectedChatList[0].messageType !=
                          Constants.mText
                  ? customEmptyAction()
                  : CustomAction(
                      visibleWidget: IconButton(
                        onPressed: () {
                          // controller.copyTextMessages();
                        },
                        icon: SvgPicture.asset(
                          copyIcon,
                          fit: BoxFit.contain,
                        ),
                      ),
                      overflowWidget: const Text("Copy"),
                      showAsAction: ShowAsAction.never,
                      keyValue: 'Copy',
                      onItemClick: () {
                        controller.closeKeyBoard();
                        controller.copyTextMessages();
                      },
                    ),
              controller.getOptionStatus('Message Info')
                  ? CustomAction(
                      visibleWidget: IconButton(
                        onPressed: () {
                          // Get.back();
                          controller.messageInfo();
                        },
                        icon: SvgPicture.asset(
                          infoIcon,
                          fit: BoxFit.contain,
                        ),
                      ),
                      overflowWidget: const Text("Message Info"),
                      showAsAction: ShowAsAction.never,
                      keyValue: 'MessageInfo',
                      onItemClick: () {
                        controller.closeKeyBoard();
                        controller.messageInfo();
                      },
                    )
                  : customEmptyAction(),
              controller.getOptionStatus('Share')
                  ? CustomAction(
                      visibleWidget: IconButton(
                          onPressed: () {}, icon: const Icon(Icons.share)),
                      overflowWidget: const Text("Share"),
                      showAsAction: ShowAsAction.never,
                      keyValue: 'Share',
                      onItemClick: () {
                        controller.closeKeyBoard();
                      },
                    )
                  : customEmptyAction(),
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
          onTap: (){Get.back();},
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 10,),
              const Icon(Icons.arrow_back),
              const SizedBox(width: 10,),
              ImageNetwork(
                url: controller.profile.image.checkNull(),
                width: 35,
                height: 35,
                clipOval: true,
                errorWidget: controller.profile.isGroupProfile!
                    ? ClipOval(
                  child: Image.asset(
                    groupImg,
                    height: 35,
                    width: 35,
                    fit: BoxFit.cover,
                  ),
                )
                    : ProfileTextImage(
                  text: controller.profile.name.checkNull().isEmpty
                      ? controller.profile.mobileNumber.checkNull()
                      : controller.profile.name.checkNull(),
                  radius: 18,
                ),
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
                Text(controller.profile.name.checkNull()),
                controller.subtitle.isNotEmpty
                    ? !controller.profile.isGroupProfile!
                        ? Text(
                            controller.subtitle,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.fade,
                          )
                        : SizedBox(
                            width: (controller.screenWidth) / 1.9,
                            height: 15,
                            child: Marquee(
                                text: "${controller.subtitle},",
                                style: const TextStyle(fontSize: 12)))
                    : const SizedBox()
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
                        controller.closeKeyBoard();
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
                      showAsAction: controller.profile.isGroupProfile!
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
                showAsAction: controller.profile.isGroupProfile!
                    ? ShowAsAction.gone
                    : ShowAsAction.never,
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
