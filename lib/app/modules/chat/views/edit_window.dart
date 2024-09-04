import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/app_localizations.dart';
import '../../../extensions/extensions.dart';
import '../../../modules/chat/controllers/chat_controller.dart';

import '../../../app_style_config.dart';
import '../../../common/constants.dart';
import '../../../data/utils.dart';
import '../../../model/chat_message_model.dart';
import '../widgets/chat_widgets.dart';
import '../widgets/message_content.dart';
import '../widgets/reply_message_widgets.dart';
import '../widgets/sender_header.dart';

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
    widget.chatController.setOnGoingUserGone();
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
    widget.chatController.setOnGoingUserAvail();
    // Dispose the focus node when the widget is removed from the widget tree
    textFocusNode.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    var messageToEdit = (widget.chatItem.messageType == Constants.mText || widget.chatItem.messageType == Constants.mAutoText) ? widget.chatItem.messageTextContent : widget.chatItem.mediaChatMessage?.mediaCaptionText;
    widget.chatController.editMessageController.text = messageToEdit ?? "";
    widget.chatController.editMessageText(messageToEdit);
    return Theme(
      data: Theme.of(context).copyWith(
          appBarTheme: AppStyleConfig.chatPageStyle.appBarTheme
      ),
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.7),
        appBar: AppBar(
          title: Text(getTranslated("editMessage")),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              widget.chatController.closeKeyBoard();
              Navigator.pop(context);
            },
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
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
                            constraints: BoxConstraints(maxWidth: NavUtils.width * 0.75),
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
                                  SenderHeader(isGroupProfile: widget.chatController.profile.isGroupProfile, chatList: [widget.chatItem], index: 0,textStyle: null,),
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
                  color: AppStyleConfig.chatPageStyle.messageTypingAreaStyle.bgColor,//Colors.white,
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
                                  decoration: AppStyleConfig.chatPageStyle.messageTypingAreaStyle.decoration,
                                  child: Row(
                                    children: [
                                      Obx(() {
                                        return InkWell(
                                            onTap: () {
                                              textFocusNode.unfocus();
                                              widget.chatController.showHideEmoji();
                                            },
                                            child: widget.chatController.showEmoji.value
                                                ? Icon(
                                              Icons.keyboard,
                                              color: AppStyleConfig.chatPageStyle.messageTypingAreaStyle.emojiIconColor,
                                            )
                                                : AppUtils.svgIcon(icon:smileIcon,colorFilter: ColorFilter.mode(AppStyleConfig.chatPageStyle.messageTypingAreaStyle.emojiIconColor, BlendMode.srcIn),));
                                      }),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Scrollbar(
                                          thumbVisibility: true, // Always show the scrollbar, optional
                                          thickness: 4.0, // Set the thickness of the scrollbar
                                          radius: const Radius.circular(20),
                                          child: TextField(
                                            focusNode: textFocusNode,
                                            onChanged: (text) {
                                              widget.chatController.editMessageText(text);
                                            },
                                            style: AppStyleConfig.chatPageStyle.messageTypingAreaStyle.textFieldStyle.editTextStyle,//const TextStyle(fontWeight: FontWeight.w400),
                                            // style: const TextStyle(fontWeight: FontWeight.w400),
                                            keyboardType: TextInputType.multiline,
                                            minLines: 1,
                                            maxLines: 5,
                                            controller: widget.chatController.editMessageController,
                                            // focusNode: controller.focusNode,
                                          decoration: InputDecoration(hintText: getTranslated("startTypingPlaceholder"), border: InputBorder.none,hintStyle:  AppStyleConfig.chatPageStyle.messageTypingAreaStyle.textFieldStyle.editTextHintStyle, contentPadding: EdgeInsets.zero),
                                        ),
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
                                    child: AppUtils.svgIcon(icon:sendIcon,colorFilter: ColorFilter.mode( AppStyleConfig.chatPageStyle.messageTypingAreaStyle.sentIconColor, BlendMode.srcIn)),
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
        ),
      ),
    );
  }
}
