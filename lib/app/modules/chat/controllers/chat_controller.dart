import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:google_cloud_translation/google_cloud_translation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mirror_fly_demo/app/common/de_bouncer.dart';
import 'package:mirror_fly_demo/app/data/session_management.dart';
import 'package:mirror_fly_demo/app/data/permissions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:record/record.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/constants.dart';
import '../../../data/apputils.dart';
import '../../../data/helper.dart';
import '../../../model/reply_hash_map.dart';
import '../../../routes/app_pages.dart';

import 'package:flysdk/flysdk.dart';

import '../chat_widgets.dart';

class ChatController extends FullLifeCycleController
    with FullLifeCycleMixin, GetTickerProviderStateMixin {
  final translator = Translation(apiKey: Constants.googleTranslateKey);

  var chatList = List<ChatMessageModel>.empty(growable: true).obs;
  late AnimationController controller;

  // ScrollController scrollController = ScrollController();

  ItemScrollController newScrollController = ItemScrollController();
  ItemPositionsListener newitemPositionsListener =
      ItemPositionsListener.create();
  ItemScrollController searchScrollController = ItemScrollController();

  late ChatMessageModel replyChatMessage;

  var isReplying = false.obs;

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

  // var keyboardVisibilityController = KeyboardVisibilityController();

  // late StreamSubscription<bool> keyboardSubscription;

  final _isMemberOfGroup = false.obs;

  set isMemberOfGroup(value) => _isMemberOfGroup.value = value;

  bool get isMemberOfGroup =>
      profile.isGroupProfile ?? false ? _isMemberOfGroup.value : true;

  var profileDetail = Profile();

  String? nJid;
  String? starredChatMessageId;

  @override
  void onInit() async {
    super.onInit();
    //await FlyChat.enableDisableBusyStatus(true);
    // var profileDetail = Get.arguments as Profile;
    // profile_.value = profileDetail;
    // if(profile_.value.jid == null){
    var userJid = SessionManagement.getChatJid().checkNull();
    if (Get.parameters['jid'] != null) {
      nJid = Get.parameters['jid'];
      debugPrint("parameter :${Get.parameters['jid']}");
      if (nJid != null) {
        userJid = Get.parameters['jid'] as String;
      }
    } else if (Get.parameters['isFromStarred'] == "true") {
      if (Get.parameters['userJid'] != null) {
        userJid = Get.parameters['userJid'] as String;
      }
      if (Get.parameters['messageId'] != null) {
        starredChatMessageId = Get.parameters['messageId'] as String;
      }
    }
    if (userJid.isEmpty) {
      var profileDetail = Get.arguments as Profile;
      profile_(profileDetail);
      checkAdminBlocked();
      ready();
      // initListeners();
    } else {
      getProfileDetails(userJid).then((value) {
        SessionManagement.setChatJid("");
        profile_(value);
        checkAdminBlocked();
        ready();
        // initListeners();
      });
    }

    player.onPlayerCompletion.listen((event) {
      playingChat!.mediaChatMessage!.isPlaying = false;
      playingChat!.mediaChatMessage!.currentPos = 0;
      player.stop();
      chatList.refresh();
      playingChat = null;
    });

    player.onAudioPositionChanged.listen((Duration p) {
      playingChat?.mediaChatMessage!.currentPos = (p.inMilliseconds);
      chatList.refresh();
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
    ever(isUserTyping, (callback) {
      mirrorFlyLog("typing ", callback.toString());
      if (callback) {
        sendUserTypingStatus();
        DeBouncer(milliseconds: 2100).run(() {
          sendUserTypingGoneStatus();
        });
      } else {
        sendUserTypingGoneStatus();
      }
    });
    messageController.addListener(() {
      mirrorFlyLog("typing", "typing..");
    });
  }

  var showHideRedirectToLatest = false.obs;

  void ready() {
    debugPrint("isBlocked===> ${profile.isBlocked}");
    debugPrint("profile detail===> ${profile.toJson().toString()}");
    getUnsentMessageOfAJid();
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
    /*keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
          if (!visible) {
            focusNode.canRequestFocus = false;
          }
        });*/
    //scrollController.addListener(_scrollController);
    /*scrollController.addListener(() {
      if (scrollController.offset <= scrollController.position.minScrollExtent &&
          !scrollController.position.outOfRange) {
        showHideRedirectToLatest(false);
      }else{
        showHideRedirectToLatest(true);
      }
    });*/
    newitemPositionsListener.itemPositions.addListener(() {
      var pos = findLastVisibleItemPositionForChat();
      if (pos >= 1) {
        showHideRedirectToLatest(true);
      } else {
        showHideRedirectToLatest(false);
        unreadCount(0);
      }
    });

    FlyChat.setOnGoingChatUser(profile.jid!);
    SessionManagement.setCurrentChatJID(profile.jid.checkNull());
    getChatHistory();
    // compute(getChatHistory, profile.jid);
    debugPrint("==================");
    debugPrint(profile.image);
    sendReadReceipt();
  }

  scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      /*if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.linear,
        );
      }*/
      if (newScrollController.isAttached) {
        newScrollController.scrollTo(
            index: 0,
            duration: const Duration(milliseconds: 100),
            curve: Curves.linear);
        unreadCount(0);
      }
    });
  }

  scrollToEnd() {
    /*if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 100),
        curve: Curves.linear,
      );
    }*/
    newScrollController.jumpTo(index: 0);
    showHideRedirectToLatest(false);
  }

  @override
  void onClose() {
    // scrollController.dispose();
    debugPrint("onClose");
    saveUnsentMessage();
    FlyChat.setOnGoingChatUser("");
    SessionManagement.setCurrentChatJID("");
    isLive = false;
    player.stop();
    player.dispose();
    super.onClose();
  }
  @override
  void dispose(){
    super.dispose();
    debugPrint("dispose");
  }

  clearMessage(){
    if (profile.jid.checkNull().isNotEmpty) {
      FlyChat.saveUnsentMessage(profile.jid.checkNull(), '');
      ReplyHashMap.saveReplyId(
          profile.jid.checkNull(), '');
    }
  }

  saveUnsentMessage() {
    if (messageController.text.trim().isNotEmpty &&
        profile.jid.checkNull().isNotEmpty) {
      FlyChat.saveUnsentMessage(
          profile.jid.checkNull(), messageController.text.toString());
    }
    if (isReplying.value) {
      ReplyHashMap.saveReplyId(
          profile.jid.checkNull(), replyChatMessage.messageId);
    }
  }

  getUnsentMessageOfAJid() async {
    if (profile.jid.checkNull().isNotEmpty) {
      FlyChat.getUnsentMessageOfAJid(profile.jid.checkNull()).then((value) {
        if (value != null) {
          messageController.text = value;
        } else {
          messageController.text = '';
        }
        if (value.checkNull().trim().isNotEmpty) {
          isUserTyping(true);
        }
      });
    }
  }

  getUnsentReplyMessage() {
    var replyMessageId = ReplyHashMap.getReplyId(profile.jid.checkNull());
    if (replyMessageId.isNotEmpty) {
      var replyChatMessage =
          chatList.firstWhere((element) => element.messageId == replyMessageId);
      handleReplyChatMessage(replyChatMessage);
    }
  }

  showAttachmentsView(BuildContext context) async {
    var busyStatus = !profile.isGroupProfile.checkNull()
        ? await FlyChat.isBusyStatusEnabled()
        : false;
    if (!busyStatus.checkNull()) {
      if (await AppUtils.isNetConnected()) {
        // focusNode.unfocus();
        showBottomSheetAttachment();
      } else {
        toToast(Constants.noInternetConnection);
      }
    } else {
      //show busy status popup
      showBusyStatusAlert(showBottomSheetAttachment);
    }
  }

  showBottomSheetAttachment() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: Get.context!,
        builder: (builder) => AttachmentsSheetView(onDocument: () {
              Get.back();
              documentPickUpload();
            }, onCamera: () {
              Get.back();
              onCameraClick();
            }, onGallery: () {
              Get.back();
              onGalleryClick();
            }, onAudio: () {
              Get.back();
              onAudioClick();
            }, onContact: () {
              Get.back();
              onContactClick();
            }, onLocation: () {
              Get.back();
              onLocationClick();
            }));
  }

  MessageObject? messageObject;

  sendMessage(Profile profile) async {
    removeUnreadSeparator();
    var busyStatus = !profile.isGroupProfile.checkNull()
        ? await FlyChat.isBusyStatusEnabled()
        : false;
    if (!busyStatus.checkNull()) {
      var replyMessageId = "";

      if (isReplying.value) {
        replyMessageId = replyChatMessage.messageId;
      }
      isReplying(false);
      if (messageController.text.trim().isNotEmpty) {
        FlyChat.sendTextMessage(
                messageController.text, profile.jid.toString(), replyMessageId)
            .then((value) {
              mirrorFlyLog("text message", value);
          messageController.text = "";
          isUserTyping(false);
          clearMessage();
          ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
          mirrorFlyLog("inserting chat message", chatMessageModel.replyParentChatMessage?.messageType ?? "value is null");
          chatList.insert(0, chatMessageModel);
          scrollToBottom();
        });
      }
    } else {
      //show busy status popup
      messageObject = MessageObject(
          toJid: profile.jid.toString(),
          replyMessageId: (isReplying.value) ? replyChatMessage.messageId : "",
          messageType: Constants.mText,
          textMessage: messageController.text);
      showBusyStatusAlert(disableBusyChatAndSend);
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

  disableBusyChatAndSend() async {
    if (messageObject != null) {
      switch (messageObject!.messageType) {
        case Constants.mText:
          sendMessage(profile);
          break;
        case Constants.mImage:
          sendImageMessage(messageObject!.file!, messageObject!.caption!,
              messageObject!.replyMessageId!);
          break;
        case Constants.mLocation:
          sendLocationMessage(
              profile, messageObject!.latitude!, messageObject!.longitude!);
          break;
        case Constants.mContact:
          sendContactMessage(
              messageObject!.contactNumbers!, messageObject!.contactName!);
          break;
        case Constants.mAudio:
          sendAudioMessage(messageObject!.file!,
              messageObject!.isAudioRecorded!, messageObject!.audioDuration!);
          break;
        case Constants.mDocument:
          sendDocumentMessage(
              messageObject!.file!, messageObject!.replyMessageId!);
          break;
      }
    }
  }

  sendLocationMessage(
      Profile profile, double latitude, double longitude) async {
    var busyStatus = !profile.isGroupProfile.checkNull()
        ? await FlyChat.isBusyStatusEnabled()
        : false;
    if (!busyStatus.checkNull()) {
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
        chatList.insert(0, chatMessageModel);
        scrollToBottom();
      });
    } else {
      //show busy status popup
      messageObject = MessageObject(
          toJid: profile.jid.toString(),
          replyMessageId: (isReplying.value) ? replyChatMessage.messageId : "",
          messageType: Constants.mLocation,
          latitude: latitude,
          longitude: longitude);
      showBusyStatusAlert(disableBusyChatAndSend);
    }
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

  RxBool chatLoading = false.obs;

  getChatHistory() {
    chatLoading(true);
    FlyChat.getMessagesOfJid(profile.jid.checkNull()).then((value) {
      debugPrint("=====chat=====");
      debugPrint("history--> $value");

      if (value == "" || value == null) {
        debugPrint("Chat List is Empty");
      } else {
        // debugPrint("parsing the value");
        try {
          // mirrorFlyLog("chat parsed history before", value);
          List<ChatMessageModel> chatMessageModel =
              chatMessageModelFromJson(value);
          //mirrorFlyLog("chat parsed history", chatMessageModelToJson(chatMessageModel));
          chatList(chatMessageModel.reversed.toList());
          Future.delayed(const Duration(milliseconds: 200), () {
            if (starredChatMessageId != null) {
              debugPrint('starredChatMessageId $starredChatMessageId');
              var chat = chatList.indexWhere(
                  (element) => element.messageId == starredChatMessageId);
              debugPrint('chat $chat');
              if (!chat.isNegative) {
                navigateToMessage(chatList[chat]);
                starredChatMessageId = null;
              }
            }
            getUnsentReplyMessage();
          });
          /*for (var index =0;index<=chatMessageModel.reversed.toList().length;index++) {
          debugPrint("isDateChanged ${isDateChanged(index,chatMessageModel.reversed.toList())}");

        }*/
        } catch (error) {
          debugPrint("chatHistory parsing error--> $error");
        }
      }
      chatLoading(false);
    }).catchError((e) {
      chatLoading(false);
    });
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
      width: width ?? MediaQuery.of(context).size.width * 0.60,
      height: height ?? MediaQuery.of(context).size.height * 0.4,
      fit: BoxFit.cover,
    );
  }

  sendImageMessage(
      String? path, String? caption, String? replyMessageID) async {
    debugPrint("Path ==> $path");
    var busyStatus = !profile.isGroupProfile.checkNull()
        ? await FlyChat.isBusyStatusEnabled()
        : false;
    if (!busyStatus.checkNull()) {
      if (isReplying.value) {
        replyMessageID = replyChatMessage.messageId;
      }
      isReplying(false);
      if (File(path!).existsSync()) {
        return FlyChat.sendImageMessage(
                profile.jid!, path, caption, replyMessageID)
            .then((value) {
          ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
          chatList.insert(0, chatMessageModel);
          scrollToBottom();
          return chatMessageModel;
        });
      } else {
        debugPrint("file not found for upload");
      }
    } else {
      //show busy status popup
      messageObject = MessageObject(
          toJid: profile.jid.toString(),
          replyMessageId: (isReplying.value) ? replyChatMessage.messageId : "",
          messageType: Constants.mImage,
          file: path,
          caption: caption);
      showBusyStatusAlert(disableBusyChatAndSend);
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
          result.files.first.extension == 'JPEG' ||
          result.files.first.extension == 'png') {
        debugPrint("Picked Image File");
        imagePath.value = (result.files.single.path!);
        Get.toNamed(Routes.imagePreview, arguments: {
          "filePath": imagePath.value,
          "userName": getName(profile),
          "profile": profile
        });
      } else if (result.files.first.extension == 'mp4' ||
          result.files.first.extension == 'MP4' ||
          result.files.first.extension == 'mov' ||
          result.files.first.extension == 'mkv') {
        debugPrint("Picked Video File");
        imagePath.value = (result.files.single.path!);
        Get.toNamed(Routes.videoPreview, arguments: {
          "filePath": imagePath.value,
          "userName": getName(profile),
          "profile": profile
        });
      }
    } else {
      // User canceled the picker
      debugPrint("======User Cancelled=====");
    }
  }

  documentPickUpload() async {
    if (await askStoragePermission()) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'ppt', 'xls', 'doc', 'docx', 'xlsx', 'txt'],
      );
      if (result != null && File(result.files.single.path!).existsSync()) {
        if (checkFileUploadSize(
            result.files.single.path!, Constants.mDocument)) {
          debugPrint(result.files.first.extension);
          filePath.value = (result.files.single.path!);
          sendDocumentMessage(filePath.value, "");
        } else {
          toToast("File Size should not exceed 20 MB");
        }
      } else {
        // User canceled the picker
      }
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
    Platform.isIOS ? Helper.showLoading(message: "Compressing Video") : null;
    return FlyChat.sendVideoMessage(
            profile.jid!, videoPath, caption, replyMessageID)
        .then((value) {
      Platform.isIOS ? Helper.hideLoading() : null;
      ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
      chatList.insert(0, chatMessageModel);
      scrollToBottom();
      return chatMessageModel;
    });
  }

  checkFile(String mediaLocalStoragePath) {
    return mediaLocalStoragePath.isNotEmpty &&
        File(mediaLocalStoragePath).existsSync();
  }

  ChatMessageModel? playingChat;

  playAudio(ChatMessageModel chatMessage) async {
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
          playingChat!.mediaChatMessage!.mediaLocalStoragePath,
          position:
              Duration(milliseconds: playingChat!.mediaChatMessage!.currentPos),
          isLocal: true);
      if (result == 1) {
        playingChat!.mediaChatMessage!.isPlaying = true;
      } else {
        mirrorFlyLog("", "Error while playing audio.");
      }
    } else if (!playingChat!.mediaChatMessage!.isPlaying) {
      int result = await player.resume();
      if (result == 1) {
        playingChat!.mediaChatMessage!.isPlaying = true;
        chatList.refresh();
      } else {
        mirrorFlyLog("", "Error on resume audio.");
      }
    } else {
      int result = await player.pause();
      if (result == 1) {
        playingChat!.mediaChatMessage!.isPlaying = false;
        chatList.refresh();
      } else {
        mirrorFlyLog("", "Error on pause audio.");
      }
    }
  }

  Future<void> playerPause() async {
    if (playingChat != null) {
      if (playingChat!.mediaChatMessage!.isPlaying) {
        int result = await player.pause();
        if (result == 1) {
          playingChat!.mediaChatMessage!.isPlaying = false;
          chatList.refresh();
        } else {
          mirrorFlyLog("", "Error on pause audio.");
        }
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

  sendContactMessage(List<String> contactList, String contactName) async {
    debugPrint("sendingName--> $contactName");
    var busyStatus = !profile.isGroupProfile.checkNull()
        ? await FlyChat.isBusyStatusEnabled()
        : false;
    debugPrint("sendContactMessage busyStatus--> $busyStatus");
    if (!busyStatus.checkNull()) {
      debugPrint("busy status not enabled");
      var replyMessageId = "";

      if (isReplying.value) {
        replyMessageId = replyChatMessage.messageId;
      }
      isReplying(false);
      return FlyChat.sendContactMessage(
              contactList, profile.jid!, contactName, replyMessageId)
          .then((value) {
        debugPrint("response--> $value");
        ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
        chatList.insert(0, chatMessageModel);
        scrollToBottom();
        return chatMessageModel;
      });
    } else {
      //show busy status popup
      messageObject = MessageObject(
          toJid: profile.jid.toString(),
          replyMessageId: (isReplying.value) ? replyChatMessage.messageId : "",
          messageType: Constants.mContact,
          contactNumbers: contactList,
          contactName: contactName);
      showBusyStatusAlert(disableBusyChatAndSend);
    }
  }

  sendDocumentMessage(String documentPath, String replyMessageId) async {
    var busyStatus = !profile.isGroupProfile.checkNull()
        ? await FlyChat.isBusyStatusEnabled()
        : false;
    if (!busyStatus.checkNull()) {
      if (isReplying.value) {
        replyMessageId = replyChatMessage.messageId;
      }
      isReplying(false);
      FlyChat.sendDocumentMessage(profile.jid!, documentPath, replyMessageId)
          .then((value) {
        ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
        chatList.insert(0, chatMessageModel);
        scrollToBottom();
        return chatMessageModel;
      });
    } else {
      //show busy status popup
      messageObject = MessageObject(
          toJid: profile.jid.toString(),
          replyMessageId: (isReplying.value) ? replyChatMessage.messageId : "",
          messageType: Constants.mText,
          file: documentPath);
      showBusyStatusAlert(disableBusyChatAndSend);
    }
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
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'wav',
        'aiff',
        'alac',
        'flac',
        'mp3',
        'aac',
        'wma',
        'ogg'
      ],
    );
    if (result != null && File(result.files.single.path!).existsSync()) {
      debugPrint(result.files.first.extension);
      if (checkFileUploadSize(result.files.single.path!, Constants.mAudio)) {
        AudioPlayer player = AudioPlayer();
        player.setUrl(result.files.single.path!);
        player.onDurationChanged.listen((Duration duration) {
          mirrorFlyLog("", 'max duration: ${duration.inMilliseconds}');
          filePath.value = (result.files.single.path!);
          sendAudioMessage(
              filePath.value, false, duration.inMilliseconds.toString());
        });
      } else {
        toToast("File Size should not exceed 20 MB");
      }
    } else {
      // User canceled the picker
    }
  }

  sendAudioMessage(String filePath, bool isRecorded, String duration) async {
    var busyStatus = !profile.isGroupProfile.checkNull()
        ? await FlyChat.isBusyStatusEnabled()
        : false;
    if (!busyStatus.checkNull()) {
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
        chatList.insert(0, chatMessageModel);
        scrollToBottom();
        return chatMessageModel;
      });
    } else {
      //show busy status popup
      messageObject = MessageObject(
          toJid: profile.jid.toString(),
          replyMessageId: (isReplying.value) ? replyChatMessage.messageId : "",
          messageType: Constants.mAudio,
          file: filePath,
          isAudioRecorded: isRecorded,
          audioDuration: duration);
      showBusyStatusAlert(disableBusyChatAndSend);
    }
  }

  void isTyping([String? typingText]) {
    messageController.text.isNotEmpty
        ? isUserTyping(true)
        : isUserTyping(false);
  }

  clearChatHistory(bool isStarredExcluded) {
    FlyChat.clearChat(profile.jid!, "chat", isStarredExcluded).then((value) {
      if (value) {
        chatList.removeWhere((p0) => p0.isMessageStarred == false);
        cancelReplyMessage();
        chatList.refresh();
      }
    });
  }

  void handleReplyChatMessage(ChatMessageModel chatListItem) {
    if (!chatListItem.isMessageRecalled && !chatListItem.isMessageDeleted) {
      debugPrint(chatListItem.messageType);
      if (isReplying.value) {
        isReplying(false);
      }
      replyChatMessage = chatListItem;
      isReplying(true);
      if (!KeyboardVisibilityController().isVisible) {
        focusNode.unfocus();
        Future.delayed(const Duration(milliseconds: 100), () {
          focusNode.requestFocus();
        });
      }
    }
  }

  cancelReplyMessage() {
    isReplying(false);
    ReplyHashMap.saveReplyId(profile.jid.checkNull(), "");
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
    for (var chatItem in chatList) {
      chatItem.isSelected = false;
    }
    selectedChatList.clear();
  }

  void addChatSelection(ChatMessageModel item) {
    if (item.messageType.toUpperCase() != Constants.mNotification) {
      selectedChatList.add(item);
      item.isSelected = true;
      chatList.refresh();
    } else {
      debugPrint("Unable to Select Notification Banner");
    }
    getMessageActions();
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
          title: "Report ${getName(profile)}?",
          message:
              "${selectedChatList.isNotEmpty ? "This message will be forwarded to admin." : "The last 5 messages from this contact will be forwarded to admin."} This Contact will not be notified.",
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
                "Are you sure you want to delete selected Message${selectedChatList.length > 1 ? "s" : ""}"),
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
                //Helper.showLoading(message: 'Deleting Message');
                FlyChat.deleteMessagesForMe(profile.jid!, chatType,
                        deleteChatListID, isMediaDelete.value)
                    .then((value) {
                  debugPrint(value.toString());
                  //Helper.hideLoading();
                  /*if (value!=null && value) {
                  removeChatList(selectedChatList);
                }
                isSelected(false);
                selectedChatList.clear();*/
                });
                removeChatList(selectedChatList);
                isSelected(false);
                selectedChatList.clear();
              },
              child: const Text("DELETE FOR ME")),
          isRecallAvailable
              ? TextButton(
                  onPressed: () {
                    Get.back();
                    //Helper.showLoading(message: 'Deleting Message for Everyone');
                    FlyChat.deleteMessagesForEveryone(profile.jid!, chatType,
                            deleteChatListID, isMediaDelete.value)
                        .then((value) {
                      debugPrint(value.toString());
                      //Helper.hideLoading();
                      if (value != null && value) {
                        // removeChatList(selectedChatList);//
                        for (var chatList in selectedChatList) {
                          chatList.isMessageRecalled = true;
                          chatList.isSelected = false;
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
        "chatMessage": selectedChatList[0],
        "isGroupProfile": profile.isGroupProfile
      });
      clearChatSelection(selectedChatList[0]);
    });
  }

  favouriteMessage() {
    /*var isMessageStarred = selectedChatList[0].isMessageStarred;
    Helper.showLoading(
        message: selectedChatList[0].isMessageStarred
            ? 'Unfavoriting Message'
            : 'Favoriting Message');

    FlyChat.updateFavouriteStatus(selectedChatList[0].messageId, profile.jid!,
        !selectedChatList[0].isMessageStarred, profile.getChatType())
        .then((value) {
      selectedChatList[0].isMessageStarred = !isMessageStarred;
      clearChatSelection(selectedChatList[0]);
      Helper.hideLoading();
    });*/
    for (var item in selectedChatList) {
      FlyChat.updateFavouriteStatus(item.messageId, item.chatUserJid,
          !item.isMessageStarred, item.messageChatType);
      var msg =
          chatList.firstWhere((element) => item.messageId == element.messageId);
      msg.isMessageStarred = !item.isMessageStarred;
      msg.isSelected = false;
    }
    isSelected(false);
    selectedChatList.clear();
    chatList.refresh();
  }

  Widget getLocationImage(
      LocationChatMessage? locationChatMessage, double width, double height) {
    return InkWell(
        onTap: () async {
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
          message: "Are you sure you want to Block ${getName(profile)}?",
          actions: [
            TextButton(
                onPressed: () {
                  Get.back();
                },
                child: const Text("CANCEL")),
            TextButton(
                onPressed: () async {
                  if (await AppUtils.isNetConnected()) {
                    Get.back();
                    Helper.showLoading(message: "Blocking User");
                    FlyChat.blockUser(profile.jid!).then((value) {
                      debugPrint(value);
                      isBlocked(true);
                      saveUnsentMessage();
                      Helper.hideLoading();
                      toToast('${getName(profile)} has been blocked');
                    }).catchError((error) {
                      Helper.hideLoading();
                      debugPrint(error);
                    });
                  } else {
                    toToast(Constants.noInternetConnection);
                  }
                },
                child: const Text("BLOCK")),
          ]);
    });
  }

  clearUserChatHistory() {
    if (chatList.isNotEmpty) {
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
    } else {
      toToast("There is no conversation.");
    }
  }

  unBlockUser() {
    Helper.showAlert(message: "Unblock ${getName(profile)}?", actions: [
      TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text("CANCEL")),
      TextButton(
          onPressed: () async {
            if (await AppUtils.isNetConnected()) {
              Get.back();
              // Helper.showLoading(message: "Unblocking User");
              FlyChat.unblockUser(profile.jid!).then((value) {
                debugPrint(value.toString());
                isBlocked(false);
                getUnsentMessageOfAJid();
                Helper.hideLoading();
                toToast('${getName(profile)} has been unblocked');
              }).catchError((error) {
                // Helper.hideLoading();
                debugPrint(error);
              });
            } else {
              toToast(Constants.noInternetConnection);
            }
          },
          child: const Text("UNBLOCK")),
    ]);
  }

  var filteredPosition = <int>[].obs;
  var searchedText = TextEditingController();
  String lastInputValue = "";

  setSearch(String text) {
    if (lastInputValue != text.trim()) {
      lastInputValue = text.trim();
      filteredPosition.clear();
      if (searchedText.text.trim().isNotEmpty) {
        for (var i = 0; i < chatList.length; i++) {
          if (chatList[i].messageType.toUpperCase() == Constants.mText &&
              chatList[i]
                  .messageTextContent
                  .startsWithTextInWords(searchedText.text.trim())) {
            filteredPosition.add(i);
          } else if (chatList[i].messageType.toUpperCase() ==
                  Constants.mImage &&
              chatList[i].mediaChatMessage!.mediaCaptionText.isNotEmpty &&
              chatList[i]
                  .mediaChatMessage!
                  .mediaCaptionText
                  .startsWithTextInWords(searchedText.text.trim())) {
            filteredPosition.add(i);
          } else if (chatList[i].messageType.toUpperCase() ==
                  Constants.mVideo &&
              chatList[i].mediaChatMessage!.mediaCaptionText.isNotEmpty &&
              chatList[i]
                  .mediaChatMessage!
                  .mediaCaptionText
                  .startsWithTextInWords(searchedText.text.trim())) {
            filteredPosition.add(i);
          } else if (chatList[i].messageType.toUpperCase() ==
                  Constants.mDocument &&
              chatList[i].mediaChatMessage!.mediaFileName.isNotEmpty &&
              chatList[i]
                  .mediaChatMessage!
                  .mediaFileName
                  .startsWithTextInWords(searchedText.text.trim())) {
            filteredPosition.add(i);
          } else if (chatList[i].messageType.toUpperCase() ==
                  Constants.mContact &&
              chatList[i].contactChatMessage!.contactName.isNotEmpty &&
              chatList[i]
                  .contactChatMessage!
                  .contactName
                  .startsWithTextInWords(searchedText.text.trim())) {
            filteredPosition.add(i);
          }
        }
      }
      chatList.refresh();
    }
  }

  var lastPosition = (-1).obs;
  var searchedPrev = "";
  var searchedNxt = "";

  searchInit() {
    lastPosition = (-1).obs;
    j = -1;
    searchedPrev = "";
    searchedNxt = "";
    filteredPosition.clear();
    searchedText.clear();
  }

  var j = -1;

  scrollUp() {
    var visiblePos = findLastVisibleItemPosition();
    mirrorFlyLog("visiblePos", visiblePos.toString());
    mirrorFlyLog("filteredPosition", filteredPosition.join(","));
    j = j + 1;
    //_scrollToPosition(getPreviousPosition(visiblePos));
    /*if (searchedPrev != (searchedText.text.toString())) {
      j = getPreviousPosition(visiblePos);
      //lastPosition.value = pre;
      searchedPrev = searchedText.text;
      searchedNxt = searchedText.text;
    } else if (filteredPosition.isNotEmpty) {
      j = max(j-1, -1);
      //lastPosition.value = max(lastPosition.value - 1, (-1));
    } else {
      j = -1;
      //lastPosition.value = -1;
    }*/
    mirrorFlyLog("scrollUp", j.toString());
    if (j > -1 && j < filteredPosition.length) {
      _scrollToPosition(j);
    } else {
      toToast("No Results Found");
    }
    /*if (lastPosition.value > -1 &&
        lastPosition.value <= filteredPosition.length) {
      var po = filteredPosition;
      _scrollToPosition(po[lastPosition.value] + 1);
    } else {
      toToast("No Results Found");
      searchedNxt = "";
    }*/
  }

  scrollDown() {
    var visiblePos = findLastVisibleItemPosition();
    mirrorFlyLog("visiblePos", visiblePos.toString());
    j = j - 1;
    /*if (searchedNxt != searchedText.text.toString()) {
      j = getNextPosition(visiblePos);
      //lastPosition.value = nex;
      searchedNxt = searchedText.text;
      searchedPrev = searchedText.text;
    } else if (filteredPosition.isNotEmpty) {
      j = min(j + 1, filteredPosition.length);
      //lastPosition.value = min(j + 1, filteredPosition.length);
    } else {
      j=-1;
      //lastPosition.value = -1;
    }*/
    mirrorFlyLog("scrollDown", j.toString());
    if (j > -1 && j < filteredPosition.length) {
      _scrollToPosition(j);
    } else {
      toToast("No Results Found");
    }
    /* if (lastPosition.value > -1 &&
        lastPosition.value <= filteredPosition.length) {
      var po = filteredPosition.reversed.toList();
      _scrollToPosition(po[lastPosition.value] + 1);
    } else {
      toToast("No Results Found");
      searchedPrev = "";
    }*/
  }

  var color = Colors.transparent.obs;

  _scrollToPosition(int position) {
    mirrorFlyLog("position", position.toString());
    if (!position.isNegative) {
      var currentPosition =
          filteredPosition[position]; //(chatList.length - (position));
      chatList[currentPosition].isSelected = true;
      searchScrollController.jumpTo(index: currentPosition);
      Future.delayed(const Duration(milliseconds: 800), () {
        currentPosition = (currentPosition);
        chatList[currentPosition].isSelected = false;
        chatList.refresh();
      });
    } else {
      toToast("No Results Found");
    }
  }

  int getPreviousPosition(int visiblePos) {
    for (var i = 0; i < filteredPosition.length; i++) {
      var po = filteredPosition.toList(); //reversed
      if (visiblePos > po.toList()[i]) {
        return filteredPosition.indexOf(po.toList()[i]);
        // break;
      }
      // return filteredPosition.indexOf(po.toList()[i]);
    }
    return -1;
  }

  int getNextPosition(int visiblePos) {
    for (var i = 0; i < filteredPosition.length; i++) {
      if (visiblePos <= filteredPosition[i]) {
        return i;
        // break;
      }
      // return i;
    }
    return -1;
  }

  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  /*int findLastVisibleItemPosition() {
    var r = itemPositionsListener.itemPositions.value
        .where((ItemPosition position) => position.itemTrailingEdge < 1)
        .reduce((ItemPosition min, ItemPosition position) =>
    position.itemTrailingEdge > min.itemTrailingEdge ? position : min)
        .index;
    return r<chatList.length ? r+1 : r;
  }*/

  int findLastVisibleItemPosition() {
    var r = itemPositionsListener.itemPositions.value
        .where((ItemPosition position) => position.itemTrailingEdge < 1)
        .reduce((ItemPosition min, ItemPosition position) =>
            position.itemTrailingEdge > min.itemTrailingEdge ? position : min)
        .index;
    return r < chatList.length ? r + 1 : r;
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

  checkBusyStatusForForward() async {
    var busyStatus = !profile.isGroupProfile.checkNull()
        ? await FlyChat.isBusyStatusEnabled()
        : false;
    if (!busyStatus.checkNull()) {
      forwardMessage();
    } else {
      showBusyStatusAlert(forwardMessage);
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
      clearAllChatSelection();
      Get.toNamed(Routes.forwardChat, arguments: {
        "forward": true,
        "group": false,
        "groupJid": "",
        "messageIds": messageIds
      })?.then((value) {
        if (value != null) {
          debugPrint(
              "result of forward ==> ${(value as Profile).toJson().toString()}");
          profile_.value = value;
          isBlocked(profile.isBlocked);
          checkAdminBlocked();
          memberOfGroup();
          FlyChat.setOnGoingChatUser(profile.jid!);
          SessionManagement.setCurrentChatJID(profile.jid.checkNull());
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
        final minDur = DateTime.now().difference(startTime!).inMinutes;
        final secDur = DateTime.now().difference(startTime!).inSeconds % 60;
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

  startRecording() async {
    if (playingChat != null) {
      playingChat!.mediaChatMessage!.isPlaying = false;
      playingChat = null;
      player.stop();
      chatList.refresh();
    }
    var busyStatus = !profile.isGroupProfile.checkNull()
        ? await FlyChat.isBusyStatusEnabled()
        : false;
    if (!busyStatus.checkNull()) {
      if (await askStoragePermission()) {
        if (await Record().hasPermission()) {
          record = Record();
          timerInit("00.00");
          isAudioRecording(Constants.audioRecording);
          startTimer();
          await record.start(
            path:
                "$audioSavePath/audio_${DateTime.now().millisecondsSinceEpoch}.m4a",
            encoder: AudioEncoder.AAC,
            bitRate: 128000,
            samplingRate: 44100,
          );
          Future.delayed(const Duration(seconds: 300), () {
            if (isAudioRecording.value == Constants.audioRecording) {
              stopRecording();
            }
          });
        }
      }
    } else {
      //show busy status popup
      showBusyStatusAlert(startRecording);
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
    if (directory != null) {
      audioSavePath = directory.path;
      debugPrint(audioSavePath);
    } else {
      debugPrint("=======Unable to set Audio Path=========");
    }
  }

  sendRecordedAudioMessage() {
    if (timerInit.value != "00.00") {
      final format = DateFormat('mm:ss');
      final dt = format.parse(timerInit.value, true);
      final recordDuration = dt.millisecondsSinceEpoch;
      sendAudioMessage(recordedAudioPath, true, recordDuration.toString());
    } else {
      toToast("Recorded Audio Time is too Short");
    }
    isUserTyping(false);
    isAudioRecording(Constants.audioRecordInitial);
    timerInit("00.00");
    record.dispose();
  }

  infoPage() {
    // FlyChat.setOnGoingChatUser("");
    // SessionManagement.setCurrentChatJID("");
    if (profile.isGroupProfile ?? false) {
      Get.toNamed(Routes.groupInfo, arguments: profile)?.then((value) {
        if (value != null) {
          profile_(value as Profile);
          isBlocked(profile.isBlocked);
          checkAdminBlocked();
          memberOfGroup();
          FlyChat.setOnGoingChatUser(profile.jid!);
          SessionManagement.setCurrentChatJID(profile.jid.checkNull());
          getChatHistory();
          sendReadReceipt();
          setChatStatus();
          debugPrint("value--> ${profile.isGroupProfile}");
        }
      });
    } else {
      Get.toNamed(Routes.chatInfo, arguments: profile)?.then((value) {
        debugPrint("chat info-->$value");
        // FlyChat.setOnGoingChatUser(profile.jid!);
        // SessionManagement.setCurrentChatJID(profile.jid.checkNull());
      });
    }
  }

  gotoSearch() {
    Future.delayed(const Duration(milliseconds: 100), () {
      Get.toNamed(Routes.chatSearch, arguments: chatList);
      /*if (searchScrollController.isAttached) {
        searchScrollController.jumpTo(index: chatList.value.length - 1);
      }*/
    });
  }

  sendUserTypingStatus() {
    FlyChat.sendTypingStatus(profile.jid.checkNull(), profile.getChatType());
  }

  sendUserTypingGoneStatus() {
    FlyChat.sendTypingGoneStatus(
        profile.jid.checkNull(), profile.getChatType());
  }

  var unreadCount = 0.obs;

  void onMessageReceived(chatMessageModel) {

    mirrorFlyLog("chatController", "onMessageReceived");

    if (chatMessageModel.chatUserJid == profile.jid) {
      removeUnreadSeparator();

      chatList.insert(0, chatMessageModel);
      unreadCount.value++;
      //scrollToBottom();
      if (isLive) {
        sendReadReceipt();
      }
    }

  }


  void onMessageStatusUpdated(ChatMessageModel chatMessageModel) {
    if (chatMessageModel.chatUserJid == profile.jid) {
      final index = chatList.indexWhere(
          (message) => message.messageId == chatMessageModel.messageId);
      debugPrint("ChatScreen Message Status Update index of search $index");
      debugPrint("messageID--> $index");
      if (!index.isNegative) {
        debugPrint("messageID--> replacing the value");
        // Helper.hideLoading();
        // chatMessageModel.isSelected=chatList[index].isSelected;
        chatList[index] = chatMessageModel;
        chatList.refresh();
      } else {
        debugPrint("messageID--> Inserting the value");
        chatList.insert(0, chatMessageModel);
        unreadCount.value++;
        // scrollToBottom();
      }

    }
    if (isSelected.value) {
      var selectedIndex = selectedChatList.indexWhere(
          (element) => chatMessageModel.messageId == element.messageId);
      if (!selectedIndex.isNegative) {
        chatMessageModel.isSelected =
            true; //selectedChatList[selectedIndex].isSelected;
        selectedChatList[selectedIndex] = chatMessageModel;
        selectedChatList.refresh();
        getMessageActions();
      }
    }
  }

  void onMediaStatusUpdated(chatMessageModel) {
    if (chatMessageModel.chatUserJid == profile.jid) {
      final index = chatList.indexWhere(
          (message) => message.messageId == chatMessageModel.messageId);
      debugPrint("Media Status Update index of search $index");
      if (index != -1) {
        // chatMessageModel.isSelected=chatList[index].isSelected;
        chatList[index] = chatMessageModel;
      }
    }
    if (isSelected.value) {
      var selectedIndex = selectedChatList.indexWhere(
          (element) => chatMessageModel.messageId == element.messageId);
      if (!selectedIndex.isNegative) {
        chatMessageModel.isSelected =
            true; //selectedChatList[selectedIndex].isSelected;
        selectedChatList[selectedIndex] = chatMessageModel;
        selectedChatList.refresh();
        getMessageActions();
      }
    }
  }

  void onGroupProfileUpdated(groupJid) {
    if (profile.jid.checkNull() == groupJid.toString()) {
      FlyChat.getProfileDetails(profile.jid.checkNull(), false).then((value) {
        if (value != null) {
          var member = Profile.fromJson(json.decode(value.toString()));
          profile_.value = member;
          profile_.refresh();
          checkAdminBlocked();
        }
      });
    }
  }


  void onLeftFromGroup({required String groupJid, required String userJid}) {
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


  void setTypingStatus(
      String singleOrgroupJid, String userId, String typingStatus) {

    if (profile.jid.checkNull() == singleOrgroupJid) {
      var jid = profile.isGroupProfile ?? false ? userId : singleOrgroupJid;
      if (!typingList.contains(jid)) {
        typingList.add(jid);
      }
      if (typingStatus.toLowerCase() == Constants.composing) {
        if (profile.isGroupProfile ?? false) {
          groupParticipantsName("");
          getProfileDetails(jid)
              .then((value) => userPresenceStatus("${value.name} typing..."));
        } else {
          //if(!profile.isGroupProfile!){//commented if due to above if condition works
          userPresenceStatus("typing...");
        }
      } else {
        if (typingList.isNotEmpty && typingList.contains(jid)) {
          typingList.remove(jid);
          userPresenceStatus("");
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

  setChatStatus() async {
    if (await AppUtils.isNetConnected()) {
      if (profile.isGroupProfile.checkNull()) {
        debugPrint("value--> show group list");
        if (typingList.isNotEmpty) {
          userPresenceStatus(
              "${Member(jid: typingList.last).getUsername()} typing...");
              //"${Member(jid: typingList.last).getUsername()} typing...");
        } else {
          getParticipantsNameAsCsv(profile.jid.checkNull());
        }
      } else {
        debugPrint("value--> show user presence");
        if(!profile.isBlockedMe.checkNull() || !profile.isAdminBlocked.checkNull()) {
          FlyChat.getUserLastSeenTime(profile.jid.toString()).then((value) {
            groupParticipantsName('');
            userPresenceStatus(value.toString());
          }).catchError((er) {
            groupParticipantsName('');
            userPresenceStatus("");
          });
        }else{
          groupParticipantsName('');
          userPresenceStatus("");
        }
      }
    } else {
      userPresenceStatus("");
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
        str.sort((a, b) {
          return a.toLowerCase().compareTo(b.toLowerCase());
        });
        groupParticipantsName(str.join(","));
      }
    });
  }

  String get subtitle => userPresenceStatus.isEmpty
      ? /*groupParticipantsName.isNotEmpty
          ? groupParticipantsName.toString()
          :*/
      Constants.emptyString
      : userPresenceStatus.toString();

  // final ImagePicker _picker = ImagePicker();

  Future<bool> askCameraPermission() async {
    final permission = await AppPermission.getCameraPermission();
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

  onCameraClick() async {
    // if (await AppPermission.askFileCameraAudioPermission()) {
    var cameraPermissionStatus = await AppPermission.checkPermission(
        Permission.camera, cameraPermission, Constants.cameraPermission);
    debugPrint("Camera Permission Status---> $cameraPermissionStatus");
    if (cameraPermissionStatus) {
      Get.toNamed(Routes.cameraPick)?.then((photo) {
        photo as XFile?;
        if (photo != null) {
          mirrorFlyLog("photo", photo.name.toString());
          if (photo.name.endsWith(".mp4")) {
            Get.toNamed(Routes.videoPreview,
                arguments: {"filePath": photo.path, "userName": profile.name!,"profile": profile});
          } else {
            Get.toNamed(Routes.imagePreview,
                arguments: {"filePath": photo.path, "userName": profile.name!,"profile": profile});
          }
        }
      });
    }
    /*final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      Get.toNamed(Routes.imagePreview,
          arguments: {"filePath": photo.path, "userName": profile.name!});
    }*/
  }

  // Future<bool> askMicrophonePermission() async {
  //   final permission = await AppPermission.getAudioPermission();
  //   switch (permission) {
  //     case PermissionStatus.granted:
  //       return true;
  //     case PermissionStatus.permanentlyDenied:
  //       return false;
  //     default:
  //       debugPrint("Contact Permission default");
  //       return false;
  //   }
  // }

  onAudioClick() async {
    // Get.back();
    // if (await askMicrophonePermission()) {
    if (await AppPermission.checkPermission(
        Permission.storage, filePermission, Constants.filePermission)) {
      pickAudio();
    }
  }

  onGalleryClick() async {
    // if (await askStoragePermission()) {
    if (await AppPermission.checkPermission(
        Permission.storage, filePermission, Constants.filePermission)) {
      try {
        // imagePicker();
        Get.toNamed(Routes.galleryPicker,
            arguments: {"userName": getName(profile),'profile':profile});
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  onContactClick() async {
    // if (await askContactsPermission()) {
    if (await AppPermission.checkPermission(
        Permission.contacts, contactPermission, Constants.contactPermission)) {
      Get.toNamed(Routes.localContact);
    } else {
      // AppPermission.permissionDeniedDialog(content: "Permission is permanently denied. Please enable Contact permission from settings");
    }
  }

  // Future<bool> askLocationPermission() async {
  //   final permission = await AppPermission.getLocationPermission();
  //   debugPrint("Permission$permission");
  //   switch (permission) {
  //     case PermissionStatus.granted:
  //       return true;
  //     case PermissionStatus.permanentlyDenied:
  //       Helper.showAlert(
  //           message:
  //               "Permission is permanently denied. Please enable location permission from settings",
  //           title: "Permission Denied",
  //           actions: [
  //             TextButton(
  //                 onPressed: () {
  //                   Get.back();
  //                 },
  //                 child: const Text("OK")),
  //           ]);
  //
  //       return false;
  //     default:
  //       debugPrint("Location Permission default");
  //       return false;
  //   }
  // }

  onLocationClick() async {
    if (await AppPermission.checkPermission(Permission.location,
        locationPinPermission, Constants.locationPermission)) {
      Get.toNamed(Routes.locationSent)?.then((value) {
        if (value != null) {
          value as LatLng;
          sendLocationMessage(profile, value.latitude, value.longitude);
        }
      });
    } else {
      // AppPermission.permissionDeniedDialog(content: "Permission is permanently denied. Please enable location permission from settings");
    }
  }

  checkAdminBlocked() {
    if (profile.isGroupProfile.checkNull()) {
      if (profile.isAdminBlocked.checkNull()) {
        toToast("This group is no longer available");
        Get.back();
      }
    } else {
      if (profile.isAdminBlocked.checkNull()) {
        toToast("This chat is no longer available");
        Get.back();
      }
    }
  }

  /*@override
  void onAdminBlockedUser(String jid, bool status) {
    super.onAdminBlockedUser(jid, status);
    mirrorFlyLog("chat onAdminBlockedUser", "$jid, $status");
    Get.find<MainController>().handleAdminBlockedUser(jid, status);
  }*/

  /*makeVoiceCall(){
    FlyChat.makeVoiceCall(profile.jid.checkNull()).then((value){
      mirrorFlyLog("makeVoiceCall", value.toString());
    });
  }*/

  Future<void> translateMessage(int index) async {
    if (SessionManagement.isGoogleTranslationEnable()) {
      var text = chatList[index].messageTextContent!;
      debugPrint("customField : ${chatList[index].messageCustomField.isEmpty}");
      if (chatList[index].messageCustomField.isNotEmpty) {
      } else {
        await translator
            .translate(
                text: text, to: SessionManagement.getTranslationLanguageCode())
            .then((translation) {
          var map = <String, dynamic>{};
          map["is_message_translated"] = true;
          map["translated_language"] =
              SessionManagement.getTranslationLanguage();
          map["translated_message_content"] = translation.translatedText;
          debugPrint(
              "translation source : ${translation.detectedSourceLanguage}");
          debugPrint("translation text : ${translation.translatedText}");
        }).catchError((onError) {
          debugPrint("exception : $onError");
        });
      }
    }
  }

  bool forwardMessageVisibility(ChatMessageModel chat) {
    if (!chat.isMessageRecalled && !chat.isMessageDeleted) {
      if (chat.isMediaMessage()) {
        if (chat.mediaChatMessage!.mediaDownloadStatus ==
                Constants.mediaDownloaded ||
            chat.mediaChatMessage!.mediaUploadStatus ==
                Constants.mediaUploaded) {
          return true;
        }
      } else {
        if (chat.messageType == Constants.mLocation) {
          return true;
        }
      }
    }
    return false;
  }

  forwardSingleMessage(String messageId) {
    var messageIds = <String>[];
    messageIds.add(messageId);
    Get.toNamed(Routes.forwardChat, arguments: {
      "forward": true,
      "group": false,
      "groupJid": "",
      "messageIds": messageIds
    })?.then((value) {
      if (value != null) {
        debugPrint(
            "result of forward ==> ${(value as Profile).toJson().toString()}");
        profile_.value = value;
        isBlocked(profile.isBlocked);
        checkAdminBlocked();
        memberOfGroup();
        FlyChat.setOnGoingChatUser(profile.jid!);
        SessionManagement.setCurrentChatJID(profile.jid.checkNull());
        getChatHistory();
        sendReadReceipt();
      }
    });
  }

  var containsRecalled = false.obs;
  var canBeStarred = false.obs;
  var canBeStarredSet = false;
  var canBeUnStarred = false.obs;
  var canBeUnStarredSet = false;
  var canBeShared = false.obs;
  var canBeSharedSet = false;
  var canBeForwarded = false.obs;
  var canBeForwardedSet = false;
  var canBeCopied = false.obs;
  var canBeCopiedSet = false;
  var canBeReplied = false.obs;
  var canShowInfo = false.obs;
  var canShowReport = false.obs;

  getMessageActions() {
    if (selectedChatList.isEmpty) {
      return;
    }

    containsRecalled(false);
    canBeStarred(true);
    canBeStarredSet = false;
    canBeUnStarred(true);
    canBeUnStarredSet = false;
    canBeShared(true);
    canBeSharedSet = false;
    canBeForwarded(true);
    canBeForwardedSet = false;
    canBeCopied(true);
    canBeCopiedSet = false;
    canBeReplied(true);
    canShowInfo(true);
    canShowReport(true);

    for (var message in selectedChatList) {
      //Recalled Validation
      if (message.isMessageRecalled) {
        containsRecalled(true);
        break;
      }
      //Copy Validation
      if (!canBeCopiedSet && (!message.isTextMessage())) {
        canBeCopied(false);
        canBeCopiedSet = true;
      }
      setMessageActionValidations(message);
    }
    getMessagesActionDetails();
  }

  setMessageActionValidations(ChatMessageModel message) {
    //Forward Validation - can be added for forwarding more than one messages
    if (!canBeForwardedSet &&
        ((message.isMessageSentByMe && message.messageStatus == "N") ||
            (message.isMediaMessage() &&
                !checkFile(message.mediaChatMessage!.mediaLocalStoragePath)))) {
      canBeForwarded(false);
      canBeForwardedSet = true;
    }
    //Share Validation
    if (!canBeSharedSet &&
        (!message.isMediaMessage() ||
            (message.isMediaMessage() &&
                !checkFile(message.mediaChatMessage!.mediaLocalStoragePath)))) {
      canBeShared(false);
      canBeSharedSet = true;
    }
    //Starred Validation
    if (!canBeStarredSet && message.isMessageStarred ||
        (message.isMediaMessage() &&
            !checkFile(message.mediaChatMessage!.mediaLocalStoragePath))) {
      canBeStarred(false);
      canBeStarredSet = true;
    }
    //UnStarred Validation
    if (!canBeUnStarredSet && !message.isMessageStarred) {
      canBeUnStarred(false);
      canBeUnStarredSet = true;
    }
  }

  getMessagesActionDetails() {
    switch (selectedChatList.length) {
      case 1:
        var message = selectedChatList.first;
        setMenuItemsValidations(message);
        break;
      default:
        canBeReplied(false);
        canShowInfo(false);
        canBeCopied(false);
        canShowReport(false);
    }

    canBeStarred(!canBeStarred.value && !canBeUnStarred.value ||
        canBeStarred.value && !canBeUnStarred.value);

    if (containsRecalled.value) {
      canBeCopied(false);
      canBeForwarded(false);
      canBeShared(false);
      canBeStarred(false);
      canBeUnStarred(false);
      canBeReplied(false);
      canShowInfo(false);
      canShowReport(false);
    }
    // return messageActions;
    mirrorFlyLog("action_menu canBeCopied", canBeCopied.toString());
    mirrorFlyLog("action_menu canBeForwarded", canBeForwarded.toString());
    mirrorFlyLog("action_menu canBeShared", canBeShared.toString());
    mirrorFlyLog("action_menu canBeStarred", canBeStarred.toString());
    mirrorFlyLog("action_menu canBeUnStarred", canBeUnStarred.toString());
    mirrorFlyLog("action_menu canBeReplied", canBeReplied.toString());
    mirrorFlyLog("action_menu canShowInfo", canShowInfo.toString());
    mirrorFlyLog("action_menu canShowReport", canShowReport.toString());
  }

  setMenuItemsValidations(ChatMessageModel message) {
    if (!containsRecalled.value) {
      //Reply Validation
      if (message.isMessageSentByMe && message.messageStatus == "N") {
        canBeReplied(false);
      }
      //Info Validation
      if (!message.isMessageSentByMe ||
          message.messageStatus == "N" ||
          message.isMessageRecalled ||
          (message.isMediaMessage() &&
              !checkFile(message.mediaChatMessage!.mediaLocalStoragePath))) {
        canShowInfo(false);
      }
      //Report validation
      if (message.isMessageSentByMe) {
        canShowReport(false);
      }
    }
  }

  void navigateToMessage(ChatMessageModel chatMessage, {int? index}) {
    var messageID = chatMessage.messageId;
    var chatIndex = index ??
        chatList.indexWhere((element) => element.messageId == messageID);
    if (!chatIndex.isNegative) {
      newScrollController.scrollTo(index: chatIndex, duration: const Duration(milliseconds: 10));
      Future.delayed(const Duration(milliseconds: 15), () {
        chatList[chatIndex].isSelected = true;
        chatList.refresh();
      });

      Future.delayed(const Duration(milliseconds: 800), () {
        chatList[chatIndex].isSelected = false;
        chatList.refresh();
      });
    }
  }

  int findLastVisibleItemPositionForChat() {
    /*var r = newitemPositionsListener.itemPositions.value
        .where((ItemPosition position) => position.itemTrailingEdge < 1)
        .reduce((ItemPosition min, ItemPosition position) =>
            position.itemTrailingEdge < min.itemTrailingEdge ? position : min)
        .index;
    return r < chatList.length ? r + 1 : r;*/
    return newitemPositionsListener.itemPositions.value.first.index;
  }

  void share() {
    var mediaPaths = <XFile>[];
    for (var item in selectedChatList) {
      if (item.isMediaMessage()) {
        if ((item.isMediaDownloaded() || item.isMediaUploaded()) &&
            item.mediaChatMessage!.mediaLocalStoragePath
                .checkNull()
                .isNotEmpty) {
          mediaPaths.add(
              XFile(item.mediaChatMessage!.mediaLocalStoragePath.checkNull()));
        }
      }
    }
    clearAllChatSelection();
    Share.shareXFiles(mediaPaths);
  }

  @override
  void onPaused() {
    mirrorFlyLog("LifeCycle", "onPaused");
    FlyChat.setOnGoingChatUser("");
    SessionManagement.setCurrentChatJID("");
    playerPause();
    saveUnsentMessage();
    sendUserTypingGoneStatus();
  }

  @override
  void onResumed() {
    mirrorFlyLog("LifeCycle", "onResumed");
    setChatStatus();
    if (!KeyboardVisibilityController().isVisible) {
      if (focusNode.hasFocus) {
        focusNode.unfocus();
        Future.delayed(const Duration(milliseconds: 100), () {
          focusNode.requestFocus();
        });
      }
    }
    FlyChat.setOnGoingChatUser(profile.jid.checkNull());
    SessionManagement.setCurrentChatJID(profile.jid.checkNull());
  }

  @override
  void onDetached() {
    mirrorFlyLog("LifeCycle", "onDetached");
  }

  @override
  void onInactive() {
    mirrorFlyLog("LifeCycle", "onInactive");
  }


  void userUpdatedHisProfile(String jid) {
    updateProfile(jid);
  }

  void unblockedThisUser(String jid) {
    updateProfile(jid);
  }

  Future<void> updateProfile(String jid) async {
    if (jid.isNotEmpty && jid == profile.jid) {
      if(!profile.isGroupProfile.checkNull()) {
        getProfileDetails(jid).then((value) {
          SessionManagement.setChatJid("");
          profile_(value);
          checkAdminBlocked();
          isBlocked(profile.isBlocked);
          setChatStatus();
        });
      }else{
        debugPrint("unable to update profile due to group chat");
      }
    }
  }


  void userCameOnline(jid) {

    if(jid.isNotEmpty && profile.jid == jid && !profile.isGroupProfile.checkNull()) {
      debugPrint("userCameOnline : $jid");
      Future.delayed(const Duration(milliseconds: 3000),(){
        setChatStatus();
      });
    }
  }

  void userWentOffline(jid) {
    if(jid.isNotEmpty && profile.jid==jid && !profile.isGroupProfile.checkNull()) {
      debugPrint("userWentOffline : $jid");
      Future.delayed(const Duration(milliseconds: 3000),(){
        setChatStatus();
      });
    }
  }

  void networkConnected() {
    mirrorFlyLog("networkConnected", 'true');
    Future.delayed(const Duration(milliseconds: 2000), () {
      setChatStatus();
    });
  }

  void networkDisconnected() {
    mirrorFlyLog('networkDisconnected', 'false');
    setChatStatus();
  }

  void removeUnreadSeparator() async{

    chatList.removeWhere((chatItem) => chatItem.messageType == Constants.mNotification);

  }

  void onContactSyncComplete(bool result) {
    userUpdatedHisProfile(profile.jid.checkNull());
  }

}
