import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/constants.dart';
import '../../../routes/app_pages.dart';
import 'package:flysdk/flysdk.dart';

import '../controllers/chat_controller.dart';

class ChatSearchView extends GetView<ChatController> {
  const ChatSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    controller.screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    return WillPopScope(
      onWillPop: (){
        controller.searchInit();
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: TextField(
            onChanged: (text) => controller.setSearch(text),
            controller: controller.searchedText,
            autofocus: true,
            decoration: const InputDecoration(
                hintText: "Search", border: InputBorder.none),
          ),
          iconTheme: const IconThemeData(color: iconColor),
          actions: [
            IconButton(onPressed: (){
              controller.scrollUp();
            }, icon: const Icon(Icons.keyboard_arrow_up)),
            IconButton(onPressed: (){
              controller.scrollDown();
            }, icon: const Icon(Icons.keyboard_arrow_down)),
          ],
        ),
        body:  Obx(() =>
        controller.chatList.isEmpty
            ? const SizedBox.shrink()
            : chatListView(controller.chatList.toList())),
      ),
    );
  }

  Widget chatListView(List<ChatMessageModel> chatList) {
    return ScrollablePositionedList.builder(
      itemCount: chatList.length,
      initialScrollIndex: chatList.length,
      itemScrollController: controller.searchScrollController,
      itemPositionsListener: controller.itemPositionsListener,
      itemBuilder: (context, index) {
        return Container(
          color: controller.chatList[index].isSelected ? chatReplyContainerColor : Colors.transparent,
          margin: const EdgeInsets.only(
              left: 14, right: 14, top: 5, bottom: 10),
          child: Align(
              alignment: (chatList[index].isMessageSentByMe
                  ? Alignment.bottomRight
                  : Alignment.bottomLeft),
              child: Container(
                constraints: BoxConstraints(maxWidth: controller.screenWidth * 0.6),
                decoration: BoxDecoration(
                    borderRadius: chatList[index].isMessageSentByMe
                        ? const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10))
                        : const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10)),
                    color: (chatList[index].isMessageSentByMe
                        ? chatSentBgColor
                        : Colors.white),
                    border: chatList[index].isMessageSentByMe
                        ? Border.all(color: chatSentBgColor)
                        : Border.all(color: Colors.grey)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    getMessageHeader(chatList[index], context),
                    getMessageContent(index, context, chatList),
                  ],
                ),
              ),
            ),
        );
      },
    );
  }

  getMessageIndicator(String? messageStatus, bool isSender,
      String messageType) {
    // debugPrint("Message Type ==> $messageType");
    if (isSender) {
      if (messageStatus == 'A') {
        return SvgPicture.asset('assets/logos/acknowledged.svg');
      } else if (messageStatus == 'D') {
        return SvgPicture.asset('assets/logos/delivered.svg');
      } else if (messageStatus == 'S') {
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

  getMessageContent(int index, BuildContext context,
      List<ChatMessageModel> chatList) {
    // debugPrint(json.encode(chatList[index]));
    if (chatList[index].messageType == Constants.mText) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisSize: chatList[index].replyParentChatMessage == null
              ? MainAxisSize.min
              : MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: spannableText(
                chatList[index].messageTextContent ?? "",
                controller.searchedText.text,
                const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Row(
              children: [
                chatList[index].isMessageStarred
                    ? const Icon(
                  Icons.star,
                  size: 13,
                )
                    : const SizedBox.shrink(),
                const SizedBox(
                  width: 5,
                ),
                getMessageIndicator(
                    chatList[index].messageStatus.status,
                    chatList[index].isMessageSentByMe,
                    chatList[index].messageType),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  controller.getChatTime(
                      context, chatList[index].messageSentTime),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      );
    } else if (chatList[index].messageType == Constants.mNotification) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: spannableText(chatList[index].messageTextContent ?? "",
              controller.searchedText.text,const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ),
      );
    } else if (chatList[index].messageType == Constants.mImage) {
      var chatMessage = chatList[index].mediaChatMessage!;
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
                top: (controller.screenHeight * 0.4) / 2.5,
                left: (controller.screenWidth * 0.6) / 3,
                child: InkWell(
                    onTap: () {
                      handleMediaUploadDownload(
                          chatMessage.mediaDownloadStatus, chatList[index]);
                    },
                    child: getImageOverlay(chatList, index, context))),
            Positioned(
              bottom: 8,
              right: 10,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  chatList[index].isMessageStarred
                      ? const Icon(
                    Icons.star,
                    size: 13,
                  )
                      : const SizedBox.shrink(),
                  const SizedBox(
                    width: 5,
                  ),
                  getMessageIndicator(
                      chatList[index].messageStatus.status,
                      chatList[index].isMessageSentByMe,
                      chatList[index].messageType),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    controller.getChatTime(
                        context, chatList[index].messageSentTime),
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (chatList[index].messageType == Constants.mVideo) {
      var chatMessage = chatList[index].mediaChatMessage!;
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
                top: (controller.screenHeight * 0.4) / 2.6,
                left: (controller.screenWidth * 0.6) / 2.9,
                child: InkWell(
                    onTap: () {
                      handleMediaUploadDownload(
                          chatMessage.mediaDownloadStatus, chatList[index]);
                    },
                    child: getImageOverlay(chatList, index, context))),
            Positioned(
              bottom: 8,
              right: 10,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  chatList[index].isMessageStarred
                      ? const Icon(
                    Icons.star,
                    size: 13,
                  )
                      : const SizedBox.shrink(),
                  const SizedBox(
                    width: 5,
                  ),
                  getMessageIndicator(
                      chatList[index].messageStatus.status,
                      chatList[index].isMessageSentByMe,
                      chatList[index].messageType),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    controller.getChatTime(
                        context, chatList[index].messageSentTime),
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (chatList[index].messageType == Constants.mDocument) {
      return InkWell(
        onTap: () {
          controller.openDocument(
              chatList[index].mediaChatMessage!.mediaLocalStoragePath, context);
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: chatReplySenderColor,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            color: Colors.white,
          ),
          width: controller.screenWidth * 0.60,
          child: Column(
            children: [
              Padding(
                padding:
                const EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0),
                child: Row(
                  children: [
                    getImageHolder(
                        chatList[index].mediaChatMessage!.mediaFileName),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                        child: spannableText(
                          chatList[index].mediaChatMessage!.mediaFileName,controller.searchedText.text,null
                        )),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        handleMediaUploadDownload(
                            chatList[index]
                                .mediaChatMessage!
                                .mediaDownloadStatus,
                            chatList[index]);
                      },
                      child: getImageOverlay(chatList, index, context),
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
                    chatList[index].isMessageStarred
                        ? const Icon(
                      Icons.star,
                      size: 13,
                    )
                        : const SizedBox.shrink(),
                    const SizedBox(
                      width: 5,
                    ),
                    getMessageIndicator(
                        chatList[index].messageStatus.status,
                        chatList[index].isMessageSentByMe,
                        chatList[index].messageType),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      controller.getChatTime(
                          context, chatList[index].messageSentTime),
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
    } else if (chatList[index].messageType == Constants.mContact) {
      return InkWell(
        onTap: () {
          Get.toNamed(Routes.previewContact, arguments: {
            "contactList":
            chatList[index].contactChatMessage!.contactPhoneNumbers,
            "contactName": chatList[index].contactChatMessage!.contactName,
            "from": "chat"
          });
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: chatReplySenderColor,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            color: Colors.white,
          ),
          width: controller.screenWidth * 0.60,
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
                        child: spannableText(
                          chatList[index].contactChatMessage!.contactName,
                          controller.searchedText.text,null
                          //maxLines: 2,
                        )),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    chatList[index].isMessageStarred
                        ? const Icon(
                      Icons.star,
                      size: 13,
                    )
                        : const SizedBox.shrink(),
                    const SizedBox(
                      width: 5,
                    ),
                    getMessageIndicator(
                        chatList[index].messageStatus.status,
                        chatList[index].isMessageSentByMe,
                        chatList[index].messageType),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      controller.getChatTime(
                          context, chatList[index].messageSentTime),
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
    } else if (chatList[index].messageType == Constants.mAudio) {
      var chatMessage = chatList[index];
      return Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: chatReplySenderColor,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          color: Colors.white,
        ),
        width: controller.screenWidth * 0.60,
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
                            chatList[index]);
                      },
                      child: getImageOverlay(chatList, index, context),
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
                  chatList[index].isMessageStarred
                      ? const Icon(
                    Icons.star,
                    size: 13,
                  )
                      : const SizedBox.shrink(),
                  const SizedBox(
                    width: 5,
                  ),
                  getMessageIndicator(
                      chatList[index].messageStatus.status,
                      chatList[index].isMessageSentByMe,
                      chatList[index].messageType),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    controller.getChatTime(
                        context, chatList[index].messageSentTime),
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
    } else if (chatList[index].messageType.toUpperCase() ==
        Constants.mLocation) {
      return Padding(
        padding: const EdgeInsets.all(2.0),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: getLocationImage(
                  chatList[index].locationChatMessage, 200, 171),
            ),
            Positioned(
              bottom: 8,
              right: 10,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  chatList[index].isMessageStarred
                      ? const Icon(
                    Icons.star,
                    size: 13,
                  )
                      : const SizedBox.shrink(),
                  const SizedBox(
                    width: 5,
                  ),
                  getMessageIndicator(
                      chatList[index].messageStatus.status,
                      chatList[index].isMessageSentByMe,
                      chatList[index].messageType),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    controller.getChatTime(
                        context, chatList[index].messageSentTime),
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
                      chatList[index].messageStatus.status,
                      chatList[index].isMessageSentByMe,
                      chatList[index].messageType),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    controller.getChatTime(
                        context, chatList[index].messageSentTime),
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

  Widget getLocationImage(LocationChatMessage? locationChatMessage,
      double width, double height) {
    return InkWell(
        onTap: () async {
          //Redirect to Google maps App
          String googleUrl =
              'https://www.google.com/maps/search/?api=1&query=${locationChatMessage
              .latitude}, ${locationChatMessage.longitude}';
          if (await canLaunchUrl(Uri.parse(googleUrl))) {
            await launchUrl(Uri.parse(googleUrl));
          } else {
            throw 'Could not open the map.';
          }
        },
        child: Image.network(
          Helper.getMapImageUri(
              locationChatMessage!.latitude, locationChatMessage.longitude),
          fit: BoxFit.fill,
          width: width,
          height: height,
        ));
  }

  Widget iconCreation(String iconPath, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          SvgPicture.asset(iconPath),
          const SizedBox(
            height: 5,
          ),
          Text(
            text,
            style: const TextStyle(fontSize: 12, color: Colors.white),
          )
        ],
      ),
    );
  }

  getImageOverlay(List<ChatMessageModel> chatList, int index,
      BuildContext context) {
    var chatMessage = chatList[index];

    if (controller
        .checkFile(chatMessage.mediaChatMessage!.mediaLocalStoragePath) &&
        chatMessage.messageStatus.status != 'N') {
      if (chatMessage.messageType == 'VIDEO') {
        return SizedBox(
          width: 80,
          height: 50,
          child: Center(
              child: SvgPicture.asset(
                videoPlay,
                fit: BoxFit.contain,
              )),
        );
      } else if (chatMessage.messageType == 'AUDIO') {
        debugPrint("===============================");
        debugPrint(chatMessage.mediaChatMessage!.isPlaying.toString());
        return chatMessage.mediaChatMessage!.isPlaying
            ? const Icon(Icons.pause)
            : const Icon(Icons.play_arrow_sharp);
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
              chatMessage.messageType);
        case Constants.mediaUploadedNotAvailable:
          return getFileInfo(
              chatMessage.mediaChatMessage!.mediaDownloadStatus,
              chatMessage.mediaChatMessage!.mediaFileSize,
              Icons.upload_sharp,
              chatMessage.messageType);

        case Constants.mediaNotUploaded:
        case Constants.mediaDownloading:
        case Constants.mediaUploading:
          if (chatMessage.messageType == 'AUDIO' ||
              chatMessage.messageType == 'DOCUMENT') {
            return InkWell(
                onTap: () {
                  debugPrint(chatMessage.messageId);
                },
                child: SizedBox(width: 30, height: 30, child: uploadingView()));
          } else {
            return SizedBox(
              height: 40,
              width: 80,
              child: uploadingView(),
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
            width: controller.screenWidth * 0.60,
            height: controller.screenHeight * 0.4,
            fit: BoxFit.cover,
          ));
    } else {
      return controller.imageFromBase64String(
          mediaThumbImage, context, null, null);
    }
  }

  uploadingView() {
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

  handleMediaUploadDownload(int mediaDownloadStatus,
      ChatMessageModel chatList) {
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
        return uploadingView();
    // break;
    }
  }

  getAudioFeedButton(ChatMessageModel chatMessage) {}

  getImageHolder(String mediaFileName) {
    String result = mediaFileName
        .split('.')
        .last;
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
                    spannableText(
                      mediaFileName,controller.searchedText.text,null
                      //maxLines: 2,
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

  Widget replyMessageHeader(BuildContext context) {
    return Obx(() {
      if (controller.isReplying.value) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: chatSentBgColor,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: chatReplyContainerColor,
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 15.0, left: 15.0),
                        child: getReplyTitle(
                            controller.replyChatMessage.isMessageSentByMe,
                            controller.replyChatMessage.senderNickName),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding:
                        const EdgeInsets.only(bottom: 15.0, left: 15.0),
                        child: getReplyMessage(
                            controller.replyChatMessage.messageType,
                            controller.replyChatMessage.messageTextContent,
                            controller.replyChatMessage.contactChatMessage
                                ?.contactName,
                            controller.replyChatMessage.mediaChatMessage
                                ?.mediaFileName),
                      ),
                    ],
                  ),
                ),
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    getReplyImageHolder(
                        context,
                        controller.replyChatMessage.messageType,
                        controller
                            .replyChatMessage.mediaChatMessage?.mediaThumbImage,
                        controller.replyChatMessage.locationChatMessage,
                        70),
                    GestureDetector(
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 10,
                            child: Icon(Icons.close,
                                size: 15, color: Colors.black)),
                      ),
                      onTap: () => controller.cancelReplyMessage(),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    });
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
      case Constants.mText:
        return Row(
          children: [
            Helper.forMessageTypeIcon(Constants.mText),
            //Text(messageTextContent!),
            spannableText(
                messageType.toString(),
                controller.searchedText.text,null)
          ],
        );
      case Constants.mImage:
        return Row(
          children: [
            Helper.forMessageTypeIcon(Constants.mImage),
            const SizedBox(
              width: 10,
            ),
            Text(Helper.capitalize(Constants.mImage)),
          ],
        );
      case Constants.mVideo:
        return Row(
          children: [
            Helper.forMessageTypeIcon(Constants.mVideo),
            const SizedBox(
              width: 10,
            ),
            Text(Helper.capitalize(Constants.mVideo)),
          ],
        );
      case Constants.mAudio:
        return Row(
          children: [
            Helper.forMessageTypeIcon(Constants.mAudio),
            const SizedBox(
              width: 10,
            ),
            // Text(controller.replyChatMessage.mediaChatMessage!.mediaDuration),
            // SizedBox(
            //   width: 10,
            // ),
            Text(Helper.capitalize(Constants.mAudio)),
          ],
        );
      case Constants.mContact:
        return Row(
          children: [
            Helper.forMessageTypeIcon(Constants.mContact),
            const SizedBox(
              width: 10,
            ),
            Text("${Helper.capitalize(Constants.mContact)} :"),
            const SizedBox(
              width: 5,
            ),
            SizedBox(
                width: 120,
                child: spannableText(
                  contactName!,
                  controller.searchedText.text,null
                  //maxLines: 1,
                  //softWrap: false,
                  //overflow: TextOverflow.ellipsis,
                )),
          ],
        );
      case Constants.mLocation:
        return Row(
          children: [
            Helper.forMessageTypeIcon(Constants.mLocation),
            const SizedBox(
              width: 10,
            ),
            Text(Helper.capitalize(Constants.mLocation)),
          ],
        );
      case Constants.mDocument:
        return Row(
          children: [
            Helper.forMessageTypeIcon(Constants.mDocument),
            const SizedBox(
              width: 10,
            ),
            spannableText(mediaFileName!,controller.searchedText.text,null),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  getReplyImageHolder(BuildContext context,
      String messageType,
      String? mediaThumbImage,
      LocationChatMessage? locationChatMessage,
      double size) {
    switch (messageType) {
      case Constants.mImage:
        return ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: controller.imageFromBase64String(
              mediaThumbImage!, context, size, size),
        );
      case Constants.mLocation:
        return getLocationImage(locationChatMessage, size, size);
      case Constants.mVideo:
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

  getMessageHeader(ChatMessageModel chatList, BuildContext context) {
    if (chatList.replyParentChatMessage == null) {
      return const SizedBox.shrink();
    } else {
      return Container(
        padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          color: chatList.isMessageSentByMe
              ? chatReplyContainerColor
              : chatReplySenderColor,
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

  Widget spannableText(String text, String spannableText,TextStyle? style) {
    var startIndex = text.toLowerCase().startsWith(spannableText.toLowerCase()) ? text.toLowerCase().indexOf(spannableText.toLowerCase()) : -1;
    var endIndex = startIndex + spannableText.length;
    if (startIndex != -1 && endIndex != -1) {
      var startText = text.substring(0, startIndex);
      var colorText = text.substring(startIndex, endIndex);
      var endText = text.substring(endIndex, text.length);
      return Text.rich(TextSpan(
          text: startText,
          children: [
            TextSpan(text: colorText, style: const TextStyle(color: Colors.orange)),
            TextSpan(
                text: endText,
                style: style)
          ],
          style: style),maxLines: 1,overflow: TextOverflow.ellipsis,);
    } else {
      return Text(
          text,
          style: style, maxLines: 1,overflow: TextOverflow.ellipsis
      );
    }
  }
}
