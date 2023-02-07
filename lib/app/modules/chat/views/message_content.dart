import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/main_controller.dart';

import '../../../common/constants.dart';
import '../../../data/helper.dart';
import '../../../routes/app_pages.dart';
import 'package:flysdk/flysdk.dart';

import '../chat_widgets.dart';

class MessageContent extends StatefulWidget {
   const MessageContent({Key? key, required this.chatList, required this.isTapEnabled}) : super(key: key);

  final ChatMessageModel chatList;
  final bool isTapEnabled;

  @override
  State<MessageContent> createState() => _MessageContentState();
}

class _MessageContentState extends State<MessageContent> {
  var controller = Get.find<MainController>();
  // var screenWidth, screenHeight;
  @override
  Widget build(BuildContext context) {

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      child: getMessageContent(widget.chatList, screenHeight, screenWidth)
    );
}

  getMessageContent(ChatMessageModel chatList, double screenHeight, double screenWidth) {

    if (chatList.messageType == Constants.mText) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisSize: chatList.replyParentChatMessage == null
              ? MainAxisSize.min
              : MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              chatList.messageTextContent ?? "",
              style: const TextStyle(fontSize: 17),
            ),
            const SizedBox(
              width: 10,
            ),
            Row(
              children: [
                chatList.isMessageStarred
                    ? const Icon(
                  Icons.star,
                  size: 13,
                )
                    : const SizedBox.shrink(),
                const SizedBox(
                  width: 5,
                ),
                getMessageIndicator(
                    chatList.messageStatus,
                    chatList.isMessageSentByMe,
                    chatList.messageType),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  getChatTime(
                      context, chatList.messageSentTime.toInt()),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      );
    } else if (chatList.messageType.toUpperCase() == Constants.mNotification) {
      return Center(
        child: Container(
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(40)),
              color: chatReplyContainerColor),
          padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 8.0, bottom: 8.0),
          // child: Text(chatList[index].messageTextContent!,
          child: Text(chatList.messageTextContent ?? "",
              style:
              const TextStyle(fontSize: 12)),
        ),
      );
    } else if (chatList.messageType == Constants.mImage) {
      var chatMessage = chatList.mediaChatMessage!;
      //mediaLocalStoragePath
      //mediaThumbImage
      return Padding(
        padding: const EdgeInsets.all(2.0),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: getImage(
                  chatMessage.mediaLocalStoragePath,
                  chatMessage.mediaThumbImage,
                  context,
                  chatMessage.mediaFileName),
            ),
            Positioned(
                top: (screenHeight * 0.4) / 2.5,
                left: (screenWidth * 0.6) / 3,
                child: InkWell(
                    onTap: () {
                      handleMediaUploadDownload(
                          chatMessage.mediaDownloadStatus, chatList);
                    },
                    child: getImageOverlay(chatList, context))),
            Positioned(
              bottom: 8,
              right: 10,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  chatList.isMessageStarred
                      ? const Icon(
                    Icons.star,
                    size: 13,
                  )
                      : const SizedBox.shrink(),
                  const SizedBox(
                    width: 5,
                  ),
                  getMessageIndicator(
                      chatList.messageStatus,
                      chatList.isMessageSentByMe,
                      chatList.messageType),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    getChatTime(
                        context, chatList.messageSentTime.toInt()),
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (chatList.messageType == Constants.mVideo) {
      var chatMessage = chatList.mediaChatMessage!;
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            InkWell(
              onTap: () {
                if (controller.checkFile(chatMessage.mediaLocalStoragePath) &&
                    (chatMessage.mediaDownloadStatus ==
                        Constants.mediaDownloaded ||
                        chatMessage.mediaDownloadStatus ==
                            Constants.mediaUploaded)) {
                  Get.toNamed(Routes.videoPlay, arguments: {
                    "filePath": chatMessage.mediaLocalStoragePath,
                  });
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: controller.imageFromBase64String(
                    chatMessage.mediaThumbImage, context, null, null),
              ),
            ),
            Positioned(
                top: (screenHeight * 0.4) / 2.6,
                left: (screenWidth * 0.6) / 2.9,
                child: InkWell(
                    onTap: () {
                      handleMediaUploadDownload(
                          chatMessage.mediaDownloadStatus, chatList);
                    },
                    child: getImageOverlay(chatList, context))),
            Positioned(
              bottom: 8,
              right: 10,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  chatList.isMessageStarred
                      ? const Icon(
                    Icons.star,
                    size: 13,
                  )
                      : const SizedBox.shrink(),
                  const SizedBox(
                    width: 5,
                  ),
                  getMessageIndicator(
                      chatList.messageStatus,
                      chatList.isMessageSentByMe,
                      chatList.messageType),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    getChatTime(
                        context, chatList.messageSentTime.toInt()),
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (chatList.messageType == Constants.mDocument) {
      return InkWell(
        onTap: () {
          controller.openDocument(
              chatList.mediaChatMessage!.mediaLocalStoragePath, context);
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: chatReplySenderColor,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            color: Colors.white,
          ),
          width: screenWidth * 0.60,
          child: Column(
            children: [
              Padding(
                padding:
                const EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0),
                child: Row(
                  children: [
                    getImageHolder(
                        chatList.mediaChatMessage!.mediaFileName),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                        child: Text(
                          chatList.mediaChatMessage!.mediaFileName,
                          maxLines: 2,
                        )),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        handleMediaUploadDownload(
                            chatList
                                .mediaChatMessage!
                                .mediaDownloadStatus,
                            chatList);
                      },
                      child: getImageOverlay(chatList, context),
                    ),
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
                    chatList.isMessageStarred
                        ? const Icon(
                      Icons.star,
                      size: 13,
                    )
                        : const SizedBox.shrink(),
                    const SizedBox(
                      width: 5,
                    ),
                    getMessageIndicator(
                        chatList.messageStatus,
                        chatList.isMessageSentByMe,
                        chatList.messageType),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      getChatTime(
                          context, chatList.messageSentTime.toInt()),
                      style: const TextStyle(fontSize: 12, color: Colors.black),
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
    } else if (chatList.messageType == Constants.mContact) {
      return InkWell(
        onTap: () {
          // Get.toNamed(Routes.previewContact, arguments: {
          //   "contactList":
          //   chatList.contactChatMessage!.contactPhoneNumbers,
          //   "contactName": chatList.contactChatMessage!.contactName,
          //   "from": "chat"
          // });
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: chatReplySenderColor,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            color: Colors.white,
          ),
          width: screenWidth * 0.60,
          child: Column(
            children: [
              Padding(
                padding:
                const EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0),
                child: Row(
                  children: [
                    Image.asset(
                      profileImage,
                      width: 35,
                      height: 35,
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                        child: Text(
                          chatList.contactChatMessage!.contactName,
                          maxLines: 2,
                        )),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    chatList.isMessageStarred
                        ? const Icon(
                      Icons.star,
                      size: 13,
                    )
                        : const SizedBox.shrink(),
                    const SizedBox(
                      width: 5,
                    ),
                    getMessageIndicator(
                        chatList.messageStatus,
                        chatList.isMessageSentByMe,
                        chatList.messageType),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      getChatTime(
                          context, chatList.messageSentTime.toInt()),
                      style: const TextStyle(fontSize: 12, color: Colors.black),
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
    } else if (chatList.messageType == Constants.mAudio) {
      var chatMessage = chatList;
      return Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: chatReplySenderColor,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          color: Colors.white,
        ),
        width: screenWidth * 0.60,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
                color: chatReplySenderColor,
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SvgPicture.asset(
                          audioMicBg,
                          width: 28,
                          height: 28,
                          fit: BoxFit.contain,
                        ),
                        SvgPicture.asset(
                          audioMic1,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                    // getAudioFeedButton(chatMessage),
                    const SizedBox(
                      width: 10,
                    ),
                    InkWell(
                      onTap: () {
                        handleMediaUploadDownload(
                            chatMessage.mediaChatMessage!.mediaDownloadStatus,
                            chatList);
                      },
                      child: getImageOverlay(chatList, context),
                    ),

                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: SizedBox(
                        // width: 168,
                        child: SliderTheme(
                          data: SliderThemeData(
                            thumbColor: audioColorDark,
                            overlayShape: SliderComponentShape.noOverlay,
                            thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 5),
                          ),
                          child: Slider(
                            value: double.parse(
                                controller.currentPos.value.toString()),
                            min: 0,
                            activeColor: audioColorDark,
                            inactiveColor: audioColor,
                            max: double.parse(
                                controller.maxDuration.value.toString()),
                            divisions: controller.maxDuration.value,
                            onChanged: (double value) async {

                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
                  chatList.isMessageStarred
                      ? const Icon(
                    Icons.star,
                    size: 13,
                  )
                      : const SizedBox.shrink(),
                  const SizedBox(
                    width: 5,
                  ),
                  getMessageIndicator(
                      chatList.messageStatus,
                      chatList.isMessageSentByMe,
                      chatList.messageType),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    getChatTime(
                        context, chatList.messageSentTime.toInt()),
                    style: const TextStyle(fontSize: 12, color: Colors.black),
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
      );
    } else if (chatList.messageType.toUpperCase() ==
        Constants.mLocation) {
      return Padding(
        padding: const EdgeInsets.all(2.0),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: controller.getLocationImage(
                  chatList.locationChatMessage, 200, 171),
            ),
            Positioned(
              bottom: 8,
              right: 10,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  chatList.isMessageStarred
                      ? const Icon(
                    Icons.star,
                    size: 13,
                  )
                      : const SizedBox.shrink(),
                  const SizedBox(
                    width: 5,
                  ),
                  getMessageIndicator(
                      chatList.messageStatus,
                      chatList.isMessageSentByMe,
                      chatList.messageType),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    getChatTime(
                        context, chatList.messageSentTime.toInt()),
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                  ),
                ],
              ),
            ),
            /*Positioned(
              bottom: 8,
              right: 10,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  getMessageIndicator(
                      chatList.messageStatus.status,
                      chatList.isMessageSentByMe,
                      chatList.messageType),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    controller.getChatTime(
                        context, chatList.messageSentTime),
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ],
              ),
            ),*/
          ],
        ),
      );
    }

  }

  getMessageIndicator(
      String? messageStatus, bool isSender, String messageType) {
    // debugPrint("Message Type ==> $messageType");
    if (isSender) {
      if (messageStatus == 'A' || messageStatus == 'acknowledge') {
        return SvgPicture.asset('assets/logos/acknowledged.svg');
      } else if (messageStatus == 'D' || messageStatus == 'delivered') {
        return SvgPicture.asset('assets/logos/delivered.svg');
      } else if (messageStatus == 'S' || messageStatus == 'seen') {
        return SvgPicture.asset('assets/logos/seen.svg');
      } else {
        return const Icon(
          Icons.access_time_filled,
          size: 10,
          color: Colors.red,
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  getImageOverlay(
      ChatMessageModel chatList, BuildContext context) {
    var chatMessage = chatList;
    debugPrint("****GET IMAGE OVERLAY**** ${chatMessage.messageStatus} **** ${chatMessage.messageType.toUpperCase()}");
    if (controller
        .checkFile(chatMessage.mediaChatMessage!.mediaLocalStoragePath) &&
        chatMessage.messageStatus != 'N'){
      if (chatMessage.messageType.toUpperCase() == 'VIDEO') {
        return SizedBox(
          width: 80,
          height: 50,
          child: Center(
              child: SvgPicture.asset(
                videoPlay,
                fit: BoxFit.contain,
              )),
        );
      } else if (chatMessage.messageType.toUpperCase() == 'AUDIO') {
        debugPrint("===============================");
        debugPrint(chatMessage.mediaChatMessage!.isPlaying.toString());
        // return Obx(() {
        return chatMessage.mediaChatMessage!.isPlaying
            ? const Icon(Icons.pause)
            : const Icon(Icons.play_arrow_sharp);
        // });
      } else {
        return const SizedBox.shrink();
      }
    } else {
      switch (chatMessage.isMessageSentByMe
          ? chatMessage.mediaChatMessage!.mediaUploadStatus
          : chatMessage.mediaChatMessage!.mediaDownloadStatus) {
        case Constants.mediaDownloaded:
        case Constants.mediaUploaded:
          return const SizedBox.shrink();

        case Constants.mediaDownloadedNotAvailable:
        case Constants.mediaNotDownloaded:
          return getFileInfo(
              chatMessage.mediaChatMessage!.mediaDownloadStatus,
              chatMessage.mediaChatMessage!.mediaFileSize,
              Icons.download_sharp,
              chatMessage.messageType.toUpperCase());
        case Constants.mediaUploadedNotAvailable:
          return getFileInfo(
              chatMessage.mediaChatMessage!.mediaDownloadStatus,
              chatMessage.mediaChatMessage!.mediaFileSize,
              Icons.upload_sharp,
              chatMessage.messageType.toUpperCase());

        case Constants.mediaNotUploaded:
        case Constants.mediaDownloading:
        case Constants.mediaUploading:
          if (chatMessage.messageType.toUpperCase() == 'AUDIO' ||
              chatMessage.messageType.toUpperCase() == 'DOCUMENT') {
            return InkWell(
                onTap: () {
                  debugPrint(chatMessage.messageId);
                  cancelMediaUploadOrDownload(chatMessage.messageId);
                },
                child:
                SizedBox(width: 30, height: 30, child: uploadingView(chatMessage.messageType)));
          } else {
            return InkWell(
              onTap: (){
                cancelMediaUploadOrDownload(chatMessage.messageId);
              },
              child: SizedBox(
                height: 40,
                width: 80,
                child: uploadingView(chatMessage.messageType),
              ),
            );
          }
      }
    }
  }
  getFileInfo(int mediaDownloadStatus, int mediaFileSize, IconData iconData,
      String messageType) {
    return messageType == 'AUDIO' || messageType == 'DOCUMENT'
        ? Icon(
      iconData,
      color: audioColorDark,
    )
        : Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: textColor,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          color: Colors.black38,
        ),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Row(
          children: [
            Icon(
              iconData,
              color: Colors.white,
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              Helper.formatBytes(mediaFileSize, 0),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ));
  }
  uploadingView(String messageType) {
    if(messageType == "AUDIO"){
      return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: textColor,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(2)),
            color: Colors.black45,
          ),
          child: Stack(alignment: Alignment.center,
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  downloading,
                  fit: BoxFit.contain,
                ),
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    height: 2,
                    child: LinearProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                      backgroundColor: audioBgColor,
                      // minHeight: 1,
                    ),
                  ),
                ),
              ]));
    }
    return Container(
      // height: 40,
      // width: 80,
        decoration: BoxDecoration(
          border: Border.all(
            color: textColor,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(2)),
          color: audioBgColor,
        ),
        // padding: EdgeInsets.symmetric(vertical: 5),
        child: Stack(alignment: Alignment.center,
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                downloading,
                fit: BoxFit.contain,
              ),
              const Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: 2,
                  child: LinearProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                    backgroundColor: audioBgColor,
                    // minHeight: 1,
                  ),
                ),
              ),
            ]));
  }

  handleMediaUploadDownload(
      int mediaDownloadStatus, ChatMessageModel chatList) {
    switch (chatList.isMessageSentByMe
        ? chatList.mediaChatMessage?.mediaUploadStatus
        : mediaDownloadStatus) {
      case Constants.mediaDownloaded:
      case Constants.mediaUploaded:
        if (chatList.messageType == 'VIDEO') {
          if (controller.checkFile(
              chatList.mediaChatMessage!.mediaLocalStoragePath) &&
              (chatList.mediaChatMessage!.mediaDownloadStatus ==
                  Constants.mediaDownloaded ||
                  chatList.mediaChatMessage!.mediaDownloadStatus ==
                      Constants.mediaUploaded ||
                  chatList.isMessageSentByMe)) {
            Get.toNamed(Routes.videoPlay, arguments: {
              "filePath": chatList.mediaChatMessage!.mediaLocalStoragePath,
            });
          }
        }
        if (chatList.messageType == 'AUDIO') {
          if (controller.checkFile(
              chatList.mediaChatMessage!.mediaLocalStoragePath) &&
              (chatList.mediaChatMessage!.mediaDownloadStatus ==
                  Constants.mediaDownloaded ||
                  chatList.mediaChatMessage!.mediaDownloadStatus ==
                      Constants.mediaUploaded ||
                  chatList.isMessageSentByMe)) {
            // debugPrint("audio click1");
            chatList.mediaChatMessage!.isPlaying = controller.isPlaying.value;
            // controller.playAudio(chatList.mediaChatMessage!);
            playAudio(chatList.mediaChatMessage!.mediaLocalStoragePath,
                chatList.mediaChatMessage!.mediaFileName);
          } else {
            debugPrint("condition failed");
          }
        }
        break;

      case Constants.mediaDownloadedNotAvailable:
      case Constants.mediaNotDownloaded:
      //download
        debugPrint("Download");
        debugPrint(chatList.messageId);
        chatList.mediaChatMessage!.mediaDownloadStatus =
            Constants.mediaDownloading;
        controller.downloadMedia(chatList.messageId);
        break;
      case Constants.mediaUploadedNotAvailable:
      //upload
        break;
      case Constants.mediaNotUploaded:
      case Constants.mediaDownloading:
      case Constants.mediaUploading:
        return InkWell(
          onTap: (){
            cancelMediaUploadOrDownload(chatList.messageId);
          },
          child: uploadingView(chatList.messageType),
        );
        // return uploadingView();
    // break;
    }
  }
  playAudio(String filePath, String mediaFileName) {
    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            // mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  controller.playAudio(filePath);
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset(
                      audioMicBg,
                      width: 50,
                      height: 50,
                      fit: BoxFit.contain,
                    ),
                    Obx(() {
                      return controller.isPlaying.value
                          ? const Icon(Icons.pause)
                          : const Icon(Icons.play_arrow);
                    }),
                  ],
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      mediaFileName,
                      maxLines: 2,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      // width: 168,
                      child: SliderTheme(
                        data: SliderThemeData(
                          thumbColor: audioColorDark,
                          overlayShape: SliderComponentShape.noOverlay,
                          thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 5),
                        ),
                        child: Obx(() {
                          return Slider(
                            value:
                            double.parse(controller.currentPos.toString()),
                            min: 0,
                            activeColor: audioColorDark,
                            inactiveColor: audioColor,
                            max: double.parse(
                                controller.maxDuration.value.toString()),
                            divisions: controller.maxDuration.value,
                            label: controller.currentPostLabel,
                            onChanged: (double value) async {

                            },
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  getImage(String mediaLocalStoragePath, String mediaThumbImage,
      BuildContext context, String mediaFileName) {
    if (controller.checkFile(mediaLocalStoragePath)) {
      return InkWell(
          onTap: () {
            Get.toNamed(Routes.imageView, arguments: {
              'imageName': mediaFileName,
              'imagePath': mediaLocalStoragePath
            });
          },
          child: Image.file(
            File(mediaLocalStoragePath),
            width: MediaQuery.of(context).size.width * 0.60,
            height: MediaQuery.of(context).size.height * 0.4,
            fit: BoxFit.cover,
          ));
    } else {
      return controller.imageFromBase64String(
          mediaThumbImage, context, null, null);
    }
  }

  getImageHolder(String mediaFileName) {
    String result = mediaFileName.split('.').last;
    debugPrint("File Type ==> $result");
    switch (result) {
      case Constants.pdf:
        return SvgPicture.asset(
          pdfImage,
          width: 30,
          height: 30,
        );
      case Constants.ppt:
        return SvgPicture.asset(
          pptImage,
          width: 30,
          height: 30,
        );
      case Constants.xls:
        return SvgPicture.asset(
          xlsImage,
          width: 30,
          height: 30,
        );
      case Constants.xlsx:
        return SvgPicture.asset(
          xlsxImage,
          width: 30,
          height: 30,
        );
      case Constants.doc:
      case Constants.docx:
        return SvgPicture.asset(
          docImage,
          width: 30,
          height: 30,
        );
      case Constants.apk:
        return SvgPicture.asset(
          apkImage,
          width: 30,
          height: 30,
        );
      default:
        return SvgPicture.asset(
          docImage,
          width: 30,
          height: 30,
        );
    }
  }
}
