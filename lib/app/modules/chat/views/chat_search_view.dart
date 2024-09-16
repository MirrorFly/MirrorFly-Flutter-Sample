import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app_style_config.dart';
import '../../../common/app_localizations.dart';
import '../../../extensions/extensions.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../common/constants.dart';
import '../../../data/utils.dart';
import '../../../model/chat_message_model.dart';
import '../../../stylesheet/stylesheet.dart';
import '../controllers/chat_controller.dart';
import '../widgets/chat_widgets.dart';
import '../widgets/message_content.dart';
import '../widgets/notification_message_view.dart';
import '../widgets/reply_message_widgets.dart';
import '../widgets/sender_header.dart';

class ChatSearchView extends StatelessWidget {
  ChatSearchView({super.key});

  final ChatController controller = ChatController(null).get();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        controller.searchInit();
        if (didPop) {
          return;
        }
      },
      child: Theme(
        data: Theme.of(context).copyWith(appBarTheme: AppStyleConfig.chatPageStyle.appBarTheme),
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: true,
            title: TextField(
              onChanged: (text) => controller.setSearch(text),
              controller: controller.searchedText,
              focusNode: controller.searchfocusNode,
              autofocus: true,
              style: AppStyleConfig.chatPageStyle.searchTextFieldStyle.editTextStyle,
              decoration: InputDecoration(
                  hintText: getTranslated("searchPlaceholder"), border: InputBorder.none,
                hintStyle: AppStyleConfig.chatPageStyle.searchTextFieldStyle.editTextHintStyle
              ),
              onSubmitted: (str) {
                if (controller.filteredPosition.isNotEmpty) {
                  controller.scrollUp();
                } else {
                  toToast(getTranslated("noResultsFound"));
                }
              },
            ),
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
              ? const Offstage()
              : chatListView(controller.chatList,senderChatStyle: AppStyleConfig.chatPageStyle.senderChatBubbleStyle,receiverChatStyle: AppStyleConfig.chatPageStyle.receiverChatBubbleStyle,chatSelectedColor: AppStyleConfig.chatPageStyle.chatSelectionBgColor,notificationMessageViewStyle: AppStyleConfig.chatPageStyle.notificationMessageViewStyle)),
        ),
      ),
    );
  }

  Widget chatListView(List<ChatMessageModel> chatList,{required SenderChatBubbleStyle senderChatStyle,required ReceiverChatBubbleStyle receiverChatStyle, required Color chatSelectedColor,required NotificationMessageViewStyle notificationMessageViewStyle}) {
    return ScrollablePositionedList.separated(
      separatorBuilder: (context, index) {
        var string = AppUtils.groupedDateMessage(index, chatList); //Date Labels
        return string != null ? NotificationMessageView(chatMessage: string) : const Offstage();
      },
      itemCount: chatList.length,
      itemScrollController: controller.searchScrollController,
      itemPositionsListener: controller.newItemPositionsListener,
      reverse: true,
      itemBuilder: (context, index) {
        return Column(
          children: [
            Obx(() {
              // LogMessage.d("ScrollablePositionedList inside AutomaticKeepAlive", "build $index");
              return controller.showLoadingPrevious.value && index == chatList.length - 1
                  ? const Center(child: CircularProgressIndicator())
                  : const Offstage();
            }),
            (chatList[index].messageType.toUpperCase() !=
                    Constants.mNotification)
                ? Container(
              key: ValueKey(chatList[index].messageId),
              color: chatList[index].isSelected.value ? chatSelectedColor : Colors.transparent,
              margin: const EdgeInsets.only(left: 14, right: 14, top: 5, bottom: 10),
              child: Align(
                alignment: (chatList[index].isMessageSentByMe ? Alignment.bottomRight : Alignment.bottomLeft),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Visibility(
                      visible: chatList[index].isMessageSentByMe && controller.forwardMessageVisibility(chatList[index]),
                      child: IconButton(
                          onPressed: () {
                            controller.forwardSingleMessage(chatList[index].messageId);
                          },
                          icon: AppUtils.svgIcon(icon:forwardMedia)),
                    ),
                    Container(
                      constraints: BoxConstraints(maxWidth: NavUtils.width * 0.75),
                      decoration: chatList[index].isMessageSentByMe ? senderChatStyle.decoration : receiverChatStyle.decoration,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (controller.profile.isGroupProfile.checkNull()) ...[
                                  SenderHeader(
                                    isGroupProfile: controller.profile.isGroupProfile,
                                    chatList: chatList,
                                    index: index,textStyle: receiverChatStyle.participantNameTextStyle,),
                                ],
                                chatList[index].isThisAReplyMessage
                                    ? chatList[index].replyParentChatMessage == null
                                    ? messageNotAvailableWidget(chatList[index])
                                    : ReplyMessageHeader(chatMessage: chatList[index],replyHeaderMessageViewStyle: chatList[index].isMessageSentByMe ? senderChatStyle.replyHeaderMessageViewStyle : receiverChatStyle.replyHeaderMessageViewStyle,)
                                    : const Offstage(),
                                MessageContent(
                                  chatList: chatList,
                                  index: index,
                                  search: controller.searchedText.text.trim(),
                                  onPlayAudio: () {
                                    // controller.playAudio(chatList[index]);
                                  },
                                  onSeekbarChange:(value){

                                  },
                                  senderChatBubbleStyle: senderChatStyle,
                                  receiverChatBubbleStyle: receiverChatStyle,
                                  notificationMessageViewStyle: notificationMessageViewStyle,)
                              ],
                            ),
                          ),
                    if (!chatList[index].isMessageSentByMe &&
                        controller.forwardMessageVisibility(chatList[index])) ...[
                      IconButton(
                          onPressed: () {
                            controller.forwardSingleMessage(chatList[index].messageId);
                          },
                          icon: AppUtils.svgIcon(icon:forwardMedia))
                    ],
                        ],
                      ),
                    ),
                  )
                : NotificationMessageView(
                    chatMessage: chatList[index].messageTextContent),
            Obx(() {
              return controller.showLoadingNext.value && index == 0
                  ? const Center(
                child: CircularProgressIndicator(),
              )
                  : const Offstage();
            }),
          ],
        );
      },
    );
  }
}
