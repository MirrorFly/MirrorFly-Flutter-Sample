import 'dart:convert';
import 'dart:io';

import 'package:contacts_service/contacts_service.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:mirror_fly_demo/app/common/widgets.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/data/permissions.dart';
import 'package:mirror_fly_demo/app/model/chatMessageModel.dart';
import 'package:mirror_fly_demo/app/modules/chat/views/locationsent_view.dart';

// import 'package:image_picker/image_picker.dart';
import 'package:mirror_fly_demo/app/routes/app_pages.dart';
import 'package:mirror_fly_demo/app/widgets/record_button.dart';
import 'package:swipe_to/swipe_to.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/constants.dart';
import '../../../data/helper.dart';
import '../../../widgets/custom_action_bar_icons.dart';
import '../controllers/chat_controller.dart';
import 'dart:math' as math;

class ChatView extends GetView<ChatController> {
  ChatView({Key? key}) : super(key: key);

  final ImagePicker _picker = ImagePicker();

  dynamic _pickImageError;

  var screenWidth, screenHeight;

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return KeyboardDismisser(
      // onTap: (){
      //   FocusManager.instance.primaryFocus?.unfocus();
      // },
      child: Scaffold(
          appBar: getAppBar(context),
          body: SafeArea(
            child: Container(
              width: screenWidth,
              height: screenHeight,
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
                  } else if (MediaQuery.of(context).viewInsets.bottom > 0) {
                    FocusManager.instance.primaryFocus?.unfocus();
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
                          : chatListView(
                              controller.chatList.reversed.toList())),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Obx(() {
                        return Container(
                          color: Colors.white,
                          child: controller.isBlocked.value
                              ? Column(
                                  children: [
                                    const Divider(
                                      height: 1,
                                      thickness: 0.29,
                                      color: textblackcolor,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 15.0, bottom: 15.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "You have blocked ${controller.profile.name}.",
                                            style:
                                                const TextStyle(fontSize: 15),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          InkWell(
                                            child: const Text(
                                              'UNBLOCK',
                                              style: TextStyle(
                                                  decoration:
                                                      TextDecoration.underline,
                                                  color: Colors.blue),
                                            ),
                                            onTap: () =>
                                                controller.unBlockUser(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    replyMessageHeader(context),
                                    const Divider(
                                      height: 1,
                                      thickness: 0.29,
                                      color: textblackcolor,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Container(
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                            margin: const EdgeInsets.only(
                                                left: 10,
                                                right: 10,
                                                bottom: 10),
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: textcolor,
                                              ),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(40)),
                                              color: Colors.white,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: <Widget>[
                                                InkWell(
                                                    onTap: () {
                                                      if (!controller
                                                          .showEmoji.value) {
                                                        FocusScope.of(context)
                                                            .unfocus();
                                                        controller.focusNode
                                                                .canRequestFocus =
                                                            false;
                                                      }
                                                      Future.delayed(
                                                          const Duration(
                                                              milliseconds:
                                                                  500), () {
                                                        controller.showEmoji(
                                                            !controller
                                                                .showEmoji
                                                                .value);
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
                                                      controller.focusNode
                                                          .requestFocus();
                                                    },
                                                    onChanged: (text) {
                                                      controller.isTyping(text);
                                                    },
                                                    keyboardType:
                                                        TextInputType.multiline,
                                                    minLines: 1,
                                                    maxLines: 4,
                                                    controller: controller
                                                        .messageController,
                                                    focusNode:
                                                        controller.focusNode,
                                                    decoration:
                                                        const InputDecoration(
                                                            hintText:
                                                                "Start Typing...",
                                                            border: InputBorder
                                                                .none),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 15,
                                                ),
                                                IconButton(
                                                  color: Colors.blue,
                                                  onPressed: () async {
                                                    if (await controller
                                                        .askStoragePermission()) {
                                                      showModalBottomSheet(
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          context: context,
                                                          builder: (builder) =>
                                                              bottomSheet(
                                                                  context));
                                                    }
                                                  },
                                                  icon: SvgPicture.asset(
                                                      'assets/logos/attach.svg'),
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                // SvgPicture.asset('assets/logos/mic.svg'),
                                                // RecordButton(controller: controller.controller,),
                                                // const SizedBox(
                                                //   width: 20,
                                                // ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        // InkWell(
                                        //     onTap: () {
                                        //       // if (scrollController.hasClients) {
                                        //       // scrollController.animateTo(
                                        //       //   scrollController.position.maxScrollExtent,
                                        //       //   curve: Curves.easeOut,
                                        //       //   duration: const Duration(milliseconds: 300),
                                        //       // );
                                        //       // }
                                        //       controller.sendMessage(controller.profile);
                                        //     },
                                        //     child: SvgPicture.asset('assets/logos/send.svg')),

                                        Obx(() {
                                          return controller.isUserTyping.value
                                              ? InkWell(
                                                  onTap: () {
                                                    controller.sendMessage(
                                                        controller.profile);
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0,
                                                            right: 8.0,
                                                            bottom: 8),
                                                    child: SvgPicture.asset(
                                                        'assets/logos/send.svg'),
                                                  ))
                                              : Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 8.0),
                                                  child: RecordButton(
                                                    controller:
                                                        controller.controller,
                                                  ),
                                                );
                                        }),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                      ],
                                    ),
                                    emojiLayout(),
                                  ],
                                ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
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
        return SwipeTo(
          key: ValueKey(chatList[index].messageId),
          onRightSwipe: () {
            var swipeList = controller.chatList.reversed.toList();
            controller.handleReplyChatMessage(swipeList[index]);
          },
          animationDuration: const Duration(milliseconds: 300),
          offsetDx: 0.2,
          child: GestureDetector(
            onLongPress: () {
              debugPrint("LongPressed");
              FocusManager.instance.primaryFocus?.unfocus();
              if (!controller.isSelected.value) {
                controller.isSelected(true);
                controller.addChatSelection(chatList[index]);
              }
            },
            onTap: () {
              debugPrint("On Tap");
              controller.isSelected.value
                  ? controller.selectedChatList.contains(chatList[index])
                      ? controller.clearChatSelection(chatList[index])
                      : controller.addChatSelection(chatList[index])
                  : null;
            },
            child: Obx(() {
              return Container(
                key: Key(chatList[index].messageId),
                color: controller.isSelected.value &&
                        chatList[index].isSelected &&
                        controller.selectedChatList.isNotEmpty
                    ? chatreplycontainercolor
                    : Colors.transparent,
                margin: const EdgeInsets.only(
                    left: 14, right: 14, top: 5, bottom: 10),
                child: Align(
                  alignment: (chatList[index].isMessageSentByMe
                      ? Alignment.bottomRight
                      : Alignment.bottomLeft),
                  child: Container(
                    constraints: BoxConstraints(maxWidth: screenWidth * 0.6),
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
                            ? chatsentbgcolor
                            : Colors.white),
                        border: chatList[index].isMessageSentByMe
                            ? Border.all(color: chatsentbgcolor)
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
            }),
          ),
        );
      },
    );
  }

  getMessageIndicator(
      String? messageStatus, bool isSender, String messageType) {
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

  getMessageContent(
      int index, BuildContext context, List<ChatMessageModel> chatList) {
    // debugPrint(json.encode(chatList[index]));
    if (chatList[index].messageType == Constants.MTEXT) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisSize: chatList[index].replyParentChatMessage == null
              ? MainAxisSize.min
              : MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              chatList[index].messageTextContent ?? "",
              style: const TextStyle(fontSize: 17),
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
    } else if (chatList[index].messageType == Constants.MNOTIFICATION) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          // child: Text(chatList[index].messageTextContent!,
          child: Text(chatList[index].messageTextContent ?? "",
              style:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ),
      );
    } else if (chatList[index].messageType == Constants.MIMAGE) {
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
                top: (screenHeight * 0.4) / 2.5,
                left: (screenWidth * 0.6) / 3,
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
    } else if (chatList[index].messageType == Constants.MVIDEO) {
      var chatMessage = chatList[index].mediaChatMessage!;
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            InkWell(
              onTap: () {
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
                    chatMessage.mediaThumbImage, context, null, null),
              ),
            ),
            Positioned(
                top: (screenHeight * 0.4) / 2.6,
                left: (screenWidth * 0.6) / 2.9,
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
    } else if (chatList[index].messageType == Constants.MDOCUMENT) {
      return InkWell(
        onTap: () {
          controller.openDocument(
              chatList[index].mediaChatMessage!.mediaLocalStoragePath, context);
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: chatreplysendercolor,
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
                        chatList[index].mediaChatMessage!.mediaFileName),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                        child: Text(
                      chatList[index].mediaChatMessage!.mediaFileName,
                      maxLines: 2,
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
                        : SizedBox.shrink(),
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
    } else if (chatList[index].messageType == Constants.MCONTACT) {
      return InkWell(
        onTap: () {
          Get.toNamed(Routes.PREVIEW_CONTACT, arguments: {
            "contactList":
                chatList[index].contactChatMessage!.contactPhoneNumbers,
            "contactName": chatList[index].contactChatMessage!.contactName,
            "from": "chat"
          });
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: chatreplysendercolor,
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
                      profile_img,
                      width: 35,
                      height: 35,
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                        child: Text(
                      chatList[index].contactChatMessage!.contactName,
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
    } else if (chatList[index].messageType == Constants.MAUDIO) {
      var chatMessage = chatList[index];
      return Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: chatreplysendercolor,
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
                color: chatreplysendercolor,
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
                          audio_mic_bg,
                          width: 28,
                          height: 28,
                          fit: BoxFit.contain,
                        ),
                        SvgPicture.asset(
                          audio_mic_1,
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
                            thumbColor: audiocolordark,
                            overlayShape: SliderComponentShape.noOverlay,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 5),
                          ),
                          child: Slider(
                            value: double.parse(
                                controller.currentpos.value.toString()),
                            min: 0,
                            activeColor: audiocolordark,
                            inactiveColor: audiocolor,
                            max: double.parse(
                                controller.maxduration.value.toString()),
                            divisions: controller.maxduration.value,
                            // label: controller.currentpostlabel,
                            onChanged: (double value) async {
                              // int seekval = value.round();
                              // int result = await player.seek(Duration(milliseconds: seekval));
                              // if(result == 1){ //seek successful
                              //   currentpos = seekval;
                              // }else{
                              //   print("Seek unsuccessful.");
                              // }
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
        Constants.MLOCATION) {
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

  Widget getLocationImage(
      LocationChatMessage? locationChatMessage, double width, double height) {
    return InkWell(
        onTap: () async {
          //Redirect to Google maps App
          String googleUrl =
              'https://www.google.com/maps/search/?api=1&query=${locationChatMessage.latitude}, ${locationChatMessage.longitude}';
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

  Widget bottomSheet(BuildContext context) {
    return Container(
      height: 270,
      width: screenWidth,
      margin: const EdgeInsets.only(bottom: 40),
      child: Card(
        color: bottomsheetcolor,
        margin: const EdgeInsets.all(18.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconCreation(documentImg, "Document", () {
                    Get.back();
                    controller.documentPickUpload();
                  }),
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
                  iconCreation(audioImg, "Audio", () {
                    Get.back();
                    controller.pickAudio();
                  }),
                  const SizedBox(
                    width: 50,
                  ),
                  iconCreation(contactImg, "Contact", () async {
                    if (await controller.askContactsPermission()) {
                      Get.back();
                      Get.toNamed(Routes.LOCAL_CONTACT);
                      // Contact? c = contacts.elementAt(1);
                      // Item? contactItem = c.phones?.elementAt(0);
                      // debugPrint(contactItem?.value);
                    } else {
                      debugPrint("Permission Denied");
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text('Permission Denied'),
                        action: SnackBarAction(
                            label: 'Ok',
                            onPressed: ScaffoldMessenger.of(context)
                                .hideCurrentSnackBar),
                      ));
                    }
                  }),
                  const SizedBox(
                    width: 50,
                  ),
                  iconCreation(locationImg, "Location", () {
                    Permission().getLocationPermission().then((bool value) {
                      Log("Location permission", value.toString());
                      if (value) {
                        Get.back();
                        Get.toNamed(Routes.LOCATIONSENT)?.then((value) {
                          if (value != null) {
                            value as LatLng;
                            controller.sendLocationMessage(controller.profile,
                                value.latitude, value.longitude);
                          }
                        });
                      }
                    });
                  }),
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

  getImageOverlay(
      List<ChatMessageModel> chatList, int index, BuildContext context) {
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
            video_play,
            fit: BoxFit.contain,
          )),
        );
      } else if (chatMessage.messageType == 'AUDIO') {
        debugPrint("===============================");
        debugPrint(chatMessage.mediaChatMessage!.isPlaying.toString());
        // return Obx(() {
        // chatMessage.mediaChatMessage!.isPlaying = controller.audioplayed.value;
        return chatMessage.mediaChatMessage!.isPlaying
            ? Icon(Icons.pause)
            : Icon(Icons.play_arrow_sharp);
        // });
      } else {
        return SizedBox.shrink();
      }
    } else {
      switch (chatMessage.isMessageSentByMe
          ? chatMessage.mediaChatMessage!.mediaUploadStatus
          : chatMessage.mediaChatMessage!.mediaDownloadStatus) {
        case Constants.MEDIA_DOWNLOADED:
        case Constants.MEDIA_UPLOADED:
          return SizedBox.shrink();

        case Constants.MEDIA_DOWNLOADED_NOT_AVAILABLE:
        case Constants.MEDIA_NOT_DOWNLOADED:
          return getFileInfo(
              chatMessage.mediaChatMessage!.mediaDownloadStatus,
              chatMessage.mediaChatMessage!.mediaFileSize,
              Icons.download_sharp,
              chatMessage.messageType);
        case Constants.MEDIA_UPLOADED_NOT_AVAILABLE:
          return getFileInfo(
              chatMessage.mediaChatMessage!.mediaDownloadStatus,
              chatMessage.mediaChatMessage!.mediaFileSize,
              Icons.upload_sharp,
              chatMessage.messageType);

        case Constants.MEDIA_NOT_UPLOADED:
        case Constants.MEDIA_DOWNLOADING:
        case Constants.MEDIA_UPLOADING:
          if (chatMessage.messageType == 'AUDIO' ||
              chatMessage.messageType == 'DOCUMENT') {
            return InkWell(
                onTap: () {
                  debugPrint(chatMessage.messageId);
                },
                child:
                    Container(width: 30, height: 30, child: uploadingView()));
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
            color: audiocolordark,
          )
        : Container(
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
            width: screenWidth * 0.60,
            height: screenHeight * 0.4,
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
            color: textcolor,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(2)),
          color: audiobgcolor,
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
                    backgroundColor: audiobgcolor,
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
      case Constants.MEDIA_DOWNLOADED:
      case Constants.MEDIA_UPLOADED:
        if (chatList.messageType == 'VIDEO') {
          if (controller.checkFile(
                  chatList.mediaChatMessage!.mediaLocalStoragePath) &&
              (chatList.mediaChatMessage!.mediaDownloadStatus ==
                      Constants.MEDIA_DOWNLOADED ||
                  chatList.mediaChatMessage!.mediaDownloadStatus ==
                      Constants.MEDIA_UPLOADED ||
                  chatList.isMessageSentByMe)) {
            Get.toNamed(Routes.VIDEO_PLAY, arguments: {
              "filePath": chatList.mediaChatMessage!.mediaLocalStoragePath,
            });
          }
        }
        if (chatList.messageType == 'AUDIO') {
          if (controller.checkFile(
                  chatList.mediaChatMessage!.mediaLocalStoragePath) &&
              (chatList.mediaChatMessage!.mediaDownloadStatus ==
                      Constants.MEDIA_DOWNLOADED ||
                  chatList.mediaChatMessage!.mediaDownloadStatus ==
                      Constants.MEDIA_UPLOADED ||
                  chatList.isMessageSentByMe)) {
            // debugPrint("audio click1");
            chatList.mediaChatMessage!.isPlaying = controller.isplaying.value;
            // controller.playAudio(chatList.mediaChatMessage!);
            playAudio(chatList.mediaChatMessage!.mediaLocalStoragePath,
                chatList.mediaChatMessage!.mediaFileName);
          } else {
            debugPrint("condition failed");
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
        return uploadingView();
      // break;
    }
  }

  getAudioFeedButton(ChatMessageModel chatMessage) {}

  getImageHolder(String mediaFileName) {
    String result = mediaFileName.split('.').last;
    debugPrint("File Type ==> $result");
    switch (result) {
      case Constants.PDF:
        return SvgPicture.asset(
          pdf_image,
          width: 30,
          height: 30,
        );
      case Constants.PPT:
        return SvgPicture.asset(
          ppt_image,
          width: 30,
          height: 30,
        );
      case Constants.XLS:
        return SvgPicture.asset(
          xls_image,
          width: 30,
          height: 30,
        );
      case Constants.XLXS:
        return SvgPicture.asset(
          xlsx_image,
          width: 30,
          height: 30,
        );
      case Constants.DOC:
      case Constants.DOCX:
        return SvgPicture.asset(
          doc_image,
          width: 30,
          height: 30,
        );
      case Constants.APK:
        return SvgPicture.asset(
          apk_image,
          width: 30,
          height: 30,
        );
      default:
        return SvgPicture.asset(
          doc_image,
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
                      audio_mic_bg,
                      width: 50,
                      height: 50,
                      fit: BoxFit.contain,
                    ),
                    Obx(() {
                      return controller.isplaying.value
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
                          thumbColor: audiocolordark,
                          overlayShape: SliderComponentShape.noOverlay,
                          thumbShape:
                              RoundSliderThumbShape(enabledThumbRadius: 5),
                        ),
                        child: Obx(() {
                          return Slider(
                            value:
                                double.parse(controller.currentpos.toString()),
                            min: 0,
                            activeColor: audiocolordark,
                            inactiveColor: audiocolor,
                            max: double.parse(
                                controller.maxduration.value.toString()),
                            divisions: controller.maxduration.value,
                            label: controller.currentpostlabel,
                            onChanged: (double value) async {
                              // int seekval = value.round();
                              // int result = await player.seek(Duration(milliseconds: seekval));
                              // if(result == 1){ //seek successful
                              //   currentpos = seekval;
                              // }else{
                              //   print("Seek unsuccessful.");
                              // }
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
            color: chatsentbgcolor,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: chatreplycontainercolor,
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
        ;
      } else {
        return SizedBox.shrink();
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
        return getLocationImage(locationChatMessage, size, size);
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

  selectedAppBar(BuildContext context) {
    return AppBar(
      // leadingWidth: 25,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          controller.clearAllChatSelection();
        },
      ),
      title: Text(controller.selectedChatList.length.toString()),
      actions: [
        CustomActionBarIcons(
            availableWidth: screenWidth / 2, // half the screen width
            actionWidth: 48, // default for IconButtons
            actions: [
              controller.getOptionStatus('Reply')
                  ? CustomAction(
                      visibleWidget: IconButton(
                          onPressed: () {
                            controller.handleReplyChatMessage(
                                controller.selectedChatList[0]);
                            controller.clearChatSelection(
                                controller.selectedChatList[0]);
                          },
                          icon: const Icon(Icons.reply_outlined)),
                      overflowWidget: const Text("Reply"),
                      showAsAction: ShowAsAction.ALWAYS,
                      keyValue: 'Reply',
                      onItemClick: () {
                        controller.closeKeyBoard();
                        controller.handleReplyChatMessage(
                            controller.selectedChatList[0]);
                        controller
                            .clearChatSelection(controller.selectedChatList[0]);
                      },
                    )
                  : customEmptyAction(),
              CustomAction(
                visibleWidget: Transform(
                  // angle: 180 * math.pi / 180,
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: IconButton(
                      onPressed: () {
                        controller.forwardMessage();
                      },
                      icon: const Icon(Icons.reply_outlined)),
                ),
                overflowWidget: const Text("Forward"),
                showAsAction: ShowAsAction.ALWAYS,
                keyValue: 'Forward',
                onItemClick: () {
                  controller.closeKeyBoard();
                  controller.forwardMessage();
                },
              ),
              controller.getOptionStatus('Favourite')
                  ? CustomAction(
                      visibleWidget: IconButton(
                          onPressed: () {
                            controller.favouriteMessage();
                          },
                          // icon: controller.getOptionStatus('Favourite') ? const Icon(Icons.star_border_outlined)
                          icon: controller.selectedChatList[0].isMessageStarred
                              ? const Icon(Icons.star_border_outlined)
                              : const Icon(Icons.star)),
                      overflowWidget: const Text("Favourite"),
                      showAsAction: ShowAsAction.ALWAYS,
                      keyValue: 'favourite',
                      onItemClick: () {
                        controller.closeKeyBoard();
                        controller.favouriteMessage();
                      },
                    )
                  : customEmptyAction(),
              CustomAction(
                visibleWidget: IconButton(
                    onPressed: () {
                      controller.deleteMessages();
                    },
                    icon: const Icon(Icons.delete_outline_outlined)),
                overflowWidget: const Text("Delete"),
                showAsAction: ShowAsAction.ALWAYS,
                keyValue: 'Delete',
                onItemClick: () {
                  controller.closeKeyBoard();
                  controller.deleteMessages();
                },
              ),
              controller.getOptionStatus('Report')
                  ? CustomAction(
                      visibleWidget: IconButton(
                          onPressed: () {
                            controller.reportChatOrUser();
                          },
                          icon: const Icon(Icons.report_problem_rounded)),
                      overflowWidget: const Text("Report"),
                      showAsAction: ShowAsAction.NEVER,
                      keyValue: 'Report',
                      onItemClick: () {
                        controller.closeKeyBoard();
                        controller.reportChatOrUser();
                      },
                    )
                  : customEmptyAction(),
              controller.selectedChatList.length > 1 ||
                      controller.selectedChatList[0].messageType !=
                          Constants.MTEXT
                  ? customEmptyAction()
                  : CustomAction(
                      visibleWidget: IconButton(
                        onPressed: () {
                          // controller.copyTextMessages();
                        },
                        icon: SvgPicture.asset(
                          copyIcon,
                          fit: BoxFit.contain,
                        ),
                      ),
                      overflowWidget: const Text("Copy"),
                      showAsAction: ShowAsAction.NEVER,
                      keyValue: 'Copy',
                      onItemClick: () {
                        controller.closeKeyBoard();
                        controller.copyTextMessages();
                      },
                    ),
              controller.getOptionStatus('Message Info')
                  ? CustomAction(
                      visibleWidget: IconButton(
                        onPressed: () {
                          // Get.back();
                          controller.messageInfo();
                        },
                        icon: SvgPicture.asset(
                          infoIcon,
                          fit: BoxFit.contain,
                        ),
                      ),
                      overflowWidget: const Text("Message Info"),
                      showAsAction: ShowAsAction.NEVER,
                      keyValue: 'MessageInfo',
                      onItemClick: () {
                        controller.closeKeyBoard();
                        controller.messageInfo();
                      },
                    )
                  : customEmptyAction(),
              controller.getOptionStatus('Share')
                  ? CustomAction(
                      visibleWidget: IconButton(
                          onPressed: () {}, icon: const Icon(Icons.share)),
                      overflowWidget: const Text("Share"),
                      showAsAction: ShowAsAction.NEVER,
                      keyValue: 'Share',
                      onItemClick: () {
                        controller.closeKeyBoard();
                      },
                    )
                  : customEmptyAction(),
            ]),
      ],
    );
  }

  chatAppBar(BuildContext context) {
    return AppBar(
      leadingWidth: 25,
      title: Row(
        children: [
          ImageNetwork(
            url: controller.profile.image.checkNull(),
            width: 45,
            height: 45,
            clipoval: true,
            errorWidget: ProfileTextImage(
              text: controller.profile.name.checkNull().isEmpty
                  ? controller.profile.mobileNumber.checkNull()
                  : controller.profile.name.checkNull(),
              radius: 20,
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Text(controller.profile.name.toString()),
        ],
      ),
      actions: [
        CustomActionBarIcons(
          availableWidth: screenWidth / 2, // half the screen width
          actionWidth: 48, // default for IconButtons
          actions: [
            CustomAction(
              visibleWidget: IconButton(
                onPressed: () {
                  controller.clearUserChatHistory();
                },
                icon: const Icon(Icons.cancel),
              ),
              overflowWidget: const Text("Clear Chat"),
              showAsAction: ShowAsAction.NEVER,
              keyValue: 'Clear Chat',
              onItemClick: () {
                controller.closeKeyBoard();
                debugPrint("Clear chat tap");
                controller.clearUserChatHistory();
              },
            ),
            CustomAction(
              visibleWidget: IconButton(
                onPressed: () {
                  controller.reportChatOrUser();
                },
                icon: const Icon(Icons.report_problem_rounded),
              ),
              overflowWidget: const Text("Report"),
              showAsAction: ShowAsAction.NEVER,
              keyValue: 'Report',
              onItemClick: () {
                controller.closeKeyBoard();
                controller.reportChatOrUser();
              },
            ),
            controller.isBlocked.value
                ? CustomAction(
                    visibleWidget: IconButton(
                      onPressed: () {
                        // Get.back();
                        controller.unBlockUser();
                      },
                      icon: const Icon(Icons.block),
                    ),
                    overflowWidget: const Text("Unblock"),
                    showAsAction: ShowAsAction.NEVER,
                    keyValue: 'Unblock',
                    onItemClick: () {
                      controller.closeKeyBoard();
                      controller.unBlockUser();
                    },
                  )
                : CustomAction(
                    visibleWidget: IconButton(
                      onPressed: () {
                        // Get.back();
                        controller.blockUser();
                      },
                      icon: const Icon(Icons.block),
                    ),
                    overflowWidget: const Text("Block"),
                    showAsAction: ShowAsAction.NEVER,
                    keyValue: 'Block',
                    onItemClick: () {
                      controller.closeKeyBoard();
                      controller.blockUser();
                    },
                  ),
            CustomAction(
              visibleWidget: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.search),
              ),
              overflowWidget: const Text("Search"),
              showAsAction: ShowAsAction.NEVER,
              keyValue: 'Search',
              onItemClick: () {
                controller.closeKeyBoard();
              },
            ),
            CustomAction(
              visibleWidget: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.search),
              ),
              overflowWidget: const Text("Email Chat"),
              showAsAction: ShowAsAction.NEVER,
              keyValue: 'EmailChat',
              onItemClick: () {
                controller.closeKeyBoard();
                controller.exportChat();
              },
            ),
            CustomAction(
              visibleWidget: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.shortcut),
              ),
              overflowWidget: const Text("Add Chat Shortcut"),
              showAsAction: ShowAsAction.NEVER,
              keyValue: 'Shortcut',
              onItemClick: () {
                controller.closeKeyBoard();
              },
            ),
          ],
        ),
      ],
    );
  }

  getAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(55.0),
      child: Obx(() {
        return Container(
          child: controller.isSelected.value
              ? selectedAppBar(context)
              : chatAppBar(context),
        );
      }),
    );
  }

  customEmptyAction() {
    return CustomAction(
        visibleWidget: const SizedBox.shrink(),
        overflowWidget: const SizedBox.shrink(),
        showAsAction: ShowAsAction.ALWAYS,
        keyValue: 'Empty',
        onItemClick: () {});
  }
}
