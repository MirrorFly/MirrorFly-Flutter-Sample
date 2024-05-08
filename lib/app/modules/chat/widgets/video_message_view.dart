import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/data/utils.dart';
import 'package:mirror_fly_demo/app/extensions/extensions.dart';
import 'package:mirrorfly_plugin/message_params.dart';

import '../../../common/constants.dart';
import '../../../data/helper.dart';
import '../../../model/chat_message_model.dart';
import '../../../routes/route_settings.dart';
import '../chat_widgets.dart';
import 'caption_message_view.dart';
import 'media_message_overlay.dart';

class VideoMessageView extends StatelessWidget {
  const VideoMessageView({Key? key,
    required this.chatMessage,
    this.search = "",
    required this.isSelected})
      : super(key: key);
  final ChatMessageModel chatMessage;
  final String search;
  final bool isSelected;

  onVideoClick() {
    switch (chatMessage.isMessageSentByMe
        ? chatMessage.mediaChatMessage?.mediaUploadStatus.value
        : chatMessage.mediaChatMessage?.mediaDownloadStatus.value) {
      case MediaDownloadStatus.isMediaDownloaded:
      case MediaUploadStatus.isMediaUploaded:
        if (chatMessage.messageType.toUpperCase() == 'VIDEO') {
          if (MediaUtils.isFileExist(chatMessage.mediaChatMessage!.mediaLocalStoragePath.value) &&
              (chatMessage.mediaChatMessage!.mediaDownloadStatus.value ==
                  MediaDownloadStatus.isMediaDownloaded ||
                  chatMessage.mediaChatMessage!.mediaDownloadStatus.value ==
                      MediaUploadStatus.isMediaUploaded ||
                  chatMessage.isMessageSentByMe)) {
            Get.toNamed(Routes.videoPlay, arguments: {
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
      width: Get.width * 0.60,
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
                  borderRadius: BorderRadius.circular(15),
                  child: imageFromBase64String(
                      mediaMessage.mediaThumbImage, context, null, null),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Row(
                  children: [
                    SvgPicture.asset(
                      mVideoIcon,
                      fit: BoxFit.contain,
                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      Helper.durationToString(
                          Duration(milliseconds: mediaMessage.mediaDuration)),
                      style: const TextStyle(fontSize: 11, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Obx(() {
                return MediaMessageOverlay(chatMessage: chatMessage,
                    onVideo: isSelected ? null : onVideoClick);
              }),
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
                        ? SvgPicture.asset(starSmallIcon)
                        : const Offstage(),
                    const SizedBox(
                      width: 5,
                    ),
                    getMessageIndicator(
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
                      style: TextStyle(
                          fontSize: 11,
                          color: chatMessage.isMessageSentByMe
                              ? durationTextColor
                              : textHintColor),
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
              search: search)
              : const SizedBox()
        ],
      ),
    );
  }
}