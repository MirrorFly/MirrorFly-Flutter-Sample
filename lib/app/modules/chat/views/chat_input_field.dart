import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/call_modules/ripple_animation_view.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/utils.dart';
import 'package:mirror_fly_demo/app/extensions/extensions.dart';
import 'package:mirror_fly_demo/app/model/arguments.dart';
import 'package:mirror_fly_demo/app/modules/chat/controllers/chat_controller.dart';
import 'package:mirror_fly_demo/app/modules/chat/widgets/reply_message_widgets.dart';
import 'package:mirror_fly_demo/app/modules/dashboard/dashboard_widgets/contact_item.dart';
import 'package:mirror_fly_demo/app/stylesheet/stylesheet.dart';
import 'package:mirror_fly_demo/app/widgets/lottie_animation.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';

import '../../../common/app_localizations.dart';


class ChatInputField extends NavViewStateful<ChatController> {
  ChatInputField(
      {Key? key, required this.messageTypingAreaStyle, required this.chatViewArguments})
      : super(key: key, tag: chatViewArguments?.chatJid);
  final MessageTypingAreaStyle messageTypingAreaStyle;
  final ChatViewArguments? chatViewArguments;


  @override
  ChatController createController({String? tag}) =>
      ChatController(chatViewArguments).get(tag: tag);


  @override
  Widget build(BuildContext context) {
    return Container(
      color: messageTypingAreaStyle.bgColor, //Colors.white,
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
                onCancel: () =>
                    controller.cancelReplyMessage(),
                onClick: () {
                  controller.navigateToMessage(
                      controller.replyChatMessage);
                },
                replyBgColor: messageTypingAreaStyle.replyBgColor,
              );
            } else {
              return const Offstage();
            }
          }),
          MentionUsersList(chatViewArguments: chatViewArguments!,
            mentionUserBgDecoration: messageTypingAreaStyle
                .mentionUserBgDecoration,
            mentionUserStyle: messageTypingAreaStyle.mentionUserStyle,),
          Divider(
              height: 1,
              thickness: 0.29,
              color: messageTypingAreaStyle
                  .dividerColor //textBlackColor,
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(10),
                  width: double.infinity,
                  decoration: messageTypingAreaStyle.decoration,
                  child: Obx(() {
                    return messageTypingView(context);
                  }),
                ),
              ),
              Obx(() {
                return controller.isAudioRecording
                    .value == Constants.audioRecording
                    ? InkWell(
                  onTap: () {
                    controller.stopRecording();
                  },
                  child: RippleWidget(
                    size: 50,
                    rippleColor: messageTypingAreaStyle
                        .rippleColor,
                    child: CircleAvatar(
                      backgroundColor: messageTypingAreaStyle
                          .audioRecordIcon.bgColor,
                      //const Color(0xff3276E2),
                      radius: 48 / 2,
                      child: messageTypingAreaStyle.iconRecord ??
                          AppUtils.svgIcon(icon: audioMic,
                            colorFilter: ColorFilter.mode(
                                messageTypingAreaStyle.audioRecordIcon
                                    .iconColor, BlendMode.srcIn),
                          ),),
                  ),
                )
                    : controller.isUserTyping.value ||
                    controller.isAudioRecording.value ==
                        Constants.audioRecordDone
                    ? InkWell(
                    onTap: () {
                      controller.isAudioRecording.value ==
                          Constants.audioRecordDone
                          ? controller
                          .sendRecordedAudioMessage()
                          : controller.sendMessage(
                          controller.profile);
                    },
                    child: messageTypingAreaStyle.iconSend ?? AppUtils.svgIcon(
                        icon: sendIcon,
                        colorFilter: ColorFilter.mode(
                            messageTypingAreaStyle.sentIconColor,
                            BlendMode.srcIn)))
                    : const Offstage();
              }),
              const SizedBox(
                width: 5,
              ),
            ],
          ),
          controller.emojiLayout(
              textEditingController: controller
                  .messageController,
              sendTypingStatus: true),
        ],
      )
          : !controller.availableFeatures.value
          .isGroupChatAvailable.checkNull()
          ? featureNotAvailable(context)
          : userNoLonger(context),
    );
  }


  Widget messageTypingView(BuildContext context) {
    return Row(
      children: <Widget>[
        if(controller.isAudioRecording.value == Constants.audioRecording ||
            controller.isAudioRecording.value == Constants.audioRecordDone)...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(controller.timerInit.value,
                style: messageTypingAreaStyle
                    .audioRecordingViewStyle.durationTextStyle),
          )
        ],
        if(controller.isAudioRecording.value ==
            Constants.audioRecordInitial)...[
          IconButton(onPressed: () {
            controller.showHideEmoji();
          }, icon: controller.showEmoji.value
              ? messageTypingAreaStyle.iconKeyBoard ?? Icon(
            Icons.keyboard,
            color: messageTypingAreaStyle
                .emojiIconColor,
          )
              : messageTypingAreaStyle.iconEmoji ?? AppUtils.svgIcon(
            icon: smileIcon,
            colorFilter: ColorFilter.mode(
                messageTypingAreaStyle.emojiIconColor, BlendMode.srcIn),))
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
                    height: 50,
                    child: Align(alignment: Alignment.centerRight,
                        child: Text(getTranslated("slideToCancel"),
                          textAlign: TextAlign.end,
                          style: messageTypingAreaStyle.audioRecordingViewStyle
                              .cancelTextStyle,))),
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
                  style: messageTypingAreaStyle
                      .audioRecordingViewStyle.cancelTextStyle.copyWith(
                      color: Colors.red),
                ),
              ),
            ),
          )
        ],
        if(controller.isAudioRecording.value ==
            Constants.audioRecordInitial)...[
          Expanded(
            child: TextField(
              onChanged: (text) {
                controller.isTyping(text);
              },
              style: messageTypingAreaStyle
                  .textFieldStyle.editTextStyle,
              //const TextStyle(fontWeight: FontWeight.w400),
              keyboardType: TextInputType.multiline,
              minLines: 1,
              maxLines: 4,
              enabled: controller.isAudioRecording.value ==
                  Constants.audioRecordInitial ? true : false,
              controller: controller.messageController,
              focusNode: controller.focusNode,
              decoration: InputDecoration(
                  hintText: getTranslated("startTypingPlaceholder"),
                  border: InputBorder.none,
                  hintStyle: messageTypingAreaStyle
                      .textFieldStyle.editTextHintStyle),
            ),
          )
        ],
        if(controller.isAudioRecording.value == Constants.audioRecordInitial &&
            controller.availableFeatures.value.isAttachmentAvailable
                .checkNull())...[
          IconButton(
            onPressed: () {
              controller.showAttachmentsView(context);
            },
            icon: messageTypingAreaStyle.iconAttachment ?? AppUtils.svgIcon(
              icon: attachIcon,
              colorFilter: ColorFilter.mode(
                  messageTypingAreaStyle.emojiIconColor, BlendMode.srcIn),),
          )
        ],
        if(controller.isAudioRecording.value == Constants.audioRecordInitial &&
            controller.availableFeatures.value.isAudioAttachmentAvailable
                .checkNull())...[
          IconButton(
            onPressed: () {
              controller.startRecording();
            },
            icon: messageTypingAreaStyle.iconRecord ?? AppUtils.svgIcon(
              icon: audioMic,
              colorFilter: ColorFilter.mode(
                  messageTypingAreaStyle.emojiIconColor, BlendMode.srcIn),),
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
          color: messageTypingAreaStyle
              .dividerColor,
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
                style: messageTypingAreaStyle
                    .textFieldStyle.editTextStyle,
                // style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(
                width: 5,
              ),
              Flexible(
                child: Text(controller.profile.getName(),
                  //controller.profile.name.checkNull(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: messageTypingAreaStyle
                      .textFieldStyle.editTextStyle,
                  // style: const TextStyle(fontSize: 15),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              InkWell(
                child: Text(
                  getTranslated("unblock"),
                  style: messageTypingAreaStyle
                      .textFieldStyle.editTextStyle.copyWith(
                      color: Colors.blue),
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
            color: messageTypingAreaStyle
                .dividerColor //textBlackColor,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
          child: Text(
            getTranslated("youCantSentMessageNoLonger"),
            style: messageTypingAreaStyle
                .textFieldStyle.editTextHintStyle,
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
            color: messageTypingAreaStyle
                .dividerColor //textBlackColor,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
          child: Text(
            getTranslated("featureNotAvailable"),
            style: messageTypingAreaStyle
                .textFieldStyle.editTextHintStyle,
            // style: const TextStyle(
            //   fontSize: 15,
            // ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

}

/*class MentionUserList extends StatefulWidget {
  const MentionUserList({super.key,required this.chatViewArguments,this.mentionUserBgDecoration, this.mentionUserStyle = const ContactItemStyle(),});
  final Decoration? mentionUserBgDecoration;
  final ContactItemStyle mentionUserStyle;
  final ChatViewArguments chatViewArguments;

  @override
  State<MentionUserList> createState() => _MentionUserListState();
}

class _MentionUserListState extends State<MentionUserList> {
  var filteredItems = List<ProfileDetails>.empty().obs;

  late final ChatController controller;

  @override
  void initState() {
    controller = ChatController(widget.chatViewArguments).get(tag: widget.chatViewArguments.chatJid);
    filteredItems = controller.groupMembers;
    super.initState();
  }

  void filterItems() {
    final query = controller.messageController.text.toLowerCase();
    // setState(() {
    filteredItems(controller.groupMembers
        .where((item) => item.getName().toLowerCase().contains(query))
        .toList());
    // });
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
        builder: (context, isKeyboardVisible) {
          return controller.filteredItems.isNotEmpty ? Container(
            decoration: widget.mentionUserBgDecoration,
            height: isKeyboardVisible ? 150 : 250,
            child: ListView.builder(
                key: const PageStorageKey("mentionUsers"),
                itemCount: controller.filteredItems.length,
                itemBuilder: (ct, index) {
                  return ContactItem(item: controller.filteredItems[index],
                    checkValue: false,
                    onCheckBoxChange: (val) {},
                    showStatus: false,
                    contactItemStyle: widget.mentionUserStyle,);
                }),
          ) : const Offstage();
        }
    );
  }
}*/


class MentionUsersList extends NavViewStateful<ChatController> {
  MentionUsersList(
      {Key? key, required this.chatViewArguments, this.mentionUserBgDecoration, this.mentionUserStyle = const ContactItemStyle(),})
      : super(key: key, tag: chatViewArguments.chatJid);
  final Decoration? mentionUserBgDecoration;
  final ContactItemStyle mentionUserStyle;
  final ChatViewArguments chatViewArguments;

  @override
  createController({String? tag}) =>
      ChatController(chatViewArguments).get(tag: tag);


  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
        builder: (context, isKeyboardVisible) {
          return Obx(() {
            debugPrint("showMentionUserList : ${controller.showMentionUserList} ${controller.filteredItems.length}");
            return controller.filteredItems.isNotEmpty &&
                controller.showMentionUserList.value ? Container(
              decoration: mentionUserBgDecoration,
              height: isKeyboardVisible ? 150 : 250,
              child: ListView.builder(
                  key: const PageStorageKey("mentionUsers"),
                  shrinkWrap: true,
                  itemCount: controller.filteredItems.length,
                  itemBuilder: (ct, index) {
                    return ContactItem(item: controller.filteredItems[index],
                      checkValue: false,
                      onCheckBoxChange: (val) {},
                      showStatus: false,
                      contactItemStyle: mentionUserStyle,);
                  }),
            ) : const Offstage();
          });
        }
    );
  }

}

