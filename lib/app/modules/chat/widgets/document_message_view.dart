import 'package:flutter/material.dart';
import '../../../data/utils.dart';
import '../../../extensions/extensions.dart';
import '../../../stylesheet/stylesheet.dart';

import '../../../common/constants.dart';
import '../../../data/helper.dart';
import '../../../model/chat_message_model.dart';
import 'chat_widgets.dart';
import 'media_message_overlay.dart';

class DocumentMessageView extends StatelessWidget {
  const DocumentMessageView({Key? key, required this.chatMessage, this.search = "",this.docMessageViewStyle = const DocMessageViewStyle(), this.decoration = const BoxDecoration()})
      : super(key: key);
  final ChatMessageModel chatMessage;
  final String search;
  final DocMessageViewStyle docMessageViewStyle;
  final Decoration decoration;

  onDocumentClick() {
    AppUtils.openDocument(chatMessage.mediaChatMessage!.mediaLocalStoragePath.value);
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = NavUtils.width;
    return InkWell(
      onTap: () {
        onDocumentClick();
      },
      child: Container(
        color: Colors.transparent,
        // decoration: decoration,
        // decoration: BoxDecoration(
        //   border: Border.all(
        //     color: chatMessage.isMessageSentByMe
        //         ? chatReplyContainerColor
        //         : chatReplySenderColor,
        //   ),
        //   borderRadius: const BorderRadius.all(Radius.circular(10)),
        //   color: Colors.transparent,
        // ),
        width: screenWidth * 0.60,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.all(2),
              decoration: docMessageViewStyle.decoration,
              // decoration: BoxDecoration(
              //   borderRadius: const BorderRadius.only(
              //       bottomRight: Radius.circular(10),
              //       bottomLeft: Radius.circular(10),
              //       topLeft: Radius.circular(10),
              //       topRight: Radius.circular(10)),
              //   color: chatMessage.isMessageSentByMe
              //       ? chatReplyContainerColor
              //       : chatReplySenderColor,
              // ),
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  MessageUtils.getDocumentTypeIcon(
                      chatMessage.mediaChatMessage!.mediaFileName, 30),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: search.isEmpty
                        ? Text(
                      chatMessage.mediaChatMessage!.mediaFileName,
                      style: docMessageViewStyle.fileTextStyle.textStyle,
                      // style: const TextStyle(
                      //   fontSize: 12,
                      // ),
                      maxLines: 2,
                    ) /*textMessageSpannableText(
                            chatMessage.mediaChatMessage!.mediaFileName
                                .checkNull(),
                            maxLines: 2,
                          )*/
                        : chatSpannedText(
                        chatMessage.mediaChatMessage!.mediaFileName
                            .checkNull(),
                        search,
                        docMessageViewStyle.fileTextStyle.textStyle,
                        // const TextStyle(
                        //     color: Colors.black,
                        //     fontWeight: FontWeight.w400),
                        maxLines: 2,spanColor: docMessageViewStyle.fileTextStyle.highlightColor,), /*Text(
                    chatMessage.mediaChatMessage!.mediaFileName,
                    maxLines: 2,
                        style: const TextStyle(fontSize: 12,color: Colors.black,fontWeight: FontWeight.w400),
                  )*/
                  ),
                  MediaMessageOverlay(chatMessage: chatMessage,downloadUploadViewStyle:  docMessageViewStyle.downloadUploadViewStyle,),
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
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    MediaUtils.fileSize(
                        chatMessage.mediaChatMessage?.mediaFileSize ?? 0),
                    style: docMessageViewStyle.sizeTextStyle,
                    // style: const TextStyle(
                    //     color: Colors.black,
                    //     fontSize: 7,
                    //     fontWeight: FontWeight.w400),
                  ),
                  const Spacer(),
                  chatMessage.isMessageStarred.value
                      ? AppUtils.svgIcon(icon:starSmallIcon)
                      : const Offstage(),
                  const SizedBox(
                    width: 5,
                  ),
                  MessageUtils.getMessageIndicatorIcon(
                      chatMessage.messageStatus.value,
                      chatMessage.isMessageSentByMe,
                      chatMessage.messageType,
                      chatMessage.isMessageRecalled.value),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    getChatTime(context, chatMessage.messageSentTime.toInt()),
                    style: docMessageViewStyle.fileTextStyle.timeTextStyle,
                    // style: TextStyle(
                    //     fontSize: 12,
                    //     color: chatMessage.isMessageSentByMe
                    //         ? durationTextColor
                    //         : textHintColor),
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
  }
}