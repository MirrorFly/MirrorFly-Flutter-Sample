import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/utils.dart';
import '../../../extensions/extensions.dart';
import '../../../modules/chat/widgets/caption_message_view.dart';
import '../../../stylesheet/stylesheet.dart';

import '../../../common/constants.dart';
import '../../../data/helper.dart';
import '../../../model/chat_message_model.dart';
import '../../../routes/route_settings.dart';
import 'image_cache_manager.dart';
import 'media_message_overlay.dart';

class ImageMessageView extends StatefulWidget {
  final ChatMessageModel chatMessage;
  final String search;
  final bool isSelected;
  final ImageMessageViewStyle imageMessageViewStyle;
  final Decoration decoration;

  const ImageMessageView({super.key, required this.chatMessage, this.search = "", required this.isSelected,this.imageMessageViewStyle = const ImageMessageViewStyle(), this.decoration = const BoxDecoration()});

  @override
  State<ImageMessageView> createState() => _ImageMessageViewState();
}

class _ImageMessageViewState extends State<ImageMessageView> {
  @override
  Widget build(BuildContext context) {
    var mediaMessage = widget.chatMessage.mediaChatMessage!;
    return Container(
      key: ValueKey(widget.chatMessage.messageId),
      width: NavUtils.size.width * 0.60,
      padding: const EdgeInsets.all(2.0),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width:NavUtils.width * 0.60,
                height: NavUtils.height *0.4,
                child: ClipRRect(
                  borderRadius: widget.imageMessageViewStyle.imageBorderRadius,
                  child: Obx(() {
                    return getImage(
                        mediaMessage.mediaLocalStoragePath, mediaMessage.mediaThumbImage, context, mediaMessage.mediaFileName, widget.isSelected, widget.chatMessage.messageId, widget.chatMessage.isMediaDownloaded());
                  }),
                ),
              ),
              MediaMessageOverlay(chatMessage: widget.chatMessage,downloadUploadViewStyle: widget.imageMessageViewStyle.downloadUploadViewStyle,),
              mediaMessage.mediaCaptionText.checkNull().isEmpty
                  ? Positioned(
                      bottom: 8,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.only(left: 30, top: 30),
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(mediaBg),
                            fit: BoxFit.fill,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            widget.chatMessage.isMessageStarred.value ? widget.imageMessageViewStyle.iconFavourites ?? AppUtils.svgIcon(icon:starSmallIcon) : const SizedBox.shrink(),
                            const SizedBox(
                              width: 5,
                            ),
                            MessageUtils.getMessageIndicatorIcon(widget.chatMessage.messageStatus.value, widget.chatMessage.isMessageSentByMe,
                                widget.chatMessage.messageType, widget.chatMessage.isMessageRecalled.value),
                            const SizedBox(
                              width: 4,
                            ),
                            Stack(
                              children: [
                                // AppUtils.assetIcon(assetName:cornerShadow,width: 40,height: 20,fit: BoxFit.fitHeight,),
                                Text(
                                  getChatTime(context, widget.chatMessage.messageSentTime.toInt()),
                                  style: widget.imageMessageViewStyle.timeTextStyle,
                                  // style: TextStyle(fontSize: 11, color: widget.chatMessage.isMessageSentByMe ? durationTextColor : textButtonColor),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  : const Offstage(),
            ],
          ),
          mediaMessage.mediaCaptionText.checkNull().isNotEmpty
              ? CaptionMessageView(mediaMessage: mediaMessage, chatMessage: widget.chatMessage, context: context, search: widget.search,textMessageViewStyle: widget.imageMessageViewStyle.captionTextViewStyle,)
              : const Offstage(),
        ],
      ),
    );
  }

/* @override
  bool get wantKeepAlive => true;*/
}

getImage(RxString mediaLocalStoragePath, String mediaThumbImage, BuildContext context, String mediaFileName, bool isSelected, String messageId, bool isMediaDownloaded) {
  debugPrint("getImage mediaLocalStoragePath : $mediaLocalStoragePath -- $mediaFileName");
  // isMediaDownloaded conditional check is for the media download in android once
  // after deleting it from local, the isMediaExists returns true but the file is empty,
  // error Image error builder, so we added.
  if (MediaUtils.isMediaExists(mediaLocalStoragePath.value) && isMediaDownloaded) {
    return InkWell(
        onTap: isSelected
            ? null
            : () {
                NavUtils.toNamed(Routes.imageView, arguments: {'imageName': mediaFileName, 'imagePath': mediaLocalStoragePath.value});
              },
        child: Obx(() {
          return Image(
            image: FileImage(File(mediaLocalStoragePath.value)),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return FutureBuilder(
                    future: null,
                    builder: (context, d) {
                      return child;
                    });
              }
              return const Center(child: CircularProgressIndicator());
            },
            frameBuilder: (cxt, child, frame, wasSynchronouslyLoaded) {
              debugPrint("getImage frameBuilder : frame : $frame ,wasSynchronouslyLoaded :$wasSynchronouslyLoaded");
              return child;
            },
            errorBuilder: (cxt, obj, strace) {
              debugPrint("getImage errorBuilder : obj : $obj ,strace :$strace");
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("$obj"),
              );
            },
            width: NavUtils.size.width * 0.60,
            height: NavUtils.size.height * 0.4,
            fit: BoxFit.cover,
          );
        }));
  } else {
    return ImageCacheManager.getImage(mediaThumbImage, messageId);
  }
}

