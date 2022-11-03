import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:io' as Io;

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mirror_fly_demo/app/model/chatMessageModel.dart';
import 'package:mirror_fly_demo/app/nativecall/platformRepo.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/constants.dart';
import '../../../data/contact_utils.dart';
import '../../../data/helper.dart';
import '../../../model/checkModel.dart' as checkModel;
import '../../../model/userlistModel.dart';
import '../../../routes/app_pages.dart';


class ChatController extends GetxController
    with GetSingleTickerProviderStateMixin {
  //TODO: Implement DashboardController

  var chatList = List<ChatMessageModel>.empty(growable: true).obs;
  late AnimationController controller;
  ScrollController scrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  late ChatMessageModel replyChatMessage;

  var isReplying = false.obs;

  String currentpostlabel = "00:00";

  var maxduration = 100.obs;
  var currentpos = 0.obs;
  var isplaying = false.obs;
  var audioplayed = false.obs;

  var isUserTyping = false.obs;
  // late Uint8List audiobytes;

  AudioPlayer player = AudioPlayer();

  TextEditingController messageController = TextEditingController();

  FocusNode focusNode = FocusNode();

  var calendar = DateTime.now();
  late Profile profile; // = Get.arguments as Profile;
  var base64img = ''.obs;
  var imagePath = ''.obs;
  var filePath = ''.obs;

  var showEmoji = false.obs;

  var isLive = false;

  var isSelected = false.obs;

  var isBlocked = false.obs;

  var selectedChatList = List<ChatMessageModel>.empty(growable: true).obs;


  var keyboardVisibilityController = KeyboardVisibilityController();

  late StreamSubscription<bool> keyboardSubscription;

  @override
  void onInit() {
    super.onInit();
    profile = Get.arguments as Profile;
    debugPrint("isBlocked===> ${profile.isBlocked}");
    isBlocked(profile.isBlocked);
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // askStoragePermission();
    isLive = true;
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        showEmoji(false);
      }
    });
    keyboardSubscription = keyboardVisibilityController.onChange.listen((bool visible) {
      if(!visible) {
        focusNode.canRequestFocus = false;
      }
    });
    scrollController.addListener(() {
      double offset = 0.9 * scrollController.position.maxScrollExtent;

      if (scrollController.position.pixels > offset) {
        debugPrint('scrollController offset > load more');
      }
    });
    registerChatSync();
    PlatformRepo().ongoingChat(profile.jid!);
    getChatHistory(profile.jid!);
    debugPrint("==================");
    debugPrint(profile.image);
    sendReadReceipt();

    player.onDurationChanged.listen((Duration d) {
      //get the duration of audio
      maxduration(d.inMilliseconds);
    });

    player.onPlayerCompletion.listen((event) {
      isplaying(false);
      audioplayed(false);
    });

    player.onAudioPositionChanged.listen((Duration p) {
      currentpos(p.inMilliseconds); //get the current position of playing audio

      int milliseconds = currentpos.value;
      //generating the duration label
      int shours = Duration(milliseconds: milliseconds).inHours;
      int sminutes = Duration(milliseconds: milliseconds).inMinutes;
      int sseconds = Duration(milliseconds: milliseconds).inSeconds;

      int rhours = shours;
      int rminutes = sminutes - (shours * 60);
      int rseconds = sseconds - (sminutes * 60 + shours * 60 * 60);

      currentpostlabel = "$rhours:$rminutes:$rseconds";
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    PlatformRepo().ongoingChat("");
    // Get.delete<ChatController>();
    isLive = false;
    super.onClose();
  }

  @override
  void dispose() {
    controller.dispose();
    // Get.delete<ChatController>();
    super.dispose();
  }

  registerChatSync() {
    debugPrint("Registering Event");
    var messageEvent = PlatformRepo().onMessageReceived;
    messageEvent.listen((msgData) {
      ChatMessageModel chatMessageModel = sendMessageModelFromJson(msgData);

      chatList.add(chatMessageModel);
      if (isLive) {
        sendReadReceipt();
      }
    });

    PlatformRepo().onMessageStatusUpdated.listen((msgData) {
      ChatMessageModel chatMessageModel = sendMessageModelFromJson(msgData);
      final index = chatList.indexWhere(
          (message) => message.messageId == chatMessageModel.messageId);
      debugPrint("Message Status Update index of search $index");
      if (index != -1) {
        // Helper.hideLoading();
        chatList[index] = chatMessageModel;
      }
    });
    PlatformRepo().onMediaStatusUpdated.listen((msgData) {
      ChatMessageModel chatMessageModel = sendMessageModelFromJson(msgData);
      final index = chatList.indexWhere(
          (message) => message.messageId == chatMessageModel.messageId);
      debugPrint("Media Status Update index of search $index");
      if (index != -1) {
        chatList[index] = chatMessageModel;
      }
    });
  }

  sendMessage(Profile profile) {
    var replyMessageId = "";

    if (isReplying.value) {
      replyMessageId = replyChatMessage.messageId;
    }
    isReplying(false);
    if (messageController.text.trim().isNotEmpty) {
      PlatformRepo()
          .sendTextMessage(
              messageController.text, profile.jid.toString(), replyMessageId)
          .then((value) {
        messageController.text = "";
        ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
        chatList.add(chatMessageModel);
      });
    }
  }

  sendLocationMessage(Profile profile, double latitude, double longitude) {
    var replyMessageId = "";
    if (isReplying.value) {
      replyMessageId = replyChatMessage.messageId;
    }
    isReplying(false);

    PlatformRepo()
        .sentLocationMessage(
            profile.jid.toString(), latitude, longitude, replyMessageId)
        .then((value) {
      Log("Location_msg", value.toString());
      ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
      chatList.add(chatMessageModel);
    });
  }

  String gettime(int? timestamp) {
    DateTime now = DateTime.now();
    final DateTime date1 = timestamp == null
        ? now
        : DateTime.fromMillisecondsSinceEpoch(timestamp);
    String formattedDate = DateFormat('hh:mm a').format(date1); //yyyy-MM-dd –
    // var fm1 = DateFormat('hh:mm a').parse(formattedDate, true);
    return formattedDate;
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
        ? DateFormat("dd-MMM").format(calendar)
        : DateFormat("yyyy/MM/dd").format(calendar);
    return hourTime;
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

  getChatHistory(String jid) {
    PlatformRepo().getChatHistory(jid).then((value) {
      List<ChatMessageModel> chatMessageModel = chatMessageModelFromJson(value);
      chatList(chatMessageModel);
      // if (scrollController.hasClients) {
      //   scrollController.animateTo(
      //     0.0,
      //     curve: Curves.easeOut,
      //     duration: const Duration(milliseconds: 300),
      //   );
      // }
    });
  }

  getMedia(String mid) {
    return PlatformRepo().getMedia(mid).then((value) {
      // debugPrint("Media==> $value");
      checkModel.CheckModel chatMessageModel =
          checkModel.checkModelFromJson(value);
      String thumbImage = chatMessageModel.mediaChatMessage.mediaThumbImage;
      thumbImage = thumbImage.replaceAll("\n", "");
      // debugPrint("Thumbnail ==> $thumbImage");
      return thumbImage;
    });

    // return imageFromBase64String(chatMessageModel.mediaChatMessage!.mediaThumbImage!);
    // // return media;
    // return base64Decode(chatMessageModel.mediaChatMessage.mediaThumbImage);
  }

  Image imageFromBase64String(String base64String, BuildContext context,
      double? width, double? height) {
    var decodedBase64 = base64String.replaceAll("\n", "");
    Uint8List image = const Base64Decoder().convert(decodedBase64);
    return Image.memory(
      image,
      width: width ?? MediaQuery.of(context).size.width * 0.60,
      height: height ?? MediaQuery.of(context).size.height * 0.4,
      fit: BoxFit.cover,
    );
  }

  sendImageMessage(String? path, String? caption, String? replyMessageID) {
    debugPrint("Path ==> $path");
    if (isReplying.value) {
      replyMessageID = replyChatMessage.messageId;
    }
    isReplying(false);
    if (File(path!).existsSync()) {
      return PlatformRepo()
          .sendImageMessage(profile.jid!, path, caption, replyMessageID)
          .then((value) {
        ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
        chatList.add(chatMessageModel);

        return chatMessageModel;
      });
    } else {
      debugPrint("file not found for upload");
    }
  }

  Future imagePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'mp4', 'mov', 'wmv', 'mkv'],
    );
    if (result != null && File(result.files.single.path!).existsSync()) {
      debugPrint(result.files.first.extension);
      if (result.files.first.extension == 'jpg' ||
          result.files.first.extension == 'png') {
        debugPrint("Picked Image File");
        imagePath.value = (result.files.single.path!);
        Get.toNamed(Routes.IMAGEPREVIEW, arguments: {
          "filePath": imagePath.value,
          "userName": profile.name!
        });
      } else if (result.files.first.extension == 'mp4' ||
          result.files.first.extension == 'mov' ||
          result.files.first.extension == 'mkv') {
        debugPrint("Picked Video File");
        imagePath.value = (result.files.single.path!);
        Get.toNamed(Routes.VIDEO_PREVIEW, arguments: {
          "filePath": imagePath.value,
          "userName": profile.name!
        });
      }
    } else {
      // User canceled the picker
    }
  }

  Future documentPickUpload() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'ppt', 'xls', 'doc', 'docx', 'xlsx'],
    );
    if (result != null && File(result.files.single.path!).existsSync()) {
      debugPrint(result.files.first.extension);
      filePath.value = (result.files.single.path!);
      sendDocumentMessage(filePath.value, "");
    } else {
      // User canceled the picker
    }
  }

  sendReadReceipt() {
    PlatformRepo().sendReadReceipts(profile.jid!).then((value) {
      debugPrint("Chat Read Receipt Response ==> $value");
    });
  }

  sendVideoMessage(String videoPath, String caption, String replyMessageID) {
    if (isReplying.value) {
      replyMessageID = replyChatMessage.messageId;
    }
    isReplying(false);
    return PlatformRepo()
        .sendMediaMessage(profile.jid!, videoPath, caption, replyMessageID)
        .then((value) {
      ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
      chatList.add(chatMessageModel);
      return chatMessageModel;
    });
  }

  checkFile(String mediaLocalStoragePath) {
    return mediaLocalStoragePath.isNotEmpty &&
        File(mediaLocalStoragePath).existsSync();
  }

  downloadMedia(String messageId) async {
    if (await askStoragePermission()) {
      PlatformRepo().mediaDownload(messageId);
    }
  }

  playAudio(String filePath) async {
    if (!isplaying.value && !audioplayed.value) {
      int result = await player.play(filePath, isLocal: true);
      if (result == 1) {
        //play success

        isplaying(true);
        audioplayed(true);
      } else {
        print("Error while playing audio.");
      }
    } else if (audioplayed.value && !isplaying.value) {
      int result = await player.resume();
      if (result == 1) {
        //resume success

        isplaying(true);
        audioplayed(true);
      } else {
        print("Error on resume audio.");
      }
    } else {
      int result = await player.pause();
      if (result == 1) {
        //pause success

        isplaying(false);
      } else {
        print("Error on pause audio.");
      }
    }

    // if(isPlaying.value){
    //   debugPrint("pause audio");
    //   // audioplayed(false);
    //
    //   isPlaying(false);
    //   // mediaChatMessage.isPlaying = false;
    //   int result = await player.pause();
    //   if (result == 1) {
    //     // success
    //     // isplaying(false);
    //   }
    // }else {
    //   debugPrint("play audio");
    //   // audioplayed(true);
    //
    //   isPlaying(true);
    //   // mediaChatMessage.isPlaying = true;
    //   int result = await player.play(filePath, isLocal: true);
    //   if (result == 1) {
    //     // success
    //     // isplaying(true);
    //   }
    // }
    // chatList.refresh();
  }

  Future<bool> askContactsPermission() async {
    final permission = await ContactUtils.getContactPermission();
    switch (permission) {
      case PermissionStatus.granted:
        return true;
      case PermissionStatus.permanentlyDenied:
        return false;
      default:
        debugPrint("Contact Permission default");
        return false;
    }
  }

  Future<bool> askStoragePermission() async {
    final permission = await ContactUtils.getStoragePermission();
    switch (permission) {
      case PermissionStatus.granted:
        return true;
      case PermissionStatus.permanentlyDenied:
        return false;
      default:
        debugPrint("Contact Permission default");
        return false;
    }
  }

  sendContactMessage(List<String> contactList, String contactName) {
    var replyMessageId = "";

    if (isReplying.value) {
      replyMessageId = replyChatMessage.messageId;
    }
    isReplying(false);
    return PlatformRepo()
        .sendContacts(contactList, profile.jid!, contactName, replyMessageId)
        .then((value) {
      ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
      chatList.add(chatMessageModel);
      return chatMessageModel;
    });
  }

  sendDocumentMessage(String documentPath, String replyMessageId) {
    if (isReplying.value) {
      replyMessageId = replyChatMessage.messageId;
    }
    isReplying(false);
    PlatformRepo()
        .sendDocument(profile.jid!, documentPath, replyMessageId)
        .then((value) {
      ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
      chatList.add(chatMessageModel);
      return chatMessageModel;
    });
  }

  openDocument(String mediaLocalStoragePath, BuildContext context) async {
    // if (await askStoragePermission()) {
    if (mediaLocalStoragePath.isNotEmpty) {
      // final _result = await OpenFile.open(mediaLocalStoragePath);
      // debugPrint(_result.message);
      // FileView(
      //   controller: FileViewController.file(File(mediaLocalStoragePath)),
      // );
      // Get.toNamed(Routes.FILE_VIEWER, arguments: { "filePath": mediaLocalStoragePath});
      // final String filePath = testFile.absolute.path;
      // final Uri uri = Uri.file(mediaLocalStoragePath);
      //
      // if (!File(uri.toFilePath()).existsSync()) {
      //   throw '$uri does not exist!';
      // }
      // if (!await launchUrl(uri)) {
      //   throw 'Could not launch $uri';
      // }

      PlatformRepo().openFile(mediaLocalStoragePath).catchError((onError) {
        final scaffold = ScaffoldMessenger.of(context);
        scaffold.showSnackBar(
          SnackBar(
            content: const Text(
                'No supported application available to open this file format'),
            action: SnackBarAction(
                label: 'Ok', onPressed: scaffold.hideCurrentSnackBar),
          ),
        );
      });
    } else {
      debugPrint("media doesnot exist");
    }
    // }
  }

  pickAudio() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(allowMultiple: false, type: FileType.audio);
    if (result != null && File(result.files.single.path!).existsSync()) {
      debugPrint(result.files.first.extension);
      AudioPlayer player = AudioPlayer();
      player.setUrl(result.files.single.path!);
      player.onDurationChanged.listen((Duration duration) {
        print('max duration: ${duration.inMilliseconds}');
        filePath.value = (result.files.single.path!);
        sendAudioMessage(
            filePath.value, false, duration.inMilliseconds.toString());
      });
    } else {
      // User canceled the picker
    }
  }

  sendAudioMessage(String filePath, bool isRecorded, String duration) {
    var replyMessageId = "";

    if (isReplying.value) {
      replyMessageId = replyChatMessage.messageId;
    }
    isReplying(false);
    PlatformRepo()
        .sendAudio(profile.jid!, filePath, isRecorded, duration, replyMessageId)
        .then((value) {
      ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
      chatList.add(chatMessageModel);
      return chatMessageModel;
    });
  }

  void isTyping(String typingText) {
    typingText.isNotEmpty ? isUserTyping(true) : isUserTyping(false);
  }

  clearChatHistory(bool isStarredExcluded) {
    PlatformRepo()
        .clearChatHistory(profile.jid!, "chat", isStarredExcluded)
        .then((value) {
      if (value) {
        chatList.clear();
      }
    });
  }

  void handleReplyChatMessage(ChatMessageModel chatListItem) {
    debugPrint(chatListItem.messageType);
    if (isReplying.value) {
      isReplying(false);
    }
    replyChatMessage = chatListItem;
    isReplying(true);
  }

  cancelReplyMessage() {
    isReplying(false);
  }

  clearChatSelection(ChatMessageModel chatList) {
    selectedChatList.remove(chatList);
    chatList.isSelected = false;
    if (selectedChatList.isEmpty) {
      isSelected(false);
      selectedChatList.clear();
    }
    this.chatList.refresh();
  }

  clearAllChatSelection() {
    isSelected(false);
    for (var chatItem in selectedChatList){
      chatItem.isSelected = false;
    }
    selectedChatList.clear();

  }

  void addChatSelection(ChatMessageModel chatList) {
    if (chatList.messageType != Constants.MNOTIFICATION) {
      selectedChatList.add(chatList);
      chatList.isSelected = true;
      this.chatList.refresh();
    } else {
      debugPrint("Unable to Select Notification Banner");
    }
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
          if (chatList.messageType == Constants.MTEXT ||
              chatList.messageType == Constants.MLOCATION ||
              chatList.messageType == Constants.MCONTACT) {
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
        return selectedChatList.length > 1 ? false: true;

      default:
        return false;
    }
  }

  reportChatOrUser() {
    Future.delayed(const Duration(milliseconds: 100), ()
    {
      var chatMessage = selectedChatList.isNotEmpty
          ? selectedChatList[0]
          : null;
      Helper.showAlert(
          title: "Report ${profile.name}?",
          message:
          "${selectedChatList.isNotEmpty
              ? "This message will be forwarded to admin."
              : "The last 5 messages from this contact will be forwarded to admin."} This Contact will not be notified.",
          actions: [
            TextButton(
                onPressed: () {
                  Get.back();
                  PlatformRepo()
                      .reportChatOrUser(
                      profile.jid!,
                      chatMessage?.messageChatType ?? "chat",
                      chatMessage?.messageId ?? "")
                      .then((value) {
                    //report success
                    debugPrint(value);
                  }).catchError((onError) {
                    //report failed
                    debugPrint(onError.toString());
                  });
                },
                child: const Text("REPORT")),
            TextButton(
                onPressed: () {
                  Get.back();
                },
                child: const Text("CANCEL")),
          ]);
    });
  }

  copyTextMessages() {
    // PlatformRepo().copyTextMessages(selectedChatList[0].messageId);
    debugPrint('Copy text ==> ${selectedChatList[0].messageTextContent}');
    Clipboard.setData(ClipboardData(text: selectedChatList[0].messageTextContent));
    // selectedChatList.clear();
    // isSelected(false);
    clearChatSelection(selectedChatList[0]);
  }

  void deleteMessages() {
    var isRecallAvailable = true;
    for (var chatList in selectedChatList) {
      if (chatList.messageSentTime > (DateTime.now().millisecondsSinceEpoch - 30000) * 1000) {
        isRecallAvailable = true;
      }else{
        isRecallAvailable = false;
        break;
      }
    }

    var deleteChatListID = List<String>.empty(growable: true);
    for(var chatList in selectedChatList){
      deleteChatListID.add(chatList.messageId);
    }

    if(deleteChatListID.isEmpty){
      return;
    }

    Helper.showAlert(
        message:
        "Are you sure you want to delete selected Message${selectedChatList.length > 1 ? "s" : ""}",
        actions: [
          TextButton(
              onPressed: () {
                Get.back();
                Helper.showLoading(message: 'Deleting Message');
                PlatformRepo().deleteMessages(profile.jid!, deleteChatListID, false).then((value){
                  debugPrint(value);
                  Helper.hideLoading();
                  if(value == "deleteMessagesForMe success"){
                    removeChatList(selectedChatList);
                  }
                  isSelected(false);
                  selectedChatList.clear();
                });
              },
              child: const Text("DELETE FOR ME")),
          TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text("CANCEL")),
          isRecallAvailable ? TextButton(
              onPressed: () {
                Get.back();
                Helper.showLoading(message: 'Deleting Message for Everyone');
                PlatformRepo().deleteMessages(profile.jid!, deleteChatListID, true).then((value){
                  debugPrint(value);
                  Helper.hideLoading();
                  if(value == "success"){
                    removeChatList(selectedChatList);
                  }
                  isSelected(false);
                  selectedChatList.clear();
                });
              },
              child: const Text("DELETE FOR EVERYONE")) : const SizedBox.shrink(),
        ]);
  }

  removeChatList(RxList<ChatMessageModel> selectedChatList) {
    for(var chatList in selectedChatList){
      this.chatList.remove(chatList);
    }
  }

  messageInfo() {
    Future.delayed(const Duration(milliseconds: 100), ()
    {
      debugPrint("sending mid ===> ${selectedChatList[0].messageId}");
      Get.toNamed(Routes.MESSAGE_INFO, arguments: {
        "messageID": selectedChatList[0].messageId,
        "chatMessage": selectedChatList[0]
      });
      clearChatSelection(selectedChatList[0]);
    });
  }

  favouriteMessage() {

    Helper.showLoading(message: selectedChatList[0].isMessageStarred ? 'Unfavoriting Message' : 'Favoriting Message');

    // for(var chatList in selectedChatList){
      PlatformRepo().favouriteMessage(selectedChatList[0].messageId, profile.jid!, !selectedChatList[0].isMessageStarred).then((value) {
        final chatIndex = chatList.indexWhere((message) => message.messageId == selectedChatList[0].messageId);
        // chatList[chatIndex].isMessageStarred = !chatList[chatIndex].isMessageStarred;
        clearChatSelection(selectedChatList[0]);
        Helper.hideLoading();
      });
    // }
  }

  Widget getLocationImage(
      LocationChatMessage? locationChatMessage, double width, double height) {
    return InkWell(
        onTap: () async {
          //Redirect to Google maps App
          String googleUrl =
              'https://www.google.com/maps/search/?api=1&query=${locationChatMessage.latitude}, ${locationChatMessage.longitude}';
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

  blockUser() {
    Future.delayed(const Duration(milliseconds: 100), () {
      Helper.showAlert(
          message: "Are you sure you want to Block ${profile.name}?",
          actions: [
            TextButton(
                onPressed: () {
                  Get.back();
                },
                child: const Text("CANCEL")),
            TextButton(
                onPressed: () {
                  Get.back();
                  Helper.showLoading(message: "Blocking User");
                  PlatformRepo().blockUser(profile.jid!).then((value) {
                    debugPrint(value);
                    isBlocked(true);
                    Helper.hideLoading();
                  }).catchError((error) {
                    Helper.hideLoading();
                    debugPrint(error);
                  });
                },
                child: const Text("BLOCK")),
          ]);
    });
  }

  clearUserChatHistory() {
    Future.delayed(const Duration(milliseconds: 100), () {
      Helper.showAlert(
          message: "Are you sure you want to clear the chat?",
          actions: [
            TextButton(
                onPressed: () {
                  Get.back();
                  clearChatHistory(false);
                },
                child: const Text("CLEAR ALL")),
            TextButton(
                onPressed: () {
                  Get.back();
                },
                child: const Text("CANCEL")),
            TextButton(
                onPressed: () {
                  Get.back();
                  clearChatHistory(true);
                },
                child: const Text("CLEAR EXCEPT STARRED")),
          ]);
    });

  }

  unBlockUser() {
    Helper.showAlert(
        message: "Unblock ${profile.name}?",
        actions: [
          TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text("CANCEL")),
          TextButton(
              onPressed: () {
                Get.back();
                Helper.showLoading(message: "Unblocking User");
                PlatformRepo().unBlockUser(profile.jid!).then((value){
                  debugPrint(value);
                  isBlocked(false);
                  Helper.hideLoading();
                }).catchError((error){
                  Helper.hideLoading();
                  debugPrint(error);
                });
              },
              child: const Text("UNBLOCK")),

        ]);
  }

  exportChat() async {
    if(chatList.isNotEmpty) {
      if (await askStoragePermission()) {
        PlatformRepo().exportChat(profile.jid.checkNull());
      }
    }else{
      toToast("There is no conversation.");
    }
  }

  forwardMessage() {
    var messageIds = List<String>.empty(growable: true);
    for(var chatItem in selectedChatList){
      messageIds.add(chatItem.messageId);
      debugPrint(messageIds.length.toString());
      debugPrint(selectedChatList.length.toString());

    }
    if(messageIds.length == selectedChatList.length){
      isSelected(false);
      selectedChatList.clear();
      Get.toNamed(Routes.CONTACTS, arguments: {"forward" : true, "messageIds": messageIds });
    }
  }

  void closeKeyBoard() {
    // keyboardVisibilityController.isVisible ? FocusManager.instance.primaryFocus?.unfocus() : null;
    FocusManager.instance.primaryFocus!.unfocus();
  }
}
