import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/constants.dart';
import '../../../common/main_controller.dart';
import '../../../data/helper.dart';
import '../../../model/chatMessageModel.dart';

class MessageHeader extends StatefulWidget {
  const MessageHeader({Key? key, required this.chatList, required this.isTapEnabled}) : super(key: key);

  final ChatMessageModel chatList;
  final bool isTapEnabled;

  @override
  State<MessageHeader> createState() => _MessageHeaderState();
}

class _MessageHeaderState extends State<MessageHeader> {
  var controller = Get.find<MainController>();
  @override
  Widget build(BuildContext context) {

    return Container(
        child: getMessageHeader(widget.chatList)
    );
  }

  getMessageHeader(ChatMessageModel chatList) {
    if (chatList.replyParentChatMessage == null) {
      return const SizedBox.shrink();
    } else {
      return Container(
        padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          color: chatList.isMessageSentByMe
              ? chatreplycontainercolor
              : chatreplysendercolor,
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
  getReplyImageHolder(
      BuildContext context,
      String messageType,
      String? mediaThumbImage,
      LocationChatMessage? locationChatMessage,
      double size) {
    switch (messageType) {
      case Constants.MIMAGE:
        return ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: controller.imageFromBase64String(
              mediaThumbImage!, context, size, size),
        );
      case Constants.MLOCATION:
        return controller.getLocationImage(locationChatMessage, size, size);
      case Constants.MVIDEO:
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
      case Constants.MTEXT:
        return Row(
          children: [
            Helper.forMessageTypeIcon(Constants.MTEXT),
            Text(messageTextContent!),
          ],
        );
      case Constants.MIMAGE:
        return Row(
          children: [
            Helper.forMessageTypeIcon(Constants.MIMAGE),
            const SizedBox(
              width: 10,
            ),
            Text(Helper.capitalize(Constants.MIMAGE)),
          ],
        );
      case Constants.MVIDEO:
        return Row(
          children: [
            Helper.forMessageTypeIcon(Constants.MVIDEO),
            const SizedBox(
              width: 10,
            ),
            Text(Helper.capitalize(Constants.MVIDEO)),
          ],
        );
      case Constants.MAUDIO:
        return Row(
          children: [
            Helper.forMessageTypeIcon(Constants.MAUDIO),
            const SizedBox(
              width: 10,
            ),
            // Text(controller.replyChatMessage.mediaChatMessage!.mediaDuration),
            // SizedBox(
            //   width: 10,
            // ),
            Text(Helper.capitalize(Constants.MAUDIO)),
          ],
        );
      case Constants.MCONTACT:
        return Row(
          children: [
            Helper.forMessageTypeIcon(Constants.MCONTACT),
            const SizedBox(
              width: 10,
            ),
            Text("${Helper.capitalize(Constants.MCONTACT)} :"),
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
      case Constants.MLOCATION:
        return Row(
          children: [
            Helper.forMessageTypeIcon(Constants.MLOCATION),
            const SizedBox(
              width: 10,
            ),
            Text(Helper.capitalize(Constants.MLOCATION)),
          ],
        );
      case Constants.MDOCUMENT:
        return Row(
          children: [
            Helper.forMessageTypeIcon(Constants.MDOCUMENT),
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

}
