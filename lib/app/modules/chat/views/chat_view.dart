import 'dart:convert';
import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mirror_fly_demo/app/common/widgets.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/model/chatMessageModel.dart';

// import 'package:image_picker/image_picker.dart';
import 'package:mirror_fly_demo/app/routes/app_pages.dart';
import 'package:mirror_fly_demo/app/widgets/record_button.dart';

import '../../../common/constants.dart';
import '../../../data/helper.dart';
import '../controllers/chat_controller.dart';

class ChatView extends GetView<ChatController> {
  ChatView({Key? key}) : super(key: key);

  final ImagePicker _picker = ImagePicker();

  dynamic _pickImageError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leadingWidth: 25,
          title: Row(
            children: [
              ImageNetwork(
                url: controller.profile.image.checkNull(),
                width: 48,
                height: 48,
                clipoval: true,
                errorWidget: ProfileTextImage(
                  text: controller.profile.name.checkNull().isEmpty ? controller.profile.mobileNumber.checkNull() : controller.profile.name.checkNull(),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Text(controller.profile.name.toString()),
            ],
          ),
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/logos/chat_bg.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: WillPopScope(
            onWillPop: () {
              if (controller.showEmoji.value) {
                controller.showEmoji(false);
              } else {
                Get.back();
              }
              return Future.value(false);
            },
            child: Column(
              children: [
                Expanded(
                  child: Obx(() => controller.chatList.isEmpty
                      ? const SizedBox.shrink()
                      : chatListView(controller.chatList.reversed.toList())),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(left: 10),
                              margin: const EdgeInsets.all(10),
                              height: 50,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: textcolor,
                                ),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(40)),
                                color: Colors.white,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  InkWell(
                                      onTap: () {
                                        if (!controller.showEmoji.value) {
                                          FocusScope.of(context).unfocus();
                                          controller.focusNode.canRequestFocus =
                                              false;
                                        }
                                        Future.delayed(
                                            const Duration(milliseconds: 500),
                                            () {
                                          controller.showEmoji(
                                              !controller.showEmoji.value);
                                        });
                                      },
                                      child: SvgPicture.asset(
                                          'assets/logos/smile.svg')),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: TextField(
                                      onTap: () {
                                        controller.focusNode.requestFocus();
                                      },
                                      controller: controller.messageController,
                                      focusNode: controller.focusNode,
                                      decoration: const InputDecoration(
                                          hintText: "Start Typing...",
                                          border: InputBorder.none),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  InkWell(
                                      onTap: () {
                                        showModalBottomSheet(
                                            backgroundColor: Colors.transparent,
                                            context: context,
                                            builder: (builder) =>
                                                bottomSheet(context));
                                      },
                                      child: SvgPicture.asset(
                                          'assets/logos/attach.svg')),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  SvgPicture.asset('assets/logos/mic.svg'),
                                  // RecordButton(controller: controller.controller,),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          InkWell(
                              onTap: () {
                                // if (scrollController.hasClients) {
                                // scrollController.animateTo(
                                //   scrollController.position.maxScrollExtent,
                                //   curve: Curves.easeOut,
                                //   duration: const Duration(milliseconds: 300),
                                // );
                                // }
                                controller.sendMessage(controller.profile);
                              },
                              child: SvgPicture.asset('assets/logos/send.svg')),
                          const SizedBox(
                            width: 15,
                          ),
                        ],
                      ),
                      emojiLayout(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget emojiLayout() {
    return Obx(() {
      if (controller.showEmoji.value) {
        return SizedBox(
          height: 250,
          child: EmojiPicker(
            onBackspacePressed: () {
              // Do something when the user taps the backspace button (optional)
            },
            textEditingController: controller.messageController,
            config: Config(
              columns: 7,
              emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
              verticalSpacing: 0,
              horizontalSpacing: 0,
              gridPadding: EdgeInsets.zero,
              initCategory: Category.RECENT,
              bgColor: const Color(0xFFF2F2F2),
              indicatorColor: Colors.blue,
              iconColor: Colors.grey,
              iconColorSelected: Colors.blue,
              backspaceColor: Colors.blue,
              skinToneDialogBgColor: Colors.white,
              skinToneIndicatorColor: Colors.grey,
              enableSkinTones: true,
              showRecentsTab: true,
              recentsLimit: 28,
              tabIndicatorAnimDuration: kTabScrollDuration,
              categoryIcons: const CategoryIcons(),
              buttonMode: ButtonMode.CUPERTINO,
            ),
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  Widget chatListView(List<ChatMessageModel> chatList) {
    return ListView.builder(
      itemCount: chatList.length,
      shrinkWrap: true,
      reverse: true,
      controller: controller.scrollController,
      itemBuilder: (context, index) {
        // int reversedIndex = chatList.length - 1 - index;
        return Container(
          padding:
              const EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
          child: Align(
            alignment: (chatList[index].isMessageSentByMe
                ? Alignment.bottomRight
                : Alignment.bottomLeft),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: (chatList[index].isMessageSentByMe
                    ? chatsentbgcolor
                    : Colors.white),
              ),
              child: getMessageContent(index, context, chatList),
            ),
          ),
        );
      },
    );
  }

  getMessageIndicator(
      String? messageStatus, bool isSender, String messageType) {
    debugPrint("Message Type ==> $messageType");
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

  getMessageContent(
      int index, BuildContext context, List<ChatMessageModel> chatList) {
    debugPrint(json.encode(chatList[index]));
    if (chatList[index].messageType == 'TEXT') {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              chatList[index].messageTextContent,
              style: const TextStyle(fontSize: 17),
            ),
            const SizedBox(
              width: 10,
            ),
            Row(
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
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      );
    } else if (chatList[index].messageType == 'NOTIFICATION') {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(chatList[index].messageTextContent,
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ),
      );
    } else if (chatList[index].messageType == 'IMAGE') {
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
                top: (MediaQuery.of(context).size.height * 0.4) / 2.5,
                left: (MediaQuery.of(context).size.width * 0.6) / 3,
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
    } else if (chatList[index].messageType == 'VIDEO') {
      var chatMessage = chatList[index].mediaChatMessage!;
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            InkWell(
              onTap: () {
                // debugPrint(controller.checkFile(chatMessage.mediaLocalStoragePath));
                // debugPrint(chatMessage.mediaDownloadStatus == Constants.MEDIA_DOWNLOADED);
                // debugPrint(chatMessage.mediaDownloadStatus == Constants.MEDIA_UPLOADED);
                if (controller.checkFile(chatMessage.mediaLocalStoragePath) &&
                    (chatMessage.mediaDownloadStatus ==
                            Constants.MEDIA_DOWNLOADED ||
                        chatMessage.mediaDownloadStatus ==
                            Constants.MEDIA_UPLOADED)) {
                  Get.toNamed(Routes.VIDEO_PLAY, arguments: {
                    "filePath": chatMessage.mediaLocalStoragePath,
                  });
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: controller.imageFromBase64String(
                    chatMessage.mediaThumbImage, context),
              ),
            ),
            Positioned(
                top: (MediaQuery.of(context).size.height * 0.4) / 2.6,
                left: (MediaQuery.of(context).size.width * 0.6) / 2.5,
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
    } else if (chatList[index].messageType == 'DOCUMENT') {
    } else if (chatList[index].messageType == 'AUDIO') {
      return Padding(
        padding: EdgeInsets.all(8.0),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.60,
          height: 60,
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SvgPicture.asset(audio_mic,
                  //   fit: BoxFit.contain,),

                  SizedBox(width: 5,),
                  Text("data"),
                ],
              ),
              Align(
                alignment: Alignment.bottomRight,
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
              ),
            ],
          ),
        ),
      );
    } else if (chatList[index].messageType == 'LOCATION') {}
  }

  Widget bottomSheet(BuildContext context) {
    return SizedBox(
      height: 270,
      width: MediaQuery.of(context).size.width,
      child: Card(
        margin: const EdgeInsets.all(18.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconCreation(documentImg, "Document", () {}),
                  const SizedBox(
                    width: 50,
                  ),
                  iconCreation(cameraImg, "Camera", () async {
                    Get.back();
                    final XFile? photo =
                        await _picker.pickImage(source: ImageSource.camera);
                    Get.toNamed(Routes.IMAGEPREVIEW, arguments: {
                      "filePath": photo?.path,
                      "userName": controller.profile.name!
                    });

                    // controller.sendImageMessage(photo?.path, "", "");
                  }),
                  const SizedBox(
                    width: 50,
                  ),
                  iconCreation(galleryImg, "Gallery", () async {
                    try {
                      Get.back();
                      // final XFile? pickedFile =
                      //     await _picker.pickImage(source: ImageSource.gallery);
                      // controller.sendImageMessage(pickedFile?.path, "", "");
                      controller.imagePicker();
                      // Get.toNamed(Routes.IMAGEPREVIEW, arguments: {
                      //   "filePath": pickedFile?.path,
                      //   "userName": controller.profile.name!
                      // });
                    } catch (e) {
                      _pickImageError = e;
                    }
                  }),
                ],
              ),
              const SizedBox(
                height: 35,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconCreation(documentImg, "Audio", () {}),
                  const SizedBox(
                    width: 50,
                  ),
                  iconCreation(contactImg, "Contact", () {}),
                  const SizedBox(
                    width: 50,
                  ),
                  iconCreation(locationImg, "Location", () {}),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget iconCreation(String iconPath, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          text == "Audio"
              ? CircleAvatar(radius: 25, child: Icon(Icons.headphones))
              : SvgPicture.asset(iconPath),
          const SizedBox(
            height: 5,
          ),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
            ),
          )
        ],
      ),
    );
  }

  getImageOverlay(
      List<ChatMessageModel> chatList, int index, BuildContext context) {
    var chatMessage = chatList[index];

    if (controller
            .checkFile(chatMessage.mediaChatMessage!.mediaLocalStoragePath) &&
        chatMessage.messageStatus.status != 'N') {
      return chatMessage.messageType == 'VIDEO'
          ? SvgPicture.asset(
              video_play,
              width: 50,
              height: 50,
              fit: BoxFit.contain,
            )
          : SizedBox.shrink();
    } else {
      switch (chatMessage.mediaChatMessage!.mediaDownloadStatus) {
        case Constants.MEDIA_DOWNLOADED:
        case Constants.MEDIA_UPLOADED:
          return SizedBox.shrink();

        case Constants.MEDIA_DOWNLOADED_NOT_AVAILABLE:
        case Constants.MEDIA_NOT_DOWNLOADED:
          return getFileInfo(
              chatMessage.mediaChatMessage!.mediaDownloadStatus,
              chatMessage.mediaChatMessage!.mediaFileSize,
              Icons.download_sharp);
        case Constants.MEDIA_UPLOADED_NOT_AVAILABLE:
          return getFileInfo(chatMessage.mediaChatMessage!.mediaDownloadStatus,
              chatMessage.mediaChatMessage!.mediaFileSize, Icons.upload_sharp);

        case Constants.MEDIA_NOT_UPLOADED:
        case Constants.MEDIA_DOWNLOADING:
        case Constants.MEDIA_UPLOADING:
          return uploadingView();
      }
    }
  }

  getFileInfo(int mediaDownloadStatus, int mediaFileSize, IconData iconData) {
    return Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: textcolor,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          color: Colors.black38,
        ),
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Row(
          children: [
            Icon(
              iconData,
              color: Colors.white,
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              Helper.formatBytes(mediaFileSize, 0),
              style: TextStyle(color: Colors.white),
            ),
          ],
        ));
  }

  getImage(String mediaLocalStoragePath, String mediaThumbImage,
      BuildContext context, String mediaFileName) {
    if (controller.checkFile(mediaLocalStoragePath)) {
      return InkWell(
          onTap: () {
            Get.toNamed(Routes.IMAGE_VIEW, arguments: {
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
      return controller.imageFromBase64String(mediaThumbImage, context);
    }
  }

  uploadingView() {
    return Container(
        height: 40,
        width: 80,
        decoration: BoxDecoration(
          border: Border.all(
            color: textcolor,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          color: Colors.black38,
        ),
        // padding: EdgeInsets.symmetric(vertical: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 10,
            ),
            SvgPicture.asset(
              downloading,
              fit: BoxFit.contain,
            ),
            SizedBox(
              height: 11,
            ),
            Expanded(
              child: LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.grey,
                ),
                backgroundColor: Colors.white,
                // minHeight: 1,
              ),
            ),
          ],
        ));
  }

  handleMediaUploadDownload(
      int mediaDownloadStatus, ChatMessageModel chatList) {
    switch (mediaDownloadStatus) {
      case Constants.MEDIA_DOWNLOADED:
      case Constants.MEDIA_UPLOADED:
        // return SizedBox.shrink();
        if (chatList.messageType == 'VIDEO') {
          if (controller.checkFile(
                  chatList.mediaChatMessage!.mediaLocalStoragePath) &&
              (chatList.mediaChatMessage!.mediaDownloadStatus ==
                      Constants.MEDIA_DOWNLOADED ||
                  chatList.mediaChatMessage!.mediaDownloadStatus ==
                      Constants.MEDIA_UPLOADED)) {
            Get.toNamed(Routes.VIDEO_PLAY, arguments: {
              "filePath": chatList.mediaChatMessage!.mediaLocalStoragePath,
            });
          }
        }
        break;

      case Constants.MEDIA_DOWNLOADED_NOT_AVAILABLE:
      case Constants.MEDIA_NOT_DOWNLOADED:
        //download
        debugPrint("Download");
        debugPrint(chatList.messageId);
        chatList.mediaChatMessage!.mediaDownloadStatus =
            Constants.MEDIA_DOWNLOADING;
        controller.downloadMedia(chatList.messageId);
        break;
      case Constants.MEDIA_UPLOADED_NOT_AVAILABLE:
        //upload
        break;
      case Constants.MEDIA_NOT_UPLOADED:
      case Constants.MEDIA_DOWNLOADING:
      case Constants.MEDIA_UPLOADING:
        // return uploadingView();
        break;
    }
  }
}
