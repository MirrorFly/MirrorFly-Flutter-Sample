import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../common/app_localizations.dart';
import '../../../data/helper.dart';
import '../../../extensions/extensions.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app_style_config.dart';
import '../../../common/constants.dart';
import '../../../data/utils.dart';
import '../../../model/arguments.dart';
import '../../../model/chat_message_model.dart';
import '../../../routes/route_settings.dart';

class StarredMessagesController extends FullLifeCycleController with FullLifeCycleMixin {
  var starredChatList = List<ChatMessageModel>.empty(growable: true).obs;
  double height = 0.0;
  double width = 0.0;
  var isSelected = false.obs;

  var isListLoading = true.obs;
  var calendar = DateTime.now();

 /* @override
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
  }*/

  /*@override
  void onClose(){
    super.onClose();
    // player.stop();
    // player.dispose();
  }*/
  getFavouriteMessages() {
    if(!isSelected.value) {
      isListLoading(true);
      Mirrorfly.getFavouriteMessages().then((value) {
        List<ChatMessageModel> chatMessageModel = chatMessageModelFromJson(
            value);
        // starredChatList(chatMessageModel.toList());
        if(Platform.isAndroid){
          starredChatList(chatMessageModel.toList());
        }else{
          var list = chatMessageModel.toList().reversed.toList();
          starredChatList(list);
        }
        isListLoading(false);
        if(isSearch.value){
          lastInputValue="";
          startSearch(searchedText.text.toString());
        }
      });
    }
  }
  void userUpdatedHisProfile(String jid) {
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
    debugPrint("Message Status Update index of $index");
    if (!index.isNegative) {
      starredChatList[index].messageStatus = chatMessageModel.messageStatus;
      starredChatList.refresh();
    }
  }

  void onMessageEdited(ChatMessageModel editedChatMessage) {
    final index = starredChatList.indexWhere(
            (message) => message.messageId == editedChatMessage.messageId);
    debugPrint("Message Edit Update index of $index");
    if (!index.isNegative) {
      starredChatList[index] = editedChatMessage;
    }
  }

  void onMediaStatusUpdated(ChatMessageModel chatMessageModel) {
    final index = starredChatList.indexWhere(
            (message) => message.messageId == chatMessageModel.messageId);
    if (!index.isNegative) {
      starredChatList[index].mediaChatMessage?.mediaLocalStoragePath(chatMessageModel.mediaChatMessage!.mediaLocalStoragePath.value);
      starredChatList[index].mediaChatMessage?.mediaDownloadStatus(chatMessageModel.mediaChatMessage!.mediaDownloadStatus.value);
      starredChatList[index].mediaChatMessage?.mediaUploadStatus(chatMessageModel.mediaChatMessage!.mediaUploadStatus.value);
    }

    if (isSelected.value) {
      var selectedIndex = selectedChatList.indexWhere(
              (element) => chatMessageModel.messageId == element.messageId);
      if (!selectedIndex.isNegative) {
        chatMessageModel.isSelected(true); //selectedChatList[selectedIndex].isSelected;
        selectedChatList[selectedIndex] = chatMessageModel;
        selectedChatList.refresh();
        validateForForwardMessage();
        validateForShareMessage();
      }
    }
    if(isSearch.value){
      var selectedIndex = searchedStarredMessageList.indexWhere(
              (element) => chatMessageModel.messageId == element.messageId);
      if (!selectedIndex.isNegative) {
        searchedStarredMessageList[selectedIndex] = chatMessageModel;
      }
    }

  }

  void onUploadDownloadProgressChanged(
      String messageId, String progressPercentage) {
    if (messageId.isNotEmpty) {
      final index =
      starredChatList.indexWhere((message) => message.messageId == messageId);
      debugPrint("Media Status Onprogress changed---> onUploadDownloadProgressChanged $index $messageId $progressPercentage");
      if (!index.isNegative) {
        starredChatList[index].mediaChatMessage?.mediaProgressStatus (int.parse(progressPercentage));
        starredChatList.refresh();
      }
      if(isSearch.value){
        var selectedIndex = searchedStarredMessageList.indexWhere(
                (message) => message.messageId == messageId);
        if (!selectedIndex.isNegative) {
          searchedStarredMessageList[selectedIndex].mediaChatMessage?.mediaProgressStatus(int.parse(progressPercentage));
        }
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
      item.isSelected (true);
      starredChatList.refresh();
      validateForForwardMessage();
      validateForShareMessage();
    } else {
      debugPrint("Unable to Select Notification Banner");
    }
  }

  clearChatSelection(ChatMessageModel item) {
    selectedChatList.remove(item);
    item.isSelected (false);
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
      chatItem.isSelected(false);
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
    var busyStatus = await Mirrorfly.isBusyStatusEnabled();
    if (!busyStatus.checkNull()) {
      forwardMessage();
    } else {
      showBusyStatusAlert(forwardMessage);
    }
  }

  showBusyStatusAlert(Function? function) {
    DialogUtils.showAlert(dialogStyle: AppStyleConfig.dialogStyle,
        message: getTranslated("disableBusy"),
        actions: [
          TextButton(style: AppStyleConfig.dialogStyle.buttonStyle,
              onPressed: () {
                NavUtils.back();
              },
              child: Text(getTranslated("no"), )),
          TextButton(style: AppStyleConfig.dialogStyle.buttonStyle,
              onPressed: () async {
                NavUtils.back();
                await Mirrorfly.enableDisableBusyStatus(enable: false, flyCallBack: (FlyResponse response) {
                  if(response.isSuccess) {
                    if (function != null) {
                      function();
                    }
                  }
                });
              },
              child: Text(getTranslated("yes"), )),
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
      NavUtils.toNamed(Routes.forwardChat, arguments: {
        "forward": true,
        "group": false,
        "groupJid": "",
        "messageIds": messageIds
      })?.then((value) {
        if (value != null) {
          debugPrint(
              "result of forward ==> ${(value as ProfileDetails).toJson().toString()}");
          // NavUtils.toNamed(Routes.chat, arguments: ChatViewArguments(chatJid: value.jid.checkNull()));
        }
      });
    }
  }

  favouriteMessage() {
    for (var item in selectedChatList) {
      Mirrorfly.updateFavouriteStatus(messageId: item.messageId,chatUserJid: item.chatUserJid,isFavourite: !item.isMessageStarred.value,chatType: item.messageChatType, flyCallBack: (FlyResponse response) {});
      starredChatList.removeWhere((element) => item.messageId == element.messageId);
      if(isSearch.value){
        searchedStarredMessageList.removeWhere((element) => item.messageId == element.messageId);
      }
    }
    selectedChatList.clear();
    isSelected(false);
  }

  copyTextMessages() {
    Clipboard.setData(
        ClipboardData(text: selectedChatList[0].messageTextContent ?? ""));
    clearChatSelection(selectedChatList[0]);
    toToast(getTranslated("textCopiedSuccess"));
  }

  Map<bool, bool> isMessageCanbeRecalled() {
    var recallTimeDifference =
        ((DateTime.now().millisecondsSinceEpoch - 30000) * 1000);
    return {
      selectedChatList.any((element) =>
              element.isMessageSentByMe &&
              !element.isMessageRecalled.value &&
              (element.messageSentTime > recallTimeDifference)):
          selectedChatList.any((element) =>
              !element.isMessageRecalled.value &&
              (element.isMediaMessage() &&
                  element.mediaChatMessage!.mediaLocalStoragePath.value
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
    DialogUtils.showAlert(dialogStyle: AppStyleConfig.dialogStyle,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedChatList.length > 1 ? getTranslated("deleteSelectedMessages") : getTranslated("deleteSelectedMessage"),
            style: AppStyleConfig.dialogStyle.contentTextStyle,),
            isCheckBoxShown
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          isMediaDelete(!isMediaDelete.value);
                          LogMessage.d(
                              "isMediaDelete", isMediaDelete.value.toString());
                        },
                        child: Row(
                          children: [
                            Obx(() {
                              return Checkbox(
                                  value: isMediaDelete.value,
                                  onChanged: (value) {
                                    isMediaDelete(!isMediaDelete.value);
                                    LogMessage.d(
                                        "isMediaDelete", value.toString());
                                  });
                            }),
                            Expanded(
                              child: Text(getTranslated("deleteMediaFromPhone")),
                            ),
                          ],
                        ),
                      )
                    ],
                  )
                : const Offstage(),
          ],
        ),
        message: "",
        actions: [
          TextButton(style: AppStyleConfig.dialogStyle.buttonStyle,
              onPressed: () {
                NavUtils.back();
              },
              child: Text(getTranslated("cancel").toUpperCase(), )),
          TextButton(style: AppStyleConfig.dialogStyle.buttonStyle,
              onPressed: () {
                NavUtils.back();
                var messageIds = selectedChatList.map((item) => item.messageId).toList();
                Mirrorfly.deleteMessagesForMe(jid: selectedChatList[0].chatUserJid,
                    chatType: selectedChatList[0].messageChatType, messageIds: messageIds,
                      isMediaDelete: isMediaDelete.value, flyCallBack: (FlyResponse response) {
                      for (var item in messageIds) {
                        starredChatList.removeWhere((element) => item == element.messageId);
                        if(isSearch.value){
                          searchedStarredMessageList
                              .removeWhere((element) => item == element.messageId);
                        }
                      }
                      isSelected(false);
                      selectedChatList.clear();
                    });
              },
              child: Text(getTranslated("deleteForMe").toUpperCase(), )),
        ]);
  }

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
        starredChatList.refresh();
      } else {
        LogMessage.d("", "Error on resume audio.");
      }
    } else {
      int result = await player.pause();
      if (result == 1) {
        playingChat!.mediaChatMessage!.isPlaying=false;
        starredChatList.refresh();
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
   /* debugPrint('onSeekbarChange $value');
    if (playingChat != null) {
      player.seek(Duration(milliseconds: value.toInt()));
    }else{
      chatMessage.mediaChatMessage?.currentPos=value.toInt();
      // starredChatList.refresh();
    }*/
  }

  RxBool canBeForward=false.obs;
  validateForForwardMessage(){
    for (var value in selectedChatList) {
      if(value.isMediaMessage()) {
        if ((value.isMediaDownloaded() || value.isMediaUploaded()) && value.mediaChatMessage!.mediaLocalStoragePath.value.checkNull().isNotEmpty) {
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
        if ((value.isMediaDownloaded() || value.isMediaUploaded()) && MediaUtils.isMediaExists(value.mediaChatMessage!.mediaLocalStoragePath.value.checkNull())) {
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
  var clear = false.obs;
  var searchedText = TextEditingController();
  String lastInputValue = "";
  void startSearch(String str){
    if(str.isNotEmpty) {
      clear(true);
      if (lastInputValue != str.trim()) {
        starredChatList.clear();
        lastInputValue = str.trim();
        addSearchedMessagesToList(str.trim());
      }
    }else{
      lastInputValue='';
      clear(false);
      starredChatList.clear();
      starredChatList.addAll(searchedStarredMessageList);
      starredChatList.refresh();
    }
  }

  onSearchClick(){
    if (isSearch.value) {
      isSearch(false);
    } else {
      isSearch(true);
      searchedStarredMessageList.clear();
      searchedStarredMessageList.addAll(starredChatList);
    }
  }

  clearSearch(){
    lastInputValue='';
    isSearch(false);
    clear(false);
    searchedText.clear();
    starredChatList.clear();
    starredChatList.addAll(searchedStarredMessageList);
    searchedStarredMessageList.clear();
    starredChatList.refresh();
  }

  var searchedStarredMessageList = <ChatMessageModel>[];
  Future<void> addSearchedMessagesToList(String filterKey) async {
    if(starredChatList.isEmpty) {
      for (var message in searchedStarredMessageList) {
        if (isTextMessageContainsFilterKey(message, filterKey)) {
          if(starredChatList.indexWhere((element) => element.messageId==message.messageId).isNegative) {
            starredChatList.add(message);
            debugPrint('starredChatList ${message.messageId}text');
          }
        } else if (isImageCaptionContainsFilterKey(message, filterKey)) {
          if(starredChatList.indexWhere((element) => element.messageId==message.messageId).isNegative) {
            starredChatList.add(message);
            debugPrint('starredChatList ${message.messageId}image');
          }
        } else if (isVideoCaptionContainsFilterKey(message, filterKey)) {
          if(starredChatList.indexWhere((element) => element.messageId==message.messageId).isNegative) {
            starredChatList.add(message);
            debugPrint('starredChatList ${message.messageId}video');
          }
        } else if (Constants.mDocument == message.messageType &&
            message.mediaChatMessage!
                .mediaFileName
                .checkNull()
                .isNotEmpty &&
            message.mediaChatMessage!.mediaFileName
                .toLowerCase()
                .contains(filterKey.toLowerCase())) {
          if(starredChatList.indexWhere((element) => element.messageId==message.messageId).isNegative) {
            starredChatList.add(message);
            debugPrint('starredChatList ${message.messageId}doc');
          }
        } else if (Constants.mContact == message.messageType &&
            message.contactChatMessage!
                .contactName
                .checkNull()
                .isNotEmpty &&
            message.contactChatMessage!.contactName
                .toLowerCase()
                .contains(filterKey.toLowerCase())) {
          if(starredChatList.indexWhere((element) => element.messageId==message.messageId).isNegative) {
            starredChatList.add(message);
            debugPrint('starredChatList ${message.messageId}contact');
          }
        } else if (message.senderUserName
            .checkNull()
            .isNotEmpty &&
            message.senderUserName
                .toLowerCase()
                .contains(filterKey.toLowerCase())) {
          if(starredChatList.indexWhere((element) => element.messageId==message.messageId).isNegative) {
            starredChatList.add(message);
            debugPrint('starredChatList ${message.messageId}sender');
          }
        } else if (message.isMessageSentByMe &&
            "You".toLowerCase().contains(filterKey.toLowerCase())) {
          if(starredChatList.indexWhere((element) => element.messageId==message.messageId).isNegative) {
            starredChatList.add(message);
            debugPrint('starredChatList ${message.messageId}you');
          }
        } else if ((message.messageChatType == ChatType.groupChat)){
          var name = await getProfileDetails(message.chatUserJid.checkNull());
            if(name.name.checkNull().contains(filterKey.toLowerCase())) {
              if(starredChatList.indexWhere((element) => element.messageId==message.messageId).isNegative) {
                starredChatList.add(message);
                debugPrint('starredChatList ${message.messageId} : group');
              }
            }
        }
        starredChatList.refresh();
      }
    }else{
      starredChatList([]);
      addSearchedMessagesToList(filterKey);
    }
    debugPrint('starredChatList ${starredChatList.length}');
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

  navigateMessage(ChatMessageModel starredChat) {
    NavUtils.toNamed(Routes.chat,arguments: ChatViewArguments(chatJid: starredChat.chatUserJid,messageId: starredChat.messageId,topicId: starredChat.topicId,));//{'isFromStarred':'true',"chatJid":starredChat.chatUserJid,"messageId":starredChat.messageId,"topicId":starredChat.topicId.checkNull()});
  }

  void share() {
    var mediaPaths = <XFile>[];
    for(var item in selectedChatList){
      if(item.isMediaMessage()){
        if((item.isMediaDownloaded() || item.isMediaUploaded()) && item.mediaChatMessage!.mediaLocalStoragePath.value.checkNull().isNotEmpty){
          mediaPaths.add(XFile(item.mediaChatMessage!.mediaLocalStoragePath.value.checkNull()));
        }
      }
    }
    clearAllChatSelection();
    Share.shareXFiles(mediaPaths);
  }

  void userDeletedHisProfile(String jid) {
    userUpdatedHisProfile(jid);
  }

  @override
  void onDetached() {}

  @override
  void onInactive() {}

  @override
  void onPaused() {}

  FocusNode searchFocus = FocusNode();
  @override
  void onResumed() {
    if(isSearch.value) {
      if (!KeyboardVisibilityController().isVisible) {
        if (searchFocus.hasFocus) {
          searchFocus.unfocus();
          Future.delayed(const Duration(milliseconds: 100), () {
            searchFocus.requestFocus();
          });
        }
      }
    }
  }

  @override
  void onHidden() {

  }


}
