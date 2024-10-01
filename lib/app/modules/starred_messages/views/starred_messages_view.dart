import 'package:flutter/material.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:get/get.dart';
import '../../../app_style_config.dart';
import '../../../common/app_localizations.dart';

import '../../../common/constants.dart';
import '../../../common/widgets.dart';
import '../../../data/utils.dart';
import '../../../extensions/extensions.dart';
import '../../../model/chat_message_model.dart';
import '../../../widgets/custom_action_bar_icons.dart';
import '../../chat/widgets/chat_widgets.dart';
import '../../chat/widgets/message_content.dart';
import '../../chat/widgets/reply_message_widgets.dart';
import '../controllers/starred_messages_controller.dart';
import 'starred_message_header.dart';

class StarredMessagesView extends NavViewStateful<StarredMessagesController> {
  const StarredMessagesView({Key? key}) : super(key: key);

  @override
StarredMessagesController createController({String? tag}) => Get.put(StarredMessagesController());

  @override
  Widget build(BuildContext context) {
    controller.height = NavUtils.size.height;
    controller.width = NavUtils.size.width;
    return Theme(
      data: Theme.of(context).copyWith(appBarTheme: AppStyleConfig.starredMessageListPageStyle.appBarTheme),
      child: FocusDetector(
        onFocusGained: () {
          controller.getFavouriteMessages();
        },
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              return;
            }
            if (controller.isSelected.value) {
              controller.clearAllChatSelection();
              return;
            }else if(controller.isSearch.value){
              controller.clearSearch();
              return;
            }
            NavUtils.back();
          },
          child: Scaffold(
            appBar: getAppBar(context),
            body: Obx(() {
              return controller.starredChatList.isNotEmpty ?
              SingleChildScrollView(child: favouriteChatListView(controller.starredChatList)) :
              controller.isListLoading.value ? const Center(child: CircularProgressIndicator(),) : Center(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 30),
                child: Text(controller.isSearch.value ? getTranslated("noResultFound") : getTranslated("noStarredMessages"),style: AppStyleConfig.starredMessageListPageStyle.noDataTextStyle,),
              ));
            })
          ),
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
                          (starredChatList[index].isSelected.value) &&
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
                          StarredMessageHeader(chatList: starredChatList[index], isTapEnabled: false,controller: controller,),
                          const SizedBox(height: 10,),
                          Align(
                            alignment: (starredChatList[index].isMessageSentByMe
                                ? Alignment.bottomRight
                                : Alignment.bottomLeft),
                            child: Container(
                              constraints:
                              BoxConstraints(maxWidth: controller.width * 0.75),
                              decoration: starredChatList[index].isMessageSentByMe ? AppStyleConfig.starredMessageListPageStyle.senderChatBubbleStyle.decoration : AppStyleConfig.starredMessageListPageStyle.receiverChatBubbleStyle.decoration,
                              /*decoration: BoxDecoration(
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
                                      : Border.all(color: chatBorderColor)),*/
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  starredChatList[index].isThisAReplyMessage ? starredChatList[index].replyParentChatMessage == null
                                      ? messageNotAvailableWidget(starredChatList[index])
                                      : ReplyMessageHeader(
                                      chatMessage: starredChatList[index],
                                    replyHeaderMessageViewStyle: starredChatList[index].isMessageSentByMe ? AppStyleConfig.starredMessageListPageStyle.senderChatBubbleStyle.replyHeaderMessageViewStyle : AppStyleConfig.starredMessageListPageStyle.receiverChatBubbleStyle.replyHeaderMessageViewStyle,) : const Offstage(),
                                  MessageContent(chatList: starredChatList,search: controller.searchedText.text.trim(),index:index, onPlayAudio: (){
                                    controller.playAudio(starredChatList[index]);
                                  },onSeekbarChange:(value){

                                  },senderChatBubbleStyle: AppStyleConfig.starredMessageListPageStyle.senderChatBubbleStyle,
                                  receiverChatBubbleStyle: AppStyleConfig.starredMessageListPageStyle.receiverChatBubbleStyle,),
                                ],
                              ),
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

  getAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(55.0),
      child: Obx(() {
        return Container(
          child: controller.isSelected.value ? selectedAppBar(context) : controller.isSearch.value ? searchBar(context) : AppBar(
            title: Text(getTranslated("starredMessages")),
            actions: [
              IconButton(
                icon: AppUtils.svgIcon(icon:
                  searchIcon,
                  width: 18,
                  height: 18,
                  fit: BoxFit.contain,
                  colorFilter: ColorFilter.mode(AppBarTheme.of(context).iconTheme?.color ?? Colors.black, BlendMode.srcIn),
                ),
                onPressed: () {
                  controller.onSearchClick();
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  searchBar(BuildContext context){
    return AppBar(
      automaticallyImplyLeading: true,
      title: TextField(
        onChanged: (text) => controller.startSearch(text),
        controller: controller.searchedText,
        focusNode: controller.searchFocus,
        autofocus: true,
        decoration: InputDecoration(
            hintText: getTranslated("searchPlaceholder"), border: InputBorder.none),
      ),
      iconTheme: const IconThemeData(color: iconColor),
      actions: [
        Visibility(
          visible: controller.clear.value,
          child: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              controller.clearSearch();
            },
          ),
        ),
      ],
    );
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
          popupMenuThemeData: AppStyleConfig.starredMessageListPageStyle.popupMenuThemeData,
            availableWidth: controller.width / 2, // half the screen width
            actionWidth: 48, // default for IconButtons
            actions: [
              CustomAction(
                visibleWidget: IconButton(
                    onPressed: () {
                      controller.checkBusyStatusForForward();
                    },
                    icon: AppUtils.svgIcon(icon:forwardIcon,colorFilter: ColorFilter.mode(AppStyleConfig.starredMessageListPageStyle.appBarTheme.actionsIconTheme?.color ?? Colors.black, BlendMode.srcIn),),tooltip: 'Forward',),
                overflowWidget: Text(getTranslated("forward")),
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
                    icon: AppUtils.svgIcon(icon:unFavouriteIcon,colorFilter: ColorFilter.mode(AppStyleConfig.starredMessageListPageStyle.appBarTheme.actionsIconTheme?.color ?? Colors.black, BlendMode.srcIn)),tooltip: 'unFavourite',),
                overflowWidget: Text(getTranslated("unFavourite")),
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
                    icon: AppUtils.svgIcon(icon:shareIcon,colorFilter: ColorFilter.mode(AppStyleConfig.starredMessageListPageStyle.appBarTheme.actionsIconTheme?.color ?? Colors.black, BlendMode.srcIn)),tooltip: 'Share',),
                overflowWidget: Text(getTranslated("share")),
                showAsAction: controller.canBeShare.value ? ShowAsAction.always : ShowAsAction.gone,
                keyValue: 'Share',
                onItemClick: () {},
              ),
              if(!(controller.selectedChatList.length > 1 ||
                  controller.selectedChatList[0].messageType !=
                      Constants.mText))...[
                CustomAction(
                  visibleWidget: IconButton(
                    onPressed: () {
                      controller.copyTextMessages();
                    },
                    icon: AppUtils.svgIcon(icon:
                        copyIcon,
                        fit: BoxFit.contain,
                        colorFilter: ColorFilter.mode(AppStyleConfig.starredMessageListPageStyle.appBarTheme.actionsIconTheme?.color ?? Colors.black, BlendMode.srcIn)
                    ),
                    tooltip: 'Copy',
                  ),
                  overflowWidget: Text(getTranslated("copy")),
                  showAsAction: ShowAsAction.always,
                  keyValue: 'Copy',
                  onItemClick: () {
                    controller.copyTextMessages();
                  },
                )
              ],
              /*controller.selectedChatList.length > 1 ||
                  controller.selectedChatList[0].messageType !=
                      Constants.mText
                  ? customEmptyAction()
                  : ,*/
              CustomAction(
                visibleWidget: IconButton(
                    onPressed: () {
                      controller.deleteMessages();
                    },
                    icon: AppUtils.svgIcon(icon:deleteIcon,colorFilter: ColorFilter.mode(AppStyleConfig.starredMessageListPageStyle.appBarTheme.actionsIconTheme?.color ?? Colors.black, BlendMode.srcIn)),tooltip: 'Delete',),
                overflowWidget: Text(getTranslated("delete")),
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
