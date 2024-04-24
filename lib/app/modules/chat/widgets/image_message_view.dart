import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/extensions.dart';
import 'package:mirror_fly_demo/app/modules/gallery_picker/src/core/decode_image.dart';

import '../../../common/constants.dart';
import '../../../data/helper.dart';
import '../../../model/chat_message_model.dart';
import '../../../routes/app_pages.dart';
import '../chat_widgets.dart';

class ImageMessageView extends StatefulWidget {
  final ChatMessageModel chatMessage;
  final String search;
  final bool isSelected;

  const ImageMessageView({super.key, required this.chatMessage, this.search = "", required this.isSelected});

  @override
  State<ImageMessageView> createState() => _ImageMessageViewState();
}

class _ImageMessageViewState extends State<ImageMessageView> {
  @override
  Widget build(BuildContext context) {
    // super.build(context);
    // LogMessage.d("ImageMessageView", "build ${widget.chatMessage.toJson()}");
    var mediaMessage = widget.chatMessage.mediaChatMessage!;
    return Container(
      key: ValueKey(widget.chatMessage.messageId),
      width: Get.width * 0.60,
      padding: const EdgeInsets.all(2.0),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Obx(() {
                  return getImage(
                      mediaMessage.mediaLocalStoragePath, mediaMessage.mediaThumbImage, context, mediaMessage.mediaFileName, widget.isSelected, widget.chatMessage.messageId);
                }),
              ),
              Obx(() {
                // LogMessage.d("ImageMessageView", "getImageOverlay ${widget.chatMessage.messageId}");
                return getImageOverlay(widget.chatMessage);
              }),
              mediaMessage.mediaCaptionText.checkNull().isEmpty
                  ? Positioned(
                      bottom: 8,
                      right: 10,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          widget.chatMessage.isMessageStarred.value ? SvgPicture.asset(starSmallIcon) : const SizedBox.shrink(),
                          const SizedBox(
                            width: 5,
                          ),
                          getMessageIndicator(widget.chatMessage.messageStatus.value, widget.chatMessage.isMessageSentByMe,
                              widget.chatMessage.messageType, widget.chatMessage.isMessageRecalled.value),
                          const SizedBox(
                            width: 4,
                          ),
                          Stack(
                            children: [
                              // Image.asset(cornerShadow,width: 40,height: 20,fit: BoxFit.fitHeight,),
                              Text(
                                getChatTime(context, widget.chatMessage.messageSentTime.toInt()),
                                style: TextStyle(fontSize: 11, color: widget.chatMessage.isMessageSentByMe ? durationTextColor : textButtonColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : const Offstage(),
            ],
          ),
          mediaMessage.mediaCaptionText.checkNull().isNotEmpty
              ? setCaptionMessage(mediaMessage, widget.chatMessage, context, search: widget.search)
              : const Offstage(),
        ],
      ),
    );
  }

/* @override
  bool get wantKeepAlive => true;*/
}

getImage(RxString mediaLocalStoragePath, String mediaThumbImage, BuildContext context, String mediaFileName, bool isSelected, String messageId) {
  debugPrint("getImage mediaLocalStoragePath : $mediaLocalStoragePath -- $mediaFileName");
  if (checkFile(mediaLocalStoragePath.value)) {
    return InkWell(
        onTap: isSelected
            ? null
            : () {
                Get.toNamed(Routes.imageView, arguments: {'imageName': mediaFileName, 'imagePath': mediaLocalStoragePath.value});
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
            width: Get.width * 0.60,
            height: Get.height * 0.4,
            fit: BoxFit.cover,
          );
        }));
  } else {
    // return Image(
    //   image: DecodeImageNew(
    //       mediaThumbImage,
    //       thumbSize: 100),
    //   gaplessPlayback: true,
    //   fit: BoxFit.cover,
    //   filterQuality: FilterQuality.high,
    // );
    return ImageCacheManager.getImage(mediaThumbImage, messageId);
    // return imageFromBase64String(mediaThumbImage, context, null, null);
    // return ImageScreen(base64: mediaThumbImage);
    // return NetworkImage(url)
  }
}

class ImageCacheManager {
  static final Map<String, Image> _cache = {};

  static Image getImage(String base64String, String messageId) {
    if (_cache.containsKey(messageId)) {
      return _cache[messageId]!;
    } else {
      Uint8List bytes = base64Decode(base64String);
      Image image = Image.memory(bytes, gaplessPlayback: true,  width: Get.width * 0.60,
        height: Get.height * 0.4, fit: BoxFit.cover,);
      _cache[messageId] = image;
      return image;
    }
  }
}

