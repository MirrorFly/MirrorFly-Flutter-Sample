import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../common/constants.dart';
import '../../chat/views/message_content.dart';
import '../../chat/views/starred_message_header.dart';
import '../controllers/starred_messages_controller.dart';
import 'package:flysdk/flysdk.dart';

class StarredMessagesView extends GetView<StarredMessagesController> {
  const StarredMessagesView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    controller.height = MediaQuery.of(context).size.height;
    controller.width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Starred Messages'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            width: controller.width,
            height: controller.height - 150,
            child: Column(
              children: [
                Expanded(
                  child: Obx(() {
                    return controller.starredChatList.isNotEmpty ?
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: favouriteChatListView(controller.starredChatList),
                    ) : const Center(child: Text("No Starred Messages Found"));
                  }),
                ),
              ],
            ),
          ),
        ),
      )
    );
  }

  Widget favouriteChatListView(RxList<ChatMessageModel> starredChatList) {
    return Align(
      alignment: Alignment.topCenter,
      child: ListView.builder(
        // controller: controller.scrollController,
        itemCount: starredChatList.length,
        shrinkWrap: true,
        reverse: false,
        itemBuilder: (context, index) {
          // int reversedIndex = chatList.length - 1 - index;
            return GestureDetector(
              onLongPress: () {

              },
              onTap: () {
                debugPrint("On Tap");

              },
              child: Obx(() {
                return Column(
                  children: [
                    StarredMessageHeader(chatList: starredChatList[index], isTapEnabled: false,),
                    const SizedBox(height: 10,),
                    Container(
                      key: Key(starredChatList[index].messageId),
                      color: controller.isSelected.value &&
                          (starredChatList[index].isSelected) &&
                          controller.starredChatList.isNotEmpty
                          ? chatReplyContainerColor
                          : Colors.transparent,
                      margin: const EdgeInsets.only(
                          left: 14, right: 14, top: 5, bottom: 10),
                      child: Align(
                        alignment: (starredChatList[index].isMessageSentByMe
                            ? Alignment.bottomRight
                            : Alignment.bottomLeft),
                        child: Container(
                          constraints:
                          BoxConstraints(maxWidth: controller.width * 0.75),
                          decoration: BoxDecoration(
                              borderRadius: starredChatList[index].isMessageSentByMe
                                  ? const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomLeft: Radius.circular(10))
                                  : const BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                  bottomRight: Radius.circular(10)),
                              color: (starredChatList[index].isMessageSentByMe
                                  ? chatSentBgColor
                                  : Colors.white),
                              border: starredChatList[index].isMessageSentByMe
                                  ? Border.all(color: chatSentBgColor)
                                  : Border.all(color: chatBorderColor)),
                          child: MessageContent(chatList: starredChatList[index], isTapEnabled: false,),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            );
        },
      ),
    );
  }
}
