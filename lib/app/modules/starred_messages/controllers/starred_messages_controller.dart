import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flysdk/flysdk.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:share_plus/share_plus.dart';

import '../../../common/constants.dart';
import '../../../routes/app_pages.dart';

class StarredMessagesController extends GetxController {
  var starredChatList = List<ChatMessageModel>.empty(growable: true).obs;
  double height = 0.0;
  double width = 0.0;
  var isSelected = false.obs;

  var isListLoading = true.obs;
  var calendar = DateTime.now();

  @override
  void onInit() {
    super.onInit();
    //getFavouriteMessages();
    player.onPlayerCompletion.listen((event) {
      playingChat!.mediaChatMessage!.isPlaying=false;
      playingChat!.mediaChatMessage!.currentPos=0;
      player.stop();
      starredChatList.refresh();
      playingChat=null;
    });

    player.onAudioPositionChanged.listen((Duration p) {
      playingChat?.mediaChatMessage!.currentPos=(p.inMilliseconds);
      starredChatList.refresh();
    });
  }

  @override
  void onClose(){
    super.onClose();
    player.stop();
    player.dispose();
  }
  getFavouriteMessages() {
    if(!isSelected.value) {
      isListLoading(true);
      FlyChat.getFavouriteMessages().then((value) {
        List<ChatMessageModel> chatMessageModel = chatMessageModelFromJson(
            value);
        starredChatList(chatMessageModel.toList());
        isListLoading(false);
      });
    }
  }
  void userUpdatedHisProfile(jid) {
    if (jid.isNotEmpty) {
      getProfileDetails(jid).then((value) {
        var messageIndex = starredChatList.indexWhere((element) => element.chatUserJid == jid);
        if(!messageIndex.isNegative){
          starredChatList.refresh();
        }
      });
    }
  }
  void onMessageStatusUpdated(chatMessageModel) {
    final index = starredChatList.indexWhere(
            (message) => message.messageId == chatMessageModel.messageId);
    debugPrint("Message Status Update index of search $index");
    if (!index.isNegative) {
      starredChatList[index].messageStatus = chatMessageModel.messageStatus;
      starredChatList.refresh();
    }
  }

  void onMediaStatusUpdated(ChatMessageModel chatMessageModel) {
    final index = starredChatList.indexWhere(
            (message) => message.messageId == chatMessageModel.messageId);
    if (!index.isNegative) {
      starredChatList[index] = chatMessageModel;
      starredChatList.refresh();
    }

    if (isSelected.value) {
      var selectedIndex = selectedChatList.indexWhere(
              (element) => chatMessageModel.messageId == element.messageId);
      if (!selectedIndex.isNegative) {
        chatMessageModel.isSelected =
        true; //selectedChatList[selectedIndex].isSelected;
        selectedChatList[selectedIndex] = chatMessageModel;
        selectedChatList.refresh();
        validateForForwardMessage();
        validateForShareMessage();
      }
    }

  }

  String getChatTime(context, int? epochTime) {
    if (epochTime == null) return "";
    if (epochTime == 0) return "";
    var convertedTime = epochTime; // / 1000;
    //messageDate.time = convertedTime
    // var hourTime = manipulateMessageTime(
    //     context, DateTime.fromMicrosecondsSinceEpoch(convertedTime));
    var currentYear = DateTime.now().year;
    calendar = DateTime.fromMicrosecondsSinceEpoch(convertedTime);
    var time = (currentYear == calendar.year)
        ? DateFormat("dd-MMM-yyyy").format(calendar)
        : DateFormat("yyyy/MM/dd").format(calendar);
    return time;
  }

  String manipulateMessageTime(context, DateTime messageDate) {
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

  var selectedChatList = List<ChatMessageModel>.empty(growable: true).obs;

  void addChatSelection(ChatMessageModel item) {
    if (item.messageType.toUpperCase() != Constants.mNotification) {
      selectedChatList.add(item);
      item.isSelected = true;
      starredChatList.refresh();
      validateForForwardMessage();
      validateForShareMessage();
    } else {
      debugPrint("Unable to Select Notification Banner");
    }
  }

  clearChatSelection(ChatMessageModel item) {
    selectedChatList.remove(item);
    item.isSelected = false;
    if (selectedChatList.isEmpty) {
      isSelected(false);
      selectedChatList.clear();
    }
    starredChatList.refresh();
    validateForForwardMessage();
    validateForShareMessage();
  }

  clearAllChatSelection() {
    isSelected(false);
    for (var chatItem in selectedChatList) {
      chatItem.isSelected = false;
    }
    selectedChatList.clear();
  }

  bool getOptionStatus(String optionName) {
    switch (optionName) {
      case 'Reply':
        return selectedChatList.length > 1 ? false : true;

      case 'Report':
        return selectedChatList.length > 1
            ? false
            : selectedChatList[0].isMessageSentByMe
                ? false
                : true;

      case 'Message Info':
        return selectedChatList.length > 1
            ? false
            : selectedChatList[0].isMessageSentByMe
                ? true
                : false;

      case 'Share':
        for (var chatList in selectedChatList) {
          if (chatList.messageType == Constants.mText ||
              chatList.messageType == Constants.mLocation ||
              chatList.messageType == Constants.mContact) {
            return false;
          }
        }
        return true;

      case 'Favourite':
        // for (var chatList in selectedChatList) {
        //   if (chatList.isMessageStarred) {
        //     return true;
        //   }
        // }
        // return false;
        return selectedChatList.length > 1 ? false : true;

      default:
        return false;
    }
  }

  checkBusyStatusForForward() async {
    var busyStatus = await FlyChat.isBusyStatusEnabled();
    if (!busyStatus.checkNull()) {
      forwardMessage();
    } else {
      showBusyStatusAlert(forwardMessage);
    }
  }

  showBusyStatusAlert(Function? function) {
    Helper.showAlert(
        message: "Disable busy status. Do you want to continue?",
        actions: [
          TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text("No")),
          TextButton(
              onPressed: () async {
                Get.back();
                await FlyChat.enableDisableBusyStatus(false);
                if (function != null) {
                  function();
                }
              },
              child: const Text("Yes")),
        ]);
  }

  forwardMessage() {
    var messageIds = List<String>.empty(growable: true);
    for (var chatItem in selectedChatList) {
      messageIds.add(chatItem.messageId);
      debugPrint(messageIds.length.toString());
      debugPrint(selectedChatList.length.toString());
    }
    if (messageIds.length == selectedChatList.length) {
      isSelected(false);
      selectedChatList.clear();
      Get.toNamed(Routes.forwardChat, arguments: {
        "forward": true,
        "group": false,
        "groupJid": "",
        "messageIds": messageIds
      })?.then((value) {
        if (value != null) {
          debugPrint(
              "result of forward ==> ${(value as Profile).toJson().toString()}");
          Get.toNamed(Routes.chat, arguments: value);
        }
      });
    }
  }

  favouriteMessage() {
    for (var item in selectedChatList) {
      FlyChat.updateFavouriteStatus(
          item.messageId, item.chatUserJid, !item.isMessageStarred, item.messageChatType);
      starredChatList
          .removeWhere((element) => item.messageId == element.messageId);
    }
    selectedChatList.clear();
    isSelected(false);
  }

  copyTextMessages() {
    Clipboard.setData(
        ClipboardData(text: selectedChatList[0].messageTextContent));
    clearChatSelection(selectedChatList[0]);
    toToast("1 Text Copied Successfully to the clipboard");
  }

  Map<bool, bool> isMessageCanbeRecalled() {
    var recallTimeDifference =
        ((DateTime.now().millisecondsSinceEpoch - 30000) * 1000);
    return {
      selectedChatList.any((element) =>
              element.isMessageSentByMe &&
              !element.isMessageRecalled &&
              (element.messageSentTime > recallTimeDifference)):
          selectedChatList.any((element) =>
              !element.isMessageRecalled &&
              (element.isMediaMessage() &&
                  element.mediaChatMessage!.mediaLocalStoragePath
                      .checkNull()
                      .isNotEmpty))
    };
  }

  void deleteMessages() {
    //var isRecallAvailable = isMessageCanbeRecalled().keys.first;
    var isCheckBoxShown = isMessageCanbeRecalled().values.first;
    /*var deleteChatListID = List<String>.empty(growable: true);
    for (var element in selectedChatList) {
      deleteChatListID.add(element.messageId);
    }
    if (deleteChatListID.isEmpty) {
      return;
    }*/
    var isMediaDelete = false.obs;
    //var chatType =  profile.isGroupProfile ?? false ? "groupchat" : "chat";
    Helper.showAlert(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                "Are you sure you want to delete selected Message${selectedChatList.length > 1 ? "s" : ""}?"),
            isCheckBoxShown
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          isMediaDelete(!isMediaDelete.value);
                          mirrorFlyLog(
                              "isMediaDelete", isMediaDelete.value.toString());
                        },
                        child: Row(
                          children: [
                            Obx(() {
                              return Checkbox(
                                  value: isMediaDelete.value,
                                  onChanged: (value) {
                                    isMediaDelete(!isMediaDelete.value);
                                    mirrorFlyLog(
                                        "isMediaDelete", value.toString());
                                  });
                            }),
                            const Expanded(
                              child: Text("Delete media from my phone"),
                            ),
                          ],
                        ),
                      )
                    ],
                  )
                : const SizedBox(),
          ],
        ),
        message: "",
        actions: [
          TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text("CANCEL")),
          TextButton(
              onPressed: () {
                Get.back();
                for (var item in selectedChatList) {
                  FlyChat.deleteMessagesForMe(
                      item.chatUserJid,
                      item.messageChatType,
                      [item.messageId],
                      isMediaDelete.value);
                  starredChatList.removeWhere(
                      (element) => item.messageId == element.messageId);
                }
                isSelected(false);
                selectedChatList.clear();
              },
              child: const Text("DELETE FOR ME")),
          /*isRecallAvailable
              ? TextButton(
              onPressed: () {
                Get.back();
                Helper.showLoading(
                    message: 'Deleting Message for Everyone');
                */ /*FlyChat.deleteMessagesForEveryone(
                    profile.jid!,chatType, deleteChatListID, isMediaDelete.value)
                    .then((value) {
                  debugPrint(value.toString());
                  Helper.hideLoading();
                  if (value!=null && value) {
                    // removeChatList(selectedChatList);//
                    for (var chatList in selectedChatList) {
                      chatList.isMessageRecalled = true;
                      chatList.isSelected=false;
                      this.chatList.refresh();
                    }
                  }
                  isSelected(false);
                  selectedChatList.clear();
                });*/ /*
              },
              child: const Text("DELETE FOR EVERYONE"))
              : const SizedBox.shrink(),*/
        ]);
  }

  AudioPlayer player = AudioPlayer();
  ChatMessageModel? playingChat;
  playAudio(ChatMessageModel chatMessage) async {
    if(playingChat!=null){
      if(playingChat?.mediaChatMessage!.messageId!=chatMessage.messageId){
        player.stop();
        playingChat?.mediaChatMessage!.isPlaying=false;
        playingChat = chatMessage;
      }
    }
    else{
      playingChat = chatMessage;
    }
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
        starredChatList.refresh();
      } else {
        mirrorFlyLog("", "Error on resume audio.");
      }
    } else {
      int result = await player.pause();
      if (result == 1) {
        playingChat!.mediaChatMessage!.isPlaying=false;
        starredChatList.refresh();
      } else {
        mirrorFlyLog("", "Error on pause audio.");
      }
    }
  }
  RxBool canBeForward=false.obs;
  validateForForwardMessage(){
    for (var value in selectedChatList) {
      if(value.isMediaMessage()) {
        if ((value.isMediaDownloaded() || value.isMediaUploaded()) && value.mediaChatMessage!.mediaLocalStoragePath.checkNull().isNotEmpty) {
          canBeForward(true);
        } else {
          canBeForward(false);
          break;
        }
      }else{
        canBeForward(true);
      }
    }
  }

  RxBool canBeShare=false.obs;
  validateForShareMessage(){
    for (var value in selectedChatList) {
      if(value.isMediaMessage()) {
        if ((value.isMediaDownloaded() || value.isMediaUploaded()) && checkFile(value.mediaChatMessage!.mediaLocalStoragePath.checkNull())) {
          canBeShare(true);
        } else {
          canBeShare(false);
          break;
        }
      }else{
        canBeShare(false);
        break;
      }
    }
  }

  var isSearch = false.obs;
  var searchedText = TextEditingController();
  void startSearch(String str){
    if(str.isNotEmpty) {
      searchedStarredMessageList=(starredChatList);
      addSearchedMessagesToList(str);
    }else{
      starredChatList(searchedStarredMessageList);
    }
  }

  clearSearch(){

  }

  var searchedStarredMessageList = <ChatMessageModel>[];
  Future<void> addSearchedMessagesToList(String filterKey) async {
    starredChatList.clear();
    for (var message in searchedStarredMessageList) {
      var name = await getProfile(message.chatUserJid.checkNull());
      if (isTextMessageContainsFilterKey(message, filterKey)) {
        starredChatList.add(message);
      } else if (isImageCaptionContainsFilterKey(message, filterKey)) {
        starredChatList.add(message);
      } else if (isVideoCaptionContainsFilterKey(message, filterKey)) {
        starredChatList.add(message);
      } else if (Constants.mDocument == message.messageType &&
          message.mediaChatMessage!.mediaFileName.checkNull().isNotEmpty &&
          message.mediaChatMessage!.mediaFileName
              .toLowerCase()
              .contains(filterKey.toLowerCase())) {
        starredChatList.add(message);
      } else if (Constants.mContact == message.messageType &&
          message.contactChatMessage!.contactName.checkNull().isNotEmpty &&
          message.contactChatMessage!.contactName
              .toLowerCase()
              .contains(filterKey.toLowerCase())) {
        starredChatList.add(message);
      } else if (message.senderUserName.checkNull().isNotEmpty &&
          message.senderUserName
              .toLowerCase()
              .contains(filterKey.toLowerCase())) {
        starredChatList.add(message);
      } else if (message.isMessageSentByMe &&
          "You".toLowerCase().contains(filterKey.toLowerCase())) {
        starredChatList.add(message);
      } else if ((message.messageChatType== Constants.typeGroupChat)&&
          name.name.checkNull().contains(filterKey.toLowerCase())) {
        starredChatList.add(message);
      }
    }
    /*starredMessagesAdapterAdapterData!!.setSearch(searchEnabled, searchedText)
  starredMessagesAdapterAdapterData!!.setStarredMessages(searchedStarredMessageList)
  starredMessagesAdapterAdapterData!!.notifyDataSetChanged()*/
  }

  bool isVideoCaptionContainsFilterKey(
      ChatMessageModel message, String filterKey) {
    return Constants.mVideo == message.messageType &&
        message.mediaChatMessage!.mediaCaptionText.checkNull().isNotEmpty &&
        message.mediaChatMessage!.mediaCaptionText
            .checkNull()
            .toLowerCase()
            .contains(filterKey.toLowerCase());
  }

  bool isImageCaptionContainsFilterKey(
      ChatMessageModel message, String filterKey) {
    return Constants.mImage == message.messageType &&
        message.mediaChatMessage!.mediaCaptionText.checkNull().isNotEmpty &&
        message.mediaChatMessage!.mediaCaptionText
            .checkNull()
            .toLowerCase()
            .contains(filterKey.toLowerCase());
  }

  bool isTextMessageContainsFilterKey(
      ChatMessageModel message, String filterKey) {
    return Constants.mText == message.messageType &&
        message.messageTextContent
            .checkNull()
            .toLowerCase()
            .contains(filterKey.toLowerCase());
  }
  Future<Profile> getProfile(String jid) async {
    var value = await FlyChat.getProfileDetails(jid, true);
    return Profile.fromJson(json.decode(value.toString()));
  }

  navigateMessage(ChatMessageModel starredChat) {
    Get.toNamed(Routes.chat,parameters: {'isFromStarred':'true',"userJid":starredChat.chatUserJid,"messageId":starredChat.messageId});
  }

  void share() {
    var mediaPaths = <XFile>[];
    for(var item in selectedChatList){
      if(item.isMediaMessage()){
        if((item.isMediaDownloaded() || item.isMediaUploaded()) && item.mediaChatMessage!.mediaLocalStoragePath.checkNull().isNotEmpty){
          mediaPaths.add(XFile(item.mediaChatMessage!.mediaLocalStoragePath.checkNull()));
        }
      }
    }
    clearAllChatSelection();
    Share.shareXFiles(mediaPaths);
  }



}
