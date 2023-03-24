import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:focus_detector/focus_detector.dart';

import 'package:get/get.dart';

import '../../../common/constants.dart';
import '../../../common/widgets.dart';
import '../../../widgets/custom_action_bar_icons.dart';
import '../../chat/chat_widgets.dart';
import '../../chat/views/starred_message_header.dart';
import '../controllers/starred_messages_controller.dart';
import 'package:fly_chat/flysdk.dart';

class StarredMessagesView extends GetView<StarredMessagesController> {
  const StarredMessagesView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    controller.height = MediaQuery.of(context).size.height;
    controller.width = MediaQuery.of(context).size.width;
    return FocusDetector(
      onFocusGained: () {
        controller.getFavouriteMessages();
      },
      child: WillPopScope(
        onWillPop: () {
          if (controller.isSelected.value) {
            controller.clearAllChatSelection();
            return Future.value(false);
          }
          return Future.value(true);
        },
        child: Scaffold(
          appBar: getAppBar(),
          body: Obx(() {
            return controller.starredChatList.isNotEmpty ?
            SingleChildScrollView(child: favouriteChatListView(controller.starredChatList)) :
            controller.isListLoading.value ? const Center(child: CircularProgressIndicator(),) : const Center(child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 30),
              child: Text("No Starred Messages Found"),
            ));
          })
        ),
      ),
    );
  }

  Widget favouriteChatListView(RxList<ChatMessageModel> starredChatList) {
    return Align(
      alignment: Alignment.topCenter,
      child: ListView.builder(
        // controller: controller.scrollController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: starredChatList.length,
        shrinkWrap: true,
        reverse: false,
        itemBuilder: (context, index) {
          // int reversedIndex = chatList.length - 1 - index;
            return GestureDetector(
              onLongPress: () {
                if (!controller.isSelected.value) {
                  controller.isSelected(true);
                  controller.addChatSelection(starredChatList[index]);
                }
              },
              onTap: () {
                debugPrint("On Tap");
                controller.isSelected.value
                    ? controller.selectedChatList.contains(starredChatList[index])
                    ? controller.clearChatSelection(starredChatList[index])
                    : controller.addChatSelection(starredChatList[index])
                    : controller.navigateMessage(starredChatList[index]);
              },
              child: Obx(() {
                return Column(
                  children: [
                    Container(
                      key: Key(starredChatList[index].messageId),
                      color: controller.isSelected.value &&
                          (starredChatList[index].isSelected) &&
                          controller.starredChatList.isNotEmpty
                          ? chatReplyContainerColor
                          : Colors.transparent,
                      padding: const EdgeInsets.only(
                          left: 14, right: 14, top: 5, bottom: 10),
                      margin: const EdgeInsets.all(2),
                      child: Column(
                        children: [
                          const AppDivider(),
                          const SizedBox(height: 10,),
                          StarredMessageHeader(chatList: starredChatList[index], isTapEnabled: false,),
                          const SizedBox(height: 10,),
                          Align(
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
                              child: MessageContent(chatList: starredChatList,index:index, onPlayAudio: (){
                                controller.playAudio(starredChatList[index]);
                              },onSeekbarChange:(value){

                              },),
                            ),
                          ),
                        ],
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

  getAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(55.0),
      child: Obx(() {
        return Container(
          child: controller.isSelected.value ? selectedAppBar() : controller.isSearch.value ? searchBar() : AppBar(
            title: const Text('Starred Messages'),
            actions: [
              IconButton(
                icon: SvgPicture.asset(
                  searchIcon,
                  width: 18,
                  height: 18,
                  fit: BoxFit.contain,
                ),
                onPressed: () {
                  /*if (controller.isSearch.value) {
                    controller.isSearch(false);
                  } else {
                    controller.isSearch(true);
                  }*/
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  searchBar(){
    return AppBar(
      automaticallyImplyLeading: true,
      title: TextField(
        onChanged: (text) => controller.startSearch(text),
        controller: controller.searchedText,
        autofocus: true,
        decoration: const InputDecoration(
            hintText: "Search...", border: InputBorder.none),
      ),
      iconTheme: const IconThemeData(color: iconColor),
    );
  }

  selectedAppBar() {
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
            availableWidth: controller.width / 2, // half the screen width
            actionWidth: 48, // default for IconButtons
            actions: [
              CustomAction(
                visibleWidget: IconButton(
                    onPressed: () {
                      controller.checkBusyStatusForForward();
                    },
                    icon: SvgPicture.asset(forwardIcon),tooltip: 'Forward',),
                overflowWidget: const Text("Forward"),
                showAsAction: controller.canBeForward.value ? ShowAsAction.always : ShowAsAction.gone,
                keyValue: 'Forward',
                onItemClick: () {
                  controller.checkBusyStatusForForward();
                },
              ),
              CustomAction(
                visibleWidget: IconButton(
                    onPressed: () {
                      controller.favouriteMessage();
                    },
                    icon: SvgPicture.asset(unFavouriteIcon),tooltip: 'unFavourite',),
                overflowWidget: const Text("unFavourite"),
                showAsAction: ShowAsAction.always,
                keyValue: 'unfavoured',
                onItemClick: () {
                  controller.favouriteMessage();
                },
              ),
              CustomAction(
                visibleWidget: IconButton(
                    onPressed: () {
                      controller.share();
                    },
                    icon: SvgPicture.asset(shareIcon),tooltip: 'Share',),
                overflowWidget: const Text("Share"),
                showAsAction: controller.canBeShare.value ? ShowAsAction.always : ShowAsAction.gone,
                keyValue: 'Share',
                onItemClick: () {},
              ),
              controller.selectedChatList.length > 1 ||
                  controller.selectedChatList[0].messageType !=
                      Constants.mText
                  ? customEmptyAction()
                  : CustomAction(
                visibleWidget: IconButton(
                  onPressed: () {
                    controller.copyTextMessages();
                  },
                  icon: SvgPicture.asset(
                    copyIcon,
                    fit: BoxFit.contain,
                  ),
                  tooltip: 'Copy',
                ),
                overflowWidget: const Text("Copy"),
                showAsAction: ShowAsAction.always,
                keyValue: 'Copy',
                onItemClick: () {
                  controller.copyTextMessages();
                },
              ),
              CustomAction(
                visibleWidget: IconButton(
                    onPressed: () {
                      controller.deleteMessages();
                    },
                    icon: SvgPicture.asset(deleteIcon),tooltip: 'Delete',),
                overflowWidget: const Text("Delete"),
                showAsAction: ShowAsAction.always,
                keyValue: 'Delete',
                onItemClick: () {
                  controller.deleteMessages();
                },
              ),
            ]),
      ],
    );
  }

  customEmptyAction() {
    return CustomAction(
        visibleWidget: const SizedBox.shrink(),
        overflowWidget: const SizedBox.shrink(),
        showAsAction: ShowAsAction.gone,
        keyValue: 'Empty',
        onItemClick: () {});
  }
}
