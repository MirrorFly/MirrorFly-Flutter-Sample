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
import 'package:mirror_fly_demo/app/common/widgets.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/data/permissions.dart';
import 'package:mirror_fly_demo/app/model/chatMessageModel.dart';
import 'package:mirror_fly_demo/app/modules/chat/views/locationsent_view.dart';

// import 'package:image_picker/image_picker.dart';
import 'package:mirror_fly_demo/app/routes/app_pages.dart';
import 'package:mirror_fly_demo/app/widgets/record_button.dart';
import 'package:url_launcher/url_launcher.dart';

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
                width: 45,
                height: 45,
                clipoval: true,
                errorWidget: ProfileTextImage(
                  text: controller.profile.name
                      .checkNull()
                      .isEmpty
                      ? controller.profile.mobileNumber.checkNull()
                      : controller.profile.name.checkNull(), radius: 20,
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
                top: (MediaQuery
                    .of(context)
                    .size
                    .height * 0.4) / 2.5,
                left: (MediaQuery
                    .of(context)
                    .size
                    .width * 0.6) / 3,
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
                top: (MediaQuery
                    .of(context)
                    .size
                    .height * 0.4) / 2.6,
                left: (MediaQuery
                    .of(context)
                    .size
                    .width * 0.6) / 2.9,
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
      return InkWell(
        onTap: () {
          controller.openDocument(
              chatList[index].mediaChatMessage!.mediaLocalStoragePath, context);
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black12,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            color: Colors.white,
          ),
          width: MediaQuery
              .of(context)
              .size
              .width * 0.60,
          child: Column(
            children: [
              Padding(
                padding:
                const EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0),
                child: Row(
                  children: [
                    getImageHolder(
                        chatList[index].mediaChatMessage!.mediaFileName),
                    SizedBox(
                      width: 12,
                    ),
                    Expanded(
                        child: Text(
                          chatList[index].mediaChatMessage!.mediaFileName,
                          maxLines: 2,
                        )),
                    Spacer(),
                    InkWell(
                      onTap: () {
                        handleMediaUploadDownload(
                            chatList[index].mediaChatMessage!
                                .mediaDownloadStatus,
                            chatList[index]);
                      },
                      child: getImageOverlay(chatList, index, context),
                    ),

                  ],
                ),
              ),
              SizedBox(
                height: 5,
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
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 5,
              ),
            ],
          ),
        ),
      );
    } else if (chatList[index].messageType == 'CONTACT') {
      return InkWell(
        onTap: (){
          Get.toNamed(Routes.PREVIEW_CONTACT, arguments: {"contactList" : chatList[index].contactChatMessage!.contactPhoneNumbers, "contactName": chatList[index].contactChatMessage!.contactName, "from": "chat"});
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black12,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            color: Colors.white,
          ),
          width: MediaQuery
              .of(context)
              .size
              .width * 0.60,
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
                    SizedBox(
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
                    SizedBox(
                      width: 10,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 5,
              ),
            ],
          ),
        ),
      );
    } else if (chatList[index].messageType == 'AUDIO') {
      var chatMessage = chatList[index];
      return Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black12,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          color: Colors.white,
        ),
        width: MediaQuery
            .of(context)
            .size
            .width * 0.60,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
                color: Colors.black12,
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
                    SizedBox(
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

                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: SizedBox(
                        // width: 168,
                        child: SliderTheme(
                          data: SliderThemeData(
                            thumbColor: audiocolordark,
                            overlayShape: SliderComponentShape.noOverlay,
                            thumbShape:
                            RoundSliderThumbShape(enabledThumbRadius: 5),
                          ),
                          child: Slider(
                            value:
                            double.parse(controller.currentpos.value.toString()),
                            min: 0,
                            activeColor: audiocolordark,
                            inactiveColor: audiocolor,
                            max:
                            double.parse(controller.maxduration.value.toString()),
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
            SizedBox(
              height: 5,
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
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 5,
            ),
            ],
          ),
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
              child: getLocationImage(chatList[index]),
            ),
            Positioned(
              bottom: 8,
              right: 10,
              child:Row(
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
                    style:
                    const TextStyle(fontSize: 12, color: Colors.black),
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

  Widget getLocationImage(ChatMessageModel item) {
    return InkWell(
        onTap: () async {
          //Redirect to Google maps App
          String googleUrl =
              'https://www.google.com/maps/search/?api=1&query=${item.locationChatMessage!.latitude}, ${item.locationChatMessage!.longitude}';
          if (await canLaunchUrl(Uri.parse(googleUrl))) {
            await launchUrl(Uri.parse(googleUrl));
          } else {
            throw 'Could not open the map.';
          }
        },
        child: Image.network(
          Helper.getMapImageUri(item.locationChatMessage!.latitude,
              item.locationChatMessage!.longitude),
          fit: BoxFit.fill,
          width: 200,
          height: 171,
        ));
  }

  Widget bottomSheet(BuildContext context) {
    return SizedBox(
      height: 270,
      width: MediaQuery
          .of(context)
          .size
          .width,
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
                  iconCreation(documentImg, "Document", () {
                    Get.back();
                    controller.documetPickUpload();
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
                  iconCreation(documentImg, "Audio", () {
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
                            onPressed: ScaffoldMessenger
                                .of(context)
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
              video_play,
              fit: BoxFit.contain,
            )
          ),
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
      switch (chatMessage.mediaChatMessage!.mediaDownloadStatus) {
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
            return Container(width: 30, height: 30, child: uploadingView());
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
            width: MediaQuery
                .of(context)
                .size
                .width * 0.60,
            height: MediaQuery
                .of(context)
                .size
                .height * 0.4,
            fit: BoxFit.cover,
          ));
    } else {
      return controller.imageFromBase64String(mediaThumbImage, context);
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
        child: Stack(
          alignment: Alignment.center,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              downloading,
              fit: BoxFit.contain,
            ),
            Align(
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
          ]
        ));
  }

  handleMediaUploadDownload(int mediaDownloadStatus,
      ChatMessageModel chatList) {
    debugPrint(mediaDownloadStatus.toString());
    debugPrint(chatList.messageType.toString());
    debugPrint(chatList.isMessageSentByMe.toString());
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
                      Constants.MEDIA_UPLOADED || chatList.isMessageSentByMe)) {
            Get.toNamed(Routes.VIDEO_PLAY, arguments: {
              "filePath": chatList.mediaChatMessage!.mediaLocalStoragePath,
            });
          }
        }
        if (chatList.messageType == 'AUDIO') {
          debugPrint(controller.checkFile(chatList.mediaChatMessage!.mediaLocalStoragePath));
          debugPrint(chatList.mediaChatMessage!.mediaDownloadStatus.toString());
          if (controller.checkFile(
              chatList.mediaChatMessage!.mediaLocalStoragePath) &&
              (chatList.mediaChatMessage!.mediaDownloadStatus ==
                  Constants.MEDIA_DOWNLOADED ||
                  chatList.mediaChatMessage!.mediaDownloadStatus ==
                      Constants.MEDIA_UPLOADED || chatList.isMessageSentByMe)) {
            debugPrint("audio click1");
            chatList.mediaChatMessage!.isPlaying = controller.isplaying.value;
            // controller.playAudio(chatList.mediaChatMessage!);
            playAudio(chatList.mediaChatMessage!.mediaLocalStoragePath,
                chatList.mediaChatMessage!.mediaFileName);
          }else{
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
        // return uploadingView();
        break;
    }
  }

  getAudioFeedButton(ChatMessageModel chatMessage) {}

  getImageHolder(String mediaFileName) {
    String result = mediaFileName
        .split('.')
        .last;
    debugPrint("File Type ==> $result");
    switch (result) {
      case Constants.PDF:
        return SvgPicture.asset(pdf_image, width: 30, height: 30,);
      case Constants.PPT:
        return SvgPicture.asset(ppt_image, width: 30, height: 30,);
      case Constants.XLS:
        return SvgPicture.asset(xls_image, width: 30, height: 30,);
      case Constants.XLXS:
        return SvgPicture.asset(xlsx_image, width: 30, height: 30,);
      case Constants.DOC:
      case Constants.DOCX:
        return SvgPicture.asset(doc_image, width: 30, height: 30,);
      case Constants.APK:
        return SvgPicture.asset(apk_image, width: 30, height: 30,);
      default:
        return SvgPicture.asset(doc_image, width: 30, height: 30,);
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
                      return controller.isplaying.value ? Icon(Icons.pause) :
                      Icon(Icons.play_arrow);
                    }),
                  ],
                ),
              ),
              SizedBox(width: 20,),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(mediaFileName, maxLines: 2,),
                    SizedBox(height: 15,),
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
                            max:
                            double.parse(controller.maxduration.value.toString()),
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
}
