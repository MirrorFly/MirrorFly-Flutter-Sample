import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart'
    as lib_phone_number;
import 'package:get/get.dart';

// import 'package:google_cloud_translation/google_cloud_translation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mirror_fly_demo/app/common/de_bouncer.dart';
import 'package:mirror_fly_demo/app/common/main_controller.dart';
import 'package:mirror_fly_demo/app/data/session_management.dart';
import 'package:mirror_fly_demo/app/data/permissions.dart';
import 'package:mirror_fly_demo/app/modules/notification/notification_builder.dart';
import 'package:mirrorfly_plugin/internal_models/callback.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:record/record.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/constants.dart';
import '../../../data/apputils.dart';
import '../../../data/helper.dart';
import '../../../model/chat_message_model.dart';
import '../../../model/reply_hash_map.dart';
import '../../../routes/app_pages.dart';

import 'package:mirrorfly_plugin/mirrorflychat.dart';

import '../../gallery_picker/src/data/models/picked_asset_model.dart';
import '../chat_widgets.dart';

class ChatController extends FullLifeCycleController
    with FullLifeCycleMixin, GetTickerProviderStateMixin {
  // final translator = Translation(apiKey: Constants.googleTranslateKey);

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
  var timerInit = "00:00".obs;
  DateTime? startTime;

  double screenHeight = 0.0;
  double screenWidth = 0.0;

  // AudioPlayer player = AudioPlayer();

  late String audioSavePath;
  late String recordedAudioPath;
  late Record record;

  TextEditingController messageController = TextEditingController();

  FocusNode focusNode = FocusNode();
  FocusNode searchfocusNode = FocusNode();

  var calendar = DateTime.now();
  var profile_ = ProfileDetails().obs;

  ProfileDetails get profile => profile_.value;
  var base64img = ''.obs;
  var imagePath = ''.obs;
  var filePath = ''.obs;

  var showEmoji = false.obs;

  ///Commenting this and handled this using SessionManagement.getCurrentChatJID() != ""
  ///in iOS onClose function is not called when we navigate to Info Screen
  // var isLive = false;

  var isSelected = false.obs;

  var isBlocked = false.obs;

  var selectedChatList = List<ChatMessageModel>.empty(growable: true).obs;

  // var keyboardVisibilityController = KeyboardVisibilityController();

  // late StreamSubscription<bool> keyboardSubscription;

  final _isMemberOfGroup = false.obs;

  set isMemberOfGroup(value) => _isMemberOfGroup.value = value;

  bool get isMemberOfGroup =>
      profile.isGroupProfile ?? false ? availableFeatures.value.isGroupChatAvailable.checkNull() && _isMemberOfGroup.value : true;

  // var profileDetail = Profile();

  String? nJid;
  String? starredChatMessageId;
  String unreadMessageTypeMessageId = "";

  bool get isTrail => !Constants.enableContactSync;

  var showLoadingNext = false.obs;
  var showLoadingPrevious = false.obs;
  

  final deBouncer = DeBouncer(milliseconds: 1000);

  var topicId = Constants.topicId;
  var availableFeatures = AvailableFeatures().obs;
  RxList<AttachmentIcon> availableAttachments = <AttachmentIcon>[].obs;

  bool get isAudioCallAvailable => profile.isGroupProfile.checkNull() ? availableFeatures.value.isGroupCallAvailable.checkNull() : availableFeatures.value.isOneToOneCallAvailable.checkNull();
  bool get isVideoCallAvailable => profile.isGroupProfile.checkNull() ? availableFeatures.value.isGroupCallAvailable.checkNull() : availableFeatures.value.isOneToOneCallAvailable.checkNull();
  @override
  void onInit() async {
    super.onInit();
    getAvailableFeatures();
    //await Mirrorfly.enableDisableBusyStatus(true);
    // var profileDetail = Get.arguments as Profile;
    // profile_.value = profileDetail;
    // if(profile_.value.jid == null){
    if(Get.parameters['topicId']!=null){
      topicId = Get.parameters['topicId'].toString();
      getTopicDetail();
    }
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
    if (Get.parameters['chatJid'] != null) {
      userJid = Get.parameters['chatJid'] as String;
      LogMessage.d("chatJid", userJid);
    }
    if (userJid.isEmpty) {
      var profileDetail = Get.arguments as ProfileDetails;
      profile_(profileDetail);
      //make unreadMessageTypeMessageId
      unreadMessageTypeMessageId = "M${profileDetail.jid}";
      checkAdminBlocked();
      ready();
      // initListeners();
    } else {
      getProfileDetails(userJid).then((value) {
        SessionManagement.setChatJid("");
        profile_(value);
        //make unreadMessageTypeMessageId
        unreadMessageTypeMessageId = "M${value.jid}";
        checkAdminBlocked();
        ready();
        // initListeners();
      });
    }
    // mirrorFlyLog('savedContact', profile.isItSavedContact.toString());

    /*player.onPlayerCompletion.listen((event) {
      playingChat!.mediaChatMessage!.isPlaying = false;
      playingChat!.mediaChatMessage!.currentPos = 0;
      player.stop();
      chatList.refresh();
      playingChat = null;
    });

    player.onAudioPositionChanged.listen((Duration p) {
      mirrorFlyLog('p.inMilliseconds', p.inMilliseconds.toString());
      playingChat?.mediaChatMessage!.currentPos = (p.inMilliseconds);
      chatList.refresh();
    });*/

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

      ///Commenting this, bcz this executed only when value is changed to true or false. if started typing value changed to true.
      ///Then after some interval, if we type again the value remains true so this is not calling
      ///Changing to below messageController.addListener()
      /*if (callback) {
        mirrorFlyLog("inside callback ", callback.toString());
        sendUserTypingStatus();
        DeBouncer(milliseconds: 2100).run(() {
          sendUserTypingGoneStatus();
        });
      } else {
        mirrorFlyLog("inside else callback ", callback.toString());
        sendUserTypingGoneStatus();
      }*/
    });

    messageController.addListener(() {
      // mirrorFlyLog("typing", "typing..");

      /*sendUserTypingStatus();
      debugPrint('User is typing');
      deBouncer.cancel();
      deBouncer.run(() {
        debugPrint("DeBouncer");
        sendUserTypingGoneStatus();
      });*/
    });

    // if (Get.isRegistered<MainController>()) {
      /*availableFeatures(Get
          .find<MainController>()
          .availableFeature
          .value);*/
    // }
  }
  void getAvailableFeatures(){
    Mirrorfly.getAvailableFeatures().then((features) {
      debugPrint("getAvailableFeatures $features");
      var featureAvailable = availableFeaturesFromJson(features);
      updateAvailableFeature(featureAvailable);
    });
  }

  var showHideRedirectToLatest = false.obs;

  void ready() {
    debugPrint("Chat controller ready");
    _loadMessages();
    cancelNotification();
    // debugPrint("isBlocked===> ${profile.isBlocked}");
    // debugPrint("profile detail===> ${profile.toJson().toString()}");
    getUnsentMessageOfAJid();
    isBlocked(profile.isBlocked);
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    /*Member(jid: profile.jid.checkNull())
        .getProfileDetails()
        .then((value) => profileDetail = value);*/
    memberOfGroup();
    setChatStatus();
    // isLive = true;
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        showEmoji(false);
      }
    });
    itemPositionsListener.itemPositions.addListener(() {
      debugPrint('scrolled : ${findTopFirstVisibleItemPosition()}');
      // j=findLastVisibleItemPosition();
    });
    newitemPositionsListener.itemPositions.addListener(() {
      var pos = lastVisiblePosition();
      if (pos >= 1) {
        showHideRedirectToLatest(true);
      } else {
        showHideRedirectToLatest(false);
        unreadCount(0);
      }
    });

    setOnGoingUserAvail();
    debugPrint("==================");
    debugPrint(profile.image);
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
    setOnGoingUserGone();
    // isLive = false;
    // player.stop();
    // player.dispose();
    super.onClose();
  }

  @override
  void dispose() {
    super.dispose();
    debugPrint("dispose");
  }

  clearMessage() {
    if (profile.jid.checkNull().isNotEmpty) {
      messageController.text = "";
      Mirrorfly.saveUnsentMessage(profile.jid.checkNull(), '');
      ReplyHashMap.saveReplyId(profile.jid.checkNull(), '');
    }
  }

  saveUnsentMessage() {
    if (profile.jid.checkNull().isNotEmpty) {
      Mirrorfly.saveUnsentMessage(
          profile.jid.checkNull(), messageController.text.trim().toString());
    }
    if (isReplying.value) {
      ReplyHashMap.saveReplyId(
          profile.jid.checkNull(), replyChatMessage.messageId);
    }
  }

  getUnsentMessageOfAJid() async {
    if (profile.jid.checkNull().isNotEmpty) {
      Mirrorfly.getUnsentMessageOfAJid(profile.jid.checkNull()).then((value) {
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
        ? await Mirrorfly.isBusyStatusEnabled()
        : false;
    if (!busyStatus.checkNull()) {
      //if (await AppUtils.isNetConnected()) {
      focusNode.unfocus();
      showBottomSheetAttachment();
      /*} else {
        toToast(Constants.noInternetConnection);
      }*/
    } else {
      //show busy status popup
      showBusyStatusAlert(showBottomSheetAttachment);
    }
  }

  showBottomSheetAttachment() {
    Get.bottomSheet(
      Container(
        margin: const EdgeInsets.only(right: 18.0, left: 18.0, bottom: 50),
        child: BottomSheet(
            onClosing: () {},
            backgroundColor: Colors.transparent,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            builder: (builder) => AttachmentsSheetView(
                      attachments: availableAttachments,
                      availableFeatures: availableFeatures,
                      onDocument: () {
                        Get.back();
                        documentPickUpload();
                      },
                      onCamera: () {
                        Get.back();
                        onCameraClick();
                      },
                      onGallery: () {
                        Get.back();
                        onGalleryClick();
                      },
                      onAudio: () {
                        Get.back();
                        onAudioClick();
                      },
                      onContact: () {
                        Get.back();
                        onContactClick();
                      },
                      onLocation: () {
                        Get.back();
                        onLocationClick();
                      }))
      ),
      ignoreSafeArea: true,
    );
  }

  MessageObject? messageObject;

  sendMessage(ProfileDetails profile) async {
    removeUnreadSeparator();
    var busyStatus = !profile.isGroupProfile.checkNull()
        ? await Mirrorfly.isBusyStatusEnabled()
        : false;
    if (!busyStatus.checkNull()) {
      var replyMessageId = "";

      if (isReplying.value) {
        replyMessageId = replyChatMessage.messageId;
      }
      isReplying(false);
      if (messageController.text.trim().isNotEmpty) {
        Mirrorfly.sendTextMessage(messageController.text.trim(),
            profile.jid.toString(),replyMessageId,topicId: topicId)
            .then((value) {
          mirrorFlyLog("text message", value);
          messageController.text = "";
          isUserTyping(false);
          clearMessage();
          ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
          mirrorFlyLog(
              "inserting chat message",
              chatMessageModel.replyParentChatMessage?.messageType ??
                  "value is null");
          // chatList.insert(0, chatMessageModel);
          scrollToBottom();
          updateLastMessage(value);
        });
      }
    } else {
      //show busy status popup
      messageObject = MessageObject(
          toJid: profile.jid.toString(),
          replyMessageId: (isReplying.value) ? replyChatMessage.messageId : "",
          messageType: Constants.mText,
          textMessage: messageController.text.trim());
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
                await Mirrorfly.enableDisableBusyStatus(false);
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
        case Constants.mVideo:
          sendVideoMessage(messageObject!.file!, messageObject!.caption!,
              messageObject!.replyMessageId!);
          break;
      }
    }
  }

  sendLocationMessage(
      ProfileDetails profile, double latitude, double longitude) async {
    if(!availableFeatures.value.isLocationAttachmentAvailable.checkNull()){
      Helper.showFeatureUnavailable();
      return;
    }
    var busyStatus = !profile.isGroupProfile.checkNull()
        ? await Mirrorfly.isBusyStatusEnabled()
        : false;
    if (!busyStatus.checkNull()) {
      var replyMessageId = "";
      if (isReplying.value) {
        replyMessageId = replyChatMessage.messageId;
      }
      isReplying(false);

      Mirrorfly.sendLocationMessage(
          profile.jid.toString(), latitude, longitude, replyMessageId,topicId: topicId)
          .then((value) {
        mirrorFlyLog("Location_msg", value.toString());
        // ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
        // chatList.insert(0, chatMessageModel);
        scrollToBottom();
        updateLastMessage(value);
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

  void _loadMessages() {
    // getChatHistory();
    chatLoading(true);
    Mirrorfly.initializeMessageList(userJid: profile.jid.checkNull(), limit: 25,topicId: topicId)//message
        .then((value) {
      if(value) {
        Mirrorfly.loadMessages(FlyCallback()..onResponse = (FlyResponse response){
          showLoadingNext(false);
          showLoadingPrevious(false);
          if(response.isSuccess && response.data.isNotEmpty){
            List<ChatMessageModel> chatMessageModel = chatMessageModelFromJson(response.data);
            chatList(chatMessageModel.reversed.toList());
            showStarredMessage();
            sendReadReceipt(removeUnreadFromList: false);
            // loadPrevORNextMessagesLoad();
          }
          chatLoading(false);
        });
      }else{
        chatLoading(false);
        toToast("Chat History Not Initialized");
      }
    });
  }

  Future<void> _loadPreviousMessages() async {
    showLoadingPrevious(await Mirrorfly.hasPreviousMessages());
    Mirrorfly.loadPreviousMessages(FlyCallback()..onResponse = (FlyResponse response){
      if(response.isSuccess && response.data.isNotEmpty){
        var chatMessageModel =
            List<ChatMessageModel>.empty(growable: true).obs;
        chatMessageModel.addAll(chatMessageModelFromJson(response.data));
        if (chatMessageModel
            .toList()
            .isNotEmpty) {
          chatList.insertAll(
              chatList.length, chatMessageModel.reversed.toList());
        } else {
          debugPrint("chat list is empty");
        }
        showStarredMessage();
      }
      showLoadingPrevious(false);
    });
  }

  Future<void> _loadNextMessages({bool showLoading = true,bool removeUnreadFromList = true}) async {
    if(showLoading) {
      showLoadingNext(await Mirrorfly.hasNextMessages());
    }else{
      showLoadingNext(showLoading);
    }
    Mirrorfly.loadNextMessages(FlyCallback()..onResponse = (FlyResponse response){
      if(response.isSuccess && response.data.isNotEmpty){
        List<ChatMessageModel> chatMessageModel =
        chatMessageModelFromJson(response.data);
        if (chatMessageModel.isNotEmpty) {
          chatList.insertAll(0, chatMessageModel.reversed.toList());
          sendReadReceipt(removeUnreadFromList: removeUnreadFromList);
        }
        showStarredMessage();
      }
      showLoadingNext(false);
    });
  }

  showStarredMessage() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (starredChatMessageId != null) {
        debugPrint('starredChatMessageId $starredChatMessageId');
        var chat = chatList
            .indexWhere((element) => element.messageId == starredChatMessageId);
        debugPrint('chat $chat');
        if (!chat.isNegative) {
          navigateToMessage(chatList[chat]);
          starredChatMessageId = null;
        } else {
          toToast('Message not found');
        }
      }
      getUnsentReplyMessage();
    });
  }

  getChatHistory() {
    chatLoading(true);
    Mirrorfly.getMessagesOfJid(profile.jid.checkNull()).then((value) {
      // debugPrint("=====chat=====");
      // debugPrint("history--> $value");

      if (value == "" || value == null) {
        debugPrint("Chat List is Empty");
      } else {
        // debugPrint("parsing the value");
        try {
          // mirrorFlyLog("chat parsed history before", value);
          List<ChatMessageModel> chatMessageModel =
          chatMessageModelFromJson(value);
          // mirrorFlyLog("chat parsed history", chatMessageModelToJson(chatMessageModel));
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
              } else {
                toToast('Message not found');
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

  /*getMedia(String mid) {
    return Mirrorfly.getMessageOfId(mid).then((value) {
      CheckModel chatMessageModel = checkModelFromJson(value);
      String thumbImage = chatMessageModel.mediaChatMessage.mediaThumbImage;
      thumbImage = thumbImage.replaceAll("\n", "");
      return thumbImage;
    });

    // return imageFromBase64String(chatMessageModel.mediaChatMessage!.mediaThumbImage!);
    // // return media;
    // return base64Decode(chatMessageModel.mediaChatMessage.mediaThumbImage);
  }*/

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

  sendImageMessage(String? path, String? caption, String? replyMessageID) async {
    if(!availableFeatures.value.isImageAttachmentAvailable.checkNull()){
      Helper.showFeatureUnavailable();
      return;
    }
    debugPrint("Path ==> $path");
    var busyStatus = !profile.isGroupProfile.checkNull()
        ? await Mirrorfly.isBusyStatusEnabled()
        : false;
    if (!busyStatus.checkNull()) {
      if (isReplying.value) {
        replyMessageID = replyChatMessage.messageId;
      }
      isReplying(false);
      if (File(path!).existsSync()) {
        return Mirrorfly.sendImageMessage(
            profile.jid!, path, caption, replyMessageID,topicId: topicId)
            .then((value) {
          clearMessage();
          ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
          // chatList.insert(0, chatMessageModel);
          scrollToBottom();
          updateLastMessage(value);
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

  documentPickUpload() async {
    if(!availableFeatures.value.isDocumentAttachmentAvailable.checkNull()){
      Helper.showFeatureUnavailable();
      return;
    }
    var permission = await AppPermission.getStoragePermission();
    if (permission) {
      setOnGoingUserGone();
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'ppt', 'xls', 'doc', 'docx', 'xlsx', 'txt'],
      );
      if (result != null && File(result.files.single.path!).existsSync()) {
        if (checkFileUploadSize(
            result.files.single.path!, Constants.mDocument)) {
          debugPrint("sendDoc ${result.files.first.extension}");
          Future.delayed(const Duration(seconds: 1), () {
            filePath.value = (result.files.single.path!);
            sendDocumentMessage(filePath.value, "");
          });
        } else {
          toToast("File Size should not exceed ${Constants.maxDocFileSize} MB");
        }
        setOnGoingUserAvail();
      } else {
        // User canceled the picker
        setOnGoingUserAvail();
      }
    }
  }

  sendReadReceipt({bool removeUnreadFromList = true}) {
    LogMessage.d("ChatController", "sendReadReceipt");
    markConversationReadNotifyUI();
    handleUnreadMessageSeparator(remove: true,removeFromList: removeUnreadFromList);//lastVisiblePosition()==0
  }

  sendVideoMessage(String videoPath, String caption, String replyMessageID) async {
    if(!availableFeatures.value.isVideoAttachmentAvailable.checkNull()){
      Helper.showFeatureUnavailable();
      return;
    }
    var busyStatus = !profile.isGroupProfile.checkNull()
        ? await Mirrorfly.isBusyStatusEnabled()
        : false;
    if (!busyStatus.checkNull()) {
      if (isReplying.value) {
        replyMessageID = replyChatMessage.messageId;
      }
      isReplying(false);
      Platform.isIOS ? Helper.showLoading(message: "Compressing Video") : null;
      return Mirrorfly.sendVideoMessage(
          profile.jid!, videoPath, caption, replyMessageID,topicId: topicId)
          .then((value) {
        clearMessage();
        Platform.isIOS ? Helper.hideLoading() : null;
        ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
        // chatList.insert(0, chatMessageModel);
        scrollToBottom();
        updateLastMessage(value);
        return chatMessageModel;
      });
    } else {
      //show busy status popup
      messageObject = MessageObject(
          toJid: profile.jid.toString(),
          replyMessageId: (isReplying.value) ? replyChatMessage.messageId : "",
          messageType: Constants.mVideo,
          file: videoPath,
          caption: caption);
      showBusyStatusAlert(disableBusyChatAndSend);
    }
  }

  checkFile(String mediaLocalStoragePath) {
    return mediaLocalStoragePath.isNotEmpty &&
        File(mediaLocalStoragePath).existsSync();
  }

  ChatMessageModel? playingChat;

  playAudio(ChatMessageModel chatMessage) async {
    /*setPlayingChat(chatMessage);
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
    }*/
  }

  void setPlayingChat(ChatMessageModel chatMessage) {
    /*if (playingChat != null) {
      if (playingChat?.mediaChatMessage!.messageId != chatMessage.messageId) {
        player.stop();
        playingChat?.mediaChatMessage!.isPlaying = false;
        playingChat = chatMessage;
      }
    } else {
      playingChat = chatMessage;
    }
    if (isAudioRecording.value == Constants.audioRecording) {
      stopRecording();
    }*/
  }

  void onSeekbarChange(double value, ChatMessageModel chatMessage) {
    /*debugPrint('onSeekbarChange $value');
    if (playingChat != null) {
      player.seek(Duration(milliseconds: value.toInt()));
    }else{
      chatMessage.mediaChatMessage?.currentPos=value.toInt();
      //chatList.refresh();
    }*/
  }

  Future<void> playerPause() async {
    /* if (playingChat != null) {
      if (playingChat!.mediaChatMessage!.isPlaying) {
        int result = await player.pause();
        if (result == 1) {
          playingChat!.mediaChatMessage!.isPlaying = false;
          chatList.refresh();
        } else {
          mirrorFlyLog("", "Error on pause audio.");
        }
      }
    }*/
  }

  sendContactMessage(List<String> contactList, String contactName) async {
    if(!availableFeatures.value.isContactAttachmentAvailable.checkNull()){
      Helper.showFeatureUnavailable();
      return;
    }
    debugPrint("sendingName--> $contactName");
    var busyStatus = !profile.isGroupProfile.checkNull()
        ? await Mirrorfly.isBusyStatusEnabled()
        : false;
    debugPrint("sendContactMessage busyStatus--> $busyStatus");
    if (!busyStatus.checkNull()) {
      debugPrint("busy status not enabled");
      var replyMessageId = "";

      if (isReplying.value) {
        replyMessageId = replyChatMessage.messageId;
      }
      isReplying(false);
      return Mirrorfly.sendContactMessage(
          contactList, profile.jid!, contactName, replyMessageId,topicId: topicId)
          .then((value) {
        debugPrint("response--> $value");
        ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
        // chatList.insert(0, chatMessageModel);
        scrollToBottom();
        updateLastMessage(value);
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
    if(!availableFeatures.value.isDocumentAttachmentAvailable.checkNull()){
      Helper.showFeatureUnavailable();
      return;
    }
    var busyStatus = !profile.isGroupProfile.checkNull()
        ? await Mirrorfly.isBusyStatusEnabled()
        : false;
    if (!busyStatus.checkNull()) {
      if (isReplying.value) {
        replyMessageId = replyChatMessage.messageId;
      }
      isReplying(false);
      Mirrorfly.sendDocumentMessage(profile.jid!, documentPath, replyMessageId,topicId: topicId)
          .then((value) {
        ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
        // chatList.insert(0, chatMessageModel);
        scrollToBottom();
        updateLastMessage(value);
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

  pickAudio() async {
    setOnGoingUserGone();
    if (Platform.isIOS) {
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
            Future.delayed(const Duration(seconds: 1), () {
              filePath.value = (result.files.single.path!);
              sendAudioMessage(
                  filePath.value, false, duration.inMilliseconds.toString());
            });
          });
        } else {
          toToast("File Size should not exceed ${Constants.maxAudioFileSize} MB");
        }
        setOnGoingUserAvail();
      } else {
        // User canceled the picker
        setOnGoingUserAvail();
      }
    } else {
      await Mirrorfly.openAudioFilePicker().then((value) {
        if (value != null) {
          if (checkFileUploadSize(value, Constants.mAudio)) {
            AudioPlayer player = AudioPlayer();
            player.setUrl(value);
            player.onDurationChanged.listen((Duration duration) {
              mirrorFlyLog("", 'max duration: ${duration.inMilliseconds}');
              Future.delayed(const Duration(seconds: 1), () {
                filePath.value = (value);
                sendAudioMessage(
                    filePath.value, false, duration.inMilliseconds.toString());
              });
            });
          } else {
            toToast("File Size should not exceed ${Constants.maxAudioFileSize} MB");
          }
        } else {
          setOnGoingUserAvail();
        }
      }).catchError((onError) {
        LogMessage.d("openAudioFilePicker", onError);
        setOnGoingUserAvail();
      });
    }
  }

  sendAudioMessage(String filePath, bool isRecorded, String duration) async {
    if(!availableFeatures.value.isAudioAttachmentAvailable.checkNull()){
      Helper.showFeatureUnavailable();
      return;
    }
    var busyStatus = !profile.isGroupProfile.checkNull()
        ? await Mirrorfly.isBusyStatusEnabled()
        : false;
    if (!busyStatus.checkNull()) {
      var replyMessageId = "";

      if (isReplying.value) {
        replyMessageId = replyChatMessage.messageId;
      }

      isUserTyping(false);
      isReplying(false);
      Mirrorfly.sendAudioMessage(
          profile.jid!, filePath, isRecorded, duration, replyMessageId,topicId: topicId)
          .then((value) {
        mirrorFlyLog("Audio Message sent", value);
        ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
        // chatList.insert(0, chatMessageModel);
        scrollToBottom();
        updateLastMessage(value);
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
    mirrorFlyLog("isTyping", typingText.toString());
    messageController.text
        .trim()
        .isNotEmpty
        ? isUserTyping(true)
        : isUserTyping(false);
    sendUserTypingStatus();
    debugPrint('User is typing');
    deBouncer.cancel();
    deBouncer.run(() {
      debugPrint("DeBouncer");
      sendUserTypingGoneStatus();
    });
  }

  clearChatHistory(bool isStarredExcluded) {
    if(!availableFeatures.value.isClearChatAvailable.checkNull()){
      Helper.showFeatureUnavailable();
      return;
    }
    Mirrorfly.clearChat(profile.jid!, "chat", isStarredExcluded).then((value) {
      if (value) {
        // var chatListrev = chatList.reversed;

        isStarredExcluded
            ? chatList.removeWhere((p0) => p0.isMessageStarred.value == false)
            : chatList.clear();
        cancelReplyMessage();
        // chatList.refresh();
        onMessageDeleteNotifyUI(profile.jid.checkNull());
      }
    });
  }

  void handleReplyChatMessage(ChatMessageModel chatListItem) {
    if (!chatListItem.isMessageRecalled.value &&
        !chatListItem.isMessageDeleted) {
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
    chatList.isSelected(false);
    if (selectedChatList.isEmpty) {
      isSelected(false);
      selectedChatList.clear();
    }
    this.chatList.refresh();
  }

  clearAllChatSelection() {
    isSelected(false);
    for (var chatItem in chatList) {
      chatItem.isSelected(false);
    }
    selectedChatList.clear();
    chatList.refresh();
  }

  void addChatSelection(ChatMessageModel item) {
    if (item.messageType.toUpperCase() != Constants.mNotification) {
      selectedChatList.add(item);
      item.isSelected(true);
      // chatList.refresh();
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
    Future.delayed(const Duration(milliseconds: 100), () async {
      var chatMessage =
      selectedChatList.isNotEmpty ? selectedChatList[0] : null;
      Helper.showAlert(
          title: "Report ${getName(profile)}?",
          message:
          "${selectedChatList.isNotEmpty
              ? "This message will be forwarded to admin."
              : "The last 5 messages from this contact will be forwarded to admin."} This Contact will not be notified.",
          actions: [
            TextButton(
                onPressed: () async {
                  Get.back();
                  if (await AppUtils.isNetConnected()) {
                    Mirrorfly.reportUserOrMessages(
                        profile.jid!,
                        chatMessage?.messageChatType ?? "chat",
                        chatMessage?.messageId ?? "")
                        .then((value) {
                      //report success
                      debugPrint(value.toString());
                      if (value.checkNull()) {
                        toToast("Report sent");
                      } else {
                        toToast("There are no messages available");
                      }
                    }).catchError((onError) {
                      //report failed
                      debugPrint(onError.toString());
                    });
                  } else {
                    toToast(Constants.noInternetConnection);
                  }
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
        ClipboardData(text: selectedChatList[0].messageTextContent ?? ""));
    // selectedChatList.clear();
    // isSelected(false);
    clearChatSelection(selectedChatList[0]);
    toToast("1 Text Copied Successfully to the clipboard");
  }

  Map<bool, bool> isMessageCanbeRecalled() {
    var recallTimeDifference =
    ((DateTime
        .now()
        .millisecondsSinceEpoch - 30000) * 1000);
    return {
      selectedChatList.any((element) =>
      element.isMessageSentByMe &&
          !element.isMessageRecalled.value &&
          (element.messageSentTime > recallTimeDifference)):
      selectedChatList.any((element) =>
      !element.isMessageRecalled.value &&
          (element.isMediaMessage() &&
              element.mediaChatMessage!
                  .mediaLocalStoragePath.value
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
              "Are you sure you want to delete selected Message${selectedChatList.length > 1 ? "s" : ""}?",
              style: const TextStyle(fontSize: 18, color: textColor),
            ),
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
                if(!availableFeatures.value.isDeleteMessageAvailable.checkNull()){
                  Helper.showFeatureUnavailable();
                  return;
                }
                //Helper.showLoading(message: 'Deleting Message');
                var chatJid = selectedChatList.last.chatUserJid;
                Mirrorfly.deleteMessagesForMe(profile.jid!, chatType,
                    deleteChatListID, isMediaDelete.value)
                    .then((value) {
                  debugPrint(value.toString());
                  //Helper.hideLoading();
                  /*if (value!=null && value) {
                  removeChatList(selectedChatList);
                }
                isSelected(false);
                selectedChatList.clear();*/

                  onMessageDeleteNotifyUI(chatJid);
                });
                removeChatList(selectedChatList);
                isSelected(false);
                selectedChatList.clear();
              },
              child: const Text("DELETE FOR ME")),
          TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text("CANCEL")),
          isRecallAvailable
              ? TextButton(
              onPressed: () {
                Get.back();
                if(!availableFeatures.value.isDeleteMessageAvailable.checkNull()){
                  Helper.showFeatureUnavailable();
                  return;
                }
                //Helper.showLoading(message: 'Deleting Message for Everyone');
                Mirrorfly.deleteMessagesForEveryone(profile.jid!, chatType,
                    deleteChatListID, isMediaDelete.value)
                    .then((value) {
                  debugPrint(value.toString());
                  //Helper.hideLoading();
                  if (value) {
                    // removeChatList(selectedChatList);//
                    for (var chatList in selectedChatList) {
                      chatList.isMessageRecalled(true);
                      chatList.isSelected(false);
                      // this.chatList.refresh();
                      if (selectedChatList.last.messageId ==
                          chatList.messageId) {
                        onMessageDeleteNotifyUI(chatList.chatUserJid);
                      }
                    }
                  }
                  if (!value) {
                    toToast("Unable to delete the selected Messages");
                    for (var chatList in selectedChatList) {
                      chatList.isSelected(false);
                      // this.chatList.refresh();
                      if (selectedChatList.last.messageId ==
                          chatList.messageId) {
                        onMessageDeleteNotifyUI(chatList.chatUserJid);
                      }
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
    setOnGoingUserGone();
    Future.delayed(const Duration(milliseconds: 100), () {
      debugPrint("sending mid ===> ${selectedChatList[0].messageId}");
      Get.toNamed(Routes.messageInfo, arguments: {
        "messageID": selectedChatList[0].messageId,
        "chatMessage": selectedChatList[0],
        "isGroupProfile": profile.isGroupProfile,
        "jid": profile.jid
      })?.then((value) {
        setOnGoingUserAvail();
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

    Mirrorfly.updateFavouriteStatus(selectedChatList[0].messageId, profile.jid!,
        !selectedChatList[0].isMessageStarred, profile.getChatType())
        .then((value) {
      selectedChatList[0].isMessageStarred = !isMessageStarred;
      clearChatSelection(selectedChatList[0]);
      Helper.hideLoading();
    });*/
    for (var item in selectedChatList) {
      Mirrorfly.updateFavouriteStatus(item.messageId, item.chatUserJid,
          !item.isMessageStarred.value, item.messageChatType);
      var msg =
      chatList.firstWhere((element) => item.messageId == element.messageId);
      msg.isMessageStarred(!item.isMessageStarred.value);
      msg.isSelected(false);
    }
    isSelected(false);
    selectedChatList.clear();
    // chatList.refresh();
  }

  Widget getLocationImage(
      LocationChatMessage? locationChatMessage, double width, double height) {
    return InkWell(
        onTap: () async {
          String googleUrl =
              'https://www.google.com/maps/search/?api=1&query=${locationChatMessage.latitude}, ${locationChatMessage
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

  blockUser() {
    Future.delayed(const Duration(milliseconds: 100), () async {
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
                    Mirrorfly.blockUser(profile.jid!).then((value) {
                      debugPrint("$value");
                      profile.isBlocked = true;
                      isBlocked(true);
                      profile_.refresh();
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
    if(!availableFeatures.value.isClearChatAvailable.checkNull()){
      Helper.showFeatureUnavailable();
      return;
    }
    if (chatList.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 100), () {
        var starred =
        chatList.indexWhere((element) => element.isMessageStarred.value);
        Helper.showAlert(
            message: "Are you sure you want to clear the chat?",
            actions: [
              Visibility(
                visible: !starred.isNegative,
                child: TextButton(
                    onPressed: () {
                      Get.back();
                      clearChatHistory(false);
                    },
                    child: const Text("CLEAR ALL")),
              ),
              TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text("CANCEL")),
              Visibility(
                visible: starred.isNegative,
                child: TextButton(
                    onPressed: () {
                      Get.back();
                      clearChatHistory(false);
                    },
                    child: const Text("CLEAR")),
              ),
              Visibility(
                visible: !starred.isNegative,
                child: TextButton(
                    onPressed: () {
                      Get.back();
                      clearChatHistory(true);
                    },
                    child: const Text("CLEAR EXCEPT STARRED")),
              ),
            ]);
      });
    } else {
      toToast("There is no conversation.");
    }
  }

  unBlockUser() {
    Future.delayed(const Duration(milliseconds: 100), () {
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
                Mirrorfly.unblockUser(profile.jid!).then((value) {
                  debugPrint(value.toString());
                  profile.isBlocked = false;
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
    });
  }

  var filteredPosition = <int>[].obs;
  var searchedText = TextEditingController();
  String lastInputValue = "";

  setSearch(String text) {
    if (lastInputValue != text.trim()) {
      lastInputValue = text.trim();
      filteredPosition.clear();
      if (searchedText.text
          .trim()
          .isNotEmpty) {
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
    if (filteredPosition.isNotEmpty) {
      var visiblePos = findTopFirstVisibleItemPosition();
      mirrorFlyLog("visiblePos", visiblePos.toString());
      mirrorFlyLog(
          "visiblePos2", findBottomLastVisibleItemPosition().toString());
      var g = getNextPosition(findTopFirstVisibleItemPosition(),
          findBottomLastVisibleItemPosition(), j);
      if (g != null) j = g;
      mirrorFlyLog("scrollUp", g.toString());
      if (j >= 0 && g != null) {
        _scrollToPosition(j);
      } else {
        toToast("No Results Found");
      }
    } else {
      toToast("No Results Found");
    }
  }

  scrollDown() {
    if (filteredPosition.isNotEmpty) {
      var visiblePos = findTopFirstVisibleItemPosition();
      mirrorFlyLog("visiblePos", visiblePos.toString());
      var g = getPreviousPosition(findTopFirstVisibleItemPosition(),
          findBottomLastVisibleItemPosition(), j);
      if (g != null) j = g;
      mirrorFlyLog("scrollDown", j.toString());
      if (j >= 0 && g != null) {
        _scrollToPosition(j);
      } else {
        toToast("No Results Found");
      }
    } else {
      toToast("No Results Found");
    }
  }

  var color = Colors.transparent.obs;

  _scrollToPosition(int position) {
    // mirrorFlyLog("position", position.toString());
    if (!position.isNegative) {
      var currentPosition = position;
      // filteredPosition[position]; //(chatList.length - (position));
      mirrorFlyLog("currentPosition", currentPosition.toString());
      chatList[currentPosition].isSelected(true);
      searchScrollController.jumpTo(index: currentPosition);
      Future.delayed(const Duration(milliseconds: 800), () {
        currentPosition = (currentPosition);
        chatList[currentPosition].isSelected(false);
        chatList.refresh();
      });
    } else {
      toToast("No Results Found");
    }
  }

  int? getPreviousPosition(int end, int start, int previousPos) {
    var previousClicked =
        previousPos; //!previousPos.isNegative ? filteredPosition[previousPos] : -1;
    debugPrint(
        'start : $start end : $end previousClickedPos : $previousClicked');
    debugPrint('previousPos : $previousPos');
    var isNotInTheView = (previousClicked <= end && previousClicked >= start);
    if (previousClicked == filteredPosition.first && isNotInTheView) {
      return null;
    }
    var reversedList = filteredPosition.reversed.toList();
    var findBetweenOrBelow = reversedList.firstWhere((y) =>
    ((y <= end && y >= start) && !previousClicked.isNegative
        ? (previousClicked != y)
        : true) &&
        start > y);
    if (!findBetweenOrBelow.isNegative) {
      debugPrint('findBetweenOrBelow : $findBetweenOrBelow}');
    }
    debugPrint('filteredPosition : ${reversedList.join(',')}');
    return findBetweenOrBelow;
  }

  //returns the position of filtered position
  int? getNextPosition(int end, int start, int previousPos) {
    var previousClicked =
        previousPos; //!previousPos.isNegative ? filteredPosition[previousPos] : -1;
    debugPrint(
        'start : $start end : $end previousClickedPos : $previousClicked');
    debugPrint('previousPos : $previousPos');
    var isNotInTheView = (previousClicked <= end && previousClicked >= start);
    if (previousClicked == filteredPosition.last && isNotInTheView) {
      return null;
    }
    var findBetweenOrAbove = filteredPosition.firstWhere((y) =>
    ((y >= end && y <= start) && !previousClicked.isNegative
        ? (previousClicked != y)
        : true) &&
        start < y);
    if (!findBetweenOrAbove.isNegative) {
      debugPrint('findbetweenorabove : $findBetweenOrAbove');
    }
    debugPrint('filteredPosition : ${filteredPosition.join(',')}');
    return findBetweenOrAbove;
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

  int findTopFirstVisibleItemPosition() {
    var r = itemPositionsListener.itemPositions.value
        .where((ItemPosition position) => position.itemTrailingEdge < 1)
        .reduce((ItemPosition min, ItemPosition position) =>
    position.itemTrailingEdge > min.itemTrailingEdge ? position : min)
        .index;
    return r; //< chatList.length ? r + 1 : r;
  }

  int findBottomLastVisibleItemPosition() {
    var r = itemPositionsListener.itemPositions.value
        .where((ItemPosition position) => position.itemTrailingEdge < 1)
        .reduce((ItemPosition min, ItemPosition position) =>
    position.itemTrailingEdge < min.itemTrailingEdge ? position : min)
        .index;
    return r; // < chatList.length ? r + 1 : r;
  }

  exportChat() async {
    if (chatList.isNotEmpty) {
      var permission = await AppPermission.getStoragePermission();
      if (permission) {
        Mirrorfly.exportChatConversationToEmail(profile.jid.checkNull())
            .then((value) async {
          debugPrint("exportChatConversationToEmail $value");
          var data = exportModelFromJson(value);
          if (data.mediaAttachmentsUrl != null) {
            if (data.mediaAttachmentsUrl!.isNotEmpty) {
              var xfiles = <XFile>[];
              data.mediaAttachmentsUrl
                  ?.forEach((element) => xfiles.add(XFile(element)));
              await Share.shareXFiles(xfiles);
            }
          }
        });
      } else {
        toToast("permission denid");
      }
    } else {
      toToast("There is no conversation.");
    }
  }

  checkBusyStatusForForward() async {
    var busyStatus = !profile.isGroupProfile.checkNull()
        ? await Mirrorfly.isBusyStatusEnabled()
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
      setOnGoingUserGone();
      clearAllChatSelection();
      Get.toNamed(Routes.forwardChat, arguments: {
        "forward": true,
        "group": false,
        "groupJid": "",
        "messageIds": messageIds
      })?.then((value) {
        if (value != null) {
          debugPrint(
              "result of forward ==> ${(value as ProfileDetails).toJson().toString()}");
          profile_.value = value;
          isBlocked(profile.isBlocked);
        }
        setChatStatus();
        checkAdminBlocked();
        memberOfGroup();
        setOnGoingUserAvail();
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

  startRecording() async {
    if (playingChat != null) {
      playingChat!.mediaChatMessage!.isPlaying = false;
      playingChat = null;
      // player.stop();
      chatList.refresh();
    }
    var busyStatus = !profile.isGroupProfile.checkNull()
        ? await Mirrorfly.isBusyStatusEnabled()
        : false;
    if (!busyStatus.checkNull()) {
      var permission = await AppPermission.getStoragePermission();
      if (permission) {
        if (await Record().hasPermission()) {
          record = Record();
          timerInit("00:00");
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
        debugPrint("File Not Found For Audio");
      }
      debugPrint(filePath);
    });
  }

  Future<void> deleteRecording() async {
    var filePath = await record.stop();
    File(filePath!).delete();
    isUserTyping(false);
    isAudioRecording(Constants.audioRecordInitial);
    timerInit("00:00");
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
    if (timerInit.value != "00:00") {
      final format = DateFormat('mm:ss');
      final dt = format.parse(timerInit.value, true);
      final recordDuration = dt.millisecondsSinceEpoch;
      sendAudioMessage(recordedAudioPath, true, recordDuration.toString());
    } else {
      toToast("Recorded Audio Time is too Short");
    }
    isUserTyping(false);
    isAudioRecording(Constants.audioRecordInitial);
    timerInit("00:00");
    record.dispose();
  }

  infoPage() {
    setOnGoingUserGone();
    if (profile.isGroupProfile ?? false) {
      Get.toNamed(Routes.groupInfo, arguments: profile)?.then((value) {
        if (value != null) {
          profile_(value as ProfileDetails);
          isBlocked(profile.isBlocked);
          debugPrint("value--> ${profile.isGroupProfile}");
        }
        checkAdminBlocked();
        memberOfGroup();
        setChatStatus();
        setOnGoingUserAvail();
      });
    } else {
      Get.toNamed(Routes.chatInfo, arguments: profile)?.then((value) {
        debugPrint("chat info-->$value");
        setOnGoingUserAvail();
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
    Mirrorfly.sendTypingStatus(profile.jid.checkNull(), profile.getChatType());
  }

  sendUserTypingGoneStatus() {
    Mirrorfly.sendTypingGoneStatus(
        profile.jid.checkNull(), profile.getChatType());
  }

  var unreadCount = 0.obs;

  void onMessageReceived(ChatMessageModel chatMessageModel) {
    mirrorFlyLog("chatController", "onMessageReceived");

    if (chatMessageModel.chatUserJid == profile.jid) {
      // chatList.insert(0, chatMessageModel);
      loadLastMessages(chatMessageModel);
      //scrollToBottom();
      // if (isLive) {
      if (SessionManagement.getCurrentChatJID() != "") {
        setOnGoingUserAvail();
      }
      // }
    }
  }

  Future<void> onMessageStatusUpdated(ChatMessageModel chatMessageModel) async {
    if (chatMessageModel.chatUserJid == profile.jid) {
      final index = chatList.indexWhere(
              (message) => message.messageId == chatMessageModel.messageId);
      debugPrint("ChatScreen Message Status Update index of search $index");
      debugPrint("messageID--> $index  ${chatMessageModel.messageId}");
      if (!index.isNegative) {
        debugPrint("messageID--> replacing the value");
        // Helper.hideLoading();
        // chatMessageModel.isSelected=chatList[index].isSelected;
        chatList[index] = chatMessageModel;
        chatList.refresh();
      }
    }
    if (isSelected.value) {
      var selectedIndex = selectedChatList.indexWhere(
              (element) => chatMessageModel.messageId == element.messageId);
      if (!selectedIndex.isNegative) {
        chatMessageModel
            .isSelected(true); //selectedChatList[selectedIndex].isSelected;
        selectedChatList[selectedIndex] = chatMessageModel;
        selectedChatList.refresh();
        getMessageActions();
      }
    }
  }

  void onMediaStatusUpdated(ChatMessageModel chatMessageModel) {
    if (chatMessageModel.chatUserJid == profile.jid) {
      final index = chatList.indexWhere(
              (message) => message.messageId == chatMessageModel.messageId);
      debugPrint("Media Status Update index of search $index");
      if (index != -1) {
        // chatMessageModel.isSelected=chatList[index].isSelected;
        chatList[index].mediaChatMessage?.mediaLocalStoragePath(chatMessageModel.mediaChatMessage!.mediaLocalStoragePath.value);
        chatList[index].mediaChatMessage?.mediaDownloadStatus(chatMessageModel.mediaChatMessage!.mediaDownloadStatus.value);
        chatList[index].mediaChatMessage?.mediaUploadStatus(chatMessageModel.mediaChatMessage!.mediaUploadStatus.value);
      }
    }
    if (isSelected.value) {
      var selectedIndex = selectedChatList.indexWhere(
              (element) => chatMessageModel.messageId == element.messageId);
      if (!selectedIndex.isNegative) {
        chatMessageModel.isSelected(true); //selectedChatList[selectedIndex].isSelected;
        selectedChatList[selectedIndex] = chatMessageModel;
        selectedChatList.refresh();
        getMessageActions();
      }
    }
  }

  void onGroupProfileUpdated(groupJid) {
    if (profile.jid.checkNull() == groupJid.toString()) {
      getProfileDetails(profile.jid.checkNull()).then((value) {
        if (value.jid != null) {
          var member = value; //Profile.fromJson(json.decode(value.toString()));
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

  void setTypingStatus(String singleOrgroupJid, String userId, String typingStatus) {
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
      Mirrorfly.isMemberOfGroup(profile.jid.checkNull(), SessionManagement.getUserJID())
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
              "${ProfileDetails(jid: typingList.last).getUsername()} typing...");
          //"${Member(jid: typingList.last).getUsername()} typing...");
        } else {
          getParticipantsNameAsCsv(profile.jid.checkNull());
        }
      } else {
        if (!profile.isBlockedMe.checkNull() ||
            !profile.isAdminBlocked.checkNull()) {
          Mirrorfly.getUserLastSeenTime(profile.jid.toString()).then((value) {
            debugPrint("date time flutter--->");
            var lastSeen = convertSecondToLastSeen(value!);
            groupParticipantsName('');
            userPresenceStatus(lastSeen.toString());
          }).catchError((er) {
            groupParticipantsName('');
            userPresenceStatus("");
          });
        } else {
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
    Mirrorfly.getGroupMembersList(jid, false).then((value) {
      if (value.isNotEmpty) {
        var str = <String>[];
        mirrorFlyLog("getGroupMembersList-->", value);
        var groupsMembersProfileList = memberFromJson(value);
        for (var it in groupsMembersProfileList) {
          if (it.jid.checkNull() !=
              SessionManagement.getUserJID().checkNull()) {
            str.add(getMemberName(it).checkNull());
          }
        }
        str.sort((a, b) {
          return a.toLowerCase().compareTo(b.toLowerCase());
        });
        groupParticipantsName(str.join(","));
      }
    });
  }

  String get subtitle =>
      userPresenceStatus.isEmpty
          ? /*groupParticipantsName.isNotEmpty
          ? groupParticipantsName.toString()
          :*/
      Constants.emptyString
          : userPresenceStatus.toString();

  // final ImagePicker _picker = ImagePicker();

  onCameraClick() async {
    if(!availableFeatures.value.isImageAttachmentAvailable.checkNull() && !availableFeatures.value.isVideoAttachmentAvailable.checkNull()){
      Helper.showFeatureUnavailable();
      return;
    }
    // if (await AppPermission.askFileCameraAudioPermission()) {
    var cameraPermissionStatus = await AppPermission.checkPermission(
        Permission.camera, cameraPermission, Constants.cameraPermission);
    debugPrint("Camera Permission Status---> $cameraPermissionStatus");
    if (cameraPermissionStatus) {
      setOnGoingUserGone();
      Get.toNamed(Routes.cameraPick)?.then((photo) {
        photo as XFile?;
        if (photo != null) {
          mirrorFlyLog("photo", photo.name.toString());
          mirrorFlyLog("caption text sending-->", messageController.text);
          /*if (photo.name.endsWith(".mp4")) {
            Get.toNamed(Routes.videoPreview, arguments: {
              "filePath": photo.path,
              "userName": profile.name!,
              "profile": profile,
              "caption": messageController.text
            });
          } else {
            Get.toNamed(Routes.imagePreview, arguments: {
              "filePath": photo.path,
              "userName": profile.name!,
              "profile": profile,
              "caption": messageController.text
            });
          }*/
          var file = PickedAssetModel(
            path: photo.path,
            type: !photo.name.endsWith(".mp4") ? "image" : "video",
          );
          Get.toNamed(Routes.mediaPreview, arguments: {
            "filePath": [file],
            "userName": profile.name!,
            'profile': profile,
            'caption': messageController.text.trim(),
            'showAdd': false,
            'from': 'camera_pick'
          })?.then((value) => setOnGoingUserAvail());
        } else {
          setOnGoingUserAvail();
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
    if(!availableFeatures.value.isAudioAttachmentAvailable.checkNull()){
      Helper.showFeatureUnavailable();
      return;
    }
    var permission = await AppPermission.getStoragePermission();
    if (permission) {
      pickAudio();
    }
  }

  onGalleryClick() async {
    if(!availableFeatures.value.isImageAttachmentAvailable.checkNull() && !availableFeatures.value.isVideoAttachmentAvailable.checkNull()){
      Helper.showFeatureUnavailable();
      return;
    }
    var permission = await AppPermission.getStoragePermission();
    if (permission) {
      try {
        // imagePicker();
        setOnGoingUserGone();
        Get.toNamed(Routes.galleryPicker, arguments: {
          "userName": getName(profile),
          'profile': profile,
          'caption': messageController.text.trim()
        })?.then((value) => setOnGoingUserAvail());
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  onContactClick() async {
    if(!availableFeatures.value.isContactAttachmentAvailable.checkNull()){
      Helper.showFeatureUnavailable();
      return;
    }
    // if (await askContactsPermission()) {
    if (await AppPermission.checkPermission(
        Permission.contacts, contactPermission, Constants.contactPermission)) {
      setOnGoingUserGone();
      Get.toNamed(Routes.localContact)?.then((value) => setOnGoingUserAvail());
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
    if(!availableFeatures.value.isLocationAttachmentAvailable.checkNull()){
      Helper.showFeatureUnavailable();
      return;
    }
    if (await AppUtils.isNetConnected()) {
      if (await AppPermission.checkPermission(Permission.location,
          locationPinPermission, Constants.locationPermission)) {
        setOnGoingUserGone();
        Get.toNamed(Routes.locationSent)?.then((value) {
          if (value != null) {
            value as LatLng;
            sendLocationMessage(profile, value.latitude, value.longitude);
          }
          setOnGoingUserAvail();
        });
      }
    } else {
      toToast(Constants.noInternetConnection);
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
    Mirrorfly.makeVoiceCall(profile.jid.checkNull()).then((value){
      mirrorFlyLog("makeVoiceCall", value.toString());
    });
  }*/

  Future<void> translateMessage(int index) async {
    /*if (SessionManagement.isGoogleTranslationEnable()) {
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
    }*/
  }

  bool forwardMessageVisibility(ChatMessageModel chat) {
    if (!chat.isMessageRecalled.value && !chat.isMessageDeleted) {
      if (chat.isMediaMessage()) {
        if ((chat.mediaChatMessage!.mediaDownloadStatus.value ==
            Constants.mediaDownloaded ||
            chat.mediaChatMessage!.mediaUploadStatus.value ==
                Constants.mediaUploaded) &&(checkFile(chat.mediaChatMessage!.mediaLocalStoragePath.value.checkNull()))) {
          return true;
        }
      } else {
        if (chat.messageType == Constants.mLocation ||
            chat.messageType == Constants.mContact) {
          return true;
        }
      }
    }
    return false;
  }

  forwardSingleMessage(String messageId) {
    setOnGoingUserGone();
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
            "result of forward ==> ${(value as ProfileDetails).toJson().toString()}");
        profile_.value = value;
        isBlocked(profile.isBlocked);
      }
      checkAdminBlocked();
      memberOfGroup();
      setOnGoingUserAvail();
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
      if (message.isMessageRecalled.value) {
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
        ((message.isMessageSentByMe && message.messageStatus.value == "N") ||
            (message.isMediaMessage() &&
                !checkFile(message.mediaChatMessage!.mediaLocalStoragePath.value)))) {
      canBeForwarded(false);
      canBeForwardedSet = true;
    }
    //Share Validation
    if (!canBeSharedSet &&
        (!message.isMediaMessage() ||
            (message.isMediaMessage() &&
                !checkFile(message.mediaChatMessage!.mediaLocalStoragePath.value)))) {
      canBeShared(false);
      canBeSharedSet = true;
    }
    //Starred Validation
    if (!canBeStarredSet && message.isMessageStarred.value ||
        (message.isMediaMessage() &&
            !checkFile(message.mediaChatMessage!.mediaLocalStoragePath.value))) {
      canBeStarred(false);
      canBeStarredSet = true;
    }
    //UnStarred Validation
    if (!canBeUnStarredSet && !message.isMessageStarred.value) {
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
      if (message.isMessageSentByMe && message.messageStatus.value == "N") {
        canBeReplied(false);
      }
      //Info Validation
      if (!message.isMessageSentByMe ||
          message.messageStatus.value == "N" ||
          message.isMessageRecalled.value ||
          (message.isMediaMessage() &&
              !checkFile(message.mediaChatMessage!.mediaLocalStoragePath.value))) {
        canShowInfo(false);
      }
      //Report validation
      if (message.isMessageSentByMe) {
        canShowReport(false);
      } else {
        canShowReport(true);
      }
    }
  }

  void navigateToMessage(ChatMessageModel chatMessage, {int? index}) {
    var messageID = chatMessage.messageId;
    var chatIndex = index ??
        chatList.indexWhere((element) => element.messageId == messageID);
    if (!chatIndex.isNegative) {
      newScrollController.scrollTo(
          index: chatIndex, duration: const Duration(milliseconds: 10));
      Future.delayed(const Duration(milliseconds: 15), () {
        chatList[chatIndex].isSelected(true);
        chatList.refresh();
      });

      Future.delayed(const Duration(milliseconds: 800), () {
        chatList[chatIndex].isSelected(false);
        chatList.refresh();
      });
    } else {
      getMessageFromServerAndNavigateToMessage(chatMessage, index);
    }
  }

  void getMessageFromServerAndNavigateToMessage(ChatMessageModel chatMessage, int? index) {
    Mirrorfly.loadMessages(FlyCallback()..onResponse = (FlyResponse response){
      showLoadingNext(false);
      showLoadingPrevious(false);
      if(response.isSuccess && response.data.isNotEmpty){
        chatList.clear();
        List<ChatMessageModel> chatMessageModel =
        chatMessageModelFromJson(response.data);
        chatList(chatMessageModel.reversed.toList());
        navigateToMessage(chatMessage, index: index);
        chatLoading(false);
      }else{
        chatLoading(false);
      }
    });
     /*   .then((value) {

    }).catchError((e) {
      chatLoading(false);
    });*/
  }

  int findLastVisibleItemPositionForChat() {
    /*var r = newitemPositionsListener.itemPositions.value
        .where((ItemPosition position) => position.itemTrailingEdge < 1)
        .reduce((ItemPosition min, ItemPosition position) =>
            position.itemTrailingEdge < min.itemTrailingEdge ? position : min)
        .index;
    return r < chatList.length ? r + 1 : r;*/
    return newitemPositionsListener.itemPositions.value.first.index - 1;
  }

  void share() {
    var mediaPaths = <XFile>[];
    for (var item in selectedChatList) {
      if (item.isMediaMessage()) {
        if ((item.isMediaDownloaded() || item.isMediaUploaded()) &&
            item.mediaChatMessage!
                .mediaLocalStoragePath.value
                .checkNull()
                .isNotEmpty) {
          mediaPaths.add(
              XFile(item.mediaChatMessage!.mediaLocalStoragePath.value.checkNull()));
          debugPrint(
              "mediaPaths ${item.mediaChatMessage!.mediaLocalStoragePath.value.checkNull()}");
        }
      }
    }
    clearAllChatSelection();
    Share.shareXFiles(mediaPaths);
  }

  @override
  void onPaused() {
    mirrorFlyLog("chat controller LifeCycle", "onPaused");
    setOnGoingUserGone();
    playerPause();
    saveUnsentMessage();
    sendUserTypingGoneStatus();
  }

  @override
  void onResumed() {
    mirrorFlyLog("LifeCycle", "onResumed");
    cancelNotification();
    setChatStatus();
    getAvailableFeatures();

    /// we loading next messages instead of load message because the new messages received will be available in load next message
    _loadNextMessages();
    if (!KeyboardVisibilityController().isVisible) {
      if (focusNode.hasFocus) {
        focusNode.unfocus();
        Future.delayed(const Duration(milliseconds: 100), () {
          focusNode.requestFocus();
        });
      }
      if (searchfocusNode.hasFocus) {
        searchfocusNode.unfocus();
        Future.delayed(const Duration(milliseconds: 100), () {
          searchfocusNode.requestFocus();
        });
      }
    }
    setOnGoingUserAvail();
  }

  void markConversationReadNotifyUI() {
    mirrorFlyLog("setConversationAsRead", "chat");
    if (Get.isRegistered<MainController>()) {
      Get.find<MainController>()
          .markConversationReadNotifyUI(profile.jid.checkNull());
    }
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
      if (!profile.isGroupProfile.checkNull()) {
        getProfileDetails(jid).then((value) {
          debugPrint("update Profile contact sync $value");
          SessionManagement.setChatJid("");
          profile_(value);
          checkAdminBlocked();
          isBlocked(profile.isBlocked);
          setChatStatus();
          profile_.refresh();
        });
      } else {
        debugPrint("unable to update profile due to group chat");
      }
    }
  }

  void userCameOnline(jid) {
    if (jid.isNotEmpty &&
        profile.jid == jid &&
        !profile.isGroupProfile.checkNull()) {
      debugPrint("userCameOnline : $jid");
      Future.delayed(const Duration(milliseconds: 3000), () {
        setChatStatus();
      });
    }
  }

  void userWentOffline(jid) {
    if (jid.isNotEmpty &&
        profile.jid == jid &&
        !profile.isGroupProfile.checkNull()) {
      debugPrint("userWentOffline : $jid");
      Future.delayed(const Duration(milliseconds: 3000), () {
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

  void removeUnreadSeparator() async {
    if (!profile.isGroupProfile.checkNull()) {
      chatList.removeWhere(
              (chatItem) => chatItem.messageType == Constants.mNotification);
    }
  }

  void onContactSyncComplete(bool result) {
    userUpdatedHisProfile(profile.jid.checkNull());
  }

  void userDeletedHisProfile(String jid) {
    userUpdatedHisProfile(jid);
  }

  void onNewMemberAddedToGroup({required String groupJid,
    required String newMemberJid,
    required String addedByMemberJid}) {
    if (profile.isGroupProfile.checkNull()) {
      if (profile.jid == groupJid) {
        debugPrint('onNewMemberAddedToGroup $newMemberJid');
        getParticipantsNameAsCsv(groupJid);
      }
    }
  }

  void onMemberRemovedFromGroup({required String groupJid,
    required String removedMemberJid,
    required String removedByMemberJid}) {
    if (profile.isGroupProfile.checkNull()) {
      if (profile.jid == groupJid) {
        debugPrint('onMemberRemovedFromGroup $removedMemberJid');
        if (removedMemberJid != profile.jid) {
          getParticipantsNameAsCsv(groupJid);
        } else {
          //removed me
          onLeftFromGroup(groupJid: groupJid, userJid: removedMemberJid);
        }
      }
    }
  }

  Future<void> saveContact() async {
    var phone = profile.mobileNumber
        .checkNull()
        .isNotEmpty
        ? profile.mobileNumber.checkNull()
        : getMobileNumberFromJid(profile.jid.checkNull());
    var userName = profile.nickName
        .checkNull()
        .isNotEmpty
        ? profile.nickName.checkNull()
        : profile.name.checkNull();
    if (phone.isNotEmpty) {
      lib_phone_number.init();
      var formatNumberSync = lib_phone_number.formatNumberSync(phone);
      var parse = await lib_phone_number.parse(formatNumberSync);
      debugPrint("parse-----> $parse");
      Mirrorfly.addContact(parse["international"], userName).then((value) {
        if (value ?? false) {
          toToast("Contact Saved");
          if (Constants.enableContactSync) {
            syncContacts();
          }
        }
      });
    } else {
      mirrorFlyLog('mobile number', phone.toString());
    }
  }

  void syncContacts() async {
    if (await Permission.contacts.isGranted) {
      if (await AppUtils.isNetConnected() &&
          !await Mirrorfly.contactSyncStateValue()) {
        final permission = await Permission.contacts.status;
        if (permission == PermissionStatus.granted) {
          if (SessionManagement.getLogin()) {
            Mirrorfly.syncContacts(
                !SessionManagement.isInitialContactSyncDone());
          }
        }
      }
    } else {
      debugPrint("Contact sync permission is not granted");
      if (SessionManagement.isInitialContactSyncDone()) {
        Mirrorfly.revokeContactSync().then((value) {
          onContactSyncComplete(true);
          mirrorFlyLog("checkContactPermission isSuccess", value.toString());
        });
      }
    }
  }

  void userBlockedMe(String jid) {
    updateProfile(jid);
  }

  void showHideEmoji(BuildContext context) {
    if (!showEmoji.value) {
      focusNode.unfocus();
    } else {
      focusNode.requestFocus();
      return;
    }
    Future.delayed(const Duration(milliseconds: 100), () {
      showEmoji(!showEmoji.value);
    });
  }

  void onUploadDownloadProgressChanged(String messageId, String progressPercentage) {
    if (messageId.isNotEmpty) {
      final index =
      chatList.indexWhere((message) => message.messageId == messageId);
      debugPrint(
          "Media Status Onprogress changed---> onUploadDownloadProgressChanged $index $messageId $progressPercentage");
      if (!index.isNegative) {
        // chatMessageModel.isSelected=chatList[index].isSelected;
        // debugPrint("Media Status Onprogress changed---> flutter conversion ${int.parse(progressPercentage)}");
        chatList[index]
            .mediaChatMessage
            ?.mediaProgressStatus(int.parse(progressPercentage));
        // chatList.refresh();
      }
    }
  }

  void makeVoiceCall() async {
    debugPrint("#FLY CALL VOICE CALL CALLING");
    closeKeyBoard();
    if (await AppUtils.isNetConnected()) {
      if (await AppPermission.askAudioCallPermissions()) {
        if(profile.isGroupProfile.checkNull()) {
          Get.toNamed(Routes.groupParticipants,arguments: {"groupId": profile.jid, "callType": CallType.audio});
        }else{
          Mirrorfly.makeVoiceCall(profile.jid.checkNull()).then((value) {
            if (value) {
              debugPrint("#Mirrorfly Call userjid ${profile.jid}");
              setOnGoingUserGone();
              Get.toNamed(Routes.outGoingCallView,
                  arguments: {"userJid": [profile.jid], "callType": CallType.audio})
                  ?.then((value) => setOnGoingUserAvail());
            }
          }).catchError((e) {
            debugPrint("#Mirrorfly Call $e");
          });
        }
      } else {
        debugPrint("permission not given");
      }
    } else {
      toToast(Constants.noInternetConnection);
    }
  }

  void makeVideoCall() async {
    closeKeyBoard();
    if (await AppUtils.isNetConnected()) {
      if (await AppPermission.askVideoCallPermissions()) {
        if(profile.isGroupProfile.checkNull()) {
          Get.toNamed(Routes.groupParticipants,arguments: {"groupId": profile.jid, "callType": CallType.video});
        }else {
          Mirrorfly.makeVideoCall(profile.jid.checkNull()).then((value) {
            if (value) {
              setOnGoingUserGone();
              Get.toNamed(Routes.outGoingCallView,
                  arguments: {"userJid": [profile.jid], "callType": CallType.video})
                  ?.then((value) => setOnGoingUserAvail());
            }
          }).catchError((e) {
            debugPrint("#Mirrorfly Call $e");
          });
        }
      } else {
        LogMessage.d("askVideoCallPermissions", "false");
      }
    } else {
      toToast(Constants.noInternetConnection);
    }
  }

  void loadNextChatHistory() {
    final itemPositions = newitemPositionsListener.itemPositions.value;

    if (itemPositions.isNotEmpty) {
      final firstVisibleItemIndex = itemPositions.first.index;

      debugPrint("reached length ${itemPositions.first.itemLeadingEdge}");
      debugPrint("reached firstItemIndex $firstVisibleItemIndex");
      debugPrint("reached chatList.length ${chatList.length}");
      debugPrint("reached itemPositions.length ${itemPositions.length}");

      if(Platform.isIOS) {
        ///This is the top constraint changing to bottom constraint and calling nextMessages bcz reversing the list view in display
        if (firstVisibleItemIndex <= 1 &&
            itemPositions.first.itemLeadingEdge <= 0) {
          // Scrolled to the Bottom
          debugPrint("reached Bottom yes load next messages");
          _loadNextMessages();
          ///This is the bottom constraint changing to Top constraint and calling prevMessages bcz reversing the list view in display
        } else if (firstVisibleItemIndex + itemPositions.length >=
            chatList.length) {
          // Scrolled to the Top
          _loadPreviousMessages();
          debugPrint("reached Top yes load previous msgs");
        }
      }else if(Platform.isAndroid){
        if(firstVisibleItemIndex==0){
          debugPrint("reached Bottom yes load next messages");
          _loadNextMessages();
        }else if(firstVisibleItemIndex + itemPositions.length >= chatList.length){
          debugPrint("reached Top yes load previous msgs");
          _loadPreviousMessages();
        }
      }
    }
  }

  void cancelNotification() {
    NotificationBuilder.cancelNotifications();
  }

  void setOnGoingUserGone() {
    Mirrorfly.setOnGoingChatUser("");
    SessionManagement.setCurrentChatJID("");
  }

  void setOnGoingUserAvail() {
    debugPrint("setOnGoingUserAvail");
    Mirrorfly.setOnGoingChatUser(profile.jid.checkNull());
    SessionManagement.setCurrentChatJID(profile.jid.checkNull());
    markConversationReadNotifyUI();
    cancelNotification();
  }

  void onMessageDeleteNotifyUI(String chatUserJid) {
    Get.find<MainController>().onMessageDeleteNotifyUI(chatUserJid);
  }

  Future<void> updateLastMessage(dynamic value) async {
    Get.find<MainController>().onMessageStatusUpdated(value);
    ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
    loadLastMessages(chatMessageModel);
  }

  void onAvailableFeaturesUpdated(AvailableFeatures features) {
    LogMessage.d("ChatView", "onAvailableFeaturesUpdated ${features.toJson()}");
    updateAvailableFeature(features);
  }
  void updateAvailableFeature(AvailableFeatures features){
    availableFeatures(features);
    var availableAttachment = <AttachmentIcon>[];
    if (features.isDocumentAttachmentAvailable.checkNull()) {
      availableAttachment.add(AttachmentIcon(documentImg, "Document"));
    }
    if (features.isImageAttachmentAvailable.checkNull() || features.isVideoAttachmentAvailable.checkNull()) {
      availableAttachment.add(AttachmentIcon(cameraImg, "Camera"));
      availableAttachment.add(AttachmentIcon(galleryImg, "Gallery"));
    }
    if (features.isAudioAttachmentAvailable.checkNull()) {
      availableAttachment.add(AttachmentIcon(audioImg, "Audio"));
    }
    if (features.isContactAttachmentAvailable.checkNull()) {
      availableAttachment.add(AttachmentIcon(contactImg, "Contact"));
    }
    if (features.isLocationAttachmentAvailable.checkNull()) {
      availableAttachment.add(AttachmentIcon(locationImg, "Location"));
    }
    availableAttachments(availableAttachment);
  }

  var topic = Topics().obs;
  void getTopicDetail() async {
    if(topicId.isNotEmpty) {
      await Mirrorfly.getTopics(topicIds: [topicId]).then((value) {
        var topics = topicsFromJson(value.toString());
        topic(topics.isNotEmpty ? topics[0] : null);
        //"a00251d7-d388-4f47-8672-553f8afc7e11","c640d387-8dfc-4252-b20a-d2901ebe3197","f5dc3456-cd2a-4e64-ad91-79373a867aa3","0075fe28-ec93-45c6-be3a-85004bf860a1","da757122-1a74-40ae-9c7d-0e4c2757e6bd","5d3788c1-78ef-4158-a92b-a48f092da0b9","4d83dfad-79a8-43fd-98b8-7eb8943dc8ca","0b290e7f-b05c-4859-a72d-100c48f73c8d","1ab018d1-1068-4988-8b28-fe1079e07ab2"
        LogMessage.d("getTopics by Id", value);
        LogMessage.d("getTopics [0] meta", "${topics[0].metaData}");
      }).catchError((onError) {
        LogMessage.d("getTopics error", onError);
      });
    }
  }

  @override
  void onHidden() {

  }

  void loadLastMessages(ChatMessageModel chatMessageModel) async{
    if(await Mirrorfly.hasNextMessages()) {
      _loadNextMessages(showLoading: false);
    }else{
      chatList.insert(0, chatMessageModel);
      sendReadReceipt();
    }
  }

  Future<void> loadPrevORNextMessagesLoad({bool? isReplyMessage}) async {
    if(await Mirrorfly.hasNextMessages()) {
      _loadNextMessages(showLoading: false,removeUnreadFromList: false);
    }
  }

  void handleUnreadMessageSeparator({bool remove = true,bool removeFromList = false}){
    var tuple3 = findIndexOfUnreadMessageType();
    var isUnreadSeparatorIsAvailable = tuple3.item1;
    var separatorPosition = tuple3.item2;
    if (isUnreadSeparatorIsAvailable && chatList.isNotEmpty) {
      if (remove) {
        removeUnreadMessageSeparator(separatorPosition,removeFromList: removeFromList);
      } else {
        displayUnreadMessageSeparator(separatorPosition);
      }
    }
  }

  void displayUnreadMessageSeparator(int separatorPosition) {
    var shouldNotCount = chatList.sublist(0 , separatorPosition + 1).where((it) => it.isMessageSentByMe).length;
    LogMessage.e("displayUnreadMessageSeparator", "should not count--->$shouldNotCount");

    var defaultUnreadCountResult = 0 + (separatorPosition);
    var shouldNotCountResult = defaultUnreadCountResult - shouldNotCount;
    LogMessage.e("displayUnreadMessageSeparator", "should Not Count Result--->$shouldNotCountResult");

    var noOfItemsAfterUnreadMessageSeparator = shouldNotCountResult!=0 ? shouldNotCountResult : chatList.length - separatorPosition - 1;
    if (noOfItemsAfterUnreadMessageSeparator != 0) {
      unreadCount(noOfItemsAfterUnreadMessageSeparator);
      var unreadMessageDetails = chatList[separatorPosition];
      if (chatList[separatorPosition].messageId == unreadMessageTypeMessageId) {
        unreadMessageDetails.messageTextContent = "$noOfItemsAfterUnreadMessageSeparator ${ (noOfItemsAfterUnreadMessageSeparator == 1) ? "UNREAD MESSAGE" : "UNREAD MESSAGES"}";
        // chatAdapter.notifyItemChanged(separatorPosition);
      }
    } else {
      handleUnreadMessageSeparator();
    }
  }

  void removeUnreadMessageSeparator(int separatorPosition,{bool removeFromList = true}){
    Mirrorfly.markAsReadDeleteUnreadSeparator(profile.jid.checkNull());
    if(removeFromList) {
      chatList.removeAt(separatorPosition);
    }
  }

  Tuple3<bool,int,String> findIndexOfUnreadMessageType() {
    LogMessage.d("TAG", "findIndexOfUnreadMessageType $unreadMessageTypeMessageId");
    var position = getMessagePosition(unreadMessageTypeMessageId);
    var message = Constants.emptyString;
    var isUnreadSeparatorIsAvailable = false;
    try {
      if (position != -1) {
        isUnreadSeparatorIsAvailable = true;
        message = chatList[position].messageTextContent.checkNull();
        // unReadMessageScrollPosition(position);
      }
      // if (position != -1 && lastVisiblePosition() == 0){
        // listChats.scrollToPosition(position + 1);
      // }

      // if (position == -1 && lastVisiblePosition() == (chatList.length - 2)) {
        // listChats.scrollToPosition(mainList.size - 1)
      // }
    } catch (e) {
      LogMessage.e("TAG", e.toString());
      return const Tuple3(false, 0, "");
    }
    LogMessage.d("findIndexOfUnreadMessageType", "$isUnreadSeparatorIsAvailable, $position, $message");
    return Tuple3(isUnreadSeparatorIsAvailable, position, message);
  }

  int getMessagePosition(String messageId) => chatList.indexWhere((it) => it.messageId == messageId);

  int lastVisiblePosition() {
    final itemPositions = newitemPositionsListener.itemPositions.value;
    final firstVisibleItemIndex = itemPositions.first.index;
    LogMessage.d("lastVisiblePosition", "$firstVisibleItemIndex");
    return firstVisibleItemIndex;
  }

  void unReadMessageScrollPosition(int position) {
    try {
      if(chatList.length > position){
        var sublist= chatList.sublist(position, chatList.length);
        if(sublist.length>3) {
          scrollToPosition(position + 3);
        } else {
          scrollToPosition(position + 1);
        }
      } else {
        scrollToPosition(position + 1);
      }
    } catch(e) {
      LogMessage.e("TAG",e.toString());
    }
  }

  void scrollToPosition(int position){
    if (!position.isNegative) {
      if (newScrollController.isAttached) {
        newScrollController.scrollTo(
            index: position,
            duration: const Duration(milliseconds: 100));
      }
    }
  }
}
