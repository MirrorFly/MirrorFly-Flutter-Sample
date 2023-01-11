import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flysdk/flysdk.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/constants.dart';
import '../../data/helper.dart';
import '../../routes/app_pages.dart';
import '../dashboard/widgets.dart';

class ReplyingMessageHeader extends StatelessWidget {
  const ReplyingMessageHeader(
      {Key? key, required this.chatMessage, required this.onCancel})
      : super(key: key);
  final ChatMessageModel chatMessage;
  final Function() onCancel;

  @override
  Widget build(BuildContext context) {
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
                        chatMessage.isMessageSentByMe,
                        chatMessage.senderNickName),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding:
                    const EdgeInsets.only(bottom: 15.0, left: 15.0),
                    child: getReplyMessage(
                        chatMessage.messageType.toUpperCase(),
                        chatMessage.messageTextContent,
                        chatMessage.contactChatMessage
                            ?.contactName,
                        chatMessage.mediaChatMessage
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
                    chatMessage.messageType.toUpperCase(),
                    chatMessage.mediaChatMessage?.mediaThumbImage,
                    chatMessage.locationChatMessage,
                    70),
                GestureDetector(
                  onTap: onCancel,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 10,
                        child: Icon(Icons.close,
                            size: 15, color: Colors.black)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
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
          Text(messageTextContent!),
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
              child: Text(
                contactName!,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
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
    case Constants.mImage:
      return ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: imageFromBase64String(mediaThumbImage!, context, size, size),
      );
    case Constants.mLocation:
      return getLocationImage(locationChatMessage, size, size);
    case Constants.mVideo:
      return ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: imageFromBase64String(mediaThumbImage!, context, size, size),
      );
    default:
      return SizedBox(
        height: size,
      );
  }
}

class ReplyMessageHeader extends StatelessWidget {
  const ReplyMessageHeader({Key? key, required this.chatMessage}) : super(key: key);
  final ChatMessageModel chatMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          color: chatMessage.isMessageSentByMe
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
                      chatMessage.replyParentChatMessage!.isMessageSentByMe,
                      chatMessage.replyParentChatMessage!.senderUserName),
                  const SizedBox(height: 5),
                  getReplyMessage(
                      chatMessage.replyParentChatMessage!.messageType,
                      chatMessage.replyParentChatMessage?.messageTextContent,
                      chatMessage.replyParentChatMessage?.contactChatMessage
                          ?.contactName,
                      chatMessage.replyParentChatMessage?.mediaChatMessage
                          ?.mediaFileName),
                ],
              ),
            ),
            getReplyImageHolder(
                context,
                chatMessage.replyParentChatMessage!.messageType,
                chatMessage
                    .replyParentChatMessage?.mediaChatMessage?.mediaThumbImage,
                chatMessage.replyParentChatMessage?.locationChatMessage,
                55),
          ],
        ),
      );
  }
}

Image imageFromBase64String(
    String base64String, BuildContext context, double? width, double? height) {
  var decodedBase64 = base64String.replaceAll("\n", "");
  Uint8List image = const Base64Decoder().convert(decodedBase64);
  return Image.memory(
    image,
    width: width ?? MediaQuery.of(context).size.width * 0.60,
    height: height ?? MediaQuery.of(context).size.height * 0.4,
    fit: BoxFit.cover,
  );
}

Widget getLocationImage(
    LocationChatMessage? locationChatMessage, double width, double height) {
  return InkWell(
      onTap: () async {
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

class SenderHeader extends StatelessWidget {
  const SenderHeader({Key? key, required this.isGroupProfile, required this.chatList, required this.index}) : super(key: key);
  final bool? isGroupProfile;
  final List<ChatMessageModel> chatList;
  final int index;
  
  bool isSenderChanged(List<ChatMessageModel> messageList, int position) {
    var preposition = position - 1;
    if (!preposition.isNegative) {
      var currentMessage = messageList[position];
      var previousMessage = messageList[position - 1];
      if (currentMessage.isMessageSentByMe != previousMessage.isMessageSentByMe ||
          previousMessage.messageType == Constants.msgTypeNotification ||
          (currentMessage.messageChatType == Constants.typeGroupChat &&
              currentMessage.isThisAReplyMessage)) {
        return true;
      }
      var currentSenderJid = currentMessage.senderUserJid.checkNull();
      var previousSenderJid = previousMessage.senderUserJid.checkNull();
      return previousSenderJid != currentSenderJid;
    } else {
      return false;
    }
  }

  bool isMessageDateEqual(List<ChatMessageModel> messageList, int position) {
    var previousMessage = getPreviousMessage(messageList, position);
    return previousMessage != null && checkIsNotNotification(previousMessage);
  }

  ChatMessageModel? getPreviousMessage(
      List<ChatMessageModel> messageList, int position) {
    return (position > 0) ? messageList[position - 1] : null;
  }

  bool checkIsNotNotification(ChatMessageModel messageItem) {
    var msgType = messageItem.messageType;
    return msgType.toUpperCase() != Constants.mNotification;
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isGroupProfile ?? false
          ? (index == 0 ||
          isSenderChanged(chatList, index) ||
          !isMessageDateEqual(chatList, index)) &&
          !chatList[index].isMessageSentByMe
          : false,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0, right: 8.0, left: 8.0),
        child: Text(
          chatList[index].senderNickName.checkNull(),
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(Helper.getColourCode(
                  chatList[index].senderNickName.checkNull()))),
        ),
      ),
    );
  }
}

class LocationMessageView extends StatelessWidget {
  const LocationMessageView({Key? key, required this.chatMessage}) : super(key: key);
  final ChatMessageModel chatMessage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: getLocationImage(
                chatMessage.locationChatMessage, 200, 171),
          ),
          Positioned(
            bottom: 8,
            right: 10,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                chatMessage.isMessageStarred
                    ? const Icon(
                  Icons.star,
                  size: 13,
                )
                    : const SizedBox.shrink(),
                const SizedBox(
                  width: 5,
                ),
                getMessageIndicator(
                    chatMessage.messageStatus,
                    chatMessage.isMessageSentByMe,
                    chatMessage.messageType),
                const SizedBox(
                  width: 4,
                ),
                Text(
                  getChatTime(
                      context, chatMessage.messageSentTime.toInt()),
                  style: const TextStyle(fontSize: 12, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AudioMessageView extends StatelessWidget {
  const AudioMessageView({Key? key, required this.chatMessage, required this.onTap, required this.currentPos, required this.maxDuration}) : super(key: key);
  final ChatMessageModel chatMessage;
  final int currentPos;
  final int maxDuration;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
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
                  topLeft: Radius.circular(10), topRight: Radius.circular(10)),
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
                    onTap: onTap,
                    child: getImageOverlay(chatMessage),
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
                              currentPos.toString()),
                          min: 0,
                          activeColor: audioColorDark,
                          inactiveColor: audioColor,
                          max: double.parse(
                              maxDuration.toString()),
                          divisions: maxDuration,
                          onChanged: (double value) async {},
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
                const SizedBox(
                  width: 10,
                ),
                Text(
                  Helper.durationToString(Duration(microseconds: chatMessage.mediaChatMessage?.mediaDuration ?? 0)),
                  style: const TextStyle(color: Colors.black, fontSize: 10),
                ),
                const Spacer(),
                chatMessage.isMessageStarred
                    ? const Icon(
                  Icons.star,
                  size: 13,
                )
                    : const SizedBox.shrink(),
                const SizedBox(
                  width: 5,
                ),
                getMessageIndicator(
                    chatMessage.messageStatus,
                    chatMessage.isMessageSentByMe,
                    chatMessage.messageType),
                const SizedBox(
                  width: 4,
                ),
                Text(
                  getChatTime(
                      context, chatMessage.messageSentTime.toInt()),
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
  }
}

class ContactMessageView extends StatelessWidget {
  const ContactMessageView({Key? key, required this.chatMessage}) : super(key: key);
  final ChatMessageModel chatMessage;

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () {
        Get.toNamed(Routes.previewContact, arguments: {
          "contactList": chatMessage.contactChatMessage!.contactPhoneNumbers,
          "contactName": chatMessage.contactChatMessage!.contactName,
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
        width: screenWidth * 0.60,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0),
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
                        chatMessage.contactChatMessage!.contactName,
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
                  chatMessage.isMessageStarred
                      ? const Icon(
                    Icons.star,
                    size: 13,
                  )
                      : const SizedBox.shrink(),
                  const SizedBox(
                    width: 5,
                  ),
                  getMessageIndicator(
                      chatMessage.messageStatus,
                      chatMessage.isMessageSentByMe,
                      chatMessage.messageType),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    getChatTime(
                        context, chatMessage.messageSentTime.toInt()),
                    style: const TextStyle(fontSize: 11, color: chatTimeColor),
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
  }
}

class DocumentMessageView extends StatelessWidget {
  const DocumentMessageView({Key? key, required this.chatMessage, required this.onTap}) : super(key: key);
  final ChatMessageModel chatMessage;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () {
        openDocument(
            chatMessage.mediaChatMessage!.mediaLocalStoragePath, context);
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
              padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0),
              child: Row(
                children: [
                  getImageHolder(chatMessage.mediaChatMessage!.mediaFileName),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                      child: Text(
                        chatMessage.mediaChatMessage!.mediaFileName,
                        maxLines: 2,
                      )),
                  const Spacer(),
                  InkWell(
                    onTap: onTap,
                    child: getImageOverlay(chatMessage),
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
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    Helper.formatBytes(chatMessage.mediaChatMessage?.mediaFileSize ?? 0, 0),
                    style: const TextStyle(color: Colors.black, fontSize: 10),
                  ),
                  const Spacer(),
                  chatMessage.isMessageStarred
                      ? const Icon(
                    Icons.star,
                    size: 13,
                  )
                      : const SizedBox.shrink(),
                  const SizedBox(
                    width: 5,
                  ),
                  getMessageIndicator(
                      chatMessage.messageStatus,
                      chatMessage.isMessageSentByMe,
                      chatMessage.messageType),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    getChatTime(
                        context, chatMessage.messageSentTime.toInt()),
                    style: const TextStyle(fontSize: 11, color: chatTimeColor),
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
  }

  Widget getImageHolder(String mediaFileName) {
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

class VideoMessageView extends StatelessWidget {
  const VideoMessageView(
      {Key? key, required this.chatMessage, required this.onTap, this.search=""})
      : super(key: key);
  final ChatMessageModel chatMessage;
  final String search;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    var mediaMessage = chatMessage.mediaChatMessage!;
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth * 0.60,
      padding: const EdgeInsets.all(2.0),
      child: Column(
        children: [
          Stack(
            children: [
              InkWell(
                onTap: () {
                  if (checkFile(mediaMessage.mediaLocalStoragePath) &&
                      (mediaMessage.mediaDownloadStatus ==
                              Constants.mediaDownloaded ||
                          mediaMessage.mediaDownloadStatus ==
                              Constants.mediaUploaded)) {
                    Get.toNamed(Routes.videoPlay, arguments: {
                      "filePath": mediaMessage.mediaLocalStoragePath,
                    });
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: imageFromBase64String(
                      mediaMessage.mediaThumbImage, context, null, null),
                ),
              ),
              Positioned(
                  top: (screenHeight * 0.4) / 2.5,
                  left: (screenWidth * 0.6) / 3,
                  child: InkWell(
                      onTap: onTap, child: getImageOverlay(chatMessage))),
              mediaMessage.mediaCaptionText.checkNull().isEmpty
                  ? Positioned(
                      bottom: 8,
                      right: 10,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          chatMessage.isMessageStarred
                              ? const Icon(
                                  Icons.star,
                                  size: 13,
                                )
                              : const SizedBox.shrink(),
                          const SizedBox(
                            width: 5,
                          ),
                          getMessageIndicator(
                              chatMessage.messageStatus,
                              chatMessage.isMessageSentByMe,
                              chatMessage.messageType),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                            getChatTime(
                                context, chatMessage.messageSentTime.toInt()),
                            style: const TextStyle(
                                fontSize: 11, color: Colors.white),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
          mediaMessage.mediaCaptionText.checkNull().isNotEmpty ? setCaptionMessage(mediaMessage, chatMessage, context,search: search) : const SizedBox()
        ],
      ),
    );
  }
}

class ImageMessageView extends StatelessWidget {
  const ImageMessageView(
      {Key? key, required this.chatMessage, required this.onTap, this.search=""})
      : super(key: key);
  final ChatMessageModel chatMessage;
  final String search;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    var mediaMessage = chatMessage.mediaChatMessage!;
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth * 0.60,
      padding: const EdgeInsets.all(2.0),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: getImage(
                    mediaMessage.mediaLocalStoragePath,
                    mediaMessage.mediaThumbImage,
                    context,
                    mediaMessage.mediaFileName),
              ),
              Positioned(
                  top: (screenHeight * 0.4) / 2.5,
                  left: (screenWidth * 0.6) / 3,
                  child: InkWell(
                      onTap: onTap, child: getImageOverlay(chatMessage))),
              mediaMessage.mediaCaptionText.checkNull().isEmpty
                  ? Positioned(
                      bottom: 8,
                      right: 10,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          chatMessage.isMessageStarred
                              ? const Icon(
                                  Icons.star,
                                  size: 13,
                                )
                              : const SizedBox.shrink(),
                          const SizedBox(
                            width: 5,
                          ),
                          getMessageIndicator(
                              chatMessage.messageStatus,
                              chatMessage.isMessageSentByMe,
                              chatMessage.messageType),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                            getChatTime(
                                context, chatMessage.messageSentTime.toInt()),
                            style: const TextStyle(
                                fontSize: 11, color: Colors.white),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
          mediaMessage.mediaCaptionText.checkNull().isNotEmpty ? setCaptionMessage(mediaMessage, chatMessage, context,search: search) : const SizedBox(),
        ],
      ),
    );
  }

  getImage(String mediaLocalStoragePath, String mediaThumbImage,
      BuildContext context, String mediaFileName) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    if (checkFile(mediaLocalStoragePath)) {
      return InkWell(
          onTap: () {
            Get.toNamed(Routes.imageView, arguments: {
              'imageName': mediaFileName,
              'imagePath': mediaLocalStoragePath
            });
          },
          child: Image(
            image: FileImage(File(mediaLocalStoragePath)),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return FutureBuilder(builder: (context, d) {
                  return child;
                });
              }
              return const Center(child: CircularProgressIndicator());
            },
            width: screenWidth * 0.60,
            height: screenHeight * 0.4,
            fit: BoxFit.cover,
          ) /*Image.file(
            File(mediaLocalStoragePath),
            width: controller.screenWidth * 0.60,
            height: controller.screenHeight * 0.4,
            fit: BoxFit.cover,
          )*/
          );
    } else {
      return imageFromBase64String(mediaThumbImage, context, null, null);
    }
  }
}

Widget setCaptionMessage(MediaChatMessage mediaMessage,
    ChatMessageModel chatMessage,BuildContext context,{String search = ""}) {
  return Padding(
    padding: const EdgeInsets.all(10.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        search.isEmpty ? textMessageSpannableText(mediaMessage.mediaCaptionText.checkNull()) : chatSpannedText(
          mediaMessage.mediaCaptionText.checkNull(),
          search,
          const TextStyle(fontSize: 14,color: textHintColor),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            chatMessage.isMessageStarred
                ? const Icon(
                    Icons.star,
                    size: 13,
                  )
                : const SizedBox.shrink(),
            const SizedBox(
              width: 5,
            ),
            getMessageIndicator(chatMessage.messageStatus,
                chatMessage.isMessageSentByMe, chatMessage.messageType),
            const SizedBox(
              width: 5,
            ),
            Text(
              getChatTime(context, chatMessage.messageSentTime.toInt()),
              style: const TextStyle(fontSize: 11, color: chatTimeColor),
            ),
          ],
        ),
      ],
    ),
  );
}

class NotificationMessageView extends StatelessWidget {
  const NotificationMessageView({Key? key, required this.chatMessage})
      : super(key: key);
  final ChatMessageModel chatMessage;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
        decoration: const BoxDecoration(
            color: notificationTextBgColor,
            borderRadius: BorderRadius.all(Radius.circular(15))),
        child: Text(chatMessage.messageTextContent ?? "",
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: notificationTextColor)),
      ),
    );
  }
}

class MessageContent extends StatelessWidget {
  const MessageContent({Key? key, required this.chatList, required this.index, required this.handleMediaUploadDownload, required this.currentPos, required this.maxDuration}) : super(key: key);
  final List<ChatMessageModel> chatList;
  final int index;
  final Function(int mediaDownloadStatus,
      ChatMessageModel chatList) handleMediaUploadDownload;
  final int currentPos;
  final int maxDuration;
  @override
  Widget build(BuildContext context) {
    var chatMessage = chatList[index];
    if (chatList[index].isMessageRecalled) {
      return RecalledMessageView(
        chatMessage: chatMessage,
      );
    } else {
      if (chatList[index].messageType.toUpperCase() == Constants.mText) {
        return TextMessageView(chatMessage: chatMessage);
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
                onTap: () {
                  handleMediaUploadDownload(
                      chatMessage.mediaChatMessage!.mediaDownloadStatus,
                      chatList[index]);
                });
          } else if (chatList[index].messageType.toUpperCase() == Constants.mVideo) {
            return VideoMessageView(
                chatMessage: chatMessage,
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
                currentPos: currentPos,
                maxDuration: maxDuration);
          }else{
            return const SizedBox.shrink();
          }
        }
      }
    }
  }
}


class TextMessageView extends StatelessWidget {
  const TextMessageView({Key? key, required this.chatMessage, this.search="",})
      : super(key: key);
  final ChatMessageModel chatMessage;
  final String search;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisSize: chatMessage.replyParentChatMessage == null
            ? MainAxisSize.min
            : MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: search.isEmpty ? textMessageSpannableText(chatMessage.messageTextContent ?? "") : chatSpannedText(
             chatMessage.messageTextContent ?? "",
             search,
             const TextStyle(fontSize: 14,color: textHintColor),
           ),
          ),
          const SizedBox(
            width: 10,
          ),
          Row(
            children: [
              chatMessage.isMessageStarred
                  ? const Icon(
                Icons.star,
                size: 13,
              )
                  : const SizedBox.shrink(),
              const SizedBox(
                width: 5,
              ),
              getMessageIndicator(chatMessage.messageStatus,
                  chatMessage.isMessageSentByMe,chatMessage.messageType),
              const SizedBox(
                width: 5,
              ),
              Text(
                getChatTime(context, chatMessage.messageSentTime.toInt()),
                style: const TextStyle(fontSize: 11, color: chatTimeColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RecalledMessageView extends StatelessWidget {
  const RecalledMessageView({Key? key, required this.chatMessage})
      : super(key: key);
  final ChatMessageModel chatMessage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisSize: chatMessage.replyParentChatMessage == null
            ? MainAxisSize.min
            : MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Image.asset(
                disabledIcon,
                width: 15,
                height: 15,
              ),
              const SizedBox(width: 10),
              Text(
                chatMessage.isMessageSentByMe
                    ? "You deleted this message"
                    : "This message was deleted",
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(
            width: 10,
          ),
          Row(
            children: [
              Text(
                getChatTime(context, chatMessage.messageSentTime.toInt()),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

getMessageIndicator(String? messageStatus, bool isSender, String messageType) {
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

getImageOverlay(ChatMessageModel chatMessage) {

  debugPrint("****GET IMAGE OVERLAY**** ${chatMessage.messageStatus} **** ${chatMessage.messageType.toUpperCase()}");
  debugPrint(checkFile(chatMessage.mediaChatMessage!.mediaLocalStoragePath).toString());
  debugPrint(chatMessage.mediaChatMessage!.mediaLocalStoragePath);
  if (checkFile(chatMessage.mediaChatMessage!.mediaLocalStoragePath) &&
      chatMessage.messageStatus != 'N') {
    debugPrint("===media in play state===");
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
      return chatMessage.mediaChatMessage!.isPlaying
          ? const Icon(Icons.pause)
          : const Icon(Icons.play_arrow_sharp);
    } else {
      debugPrint("==Showing EMpty===");
      return const SizedBox.shrink();
    }
  } else {
    debugPrint("===media in Download/Upload state===");
    debugPrint(chatMessage.isMessageSentByMe.toString());
    debugPrint("upload status--- ${chatMessage.mediaChatMessage!.mediaUploadStatus.toString()}");
    debugPrint("download status--- ${chatMessage.mediaChatMessage!.mediaDownloadStatus.toString()}");
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

uploadingView() {
  return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: textColor,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(2)),
        color: audioBgColor,
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

class AttachmentsSheetView extends StatelessWidget {
  const AttachmentsSheetView({Key? key, required this.onDocument, required this.onCamera, required this.onGallery, required this.onAudio, required this.onContact, required this.onLocation}) : super(key: key);
  final Function() onDocument;
  final Function() onCamera;
  final Function() onGallery;
  final Function() onAudio;
  final Function() onContact;
  final Function() onLocation;

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return Container(
      height: 270,
      width: screenWidth,
      margin: const EdgeInsets.only(bottom: 40),
      child: Card(
        color: bottomSheetColor,
        margin: const EdgeInsets.all(18.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconCreation(documentImg, "Document",onDocument),
                  const SizedBox(
                    width: 50,
                  ),
                  iconCreation(cameraImg, "Camera", onCamera),
                  const SizedBox(
                    width: 50,
                  ),
                  iconCreation(galleryImg,  "Gallery", onGallery),
                ],
              ),
              const SizedBox(
                height: 35,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconCreation(audioImg, "Audio", onAudio),
                  const SizedBox(
                    width: 50,
                  ),
                  iconCreation(contactImg, "Contact", onContact),
                  const SizedBox(
                    width: 50,
                  ),
                  iconCreation(locationImg, "Location", onLocation),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
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

Widget chatSpannedText(String text, String spannableText,TextStyle? style) {
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
              text: endText)
        ],
        style: style));
  } else {
    return textMessageSpannableText(text);//Text(text, style: style);
  }
}
