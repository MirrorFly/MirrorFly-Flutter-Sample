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

import '../chat_widgets.dart';
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
                hintText: "Search...", border: InputBorder.none),
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
        if (chatList[index].messageType.toUpperCase() != Constants.mNotification) {
          return Container(
            color: controller.chatList[index].isSelected
                ? chatReplyContainerColor
                : Colors.transparent,
            margin: const EdgeInsets.only(
                left: 14, right: 14, top: 5, bottom: 10),
            child: Align(
              alignment: (chatList[index].isMessageSentByMe
                  ? Alignment.bottomRight
                  : Alignment.bottomLeft),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Visibility(
                    visible: controller
                        .forwardMessageVisibility(chatList[index]),
                    child: IconButton(
                        onPressed: () {
                          controller.forwardSingleMessage(
                              chatList[index].messageId);
                        },
                        icon: SvgPicture.asset(forwardMedia)),
                  ),
                  Container(
                    constraints: BoxConstraints(
                        maxWidth: controller.screenWidth * 0.75),
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
                            : Border.all(color: chatBorderColor)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        (chatList[index].replyParentChatMessage == null)
                            ? const SizedBox.shrink()
                            : ReplyMessageHeader(
                            chatMessage: chatList[index]),
                        SenderHeader(
                            isGroupProfile: controller.profile.isGroupProfile,
                            chatList: chatList,
                            index: index),
                        getMessageContent(index, context, chatList),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }else{
          return NotificationMessageView(chatMessage: chatList[index]);
        }
      },
    );
  }

  getMessageContent(int index, BuildContext context,
      List<ChatMessageModel> chatList) {
    var chatMessage = chatList[index];
    if (chatList[index].isMessageRecalled) {
      return RecalledMessageView(
        chatMessage: chatMessage,
      );
    } else {
      if (chatList[index].messageType.toUpperCase() == Constants.mText) {
        return TextMessageView(chatMessage: chatMessage,
          search: controller.searchedText.text,);
      } else if (chatList[index].messageType.toUpperCase() == Constants.mNotification) {
        return NotificationMessageView(chatMessage: chatMessage);
      } else if (chatList[index].messageType.toUpperCase() ==
          Constants.mLocation) {
        if (chatList[index].locationChatMessage == null) {
          return const SizedBox.shrink();
        }
        return LocationMessageView(chatMessage: chatMessage);
      } else if (chatList[index].messageType.toUpperCase() == Constants.mContact) {
        if (chatList[index].contactChatMessage == null) {
          return const SizedBox.shrink();
        }
        return ContactMessageView(chatMessage: chatMessage);
      } else {
        if (chatList[index].mediaChatMessage == null) {
          return const SizedBox.shrink();
        } else {
          if (chatList[index].messageType.toUpperCase() == Constants.mImage) {
            return ImageMessageView(
                chatMessage: chatMessage,
                search: controller.searchedText.text,
                onTap: () {
                  handleMediaUploadDownload(
                      chatMessage.mediaChatMessage!.mediaDownloadStatus,
                      chatList[index]);
                });
          } else if (chatList[index].messageType.toUpperCase() == Constants.mVideo) {
            return VideoMessageView(
                chatMessage: chatMessage,
                search: controller.searchedText.text,
                onTap: () {
                  handleMediaUploadDownload(
                      chatMessage.mediaChatMessage!.mediaDownloadStatus,
                      chatList[index]);
                });
          } else if (chatList[index].messageType.toUpperCase() == Constants.mDocument || chatList[index].messageType.toUpperCase() == Constants.mFile) {
            return DocumentMessageView(
                chatMessage: chatMessage,
                onTap: () {
                  handleMediaUploadDownload(
                      chatMessage.mediaChatMessage!.mediaDownloadStatus,
                      chatList[index]);
                });
          } else if (chatList[index].messageType.toUpperCase() == Constants.mAudio) {
            return AudioMessageView(
                chatMessage: chatMessage,
                onTap: () {
                  handleMediaUploadDownload(
                      chatMessage.mediaChatMessage!.mediaDownloadStatus,
                      chatList[index]);
                },
                currentPos: controller.currentPos.value,
                maxDuration: controller.maxDuration.value);
          }
        }
      }
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
        chatList[index].messageStatus != 'N') {
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
                    chatSpannedText(
                      mediaFileName,controller.searchedText.text,
                      const TextStyle(fontSize: 14,color: textHintColor),
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
}
