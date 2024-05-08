
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';

// import 'package:grouped_list/grouped_list.dart';
import 'package:marquee/marquee.dart';
import 'package:mirror_fly_demo/app/common/widgets.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/common/extensions.dart';
import 'package:mirror_fly_demo/app/routes/app_pages.dart';
import 'package:mirrorfly_plugin/logmessage.dart';

import '../../../common/constants.dart';
import '../../../widgets/custom_action_bar_icons.dart';
import '../../../widgets/lottie_animation.dart';
import '../chat_widgets.dart';
import '../controllers/chat_controller.dart';
import 'chat_list_view.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    LogMessage.d("chatview build", "${Get.height}");
    return Scaffold(
        appBar: getAppBar(),
        body: SafeArea(
          child: Container(
            width: Get.width,
            height: Get.height,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/logos/chat_bg.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: PopScope(
              canPop: false,
              onPopInvoked: (didPop) {
                if (didPop) {
                  return;
                }
                LogMessage.d("viewInsets", MediaQuery.of(context).viewInsets.bottom.toString());
                if (controller.showEmoji.value) {
                  controller.showEmoji(false);
                } else if (MediaQuery.of(context).viewInsets.bottom > 0.0) {
                  //FocusManager.instance.primaryFocus?.unfocus();
                  controller.focusNode.unfocus();
                } else if (controller.nJid != null) {
                  // controller.saveUnsentMessage();
                  Get.offAllNamed(Routes.dashboard);
                  Get.back();
                } else if (controller.isSelected.value) {
                  controller.clearAllChatSelection();
                } else {
                  Get.back();
                }
              },
              child: Stack(
                children: [
                  Column(
                    children: [
                      Obx(() {
                        return Visibility(
                            visible: controller.topic.value.topicName != null,
                            child: Container(
                                width: Get.width,
                                decoration: const BoxDecoration(
                                  color: Color(0xffff9f00),
                                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                                ),
                                padding: const EdgeInsets.all(2),
                                child: Text(
                                  controller.topic.value.topicName.checkNull(),
                                  textAlign: TextAlign.center,
                                )));
                      }),
                      Expanded(child: Obx(() {
                        return controller.chatLoading.value
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : ChatListView(chatController: controller, chatList: controller.chatList);
                      })),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Obx(() {
                          return Container(
                            color: Colors.white,
                            child: controller.isBlocked.value
                                ? userBlocked()
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
                                              );
                                            } else {
                                              return const SizedBox.shrink();
                                            }
                                          }),
                                          const Divider(
                                            height: 1,
                                            thickness: 0.29,
                                            color: textBlackColor,
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          IntrinsicHeight(
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                              children: [
                                                Flexible(
                                                  child: Container(
                                                    padding: const EdgeInsets.only(left: 10),
                                                    margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: textColor,
                                                      ),
                                                      borderRadius: const BorderRadius.all(Radius.circular(40)),
                                                      color: Colors.white,
                                                    ),
                                                    child: Obx(() {
                                                      return messageTypingView(context);
                                                    }),
                                                  ),
                                                ),
                                                Obx(() {
                                                  return controller.isUserTyping.value
                                                      ? InkWell(
                                                          onTap: () {
                                                            controller.isAudioRecording.value == Constants.audioRecordDone
                                                                ? controller.sendRecordedAudioMessage()
                                                                : controller.sendMessage(controller.profile);
                                                          },
                                                          child: Padding(
                                                            padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8),
                                                            child: SvgPicture.asset(sendIcon),
                                                          ))
                                                      : const SizedBox.shrink();
                                                }),
                                                Obx(() {
                                                  return controller.isAudioRecording.value == Constants.audioRecording
                                                      ? InkWell(
                                                          onTap: () {
                                                            controller.stopRecording();
                                                          },
                                                          child: const Padding(
                                                            padding: EdgeInsets.only(bottom: 8.0),
                                                            child: LottieAnimation(
                                                              lottieJson: audioJson1,
                                                              showRepeat: true,
                                                              width: 54,
                                                              height: 54,
                                                            ),
                                                          ))
                                                      : const SizedBox.shrink();
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
                                        ? featureNotAvailable()
                                        : userNoLonger(),
                          );
                        }),
                      ),
                    ],
                  ),
                  Obx(() {
                    return Visibility(
                      visible: controller.showHideRedirectToLatest.value,
                      child: Positioned(
                        bottom: controller.isReplying.value ? 160 : 100,
                        right: 0,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            controller.unreadCount.value != 0
                                ? CircleAvatar(
                                    radius: 8,
                                    child: Text(
                                      returnFormattedCount(controller.unreadCount.value),
                                      style: const TextStyle(fontSize: 9, color: Colors.white, fontFamily: 'sf_ui'),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                            IconButton(
                              icon: Image.asset(
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
                                    text: 'Add',
                                    onClick: () {
                                      controller.saveContact();
                                    }),
                                const SizedBox(
                                  width: 8,
                                ),
                                buttonNotSavedContact(
                                    text: controller.profile.isBlocked.checkNull() ? 'UnBlock' : 'Block',
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
              ),
            ),
          ),
        ));
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
        controller.isAudioRecording.value == Constants.audioRecording || controller.isAudioRecording.value == Constants.audioRecordDone
            ? Text(controller.timerInit.value, style: const TextStyle(color: buttonBgColor))
            : const SizedBox.shrink(),
        controller.isAudioRecording.value == Constants.audioRecordInitial
            ? InkWell(
                onTap: () {
                  controller.showHideEmoji(context);
                },
                child: controller.showEmoji.value
                    ? const Icon(
                        Icons.keyboard,
                        color: iconColor,
                      )
                    : SvgPicture.asset(smileIcon))
            : const SizedBox.shrink(),
        controller.isAudioRecording.value == Constants.audioRecordDelete
            ? const Padding(
                padding: EdgeInsets.all(13.0),
                child: LottieAnimation(
                  lottieJson: deleteDustbin,
                  showRepeat: false,
                  width: 25,
                  height: 25,
                ),
              )
            : const SizedBox.shrink(),
        const SizedBox(
          width: 10,
        ),
        controller.isAudioRecording.value == Constants.audioRecording
            ? Expanded(
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
                  child: const Padding(
                    padding: EdgeInsets.only(right: 15.0),
                    child: SizedBox(
                        height: 50, child: Align(alignment: Alignment.centerRight, child: Text('< Slide to Cancel', textAlign: TextAlign.end))),
                  ),
                ),
              )
            : const SizedBox.shrink(),
        controller.isAudioRecording.value == Constants.audioRecordDone
            ? Expanded(
                child: InkWell(
                  onTap: () {
                    controller.deleteRecording();
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(17.0),
                    child: Text(
                      'Cancel',
                      textAlign: TextAlign.end,
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
        controller.isAudioRecording.value == Constants.audioRecordInitial
            ? Expanded(
                child: TextField(
                  onChanged: (text) {
                    controller.isTyping(text);
                  },
                  style: const TextStyle(fontWeight: FontWeight.w400),
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                  maxLines: 5,
                  enabled: controller.isAudioRecording.value == Constants.audioRecordInitial ? true : false,
                  controller: controller.messageController,
                  focusNode: controller.focusNode,
                  decoration: const InputDecoration(hintText: "Start Typing...", border: InputBorder.none),
                ),
              )
            : const SizedBox.shrink(),
        (controller.isAudioRecording.value == Constants.audioRecordInitial && controller.availableFeatures.value.isAttachmentAvailable.checkNull())
            ? IconButton(
                onPressed: () {
                  controller.showAttachmentsView(context);
                },
                icon: SvgPicture.asset('assets/logos/attach.svg'),
              )
            : const SizedBox.shrink(),
        (controller.isAudioRecording.value == Constants.audioRecordInitial &&
                controller.availableFeatures.value.isAudioAttachmentAvailable.checkNull())
            ? IconButton(
                onPressed: () {
                  controller.startRecording();
                },
                icon: SvgPicture.asset('assets/logos/mic.svg'),
              )
            : const SizedBox.shrink(),
        const SizedBox(
          width: 5,
        ),
      ],
    );
  }

  Widget userBlocked() {
    return Column(
      children: [
        const Divider(
          height: 1,
          thickness: 0.29,
          color: textBlackColor,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 15.0, bottom: 15.0, left: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "You have blocked ",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 15),
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
                  style: const TextStyle(fontSize: 15),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              InkWell(
                child: const Text(
                  'UNBLOCK',
                  style: TextStyle(decoration: TextDecoration.underline, color: Colors.blue),
                ),
                onTap: () => controller.unBlockUser(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget userNoLonger() {
    return const Column(
      children: [
        Divider(
          height: 1,
          thickness: 0.29,
          color: textBlackColor,
        ),
        Padding(
          padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
          child: Text(
            "You can't send messages to this group because you're no longer a participant.",
            style: TextStyle(
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget featureNotAvailable() {
    return const Column(
      children: [
        Divider(
          height: 1,
          thickness: 0.29,
          color: textBlackColor,
        ),
        Padding(
          padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
          child: Text(
            "You can't send messages to this group because Feature unavailable for your plan.",
            style: TextStyle(
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
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
            availableWidth: Get.width / 2, // half the screen width
            actionWidth: 48, // default for IconButtons
            actions: [
              // controller.getOptionStatus('Reply')
              CustomAction(
                visibleWidget: IconButton(
                  onPressed: () {
                    controller.handleReplyChatMessage(controller.selectedChatList[0]);
                    controller.clearChatSelection(controller.selectedChatList[0]);
                  },
                  icon: SvgPicture.asset(replyIcon),
                  tooltip: 'Reply',
                ),
                overflowWidget: const Text("Reply"),
                showAsAction: (controller.canBeReplied.value && controller.availableFeatures.value.isClearChatAvailable.checkNull())
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
                  icon: SvgPicture.asset(forwardIcon),
                  tooltip: 'Forward',
                ),
                overflowWidget: const Text("Forward"),
                showAsAction: controller.canBeForwarded.value ? ShowAsAction.always : ShowAsAction.gone,
                keyValue: 'Forward',
                onItemClick: () {
                  controller.closeKeyBoard();
                  controller.checkBusyStatusForForward();
                },
              ),
              /*controller.getOptionStatus('Favourite')
                  ?
                  : customEmptyAction(),*/
              CustomAction(
                visibleWidget: IconButton(
                  onPressed: () {
                    controller.favouriteMessage();
                  },
                  // icon: controller.getOptionStatus('Favourite') ? const Icon(Icons.star_border_outlined)
                  // icon: controller.selectedChatList[0].isMessageStarred
                  icon: SvgPicture.asset(favouriteIcon),
                  tooltip: 'Favourite',
                ),
                overflowWidget: const Text("Favourite"),
                showAsAction: controller.canBeStarred.value ? ShowAsAction.always : ShowAsAction.gone,
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
                  icon: SvgPicture.asset(unFavouriteIcon),
                  tooltip: 'unFavourite',
                ),
                overflowWidget: const Text("unFavourite"),
                showAsAction: controller.canBeUnStarred.value ? ShowAsAction.always : ShowAsAction.gone,
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
                  icon: SvgPicture.asset(deleteIcon),
                  tooltip: 'Delete',
                ),
                overflowWidget: const Text("Delete"),
                showAsAction: controller.availableFeatures.value.isDeleteMessageAvailable.checkNull() ? ShowAsAction.always : ShowAsAction.gone,
                keyValue: 'Delete',
                onItemClick: () {
                  controller.closeKeyBoard();
                  controller.deleteMessages();
                },
              ),
              /*controller.getOptionStatus('Report')
                  ?
                  : customEmptyAction(),*/
              CustomAction(
                visibleWidget: IconButton(
                    onPressed: () {
                      controller.reportChatOrUser();
                    },
                    icon: const Icon(Icons.report_problem_rounded)),
                overflowWidget: const Text("Report"),
                showAsAction: controller.canShowReport.value ? ShowAsAction.never : ShowAsAction.gone,
                keyValue: 'Report',
                onItemClick: () {
                  controller.closeKeyBoard();
                  controller.reportChatOrUser();
                },
              ),
              /*controller.selectedChatList.length > 1 ||
                      controller.selectedChatList[0].messageType !=
                          Constants.mText
                  ? customEmptyAction()
                  : ,*/
              CustomAction(
                visibleWidget: IconButton(
                  onPressed: () {
                    controller.closeKeyBoard();
                    controller.copyTextMessages();
                  },
                  icon: SvgPicture.asset(
                    copyIcon,
                    fit: BoxFit.contain,
                  ),
                  tooltip: 'Copy',
                ),
                overflowWidget: const Text("Copy"),
                showAsAction: controller.canBeCopied.value ? ShowAsAction.never : ShowAsAction.gone,
                keyValue: 'Copy',
                onItemClick: () {
                  controller.closeKeyBoard();
                  controller.copyTextMessages();
                },
              ),
              /*controller.getOptionStatus('Message Info')
                  ?
                  : customEmptyAction(),*/
              CustomAction(
                visibleWidget: IconButton(
                  onPressed: () {
                    // Get.back();
                    controller.messageInfo();
                  },
                  icon: SvgPicture.asset(
                    infoIcon,
                    fit: BoxFit.contain,
                  ),
                  tooltip: 'Message Info',
                ),
                overflowWidget: const Text("Message Info"),
                showAsAction: controller.canShowInfo.value ? ShowAsAction.never : ShowAsAction.gone,
                keyValue: 'MessageInfo',
                onItemClick: () {
                  controller.closeKeyBoard();
                  controller.messageInfo();
                },
              ),
              /*controller.getOptionStatus('Share')
                  ?
                  : customEmptyAction(),*/
              CustomAction(
                visibleWidget: IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset(shareIcon),
                  tooltip: 'Share',
                ),
                overflowWidget: const Text("Share"),
                showAsAction: controller.canBeShared.value ? ShowAsAction.never : ShowAsAction.gone,
                keyValue: 'Share',
                onItemClick: () {
                  controller.closeKeyBoard();
                  controller.share();
                },
              ),
              CustomAction(
                visibleWidget: IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset(shareIcon),
                  tooltip: 'Edit Message',
                ),
                overflowWidget: const Text("Edit Message"),
                showAsAction: controller.canEditMessage.value ? ShowAsAction.never : ShowAsAction.gone,
                keyValue: 'Edit Message',
                onItemClick: () {
                  controller.closeKeyBoard();
                  controller.editMessage();
                },
              ),
            ]),
      ],
    );
  }

  chatAppBar() {
    return Obx(() {
      return AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 80,
        leading: InkWell(
          onTap: () {
            if (controller.showEmoji.value) {
              controller.showEmoji(false);
            } else if (controller.nJid != null) {
              Get.offAllNamed(Routes.dashboard);
            } else {
              Get.back();
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
                width: 35,
                height: 35,
                clipOval: true,
                isGroup: controller.profile.isGroupProfile.checkNull(),
                errorWidget: controller.profile.isGroupProfile ?? false
                    ? ClipOval(
                        child: Image.asset(
                          groupImg,
                          height: 35,
                          width: 35,
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
          width: (Get.width) / 1.9,
          child: InkWell(
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
                ),
                Obx(() {
                  return controller.groupParticipantsName.isNotEmpty
                      ? SizedBox(
                          width: Get.width * 0.90,
                          height: 15,
                          child: Marquee(text: "${controller.groupParticipantsName}       ", style: const TextStyle(fontSize: 12)))
                      : controller.subtitle.isNotEmpty
                          ? Text(
                              controller.subtitle,
                              style: const TextStyle(fontSize: 12),
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
        actions: [
          CustomActionBarIcons(
            availableWidth: Get.width / 2, // half the screen width
            actionWidth: 48, // default for IconButtons
            actions: [
              CustomAction(
                overflowWidget: const Text("Clear Chat"),
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
                    controller.reportChatOrUser();
                  },
                  icon: const Icon(Icons.report_problem_rounded),
                ),
                overflowWidget: const Text("Report"),
                showAsAction: ShowAsAction.never,
                keyValue: 'Report',
                onItemClick: () {
                  controller.closeKeyBoard();
                  controller.reportChatOrUser();
                },
              ),
              controller.isBlocked.value
                  ? CustomAction(
                      visibleWidget: IconButton(
                        onPressed: () {
                          // Get.back();
                          controller.unBlockUser();
                        },
                        icon: const Icon(Icons.block),
                      ),
                      overflowWidget: const Text("Unblock"),
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
                          // Get.back();
                          controller.blockUser();
                        },
                        icon: const Icon(Icons.block),
                      ),
                      overflowWidget: const Text("Block"),
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
                overflowWidget: const Text("Search"),
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
                  child: const Text("Email Chat"),
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
                overflowWidget: const Text("Add Chat Shortcut"),
                showAsAction: ShowAsAction.gone,
                keyValue: 'Shortcut',
                onItemClick: () {
                  controller.closeKeyBoard();
                },
              ),
              CustomAction(
                visibleWidget: IconButton(
                  onPressed: () {
                    controller.makeVideoCall();
                  },
                  icon: SvgPicture.asset(videoCallIcon),
                ),
                overflowWidget: const Text("Video Call"),
                showAsAction: controller.isVideoCallAvailable ? ShowAsAction.always : ShowAsAction.gone,
                keyValue: 'Video Call',
                onItemClick: () {
                  controller.makeVideoCall();
                },
              ),
              CustomAction(
                visibleWidget: IconButton(
                  onPressed: () {
                    controller.makeVoiceCall();
                  },
                  icon: SvgPicture.asset(audioCallIcon),
                ),
                overflowWidget: const Text("Call"),
                showAsAction: controller.isAudioCallAvailable ? ShowAsAction.always : ShowAsAction.gone,
                keyValue: 'Audio Call',
                onItemClick: () {
                  controller.makeVoiceCall();
                },
              ),
            ],
          ),
        ],
      );
    });
  }

  getAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(55.0),
      child: Obx(() {
        return Container(
          child: controller.isSelected.value ? selectedAppBar() : chatAppBar(),
        );
      }),
    );
  }

  customEmptyAction() {
    return CustomAction(
        visibleWidget: const SizedBox.shrink(),
        overflowWidget: const SizedBox.shrink(),
        showAsAction: ShowAsAction.always,
        keyValue: 'Empty',
        onItemClick: () {});
  }
}
