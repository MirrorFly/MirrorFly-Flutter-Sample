
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:grouped_list/grouped_list.dart';
// import 'package:marquee/marquee.dart';
import '../../../app_style_config.dart';
import '../../../common/app_localizations.dart';
import '../../../common/widgets.dart';
import '../../../data/helper.dart';
import '../../../extensions/extensions.dart';
import '../../../modules/chat/widgets/floating_fab.dart';
import 'package:mirrorfly_plugin/logmessage.dart';

import '../../../call_modules/ripple_animation_view.dart';
import '../../../common/constants.dart';
import '../../../data/utils.dart';
import '../../../model/arguments.dart';
import '../../../routes/route_settings.dart';
import '../../../widgets/custom_action_bar_icons.dart';
import '../../../widgets/lottie_animation.dart';
import '../../../widgets/marquee_text.dart';
import '../controllers/chat_controller.dart';
import '../widgets/reply_message_widgets.dart';
import 'chat_list_view.dart';

class ChatView extends NavViewStateful<ChatController> {
  ChatView({Key? key, this.chatViewArguments}) : super(key: key, tag: chatViewArguments?.chatJid);
  final ChatViewArguments? chatViewArguments;
  @override
  ChatController createController({String? tag}) {
    debugPrint("ChatView createController");
    final arguments = chatViewArguments ?? NavUtils.arguments as ChatViewArguments;
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
        appBarTheme: AppStyleConfig.chatPageStyle.appBarTheme
      ),
      child: Scaffold(
          appBar: !((controller.arguments?.disableAppBar).checkNull()) ? getAppBar(context) : null,
          body: SafeArea(
            child: Container(
              width: NavUtils.width,
              height: NavUtils.height,
              decoration: BoxDecoration(
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
                  LogMessage.d("viewInsets", "${NavUtils.defaultRouteName} : ${MediaQuery.of(context).viewInsets.bottom}");
                  if (controller.showEmoji.value) {
                    controller.showEmoji(false);
                  } else if (MediaQuery.of(context).viewInsets.bottom > 0.0) {
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
                                color: Theme.of(context).primaryColor,
                                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
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
                                  debugPrint("list view constraints $constraints");
                                  controller.screenWidth(constraints.maxWidth);
                                  controller.screenHeight(constraints.maxHeight);
                                  return ChatListView(chatController: controller, chatList: controller.chatList,senderChatStyle: AppStyleConfig.chatPageStyle.senderChatBubbleStyle,receiverChatStyle: AppStyleConfig.chatPageStyle.receiverChatBubbleStyle,chatSelectedColor: AppStyleConfig.chatPageStyle.chatSelectionBgColor,
                                                            notificationMessageViewStyle: AppStyleConfig.chatPageStyle.notificationMessageViewStyle,);
                                }
                              );
                        }),
                        FloatingFab(
                          fabTheme: AppStyleConfig.chatPageStyle.instantScheduleMeetStyle.meetFabStyle,
                          parentWidgetWidth: controller.screenWidth,
                          parentWidgetHeight: controller.screenHeight,
                          onFabTap: (){
                            controller.showMeetBottomSheet(AppStyleConfig.chatPageStyle.instantScheduleMeetStyle.meetBottomSheetStyle);
                          },
                        ),
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
                                      returnFormattedCount(controller.unreadCount.value),
                                      style: const TextStyle(fontSize: 9, color: Colors.white),
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
                        if (Constants.enableContactSync) ...[
                          Obx(() {
                            return !controller.profile.isItSavedContact.checkNull()
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
                                    text: controller.profile.isBlocked.checkNull() ? getTranslated("unblock") : getTranslated("block"),
                                    onClick: () {
                                      if (controller.profile.isBlocked.checkNull()) {
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
                      child: Obx(() {
                        return Container(
                          color: AppStyleConfig.chatPageStyle.messageTypingAreaStyle.bgColor,//Colors.white,
                          child: controller.isBlocked.value
                              ? userBlocked(context)
                              : controller.isMemberOfGroup
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Obx(() {
                                          if (controller.isReplying.value) {
                                            return ReplyingMessageHeader(
                                              chatMessage: controller.replyChatMessage,
                                              onCancel: () => controller.cancelReplyMessage(),
                                              onClick: () {
                                                controller.navigateToMessage(controller.replyChatMessage);
                                              },
                                              replyBgColor: AppStyleConfig.chatPageStyle.messageTypingAreaStyle.replyBgColor,
                                            );
                                          } else {
                                            return const Offstage();
                                          }
                                        }),
                                        Divider(
                                          height: 1,
                                          thickness: 0.29,
                                          color: AppStyleConfig.chatPageStyle.messageTypingAreaStyle.dividerColor//textBlackColor,
                                        ),
                                        /*const SizedBox(
                                          height: 10,
                                        ),*/
                                        IntrinsicHeight(
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: [
                                              Flexible(
                                                child: Container(
                                                  margin: const EdgeInsets.all(10),
                                                  width: double.infinity,
                                                  decoration: AppStyleConfig.chatPageStyle.messageTypingAreaStyle.decoration,
                                                  // decoration: BoxDecoration(
                                                  //   border: Border.all(
                                                  //     color: textColor,
                                                  //   ),
                                                  //   borderRadius: const BorderRadius.all(Radius.circular(40)),
                                                  //   color: Colors.white,
                                                  // ),
                                                  child: Obx(() {
                                                    return messageTypingView(context);
                                                  }),
                                                ),
                                              ),
                                              Obx(() {
                                                return controller.isUserTyping.value || controller.isAudioRecording.value == Constants.audioRecordDone
                                                    ? InkWell(
                                                        onTap: () {
                                                          controller.isAudioRecording.value == Constants.audioRecordDone
                                                              ? controller.sendRecordedAudioMessage()
                                                              : controller.sendMessage(controller.profile);
                                                        },
                                                        child: AppUtils.svgIcon(icon:sendIcon,colorFilter: ColorFilter.mode( AppStyleConfig.chatPageStyle.messageTypingAreaStyle.sentIconColor, BlendMode.srcIn)))
                                                    : const Offstage();
                                              }),
                                              Obx(() {
                                                return controller.isAudioRecording.value == Constants.audioRecording
                                                    ? InkWell(
                                                        onTap: () {
                                                          controller.stopRecording();
                                                        },
                                                  child: RippleWidget(
                                                    size: 50,
                                                    rippleColor: AppStyleConfig.chatPageStyle.messageTypingAreaStyle.rippleColor,
                                                    child: CircleAvatar(
                                                      backgroundColor: AppStyleConfig.chatPageStyle.messageTypingAreaStyle.audioRecordIcon.bgColor,//const Color(0xff3276E2),
                                                      radius: 48/2,
                                                      child: AppUtils.svgIcon(icon: audioMic,
                                                        colorFilter: ColorFilter.mode(AppStyleConfig.chatPageStyle.messageTypingAreaStyle.audioRecordIcon.iconColor, BlendMode.srcIn),
                                                      ),),
                                                  ),
                                                        /*child: const Padding(
                                                          padding: EdgeInsets.only(bottom: 8.0),
                                                          child: LottieAnimation(
                                                            lottieJson: audioJson1,
                                                            showRepeat: true,
                                                            width: 54,
                                                            height: 54,
                                                          ),
                                                        )*/
                                                )
                                                    : const Offstage();
                                              }),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                            ],
                                          ),
                                        ),
                                        controller.emojiLayout(textEditingController: controller.messageController, sendTypingStatus: true),
                                      ],
                                    )
                                  : !controller.availableFeatures.value.isGroupChatAvailable.checkNull()
                                      ? featureNotAvailable(context)
                                      : userNoLonger(context),
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

  Widget buttonNotSavedContact({required String text, required Function()? onClick}) => Expanded(
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

  messageTypingView(BuildContext context) {
    return Row(
      children: <Widget>[
        if(controller.isAudioRecording.value == Constants.audioRecording || controller.isAudioRecording.value == Constants.audioRecordDone)...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(controller.timerInit.value, style: AppStyleConfig.chatPageStyle.messageTypingAreaStyle.audioRecordingViewStyle.durationTextStyle),
            )
        ],
        if(controller.isAudioRecording.value == Constants.audioRecordInitial)...[
            IconButton(onPressed: (){
          controller.showHideEmoji();
        }, icon: controller.showEmoji.value
            ? Icon(
          Icons.keyboard,
          color: AppStyleConfig.chatPageStyle.messageTypingAreaStyle.emojiIconColor,
        )
            : AppUtils.svgIcon(icon:smileIcon,colorFilter: ColorFilter.mode(AppStyleConfig.chatPageStyle.messageTypingAreaStyle.emojiIconColor, BlendMode.srcIn),))
        ],
        if(controller.isAudioRecording.value == Constants.audioRecordDelete)...[
          const Padding(
                padding: EdgeInsets.all(12.0),
                child: LottieAnimation(
                  lottieJson: deleteDustbin,
                  showRepeat: false,
                  width: 24,
                  height: 24,
                ),
              )
         ],
        /*const SizedBox(
          width: 10,
        ),*/
        if(controller.isAudioRecording.value == Constants.audioRecording)...[
            Expanded(
                child: Dismissible(
                  key: UniqueKey(),
                  dismissThresholds: const {
                    DismissDirection.endToStart: 0.1,
                  },
                  confirmDismiss: (DismissDirection direction) async {
                    if (direction == DismissDirection.endToStart) {
                      controller.cancelRecording();
                      return true;
                    }
                    return false;
                  },
                  onUpdate: (details) {
                    LogMessage.d("dismiss", details.progress.toString());
                    if (details.progress > 0.5) {
                      controller.cancelRecording();
                    }
                  },
                  direction: DismissDirection.endToStart,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: SizedBox(
                        height: 50, child: Align(alignment: Alignment.centerRight, child: Text(getTranslated("slideToCancel"), textAlign: TextAlign.end,style: AppStyleConfig.chatPageStyle.messageTypingAreaStyle.audioRecordingViewStyle.cancelTextStyle,))),
                  ),
                ),
              )
        ],
        if(controller.isAudioRecording.value == Constants.audioRecordDone)...[
            Expanded(
                child: InkWell(
                  onTap: () {
                    controller.deleteRecording();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(17.0),
                    child: Text(
                      getTranslated("cancel"),
                      textAlign: TextAlign.end,
                      style: AppStyleConfig.chatPageStyle.messageTypingAreaStyle.audioRecordingViewStyle.cancelTextStyle.copyWith(color: Colors.red),
                    ),
                  ),
                ),
              )
        ],
        if(controller.isAudioRecording.value == Constants.audioRecordInitial)...[
            Expanded(
                child: TextField(
                  onChanged: (text) {
                    controller.isTyping(text);
                  },
                  style: AppStyleConfig.chatPageStyle.messageTypingAreaStyle.textFieldStyle.editTextStyle,//const TextStyle(fontWeight: FontWeight.w400),
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                  maxLines: 5,
                  enabled: controller.isAudioRecording.value == Constants.audioRecordInitial ? true : false,
                  controller: controller.messageController,
                  focusNode: controller.focusNode,
                  decoration: InputDecoration(hintText: getTranslated("startTypingPlaceholder"), border: InputBorder.none,hintStyle:  AppStyleConfig.chatPageStyle.messageTypingAreaStyle.textFieldStyle.editTextHintStyle),
                ),
              )
        ],
        if(controller.isAudioRecording.value == Constants.audioRecordInitial && controller.availableFeatures.value.isAttachmentAvailable.checkNull())...[
            IconButton(
                onPressed: () {
                  controller.showAttachmentsView(context);
                },
                icon: AppUtils.svgIcon(icon: attachIcon,colorFilter: ColorFilter.mode(AppStyleConfig.chatPageStyle.messageTypingAreaStyle.emojiIconColor, BlendMode.srcIn),),
              )
        ],
        if(controller.isAudioRecording.value == Constants.audioRecordInitial &&
                controller.availableFeatures.value.isAudioAttachmentAvailable.checkNull())...[
            IconButton(
                onPressed: () {
                  controller.startRecording();
                },
                icon: AppUtils.svgIcon(icon: audioMic,colorFilter: ColorFilter.mode(AppStyleConfig.chatPageStyle.messageTypingAreaStyle.emojiIconColor, BlendMode.srcIn),),
              )
        ],
        /*const SizedBox(
          width: 5,
        ),*/
      ],
    );
  }

  Widget userBlocked(BuildContext context) {
    return Column(
      children: [
        Divider(
          height: 1,
          thickness: 0.29,
          color: AppStyleConfig.chatPageStyle.messageTypingAreaStyle.dividerColor,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 15.0, bottom: 15.0, left: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                getTranslated("youHaveBlocked"),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppStyleConfig.chatPageStyle.messageTypingAreaStyle.textFieldStyle.editTextStyle,
                // style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(
                width: 5,
              ),
              Flexible(
                child: Text(
                  getName(controller.profile),
                  //controller.profile.name.checkNull(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyleConfig.chatPageStyle.messageTypingAreaStyle.textFieldStyle.editTextStyle,
                  // style: const TextStyle(fontSize: 15),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              InkWell(
                child: Text(
                  getTranslated("unblock"),
                  style: AppStyleConfig.chatPageStyle.messageTypingAreaStyle.textFieldStyle.editTextStyle.copyWith(color: Colors.blue),
                  // style: const TextStyle(decoration: TextDecoration.underline, color: Colors.blue),
                ),
                onTap: () => controller.unBlockUser(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget userNoLonger(BuildContext context) {
    return Column(
      children: [
        Divider(
          height: 1,
          thickness: 0.29,
          color: AppStyleConfig.chatPageStyle.messageTypingAreaStyle.dividerColor//textBlackColor,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
          child: Text(
            getTranslated("youCantSentMessageNoLonger"),
            style: AppStyleConfig.chatPageStyle.messageTypingAreaStyle.textFieldStyle.editTextHintStyle,
            // style: const TextStyle(
            //   fontSize: 15,
            // ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget featureNotAvailable(BuildContext context) {
    return Column(
      children: [
        Divider(
          height: 1,
          thickness: 0.29,
          color: AppStyleConfig.chatPageStyle.messageTypingAreaStyle.dividerColor//textBlackColor,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
          child: Text(
            getTranslated("featureNotAvailable"),
            style: AppStyleConfig.chatPageStyle.messageTypingAreaStyle.textFieldStyle.editTextHintStyle,
            // style: const TextStyle(
            //   fontSize: 15,
            // ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  selectedAppBar(BuildContext context) {
    return AppBar(
      // leadingWidth: 25,
      leading: IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          controller.clearAllChatSelection();
        },
      ),
      title: Text(controller.selectedChatList.length.toString(),style: AppStyleConfig.chatPageStyle.chatUserAppBarStyle.titleTextStyle,),
      actions: [
        CustomActionBarIcons(
          popupMenuThemeData: AppStyleConfig.chatPageStyle.popupMenuThemeData,
            availableWidth: NavUtils.width / 2, // half the screen width
            actionWidth: 48, // default for IconButtons
            actions: actionBarItems(context,isSelected: true)),
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
              const Icon(Icons.arrow_back),
              const SizedBox(
                width: 10,
              ),
              ImageNetwork(
                url: controller.profile.image.checkNull(),
                width: AppStyleConfig.chatPageStyle.chatUserAppBarStyle.profileImageSize.width,//35,
                height: AppStyleConfig.chatPageStyle.chatUserAppBarStyle.profileImageSize.height,//35,
                clipOval: true,
                isGroup: controller.profile.isGroupProfile.checkNull(),
                errorWidget: controller.profile.isGroupProfile ?? false
                    ? ClipOval(
                        child: AppUtils.assetIcon(assetName:
                          groupImg,
                          width: AppStyleConfig.chatPageStyle.chatUserAppBarStyle.profileImageSize.width,//35,
                          height: AppStyleConfig.chatPageStyle.chatUserAppBarStyle.profileImageSize.height,//35,
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
                blocked: controller.profile.isBlockedMe.checkNull() || controller.profile.isAdminBlocked.checkNull(),
                unknown: (!controller.profile.isItSavedContact.checkNull() || controller.profile.isDeletedContact()),
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
                  style: AppStyleConfig.chatPageStyle.chatUserAppBarStyle.titleTextStyle,
                ),
                Obx(() {
                  return controller.groupParticipantsName.isNotEmpty
                      ? SizedBox(
                          width: NavUtils.width * 0.90,
                          height: 15,
                          child: Marquee(text: "${controller.groupParticipantsName}", style: AppStyleConfig.chatPageStyle.chatUserAppBarStyle.subtitleTextStyle, blankSpace: 25,))
                      : controller.subtitle.isNotEmpty
                          ? Text(
                              controller.subtitle,
                              style: AppStyleConfig.chatPageStyle.chatUserAppBarStyle.subtitleTextStyle,//const TextStyle(fontSize: 12),
                              overflow: TextOverflow.fade,
                            )
                          : const SizedBox();
                })
              ],
            ),
            onTap: () {
              LogMessage.d("title clicked", controller.profile.isGroupProfile.toString());
              controller.infoPage();
            },
          ),
        ),
        actions: actionBarItems(context,isSelected: false),
      );
    });
  }

  actionBarItems(BuildContext context, {bool isSelected = false}){
      if(isSelected){
        return [
        CustomAction(
          visibleWidget: IconButton(
            onPressed: () {
              controller.handleReplyChatMessage(controller.selectedChatList[0]);
              controller.clearChatSelection(controller.selectedChatList[0]);
            },
            icon: AppUtils.svgIcon(icon:replyIcon,colorFilter: ColorFilter.mode(AppStyleConfig.chatPageStyle.appBarTheme.actionsIconTheme?.color ?? Colors.black, BlendMode.srcIn),),
            tooltip: 'Reply',
          ),
          overflowWidget: Text(getTranslated("reply"),style:AppStyleConfig.chatPageStyle.popupMenuThemeData.textStyle),
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
            icon: AppUtils.svgIcon(icon:forwardIcon,colorFilter: ColorFilter.mode(AppStyleConfig.chatPageStyle.appBarTheme.actionsIconTheme?.color ?? Colors.black, BlendMode.srcIn)),
            tooltip: 'Forward',
          ),
          overflowWidget: Text(getTranslated("forward"),style:AppStyleConfig.chatPageStyle.popupMenuThemeData.textStyle),
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
            icon: AppUtils.svgIcon(icon:favouriteIcon,colorFilter: ColorFilter.mode(AppStyleConfig.chatPageStyle.appBarTheme.actionsIconTheme?.color ?? Colors.black, BlendMode.srcIn)),
            tooltip: 'Favourite',
          ),
          overflowWidget: Text(getTranslated("favourite"),style:AppStyleConfig.chatPageStyle.popupMenuThemeData.textStyle),
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
            icon: AppUtils.svgIcon(icon:unFavouriteIcon,colorFilter: ColorFilter.mode(AppStyleConfig.chatPageStyle.appBarTheme.actionsIconTheme?.color ?? Colors.black, BlendMode.srcIn)),
            tooltip: 'unFavourite',
          ),
          overflowWidget: Text(getTranslated("unFavourite"),style:AppStyleConfig.chatPageStyle.popupMenuThemeData.textStyle),
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
            icon: AppUtils.svgIcon(icon:deleteIcon,colorFilter: ColorFilter.mode(AppStyleConfig.chatPageStyle.appBarTheme.actionsIconTheme?.color ?? Colors.black, BlendMode.srcIn)),
            tooltip: 'Delete',
          ),
          overflowWidget: Text(getTranslated("delete"),style:AppStyleConfig.chatPageStyle.popupMenuThemeData.textStyle),
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
              icon: const Icon(Icons.report_problem_rounded)),
          overflowWidget: Text(getTranslated("report"),style:AppStyleConfig.chatPageStyle.popupMenuThemeData.textStyle),
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
            icon: AppUtils.svgIcon(icon:
              copyIcon,
              fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(AppStyleConfig.chatPageStyle.appBarTheme.actionsIconTheme?.color ?? Colors.black, BlendMode.srcIn)
            ),
            tooltip: 'Copy',
          ),
          overflowWidget: Text(getTranslated("copy"),style:AppStyleConfig.chatPageStyle.popupMenuThemeData.textStyle),
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
            icon: AppUtils.svgIcon(icon:
              infoIcon,
              fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(AppStyleConfig.chatPageStyle.appBarTheme.actionsIconTheme?.color ?? Colors.black, BlendMode.srcIn)
            ),
            tooltip: 'Message Info',
          ),
          overflowWidget: Text(getTranslated("messageInfo"),style:AppStyleConfig.chatPageStyle.popupMenuThemeData.textStyle),
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
            icon: AppUtils.svgIcon(icon:shareIcon,colorFilter: ColorFilter.mode(AppStyleConfig.chatPageStyle.appBarTheme.actionsIconTheme?.color ?? Colors.black, BlendMode.srcIn)),
            tooltip: 'Share',
          ),
          overflowWidget: Text(getTranslated("share"),style:AppStyleConfig.chatPageStyle.popupMenuThemeData.textStyle),
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
            icon: AppUtils.svgIcon(icon:shareIcon,colorFilter: ColorFilter.mode(AppStyleConfig.chatPageStyle.appBarTheme.actionsIconTheme?.color ?? Colors.black, BlendMode.srcIn)),
            tooltip: 'Edit Message',
          ),
          overflowWidget: Text(getTranslated("editMessage"),style:AppStyleConfig.chatPageStyle.popupMenuThemeData.textStyle),
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
      }else{
        return [
          CustomActionBarIcons(
            popupMenuThemeData: AppStyleConfig.chatPageStyle.popupMenuThemeData,
            availableWidth: NavUtils.width / 2, // half the screen width
            actionWidth: 48, // default for IconButtons
            actions: [
              CustomAction(
                overflowWidget: Text(getTranslated("clearChat"),style:AppStyleConfig.chatPageStyle.popupMenuThemeData.textStyle),
                showAsAction: controller.availableFeatures.value.isClearChatAvailable.checkNull() ? ShowAsAction.never : ShowAsAction.gone,
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
                  icon: const Icon(Icons.report_problem_rounded),
                ),
                overflowWidget: Text(getTranslated("report"),style:AppStyleConfig.chatPageStyle.popupMenuThemeData.textStyle),
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
                  icon: const Icon(Icons.block),
                ),
                overflowWidget: Text(getTranslated("unblock"),style:AppStyleConfig.chatPageStyle.popupMenuThemeData.textStyle),
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
                  icon: const Icon(Icons.block),
                ),
                overflowWidget: Text(getTranslated("block"),style:AppStyleConfig.chatPageStyle.popupMenuThemeData.textStyle),
                showAsAction: controller.profile.isGroupProfile ?? false ? ShowAsAction.gone : ShowAsAction.never,
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
                overflowWidget: Text(getTranslated("search"),style:AppStyleConfig.chatPageStyle.popupMenuThemeData.textStyle),
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
                  icon: const Icon(Icons.email_outlined),
                ),
                overflowWidget: GestureDetector(
                  onTap: () {
                    controller.closeKeyBoard();
                    controller.exportChat();
                  },
                  child: Text(getTranslated("emailChat"),style:AppStyleConfig.chatPageStyle.popupMenuThemeData.textStyle),
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
                  icon: const Icon(Icons.shortcut),
                ),
                overflowWidget: Text(getTranslated("addChatShortcut"),style:AppStyleConfig.chatPageStyle.popupMenuThemeData.textStyle),
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
                  icon: AppUtils.svgIcon(icon:videoCallIcon,colorFilter: ColorFilter.mode(AppStyleConfig.chatPageStyle.appBarTheme.actionsIconTheme?.color ?? Colors.black, BlendMode.srcIn)),
                ),
                overflowWidget: Text(getTranslated("videoCall"),style:AppStyleConfig.chatPageStyle.popupMenuThemeData.textStyle),
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
                  icon: AppUtils.svgIcon(icon:audioCallIcon,colorFilter: ColorFilter.mode(AppStyleConfig.chatPageStyle.appBarTheme.actionsIconTheme?.color ?? Colors.black, BlendMode.srcIn)),
                ),
                overflowWidget: Text(getTranslated("audioCall"),style:AppStyleConfig.chatPageStyle.popupMenuThemeData.textStyle),
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
          child: controller.isSelected.value ? selectedAppBar(context) : chatAppBar(context),
          color: AppStyleConfig.chatPageStyle.appBarTheme.backgroundColor,
        );
      }),
    );
  }
}

