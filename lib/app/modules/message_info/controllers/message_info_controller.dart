import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:mirrorfly_chat/mirrorflychat.dart';
import 'package:mirror_fly_demo/app/modules/chat/controllers/chat_controller.dart';

import '../../../common/constants.dart';
import '../../../data/helper.dart';
import '../../../data/permissions.dart';
import '../../../model/chat_message_model.dart';

class MessageInfoController extends GetxController {
  var chatController = Get.find<ChatController>();

  var messageID = Get.arguments["messageID"];
  var jid = Get.arguments["jid"];
  var isGroupProfile = Get.arguments["isGroupProfile"];
  var chatMessage = [Get.arguments["chatMessage"] as ChatMessageModel].obs;
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
    var permission = await AppPermission.getStoragePermission();
    if (permission) {
      Mirrorfly.downloadMedia(messageId);
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
        mirrorFlyLog("", "Error while playing audio.");
      }
    } else if (!playingChat!.mediaChatMessage!.isPlaying) {
      int result = await player.resume();
      if (result == 1) {
        playingChat!.mediaChatMessage!.isPlaying=true;
        this.chatMessage.refresh();
      } else {
        mirrorFlyLog("", "Error on resume audio.");
      }
    } else {
      int result = await player.pause();
      if (result == 1) {
        playingChat!.mediaChatMessage!.isPlaying=false;
        this.chatMessage.refresh();
      } else {
        mirrorFlyLog("", "Error on pause audio.");
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

  var messageDeliveredList = <DeliveredParticipantList>[].obs;
  var messageReadList = <DeliveredParticipantList>[].obs;
  var statusCount = 0.obs;
  String chatDate(BuildContext cxt,DeliveredParticipantList item) => getChatTime(cxt, int.parse(item.time.checkNull()));
  getMessageStatus(String messageId) async {
    var delivered = await Mirrorfly.getGroupMessageDeliveredToList(messageId, jid);
    mirrorFlyLog("deliveredResp", delivered);
    var item = MessageDeliveredStatus.fromJson(json.decode(delivered), "delivered");
    statusCount(item.totalParticipatCount!);
    messageDeliveredList(item.participantList);


    var read = await Mirrorfly.getGroupMessageReadByList(messageId, jid);
    mirrorFlyLog("readResp", read);
    var readItem = MessageDeliveredStatus.fromJson(json.decode(read), "read");
    messageReadList(readItem.participantList);
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
    // mirrorFlyLog("MESSAGE STATUS UPDATED on Info", chatMessageModel.messageId);
    if(chatMessageModel.messageId == chatMessage[0].messageId){
      chatMessage[0]=chatMessageModel;
      chatMessage.refresh();
      getStatusOfMessage(chatMessageModel.messageId);
    }
  }
  
  getStatusOfMessage(String messageId){
    if(!isGroupProfile) {
      Mirrorfly.getMessageStatusOfASingleChatMessage(messageId).then((value) {
        var response = json.decode(value);
        readTime(response["seenTime"]);
        deliveredTime(response["deliveredTime"]);
      });
    }else{
      getMessageStatus(messageId);
    }
  }
}
