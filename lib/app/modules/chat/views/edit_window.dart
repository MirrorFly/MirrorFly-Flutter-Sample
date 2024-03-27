import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/extensions.dart';
import 'package:mirror_fly_demo/app/modules/chat/controllers/chat_controller.dart';

import '../../../common/constants.dart';
import '../../../model/chat_message_model.dart';
import '../chat_widgets.dart';

class EditMessageScreen extends StatelessWidget {
  final ChatController chatController;
  final ChatMessageModel chatItem;
  const EditMessageScreen({super.key, required this.chatController, required this.chatItem});

  @override
  Widget build(BuildContext context) {
    var messageToEdit = chatItem.messageType == Constants.mText ? chatItem.messageTextContent : chatItem.mediaChatMessage?.mediaCaptionText;
    chatController.editMessageController.text = messageToEdit ?? "";
    chatController.editMessageText(messageToEdit);
    return Container(
      color: Colors.black.withOpacity(0.6), // Adjust opacity here
      child: Column(
        children: [
          AppBar(
            title: const Text('Edit Message'),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                chatController.closeKeyBoard();
                Get.back();
              },
            ),
          ),
          Expanded(
            child: InkWell(
              splashColor: Colors.transparent,
              onTap: () => chatController.closeKeyBoard(),
              child: Stack(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        key: ValueKey(chatItem.messageId),
                        color: Colors.transparent,
                        margin: const EdgeInsets.only(left: 14, right: 14, top: 5, bottom: 10),
                        child: Container(
                          constraints: BoxConstraints(maxWidth: Get.width * 0.75),
                          decoration: BoxDecoration(
                              borderRadius:
                              const BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10)),
                              color: (chatItem.isMessageSentByMe ? chatSentBgColor : Colors.white),
                              border: chatItem.isMessageSentByMe ? Border.all(color: chatSentBgColor) : Border.all(color: chatBorderColor)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (chatController.profile.isGroupProfile.checkNull()) ...[
                                SenderHeader(isGroupProfile: chatController.profile.isGroupProfile, chatList: [chatItem], index: 0),
                              ],
                              chatItem.isThisAReplyMessage
                                  ? chatItem.replyParentChatMessage == null
                                  ? messageNotAvailableWidget(chatItem)
                                  : ReplyMessageHeader(chatMessage: chatItem)
                                  : const SizedBox.shrink(),
                              MessageContent(
                                  chatList: [chatItem], index: 0, onPlayAudio: () {}, onSeekbarChange: (double value) {}, isSelected: chatController.isSelected.value)
                            ],
                          ),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                        child: IntrinsicHeight(
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
                                                chatController.showHideEmoji(Get.context!);
                                              },
                                              child: chatController.showEmoji.value
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
                                            onChanged: (text) {
                                              chatController.editMessageText(text);
                                            },
                                            style: const TextStyle(fontWeight: FontWeight.w400),
                                            keyboardType: TextInputType.multiline,
                                            minLines: 1,
                                            maxLines: 5,
                                            controller: chatController.editMessageController,
                                            // focusNode: controller.focusNode,
                                            decoration: const InputDecoration(hintText: "Start Typing...", border: InputBorder.none),
                                          ),
                                        ),
                                      ],
                                    )),
                              ),
                              Obx(() {
                                return chatController.editMessageText.value.trim() != messageToEdit && chatController.editMessageText.value.trim().isNotEmpty
                                    ? InkWell(
                                    onTap: () {
                                      chatController.updateSentMessage(messageId: chatItem.messageId);
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
                      ),
                      chatController.emojiLayout()
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
