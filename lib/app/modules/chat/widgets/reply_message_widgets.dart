import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../extensions/extensions.dart';
import '../../../modules/chat/widgets/image_cache_manager.dart';
import '../../../stylesheet/stylesheet.dart';
import 'package:mirrorfly_plugin/logmessage.dart';

import '../../../common/app_localizations.dart';
import '../../../common/constants.dart';
import '../../../data/utils.dart';
import '../../../model/chat_message_model.dart';
import 'chat_widgets.dart';

class ReplyingMessageHeader extends StatelessWidget {
  const ReplyingMessageHeader({Key? key, required this.chatMessage, required this.onCancel, required this.onClick, this.replyHeaderMessageViewStyle = const ReplyHeaderMessageViewStyle(), required this.replyBgColor}) : super(key: key);
  final ChatMessageModel chatMessage;
  final Function() onCancel;
  final Function() onClick;
  final ReplyHeaderMessageViewStyle replyHeaderMessageViewStyle;
  final Color replyBgColor;

  @override
  Widget build(BuildContext context) {
    LogMessage.d("ReplyingMessageHeader", chatMessage.toJson());
    return InkWell(
      onTap: onClick,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: replyBgColor,
        ),
        child: Container(
          decoration: replyHeaderMessageViewStyle.decoration,
          /*decoration: const BoxDecoration(
            color: chatReplyContainerColor,
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),*/
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0, left: 15.0),
                      child: getReplyTitle(chatMessage.isMessageSentByMe,
                          chatMessage.senderUserName.checkNull().isNotEmpty ? chatMessage.senderUserName : chatMessage.senderNickName,replyHeaderMessageViewStyle.titleTextStyle),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15.0, left: 15.0),
                      child: getReplyMessage(
                          chatMessage.messageType.toUpperCase(),
                          chatMessage.messageTextContent,
                          chatMessage.contactChatMessage?.contactName,
                          chatMessage.mediaChatMessage?.mediaFileName,
                          chatMessage.mediaChatMessage,
                          true,replyHeaderMessageViewStyle.contentTextStyle),
                    ),
                  ],
                ),
              ),
              Stack(
                alignment: Alignment.topRight,
                children: [
                  getReplyImageHolder(context,
                      chatMessage,
                      chatMessage.mediaChatMessage,
                      70, true,
                      chatMessage.locationChatMessage,
                      replyHeaderMessageViewStyle.mediaIconStyle,replyHeaderMessageViewStyle.borderRadius),
                  GestureDetector(
                    onTap: onCancel,
                    child: const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: CircleAvatar(backgroundColor: Colors.white, radius: 10, child: Icon(Icons.close, size: 15, color: Colors.black)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

getReplyTitle(bool isMessageSentByMe, String senderUserName,TextStyle textStyle) {
  return isMessageSentByMe
      ? Text(
          getTranslated("you"),
          style: textStyle,
          // style: const TextStyle(fontWeight: FontWeight.bold),
        )
      : Text(senderUserName, style: textStyle,/*style: const TextStyle(fontWeight: FontWeight.bold)*/);
}

getReplyMessage(
    String messageType, String? messageTextContent, String? contactName, String? mediaFileName, MediaChatMessage? mediaChatMessage, bool isReplying,TextStyle textStyle) {
  debugPrint(messageType);
  switch (messageType) {
    case Constants.mText:
      return Row(
        children: [
          MessageUtils.getMediaTypeIcon(Constants.mText),
          // Text(messageTextContent!),
          Expanded(child: Text(messageTextContent!, maxLines: 1, overflow: TextOverflow.ellipsis,style: textStyle,)),
        ],
      );
    case Constants.mImage:
      return Row(
        children: [
          MessageUtils.getMediaTypeIcon(Constants.mImage),
          const SizedBox(
            width: 5,
          ),
          Text(Constants.mImage.capitalizeFirst!,style: textStyle,),
        ],
      );
    case Constants.mVideo:
      return Row(
        children: [
          MessageUtils.getMediaTypeIcon(Constants.mVideo),
          const SizedBox(
            width: 5,
          ),
          Text(Constants.mVideo.capitalizeFirst!,style: textStyle),
        ],
      );
    case Constants.mAudio:
      return Row(
        children: [
          isReplying
              ? MessageUtils.getMediaTypeIcon(Constants.mAudio, mediaChatMessage != null ? mediaChatMessage.isAudioRecorded : true)
              : const Offstage(),
          isReplying
              ? const SizedBox(
                  width: 5,
                )
              : const Offstage(),
          Text(
            DateTimeUtils.durationToString(Duration(milliseconds: mediaChatMessage != null ? mediaChatMessage.mediaDuration : 0)),style: textStyle
          ),
          const SizedBox(
            width: 5,
          ),
          // Text(Constants.mAudio.capitalizeFirst!),
        ],
      );
    case Constants.mContact:
      return Row(
        children: [
          MessageUtils.getMediaTypeIcon(Constants.mContact),
          const SizedBox(
            width: 5,
          ),
          Text("${Constants.mContact.capitalizeFirst} :",style: textStyle),
          const SizedBox(
            width: 5,
          ),
          SizedBox(
              width: 120,
              child: Text(
                contactName!,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis, style: textStyle
              )),
        ],
      );
    case Constants.mLocation:
      return Row(
        children: [
          MessageUtils.getMediaTypeIcon(Constants.mLocation),
          const SizedBox(
            width: 5,
          ),
          Text(Constants.mLocation.capitalizeFirst!,style: textStyle),
        ],
      );
    case Constants.mDocument:
      return Row(
        children: [
          MessageUtils.getMediaTypeIcon(Constants.mDocument),
          const SizedBox(
            width: 5,
          ),
          Flexible(
              child: Text(
            mediaFileName!,
            overflow: TextOverflow.ellipsis,
            maxLines: 1, style: textStyle
          )),
        ],
      );
    default:
      return const Offstage();
  }
}

getReplyImageHolder(BuildContext context, ChatMessageModel chatMessageModel, MediaChatMessage? mediaChatMessage, double size, bool isNotChatItem,
    LocationChatMessage? locationChatMessage,IconStyle iconStyle,BorderRadius borderRadius) {
  var isReply = false;
  if (mediaChatMessage != null || locationChatMessage != null) {
    isReply = true;
  }
  var condition = !isNotChatItem
      ? chatMessageModel.replyParentChatMessage?.messageType //(mediaChatMessage == null ? Constants.mLocation : mediaChatMessage.messageType)
      : chatMessageModel.messageType;
  LogMessage.d("isReply", isReply);
  LogMessage.d("condition", condition);
  LogMessage.d("chatMessageModel.messageType", chatMessageModel.messageType);
  switch (condition) {
    case Constants.mImage:
      debugPrint("reply header--> IMAGE");
      return ClipRRect(
        borderRadius: borderRadius,//const BorderRadius.only(topRight: Radius.circular(5), bottomRight: Radius.circular(5)),
        child: SizedBox(
          width: size,
          height: size,
          child: ImageCacheManager.getImage(
              isReply ? mediaChatMessage!.mediaThumbImage : chatMessageModel.mediaChatMessage!.mediaThumbImage.checkNull(),chatMessageModel.messageId, size, size),
        ),
      );
    case Constants.mLocation:
      return ClipRRect(
          borderRadius: borderRadius,//const BorderRadius.only(topRight: Radius.circular(5), bottomRight: Radius.circular(5)),
          child: getLocationImage(isReply ? locationChatMessage : chatMessageModel.locationChatMessage, size, size, isSelected: true));
    case Constants.mVideo:
      return ClipRRect(
        borderRadius: borderRadius,//const BorderRadius.only(topRight: Radius.circular(5), bottomRight: Radius.circular(5)),
        child: SizedBox(
          width: size,
          height: size,
          child: ImageCacheManager.getImage(
              isReply ? mediaChatMessage!.mediaThumbImage : chatMessageModel.mediaChatMessage!.mediaThumbImage, chatMessageModel.messageId, size, size),
        ),
      );
    case Constants.mDocument:
      debugPrint("isNotChatItem--> $isNotChatItem");
      debugPrint("Document --> $isReply");
      return isNotChatItem
          ? SizedBox(height: size)
          : Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                borderRadius: borderRadius,//const BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
                color: iconStyle.bgColor,
              ),
              child: Center(
                child: MessageUtils.getDocumentTypeIcon(isReply ? mediaChatMessage!.mediaFileName : chatMessageModel.mediaChatMessage!.mediaFileName, 30),
              ));
    case Constants.mAudio:
      return isNotChatItem
          ? SizedBox(height: size)
          : ClipRRect(
              borderRadius: borderRadius,//const BorderRadius.only(topRight: Radius.circular(5), bottomRight: Radius.circular(5)),
              child: Container(
                height: size,
                width: size,
                color: iconStyle.bgColor,
                child: Center(
                  child: AppUtils.svgIcon(icon:
                    mediaChatMessage!.isAudioRecorded.checkNull() ? mAudioRecordIcon : mAudioIcon,
                    fit: BoxFit.contain,
                    colorFilter: ColorFilter.mode(iconStyle.iconColor, BlendMode.srcIn),
                    height: 18,
                  ),
                ),
              ),
            );
    default:
      debugPrint("reply header--> DEFAULT");
      return SizedBox(
        height: size,
      );
  }
}

class ReplyMessageHeader extends StatelessWidget {
  const ReplyMessageHeader({Key? key, required this.chatMessage, this.replyHeaderMessageViewStyle = const ReplyHeaderMessageViewStyle()})
      : super(key: key);
  final ChatMessageModel chatMessage;
  final ReplyHeaderMessageViewStyle replyHeaderMessageViewStyle;

  @override
  Widget build(BuildContext context) {
    LogMessage.d("ReplyMessageHeader", chatMessage.toJson());
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
      margin: const EdgeInsets.all(4),
      decoration: replyHeaderMessageViewStyle.decoration,
      /*decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: chatMessage.isMessageSentByMe
            ? chatReplyContainerColor
            : chatReplySenderColor,
      ),*/
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getReplyTitle(
                    chatMessage.replyParentChatMessage!.isMessageSentByMe,
                    chatMessage.replyParentChatMessage!.senderUserName,replyHeaderMessageViewStyle.titleTextStyle),
                const SizedBox(height: 5),
                getReplyMessage(
                    chatMessage.replyParentChatMessage!.messageType,
                    chatMessage.replyParentChatMessage?.messageTextContent,
                    chatMessage.replyParentChatMessage?.contactChatMessage
                        ?.contactName,
                    chatMessage.replyParentChatMessage?.mediaChatMessage
                        ?.mediaFileName,
                    chatMessage.replyParentChatMessage?.mediaChatMessage,
                    false,replyHeaderMessageViewStyle.contentTextStyle),
              ],
            ),
          ),
          getReplyImageHolder(
              context,
              chatMessage,
              chatMessage.replyParentChatMessage?.mediaChatMessage,
              55,
              false,
              chatMessage.replyParentChatMessage?.locationChatMessage,replyHeaderMessageViewStyle.mediaIconStyle,replyHeaderMessageViewStyle.borderRadius),
        ],
      ),
    );
  }
}
