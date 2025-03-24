import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/modules/chat/views/chat_input_field.dart';

import '../../../app_style_config.dart';
import '../../../common/app_localizations.dart';
import '../../../common/widgets.dart';
import '../../../data/helper.dart';
import '../../../extensions/extensions.dart';
import '../../../modules/chat/widgets/floating_fab.dart';
import 'package:mirrorfly_plugin/logmessage.dart';

import '../../../common/constants.dart';
import '../../../data/utils.dart';
import '../../../model/arguments.dart';
import '../../../routes/route_settings.dart';
import '../../../widgets/custom_action_bar_icons.dart';
import '../../../widgets/marquee_text.dart';
import '../controllers/chat_controller.dart';
import 'chat_list_view.dart';

class ChatView extends NavViewStateful<ChatController> {
  ChatView({Key? key, this.chatViewArguments})
      : super(key: key, tag: chatViewArguments?.chatJid);
  final ChatViewArguments? chatViewArguments;
  final chatStyle = AppStyleConfig.chatPageStyle;

  @override
  ChatController createController({String? tag}) {
    debugPrint("ChatView createController");
    final arguments = chatViewArguments ??
        NavUtils.arguments as ChatViewArguments;
    return Get.put(ChatController(arguments), tag: tag);
  }

  /*@override
    void dispose() {
      Get.delete<ChatController>();
      super.dispose();
    }*/

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
          appBarTheme: chatStyle.appBarTheme
      ),
      child: Scaffold(
          appBar: !((controller.arguments?.disableAppBar).checkNull())
              ? getAppBar(context)
              : null,
          body: SafeArea(
            child: Container(
              width: NavUtils.width,
              height: NavUtils.height,
              decoration: AppStyleConfig
                  .chatPageStyle.chatPageBackgroundDecoration ?? BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(chatBgIcon, package: iconPackageName),
                  fit: BoxFit.cover,
                ),
              ),
              child: PopScope(
                canPop: false,
                onPopInvokedWithResult: (didPop, result) {
                  if (didPop) {
                    return;
                  }
                  LogMessage.d(
                      "viewInsets", "${NavUtils.defaultRouteName} : ${MediaQuery
                      .of(context)
                      .viewInsets
                      .bottom}, NavUtils.canPop : ${NavUtils.canPop}, selected : ${controller.isSelected.value},  emoji : ${controller.showEmoji.value}");
                  if (controller.showEmoji.value) {
                    controller.showEmoji(false);
                  } else if (MediaQuery
                      .of(context)
                      .viewInsets
                      .bottom > 0.0) {
                    //FocusManager.instance.primaryFocus?.unfocus();
                    controller.focusNode.unfocus();
                  } else if (!NavUtils.canPop) {
                    // controller.saveUnsentMessage();
                    NavUtils.offAllNamed(NavUtils.defaultRouteName);
                    // Navigator.pop(context);
                    // NavUtils.back();
                  } else if (controller.isSelected.value) {
                    controller.clearAllChatSelection();
                  } else {
                    NavUtils.back();
                  }
                },
                child: Column(
                  children: [
                    Obx(() {
                      return Visibility(
                          visible: controller.topic.value.topicName != null,
                          child: Container(
                              width: NavUtils.width,
                              decoration: BoxDecoration(
                                color: Theme
                                    .of(context)
                                    .primaryColor,
                                borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(8),
                                    bottomRight: Radius.circular(8)),
                              ),
                              padding: const EdgeInsets.all(2),
                              child: Text(
                                controller.topic.value.topicName.checkNull(),
                                textAlign: TextAlign.center,
                              )));
                    }),
                    Expanded(child: Stack(
                      children: [
                        Obx(() {
                          return controller.chatLoading.value
                              ? const Center(
                            child: CircularProgressIndicator(),
                          )
                              : LayoutBuilder(
                              builder: (context, constraints) {
                                debugPrint(
                                    "list view constraints $constraints");
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  controller.screenWidth(constraints.maxWidth);
                                  controller.screenHeight(constraints.maxHeight);
                                });
                                return ChatListView(
                                  chatController: controller,
                                  chatList: controller.chatList,
                                  senderChatStyle: chatStyle
                                      .senderChatBubbleStyle,
                                  receiverChatStyle: AppStyleConfig
                                      .chatPageStyle.receiverChatBubbleStyle,
                                  chatSelectedColor: AppStyleConfig
                                      .chatPageStyle.chatSelectionBgColor,
                                  notificationMessageViewStyle: AppStyleConfig
                                      .chatPageStyle
                                      .notificationMessageViewStyle,);
                              }
                          );
                        }),
                        Obx(() {
                          return Visibility(
                            visible: controller.showHideRedirectToLatest.value,
                            child: Positioned(
                              bottom: 20,
                              right: 0,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  controller.unreadCount.value != 0
                                      ? CircleAvatar(
                                    radius: 8,
                                    child: Text(
                                      returnFormattedCount(
                                          controller.unreadCount.value),
                                      style: const TextStyle(
                                          fontSize: 9, color: Colors.white),
                                    ),
                                  )
                                      : const SizedBox.shrink(),
                                  IconButton(
                                    icon: AppUtils.assetIcon(assetName:
                                      redirectLastMessage,
                                      width: 32,
                                      height: 32,
                                    ),
                                    onPressed: () {
                                      //scroll to end
                                      controller.scrollToEnd();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        Obx(() {
                          return controller.ableToScheduleMeet && !(controller.profile.isAdminBlocked.checkNull() || controller.profile.isBlocked.checkNull()||controller.isBlocked.value) && !controller.profile.isDeletedContact() ? FloatingFab(
                            fabTheme: chatStyle
                                .instantScheduleMeetStyle,
                            parentWidgetWidth: controller.screenWidth,
                            parentWidgetHeight: controller.screenHeight,
                            onFabTap: ()async{
                              await controller.setMeetBottomSheet();
                            },
                          ) : const Offstage();
                        }),
                        if (Constants.enableContactSync) ...[
                          Obx(() {
                            return !controller.profile.isItSavedContact
                                .checkNull()
                                ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(
                                  width: 8,
                                ),
                                buttonNotSavedContact(
                                    text: getTranslated("add"),
                                    onClick: () {
                                      controller.saveContact();
                                    }),
                                const SizedBox(
                                  width: 8,
                                ),
                                buttonNotSavedContact(
                                    text: controller.profile.isBlocked
                                        .checkNull()
                                        ? getTranslated("unblock")
                                        : getTranslated("block"),
                                    onClick: () {
                                      if (controller.profile.isBlocked
                                          .checkNull()) {
                                        controller.unBlockUser();
                                      } else {
                                        controller.blockUser();
                                      }
                                    }),
                                const SizedBox(
                                  width: 8,
                                ),
                              ],
                            )
                                : const SizedBox.shrink();
                          })
                        ],

                      ],
                    )),
                    Align(
                      alignment: Alignment.bottomCenter,
                      // child: Obx(() {
                        child: ChatInputField(
                          jid: controller.arguments!.chatJid.checkNull(),
                          messageTypingAreaStyle: chatStyle
                            .messageTypingAreaStyle,controller: controller,chatTaggerController: controller.messageController,
                        onChanged: (text) => controller.isTyping(text),focusNode: controller.focusNode,)
                      // }),
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }

  Widget buttonNotSavedContact(
      {required String text, required Function()? onClick}) =>
      Expanded(
        child: InkWell(
          onTap: onClick,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            padding: const EdgeInsets.all(8.0),
            color: Colors.grey,
            child: Text(
              text,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );

  selectedAppBar(BuildContext context) {
    return AppBar(
      // leadingWidth: 25,
      leading: IconButton(
        icon: chatStyle.chatUserAppBarStyle.iconClose ?? const Icon(Icons.clear),
        onPressed: () {
          controller.clearAllChatSelection();
        },
      ),
      title: Text(controller.selectedChatList.length.toString(),
        style: chatStyle.chatUserAppBarStyle.titleTextStyle,),
      actions: [
        CustomActionBarIcons(
            popupMenuThemeData: chatStyle.popupMenuThemeData,
            availableWidth: NavUtils.width / 2, // half the screen width
            actionWidth: 48, // default for IconButtons
            actions: actionBarItems(context, isSelected: true)),
      ],
    );
  }

  chatAppBar(BuildContext context) {
    return Obx(() {
      return AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 80,
        leading: InkWell(
          onTap: () {
            if (controller.showEmoji.value) {
              controller.showEmoji(false);
            } else if (NavUtils.previousRoute.isEmpty) {
              NavUtils.offAllNamed(Routes.dashboard);
            } else {
              Navigator.pop(context);
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 10,
              ),
              chatStyle.chatUserAppBarStyle.iconBack ?? const Icon(Icons.arrow_back),
              const SizedBox(
                width: 10,
              ),
              ImageNetwork(
                url: controller.profile.image.checkNull(),
                width: chatStyle.chatUserAppBarStyle
                    .profileImageSize.width,
                //35,
                height: chatStyle.chatUserAppBarStyle
                    .profileImageSize.height,
                //35,
                clipOval: true,
                isGroup: controller.profile.isGroupProfile.checkNull(),
                errorWidget: controller.profile.isGroupProfile ?? false
                    ? ClipOval(
                        child: AppUtils.assetIcon(assetName:
                    groupImg,
                    width: chatStyle.chatUserAppBarStyle
                        .profileImageSize.width, //35,
                    height: chatStyle.chatUserAppBarStyle
                        .profileImageSize.height, //35,
                    fit: BoxFit.cover,
                  ),
                )
                    : ProfileTextImage(
                  text: controller.profile.getName(),
                  /*controller.profile.name.checkNull().isEmpty
                            ? controller.profile.nickName.checkNull().isEmpty
                                ? controller.profile.mobileNumber.checkNull()
                                : controller.profile.nickName.checkNull()
                            : controller.profile.name.checkNull(),*/
                  radius: 18,
                ),
                blocked: controller.profile.isBlockedMe.checkNull() ||
                    controller.profile.isAdminBlocked.checkNull(),
                unknown: (!controller.profile.isItSavedContact.checkNull() ||
                    controller.profile.isDeletedContact()),
              ),
            ],
          ),
        ),
        title: SizedBox(
          width: (NavUtils.width) / 1.9,
          child: InkWell(
            highlightColor: Colors.transparent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  controller.profile.getName(),
                  /*controller.profile.name.checkNull().isEmpty
                      ? controller.profile.nickName.checkNull()
                      : controller.profile.name.checkNull(),*/
                  overflow: TextOverflow.fade,
                  style: chatStyle.chatUserAppBarStyle
                      .titleTextStyle,
                ),
                Obx(() {
                  return controller.groupParticipantsName.isNotEmpty
                      ? SizedBox(
                      width: NavUtils.width * 0.90,
                      height: 15,
                      child: Marquee(text: "${controller
                          .groupParticipantsName}",
                        style: chatStyle.chatUserAppBarStyle
                            .subtitleTextStyle,
                        blankSpace: 25,))
                      : controller.subtitle.isNotEmpty
                      ? Text(
                    controller.subtitle,
                    style: chatStyle.chatUserAppBarStyle
                        .subtitleTextStyle, //const TextStyle(fontSize: 12),
                    overflow: TextOverflow.fade,
                  )
                      : const SizedBox();
                })
              ],
            ),
            onTap: () {
              LogMessage.d("title clicked",
                  controller.profile.isGroupProfile.toString());
              controller.infoPage();
            },
          ),
        ),
        actions: actionBarItems(context, isSelected: false),
      );
    });
  }

  actionBarItems(BuildContext context, {bool isSelected = false}) {
    if (isSelected) {
      return [
        CustomAction(
          visibleWidget: IconButton(
            onPressed: () {
              controller.handleReplyChatMessage(controller.selectedChatList[0]);
              controller.clearChatSelection(controller.selectedChatList[0]);
            },
            icon: chatStyle.chatUserAppBarStyle.iconReply ?? AppUtils.svgIcon(icon:replyIcon,colorFilter: ColorFilter.mode(chatStyle.appBarTheme.actionsIconTheme?.color ?? Colors.black, BlendMode.srcIn),),
            tooltip: 'Reply',
          ),
          overflowWidget: Text(getTranslated("reply"),
              style: chatStyle.popupMenuThemeData.textStyle),
          showAsAction: (controller.canBeReplied.value &&
              controller.availableFeatures.value.isClearChatAvailable
                  .checkNull())
              ? ShowAsAction.always
              : ShowAsAction.gone,
          keyValue: 'Reply',
          onItemClick: () {
            controller.closeKeyBoard();
            controller.handleReplyChatMessage(controller.selectedChatList[0]);
            controller.clearChatSelection(controller.selectedChatList[0]);
          },
        ),
        CustomAction(
          visibleWidget: IconButton(
            onPressed: () {
              controller.checkBusyStatusForForward();
            },
            icon: chatStyle.chatUserAppBarStyle.iconForward ?? AppUtils.svgIcon(icon:forwardIcon,colorFilter: ColorFilter.mode(chatStyle.appBarTheme.actionsIconTheme?.color ?? Colors.black, BlendMode.srcIn)),
            tooltip: 'Forward',
          ),
          overflowWidget: Text(getTranslated("forward"),
              style: chatStyle.popupMenuThemeData.textStyle),
          showAsAction: controller.canBeForwarded.value
              ? ShowAsAction.always
              : ShowAsAction.gone,
          keyValue: 'Forward',
          onItemClick: () {
            controller.closeKeyBoard();
            controller.checkBusyStatusForForward();
          },
        ),
        CustomAction(
          visibleWidget: IconButton(
            onPressed: () {
              controller.favouriteMessage();
            },
            // icon: controller.getOptionStatus('Favourite') ? const Icon(Icons.star_border_outlined)
            // icon: controller.selectedChatList[0].isMessageStarred
            icon: chatStyle.chatUserAppBarStyle.iconFavourites ?? AppUtils.svgIcon(icon:favouriteIcon,colorFilter: ColorFilter.mode(chatStyle.appBarTheme.actionsIconTheme?.color ?? Colors.black, BlendMode.srcIn)),
            tooltip: 'Favourite',
          ),
          overflowWidget: Text(getTranslated("favourite"),
              style: chatStyle.popupMenuThemeData.textStyle),
          showAsAction: controller.canBeStarred.value
              ? ShowAsAction.always
              : ShowAsAction.gone,
          keyValue: 'favourite',
          onItemClick: () {
            controller.closeKeyBoard();
            controller.favouriteMessage();
          },
        ),
        CustomAction(
          visibleWidget: IconButton(
            onPressed: () {
              controller.favouriteMessage();
            },
            // icon: controller.getOptionStatus('Favourite') ? const Icon(Icons.star_border_outlined)
            // icon: controller.selectedChatList[0].isMessageStarred
            icon: chatStyle.chatUserAppBarStyle.iconUnFavourite ?? AppUtils.svgIcon(icon:unFavouriteIcon,colorFilter: ColorFilter.mode(chatStyle.appBarTheme.actionsIconTheme?.color ?? Colors.black, BlendMode.srcIn)),
            tooltip: 'unFavourite',
          ),
          overflowWidget: Text(getTranslated("unFavourite"),
              style: chatStyle.popupMenuThemeData.textStyle),
          showAsAction: controller.canBeUnStarred.value
              ? ShowAsAction.always
              : ShowAsAction.gone,
          keyValue: 'favourite',
          onItemClick: () {
            controller.closeKeyBoard();
            controller.favouriteMessage();
          },
        ),
        CustomAction(
          visibleWidget: IconButton(
            onPressed: () {
              controller.deleteMessages();
            },
            icon: chatStyle.chatUserAppBarStyle.iconDelete ?? AppUtils.svgIcon(icon:deleteIcon,colorFilter: ColorFilter.mode(chatStyle.appBarTheme.actionsIconTheme?.color ?? Colors.black, BlendMode.srcIn)),
            tooltip: 'Delete',
          ),
          overflowWidget: Text(getTranslated("delete"),
              style: chatStyle.popupMenuThemeData.textStyle),
          showAsAction: controller.availableFeatures.value
              .isDeleteMessageAvailable.checkNull()
              ? ShowAsAction.always
              : ShowAsAction.gone,
          keyValue: 'Delete',
          onItemClick: () {
            controller.closeKeyBoard();
            controller.deleteMessages();
          },
        ),
        CustomAction(
          visibleWidget: IconButton(
              onPressed: () {
                controller.reportChatOrMessage();
              },
              icon: chatStyle.chatUserAppBarStyle.iconReport ?? const Icon(Icons.report_problem_rounded)),
          overflowWidget: Text(getTranslated("report"),
              style: chatStyle.popupMenuThemeData.textStyle),
          showAsAction: controller.canShowReport.value
              ? ShowAsAction.never
              : ShowAsAction.gone,
          keyValue: 'Report',
          onItemClick: () {
            controller.closeKeyBoard();
            controller.reportChatOrMessage();
          },
        ),
        CustomAction(
          visibleWidget: IconButton(
            onPressed: () {
              controller.closeKeyBoard();
              controller.copyTextMessages();
            },
            icon: chatStyle.chatUserAppBarStyle.iconCopy ?? AppUtils.svgIcon(icon:
                copyIcon,
                fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(
                    chatStyle.appBarTheme.actionsIconTheme
                        ?.color ?? Colors.black, BlendMode.srcIn)
            ),
            tooltip: 'Copy',
          ),
          overflowWidget: Text(getTranslated("copy"),
              style: chatStyle.popupMenuThemeData.textStyle),
          showAsAction: controller.canBeCopied.value
              ? ShowAsAction.never
              : ShowAsAction.gone,
          keyValue: 'Copy',
          onItemClick: () {
            controller.closeKeyBoard();
            controller.copyTextMessages();
          },
        ),
        CustomAction(
          visibleWidget: IconButton(
            onPressed: () {
              controller.messageInfo();
            },
            icon: chatStyle.chatUserAppBarStyle.iconInfo ?? AppUtils.svgIcon(icon:
                infoIcon,
                fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(
                    chatStyle.appBarTheme.actionsIconTheme
                        ?.color ?? Colors.black, BlendMode.srcIn)
            ),
            tooltip: 'Message Info',
          ),
          overflowWidget: Text(getTranslated("messageInfo"),
              style: chatStyle.popupMenuThemeData.textStyle),
          showAsAction: controller.canShowInfo.value
              ? ShowAsAction.never
              : ShowAsAction.gone,
          keyValue: 'MessageInfo',
          onItemClick: () {
            controller.closeKeyBoard();
            controller.messageInfo();
          },
        ),
        CustomAction(
          visibleWidget: IconButton(
            onPressed: () {},
            icon: chatStyle.chatUserAppBarStyle.iconShare ?? AppUtils.svgIcon(icon:shareIcon,colorFilter: ColorFilter.mode(chatStyle.appBarTheme.actionsIconTheme?.color ?? Colors.black, BlendMode.srcIn)),
            tooltip: 'Share',
          ),
          overflowWidget: Text(getTranslated("share"),
              style: chatStyle.popupMenuThemeData.textStyle),
          showAsAction: controller.canBeShared.value
              ? ShowAsAction.never
              : ShowAsAction.gone,
          keyValue: 'Share',
          onItemClick: () {
            controller.closeKeyBoard();
            controller.share();
          },
        ),
        CustomAction(
          visibleWidget: IconButton(
            onPressed: () {},
            icon: chatStyle.chatUserAppBarStyle.iconEdit ?? AppUtils.svgIcon(icon:shareIcon,colorFilter: ColorFilter.mode(chatStyle.appBarTheme.actionsIconTheme?.color ?? Colors.black, BlendMode.srcIn)),
            tooltip: 'Edit Message',
          ),
          overflowWidget: Text(getTranslated("editMessage"),
              style: chatStyle.popupMenuThemeData.textStyle),
          showAsAction: controller.canEditMessage.value
              ? ShowAsAction.never
              : ShowAsAction.gone,
          keyValue: 'Edit Message',
          onItemClick: () {
            controller.closeKeyBoard();
            controller.editMessage();
          },
        ),
      ];
    } else {
      return [
        CustomActionBarIcons(
          popupMenuThemeData: chatStyle.popupMenuThemeData,
          availableWidth: NavUtils.width / 2, // half the screen width
          actionWidth: 48, // default for IconButtons
          actions: [
            CustomAction(
              visibleWidget: IconButton(
                onPressed: () {
                  controller.clearUserChatHistory();
                },
                icon: chatStyle.chatUserAppBarStyle.iconClear ?? const Icon(Icons.clear_rounded ),
              ),
              overflowWidget: Text(getTranslated("clearChat"),
                  style: chatStyle.popupMenuThemeData
                      .textStyle),
              showAsAction: controller.availableFeatures.value
                  .isClearChatAvailable.checkNull()
                  ? ShowAsAction.never
                  : ShowAsAction.gone,
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
                  controller.reportChatOrMessage();
                },
                icon: chatStyle.chatUserAppBarStyle.iconReport ?? const Icon(Icons.report_problem_rounded),
              ),
              overflowWidget: Text(getTranslated("report"),
                  style: chatStyle.popupMenuThemeData
                      .textStyle),
              showAsAction: ShowAsAction.never,
              keyValue: 'Report',
              onItemClick: () {
                controller.closeKeyBoard();
                controller.reportChatOrMessage();
              },
            ),
            controller.isBlocked.value
                ? CustomAction(
              visibleWidget: IconButton(
                onPressed: () {
                  controller.unBlockUser();
                },
                icon: chatStyle.chatUserAppBarStyle.iconUnBlock ?? const Icon(Icons.block),
              ),
              overflowWidget: Text(getTranslated("unblock"),
                  style: chatStyle.popupMenuThemeData
                      .textStyle),
              showAsAction: ShowAsAction.never,
              keyValue: 'Unblock',
              onItemClick: () {
                debugPrint('onItemClick unblock');
                controller.unBlockUser();
              },
            )
                : CustomAction(
              visibleWidget: IconButton(
                onPressed: () {
                  controller.blockUser();
                },
                icon: chatStyle.chatUserAppBarStyle.iconBlock ?? const Icon(Icons.block),
              ),
              overflowWidget: Text(getTranslated("block"),
                  style: chatStyle.popupMenuThemeData
                      .textStyle),
              showAsAction: controller.profile.isGroupProfile ?? false
                  ? ShowAsAction.gone
                  : ShowAsAction.never,
              keyValue: 'Block',
              onItemClick: () {
                controller.closeKeyBoard();
                controller.blockUser();
              },
            ),
            CustomAction(
              visibleWidget: IconButton(
                onPressed: () {},
                icon: chatStyle.chatUserAppBarStyle.iconSearch ?? const Icon(Icons.search),
              ),
              overflowWidget: Text(getTranslated("search"),
                  style: chatStyle.popupMenuThemeData
                      .textStyle),
              showAsAction: ShowAsAction.never,
              keyValue: 'Search',
              onItemClick: () {
                controller.closeKeyBoard();
                controller.gotoSearch();
              },
            ),
            CustomAction(
              visibleWidget: IconButton(
                onPressed: () {},
                icon: chatStyle.chatUserAppBarStyle.iconEmail ?? const Icon(Icons.email_outlined),
              ),
              overflowWidget: GestureDetector(
                onTap: () {
                  controller.closeKeyBoard();
                  controller.exportChat();
                },
                child: Text(getTranslated("emailChat"),
                    style: chatStyle.popupMenuThemeData
                        .textStyle),
              ),
              showAsAction: ShowAsAction.never,
              keyValue: 'EmailChat',
              onItemClick: () {
                controller.closeKeyBoard();
                controller.exportChat();
              },
            ),
            CustomAction(
              visibleWidget: IconButton(
                onPressed: () {},
                icon: chatStyle.chatUserAppBarStyle.iconShortCut ?? const Icon(Icons.shortcut),
              ),
              overflowWidget: Text(getTranslated("addChatShortcut"),
                  style: chatStyle.popupMenuThemeData
                      .textStyle),
              showAsAction: ShowAsAction.gone,
              keyValue: 'Shortcut',
              onItemClick: () {
                controller.closeKeyBoard();
              },
            ),
            CustomAction(
              visibleWidget: IconButton(
                onPressed: controller.ableToCall ? () {
                  controller.makeVideoCall();
                } : null,
                  icon: chatStyle.chatUserAppBarStyle.iconVideoCall ?? AppUtils.svgIcon(icon:videoCallIcon,colorFilter: ColorFilter.mode(chatStyle.appBarTheme.actionsIconTheme?.color ?? Colors.black, BlendMode.srcIn)),
              ),
                overflowWidget: Text(getTranslated("videoCall"),style:chatStyle.popupMenuThemeData.textStyle),
                showAsAction: controller.isVideoCallAvailable  && (controller.arguments?.enableCalls).checkNull() ? ShowAsAction.always : ShowAsAction.gone,
              keyValue: 'Video Call',
              onItemClick: controller.ableToCall ? () {
                controller.makeVideoCall();
              } : null,
            ),
            CustomAction(
              visibleWidget: IconButton(
                onPressed: controller.ableToCall ? () {
                  controller.makeVoiceCall();
                } : null,
                  icon: chatStyle.chatUserAppBarStyle.iconAudioCall ?? AppUtils.svgIcon(icon:audioCallIcon,colorFilter: ColorFilter.mode(chatStyle.appBarTheme.actionsIconTheme?.color ?? Colors.black, BlendMode.srcIn)),
              ),
                overflowWidget: Text(getTranslated("audioCall"),style:chatStyle.popupMenuThemeData.textStyle),
                showAsAction: controller.isAudioCallAvailable  && (controller.arguments?.enableCalls).checkNull() ? ShowAsAction.always : ShowAsAction.gone,
              keyValue: 'Audio Call',
              onItemClick: controller.ableToCall ? () {
                controller.makeVoiceCall();
              } : null,
            ),
          ],
        ),
      ];
    }
  }

  getAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(55.0),
      child:
      Obx(() {
        return Container(
          child: controller.isSelected.value
              ? selectedAppBar(context)
              : chatAppBar(context),
          color: chatStyle.appBarTheme.backgroundColor,
        );
      }),
    );
  }
}