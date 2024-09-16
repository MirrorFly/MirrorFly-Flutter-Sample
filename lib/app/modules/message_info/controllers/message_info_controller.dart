import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../common/app_localizations.dart';
import '../../../extensions/extensions.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';

import '../../../data/permissions.dart';
import '../../../data/utils.dart';
import '../../../model/chat_message_model.dart';

class MessageInfoController extends GetxController {

  var messageID = NavUtils.arguments["messageID"];
  var jid = NavUtils.arguments["jid"];
  var isGroupProfile = NavUtils.arguments["isGroupProfile"];
  var chatMessage = [NavUtils.arguments["chatMessage"] as ChatMessageModel].obs;
  var readTime = ''.obs;
  var deliveredTime = ''.obs;


  var calendar = DateTime.now();

  @override
  void onInit() {
    super.onInit();
    getStatusOfMessage(chatMessage.first.messageId);
  }

  String getChatTime(BuildContext context, int? epochTime) {
    if (epochTime == null) return "";
    if (epochTime == 0) return "";
    var convertedTime = epochTime; // / 1000;
    //messageDate.time = convertedTime
    var hourTime = manipulateMessageTime(
        context, DateTime.fromMicrosecondsSinceEpoch(convertedTime));
    var currentYear = DateTime.now().year;
    calendar = DateTime.fromMicrosecondsSinceEpoch(convertedTime);
    var time = (currentYear == calendar.year)
        ? DateFormat("dd-MMM-yyyy").format(calendar)
        : DateFormat("yyyy/MM/dd").format(calendar);
    return "$time at $hourTime";
  }

  String manipulateMessageTime(BuildContext context, DateTime messageDate) {
    var format = MediaQuery.of(context).alwaysUse24HourFormat ? 24 : 12;
    var hours = calendar.hour; //calendar[Calendar.HOUR]
    calendar = messageDate;
    var dateHourFormat = setDateHourFormat(format, hours);
    return DateFormat(dateHourFormat).format(messageDate);
  }

  String setDateHourFormat(int format, int hours) {
    var dateHourFormat = (format == 12)
        ? (hours < 10)
        ? "hh:mm aa"
        : "h:mm aa"
        : (hours < 10)
        ? "HH:mm"
        : "H:mm";
    return dateHourFormat;
  }

  checkFile(String mediaLocalStoragePath) {
    return mediaLocalStoragePath.isNotEmpty &&
        File(mediaLocalStoragePath).existsSync();
  }


  downloadMedia(String messageId) async {
    var permission = await AppPermission.getStoragePermission(permissionContent: getTranslated("writeStoragePermissionContent"),deniedContent: getTranslated("writeStoragePermissionDeniedContent"));
    if (permission) {
      Mirrorfly.downloadMedia(messageId: messageId);
    }
  }
  /*@override
  void onClose(){
    super.onClose();
    // player.stop();
    // player.dispose();
  }*/

  String currentPostLabel = "00:00";
  var maxDuration = 100.obs;
  var currentPos = 0.obs;
  var isPlaying = false.obs;
  var audioPlayed = false.obs;
  // AudioPlayer player = AudioPlayer();
  ChatMessageModel? playingChat;
  playAudio(ChatMessageModel chatMessage) async {
    /*setPlayingChat(chatMessage);
    if (!playingChat!.mediaChatMessage!.isPlaying) {
      int result = await player.play(playingChat!.mediaChatMessage!.mediaLocalStoragePath,position: Duration(milliseconds:playingChat!.mediaChatMessage!.currentPos), isLocal: true);
      if (result == 1) {
        playingChat!.mediaChatMessage!.isPlaying=true;
      } else {
        LogMessage.d("", "Error while playing audio.");
      }
    } else if (!playingChat!.mediaChatMessage!.isPlaying) {
      int result = await player.resume();
      if (result == 1) {
        playingChat!.mediaChatMessage!.isPlaying=true;
        this.chatMessage.refresh();
      } else {
        LogMessage.d("", "Error on resume audio.");
      }
    } else {
      int result = await player.pause();
      if (result == 1) {
        playingChat!.mediaChatMessage!.isPlaying=false;
        this.chatMessage.refresh();
      } else {
        LogMessage.d("", "Error on pause audio.");
      }
    }*/
  }

  void setPlayingChat(ChatMessageModel chatMessage) {
    /*if(playingChat!=null){
      if(playingChat?.mediaChatMessage!.messageId!=chatMessage.messageId){
        player.stop();
        playingChat?.mediaChatMessage!.isPlaying=false;
        playingChat = chatMessage;
      }
    }
    else{
      playingChat = chatMessage;
    }*/
  }

  void onSeekbarChange(double value,ChatMessageModel chatMessage) {
    /*debugPrint('onSeekbarChange $value');
    if (playingChat != null) {
      player.seek(Duration(milliseconds: value.toInt()));
    }else{
      chatMessage.mediaChatMessage?.currentPos=value.toInt();
      // this.chatMessage.refresh();
    }*/
  }

  var messageDeliveredList = <ParticipantList>[].obs;
  var messageReadList = <ParticipantList>[].obs;
  var statusCount = 0.obs;
  String chatDate(BuildContext cxt,ParticipantList item) => getChatTime(cxt, int.parse(item.time.checkNull()));
  getMessageStatus(String messageId) async {
    Mirrorfly.getGroupMessageDeliveredRecipients(messageId: messageId, groupJid: jid, flyCallBack: (FlyResponse response) {
      LogMessage.d("deliveredResp", response.data);
      if(response.hasData) {
        var item = messageStatusDetailFromJson(response.data);
        statusCount(item.totalParticipantCount!);
        messageDeliveredList(item.participantList);
      }
    });



    Mirrorfly.getGroupMessageSeenRecipients(messageId: messageId, groupJid: jid, flyCallBack: (FlyResponse response) {
      LogMessage.d("readResp", response.data);
      if(response.hasData) {
        var readItem = messageStatusDetailFromJson(response.data);
        messageReadList(readItem.participantList);
      }
    });
  }

  var visibleDeliveredList = false.obs;
  onDeliveredClick(){
    if(visibleDeliveredList.value){
      visibleDeliveredList(false);
    }else{
      visibleDeliveredList(true);
    }
  }

  var visibleReadList = false.obs;
  onReadClick(){
    if(visibleReadList.value){
      visibleReadList(false);
    }else{
      visibleReadList(true);
    }
  }

  void onMessageStatusUpdated(ChatMessageModel chatMessageModel){
    // LogMessage.d("MESSAGE STATUS UPDATED on Info", chatMessageModel.messageId);
    if(chatMessageModel.messageId == chatMessage[0].messageId){
      chatMessage[0]=chatMessageModel;
      chatMessage.refresh();
      getStatusOfMessage(chatMessageModel.messageId);
    }
  }

  void onMessageEdited(ChatMessageModel editedChatMessage) {
    if(editedChatMessage.messageId == chatMessage[0].messageId){
      chatMessage[0]=editedChatMessage;
    }
  }
  
  getStatusOfMessage(String messageId){
    if(!isGroupProfile) {
      Mirrorfly.getMessageStatusOf(messageId: messageId).then((value) {
        LogMessage.d("getMessageStatusOf", value);
        var chatMessageStatusDetail = chatMessageStatusDetailFromJson(value);
        readTime(chatMessageStatusDetail.seenTime);
        deliveredTime(chatMessageStatusDetail.deliveredTime);
      });
    }else{
      getMessageStatus(messageId);
    }
  }
}
