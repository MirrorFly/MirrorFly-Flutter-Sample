import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../common/constants.dart';
import 'package:fly_chat/flysdk.dart';

import '../chat_widgets.dart';
import '../controllers/chat_controller.dart';

class ChatSearchView extends GetView<ChatController> {
  const ChatSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.screenHeight = MediaQuery.of(context).size.height;
    controller.screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () {
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
            onSubmitted: (str) {
              if (controller.filteredPosition.isNotEmpty) {
                controller.scrollUp();
              } else {
                toToast("No Results Found");
              }
            },
          ),
          iconTheme: const IconThemeData(color: iconColor),
          actions: [
            IconButton(
                onPressed: () {
                  controller.scrollUp();
                },
                icon: const Icon(Icons.keyboard_arrow_up)),
            IconButton(
                onPressed: () {
                  controller.scrollDown();
                },
                icon: const Icon(Icons.keyboard_arrow_down)),
          ],
        ),
        body: Obx(() => controller.chatList.isEmpty
            ? const SizedBox.shrink()
            : chatListView(controller.chatList)),
      ),
    );
  }

  Widget chatListView(List<ChatMessageModel> chatList) {
    return ScrollablePositionedList.builder(
      itemCount: chatList.length,
      //initialScrollIndex: chatList.length,
      itemScrollController: controller.searchScrollController,
      itemPositionsListener: controller.itemPositionsListener,
      reverse: true,
      itemBuilder: (context, index) {
        return Column(
          children: [
            groupedDateMessage(index, chatList) != null
                ? NotificationMessageView(
                    chatMessage: groupedDateMessage(index, chatList))
                : const SizedBox.shrink(),
            (chatList[index].messageType.toUpperCase() !=
                    Constants.mNotification)
                ? Container(
                    color: chatList[index].isSelected
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
                            visible: chatList[index].isMessageSentByMe &&
                                controller
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
                                SenderHeader(
                                    isGroupProfile:
                                        controller.profile.isGroupProfile,
                                    chatList: chatList,
                                    index: index),
                                (chatList[index].replyParentChatMessage == null)
                                    ? const SizedBox.shrink()
                                    : ReplyMessageHeader(
                                        chatMessage: chatList[index]),
                                MessageContent(
                                  chatList: chatList,
                                  index: index,
                                  search: controller.searchedText.text.trim(),
                                  onPlayAudio: () {
                                    controller.playAudio(chatList[index]);
                                  },
                                  onSeekbarChange:(value){

                                  },
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible: !chatList[index].isMessageSentByMe &&
                                controller
                                    .forwardMessageVisibility(chatList[index]),
                            child: IconButton(
                                onPressed: () {
                                  controller.forwardSingleMessage(
                                      chatList[index].messageId);
                                },
                                icon: SvgPicture.asset(forwardMedia)),
                          ),
                        ],
                      ),
                    ),
                  )
                : NotificationMessageView(
                    chatMessage: chatList[index].messageTextContent),
          ],
        );
      },
    );
  }
}
