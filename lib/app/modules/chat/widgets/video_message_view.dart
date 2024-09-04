import 'package:flutter/material.dart';
import '../../../data/utils.dart';
import '../../../extensions/extensions.dart';
import '../../../stylesheet/stylesheet.dart';
import 'package:mirrorfly_plugin/message_params.dart';

import '../../../common/constants.dart';
import '../../../data/helper.dart';
import '../../../model/chat_message_model.dart';
import '../../../routes/route_settings.dart';
import 'caption_message_view.dart';
import 'image_cache_manager.dart';
import 'media_message_overlay.dart';

class VideoMessageView extends StatelessWidget {
  const VideoMessageView({Key? key,
    required this.chatMessage,
    this.search = "",
    required this.isSelected,
  this.videoMessageViewStyle = const VideoMessageViewStyle()})
      : super(key: key);
  final ChatMessageModel chatMessage;
  final String search;
  final bool isSelected;
  final VideoMessageViewStyle videoMessageViewStyle;

  onVideoClick() {
    switch (chatMessage.isMessageSentByMe
        ? chatMessage.mediaChatMessage?.mediaUploadStatus.value
        : chatMessage.mediaChatMessage?.mediaDownloadStatus.value) {
      case MediaDownloadStatus.isMediaDownloaded:
      case MediaUploadStatus.isMediaUploaded:
        if (chatMessage.messageType.toUpperCase() == 'VIDEO') {
          if (MediaUtils.isMediaExists(chatMessage.mediaChatMessage!.mediaLocalStoragePath.value) &&
              (chatMessage.mediaChatMessage!.mediaDownloadStatus.value ==
                  MediaDownloadStatus.isMediaDownloaded ||
                  chatMessage.mediaChatMessage!.mediaDownloadStatus.value ==
                      MediaUploadStatus.isMediaUploaded ||
                  chatMessage.isMessageSentByMe)) {
            NavUtils.toNamed(Routes.videoPlay, arguments: {
              "filePath": chatMessage.mediaChatMessage!.mediaLocalStoragePath.value,
            });
          } else {
            debugPrint("file is video but condition failed");
          }
        } else {
          debugPrint("File is not video");
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    var mediaMessage = chatMessage.mediaChatMessage!;
    return Container(
      width: NavUtils.width * 0.60,
      padding: const EdgeInsets.all(2.0),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              InkWell(
                onTap: isSelected
                    ? null
                    : () {
                  onVideoClick();
                },
                child: ClipRRect(
                  borderRadius: videoMessageViewStyle.videoBorderRadius,
                  child: ImageCacheManager.getImage(
                      mediaMessage.mediaThumbImage, chatMessage.messageId),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Row(
                  children: [
                    AppUtils.svgIcon(icon:
                      mVideoIcon,
                      fit: BoxFit.contain,
                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      DateTimeUtils.durationToString(
                          Duration(milliseconds: mediaMessage.mediaDuration)),
                      style: videoMessageViewStyle.timeTextStyle,
                      // style: const TextStyle(fontSize: 11, color: Colors.white),
                    ),
                  ],
                ),
              ),
              MediaMessageOverlay(chatMessage: chatMessage,
                    onVideo: isSelected ? null : onVideoClick,downloadUploadViewStyle: videoMessageViewStyle.downloadUploadViewStyle,),
              mediaMessage.mediaCaptionText
                  .checkNull()
                  .isEmpty
                  ? Positioned(
                bottom: 8,
                right: 10,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                      getChatTime(
                          context, chatMessage.messageSentTime.toInt()),
                      style: videoMessageViewStyle.timeTextStyle,
                      // style: TextStyle(
                      //     fontSize: 11,
                      //     color: chatMessage.isMessageSentByMe
                      //         ? durationTextColor
                      //         : textHintColor),
                    ),
                  ],
                ),
              )
                  : const SizedBox(),
            ],
          ),
          mediaMessage.mediaCaptionText
              .checkNull()
              .isNotEmpty
              ? CaptionMessageView(mediaMessage: mediaMessage, chatMessage: chatMessage, context: context,
              search: search,textMessageViewStyle: videoMessageViewStyle.captionTextViewStyle,)
              : const SizedBox()
        ],
      ),
    );
  }
}