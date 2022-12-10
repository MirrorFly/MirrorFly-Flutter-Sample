import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mirror_fly_demo/app/base_controller.dart';
import 'package:mirror_fly_demo/app/common/de_bouncer.dart';
import 'package:mirror_fly_demo/app/data/session_management.dart';
import 'package:mirror_fly_demo/app/data/permissions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:record/record.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/constants.dart';
import '../../../data/helper.dart';
import '../../../routes/app_pages.dart';

import 'package:flysdk/flysdk.dart';

class ChatController extends GetxController
    with GetTickerProviderStateMixin, BaseController {
  var chatList = List<ChatMessageModel>.empty(growable: true).obs;
  late AnimationController controller;
  ScrollController scrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  ItemScrollController searchScrollController = ItemScrollController();

  late ChatMessageModel replyChatMessage;

  var isReplying = false.obs;

  String currentPostLabel = "00:00";

  var maxDuration = 100.obs;
  var currentPos = 0.obs;
  var isPlaying = false.obs;
  var audioPlayed = false.obs;

  var isUserTyping = false.obs;
  var isAudioRecording = Constants.audioRecordInitial.obs;
  late Timer? _audioTimer;
  var timerInit = "00.00".obs;
  DateTime? startTime;

  double screenHeight = 0.0;
  double screenWidth = 0.0;

  AudioPlayer player = AudioPlayer();

  late String audioSavePath;
  late String recordedAudioPath;
  late Record record;

  TextEditingController messageController = TextEditingController();

  FocusNode focusNode = FocusNode();

  var calendar = DateTime.now();
  var profile_ = Profile().obs;

  Profile get profile => profile_.value;
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

  final _isMemberOfGroup = false.obs;

  set isMemberOfGroup(value) => _isMemberOfGroup.value = value;

  bool get isMemberOfGroup =>
      profile.isGroupProfile ?? false ? _isMemberOfGroup.value : true;

  var profileDetail = Profile();

  @override
  void onInit() {
    super.onInit();
    // var profileDetail = Get.arguments as Profile;
    // profile_.value = profileDetail;
    // if(profile_.value.jid == null){
      getProfileDetails(SessionManagement.getChatJid().checkNull()).then((value){
        profile_(value);
        onready();
        initListeners();
      });
    // }else{
    //   debugPrint("Got the Profile value");
    // }


    player.onDurationChanged.listen((Duration d) {
      //get the duration of audio
      maxDuration(d.inMilliseconds);
    });

    player.onPlayerCompletion.listen((event) {
      isPlaying(false);
      audioPlayed(false);
    });

    player.onAudioPositionChanged.listen((Duration p) {
      currentPos(p.inMilliseconds); //get the current position of playing audio

      int milliseconds = currentPos.value;
      //generating the duration label
      int sHours = Duration(milliseconds: milliseconds).inHours;
      int sMinutes = Duration(milliseconds: milliseconds).inMinutes;
      int sSeconds = Duration(milliseconds: milliseconds).inSeconds;

      int rHours = sHours;
      int rMinutes = sMinutes - (sHours * 60);
      int rSeconds = sSeconds - (sMinutes * 60 + sHours * 60 * 60);

      currentPostLabel = "$rHours:$rMinutes:$rSeconds";
    });

    setAudioPath();

    filteredPosition.bindStream(filteredPosition.stream);
    ever(filteredPosition, (callback) {
      lastPosition(callback.length);
      //chatList.refresh();
    });

    chatList.bindStream(chatList.stream);
    ever(chatList, (callback) {});
    isUserTyping.bindStream(isUserTyping.stream);
    ever(isUserTyping,(callback){
      mirrorFlyLog("typing ", callback.toString());
      if(callback){
        sendUserTypingStatus();
        DeBouncer(milliseconds: 2100).run(() {
          sendUserTypingGoneStatus();
        });
      }else{
        sendUserTypingGoneStatus();
      }
    });
    messageController.addListener(() {
      mirrorFlyLog("typing", "typing..");
    });
  }

  void onready() {
    debugPrint("isBlocked===> ${profile.isBlocked}");
    debugPrint("profile detail===> ${profile.toJson().toString()}");
    isBlocked(profile.isBlocked);
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    Member(jid: profile.jid.checkNull())
        .getProfileDetails()
        .then((value) => profileDetail = value);
    memberOfGroup();
    setChatStatus();
    isLive = true;
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        showEmoji(false);
      }
    });
    keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
          if (!visible) {
            focusNode.canRequestFocus = false;
          }
        });
    //scrollController.addListener(_scrollController);

    FlyChat.setOnGoingChatUser(profile.jid!);
    getChatHistory(profile.jid!);
    // compute(getChatHistory, profile.jid);
    debugPrint("==================");
    debugPrint(profile.image);
    sendReadReceipt();
  }

  scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.linear,
        );
      }
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    FlyChat.setOnGoingChatUser("");
    isLive = false;
    super.onClose();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  sendMessage(Profile profile) {
    var replyMessageId = "";

    if (isReplying.value) {
      replyMessageId = replyChatMessage.messageId;
    }
    isReplying(false);
    if (messageController.text
        .trim()
        .isNotEmpty) {
      FlyChat.sendTextMessage(
          messageController.text, profile.jid.toString(), replyMessageId)
          .then((value) {
        messageController.text = "";
        isUserTyping(false);
        //need to work here
        final jsonResponse = json.decode(value);
        //Written for iOS Response
        if(jsonResponse.containsKey('some')){
          debugPrint("Inside some condition");
          value = json.encode(jsonResponse['some']);
          debugPrint(value);
        }
        ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
        chatList.add(chatMessageModel);
        scrollToBottom();
      });
    }
  }

  sendLocationMessage(Profile profile, double latitude, double longitude) {
    var replyMessageId = "";
    if (isReplying.value) {
      replyMessageId = replyChatMessage.messageId;
    }
    isReplying(false);

    FlyChat.sendLocationMessage(
        profile.jid.toString(), latitude, longitude, replyMessageId)
        .then((value) {
      mirrorFlyLog("Location_msg", value.toString());
      ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
      chatList.add(chatMessageModel);
      scrollToBottom();
    });
  }

  String getTime(int? timestamp) {
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
    var convertedTime = epochTime;
    var hourTime = manipulateMessageTime(
        context, DateTime.fromMicrosecondsSinceEpoch(convertedTime));
    calendar = DateTime.fromMicrosecondsSinceEpoch(convertedTime);
    return hourTime;
  }

  String manipulateMessageTime(BuildContext context, DateTime messageDate) {
    var format = MediaQuery
        .of(context)
        .alwaysUse24HourFormat ? 24 : 12;
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

  getChatHistory([String? from]) {
    mirrorFlyLog("chat history", "$from");
    FlyChat.getMessagesOfJid(profile.jid.checkNull()).then((value) {
      List<ChatMessageModel> chatMessageModel = chatMessageModelFromJson(value);
      chatList(chatMessageModel);
      Future.delayed(const Duration(milliseconds: 500), () {
        Future.doWhile(() {
          if (scrollController.positions.isNotEmpty) {
            if (scrollController.position.extentAfter == 0) {
              return Future.value(false);
            }
            return scrollController
                .animateTo(scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 100),
                curve: Curves.linear)
                .then((value) => true);
          }
          return true;
        });
      });
    });
    // compute(FlyChat.getMessagesOfJid, profile.jid.checkNull()).then((chatMessageModelList){
    //   chatList(chatMessageModelList);
    //   Future.delayed(const Duration(milliseconds: 500), () {
    //     Future.doWhile(() {
    //       if (scrollController.positions.isNotEmpty) {
    //         if (scrollController.position.extentAfter == 0) {
    //           return Future.value(false);
    //         }
    //         return scrollController
    //             .animateTo(scrollController.position.maxScrollExtent,
    //             duration: const Duration(milliseconds: 100),
    //             curve: Curves.linear)
    //             .then((value) => true);
    //       }
    //       return true;
    //     });
    //   });
    // });
  }

  getMedia(String mid) {
    return FlyChat.getMessageOfId(mid).then((value) {
      CheckModel chatMessageModel = checkModelFromJson(value);
      String thumbImage = chatMessageModel.mediaChatMessage.mediaThumbImage;
      thumbImage = thumbImage.replaceAll("\n", "");
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
      width: width ?? MediaQuery
          .of(context)
          .size
          .width * 0.60,
      height: height ?? MediaQuery
          .of(context)
          .size
          .height * 0.4,
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
        return FlyChat
          .sendImageMessage(profile.jid!, path, caption, replyMessageID)
          .then((value) {
        ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
        chatList.add(chatMessageModel);
        scrollToBottom();
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
      if (result.files.first.extension == 'jpg' || result.files.first.extension == 'JPEG' ||
          result.files.first.extension == 'png') {
        debugPrint("Picked Image File");
        imagePath.value = (result.files.single.path!);
        Get.toNamed(Routes.imagePreview, arguments: {
          "filePath": imagePath.value,
          "userName": profile.name!
        });
      } else if (result.files.first.extension == 'mp4' ||result.files.first.extension == 'MP4' ||
          result.files.first.extension == 'mov' ||
          result.files.first.extension == 'mkv') {
        debugPrint("Picked Video File");
        imagePath.value = (result.files.single.path!);
        Get.toNamed(Routes.videoPreview, arguments: {
          "filePath": imagePath.value,
          "userName": profile.name!
        });
      }
    } else {
      // User canceled the picker
      debugPrint("======User Cancelled=====");
    }
  }

  documentPickUpload() async {
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
    FlyChat.markAsReadDeleteUnreadSeparator(profile.jid!).then((value) {
      debugPrint("Chat Read Receipt Response ==> $value");
    });
  }

  sendVideoMessage(String videoPath, String caption, String replyMessageID) {
    if (isReplying.value) {
      replyMessageID = replyChatMessage.messageId;
    }
    isReplying(false);
    return FlyChat.sendVideoMessage(
        profile.jid!, videoPath, caption, replyMessageID)
        .then((value) {
      ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
      chatList.add(chatMessageModel);
      scrollToBottom();
      return chatMessageModel;
    });
  }

  checkFile(String mediaLocalStoragePath) {
    return mediaLocalStoragePath.isNotEmpty &&
        File(mediaLocalStoragePath).existsSync();
  }

  downloadMedia(String messageId) async {
    if (await askStoragePermission()) {
      FlyChat.downloadMedia(messageId);
    }
  }

  playAudio(String filePath) async {
    if (!isPlaying.value && !audioPlayed.value) {
      int result = await player.play(filePath, isLocal: true);
      if (result == 1) {
        //play success

        isPlaying(true);
        audioPlayed(true);
      } else {
        mirrorFlyLog("", "Error while playing audio.");
      }
    } else if (audioPlayed.value && !isPlaying.value) {
      int result = await player.resume();
      if (result == 1) {
        //resume success

        isPlaying(true);
        audioPlayed(true);
      } else {
        mirrorFlyLog("", "Error on resume audio.");
      }
    } else {
      int result = await player.pause();
      if (result == 1) {
        //pause success

        isPlaying(false);
      } else {
        mirrorFlyLog("", "Error on pause audio.");
      }
    }
  }

  Future<bool> askContactsPermission() async {
    final permission = await AppPermission.getContactPermission();
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
    final permission = await AppPermission.getStoragePermission();
    switch (permission) {
      case PermissionStatus.granted:
        return true;
      case PermissionStatus.permanentlyDenied:
        return false;
      default:
        debugPrint("Permission default");
        return false;
    }
  }

  Future<bool> askManageStoragePermission() async {
    final permission = await AppPermission.getManageStoragePermission();
    switch (permission) {
      case PermissionStatus.granted:
        return true;
      case PermissionStatus.permanentlyDenied:
        return false;
      default:
        debugPrint("Permission default");
        return false;
    }
  }

  sendContactMessage(List<String> contactList, String contactName) {
    var replyMessageId = "";

    if (isReplying.value) {
      replyMessageId = replyChatMessage.messageId;
    }
    isReplying(false);
    return FlyChat.sendContactMessage(
        contactList, profile.jid!, contactName, replyMessageId)
        .then((value) {
      ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
      chatList.add(chatMessageModel);
      scrollToBottom();
      return chatMessageModel;
    });
  }

  sendDocumentMessage(String documentPath, String replyMessageId) {
    if (isReplying.value) {
      replyMessageId = replyChatMessage.messageId;
    }
    isReplying(false);
    FlyChat.sendDocumentMessage(profile.jid!, documentPath, replyMessageId)
        .then((value) {
      ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
      chatList.add(chatMessageModel);
      scrollToBottom();
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

      FlyChat.openFile(mediaLocalStoragePath).catchError((onError) {
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
      debugPrint("media does not exist");
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
        mirrorFlyLog("", 'max duration: ${duration.inMilliseconds}');
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
    isUserTyping(false);
    isReplying(false);
    FlyChat.sendAudioMessage(
        profile.jid!, filePath, isRecorded, duration, replyMessageId)
        .then((value) {
      ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
      chatList.add(chatMessageModel);
      scrollToBottom();
      return chatMessageModel;
    });
  }

  void isTyping([String? typingText]) {
    messageController.text.isNotEmpty
        ? isUserTyping(true)
        : isUserTyping(false);
  }

  clearChatHistory(bool isStarredExcluded) {
    FlyChat.clearChat(profile.jid!, "chat", isStarredExcluded).then((value) {
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
    for (var chatItem in selectedChatList) {
      chatItem.isSelected = false;
    }
    selectedChatList.clear();
  }

  void addChatSelection(ChatMessageModel chatList) {
    if (chatList.messageType != Constants.mNotification) {
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

  reportChatOrUser() {
    Future.delayed(const Duration(milliseconds: 100), () {
      var chatMessage =
      selectedChatList.isNotEmpty ? selectedChatList[0] : null;
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
                  FlyChat.reportUserOrMessages(
                      profile.jid!,
                      chatMessage?.messageChatType ?? "chat",
                      chatMessage?.messageId ?? "")
                      .then((value) {
                    //report success
                    debugPrint(value.toString());
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
    // PlatformRepo.copyTextMessages(selectedChatList[0].messageId);
    debugPrint('Copy text ==> ${selectedChatList[0].messageTextContent}');
    Clipboard.setData(
        ClipboardData(text: selectedChatList[0].messageTextContent));
    // selectedChatList.clear();
    // isSelected(false);
    clearChatSelection(selectedChatList[0]);
  }

  Map<bool, bool> isMessageCanbeRecalled() {
    var recallTimeDifference = ((DateTime
        .now()
        .millisecondsSinceEpoch - 30000) * 1000);
    return {
      selectedChatList.any((element) => element.isMessageSentByMe && !element.isMessageRecalled &&(element.messageSentTime >
          recallTimeDifference)):
      selectedChatList.any((element) =>
      !element.isMessageRecalled && (element.isMediaMessage() && element.mediaChatMessage!
          .mediaLocalStoragePath
          .checkNull()
          .isNotEmpty))
    };
  }

  void deleteMessages() {
    var isRecallAvailable = isMessageCanbeRecalled().keys.first;
    var isCheckBoxShown = isMessageCanbeRecalled().values.first;
    var deleteChatListID = List<String>.empty(growable: true);
    for (var element in selectedChatList) {
      deleteChatListID.add(element.messageId);
    }
    /*for (var chatList in selectedChatList) {
      deleteChatListID.add(chatList.messageId);
      if ((chatList.messageSentTime > (DateTime.now().millisecondsSinceEpoch - 30000) * 1000) && chatList.isMessageSentByMe) {
        isRecallAvailable = true;
      } else {
        isRecallAvailable = false;
        break;
      }
    }*/
    if (deleteChatListID.isEmpty) {
      return;
    }
    var isMediaDelete = false.obs;
    var chatType = profile.isGroupProfile ?? false ? "groupchat" : "chat";
    Helper.showAlert(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                "Are you sure you want to delete selected Message${selectedChatList
                    .length > 1 ? "s" : ""}"),
            isCheckBoxShown ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: (){
                    isMediaDelete(!isMediaDelete.value);
                    mirrorFlyLog("isMediaDelete", isMediaDelete.value
                        .toString());
                  },
                  child: Row(
                    children: [
                      Obx(() {
                        return Checkbox(
                            value: isMediaDelete.value, onChanged: (value) {
                          isMediaDelete(!isMediaDelete.value);
                          mirrorFlyLog("isMediaDelete", value.toString());
                        });
                      }),
                      const Expanded(
                        child: Text("Delete media from my phone"),
                      ),
                    ],
                  ),
                )
              ],
            ) : const SizedBox(),
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
                Helper.showLoading(message: 'Deleting Message');
                FlyChat.deleteMessagesForMe(
                    profile.jid!,chatType, deleteChatListID, isMediaDelete.value)
                    .then((value) {
                  debugPrint(value.toString());
                  Helper.hideLoading();
                  if (value!=null && value) {
                    removeChatList(selectedChatList);
                  }
                  isSelected(false);
                  selectedChatList.clear();
                });
              },
              child: const Text("DELETE FOR ME")),
          isRecallAvailable
              ? TextButton(
              onPressed: () {
                Get.back();
                Helper.showLoading(
                    message: 'Deleting Message for Everyone');
                FlyChat.deleteMessagesForEveryone(
                    profile.jid!,chatType, deleteChatListID, isMediaDelete.value)
                    .then((value) {
                  debugPrint(value.toString());
                  Helper.hideLoading();
                  if (value!=null && value) {
                    // removeChatList(selectedChatList);//
                    for (var chatList in selectedChatList) {
                      chatList.isMessageRecalled = true;
                      this.chatList.refresh();
                    }
                  }
                  isSelected(false);
                  selectedChatList.clear();
                });
              },
              child: const Text("DELETE FOR EVERYONE"))
              : const SizedBox.shrink(),
        ]);
  }

  removeChatList(RxList<ChatMessageModel> selectedChatList) {
    for (var chatList in selectedChatList) {
      this.chatList.remove(chatList);
    }
  }

  messageInfo() {
    Future.delayed(const Duration(milliseconds: 100), () {
      debugPrint("sending mid ===> ${selectedChatList[0].messageId}");
      Get.toNamed(Routes.messageInfo, arguments: {
        "messageID": selectedChatList[0].messageId,
        "chatMessage": selectedChatList[0]
      });
      clearChatSelection(selectedChatList[0]);
    });
  }

  favouriteMessage() {
    Helper.showLoading(
        message: selectedChatList[0].isMessageStarred
            ? 'Unfavoriting Message'
            : 'Favoriting Message');

    FlyChat.updateFavouriteStatus(selectedChatList[0].messageId, profile.jid!,
        !selectedChatList[0].isMessageStarred)
        .then((value) {
      clearChatSelection(selectedChatList[0]);
      Helper.hideLoading();
    });
  }

  Widget getLocationImage(LocationChatMessage? locationChatMessage,
      double width, double height) {
    return InkWell(
        onTap: () async {
          String googleUrl =
              'https://www.google.com/maps/search/?api=1&query=${locationChatMessage
              .latitude}, ${locationChatMessage.longitude}';
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
                  FlyChat.blockUser(profile.jid!).then((value) {
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
    Helper.showAlert(message: "Unblock ${profile.name}?", actions: [
      TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text("CANCEL")),
      TextButton(
          onPressed: () {
            Get.back();
            Helper.showLoading(message: "Unblocking User");
            FlyChat.unblockUser(profile.jid!).then((value) {
              debugPrint(value.toString());
              isBlocked(false);
              Helper.hideLoading();
            }).catchError((error) {
              Helper.hideLoading();
              debugPrint(error);
            });
          },
          child: const Text("UNBLOCK")),
    ]);
  }

  var filteredPosition = <int>[].obs;
  var searchedText = TextEditingController();

  setSearch(String text) {
    filteredPosition.clear();
    if (searchedText.text.isNotEmpty) {
      for (var i = 0; i < chatList.length; i++) {
        if (chatList[i].messageType == Constants.mText &&
            chatList[i]
                .messageTextContent
                .startsWithTextInWords(searchedText.text)) {
          filteredPosition.add(i);
        } else if (chatList[i].messageType == Constants.mImage &&
            chatList[i].mediaChatMessage!.mediaCaptionText.isNotEmpty &&
            chatList[i]
                .mediaChatMessage!
                .mediaCaptionText
                .startsWithTextInWords(searchedText.text)) {
          filteredPosition.add(i);
        } else if (chatList[i].messageType == Constants.mVideo &&
            chatList[i].mediaChatMessage!.mediaCaptionText.isNotEmpty &&
            chatList[i]
                .mediaChatMessage!
                .mediaCaptionText
                .startsWithTextInWords(searchedText.text)) {
          filteredPosition.add(i);
        } else if (chatList[i].messageType == Constants.mDocument &&
            chatList[i].mediaChatMessage!.mediaFileName.isNotEmpty &&
            chatList[i]
                .mediaChatMessage!
                .mediaFileName
                .startsWithTextInWords(searchedText.text)) {
          filteredPosition.add(i);
        } else if (chatList[i].messageType == Constants.mContact &&
            chatList[i].contactChatMessage!.contactName.isNotEmpty &&
            chatList[i]
                .contactChatMessage!
                .contactName
                .startsWithTextInWords(searchedText.text)) {
          filteredPosition.add(i);
        }
      }
    }
  }

  var lastPosition = (-1).obs;
  var searchedPrev = "";
  var searchedNxt = "";

  searchInit() {
    lastPosition = (-1).obs;
    searchedPrev = "";
    searchedNxt = "";
    filteredPosition.clear();
    searchedText.clear();
  }

  scrollUp() {
    if (searchedPrev != (searchedText.text.toString())) {
      var pre = getPreviousPosition(findLastVisibleItemPosition());
      lastPosition.value = pre;
      searchedPrev = searchedText.text;
    } else if (filteredPosition.isNotEmpty) {
      lastPosition.value = max(lastPosition.value - 1, (-1));
    } else {
      lastPosition.value = -1;
    }
    if (lastPosition.value > -1 &&
        lastPosition.value <= filteredPosition.length) {
      var po = filteredPosition;
      _scrollToPosition(po[lastPosition.value] + 1);
    } else {
      toToast("No Results Found");
      searchedNxt = "";
    }
  }

  scrollDown() {
    if (searchedNxt != searchedText.text.toString()) {
      var nex = getNextPosition(findLastVisibleItemPosition());
      lastPosition.value = nex;
      searchedNxt = searchedText.text;
    } else if (filteredPosition.isNotEmpty) {
      lastPosition.value = min(lastPosition.value - 1, filteredPosition.length);
    } else {
      lastPosition.value = -1;
    }
    if (lastPosition.value > -1 &&
        lastPosition.value <= filteredPosition.length) {
      var po = filteredPosition.reversed.toList();
      _scrollToPosition(po[lastPosition.value] + 1);
    } else {
      toToast("No Results Found");
      searchedPrev = "";
    }
  }

  var color = Colors.transparent.obs;

  _scrollToPosition(int position) {
    var currentPosition = (chatList.length - (position));
    chatList[chatList.length - position].isSelected = true;
    searchScrollController.jumpTo(index: currentPosition);
    Future.delayed(const Duration(milliseconds: 800), () {
      currentPosition = (chatList.length - position);
      chatList[chatList.length - position].isSelected = false;
      chatList.refresh();
    });
  }

  int getPreviousPosition(int visiblePos) {
    for (var i = 0; i < filteredPosition.length; i++) {
      var po = filteredPosition.reversed.toList();
      if (visiblePos > po[i]) {
        return filteredPosition.indexOf(po[i]);
      }
    }
    return -1;
  }

  int getNextPosition(int visiblePos) {
    for (var i = 0; i < filteredPosition.length; i++) {
      if (visiblePos <= filteredPosition[i]) {
        return i;
      }
    }
    return -1;
  }

  final ItemPositionsListener itemPositionsListener =
  ItemPositionsListener.create();

  int findLastVisibleItemPosition() {
    var r = itemPositionsListener.itemPositions.value
        .where((ItemPosition position) => position.itemTrailingEdge < 1)
        .reduce((ItemPosition min, ItemPosition position) =>
    position.itemTrailingEdge < min.itemTrailingEdge ? position : min)
        .index;
    return chatList.length - r;
  }

  exportChat() async {
    if (chatList.isNotEmpty) {
      if (await askStoragePermission()) {
        FlyChat.exportChatConversationToEmail(profile.jid.checkNull());
      }
    } else {
      toToast("There is no conversation.");
    }
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
              "result of forward ==> ${(value as Profile)
                  .toJson()
                  .toString()}");
          profile_.value = value;
          isBlocked(profile.isBlocked);
          memberOfGroup();
          FlyChat.setOnGoingChatUser(profile.jid!);
          getChatHistory();
          sendReadReceipt();
        }
      });
    }
  }

  void closeKeyBoard() {
    FocusManager.instance.primaryFocus!.unfocus();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    startTime = DateTime.now();
    _audioTimer = Timer.periodic(
      oneSec,
          (Timer timer) {
        final minDur = DateTime
            .now()
            .difference(startTime!)
            .inMinutes;
        final secDur = DateTime
            .now()
            .difference(startTime!)
            .inSeconds % 60;
        String min = minDur < 10 ? "0$minDur" : minDur.toString();
        String sec = secDur < 10 ? "0$secDur" : secDur.toString();
        timerInit("$min:$sec");
      },
    );
  }

  Future<void> cancelRecording() async {
    var filePath = await record.stop();
    File(filePath!).delete();
    _audioTimer?.cancel();
    record.dispose();
    _audioTimer = null;
    isAudioRecording(Constants.audioRecordDelete);

    Future.delayed(const Duration(milliseconds: 1500),
            () => isAudioRecording(Constants.audioRecordInitial));
  }

  Future<void> startRecording() async {
    if (await Record().hasPermission()) {
      record = Record();
      timerInit("00.00");
      isAudioRecording(Constants.audioRecording);
      startTimer();
      await record.start(
        path:
        "$audioSavePath/audio_${DateTime
            .now()
            .millisecondsSinceEpoch}.m4a",
        encoder: AudioEncoder.AAC,
        bitRate: 128000,
        samplingRate: 44100,
      );
    }
  }

  Future<void> stopRecording() async {
    isAudioRecording(Constants.audioRecordDone);
    isUserTyping(true);
    _audioTimer?.cancel();
    _audioTimer = null;
    await Record().stop().then((filePath) async {
      if (File(filePath!).existsSync()) {
        recordedAudioPath = filePath;
      } else {
        debugPrint("File Not Found For Image Upload");
      }
      debugPrint(filePath);
    });
  }

  Future<void> deleteRecording() async {
    var filePath = await record.stop();
    File(filePath!).delete();
    isUserTyping(false);
    isAudioRecording(Constants.audioRecordInitial);
    timerInit("00.00");
    record.dispose();
  }

  Future<void> setAudioPath() async {
    Directory? directory = Platform.isAndroid
        ? await getExternalStorageDirectory() //FOR ANDROID
        : await getApplicationSupportDirectory(); //FOR iOS
    if(directory != null){
      audioSavePath = directory.path;
      debugPrint(audioSavePath);
    }else{
      debugPrint("=======Unable to set Audio Path=========");
    }

  }

  sendRecordedAudioMessage() {
    final format = DateFormat('mm:ss');
    final dt = format.parse(timerInit.value, true);
    final recordDuration = dt.millisecondsSinceEpoch;
    sendAudioMessage(recordedAudioPath, true, recordDuration.toString());
    isUserTyping(false);
    isAudioRecording(Constants.audioRecordInitial);
    timerInit("00.00");
    record.dispose();
  }

  infoPage() {
    if (profile.isGroupProfile ?? false) {
      Get.toNamed(Routes.groupInfo, arguments: profile)?.then((value) {
        if (value != null) {
          profile_(value as Profile);
          isBlocked(profile.isBlocked);
          memberOfGroup();
          FlyChat.setOnGoingChatUser(profile.jid!);
          getChatHistory();
          sendReadReceipt();
        }
      });
    } else {
      Get.toNamed(Routes.chatInfo, arguments: profile)?.then((value) {});
    }
  }

  gotoSearch() {
    Future.delayed(const Duration(milliseconds: 100), () {
      Get.toNamed(Routes.chatSearch, arguments: chatList.value);
      /*if (searchScrollController.isAttached) {
        searchScrollController.jumpTo(index: chatList.value.length - 1);
      }*/
    });
  }

  sendUserTypingStatus(){
    FlyChat.sendTypingStatus(profile.jid.checkNull(),profile.getChatType());
  }

  sendUserTypingGoneStatus(){
    FlyChat.sendTypingGoneStatus(profile.jid.checkNull(),profile.getChatType());
  }

  @override
  void onMessageReceived(chatMessage) {
    super.onMessageReceived(chatMessage);
    mirrorFlyLog("chatController", "onMessageReceived");
    ChatMessageModel chatMessageModel = sendMessageModelFromJson(chatMessage);
    if (chatMessageModel.chatUserJid == profile.jid) {
      chatList.add(chatMessageModel);
      scrollToBottom();
      if (isLive) {
        sendReadReceipt();
      }
    }
  }

  @override
  void onMessageStatusUpdated(event) {
    super.onMessageStatusUpdated(event);
    ChatMessageModel chatMessageModel = sendMessageModelFromJson(event);
    if (chatMessageModel.chatUserJid == profile.jid) {
      final index = chatList.value.indexWhere(
              (message) => message.messageId == chatMessageModel.messageId);
      debugPrint("Message Status Update index of search $index");
      if (index != -1) {
        // Helper.hideLoading();
        chatList[index] = chatMessageModel;
      } else {
        chatList.add(chatMessageModel);
        scrollToBottom();
      }
    }
  }

  @override
  void onMediaStatusUpdated(event) {
    super.onMediaStatusUpdated(event);
    ChatMessageModel chatMessageModel = sendMessageModelFromJson(event);
    if (chatMessageModel.chatUserJid == profile.jid) {
      final index = chatList.value.indexWhere(
              (message) => message.messageId == chatMessageModel.messageId);
      debugPrint("Media Status Update index of search $index");
      if (index != -1) {
        chatList[index] = chatMessageModel;
      }
    }
  }

  @override
  void onGroupProfileUpdated(groupJid) {
    super.onGroupProfileUpdated(groupJid);
    if (profile.jid.checkNull() == groupJid.toString()) {
      FlyChat.getProfileDetails(profile.jid.checkNull(), false).then((value) {
        if (value != null) {
          var member = Profile.fromJson(json.decode(value.toString()));
          profile_.value = member;
          profile_.refresh();
        }
      });
    }
  }

  @override
  void onLeftFromGroup({required String groupJid, required String userJid}) {
    super.onLeftFromGroup(groupJid: groupJid, userJid: userJid);
    if (profile.isGroupProfile ?? false) {
      if (groupJid == profile.jid &&
          userJid == SessionManagement.getUserJID()) {
        //current user leave from the group
        _isMemberOfGroup(false);
      } else if (groupJid == profile.jid) {
        setChatStatus();
      }
    }
  }

  @override
  void setTypingStatus(String singleOrgroupJid, String userId, String typingStatus) {
    super.setTypingStatus(singleOrgroupJid, userId, typingStatus);
    if(profile.jid.checkNull() == singleOrgroupJid){
      var jid = profile.isGroupProfile ?? false ? userId : singleOrgroupJid;
      if(!typingList.contains(jid)){
        typingList.add(jid);
      }
      if(typingStatus.toLowerCase() == Constants.composing){
        if(profile.isGroupProfile ?? false){
          groupParticipantsName("");
          getProfileDetails(jid).then((value) => userPresenceStatus("${value.name} typing..."));
        }else {//if(!profile.isGroupProfile!){//commented if due to above if condition works
          userPresenceStatus("typing...");
        }
      }else{
        if(typingList.isNotEmpty && typingList.contains(jid)){
          typingList.remove(jid);
        }
        setChatStatus();
      }
    }
  }

  memberOfGroup() {
    if (profile.isGroupProfile ?? false) {
      FlyChat.isMemberOfGroup(profile.jid.checkNull(), null)
          .then((bool? value) {
        if (value != null) {
          _isMemberOfGroup(value);
        }
      });
    }
  }

  var userPresenceStatus = ''.obs;
  var typingList = <String>[].obs;

  setChatStatus() {
    if (profile.isGroupProfile ?? false) {
      if (typingList.isNotEmpty) {
        userPresenceStatus(
            "${Member(jid: typingList.last)
                .getUsername()} typing...");
      } else {
        getParticipantsNameAsCsv(profile.jid.checkNull());
      }
    } else {
      FlyChat.getUserLastSeenTime(profile.jid.toString()).then((value) {
        userPresenceStatus(value.toString());
      }).catchError((er){
        userPresenceStatus("");
      });
    }
  }

  var groupParticipantsName = ''.obs;

  getParticipantsNameAsCsv(String jid) {
    FlyChat.getGroupMembersList(jid, false).then((value) {
      if (value != null) {
        var str = <String>[];
        var groupsMembersProfileList = memberFromJson(value);
        for (var it in groupsMembersProfileList) {
          if (it.jid.checkNull() !=
              SessionManagement.getUserJID().checkNull()) {
            str.add(it.name.checkNull());
          }
        }
        groupParticipantsName(str.join(","));
      }
    });
  }

  String get subtitle =>
      userPresenceStatus.isEmpty
          ? /*groupParticipantsName.isNotEmpty
          ? groupParticipantsName.toString()
          :*/ Constants.emptyString
          : userPresenceStatus.toString();

  final ImagePicker _picker = ImagePicker();

  onCameraClick() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      Get.toNamed(Routes.imagePreview,
          arguments: {"filePath": photo.path, "userName": profile.name!});
    }
  }

  onAudioClick() {
    Get.back();
    pickAudio();
  }

  onGalleryClick() async {
    try {
      imagePicker();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  onContactClick() async {
    if (await askContactsPermission()) {
      Get.toNamed(Routes.localContact);
    } else {
      debugPrint("Permission Denied");
      ScaffoldMessenger.of(Get.context!)
          .showSnackBar(SnackBar(
        content: const Text('Permission Denied'),
        action: SnackBarAction(
            label: 'Ok',
            onPressed: ScaffoldMessenger
                .of(Get.context!)
                .hideCurrentSnackBar),
      ));
    }
  }

  onLocationClick() {
    AppPermission.getLocationPermission()
        .then((bool value) {
      mirrorFlyLog(
          "Location permission", value.toString());
      if (value) {
        Get.back();
        Get.toNamed(Routes.locationSent)
            ?.then((value) {
          if (value != null) {
            value as LatLng;
            sendLocationMessage(
                profile,
                value.latitude,
                value.longitude);
          }
        });
      }
    });
  }
}
