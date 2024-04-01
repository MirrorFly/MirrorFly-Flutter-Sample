import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/extensions.dart';
import 'package:mirror_fly_demo/app/modules/chat/controllers/chat_controller.dart';

import '../../../common/constants.dart';
import '../../../model/chat_message_model.dart';
import '../chat_widgets.dart';

class EditMessageScreen extends StatefulWidget {
  final ChatController chatController;
  final ChatMessageModel chatItem;
  const EditMessageScreen({super.key, required this.chatController, required this.chatItem});

  @override
  State<EditMessageScreen> createState() => _EditMessageScreenState();
}

class _EditMessageScreenState extends State<EditMessageScreen> {
  FocusNode textFocusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      textFocusNode.requestFocus();
    });
    textFocusNode.addListener(() {
      if (textFocusNode.hasFocus) {
        widget.chatController.showEmoji(false);
      } else {

      }
    });
  }

  @override
  void dispose() {
    // Dispose the focus node when the widget is removed from the widget tree
    textFocusNode.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    var messageToEdit = (widget.chatItem.messageType == Constants.mText || widget.chatItem.messageType == Constants.mAutoText) ? widget.chatItem.messageTextContent : widget.chatItem.mediaChatMessage?.mediaCaptionText;
    widget.chatController.editMessageController.text = messageToEdit ?? "";
    widget.chatController.editMessageText(messageToEdit);
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: Column(
        children: [
          AppBar(
            title: const Text('Edit Message'),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                widget.chatController.closeKeyBoard();
                Get.back();
              },
            ),
          ),
          Expanded(
            child: InkWell(
              splashColor: Colors.transparent,
              onTap: (){
                textFocusNode.unfocus();
                // widget.chatController.showHideEmoji(Get.context!);
              },
              child: ListView(
                shrinkWrap: true,
                reverse: true,
                  children: [
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        key: ValueKey(widget.chatItem.messageId),
                        constraints: BoxConstraints(maxWidth: Get.width * 0.75),
                        // color: Colors.transparent,
                        margin: const EdgeInsets.only(left: 14, right: 14, top: 5, bottom: 10),
                        decoration: BoxDecoration(
                            borderRadius:
                            const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10)),
                            color: (widget.chatItem.isMessageSentByMe ? chatSentBgColor : Colors.white),
                            border: widget.chatItem.isMessageSentByMe ? Border.all(color: chatSentBgColor) : Border.all(color: chatBorderColor)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.chatController.profile.isGroupProfile.checkNull()) ...[
                              SenderHeader(isGroupProfile: widget.chatController.profile.isGroupProfile, chatList: [widget.chatItem], index: 0),
                            ],
                            widget.chatItem.isThisAReplyMessage
                                ? widget.chatItem.replyParentChatMessage == null
                                ? messageNotAvailableWidget(widget.chatItem)
                                : ReplyMessageHeader(chatMessage: widget.chatItem)
                                : const SizedBox.shrink(),
                            MessageContent(
                                chatList: [widget.chatItem], index: 0, onPlayAudio: () {}, onSeekbarChange: (double value) {}, isSelected: widget.chatController.isSelected.value)
                          ],
                        ),
                      ),
                    ),
                    // widget.chatController.emojiLayout(textEditingController: widget.chatController.editMessageController)
                  ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
              child: Column(
                children: [
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Flexible(
                          child: Container(
                              padding: const EdgeInsets.only(left: 10),
                              margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: textColor,
                                ),
                                borderRadius: const BorderRadius.all(Radius.circular(40)),
                                color: Colors.white,
                              ),
                              child: Row(
                                children: [
                                  Obx(() {
                                    return InkWell(
                                        onTap: () {
                                          textFocusNode.unfocus();
                                          widget.chatController.showHideEmoji(Get.context!);
                                        },
                                        child: widget.chatController.showEmoji.value
                                            ? const Icon(
                                          Icons.keyboard,
                                          color: iconColor,
                                        )
                                            : SvgPicture.asset(smileIcon));
                                  }),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: TextField(
                                      focusNode: textFocusNode,
                                      onChanged: (text) {
                                        widget.chatController.editMessageText(text);
                                      },
                                      style: const TextStyle(fontWeight: FontWeight.w400),
                                      keyboardType: TextInputType.multiline,
                                      minLines: 1,
                                      maxLines: 5,
                                      controller: widget.chatController.editMessageController,
                                      // focusNode: controller.focusNode,
                                      decoration: const InputDecoration(hintText: "Start Typing...", border: InputBorder.none),
                                    ),
                                  ),
                                ],
                              )),
                        ),
                        Obx(() {
                          return widget.chatController.editMessageText.value.trim() != messageToEdit && widget.chatController.editMessageText.value.trim().isNotEmpty
                              ? InkWell(
                              onTap: () {
                                widget.chatController.updateSentMessage(chatItem: widget.chatItem);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8),
                                child: SvgPicture.asset(sendIcon),
                              ))
                              : const SizedBox.shrink();
                        }),
                        const SizedBox(
                          width: 5,
                        ),
                      ],
                    ),
                  ),
                  widget.chatController.emojiLayout(textEditingController: widget.chatController.editMessageController, sendTypingStatus: false),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
