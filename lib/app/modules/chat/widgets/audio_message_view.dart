import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../stylesheet/stylesheet.dart';
import 'package:mirrorfly_plugin/logmessage.dart';
import 'package:mirrorfly_plugin/message_params.dart';

import '../../../common/constants.dart';
import '../../../data/helper.dart';
import '../../../data/utils.dart';
import '../../../model/chat_message_model.dart';
import 'media_message_overlay.dart';

class AudioMessageView extends StatefulWidget {
  const AudioMessageView({Key? key,
    required this.chatMessage,
    required this.onPlayAudio,
    required this.onSeekbarChange,this.audioMessageViewStyle = const AudioMessageViewStyle(), this.decoration = const BoxDecoration()})
      : super(key: key);
  final ChatMessageModel chatMessage;
  final Function() onPlayAudio;
  final Function(double) onSeekbarChange;
  final AudioMessageViewStyle audioMessageViewStyle;
  final Decoration decoration;

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
        if (MediaUtils.isMediaExists(
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
    var screenWidth = NavUtils.width;
    var currentPos = 0.0; /*double.parse(widget.chatMessage
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
      color: Colors.transparent,
      // decoration: widget.decoration,
      // decoration: BoxDecoration(
      //   border: Border.all(
      //     color: widget.chatMessage.isMessageSentByMe
      //         ? chatReplyContainerColor
      //         : chatReplySenderColor,
      //   ),
      //   borderRadius: const BorderRadius.all(Radius.circular(10)),
      //   color: Colors.transparent,
      // ),
      width: screenWidth * 0.80,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: widget.audioMessageViewStyle.decoration,
            // decoration: BoxDecoration(
            //   borderRadius: const BorderRadius.only(
            //       topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            //   color: widget.chatMessage.isMessageSentByMe
            //       ? chatReplyContainerColor
            //       : chatReplySenderColor,
            // ),
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                 CircleAvatar(radius: (30/2),
                  backgroundColor: widget.audioMessageViewStyle.iconStyle.bgColor,
                  child: widget.chatMessage.mediaChatMessage!.isAudioRecorded
                      ? AppUtils.svgIcon(icon:audioMic,
                    colorFilter: ColorFilter.mode(widget.audioMessageViewStyle.iconStyle.iconColor, BlendMode.srcIn),height: 13,)
                    : AppUtils.svgIcon(icon:musicIcon,
                  colorFilter: ColorFilter.mode(widget.audioMessageViewStyle.iconStyle.iconColor, BlendMode.srcIn),)),
                MediaMessageOverlay(chatMessage: widget.chatMessage, onAudio: () {
                    widget.onPlayAudio();
                    playAudio(widget.chatMessage,);
                  },downloadUploadViewStyle:  widget.audioMessageViewStyle.downloadUploadViewStyle,), //widget.onPlayAudio),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 8),
                        child: SliderTheme(
                          data: widget.audioMessageViewStyle.sliderThemeData.copyWith(overlayShape: SliderComponentShape.noThumb),
                          /*SliderThemeData(
                            thumbColor: audioColorDark,
                            trackHeight: 2,
                            overlayShape: SliderComponentShape.noThumb,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 4),
                          ),*/
                          child: Slider(
                            value: currentPos,
                            /*double.parse(chatMessage
                                .mediaChatMessage!.currentPos
                                .toString()),*/
                            min: 0.0,
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
                          DateTimeUtils.durationToString(Duration(
                              milliseconds: currentPos !=
                                  0.0 // chatMessage.mediaChatMessage?.currentPos != 0
                                  ? currentPos
                                  .toInt() /*chatMessage
                                              .mediaChatMessage?.currentPos ??
                                          0*/
                                  : widget.chatMessage.mediaChatMessage!
                                  .mediaDuration)),
                          style: widget.audioMessageViewStyle.durationTextStyle,
                          // style: const TextStyle(
                          //     color: durationTextColor,
                          //     fontSize: 8,
                          //     fontWeight: FontWeight.w300),
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
                    ? AppUtils.svgIcon(icon:starSmallIcon)
                    : const Offstage(),
                const SizedBox(
                  width: 5,
                ),
                MessageUtils.getMessageIndicatorIcon(
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
                  style: widget.audioMessageViewStyle.timeTextStyle,
                  /*style: TextStyle(
                      fontSize: 12,
                      color: widget.chatMessage.isMessageSentByMe
                          ? durationTextColor
                          : textHintColor),*/
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
    DialogUtils.createDialog(
      Dialog(
        child: PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) {
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
                    AppUtils.svgIcon(icon:
                      audioMicBg,
                      width: 28,
                      height: 28,
                      fit: BoxFit.contain,
                    ),
                    AppUtils.svgIcon(icon:
                      audioMic1,
                      fit: BoxFit.contain,
                    ),
                  ],
                )
                    : AppUtils.svgIcon(icon:
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
                          ? AppUtils.svgIcon(icon:
                        pauseIcon,
                        height: 17,
                      ) //const Icon(Icons.pause)
                          : AppUtils.svgIcon(icon:
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
                            overlayShape: SliderComponentShape.noThumb,
                            activeTrackColor: Colors.white,
                            inactiveTickMarkColor: borderColor,
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
                              // activeColor: Colors.white,
                              // thumbColor: audioColorDark,
                              // inactiveColor: borderColor,
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
                                DateTimeUtils.durationToString(Duration(
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
                            DateTimeUtils.durationToString(Duration(
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