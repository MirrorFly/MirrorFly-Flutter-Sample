import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mirror_fly_demo/app/modules/chat/widgets/image_message_view.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mirror_fly_demo/app/common/widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mirror_fly_demo/app/common/extensions.dart';
import '../../common/app_localizations.dart';
import '../../common/constants.dart';
import '../../data/apputils.dart';
import '../../data/helper.dart';
import '../../data/permissions.dart';
import '../../data/session_management.dart';
import '../../model/chat_message_model.dart';
import '../../routes/app_pages.dart';
import '../dashboard/widgets.dart';

class ReplyingMessageHeader extends StatelessWidget {
  const ReplyingMessageHeader({Key? key,
    required this.chatMessage,
    required this.onCancel,
    required this.onClick})
      : super(key: key);
  final ChatMessageModel chatMessage;
  final Function() onCancel;
  final Function() onClick;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          color: chatSentBgColor,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: chatReplyContainerColor,
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0, left: 15.0),
                      child: getReplyTitle(chatMessage.isMessageSentByMe,
                          chatMessage.senderUserName.checkNull().isNotEmpty ? chatMessage.senderUserName : chatMessage.senderNickName),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 15.0, left: 15.0),
                      child: getReplyMessage(
                          chatMessage.messageType.toUpperCase(),
                          chatMessage.messageTextContent,
                          chatMessage.contactChatMessage?.contactName,
                          chatMessage.mediaChatMessage?.mediaFileName,
                          chatMessage.mediaChatMessage,
                          true),
                    ),
                  ],
                ),
              ),
              Stack(
                alignment: Alignment.topRight,
                children: [
                  getReplyImageHolder(
                      context,
                      chatMessage,
                      chatMessage.mediaChatMessage,
                      70,
                      true,
                      chatMessage.locationChatMessage),
                  GestureDetector(
                    onTap: onCancel,
                    child: const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 10,
                          child:
                          Icon(Icons.close, size: 15, color: Colors.black)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

getReplyTitle(bool isMessageSentByMe, String senderUserName) {
  /*debugPrint("issentby me $isMessageSentByMe");
  debugPrint("senderUserName $senderUserName");*/
  return isMessageSentByMe
      ? Text(getTranslated("you"),
    style: const TextStyle(fontWeight: FontWeight.bold),
  )
      : Text(senderUserName,
      style: const TextStyle(fontWeight: FontWeight.bold));
}

getReplyMessage(String messageType,
    String? messageTextContent,
    String? contactName,
    String? mediaFileName,
    MediaChatMessage? mediaChatMessage,
    bool isReplying) {
  debugPrint(messageType);
  switch (messageType) {
    case Constants.mText:
      return Row(
        children: [
          Helper.forMessageTypeIcon(Constants.mText),
          // Text(messageTextContent!),
          Expanded(
              child: Text(messageTextContent!,
                  maxLines: 1, overflow: TextOverflow.ellipsis)),
        ],
      );
    case Constants.mImage:
      return Row(
        children: [
          Helper.forMessageTypeIcon(Constants.mImage),
          const SizedBox(
            width: 5,
          ),
          Text(Constants.mImage.capitalizeFirst!),
        ],
      );
    case Constants.mVideo:
      return Row(
        children: [
          Helper.forMessageTypeIcon(Constants.mVideo),
          const SizedBox(
            width: 5,
          ),
          Text(Constants.mVideo.capitalizeFirst!),
        ],
      );
    case Constants.mAudio:
      return Row(
        children: [
          isReplying
              ? Helper.forMessageTypeIcon(
              Constants.mAudio,
              mediaChatMessage != null
                  ? mediaChatMessage.isAudioRecorded
                  : true)
              : const Offstage(),
          isReplying
              ? const SizedBox(
            width: 5,
          )
              : const Offstage(),
          Text(
            Helper.durationToString(Duration(
                milliseconds: mediaChatMessage != null
                    ? mediaChatMessage.mediaDuration
                    : 0)),
          ),
          const SizedBox(
            width: 5,
          ),
          // Text(Constants.mAudio.capitalizeFirst!),
        ],
      );
    case Constants.mContact:
      return Row(
        children: [
          Helper.forMessageTypeIcon(Constants.mContact),
          const SizedBox(
            width: 5,
          ),
          Text("${Constants.mContact.capitalizeFirst} :"),
          const SizedBox(
            width: 5,
          ),
          SizedBox(
              width: 120,
              child: Text(
                contactName!,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
              )),
        ],
      );
    case Constants.mLocation:
      return Row(
        children: [
          Helper.forMessageTypeIcon(Constants.mLocation),
          const SizedBox(
            width: 5,
          ),
          Text(Constants.mLocation.capitalizeFirst!),
        ],
      );
    case Constants.mDocument:
      return Row(
        children: [
          Helper.forMessageTypeIcon(Constants.mDocument),
          const SizedBox(
            width: 5,
          ),
          Flexible(
              child: Text(
                mediaFileName!,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              )),
        ],
      );
    default:
      return const Offstage();
  }
}

getReplyImageHolder(BuildContext context,
    ChatMessageModel chatMessageModel,
    MediaChatMessage? mediaChatMessage,
    double size,
    bool isNotChatItem,
    LocationChatMessage? locationChatMessage) {
  // LogMessage.d("getReplyImageHolder", "chatMessageModel : ${chatMessageModel.toJson()}");
  // LogMessage.d("getReplyImageHolder", "mediaChatMessage : ${mediaChatMessage?.toJson()}");
  // LogMessage.d("getReplyImageHolder", "isNotChatItem : $isNotChatItem");
  // LogMessage.d("getReplyImageHolder", "locationChatMessage : ${locationChatMessage?.toJson()}");
  var isReply = false;
  if (mediaChatMessage != null || locationChatMessage != null) {
    isReply = true;
  }
  var condition = isReply ? (mediaChatMessage == null ? Constants.mLocation : mediaChatMessage.messageType) : chatMessageModel.replyParentChatMessage?.messageType;
  LogMessage.d("getReplyImageHolder", "condition : $condition");
  switch (condition) {
    case Constants.mImage:
      debugPrint("reply header--> IMAGE");
      return ClipRRect(
        borderRadius: const BorderRadius.only(
            topRight: Radius.circular(5), bottomRight: Radius.circular(5)),
        child: imageFromBase64String(
            isReply
                ? mediaChatMessage!.mediaThumbImage
                : chatMessageModel.mediaChatMessage!.mediaThumbImage
                .checkNull(),
            context,
            size,
            size),
      );
    case Constants.mLocation:
      return getLocationImage(
          isReply ? locationChatMessage : chatMessageModel.locationChatMessage,
          size,
          size,
          isSelected: true);
    case Constants.mVideo:
      return ClipRRect(
        borderRadius: const BorderRadius.only(
            topRight: Radius.circular(5), bottomRight: Radius.circular(5)),
        child: imageFromBase64String(
            isReply
                ? mediaChatMessage!.mediaThumbImage
                : chatMessageModel.mediaChatMessage!.mediaThumbImage,
            context,
            size,
            size),
      );
    case Constants.mDocument:
      debugPrint("isNotChatItem--> $isNotChatItem");
      debugPrint("Document --> $isReply");
      debugPrint(
          "Document --> ${isReply ? mediaChatMessage!.mediaFileName : chatMessageModel.mediaChatMessage!
              .mediaFileName}");
      return isNotChatItem
          ? SizedBox(height: size)
          : Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(10)),
            color: Colors.white,
          ),
          child: Center(
            child: getImageHolder(
                isReply
                    ? mediaChatMessage!.mediaFileName
                    : chatMessageModel.mediaChatMessage!.mediaFileName,
                30),
          ));
    case Constants.mAudio:
      return isNotChatItem
          ? SizedBox(height: size)
          : ClipRRect(
        borderRadius: const BorderRadius.only(
            topRight: Radius.circular(5),
            bottomRight: Radius.circular(5)),
        child: Container(
          height: size,
          width: size,
          color: audioBgColor,
          child: Center(
            child: SvgPicture.asset(
              mediaChatMessage!.isAudioRecorded.checkNull()
                  ? mAudioRecordIcon
                  : mAudioIcon,
              fit: BoxFit.contain,
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              height: 18,
            ),
          ),
        ),
      );
    default:
      debugPrint("reply header--> DEFAULT");
      return SizedBox(
        height: size,
      );
  }
}

Widget messageNotAvailableWidget(ChatMessageModel chatMessage) {
  return Container(
    padding: const EdgeInsets.all(12),
    margin: const EdgeInsets.all(2),
    decoration: BoxDecoration(
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      color: chatMessage.isMessageSentByMe
          ? chatReplyContainerColor
          : chatReplySenderColor,
    ),
    child: Text(getTranslated("messageUnavailable"), maxLines: 2, overflow: TextOverflow.ellipsis,),
  );
}

class ReplyMessageHeader extends StatelessWidget {
  const ReplyMessageHeader({Key? key, required this.chatMessage})
      : super(key: key);
  final ChatMessageModel chatMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: chatMessage.isMessageSentByMe
            ? chatReplyContainerColor
            : chatReplySenderColor,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getReplyTitle(
                    chatMessage.replyParentChatMessage!.isMessageSentByMe,
                    chatMessage.replyParentChatMessage!.senderUserName),
                const SizedBox(height: 5),
                getReplyMessage(
                    chatMessage.replyParentChatMessage!.messageType,
                    chatMessage.replyParentChatMessage?.messageTextContent,
                    chatMessage.replyParentChatMessage?.contactChatMessage
                        ?.contactName,
                    chatMessage.replyParentChatMessage?.mediaChatMessage
                        ?.mediaFileName,
                    chatMessage.replyParentChatMessage?.mediaChatMessage,
                    false),
              ],
            ),
          ),
          getReplyImageHolder(
              context,
              chatMessage,
              chatMessage.replyParentChatMessage?.mediaChatMessage,
              55,
              false,
              chatMessage.replyParentChatMessage?.locationChatMessage),
        ],
      ),
    );
  }
}

Widget imageFromBase64String(String base64String, BuildContext context, double? width, double? height) {
  LogMessage.d("imageFromBase64String", "final");
  final decodedBase64 = base64String.replaceAll("\n", "");
  final Uint8List image = const Base64Decoder().convert(decodedBase64);
  return Image.memory(
    image,
    key: ValueKey<String>(base64String),
    width: width ?? Get.width * 0.60,
    height: height ?? Get.height * 0.4,
    fit: BoxFit.cover,
    gaplessPlayback: true,
    cacheHeight: (height ?? Get.height * 0.4).toInt(),
    cacheWidth:  (width ?? Get.width * 0.60).toInt(),
  );
}

Widget getLocationImage(LocationChatMessage? locationChatMessage, double width, double height,
    {bool isSelected = false}) {
  return InkWell(
      onTap: isSelected
          ? null
          : () async {
        String googleUrl =
            'https://www.google.com/maps/search/?api=1&query=${locationChatMessage!.latitude}, ${locationChatMessage
            .longitude}';
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
}

class SenderHeader extends StatelessWidget {
  const SenderHeader({Key? key,
    required this.isGroupProfile,
    required this.chatList,
    required this.index})
      : super(key: key);
  final bool? isGroupProfile;
  final List<ChatMessageModel> chatList;
  final int index;

  bool isSenderChanged(List<ChatMessageModel> messageList, int position) {
    var preposition = position + 1;
    if (!preposition.isNegative) {
      var currentMessage = messageList[position];
      var previousMessage = messageList[preposition];
      if (currentMessage.isMessageSentByMe !=
          previousMessage.isMessageSentByMe ||
          previousMessage.messageType == Constants.msgTypeNotification ||
          (currentMessage.messageChatType == ChatType.groupChat &&
              currentMessage.isThisAReplyMessage)) {
        return true;
      }
      var currentSenderJid = currentMessage.senderUserJid.checkNull();
      var previousSenderJid = previousMessage.senderUserJid.checkNull();
      // debugPrint("currentSenderJid  : $currentSenderJid");
      // debugPrint("previousSenderJid : $previousSenderJid");
      // debugPrint("isSenderChanged : ${previousSenderJid != currentSenderJid}");
      return previousSenderJid != currentSenderJid;
    } else {
      return false;
    }
  }

  bool isMessageDateEqual(List<ChatMessageModel> messageList, int position) {
    var previousMessage = getPreviousMessage(messageList, position);
    return previousMessage != null && checkIsNotNotification(previousMessage);
  }

  ChatMessageModel? getPreviousMessage(List<ChatMessageModel> messageList, int position) {
    return (position > 0) ? messageList[position + 1] : null;
  }

  bool checkIsNotNotification(ChatMessageModel messageItem) {
    var msgType = messageItem.messageType;
    return msgType.toUpperCase() != Constants.mNotification;
  }

  @override
  Widget build(BuildContext context) {
    // LogMessage.d("index", index.toString());
    return Visibility(
      visible: isGroupProfile ?? false
          ? (index == chatList.length - 1 ||
          isSenderChanged(chatList, index)) &&
          !chatList[index].isMessageSentByMe
          : false,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0, right: 8.0, left: 8.0),
        child: Text(
          chatList[index].senderUserName.checkNull(),
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(Helper.getColourCode(
                  chatList[index].senderUserName.checkNull()))),
        ),
      ),
    );
  }
}

class LocationMessageView extends StatelessWidget {
  const LocationMessageView({Key? key, required this.chatMessage, required this.isSelected})
      : super(key: key);
  final ChatMessageModel chatMessage;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: getLocationImage(chatMessage.locationChatMessage, 200, 171,
                isSelected: isSelected),
          ),
          Positioned(
            bottom: 8,
            right: 10,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                chatMessage.isMessageStarred.value
                    ? SvgPicture.asset(starSmallIcon)
                    : const Offstage(),
                const SizedBox(
                  width: 5,
                ),
                getMessageIndicator(
                    chatMessage.messageStatus.value,
                    chatMessage.isMessageSentByMe,
                    chatMessage.messageType,
                    chatMessage.isMessageRecalled.value),
                const SizedBox(
                  width: 4,
                ),
                Text(
                  getChatTime(context, chatMessage.messageSentTime.toInt()),
                  style: TextStyle(
                      fontSize: 12,
                      color: chatMessage.isMessageSentByMe
                          ? durationTextColor
                          : textHintColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AudioMessageView extends StatefulWidget {
  const AudioMessageView({Key? key,
    required this.chatMessage,
    required this.onPlayAudio,
    required this.onSeekbarChange})
      : super(key: key);
  final ChatMessageModel chatMessage;
  final Function() onPlayAudio;
  final Function(double) onSeekbarChange;

  @override
  State<AudioMessageView> createState() => _AudioMessageViewState();
}

class _AudioMessageViewState extends State<AudioMessageView>
    with WidgetsBindingObserver {
  onAudioClick() {
    switch (widget.chatMessage.isMessageSentByMe
        ? widget.chatMessage.mediaChatMessage?.mediaUploadStatus.value
        : widget.chatMessage.mediaChatMessage?.mediaDownloadStatus.value) {
      case MediaDownloadStatus.isMediaDownloaded:
      case MediaUploadStatus.isMediaUploaded:
        if (checkFile(
            widget.chatMessage.mediaChatMessage!.mediaLocalStoragePath.value) &&
            (widget.chatMessage.mediaChatMessage!.mediaDownloadStatus.value ==
                MediaDownloadStatus.isMediaDownloaded ||
                widget.chatMessage.mediaChatMessage!.mediaDownloadStatus.value ==
                    MediaUploadStatus.isMediaUploaded ||
                widget.chatMessage.isMessageSentByMe)) {
          //playAudio(chatList, chatList.mediaChatMessage!.mediaLocalStoragePath);
        } else {
          debugPrint("condition failed");
        }
    }
  }

  AudioPlayer player = AudioPlayer();
  RxDouble currentPos = 0.0.obs;

  /*double
        .parse(chatMessage
        .mediaChatMessage!.currentPos
        .toString())
        .obs;*/
  RxBool isPlaying = false.obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    currentPos = widget.chatMessage.mediaChatMessage!
        .currentPos
        .toDouble()
        .obs;
    // player.onPlayerCompletion.listen((event) {
    //   isPlaying(false);
    //   currentPos(0);
    //   widget.chatMessage.mediaChatMessage!.currentPos = 0;
    //   player.stop();
    // });
    //
    // player.onAudioPositionChanged.listen((Duration p) {
    //   LogMessage.d('p.inMilliseconds', p.inMilliseconds.toString());
    //   widget.chatMessage.mediaChatMessage!.currentPos = p.inMilliseconds;
    //   currentPos(p.inMilliseconds.toDouble());
    //   currentPos.refresh();
    // });
    player.onPlayerStateChanged.listen(
          (it) {
        switch (it) {
          case PlayerState.playing:
            isPlaying(true);
            break;
          case PlayerState.stopped:
            isPlaying(false);
            break;
          case PlayerState.paused:
            isPlaying(false);
            break;
          case PlayerState.completed:
            break;
          default:
            break;
        }
      },
    );
    player.onPlayerComplete.listen((event) {
      isPlaying(false);
      currentPos(0);
      widget.chatMessage.mediaChatMessage!.currentPos = 0;
      player.stop();
    });
    player.onPositionChanged.listen((Duration  p) {
      LogMessage.d('p.inMilliseconds', p.inMilliseconds.toString());
      widget.chatMessage.mediaChatMessage!.currentPos = p.inMilliseconds;
      currentPos(p.inMilliseconds.toDouble());
      currentPos.refresh();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        debugPrint('appLifeCycleState inactive');
        break;
      case AppLifecycleState.resumed:
        debugPrint('appLifeCycleState resumed');
        break;
      case AppLifecycleState.paused:
        debugPrint('appLifeCycleState paused');
        isPlaying(false);
        player.stop();
        break;
      case AppLifecycleState.detached:
        debugPrint('appLifeCycleState detached');
        break;
      case AppLifecycleState.hidden:
        debugPrint('appLifeCycleState hidden');
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
    player.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = Get.width;
    var currentPos =
    0.0; /*double.parse(widget.chatMessage
        .mediaChatMessage!.currentPos
        .toString());
    var maxPos = double.parse(widget.chatMessage
        .mediaChatMessage!.mediaDuration
        .toString());
    if (!(currentPos >= 0.0 && currentPos <= maxPos)) {
      currentPos = maxPos;
    }*/
    /* debugPrint(
        "currentPos--> ${double.parse(
            widget.chatMessage.mediaChatMessage!.currentPos.toString())}");*/
    debugPrint(
        "max duration--> ${double.parse(widget.chatMessage.mediaChatMessage!.mediaDuration.toString())}");
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: widget.chatMessage.isMessageSentByMe
              ? chatReplyContainerColor
              : chatReplySenderColor,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: Colors.transparent,
      ),
      width: screenWidth * 0.80,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10)),
              color: widget.chatMessage.isMessageSentByMe
                  ? chatReplyContainerColor
                  : chatReplySenderColor,
            ),
            padding: const EdgeInsets.all(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                widget.chatMessage.mediaChatMessage!.isAudioRecorded
                    ? Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset(
                      audioMicBg,
                      width: 32,
                      height: 32,
                      fit: BoxFit.contain,
                    ),
                    SvgPicture.asset(
                      audioMic1,
                      fit: BoxFit.contain,
                    ),
                  ],
                )
                    : SvgPicture.asset(
                  musicIcon,
                  width: 32,
                  height: 32,
                  fit: BoxFit.contain,
                ),
                Obx(() {
                  return getImageOverlay(widget.chatMessage, onAudio: () {
                    widget.onPlayAudio();
                    playAudio(widget.chatMessage);
                  });
                }), //widget.onPlayAudio),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 8),
                        child: SliderTheme(
                          data: SliderThemeData(
                            thumbColor: audioColorDark,
                            trackHeight: 2,
                            overlayShape: SliderComponentShape.noThumb,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 4),
                          ),
                          child: Slider(
                            value: currentPos,
                            /*double.parse(chatMessage
                                .mediaChatMessage!.currentPos
                                .toString()),*/
                            min: 0.0,
                            activeColor: Colors.white,
                            thumbColor: audioColorDark,
                            inactiveColor: borderColor,
                            max: double.parse(widget
                                .chatMessage.mediaChatMessage!.mediaDuration
                                .toString()),
                            divisions: widget
                                .chatMessage.mediaChatMessage!.mediaDuration,
                            onChanged: (double value) {
                              debugPrint('onChanged $value');
                              /*setState(() {
                                currentPos = value;
                              });*/
                              widget.onSeekbarChange(value);
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 2.0),
                        child: Text(
                          Helper.durationToString(Duration(
                              milliseconds: currentPos !=
                                  0.0 // chatMessage.mediaChatMessage?.currentPos != 0
                                  ? currentPos
                                  .toInt() /*chatMessage
                                              .mediaChatMessage?.currentPos ??
                                          0*/
                                  : widget.chatMessage.mediaChatMessage!
                                  .mediaDuration)),
                          style: const TextStyle(
                              color: durationTextColor,
                              fontSize: 8,
                              fontWeight: FontWeight.w300),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                widget.chatMessage.isMessageStarred.value
                    ? SvgPicture.asset(starSmallIcon)
                    : const Offstage(),
                const SizedBox(
                  width: 5,
                ),
                getMessageIndicator(
                    widget.chatMessage.messageStatus.value,
                    widget.chatMessage.isMessageSentByMe,
                    widget.chatMessage.messageType,
                    widget.chatMessage.isMessageRecalled.value),
                const SizedBox(
                  width: 4,
                ),
                Text(
                  getChatTime(
                      context, widget.chatMessage.messageSentTime.toInt()),
                  style: TextStyle(
                      fontSize: 12,
                      color: widget.chatMessage.isMessageSentByMe
                          ? durationTextColor
                          : textHintColor),
                ),
                const SizedBox(
                  width: 10,
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 5,
          ),
        ],
      ),
    );
  }

  playAudio(ChatMessageModel chatMessage) {
    var maxPos =
    double.parse(chatMessage.mediaChatMessage!.mediaDuration.toString());
    /*if(!(currentPos >= 0.0 && currentPos <= maxPos)){
      currentPos(maxPos);
    }*/
    Get.dialog(
      Dialog(
        child: PopScope(
          canPop: true,
          onPopInvoked: (didPop) {
            isPlaying(false);
            player.stop();
            if (didPop) {
              return;
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: chatMessage.isMessageSentByMe
                  ? chatReplyContainerColor
                  : chatReplySenderColor,
            ),
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Row(
              // mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 10,
                ),
                widget.chatMessage.mediaChatMessage!.isAudioRecorded
                    ? Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset(
                      audioMicBg,
                      width: 28,
                      height: 28,
                      fit: BoxFit.contain,
                    ),
                    SvgPicture.asset(
                      audioMic1,
                      fit: BoxFit.contain,
                    ),
                  ],
                )
                    : SvgPicture.asset(
                  musicIcon,
                  fit: BoxFit.contain,
                ),
                const SizedBox(
                  width: 4,
                ),
                Obx(() {
                  return InkWell(
                    onTap: () async {
                      if (!isPlaying.value) {
                        // int result = await player.play(
                        //     chatMessage.mediaChatMessage!.mediaLocalStoragePath.value,
                        //     position: Duration(
                        //         milliseconds:
                        //         chatMessage.mediaChatMessage!.currentPos),
                        //     isLocal: true);
                        // if (result == 1) {
                        //   isPlaying(true);
                        // } else {
                        //   LogMessage.d("", "Error while playing audio.");
                        // }
                        await player.play(DeviceFileSource(chatMessage.mediaChatMessage!.mediaLocalStoragePath.value),position: Duration(
                            milliseconds:
                            chatMessage.mediaChatMessage!.currentPos));
                        isPlaying(true);
                      } else {
                        // int result = await player.pause();
                        // if (result == 1) {
                        //   isPlaying(false);
                        // } else {
                        //   LogMessage.d("", "Error on pause audio.");
                        // }
                        await player.pause();
                        isPlaying(false);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: isPlaying.value
                          ? SvgPicture.asset(
                        pauseIcon,
                        height: 17,
                      ) //const Icon(Icons.pause)
                          : SvgPicture.asset(
                        playIcon,
                        height: 17,
                      ),
                    ),
                  );
                }),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 8),
                        child: SliderTheme(
                          data: SliderThemeData(
                            thumbColor: audioColorDark,
                            trackHeight: 2,
                            overlayShape: SliderComponentShape.noOverlay,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6),
                          ),
                          child: Obx(() {
                            return Slider(
                              value: (!(currentPos.value >= 0.0 &&
                                  currentPos.value <= maxPos))
                                  ? maxPos
                                  : currentPos.value,
                              /*double.parse(chatMessage
                                .mediaChatMessage!.currentPos
                                .toString()),*/
                              min: 0.0,
                              activeColor: Colors.white,
                              thumbColor: audioColorDark,
                              inactiveColor: borderColor,
                              max: double.parse(chatMessage
                                  .mediaChatMessage!.mediaDuration
                                  .toString()),
                              divisions:
                              chatMessage.mediaChatMessage!.mediaDuration,
                              onChanged: (double value) {
                                // debugPrint('onChanged $value');
                                player.seek(
                                    Duration(milliseconds: value.toInt()));
                                // currentPos(value);
                                /*setState(() {
                              currentPos = value;
                            });*/
                                //widget.onSeekbarChange(value);
                              },
                            );
                          }),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Obx(() {
                            return Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: Text(
                                Helper.durationToString(Duration(
                                    milliseconds: currentPos.value == 0.0
                                        ? widget.chatMessage.mediaChatMessage!
                                        .mediaDuration
                                        : currentPos.value.toInt())),
                                style: const TextStyle(
                                    color: durationTextColor,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w300),
                              ),
                            );
                          }),
                          /*Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: Text(
                            Helper.durationToString(Duration(
                                milliseconds: chatMessage
                                    .mediaChatMessage!.mediaDuration)),
                            style: const TextStyle(
                                color: durationTextColor,
                                fontSize: 8,
                                fontWeight: FontWeight.w400),
                          ),
                        ),*/
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ContactMessageView extends StatelessWidget {
  const ContactMessageView({Key? key,
    required this.chatMessage,
    this.search = "",
    required this.isSelected})
      : super(key: key);
  final ChatMessageModel chatMessage;
  final String search;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    var screenWidth = Get.width;
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        color: chatMessage.isMessageSentByMe
            ? chatReplyContainerColor
            : chatReplySenderColor,
      ),
      width: screenWidth * 0.60,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
            child: Row(
              children: [
                Image.asset(
                  profileImage,
                  width: 35,
                  height: 35,
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                    child: search.isEmpty
                        ? textMessageSpannableText(
                        chatMessage.contactChatMessage!.contactName
                            .checkNull(),
                        maxLines: 2)
                        : chatSpannedText(
                        chatMessage.contactChatMessage!.contactName,
                        search,
                        const TextStyle(fontSize: 14, color: textHintColor),
                        maxLines:
                        2) /*,Text(
                  chatMessage.contactChatMessage!.contactName,
                  maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                )*/
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                chatMessage.isMessageStarred.value
                    ? SvgPicture.asset(starSmallIcon)
                    : const Offstage(),
                const SizedBox(
                  width: 5,
                ),
                getMessageIndicator(
                    chatMessage.messageStatus.value,
                    chatMessage.isMessageSentByMe,
                    chatMessage.messageType,
                    chatMessage.isMessageRecalled.value),
                const SizedBox(
                  width: 4,
                ),
                Text(
                  getChatTime(context, chatMessage.messageSentTime.toInt()),
                  style: TextStyle(
                      fontSize: 11,
                      color: chatMessage.isMessageSentByMe
                          ? durationTextColor
                          : textHintColor),
                ),
                const SizedBox(
                  width: 10,
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          const AppDivider(),
          getJidOfContact(chatMessage.contactChatMessage),
        ],
      ),
    );
  }

  Future<String?> getUserJid(ContactChatMessage contactChatMessage) async {
    for (int i = 0; i < contactChatMessage.contactPhoneNumbers.length; i++) {
      debugPrint(
          "contactChatMessage.isChatAppUser[i]--> ${contactChatMessage.isChatAppUser[i]}");
      if (contactChatMessage.isChatAppUser[i]) {
        return await Mirrorfly.getJidFromPhoneNumber(mobileNumber: contactChatMessage.contactPhoneNumbers[i],
            countryCode: (SessionManagement.getCountryCode() ?? "").replaceAll('+', ''));
      }
    }
    return '';
  }

  Widget getJidOfContact(ContactChatMessage? contactChatMessage) {
    // String? userJid;
    if (contactChatMessage == null ||
        contactChatMessage.contactPhoneNumbers.isEmpty) {
      return const Offstage();
    }
    return FutureBuilder(
        future: getUserJid(contactChatMessage),
        builder: (context, snapshot) {
          if (snapshot.hasError || !snapshot.hasData) {
            return const Offstage();
          }
          var userJid = snapshot.data;
          debugPrint("getJidOfContact--> $userJid");
          return InkWell(
            onTap: () {
              (userJid != null && userJid.isNotEmpty)
                  ? sendToChatPage(userJid)
                  : showInvitePopup(contactChatMessage);
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                    child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: (userJid != null && userJid.isNotEmpty)
                              ? Text(getTranslated("message"))
                              : Text(getTranslated("invite")),
                        ))),
              ],
            ),
          );
        });
  }

  sendToChatPage(String userJid) {
    // Get.back();
    LogMessage.d('Get.currentRoute', Get.currentRoute);
    if (Get.currentRoute == Routes.chat) {
      Get.back();
      Future.delayed(const Duration(milliseconds: 500), () {
        Get.toNamed(Routes.chat,
            parameters: {'isFromStarred': 'true', "userJid": userJid});
      });
    } else {
      Get.back();
      sendToChatPage(userJid);
      /*Get.toNamed(Routes.chat,
          parameters: {'isFromStarred': 'true', "userJid": userJid});*/
    }
  }

  showInvitePopup(ContactChatMessage contactChatMessage) {
    Helper.showButtonAlert(actions: [
      ListTile(
        contentPadding: const EdgeInsets.only(left: 10),
        title: Text(getTranslated("inviteFriend"),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ),
      ListTile(
        contentPadding: const EdgeInsets.only(left: 10),
        title: Text(getTranslated("copyLink"),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
        onTap: () {
          Clipboard.setData(ClipboardData(text: getTranslated("applicationLink")));
          Get.back();
          toToast(getTranslated("linkCopied"));
        },
      ),
      ListTile(
        contentPadding: const EdgeInsets.only(left: 10),
        title: Text(getTranslated("sendSMS"),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
        onTap: () {
          Get.back();
          sendSMS(contactChatMessage.contactPhoneNumbers[0]);
        },
      ),
    ]);
  }

  void sendSMS(String contactPhoneNumber) async {
    Uri sms = Uri.parse('sms:$contactPhoneNumber?body=${getTranslated("smsContent")}');
    if (await launchUrl(sms)) {
      //app opened
    } else {
      //app is not opened
    }
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) =>
    '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}

class DocumentMessageView extends StatelessWidget {
  const DocumentMessageView({Key? key, required this.chatMessage, this.search = ""})
      : super(key: key);
  final ChatMessageModel chatMessage;
  final String search;

  onDocumentClick() {
    openDocument(chatMessage.mediaChatMessage!.mediaLocalStoragePath.value);
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = Get.width;
    return InkWell(
      onTap: () {
        onDocumentClick();
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: chatMessage.isMessageSentByMe
                ? chatReplyContainerColor
                : chatReplySenderColor,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          color: Colors.transparent,
        ),
        width: screenWidth * 0.60,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
                color: chatMessage.isMessageSentByMe
                    ? chatReplyContainerColor
                    : chatReplySenderColor,
              ),
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  getImageHolder(
                      chatMessage.mediaChatMessage!.mediaFileName, 30),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: search.isEmpty
                        ? Text(
                      chatMessage.mediaChatMessage!.mediaFileName,
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                      maxLines: 2,
                    ) /*textMessageSpannableText(
                            chatMessage.mediaChatMessage!.mediaFileName
                                .checkNull(),
                            maxLines: 2,
                          )*/
                        : chatSpannedText(
                        chatMessage.mediaChatMessage!.mediaFileName
                            .checkNull(),
                        search,
                        const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                        maxLines:
                        2), /*Text(
                    chatMessage.mediaChatMessage!.mediaFileName,
                    maxLines: 2,
                        style: const TextStyle(fontSize: 12,color: Colors.black,fontWeight: FontWeight.w400),
                  )*/
                  ),
                  Obx(() {
                    return getImageOverlay(chatMessage);
                  }),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    Helper.formatBytes(
                        chatMessage.mediaChatMessage?.mediaFileSize ?? 0, 0),
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 7,
                        fontWeight: FontWeight.w400),
                  ),
                  const Spacer(),
                  chatMessage.isMessageStarred.value
                      ? SvgPicture.asset(starSmallIcon)
                      : const Offstage(),
                  const SizedBox(
                    width: 5,
                  ),
                  getMessageIndicator(
                      chatMessage.messageStatus.value,
                      chatMessage.isMessageSentByMe,
                      chatMessage.messageType,
                      chatMessage.isMessageRecalled.value),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    getChatTime(context, chatMessage.messageSentTime.toInt()),
                    style: TextStyle(
                        fontSize: 12,
                        color: chatMessage.isMessageSentByMe
                            ? durationTextColor
                            : textHintColor),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 5,
            ),
          ],
        ),
      ),
    );
  }
}

Widget getImageHolder(String mediaFileName, double size) {
  debugPrint("mediaFileName--> $mediaFileName");
  return SvgPicture.asset(getDocAsset(mediaFileName),
      width: size, height: size);
}

class VideoMessageView extends StatelessWidget {
  const VideoMessageView({Key? key,
    required this.chatMessage,
    this.search = "",
    required this.isSelected})
      : super(key: key);
  final ChatMessageModel chatMessage;
  final String search;
  final bool isSelected;

  onVideoClick() {
    switch (chatMessage.isMessageSentByMe
        ? chatMessage.mediaChatMessage?.mediaUploadStatus.value
        : chatMessage.mediaChatMessage?.mediaDownloadStatus.value) {
      case MediaDownloadStatus.isMediaDownloaded:
      case MediaUploadStatus.isMediaUploaded:
        if (chatMessage.messageType.toUpperCase() == 'VIDEO') {
          if (checkFile(chatMessage.mediaChatMessage!.mediaLocalStoragePath.value) &&
              (chatMessage.mediaChatMessage!.mediaDownloadStatus.value ==
                  MediaDownloadStatus.isMediaDownloaded ||
                  chatMessage.mediaChatMessage!.mediaDownloadStatus.value ==
                      MediaUploadStatus.isMediaUploaded ||
                  chatMessage.isMessageSentByMe)) {
            Get.toNamed(Routes.videoPlay, arguments: {
              "filePath": chatMessage.mediaChatMessage!.mediaLocalStoragePath.value,
            });
          } else {
            debugPrint("file is video but condition failed");
          }
        } else {
          debugPrint("File is not video");
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    var mediaMessage = chatMessage.mediaChatMessage!;
    return Container(
      width: Get.width * 0.60,
      padding: const EdgeInsets.all(2.0),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              InkWell(
                onTap: isSelected
                    ? null
                    : () {
                  onVideoClick();
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: imageFromBase64String(
                      mediaMessage.mediaThumbImage, context, null, null),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Row(
                  children: [
                    SvgPicture.asset(
                      mVideoIcon,
                      fit: BoxFit.contain,
                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(
                      Helper.durationToString(
                          Duration(milliseconds: mediaMessage.mediaDuration)),
                      style: const TextStyle(fontSize: 11, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Obx(() {
                return getImageOverlay(chatMessage,
                    onVideo: isSelected ? null : onVideoClick);
              }),
              mediaMessage.mediaCaptionText
                  .checkNull()
                  .isEmpty
                  ? Positioned(
                bottom: 8,
                right: 10,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    chatMessage.isMessageStarred.value
                        ? SvgPicture.asset(starSmallIcon)
                        : const Offstage(),
                    const SizedBox(
                      width: 5,
                    ),
                    getMessageIndicator(
                        chatMessage.messageStatus.value,
                        chatMessage.isMessageSentByMe,
                        chatMessage.messageType,
                        chatMessage.isMessageRecalled.value),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      getChatTime(
                          context, chatMessage.messageSentTime.toInt()),
                      style: TextStyle(
                          fontSize: 11,
                          color: chatMessage.isMessageSentByMe
                              ? durationTextColor
                              : textHintColor),
                    ),
                  ],
                ),
              )
                  : const SizedBox(),
            ],
          ),
          mediaMessage.mediaCaptionText
              .checkNull()
              .isNotEmpty
              ? setCaptionMessage(mediaMessage, chatMessage, context,
              search: search)
              : const SizedBox()
        ],
      ),
    );
  }
}

/*class ImageMessageView extends StatelessWidget {
  const ImageMessageView({Key? key,
    required this.chatMessage,
    this.search = "",
    required this.isSelected})
      : super(key: key);
  final ChatMessageModel chatMessage;
  final String search;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    LogMessage.d("ImageMessageView", "build ${chatMessage.messageId}");
    var mediaMessage = chatMessage.mediaChatMessage!;
    return Container(
      width: Get.width * 0.60,
      padding: const EdgeInsets.all(2.0),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: getImage(
                    mediaMessage.mediaLocalStoragePath,
                    mediaMessage.mediaThumbImage,
                    context,
                    mediaMessage.mediaFileName,
                    isSelected),
              ),
              Obx(() {
                return getImageOverlay(chatMessage);
              }),
              mediaMessage.mediaCaptionText
                  .checkNull()
                  .isEmpty
                  ? Positioned(
                bottom: 8,
                right: 10,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    chatMessage.isMessageStarred.value
                        ? SvgPicture.asset(starSmallIcon)
                        : const Offstage(),
                    const SizedBox(
                      width: 5,
                    ),
                    getMessageIndicator(
                        chatMessage.messageStatus.value,
                        chatMessage.isMessageSentByMe,
                        chatMessage.messageType,
                        chatMessage.isMessageRecalled.value),
                    const SizedBox(
                      width: 4,
                    ),
                    Stack(
                      children: [
                        // Image.asset(cornerShadow,width: 40,height: 20,fit: BoxFit.fitHeight,),
                        Text(
                          getChatTime(context,
                              chatMessage.messageSentTime.toInt()),
                          style: TextStyle(
                              fontSize: 11,
                              color: chatMessage.isMessageSentByMe
                                  ? durationTextColor
                                  : textButtonColor),
                        ),
                      ],
                    ),
                  ],
                ),
              )
                  : const SizedBox(),
            ],
          ),
          mediaMessage.mediaCaptionText
              .checkNull()
              .isNotEmpty
              ? setCaptionMessage(mediaMessage, chatMessage, context,
              search: search)
              : const SizedBox(),
        ],
      ),
    );
  }

  getImage(RxString mediaLocalStoragePath, String mediaThumbImage,
      BuildContext context, String mediaFileName, bool isSelected) {
    debugPrint("getImage mediaLocalStoragePath : $mediaLocalStoragePath");
    if (checkFile(mediaLocalStoragePath.value)) {
      return InkWell(
          onTap: isSelected
              ? null
              : () {
            Get.toNamed(Routes.imageView, arguments: {
              'imageName': mediaFileName,
              'imagePath': mediaLocalStoragePath.value
            });
          },
          child: Obx(() {
            return Image(
              image: FileImage(File(mediaLocalStoragePath.value)),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return FutureBuilder(
                      future: null,
                      builder: (context, d) {
                        return child;
                      });
                }
                return const Center(child: CircularProgressIndicator());
              },
              frameBuilder: (cxt,child,frame,wasSynchronouslyLoaded){
                debugPrint("getImage frameBuilder : frame : $frame ,wasSynchronouslyLoaded :$wasSynchronouslyLoaded");
                return child;
              },
              errorBuilder: (cxt,obj,strace){
                debugPrint("getImage errorBuilder : obj : $obj ,strace :$strace");
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("$obj"),
                );
              },
              width: Get.width * 0.60,
              height: Get.height * 0.4,
              fit: BoxFit.cover,
            );
          })
      );
    } else {
      return imageFromBase64String(mediaThumbImage, context, null, null);
    }
  }
}*/

Widget setCaptionMessage(MediaChatMessage mediaMessage,
    ChatMessageModel chatMessage, BuildContext context,
    {String search = ""}) {
  return Padding(
    padding: const EdgeInsets.all(10.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        search.isEmpty
            ? textMessageSpannableText(
            mediaMessage.mediaCaptionText.checkNull())
            : chatSpannedText(
          mediaMessage.mediaCaptionText.checkNull(),
          search,
          const TextStyle(fontSize: 14, color: textHintColor),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            chatMessage.isMessageStarred.value
                ? SvgPicture.asset(starSmallIcon)
                : const Offstage(),
            const SizedBox(
              width: 5,
            ),
            getMessageIndicator(
                chatMessage.messageStatus.value,
                chatMessage.isMessageSentByMe,
                chatMessage.messageType,
                chatMessage.isMessageRecalled.value),
            const SizedBox(
              width: 5,
            ),

            if (chatMessage.isMessageEdited.value) ... [
              Text(getTranslated("edited"), style: const TextStyle(
                  fontSize: 11)),
              const SizedBox(width: 5,),
            ],
            Text(
              getChatTime(context, chatMessage.messageSentTime.toInt()),
              style: TextStyle(
                  fontSize: 12,
                  color: chatMessage.isMessageSentByMe
                      ? durationTextColor
                      : textHintColor),
            ),
          ],
        ),
      ],
    ),
  );
}

class NotificationMessageView extends StatelessWidget {
  const NotificationMessageView({Key? key, required this.chatMessage})
      : super(key: key);
  final String? chatMessage;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
        decoration: const BoxDecoration(
            color: notificationTextBgColor,
            borderRadius: BorderRadius.all(Radius.circular(15))),
        child: Text(chatMessage ?? "",
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: notificationTextColor)),
      ),
    );
  }
}

class MessageContent extends StatelessWidget {
  const MessageContent({Key? key,
    required this.chatList,
    required this.index,
    this.search = "",
    this.isSelected = false,
    required this.onPlayAudio,
    required this.onSeekbarChange})
      : super(key: key);
  final List<ChatMessageModel> chatList;
  final int index;
  final Function() onPlayAudio;
  final Function(double) onSeekbarChange;
  final String search;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    LogMessage.d("MessageContent", "build ${chatList[index].messageId}");
    var chatMessage = chatList[index];
    //LogMessage.d("message==>", json.encode(chatMessage));
    // debugPrint("Message Type===> ${chatMessage.messageType}");
    if (chatList[index].isMessageRecalled.value) {
      return RecalledMessageView(
        chatMessage: chatMessage,
      );
    } else {
      if (chatList[index].messageType.toUpperCase() == Constants.mText ||
          chatList[index].messageType.toUpperCase() == Constants.mAutoText) {
        return TextMessageView(
          chatMessage: chatMessage,
          search: search,
        );
      } else if (chatList[index].messageType.toUpperCase() ==
          Constants.mNotification) {
        return NotificationMessageView(
            chatMessage: chatMessage.messageTextContent);
      } else if (chatList[index].messageType.toUpperCase() ==
          Constants.mLocation) {
        if (chatList[index].locationChatMessage == null) {
          return const Offstage();
        }
        return LocationMessageView(
          chatMessage: chatMessage,
          isSelected: isSelected,
        );
      } else if (chatList[index].messageType.toUpperCase() ==
          Constants.mContact) {
        if (chatList[index].contactChatMessage == null) {
          return const Offstage();
        }
        return ContactMessageView(
          chatMessage: chatMessage,
          search: search,
          isSelected: isSelected,
        );
      } else {
        if (chatList[index].mediaChatMessage == null) {
          return const Offstage();
        } else {
          if (chatList[index].messageType.toUpperCase() == Constants.mImage) {
            return ImageMessageView(
                chatMessage: chatMessage,
                search: search,
                isSelected: isSelected);
          } else if (chatList[index].messageType.toUpperCase() ==
              Constants.mVideo) {
            return VideoMessageView(
                chatMessage: chatMessage,
                search: search,
                isSelected: isSelected);
          } else if (chatList[index].messageType.toUpperCase() ==
              Constants.mDocument ||
              chatList[index].messageType.toUpperCase() == Constants.mFile) {
            return DocumentMessageView(
              chatMessage: chatMessage,
              search: search,
            );
          } else if (chatList[index].messageType.toUpperCase() ==
              Constants.mAudio) {
            return AudioMessageView(
              chatMessage: chatMessage,
              onPlayAudio: onPlayAudio,
              onSeekbarChange: onSeekbarChange,
            );
          } else {
            return const Offstage();
          }
        }
      }
    }
  }
}

class TextMessageView extends StatelessWidget {
  const TextMessageView({
    Key? key,
    required this.chatMessage,
    this.search = "",
  }) : super(key: key);
  final ChatMessageModel chatMessage;
  final String search;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 5, 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: chatMessage.replyParentChatMessage == null
                ? MainAxisSize.min
                : MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flexible(
                child: search.isEmpty
                    ? textMessageSpannableText(chatMessage.messageTextContent ?? "")
                    : chatSpannedText(
                  chatMessage.messageTextContent ?? "",
                  search,
                  const TextStyle(fontSize: 14, color: textHintColor),
                ),
              ),
              const SizedBox(width: 60,),
            ],
          ),
          Row(
            mainAxisSize: chatMessage.replyParentChatMessage == null
                ? MainAxisSize.min
                : MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              chatMessage.isMessageStarred.value
                  ? SvgPicture.asset(starSmallIcon)
                  : const Offstage(),
              const SizedBox(
                width: 5,
              ),
              getMessageIndicator(
                  chatMessage.messageStatus.value,
                  chatMessage.isMessageSentByMe,
                  chatMessage.messageType,
                  chatMessage.isMessageRecalled.value),
              const SizedBox(
                width: 5,
              ),
              if (chatMessage.isMessageEdited.value) ... [
                Text(getTranslated("edited"), style: const TextStyle(
                    fontSize: 11)),
                const SizedBox(width: 5,),
              ],
              Text(
                getChatTime(context, chatMessage.messageSentTime.toInt()),
                style: TextStyle(
                    fontSize: 11,
                    color: chatMessage.isMessageSentByMe
                        ? durationTextColor
                        : textHintColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RecalledMessageView extends StatelessWidget {
  const RecalledMessageView({Key? key, required this.chatMessage})
      : super(key: key);
  final ChatMessageModel chatMessage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisSize: chatMessage.replyParentChatMessage == null
            ? MainAxisSize.min
            : MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Row(
              children: [
                Image.asset(
                  disabledIcon,
                  width: 15,
                  height: 15,
                ),
                const SizedBox(width: 10),
                Text(
                  chatMessage.isMessageSentByMe
                      ? getTranslated("youDeletedThisMessage")
                      : getTranslated("thisMessageWasDeleted"),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Row(
            children: [
              Text(
                getChatTime(context, chatMessage.messageSentTime.toInt()),
                style: TextStyle(
                    fontSize: 12,
                    color: chatMessage.isMessageSentByMe
                        ? durationTextColor
                        : textHintColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

getMessageIndicator(String? messageStatus, bool isSender, String messageType, bool isRecalled) {
  // debugPrint("Message Status ==>");
  // debugPrint("Message Status ==> $messageStatus");
  if (messageType.toUpperCase() != Constants.mNotification) {
    if (isSender && !isRecalled) {
      if (messageStatus == 'A') {
        return SvgPicture.asset(acknowledgedIcon);
      } else if (messageStatus == 'D') {
        return SvgPicture.asset(deliveredIcon);
      } else if (messageStatus == 'S') {
        return SvgPicture.asset(seenIcon);
      } else if (messageStatus == 'N') {
        return SvgPicture.asset(unSendIcon);
      } else {
        return const Offstage();
      }
    } else {
      return const Offstage();
    }
  } else {
    return const Offstage();
  }
}

Widget getImageOverlay(ChatMessageModel chatMessage,
    {Function()? onAudio, Function()? onVideo, int? progress}) {
  debugPrint("getImageOverlay media exists ${AppUtils.isMediaExists(chatMessage.mediaChatMessage!.mediaLocalStoragePath.value)}");
  // debugPrint(
  //     "getImageOverlay checkFile ${checkFile(chatMessage.mediaChatMessage!.mediaLocalStoragePath)}");
  // debugPrint("getImageOverlay messageStatus ${chatMessage.messageStatus}");
  // debugPrint(
  //     "getImageOverlay ${(checkFile(chatMessage.mediaChatMessage!.mediaLocalStoragePath) && chatMessage.messageStatus != 'N')}");

  debugPrint("isMediaDownloading ${chatMessage.isMediaDownloading()}");
  debugPrint("isMediaUploading ${chatMessage.isMediaUploading()}");

  debugPrint("#Media upload status ${chatMessage.mediaChatMessage!.mediaUploadStatus.value}");
  debugPrint("#Media download status ${chatMessage.mediaChatMessage!.mediaDownloadStatus.value}");
  if (AppUtils.isMediaExists(chatMessage.mediaChatMessage!.mediaLocalStoragePath.value) && (!chatMessage.isMediaDownloading() && !chatMessage.isMediaUploading() && !chatMessage.isUploadFailed())) {
    if (chatMessage.messageType.toUpperCase() == 'VIDEO') {
      return FloatingActionButton.small(
        heroTag: chatMessage.messageId,
        onPressed: onVideo,
        backgroundColor: Colors.white,
        child: const Icon(
          Icons.play_arrow_rounded,
          color: buttonBgColor,
        ),
      );
    } else if (chatMessage.messageType.toUpperCase() == 'AUDIO') {
      return InkWell(
        onTap: onAudio,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Container(
              height: 30,
              width: 30,
              padding: const EdgeInsets.all(7),
              child: SvgPicture.asset(
                chatMessage.mediaChatMessage!.isPlaying ? pauseIcon : playIcon,
                height: 17,
              ))
        ),
      ); //const Icon(Icons.play_arrow_sharp);
    } else {
      return const Offstage();
    }
  } else {
    var status = 0;
    if(chatMessage.isMessageSentByMe){
      if(chatMessage.mediaChatMessage!.mediaUploadStatus.value == MediaUploadStatus.isMediaUploading || chatMessage.mediaChatMessage!.mediaDownloadStatus.value == MediaDownloadStatus.isMediaDownloading ){
        status = (chatMessage.mediaChatMessage!.mediaUploadStatus.value == MediaUploadStatus.isMediaUploading) ? MediaUploadStatus.isMediaUploading : MediaDownloadStatus.isMediaDownloading;
      }else {
        if (chatMessage.mediaChatMessage!
            .mediaLocalStoragePath.value
            .checkNull()
            .isNotEmpty) {
          if (!AppUtils.isMediaExists(chatMessage.mediaChatMessage!.mediaLocalStoragePath.value.checkNull())) {
            if (chatMessage.mediaChatMessage!.mediaUploadStatus.value == MediaUploadStatus.isMediaUploaded) {
              status = MediaDownloadStatus.isMediaNotDownloaded; // for uploaded and deleted in local
            } else {
               status = -1;
              //status = MediaDownloadStatus.isMediaNotDownloaded;
            }
          } else {
            status = chatMessage.mediaChatMessage!.mediaUploadStatus.value;
          }
        } else {
          status = chatMessage.mediaChatMessage!.mediaUploadStatus.value;
        }
      }
    }else{
      status = chatMessage.mediaChatMessage!.mediaDownloadStatus.value;
    }
    debugPrint("mediaStatus : $status  messageId ${chatMessage.messageId}");
    // debugPrint(
    //     "overlay status-->${chatMessage.isMessageSentByMe ? chatMessage.mediaChatMessage!.mediaUploadStatus : chatMessage.mediaChatMessage!.mediaDownloadStatus}");
    switch (status) {
      case MediaDownloadStatus.isMediaDownloaded:
      case MediaUploadStatus.isMediaUploaded:
      case MediaDownloadStatus.isStorageNotEnough:
        if (!AppUtils.isMediaExists(chatMessage.mediaChatMessage!.mediaLocalStoragePath.value.checkNull())) {
          return InkWell(
            child: downloadView(
                chatMessage.mediaChatMessage!.mediaFileSize,
                chatMessage.messageType.toUpperCase()),
            onTap: () {
              downloadMedia(chatMessage.messageId);
            },
          );
        } else {
          return const Offstage();
        }
      case MediaDownloadStatus.isMediaDownloadedNotAvailable:
      case MediaUploadStatus.isMediaUploadedNotAvailable:
        return InkWell(
          child: downloadView(
              chatMessage.mediaChatMessage!.mediaFileSize,
              chatMessage.messageType.toUpperCase()),
          onTap: () {
            downloadMedia(chatMessage.messageId);
          },
        );
      case MediaDownloadStatus.isMediaNotDownloaded:
        return InkWell(
          child: downloadView(
              chatMessage.mediaChatMessage!.mediaFileSize,
              chatMessage.messageType.toUpperCase()),
          onTap: () {
            downloadMedia(chatMessage.messageId);
          },
        );
      case MediaUploadStatus.isMediaNotUploaded:
        return InkWell(
            onTap: () {
              debugPrint("upload Media ==> ${chatMessage.messageId}");
              uploadMedia(chatMessage.messageId);
            },
            child: uploadView(chatMessage.messageType.toUpperCase()));
      case MediaDownloadStatus.isMediaDownloading:
      case MediaUploadStatus.isMediaUploading:
        return Obx(() {
          return InkWell(onTap: () {
            cancelMediaUploadOrDownload(chatMessage.messageId);
          }, child: downloadingOrUploadingView(chatMessage.messageType,
              chatMessage.mediaChatMessage!.mediaProgressStatus.value)
          );
        });
      default:
        return InkWell(
            onTap: () {
              toToast(getTranslated("mediaDoesNotExist"));
            },
            child: uploadView(chatMessage.messageType.toUpperCase()));
    }
  }
}

Widget uploadView(String messageType) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: messageType == 'AUDIO' || messageType == 'DOCUMENT'
        ? Container(
      height: 30,
      width: 30,
        decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(3)),
        padding: const EdgeInsets.all(7),
        child: SvgPicture.asset(
          uploadIcon,
          colorFilter: const ColorFilter.mode(playIconColor, BlendMode.srcIn),
        ))
        : Container(
        height: 35,
        width: 80,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          color: Colors.black45,
        ),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(uploadIcon),
            const SizedBox(
              width: 5,
            ),
            Text(
              getTranslated("retry").toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ],
        )),
  );
}

void cancelMediaUploadOrDownload(String messageId) {
  AppUtils.isNetConnected().then((value) {
    if(value){
      Mirrorfly.cancelMediaUploadOrDownload(messageId: messageId);
    } else {
      toToast(getTranslated("noInternetConnection"));
    }
  });
}

void uploadMedia(String messageId) async {
  if (await AppUtils.isNetConnected()) {
    Mirrorfly.uploadMedia(messageId: messageId);
  } else {
    toToast(getTranslated("noInternetConnection"));
  }
}

void downloadMedia(String messageId) async {
  debugPrint("media download click");
  debugPrint("media download click--> $messageId");
  if (await AppUtils.isNetConnected()) {
    var permission = await AppPermission.getStoragePermission(permissionContent: getTranslated("writeStoragePermissionContent"),deniedContent: getTranslated("writeStoragePermissionDeniedContent"));
    if (permission) {
      debugPrint("media permission granted");
      Mirrorfly.downloadMedia(messageId: messageId);
    } else {
      debugPrint("storage permission not granted");
    }
  } else {
    toToast(getTranslated("noInternetConnection"));
  }
}

Widget downloadView(int mediaFileSize, String messageType) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0),
    child: messageType == 'AUDIO' || messageType == 'DOCUMENT'
        ? Container(
      height: 30,
        width: 30,
        decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(3)),
        padding: const EdgeInsets.all(7),
        child: SvgPicture.asset(
          downloadIcon,
          colorFilter: const ColorFilter.mode(playIconColor, BlendMode.srcIn),
        ))
        : Container(
      height: 35,
        width: 80,
        decoration: BoxDecoration(
          border: Border.all(
            color: textColor,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          color: Colors.black38,
        ),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(downloadIcon),
            const SizedBox(
              width: 5,
            ),
            Text(
              Helper.formatBytes(mediaFileSize, 0),
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ],
        )),
  );
}

downloadingOrUploadingView(String messageType, int progress) {
  debugPrint('downloadingOrUploadingView progress $progress');
  if (messageType == MessageType.audio.value || messageType == MessageType.document.value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            border: Border.all(
              color: borderColor,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(3)),
            // color: Colors.black45,
          ),
          child: Stack(
              alignment: Alignment.center,
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  downloading,
                  fit: BoxFit.contain,
                  colorFilter: const ColorFilter.mode(playIconColor, BlendMode.srcIn),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    height: 2,
                    child: LinearProgressIndicator(
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        progressColor,
                      ),
                      value: progress == 0 || progress == 100
                          ? null
                          : (progress / 100),
                      backgroundColor: Colors.transparent,
                      // minHeight: 1,
                    ),
                  ),
                ),
              ])),
    );
  } else {
    return Container(
        height: 35,
        width: 80,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          color: Colors.black45,
        ),
        child: Stack(
            alignment: Alignment.center,
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                downloading,
                fit: BoxFit.contain,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: 2,
                  child: LinearProgressIndicator(
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                    value: progress == 0 || progress == 100
                        ? null
                        : (progress / 100),
                    backgroundColor: Colors.transparent,
                    // minHeight: 1,
                  ),
                ),
              ),
            ]));
  }
}

class AttachmentsSheetView extends StatelessWidget {
  const AttachmentsSheetView({Key? key,
    required this.availableFeatures,
    required this.attachments,
    required this.onDocument,
    required this.onCamera,
    required this.onGallery,
    required this.onAudio,
    required this.onContact,
    required this.onLocation})
      : super(key: key);
  final Rx<AvailableFeatures> availableFeatures;
  final RxList<AttachmentIcon> attachments;
  final Function() onDocument;
  final Function() onCamera;
  final Function() onGallery;
  final Function() onAudio;
  final Function() onContact;
  final Function() onLocation;


  @override
  Widget build(BuildContext context) {
    LogMessage.d("attachments", attachments.length);
    // final attachments = [AttachmentIcon(documentImg, "Document", onDocument),AttachmentIcon(cameraImg, "Camera", onCamera),AttachmentIcon(galleryImg, "Gallery", onGallery),AttachmentIcon(audioImg, "Audio", onAudio),AttachmentIcon(contactImg, "Contact", onContact),AttachmentIcon(locationImg, "Location", onLocation)];
    return Card(
      color: bottomSheetColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        height: 250,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Obx(() {
          return GridView.builder(gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3,
              childAspectRatio: 1
          ),
              itemCount: attachments.length,
              shrinkWrap: true,
              itemBuilder: (BuildContext ctx, index) {
                LogMessage.d("attachments", attachments[index].text);
                return iconCreation(
                    attachments[index].iconPath, attachments[index].text,
                    (attachments[index].text == "Document") ? onDocument :
                    (attachments[index].text == "Camera") ? onCamera :
                    (attachments[index].text == "Gallery") ? onGallery :
                    (attachments[index].text == "Audio") ? onAudio :
                    (attachments[index].text == "Contact") ? onContact :
                    (attachments[index].text == "Location") ? onLocation : () {});
              });
        }),
        /*Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  availableFeatures.value.isDocumentAttachmentAvailable.checkNull() ? iconCreation(
                      documentImg, "Document", onDocument) : const Offstage(),
                  (availableFeatures.value.isImageAttachmentAvailable.checkNull() ||
                      availableFeatures.value.isVideoAttachmentAvailable.checkNull()) ? iconCreation(
                      cameraImg, "Camera", onCamera) : const Offstage(),
                  (availableFeatures.value.isImageAttachmentAvailable.checkNull() ||
                      availableFeatures.value.isVideoAttachmentAvailable.checkNull()) ? iconCreation(
                      galleryImg, "Gallery", onGallery) : const Offstage(),
                ],
              );
            }),
            const SizedBox(
              height: 35,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                availableFeatures.value.isAudioAttachmentAvailable.checkNull() ? iconCreation(
                    audioImg, "Audio", onAudio) : const Offstage(),
                availableFeatures.value.isContactAttachmentAvailable.checkNull() ? iconCreation(
                    contactImg, "Contact", onContact) : const Offstage(),
                availableFeatures.value.isLocationAttachmentAvailable.checkNull() ? iconCreation(
                    locationImg, "Location", onLocation) : const Offstage(),
              ],
            ),
          ],
        ),*/
      ),
    );
  }
}

class AttachmentIcon {
  String iconPath;
  String text;

  AttachmentIcon(this.iconPath, this.text);
}

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

Widget chatSpannedText(String text, String spannableText, TextStyle? style,
    {int? maxLines}) {
  var startIndex = text.toLowerCase().contains(spannableText.toLowerCase())
      ? text.toLowerCase().indexOf(spannableText.toLowerCase())
      : -1;
  var endIndex = startIndex + spannableText.length;
  if (startIndex != -1 && endIndex != -1) {
    var startText = text.substring(0, startIndex);
    var colorText = text.substring(startIndex, endIndex);
    var endText = text.substring(endIndex, text.length);
    return Text.rich(
      TextSpan(
          text: startText,
          children: [
            TextSpan(
                text: colorText, style: const TextStyle(color: Colors.orange)),
            TextSpan(text: endText)
          ],
          style: style),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  } else {
    return textMessageSpannableText(text,
        maxLines: maxLines); //Text(text, style: style);
  }
}

/*handleMediaUploadDownload(
    int mediaDownloadStatus, ChatMessageModel chatList) {
  switch (chatList.isMessageSentByMe
      ? chatList.mediaChatMessage?.mediaUploadStatus
      : mediaDownloadStatus) {
    case Constants.mediaDownloaded:
    case Constants.mediaUploaded:
      if (chatList.messageType.toUpperCase() == 'VIDEO') {
        if (checkFile(
            chatList.mediaChatMessage!.mediaLocalStoragePath) &&
            (chatList.mediaChatMessage!.mediaDownloadStatus ==
                Constants.mediaDownloaded ||
                chatList.mediaChatMessage!.mediaDownloadStatus ==
                    Constants.mediaUploaded ||
                chatList.isMessageSentByMe)) {
          Get.toNamed(Routes.videoPlay, arguments: {
            "filePath": chatList.mediaChatMessage!.mediaLocalStoragePath,
          });
        }
      }
      if (chatList.messageType.toUpperCase() == 'AUDIO') {
        if (checkFile(
            chatList.mediaChatMessage!.mediaLocalStoragePath) &&
            (chatList.mediaChatMessage!.mediaDownloadStatus ==
                Constants.mediaDownloaded ||
                chatList.mediaChatMessage!.mediaDownloadStatus ==
                    Constants.mediaUploaded ||
                chatList.isMessageSentByMe)) {
          debugPrint("audio click1");
          //playAudio(chatList, chatList.mediaChatMessage!.mediaLocalStoragePath);
        } else {
          debugPrint("condition failed");
        }
      }
      break;

    case Constants.mediaDownloadedNotAvailable:
    case MediaDownloadStatus.isMediaNotDownloaded:
    //download
      debugPrint("Download");
      debugPrint(chatList.messageId);
      chatList.mediaChatMessage!.mediaDownloadStatus =
          MediaDownloadStatus.isMediaDownloading;
      downloadMedia(chatList.messageId);
      break;
    case Constants.mediaUploadedNotAvailable:
    //upload
      break;
    case MediaUploadStatus.isMediaNotUploaded:
    case MediaDownloadStatus.isMediaDownloading:
    case MediaUploadStatus.isMediaUploading:
      return uploadingView(chatList.messageType);
  // break;
  }
}*/

/*class AudioMessagePlayerController extends GetxController {
  final _obj = ''.obs;

  set obj(value) => _obj.value = value;

  get obj => _obj.value;
  var maxDuration = 100.obs;
  var currentPos = 0.obs;
  var currentPlayingPosId = "0".obs;
  String currentPostLabel = "00:00";
  var audioPlayed = false.obs;
  AudioPlayer player = AudioPlayer();

  @override
  void onInit() {
    super.onInit();
    player.onPlayerCompletion.listen((event) {
      playingChat!.mediaChatMessage!.isPlaying = false;
      playingChat!.mediaChatMessage!.currentPos = 0;
      player.stop();
      //chatList.refresh();
    });

    player.onAudioPositionChanged.listen((Duration p) {
      playingChat?.mediaChatMessage!.currentPos = (p.inMilliseconds);
      //chatList.refresh();
    });
  }

  ChatMessageModel? playingChat;

  playAudio(ChatMessageModel chatMessage, String filePath) async {
    if (playingChat != null) {
      if (playingChat?.mediaChatMessage!.messageId != chatMessage.messageId) {
        player.stop();
        playingChat?.mediaChatMessage!.isPlaying = false;
        playingChat = chatMessage;
      }
    } else {
      playingChat = chatMessage;
    }
    if (!playingChat!.mediaChatMessage!.isPlaying) {
      int result = await player.play(
          playingChat!.mediaChatMessage!.mediaLocalStoragePath.value,
          position:
          Duration(milliseconds: playingChat!.mediaChatMessage!.currentPos),
          isLocal: true);
      if (result == 1) {
        playingChat!.mediaChatMessage!.isPlaying = true;
      } else {
        LogMessage.d("", "Error while playing audio.");
      }
    } else if (!playingChat!.mediaChatMessage!.isPlaying) {
      int result = await player.resume();
      if (result == 1) {
        playingChat!.mediaChatMessage!.isPlaying = true;
      } else {
        LogMessage.d("", "Error on resume audio.");
      }
    } else {
      int result = await player.pause();
      if (result == 1) {
        playingChat!.mediaChatMessage!.isPlaying = false;
      } else {
        LogMessage.d("", "Error on pause audio.");
      }
    }
  }
}*/

/// Checks the current header id with previous header id
/// @param position Position of the current item
/// @return boolean True if header changed, else false
bool isDateChanged(int position, List<ChatMessageModel> mChatData) {
  // try {
  var prePosition = position + 1;
  var size = mChatData.length - 1;
  if (position == size) {
    return true;
  } else {
    if (prePosition <= size && position <= size) {
      // debugPrint("position $position $size");
      // debugPrint("sentTime ${mChatData[position].messageSentTime}");
      // debugPrint("pre sentTime ${mChatData[prePosition].messageSentTime}");
      var currentHeaderId = mChatData[position].messageSentTime.toInt();
      var previousHeaderId = mChatData[prePosition].messageSentTime.toInt();
      return currentHeaderId != previousHeaderId;
    }
  }
  // }catch(e){
  //   return false;
  // }
  return false; //currentHeaderId != previousHeaderId;
}

String? groupedDateMessage(int index, List<ChatMessageModel> chatList) {
  if(index.isNegative){
    return null;
  }
  if (index == chatList.length - 1) {
    return addDateHeaderMessage(chatList.last);
  } else {
    return (isDateChanged(index, chatList) &&
        (addDateHeaderMessage(chatList[index + 1]) !=
            addDateHeaderMessage(chatList[index])))
        ? addDateHeaderMessage(chatList[index])
        : null;
  }
}

String addDateHeaderMessage(ChatMessageModel item) {
  var calendar = DateTime.now();
  var messageDate = getDateFromTimestamp(item.messageSentTime, "MMMM dd, yyyy");
  var monthNumber = calendar.month - 1;
  var month = getMonthForInt(monthNumber);
  var yesterdayDate = DateTime
      .now()
      .subtract(const Duration(days: 1))
      .day;
  var today = "$month ${checkTwoDigitsForDate(calendar.day)}, ${calendar.year}";
  var yesterday =
      "$month ${checkTwoDigitsForDate(yesterdayDate)}, ${calendar.year}";
  // var dateHeaderMessage = ChatMessage()
  // debugPrint("messageDate $messageDate");
  // debugPrint("today $today");
  // debugPrint("yesterday $yesterday");
  if (messageDate.toString() == (today).toString()) {
    return getTranslated("today");
    //dateHeaderMessage = createDateHeaderMessageWithDate(date, item)
  } else if (messageDate == yesterday) {
    return getTranslated("yesterday");
    //dateHeaderMessage = createDateHeaderMessageWithDate(date, item)
  } else if (!messageDate.contains("1970")) {
    //dateHeaderMessage = createDateHeaderMessageWithDate(messageDate, item)
    return messageDate;
  }
  return "";
}

String checkTwoDigitsForDate(int date) {
  if (date
      .toString()
      .length != 2) {
    return "0$date";
  } else {
    return date.toString();
  }
}

String getMonthForInt(int num) {
  var month = "";
  var dateFormatSymbols = DateFormat().dateSymbols.STANDALONEMONTHS;
  var months = dateFormatSymbols;
  if (num <= 11) {
    month = months[num];
  }
  return month;
}


class GetBoxOffset extends StatefulWidget {
  final Widget child;
  final Function(Offset offset) offset;

  const GetBoxOffset({Key? key, required this.child, required this.offset}) : super(key: key);

  @override
  GetBoxOffsetState createState() => GetBoxOffsetState();
}

class GetBoxOffsetState extends State<GetBoxOffset> {
  GlobalKey widgetKey = GlobalKey();

  Offset offset = const Offset(0.0, 0.0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = widgetKey.currentContext?.findRenderObject() as RenderBox;
      offset = box.localToGlobal(Offset.zero);
      widget.offset(offset);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: widgetKey,
      child: widget.child,
    );
  }
}