import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../common/constants.dart';
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
                        MessageContent(chatList: chatList, index: index, onPlayAudio: () {
                          controller.playAudio(chatList[index]);
                        },),
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

  /*getMessageContent(int index, BuildContext context,
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
                search: controller.searchedText.text,);
          } else if (chatList[index].messageType.toUpperCase() == Constants.mDocument || chatList[index].messageType.toUpperCase() == Constants.mFile) {
            return DocumentMessageView(
                chatMessage: chatMessage,);
          } else if (chatList[index].messageType.toUpperCase() == Constants.mAudio) {
            return AudioMessageView(
                chatMessage: chatMessage,
                onPlayAudio: () {
                  handleMediaUploadDownload(
                      chatMessage.mediaChatMessage!.mediaDownloadStatus,
                      chatList[index]);
                });
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
  }*/

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

}
