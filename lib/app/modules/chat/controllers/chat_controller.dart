import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart'
    as lib_phone_number;
import 'package:get/get.dart';

// import 'package:google_cloud_translation/google_cloud_translation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mirror_fly_demo/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:mirror_fly_demo/mention_text_field/mention_tag_text_field.dart';
import 'package:mirror_fly_demo/app/modules/chat/views/mention_list_view.dart';
import 'package:mirror_fly_demo/app/modules/chat/controllers/schedule_calender.dart';
import '../../../common/constants.dart';
import '../../../common/de_bouncer.dart';
import '../../../common/main_controller.dart';
import '../../../data/mention_utils.dart';
import '../../../data/permissions.dart';
import '../../../data/session_management.dart';
import '../../../extensions/extensions.dart';
import '../../../model/arguments.dart';
import '../../../modules/chat/views/edit_window.dart';
import '../../../modules/notification/notification_builder.dart';
import 'package:mirrorfly_plugin/edit_message_params.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tuple/tuple.dart';

import '../../../app_style_config.dart';
import '../../../call_modules/meet_sheet_view.dart';
import '../../../common/app_localizations.dart';
import '../../../common/widgets.dart';
import '../../../data/helper.dart';
import '../../../data/utils.dart';
import '../../../model/chat_message_model.dart';
import '../../../model/reply_hash_map.dart';
import '../../../routes/route_settings.dart';
import '../../../stylesheet/stylesheet.dart';
import '../../gallery_picker/src/data/models/picked_asset_model.dart';
import '../widgets/attachment_view.dart';
import '../widgets/image_cache_manager.dart';

class ChatController extends FullLifeCycleController
    with FullLifeCycleMixin, GetTickerProviderStateMixin {
  // final translator = Translation(apiKey: Constants.googleTranslateKey);
  // late final BuildContext buildContext;
  late final bool showChatDeliveryIndicator;
  var chatList = List<ChatMessageModel>.empty(growable: true).obs;
  late AnimationController controller;

  ItemScrollController? newScrollController;
  ItemPositionsListener? newItemPositionsListener;
  ItemScrollController? searchScrollController;

  late ChatMessageModel replyChatMessage;

  var isReplying = false.obs;

  var isUserTyping = false.obs;
  var isAudioRecording = Constants.audioRecordInitial.obs;
  Timer? _audioTimer;
  var timerInit = "00:00".obs;
  DateTime? startTime;

  late String audioSavePath;
  late String recordedAudioPath;
  late AudioRecorder record;
  bool _isDisposed = false;

  MentionTagTextEditingController messageController =
      MentionTagTextEditingController();
  MentionTagTextEditingController editMessageController =
      MentionTagTextEditingController();

  FocusNode focusNode = FocusNode();
  FocusNode searchfocusNode = FocusNode();

  var calendar = DateTime.now();
  var profile_ = ProfileDetails().obs;

  ChatController(this.arguments);

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

  final RxnBool _isMemberOfGroup = RxnBool(null);

  bool? get isMemberOfGroup {
    if (profile.isGroupProfile == true) {
      if (!availableFeatures.value.isGroupChatAvailable.checkNull()) {
        return false;
      }
      return _isMemberOfGroup.value; // could be true, false, or null
    } else {
      return true;
    }
  }

  bool get ableToCall => profile.isGroupProfile.checkNull()
      ? isMemberOfGroup.checkNull()
      : (!profile.isBlocked.checkNull() && !profile.isAdminBlocked.checkNull());

  bool get ableToScheduleMeet => profile.isGroupProfile ?? false
      ? availableFeatures.value.isGroupChatAvailable.checkNull() &&
          _isMemberOfGroup.value.checkNull()
      : true;
  // var profileDetail = Profile();

  String nJid = Constants.emptyString;
  String? starredChatMessageId;
  String unreadMessageTypeMessageId = Constants.emptyString;

  bool get isTrail => !Constants.enableContactSync;

  var showLoadingNext = false.obs;
  var showLoadingPrevious = false.obs;

  final deBouncer = DeBouncer(milliseconds: 1000);

  var topicId = Constants.topicId;
  var availableFeatures = AvailableFeatures().obs;
  RxList<AttachmentIcon> availableAttachments = <AttachmentIcon>[].obs;

  bool get isAudioCallAvailable => profile.isGroupProfile.checkNull()
      ? availableFeatures.value.isGroupCallAvailable.checkNull()
      : availableFeatures.value.isOneToOneCallAvailable.checkNull();

  bool get isVideoCallAvailable => profile.isGroupProfile.checkNull()
      ? availableFeatures.value.isGroupCallAvailable.checkNull()
      : availableFeatures.value.isOneToOneCallAvailable.checkNull();

  RxString editMessageText = ''.obs;

  //#metaData
  List<MessageMetaData> messageMetaData =
      []; //[MessageMetaData(key: "platform", value: "flutter")];
  final ChatViewArguments? arguments;

/*  var screenWidth = 0.0.obs;
  var screenHeight = 0.0.obs;*/
  Rx<Offset> fabPosition = Offset.zero.obs;
  RxBool isDraggingFab = false.obs;

  RxDouble screenWidth = 0.0.obs;
  RxDouble screenHeight = 0.0.obs;
  RxDouble fabHeight = 60.0.obs;
  RxDouble margin = 16.0.obs;
  RxDouble safeTop = 10.0.obs;

  void updateFabPosition(Offset newOffset) {
    double fabWidth = 56.0;
    double fabHeight = 56.0;

    double newX = newOffset.dx.clamp(0.0, screenWidth.value - fabWidth);
    double newY = newOffset.dy.clamp(0.0, screenHeight.value - fabHeight - 16);

    newX =
        newX < screenWidth.value / 2 ? 15 : screenWidth.value - fabWidth - 15;
    newY = newY.clamp(5, screenHeight.value - fabHeight - 16);

    fabPosition.value = Offset(newX, newY);
  }

  @override
  Future<void> onInit() async {
    // arguments = NavUtils.arguments as ChatViewArguments;
    // buildContext = context;
    showChatDeliveryIndicator = arguments?.showChatDeliveryIndicator ?? true;

    getAvailableFeatures();

    if ((arguments?.topicId).checkNull().isNotEmpty) {
      topicId = arguments!.topicId;
      getTopicDetail();
    }

    if ((arguments?.chatJid).checkNull().isNotEmpty) {
      nJid = arguments!.chatJid;
      debugPrint("parameter :${arguments!.chatJid}");
    }

    if (arguments?.messageId != null) {
      starredChatMessageId = arguments!.messageId;
    }
    SessionManagement.setCurrentChatJID(nJid.checkNull());
    await getChatProfile();

    setAudioPath();

    filteredPosition.bindStream(filteredPosition.stream);
    ever(filteredPosition, (callback) {
      lastPosition(callback.length);
      //chatList.refresh();
    });
    super.onInit();
  }

  var chatProfileCalled = false;
  Future<void> getChatProfile() async {
    if (Mirrorfly.isValidGroupJid(nJid)) {
      await Mirrorfly.getGroupProfile(
          groupJid: nJid.checkNull(),
          fetchFromServer: await AppUtils.isNetConnected(),
          flyCallBack: (FlyResponse response) async {
            if (response.isSuccess) {
              debugPrint("getGroupProfileDetails--> $response");
              var profile = ProfileDetails.fromJson(
                  json.decode(response.data.toString()));
              await initializeProfile(profile);
            } else {
              debugPrint("getGroupProfileDetails--> ${response.errorMessage}");
            }
          });
    } else {
      await getProfileDetails(nJid).then((value) async {
        LogMessage.d("chatController getProfileDetails", value.toJson());
        await initializeProfile(value);
      });
    }
  }

  Future<void> initializeProfile(ProfileDetails profile) async {
    chatProfileCalled = true;
    profile_(profile);

    //make unreadMessageTypeMessageId
    if (Platform.isAndroid) {
      unreadMessageTypeMessageId = "M${profile.jid.checkNull()}";
    } else if (Platform.isIOS) {
      unreadMessageTypeMessageId =
          "M_${getMobileNumberFromJid(profile.jid.checkNull())}";
    }
    checkAdminBlocked();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      newScrollController = ItemScrollController();
      newItemPositionsListener = ItemPositionsListener.create();
      searchScrollController = ItemScrollController();
      ready();
    });

    setAudioPath();

    filteredPosition.bindStream(filteredPosition.stream);
    ever(filteredPosition, (callback) {
      lastPosition(callback.length);
      //chatList.refresh();
    });
    super.onInit();
  }

  void getAvailableFeatures() {
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
    memberOfGroup();
    setChatStatus();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        showEmoji(false);
      }
    });
    newItemPositionsListener?.itemPositions.addListener(() {
      var pos = lastVisiblePosition();
      if (pos >= 1) {
        showHideRedirectToLatest(true);
      } else {
        showHideRedirectToLatest(false);
        unreadCount(0);
      }
    });

    setOnGoingUserAvail();
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
      if (newScrollController != null &&
          newScrollController!.isAttached &&
          lastVisiblePosition() >= 1) {
        LogMessage.d("newScrollController", "scrollToBottom");
        newScrollController?.scrollTo(
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
    LogMessage.d("newScrollController", "scrollToEnd");
    if (newScrollController != null && newScrollController!.isAttached) {
      newScrollController?.jumpTo(index: 0);
    }
    // newScrollController.jumpTo(0);
    showHideRedirectToLatest(false);
  }

  @override
  void onClose() {
    debugPrint("onClose");
    messageController.dispose();
    saveUnsentMessage();
    setOnGoingUserGone();
    ImageCacheManager.disposeCache();
    super.onClose();
  }

  @override
  void dispose() {
    LogMessage.d("dispose", "Chat controller");
    super.dispose();
  }

  clearMessage() {
    if (profile.jid.checkNull().isNotEmpty) {
      Mirrorfly.saveUnsentMessage(
          jid: profile.jid.checkNull(), message: Constants.emptyString);
      ReplyHashMap.saveReplyId(profile.jid.checkNull(), Constants.emptyString);
    }
  }

  void saveUnsentMessage() {
    if (profile.jid.checkNull().isNotEmpty) {
      Mirrorfly.saveUnsentMessage(
          jid: profile.jid.checkNull(),
          message: messageController.formattedText.trim().toString(),
          mentionedUsers: messageController.getTags);
    }
    if (isReplying.value) {
      ReplyHashMap.saveReplyId(
          profile.jid.checkNull(), replyChatMessage.messageId);
    }
  }

  void getUnsentMessageOfAJid() async {
    if (profile.jid.checkNull().isNotEmpty) {
      Mirrorfly.getUnsentMessageOf(jid: profile.jid.checkNull()).then((value) {
        if (value != null) {
          //{"mentionedUsers":["8000800080@xmpp-uikit-qa.contus.us"],"textContent":"@Flutter"}
          log(value,
              name:
                  "getUnsentMessageOf"); //{"mentionedUsers":[],"textContent":""}
          var data = json.decode(value.toString());
          var content = data["textContent"];
          var mentionedUsers =
              List<String>.from(data["mentionedUsers"].map((x) => x));
          setUnSentMessageInTextField(
              messageController, content, mentionedUsers);
        } else {
          messageController.text = Constants.emptyString;
        }
      });
    }
  }

  Future<void> setUnSentMessageInTextField(
      MentionTagTextEditingController controller,
      String content,
      List<String> mentionedUsers) async {
    if (content.isNotEmpty) {
      var profileDetails =
          await MentionUtils.getProfileDetailsOfUsername(mentionedUsers);
      controller.setCustomText(content, profileDetails);
      isUserTyping(true);
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
    await hideEmojiKeyboardWhenClickOnAttachments();
    var busyStatus = !profile.isGroupProfile.checkNull()
        ? await Mirrorfly.isBusyStatusEnabled()
        : false;
    if (!busyStatus.checkNull()) {
      focusNode.unfocus();
      showBottomSheetAttachment();
    } else {
      //show busy status popup
      showBusyStatusAlert(showBottomSheetAttachment);
    }
  }

  Future<void> hideEmojiKeyboardWhenClickOnAttachments() async {
    if (showEmoji.value) {
      showEmoji(!showEmoji.value);
    }
  }

  showBottomSheetAttachment() {
    DialogUtils.bottomSheet(
      Container(
          margin: const EdgeInsets.only(right: 18.0, left: 18.0, bottom: 50),
          child: BottomSheet(
              onClosing: () {},
              backgroundColor: Colors.transparent,
              shape:
                  AppStyleConfig.chatPageStyle.attachmentViewStyle.shapeBorder,
              builder: (builder) => AttachmentsSheetView(
                  attachments: availableAttachments,
                  availableFeatures: availableFeatures,
                  onDocument: () {
                    NavUtils.back();
                    documentPickUpload();
                  },
                  onCamera: () {
                    NavUtils.back();
                    onCameraClick();
                  },
                  onGallery: () {
                    NavUtils.back();
                    onGalleryClick();
                  },
                  onAudio: () {
                    NavUtils.back();
                    onAudioClick();
                  },
                  onContact: () {
                    NavUtils.back();
                    onContactClick();
                  },
                  onLocation: () {
                    NavUtils.back();
                    onLocationClick();
                  }))),
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
      var replyMessageId = Constants.emptyString;

      if (isReplying.value) {
        replyMessageId = replyChatMessage.messageId;
      }
      isReplying(false);
      if (messageController.text.trim().isNotEmpty) {
        //old method is deprecated Instead of use below new method
        /*Mirrorfly.sendTextMessage(messageController.text.trim(),
            profile.jid.toString(),replyMessageId,topicId: topicId)
            .then((value) {
          LogMessage.d("text message", value);
          messageController.text = "";
          isUserTyping(false);
          clearMessage();
          ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
          LogMessage.d(
              "inserting chat message",
              chatMessageModel.replyParentChatMessage?.messageType ??
                  "value is null");
          // chatList.insert(0, chatMessageModel);
          scrollToBottom();
          updateLastMessage(value);
        });*/
        LogMessage.d("send text sending-->",
            "${messageController.formattedText} mention : ${messageController.getTags}");
        Mirrorfly.sendMessage(
            messageParams: MessageParams.text(
                toJid: profile.jid.checkNull(),
                replyMessageId: replyMessageId,
                mentionedUsersIds: messageController.getTags,
                topicId: topicId,
                messageSecurityMode: MessageSecurityMode.disabled,
                metaData: messageMetaData,
                textMessageParams: TextMessageParams(
                    messageText: messageController.formattedText.trim())),
            flyCallback: (response) {
              if (response.isSuccess) {
                LogMessage.d("text message", response.data);
                messageController.text = Constants.emptyString;
                isUserTyping(false);
                // clearMessage();
                scrollToBottom();
                updateLastMessage(response.data);
              } else {
                LogMessage.d("sendMessage", response.errorMessage);
                showError(response.exception);
              }
            });
      }
    } else {
      //show busy status popup
      messageObject = MessageObject(
          toJid: profile.jid.toString(),
          replyMessageId: (isReplying.value)
              ? replyChatMessage.messageId
              : Constants.emptyString,
          messageType: Constants.mText,
          textMessage: messageController.formattedText.trim());
      showBusyStatusAlert(disableBusyChatAndSend);
    }
  }

  showBusyStatusAlert(Function? function) {
    DialogUtils.showAlert(
        dialogStyle: AppStyleConfig.dialogStyle,
        message: getTranslated("disableBusy"),
        actions: [
          TextButton(
              style: AppStyleConfig.dialogStyle.buttonStyle,
              onPressed: () {
                NavUtils.back();
              },
              child: Text(getTranslated("no"))),
          TextButton(
              style: AppStyleConfig.dialogStyle.buttonStyle,
              onPressed: () async {
                NavUtils.back();
                await Mirrorfly.enableDisableBusyStatus(
                    enable: false,
                    flyCallBack: (FlyResponse response) {
                      if (response.isSuccess) {
                        if (function != null) {
                          function();
                        }
                      }
                    });
              },
              child: Text(getTranslated("yes"))),
        ]);
  }

  Future<void> setMeetBottomSheet() async {
    bool? busyStatus;
    if (!(profile.isGroupProfile.checkNull())) {
      busyStatus = await Mirrorfly.isBusyStatusEnabled();
      debugPrint(busyStatus.toString());
    }

    if (busyStatus.checkNull()) {
      showBusyStatusAlert(() async {
        await ScheduleCalender().requestCalendarPermission();
        showMeetBottomSheet(
            meetBottomSheetStyle: AppStyleConfig
                .chatPageStyle.instantScheduleMeetStyle.meetBottomSheetStyle,
            isEnableSchedule: true);
      });
    } else {
      await ScheduleCalender().requestCalendarPermission();
      showMeetBottomSheet(
          meetBottomSheetStyle: AppStyleConfig
              .chatPageStyle.instantScheduleMeetStyle.meetBottomSheetStyle,
          isEnableSchedule: true);
    }
  }

  showBlockStatusAlert(Function? function) {
    DialogUtils.showAlert(
        dialogStyle: AppStyleConfig.dialogStyle,
        message: getTranslated("unBlockToSendMsg"),
        actions: [
          TextButton(
              style: AppStyleConfig.dialogStyle.buttonStyle,
              onPressed: () {
                NavUtils.back();
              },
              child: Text(
                getTranslated("cancel").toUpperCase(),
              )),
          TextButton(
              style: AppStyleConfig.dialogStyle.buttonStyle,
              onPressed: () async {
                NavUtils.back();
                Mirrorfly.unblockUser(
                    userJid: profile.jid!,
                    flyCallBack: (FlyResponse response) {
                      if (response.isSuccess) {
                        debugPrint(response.toString());
                        profile.isBlocked = false;
                        isBlocked(false);
                        DialogUtils.hideLoading();
                        toToast(getTranslated("hasUnBlocked")
                            .replaceFirst("%d", getName(profile)));
                        if (function != null) {
                          function();
                        }
                      } else {
                        toToast(response.errorMessage);
                      }
                    });
              },
              child: Text(
                getTranslated("unblock").toUpperCase(),
              )),
        ]);
  }

  disableBusyChatAndSend() async {
    if (messageObject != null) {
      switch (messageObject!.messageType) {
        case Constants.mText:
          sendMessage(profile);
          break;
        case Constants.mImage:
          sendImageMessage(
              messageObject!.file!,
              messageObject!.caption!,
              messageObject!.replyMessageId!,
              messageObject!.mentionedUsersIds ?? []);
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
          sendVideoMessage(
              messageObject!.file!,
              messageObject!.caption!,
              messageObject!.replyMessageId!,
              messageObject!.mentionedUsersIds ?? []);
          break;
      }
    }
  }

  sendLocationMessage(
      ProfileDetails profile, double latitude, double longitude) async {
    if (!availableFeatures.value.isLocationAttachmentAvailable.checkNull()) {
      DialogUtils.showFeatureUnavailable();
      return;
    }
    var busyStatus = !profile.isGroupProfile.checkNull()
        ? await Mirrorfly.isBusyStatusEnabled()
        : false;
    if (!busyStatus.checkNull()) {
      var replyMessageId = Constants.emptyString;
      if (isReplying.value) {
        replyMessageId = replyChatMessage.messageId;
      }
      isReplying(false);
      //old method is deprecated Instead of use below new method
      /*Mirrorfly.sendLocationMessage(
          profile.jid.toString(), latitude, longitude, replyMessageId,topicId: topicId)
          .then((value) {
        LogMessage.d("Location_msg", value.toString());
        // ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
        // chatList.insert(0, chatMessageModel);
        scrollToBottom();
        updateLastMessage(value);
      });*/
      Mirrorfly.sendMessage(
          messageParams: MessageParams.location(
              toJid: profile.jid.checkNull(),
              replyMessageId: replyMessageId,
              topicId: topicId,
              metaData: messageMetaData,
              //#metaData
              locationMessageParams: LocationMessageParams(
                  latitude: latitude, longitude: longitude)),
          flyCallback: (response) {
            if (response.isSuccess) {
              LogMessage.d("location message", response.data.toString());
              scrollToBottom();
              updateLastMessage(response.data);
            } else {
              LogMessage.d("sendMessage", response.errorMessage);
              showError(response.exception);
            }
          });
    } else {
      //show busy status popup
      messageObject = MessageObject(
          toJid: profile.jid.toString(),
          replyMessageId: (isReplying.value)
              ? replyChatMessage.messageId
              : Constants.emptyString,
          messageType: Constants.mLocation,
          latitude: latitude,
          longitude: longitude);
      showBusyStatusAlert(disableBusyChatAndSend);
    }
  }

  RxBool chatLoading = true.obs;

  var initializedMessageList = false;

  void _loadMessages() {
    // getChatHistory();
    Mirrorfly.initializeMessageList(
      userJid: profile.jid.checkNull(),
      limit: 20,
      topicId: topicId,
      messageId: starredChatMessageId,
      exclude: starredChatMessageId != null ? false : true,
      ascendingOrder: starredChatMessageId != null,
    ) //message
        .then((value) {
      if (value) {
        initializedMessageList = true;
        Mirrorfly.loadMessages(flyCallback: (FlyResponse response) {
          showLoadingNext(false);
          showLoadingPrevious(false);
          if (response.isSuccess && response.hasData) {
            // LogMessage.d("loadMessages", response.data);
            List<ChatMessageModel> chatMessageModel =
                chatMessageModelFromJson(response.data);
            chatList(chatMessageModel.reversed.toList());
            showStarredMessage();
            sendReadReceipt(removeUnreadFromList: false);
            loadPrevORNextMessagesLoad();
            if (chatList.isNotEmpty &&
                chatList[0].messageTextContent == Constants.chatClosed) {
              isChatClosed(true);
            } else {
              isChatClosed(false);
            }
          }
          chatLoading(false);
        });
      } else {
        initializedMessageList = false;
        chatLoading(false);
        toToast(getTranslated("chatHistoryNotInit"));
      }
    });
  }

  Future<void> _loadPreviousMessages({bool showLoading = true}) async {
    // if (showLoading) {
    //   showLoadingPrevious(await Mirrorfly.hasPreviousMessages());
    // } else {
    showLoadingPrevious(showLoading);
    // }
    // showLoadingPrevious(await Mirrorfly.hasPreviousMessages());
    Mirrorfly.loadPreviousMessages(flyCallback: (FlyResponse response) {
      // LogMessage.d("loadPreviousMessages", response);
      if (response.isSuccess && response.hasData) {
        var chatMessageModel = List<ChatMessageModel>.empty(growable: true).obs;
        chatMessageModel.addAll(chatMessageModelFromJson(response.data));
        if (chatMessageModel.toList().isNotEmpty) {
          chatList.insertAll(
              chatList.length, chatMessageModel.reversed.toList());
        } else {
          debugPrint("chat list is empty");
        }
        showStarredMessage();
        sendReadReceipt();
      }
      showLoadingPrevious(false);
    });
  }

  Future<void> _loadNextMessages(
      {bool showLoading = true, bool removeUnreadFromList = true}) async {
    // if (showLoading) {
    //   showLoadingNext(await Mirrorfly.hasNextMessages());
    // } else {
    showLoadingNext(showLoading);
    // }
    Mirrorfly.loadNextMessages(flyCallback: (FlyResponse response) {
      if (response.isSuccess && response.hasData) {
        List<ChatMessageModel> chatMessageModel =
            chatMessageModelFromJson(response.data);
        if (chatMessageModel.isNotEmpty) {
          if (chatList.isNotEmpty) {
            chatList.insertAll(0, chatMessageModel.reversed.toList());
            if (chatList.isNotEmpty &&
                chatList[0].messageTextContent == Constants.chatClosed) {
              isChatClosed(true);
            } else {
              isChatClosed(false);
            }
          } else {
            chatList(chatMessageModel.reversed.toList());
          }
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
          navigateToMessage(chatList[chat], index: chat);
          starredChatMessageId = null;
        } else {
          toToast(getTranslated("messageNotFound"));
        }
      }
      getUnsentReplyMessage();
    });
  }

  sendImageMessage(String? path, String? caption, String? replyMessageID,
      List<String> mentionedUsersIds) async {
    if (!availableFeatures.value.isImageAttachmentAvailable.checkNull()) {
      DialogUtils.showFeatureUnavailable();
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
        //old method is deprecated Instead of use below new method
        /*return Mirrorfly.sendImageMessage(
            profile.jid!, path, caption, replyMessageID,topicId: topicId)
            .then((value) {
          clearMessage();
          ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
          // chatList.insert(0, chatMessageModel);
          scrollToBottom();
          updateLastMessage(value);
          return chatMessageModel;
        });*/
        return Mirrorfly.sendMessage(
            messageParams: MessageParams.image(
                toJid: profile.jid.checkNull(),
                replyMessageId: replyMessageID,
                topicId: topicId,
                metaData: messageMetaData,
                mentionedUsersIds: mentionedUsersIds,
                //#metaData
                fileMessageParams:
                    FileMessageParams(file: File(path), caption: caption)),
            flyCallback: (response) {
              if (response.isSuccess) {
                LogMessage.d("image message", response.data.toString());
                // clearMessage();
                messageController.text = Constants.emptyString;
                ChatMessageModel chatMessageModel =
                    sendMessageModelFromJson(response.data);
                // chatList.insert(0, chatMessageModel);
                scrollToBottom();
                updateLastMessage(response.data);
                return chatMessageModel;
              } else {
                LogMessage.d("sendMessage", response.errorMessage);
                showError(response.exception);
              }
            });
      } else {
        debugPrint("file not found for upload");
      }
    } else {
      //show busy status popup
      messageObject = MessageObject(
          toJid: profile.jid.toString(),
          replyMessageId: (isReplying.value)
              ? replyChatMessage.messageId
              : Constants.emptyString,
          messageType: Constants.mImage,
          file: path,
          caption: caption,
          mentionedUsersIds: mentionedUsersIds);
      showBusyStatusAlert(disableBusyChatAndSend);
    }
  }

  documentPickUpload() async {
    if (!availableFeatures.value.isDocumentAttachmentAvailable.checkNull()) {
      DialogUtils.showFeatureUnavailable();
      return;
    }
    // var permission = await AppPermission.getStoragePermission();
    // if (permission) {
    setOnGoingUserGone();
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'ppt', 'xls', 'doc', 'docx', 'xlsx', 'txt', 'zip', 'rar', 'pptx'],
    );
    if (result != null && File(result.files.single.path!).existsSync()) {
      if (MediaUtils.checkFileUploadSize(
          result.files.single.path!, Constants.mDocument)) {
        debugPrint("sendDoc ${result.files.first.extension}");
        Future.delayed(const Duration(seconds: 1), () {
          filePath.value = (result.files.single.path!);
          sendDocumentMessage(filePath.value, Constants.emptyString);
        });
      } else {
        toToast(getTranslated("mediaMaxLimitRestriction")
            .replaceAll("%d", "${MediaUtils.maxDocFileSize}"));
      }
      setOnGoingUserAvail();
    } else {
      // User canceled the picker
      setOnGoingUserAvail();
    }
    // }
  }

  sendReadReceipt({bool removeUnreadFromList = true}) {
    LogMessage.d("ChatController", "sendReadReceipt");
    markConversationReadNotifyUI();
    handleUnreadMessageSeparator(
        remove: true,
        removeFromList: removeUnreadFromList); //lastVisiblePosition()==0
  }

  sendVideoMessage(String videoPath, String caption, String replyMessageID,
      List<String> mentionedUsersIds) async {
    if (!availableFeatures.value.isVideoAttachmentAvailable.checkNull()) {
      DialogUtils.showFeatureUnavailable();
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
      Platform.isIOS
          ? DialogUtils.showLoading(
              message: getTranslated("compressingVideo"),
              dialogStyle: AppStyleConfig.dialogStyle)
          : null;
      //old method is deprecated Instead of use below new method
      /*return Mirrorfly.sendVideoMessage(
          profile.jid!, videoPath, caption, replyMessageID,topicId: topicId)
          .then((value) {
        clearMessage();
        Platform.isIOS ? DialogUtils.hideLoading() : null;
        ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
        // chatList.insert(0, chatMessageModel);
        scrollToBottom();
        updateLastMessage(value);
        return chatMessageModel;
      });*/
      return Mirrorfly.sendMessage(
          messageParams: MessageParams.video(
              toJid: profile.jid.checkNull(),
              replyMessageId: replyMessageID,
              topicId: topicId,
              metaData: messageMetaData,
              //#metaData
              mentionedUsersIds: mentionedUsersIds,
              fileMessageParams:
                  FileMessageParams(file: File(videoPath), caption: caption)),
          flyCallback: (response) {
            if (response.isSuccess) {
              LogMessage.d("video message", response.data.toString());
              // clearMessage();
              messageController.text = Constants.emptyString;
              Platform.isIOS ? DialogUtils.hideLoading() : null;
              ChatMessageModel chatMessageModel =
                  sendMessageModelFromJson(response.data);
              // chatList.insert(0, chatMessageModel);
              scrollToBottom();
              updateLastMessage(response.data);
              return chatMessageModel;
            } else {
              LogMessage.d("sendMessage", response.errorMessage);
              //PlatformException(500, Not enough storage space on your device. Please free up space in your phone's memory. ErrorCode => 808, com.mirrorflysdk.flycommons.exception.FlyException: Not enough storage space on your device. Please free up space in your phone's memory. ErrorCode => 808
              showError(response.exception);
            }
          });
    } else {
      //show busy status popup
      messageObject = MessageObject(
          toJid: profile.jid.toString(),
          replyMessageId: (isReplying.value)
              ? replyChatMessage.messageId
              : Constants.emptyString,
          messageType: Constants.mVideo,
          file: videoPath,
          caption: caption,
          mentionedUsersIds: mentionedUsersIds);
      showBusyStatusAlert(disableBusyChatAndSend);
    }
  }

  checkFile(String mediaLocalStoragePath) {
    return mediaLocalStoragePath.isNotEmpty &&
        File(mediaLocalStoragePath).existsSync();
  }

  ChatMessageModel? playingChat;

  sendContactMessage(List<String> contactList, String contactName) async {
    if (!availableFeatures.value.isContactAttachmentAvailable.checkNull()) {
      DialogUtils.showFeatureUnavailable();
      return;
    }
    debugPrint("sendingName--> $contactName");
    var busyStatus = !profile.isGroupProfile.checkNull()
        ? await Mirrorfly.isBusyStatusEnabled()
        : false;
    debugPrint("sendContactMessage busyStatus--> $busyStatus");
    if (!busyStatus.checkNull()) {
      debugPrint("busy status not enabled");
      var replyMessageId = Constants.emptyString;

      if (isReplying.value) {
        replyMessageId = replyChatMessage.messageId;
      }
      isReplying(false);
      //old method is deprecated Instead of use below new method
      /*return Mirrorfly.sendContactMessage(
          contactList, profile.jid!, contactName, replyMessageId,topicId: topicId)
          .then((value) {
        debugPrint("response--> $value");
        ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
        // chatList.insert(0, chatMessageModel);
        scrollToBottom();
        updateLastMessage(value);
        return chatMessageModel;
      });*/
      return Mirrorfly.sendMessage(
          messageParams: MessageParams.contact(
              toJid: profile.jid.checkNull(),
              replyMessageId: replyMessageId,
              topicId: topicId,
              metaData: messageMetaData,
              //#metaData
              contactMessageParams: ContactMessageParams(
                  name: contactName, numbers: contactList)),
          flyCallback: (response) {
            if (response.isSuccess) {
              LogMessage.d("contact message", response.data.toString());
              debugPrint("response--> ${response.data}");
              scrollToBottom();
              updateLastMessage(response.data);
            } else {
              LogMessage.d("sendMessage", response.errorMessage);
              showError(response.exception);
            }
          });
    } else {
      //show busy status popup
      messageObject = MessageObject(
          toJid: profile.jid.toString(),
          replyMessageId: (isReplying.value)
              ? replyChatMessage.messageId
              : Constants.emptyString,
          messageType: Constants.mContact,
          contactNumbers: contactList,
          contactName: contactName);
      showBusyStatusAlert(disableBusyChatAndSend);
    }
  }

  sendDocumentMessage(String documentPath, String replyMessageId) async {
    if (!availableFeatures.value.isDocumentAttachmentAvailable.checkNull()) {
      DialogUtils.showFeatureUnavailable();
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
      //old method is deprecated Instead of use below new method
      /*Mirrorfly.sendDocumentMessage(profile.jid!, documentPath, replyMessageId,topicId: topicId)
          .then((value) {
        ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
        // chatList.insert(0, chatMessageModel);
        scrollToBottom();
        updateLastMessage(value);
        return chatMessageModel;
      });*/
      Mirrorfly.sendMessage(
          messageParams: MessageParams.document(
              toJid: profile.jid.checkNull(),
              replyMessageId: replyMessageId,
              topicId: topicId,
              metaData: messageMetaData,
              //#metaData
              fileMessageParams: FileMessageParams(file: File(documentPath))),
          flyCallback: (response) {
            if (response.isSuccess) {
              LogMessage.d("document message", response.data.toString());
              scrollToBottom();
              updateLastMessage(response.data);
            } else {
              LogMessage.d("sendMessage", response.errorMessage);
              showError(response.exception);
            }
          });
    } else {
      //show busy status popup
      messageObject = MessageObject(
          toJid: profile.jid.toString(),
          replyMessageId: (isReplying.value)
              ? replyChatMessage.messageId
              : Constants.emptyString,
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
        if (MediaUtils.checkFileUploadSize(
            result.files.single.path!, Constants.mAudio)) {
          AudioPlayer player = AudioPlayer();
          // player.setUrl(result.files.single.path!);
          player.setSourceDeviceFile(
              result.files.single.path ?? Constants.emptyString);
          player.onDurationChanged.listen((Duration duration) {
            LogMessage.d("", 'max duration: ${duration.inMilliseconds}');
            Future.delayed(const Duration(seconds: 1), () {
              filePath.value = (result.files.single.path!);
              sendAudioMessage(
                  filePath.value, false, duration.inMilliseconds.toString());
            });
          });
        } else {
          toToast(getTranslated("mediaMaxLimitRestriction")
              .replaceAll("%d", "${MediaUtils.maxAudioFileSize}"));
        }
        setOnGoingUserAvail();
      } else {
        // User canceled the picker
        setOnGoingUserAvail();
      }
    } else {
      ///sometimes FilePicker's path not receiving with its file extension in Android
      ///so we are adding this below method internally
      await Mirrorfly.openAudioFilePicker().then((value) {
        if (value != null) {
          if (MediaUtils.checkFileUploadSize(value, Constants.mAudio)) {
            AudioPlayer player = AudioPlayer();
            // player.setUrl(value);
            player.setSourceDeviceFile(value);
            player.onDurationChanged.listen((Duration duration) {
              LogMessage.d("", 'max duration: ${duration.inMilliseconds}');
              Future.delayed(const Duration(seconds: 1), () {
                filePath.value = (value);
                sendAudioMessage(
                    filePath.value, false, duration.inMilliseconds.toString());
              });
            });
          } else {
            toToast(getTranslated("mediaMaxLimitRestriction")
                .replaceAll("%d", "${MediaUtils.maxAudioFileSize}"));
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
    if (!availableFeatures.value.isAudioAttachmentAvailable.checkNull()) {
      DialogUtils.showFeatureUnavailable();
      return;
    }
    var busyStatus = !profile.isGroupProfile.checkNull()
        ? await Mirrorfly.isBusyStatusEnabled()
        : false;
    if (!busyStatus.checkNull()) {
      var replyMessageId = Constants.emptyString;

      if (isReplying.value) {
        replyMessageId = replyChatMessage.messageId;
      }

      isUserTyping(messageController.text.trim().isNotEmpty);
      isReplying(false);
      //old method is deprecated Instead of use below new method
      /*Mirrorfly.sendAudioMessage(
          profile.jid!, filePath, isRecorded, duration, replyMessageId,topicId: topicId)
          .then((value) {
        LogMessage.d("Audio Message sent", value);
        ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
        // chatList.insert(0, chatMessageModel);
        scrollToBottom();
        updateLastMessage(value);
        return chatMessageModel;
      });*/
      Mirrorfly.sendMessage(
          messageParams: MessageParams.audio(
              toJid: profile.jid.checkNull(),
              isRecorded: isRecorded,
              replyMessageId: replyMessageId,
              topicId: topicId,
              metaData: messageMetaData,
              //#metaData
              fileMessageParams: FileMessageParams(file: File(filePath))),
          flyCallback: (response) {
            if (response.isSuccess) {
              LogMessage.d("audio Message", response.data);
              scrollToBottom();
              updateLastMessage(response.data);
            } else {
              LogMessage.d("sendMessage", response.errorMessage);
              showError(response.exception);
            }
          });
    } else {
      //show busy status popup
      messageObject = MessageObject(
          toJid: profile.jid.toString(),
          replyMessageId: (isReplying.value)
              ? replyChatMessage.messageId
              : Constants.emptyString,
          messageType: Constants.mAudio,
          file: filePath,
          isAudioRecorded: isRecorded,
          audioDuration: duration);
      showBusyStatusAlert(disableBusyChatAndSend);
    }
  }

  Future<void> sendMeetMessage(
      {required String link, required int scheduledDateTime}) async {
    String calenderId = await SessionManagement.getCalenderId("calenderId");
    if (calenderId.isEmpty) {
      await ScheduleCalender().selectCalendarId();
    }
    var replyMessageId = Constants.emptyString;
    if (isReplying.value) {
      replyMessageId = replyChatMessage.messageId;
    }
    isReplying(false);
    Mirrorfly.sendMessage(
        messageParams: MessageParams.meet(
          toJid: profile.jid.checkNull(),
          topicId: topicId,
          metaData: messageMetaData,
          replyMessageId: replyMessageId,
          meetMessageParams: MeetMessage(
              scheduledDateTime: scheduledDateTime,
              link: Constants.webChatLogin + link,
              title: ""),
        ),
        flyCallback: (response) {
          if (response.isSuccess) {
            LogMessage.d("meet Message", response.data);
            ChatMessageModel chatMessageModel =
                sendMessageModelFromJson(response.data);
            ScheduleCalender().addEvent(chatMessageModel.meetChatMessage!);
            scrollToBottom();
            updateLastMessage(response.data);
          } else {
            LogMessage.d("sendMessage", response.errorMessage);
            showError(response.exception);
          }
        }) /*.then((value) => NavUtils.back())*/;
  }

  void isTyping([String? typingText]) {
    LogMessage.d("isTyping", typingText.toString());
    isUserTyping(messageController.text.trim().isNotEmpty);
    sendUserTypingStatus();
    debugPrint('User is typing');
    deBouncer.cancel();
    deBouncer.run(() {
      debugPrint("DeBouncer");
      sendUserTypingGoneStatus();
    });
  }

  var showMentionUsers = true;

  clearChatHistory(bool isStarredExcluded) {
    if (!availableFeatures.value.isClearChatAvailable.checkNull()) {
      DialogUtils.showFeatureUnavailable();
      return;
    }
    Mirrorfly.clearChat(
        jid: profile.jid!,
        chatType: profile.isGroupProfile.checkNull() ? "groupchat" : "chat",
        clearExceptStarred: isStarredExcluded,
        flyCallBack: (FlyResponse response) {
          LogMessage.d("clearChat response", response.toString());
          if (response.isSuccess) {
            // var chatListrev = chatList.reversed;
            isStarredExcluded
                ? chatList
                    .removeWhere((p0) => p0.isMessageStarred.value == false)
                : chatList.clear();
            cancelReplyMessage();
            onMessageDeleteNotifyUI(
                chatJid: profile.jid.checkNull(), changePosition: false);
          } else {
            toToast(getErrorDetails(response));
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
    ReplyHashMap.saveReplyId(profile.jid.checkNull(), Constants.emptyString);
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
    } else {
      debugPrint("Unable to Select Notification Banner");
    }
    getMessageActions();
  }

  //Report Chat or User
  reportChatOrMessage() {
    Future.delayed(const Duration(milliseconds: 100), () async {
      var chatMessage =
          selectedChatList.isNotEmpty ? selectedChatList[0] : null;
      DialogUtils.showAlert(
          dialogStyle: AppStyleConfig.dialogStyle,
          title: getTranslated("report").replaceFirst("%d", getName(profile)),
          message:
              "${selectedChatList.isNotEmpty ? getTranslated("thisMessageForwardToAdmin") : getTranslated("last5MessageForwardToAdmin")} ${getTranslated("contactWillBeNotified")}",
          actions: [
            TextButton(
                style: AppStyleConfig.dialogStyle.buttonStyle,
                onPressed: () async {
                  NavUtils.back();
                  if (await AppUtils.isNetConnected()) {
                    var valid = chatList
                        .where((element) =>
                            element.messageType != MessageType.isNotification)
                        .toList();
                    if (valid.isNotEmpty) {
                      Mirrorfly.reportUserOrMessages(
                          jid: profile.jid!,
                          type: chatMessage?.messageChatType ?? "chat",
                          messageId:
                              chatMessage?.messageId ?? Constants.emptyString,
                          flyCallBack: (FlyResponse response) {
                            debugPrint(response.toString());
                            if (response.isSuccess) {
                              toToast(getTranslated("reportSentSuccess"));
                            } else {
                              toToast(
                                  getTranslated("thereNoMessagesAvailable"));
                            }
                          });
                    } else {
                      toToast(getTranslated("thereNoMessagesAvailable"));
                    }
                  } else {
                    toToast(getTranslated("noInternetConnection"));
                  }
                },
                child: Text(
                  getTranslated("report").toUpperCase(),
                )),
            TextButton(
                style: AppStyleConfig.dialogStyle.buttonStyle,
                onPressed: () {
                  NavUtils.back();
                },
                child: Text(
                  getTranslated("cancel").toUpperCase(),
                )),
          ]);
    });
  }

  copyTextMessages() async {
    debugPrint('Copy text ==> ${selectedChatList[0].messageTextContent}');
    if (selectedChatList[0].mentionedUsersIds!.isEmpty) {
      Clipboard.setData(ClipboardData(
          text:
              selectedChatList[0].messageTextContent ?? Constants.emptyString));
      clearChatSelection(selectedChatList[0]);
      toToast(getTranslated("textCopiedSuccess"));
    } else {
      var selected = selectedChatList[0];
      clearChatSelection(selectedChatList[0]);
      toToast(getTranslated("textCopiedSuccess"));
      var profileDetails = await MentionUtils.getProfileDetailsOfUsername(
          selected.mentionedUsersIds!);
      var text = MentionUtils.getMentionedText(
          selected.messageTextContent.checkNull(), profileDetails);
      Clipboard.setData(ClipboardData(text: text));
      debugPrint("text : $text");
    }
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
    DialogUtils.showAlert(
        dialogStyle: AppStyleConfig.dialogStyle,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedChatList.length > 1
                  ? getTranslated("deleteSelectedMessages")
                  : getTranslated("deleteSelectedMessage"),
              style: const TextStyle(fontSize: 18, color: textColor),
            ),
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
                              child:
                                  Text(getTranslated("deleteMediaFromPhone")),
                            ),
                          ],
                        ),
                      )
                    ],
                  )
                : const SizedBox(),
          ],
        ),
        message: Constants.emptyString,
        actions: [
          TextButton(
              style: AppStyleConfig.dialogStyle.buttonStyle,
              onPressed: () {
                NavUtils.back();
              },
              child: Text(
                getTranslated("cancel").toUpperCase(),
              )),
          TextButton(
              style: AppStyleConfig.dialogStyle.buttonStyle,
              onPressed: () {
                NavUtils.back();
                if (!availableFeatures.value.isDeleteMessageAvailable
                    .checkNull()) {
                  DialogUtils.showFeatureUnavailable();
                  return;
                }
                //DialogUtils.showLoading(message: 'Deleting Message');
                var chatJid = selectedChatList.last.chatUserJid;
                Mirrorfly.deleteMessagesForMe(
                    jid: profile.jid!,
                    chatType: chatType,
                    messageIds: deleteChatListID,
                    isMediaDelete: isMediaDelete.value,
                    flyCallBack: (FlyResponse response) {
                      debugPrint(response.toString());
                      onMessageDeleteNotifyUI(chatJid: chatJid);
                    });
                removeChatList(selectedChatList);
                isSelected(false);
                selectedChatList.clear();
              },
              child: Text(
                getTranslated("deleteForMe").toUpperCase(),
              )),
          isRecallAvailable
              ? TextButton(
                  style: AppStyleConfig.dialogStyle.buttonStyle,
                  onPressed: () {
                    NavUtils.back();
                    if (!availableFeatures.value.isDeleteMessageAvailable
                        .checkNull()) {
                      DialogUtils.showFeatureUnavailable();
                      return;
                    }
                    //DialogUtils.showLoading(message: 'Deleting Message for Everyone');
                    Mirrorfly.deleteMessagesForEveryone(
                        jid: profile.jid!,
                        chatType: chatType,
                        messageIds: deleteChatListID,
                        isMediaDelete: isMediaDelete.value,
                        flyCallBack: (FlyResponse response) {
                          debugPrint(response.toString());
                          if (response.isSuccess) {
                            for (var chatList in selectedChatList) {
                              chatList.isMessageRecalled(true);
                              chatList.isSelected(false);
                              // this.chatList.refresh();
                              if (selectedChatList.last.messageId ==
                                  chatList.messageId) {
                                onMessageDeleteNotifyUI(
                                    chatJid: chatList.chatUserJid);
                              }
                            }
                          } else {
                            toToast(getTranslated("unableToDeleteMessages"));
                          }
                          isSelected(false);
                          selectedChatList.clear();
                        });
                  },
                  child: Text(
                    getTranslated("deleteForEveryone").toUpperCase(),
                  ))
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
      NavUtils.toNamed(Routes.messageInfo, arguments: {
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
    for (var item in selectedChatList) {
      Mirrorfly.updateFavouriteStatus(
          messageId: item.messageId,
          chatUserJid: item.chatUserJid,
          isFavourite: !item.isMessageStarred.value,
          chatType: item.messageChatType,
          flyCallBack: (_) {});
      var msg =
          chatList.firstWhere((element) => item.messageId == element.messageId);
      msg.isMessageStarred(!item.isMessageStarred.value);
      msg.isSelected(false);
    }
    isSelected(false);
    selectedChatList.clear();
  }

  blockUser() {
    Future.delayed(const Duration(milliseconds: 100), () async {
      DialogUtils.showAlert(
          dialogStyle: AppStyleConfig.dialogStyle,
          message: "${getTranslated("youWantToBlock")} ${getName(profile)}?",
          actions: [
            TextButton(
                style: AppStyleConfig.dialogStyle.buttonStyle,
                onPressed: () {
                  NavUtils.back();
                },
                child: Text(
                  getTranslated("cancel").toUpperCase(),
                )),
            TextButton(
                style: AppStyleConfig.dialogStyle.buttonStyle,
                onPressed: () async {
                  await AppUtils.isNetConnected().then((isConnected) {
                    if (isConnected) {
                      NavUtils.back();
                      DialogUtils.showLoading(
                          message: getTranslated("blockingUser"),
                          dialogStyle: AppStyleConfig.dialogStyle);
                      Mirrorfly.blockUser(
                          userJid: profile.jid!,
                          flyCallBack: (FlyResponse response) {
                            debugPrint("$response");
                            if (response.isSuccess) {
                              profile.isBlocked = true;
                              isBlocked(true);
                              setChatStatus();
                              profile_.refresh();
                              saveUnsentMessage();
                              DialogUtils.hideLoading();
                              toToast(getTranslated("hasBlocked")
                                  .replaceFirst("%d", getName(profile)));
                            } else {
                              DialogUtils.hideLoading();
                              toToast(response.errorMessage);
                            }
                          });
                    } else {
                      toToast(getTranslated("noInternetConnection"));
                    }
                  });
                },
                child: Text(
                  getTranslated("block").toUpperCase(),
                )),
          ]);
    });
  }

  clearUserChatHistory() {
    if (!availableFeatures.value.isClearChatAvailable.checkNull()) {
      DialogUtils.showFeatureUnavailable();
      return;
    }
    if (chatList.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 100), () {
        var starred =
            chatList.indexWhere((element) => element.isMessageStarred.value);
        DialogUtils.showAlert(
            dialogStyle: AppStyleConfig.dialogStyle,
            message: getTranslated("youWantToClearChat"),
            actions: [
              Visibility(
                visible: !starred.isNegative,
                child: TextButton(
                    style: AppStyleConfig.dialogStyle.buttonStyle,
                    onPressed: () {
                      NavUtils.back();
                      clearChatHistory(false);
                    },
                    child: Text(
                      getTranslated("clearAll").toUpperCase(),
                    )),
              ),
              TextButton(
                  style: AppStyleConfig.dialogStyle.buttonStyle,
                  onPressed: () {
                    NavUtils.back();
                  },
                  child: Text(
                    getTranslated("cancel").toUpperCase(),
                  )),
              Visibility(
                visible: starred.isNegative,
                child: TextButton(
                    style: AppStyleConfig.dialogStyle.buttonStyle,
                    onPressed: () {
                      NavUtils.back();
                      clearChatHistory(false);
                    },
                    child: Text(
                      getTranslated("clear").toUpperCase(),
                    )),
              ),
              Visibility(
                visible: !starred.isNegative,
                child: TextButton(
                    style: AppStyleConfig.dialogStyle.buttonStyle,
                    onPressed: () {
                      NavUtils.back();
                      clearChatHistory(true);
                    },
                    child: Text(
                      getTranslated("clearExceptStarred"),
                    )),
              ),
            ]);
      });
    } else {
      toToast(getTranslated("noConversation"));
    }
  }

  unBlockUser() {
    Future.delayed(const Duration(milliseconds: 100), () {
      DialogUtils.showAlert(
          dialogStyle: AppStyleConfig.dialogStyle,
          message:
              getTranslated("unBlockUser").replaceFirst("%d", getName(profile)),
          actions: [
            TextButton(
                style: AppStyleConfig.dialogStyle.buttonStyle,
                onPressed: () {
                  NavUtils.back();
                },
                child: Text(
                  getTranslated("cancel").toUpperCase(),
                )),
            TextButton(
                style: AppStyleConfig.dialogStyle.buttonStyle,
                onPressed: () async {
                  await AppUtils.isNetConnected().then((isConnected) {
                    if (isConnected) {
                      NavUtils.back();
                      // DialogUtils.showLoading(message: "Unblocking User");
                      Mirrorfly.unblockUser(
                          userJid: profile.jid!,
                          flyCallBack: (FlyResponse response) {
                            if (response.isSuccess) {
                              debugPrint(response.toString());
                              profile.isBlocked = false;
                              isBlocked(false);
                              getUnsentMessageOfAJid();
                              setChatStatus();
                              DialogUtils.hideLoading();
                              toToast(getTranslated("hasUnBlocked")
                                  .replaceFirst("%d", getName(profile)));
                            } else {
                              toToast(response.errorMessage);
                            }
                          });
                    } else {
                      toToast(getTranslated("noInternetConnection"));
                    }
                  });
                },
                child: Text(
                  getTranslated("unblock").toUpperCase(),
                )),
          ]);
    });
  }

  var filteredPosition = <int>[].obs;
  var searchedText = TextEditingController();
  String lastInputValue = Constants.emptyString;

  setSearch(String text) {
    if (lastInputValue != text.trim()) {
      lastInputValue = text.trim();
      filteredPosition.clear();
      if (searchedText.text.trim().isNotEmpty) {
        for (var i = 0; i < chatList.length; i++) {
          if (!chatList[i].isMessageRecalled.value) {
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
                    Constants.mMeet &&
                chatList[i].meetChatMessage!.link.isNotEmpty &&
                chatList[i]
                    .meetChatMessage!
                    .link
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
      }
      chatList.refresh();
    }
  }

  var lastPosition = (-1).obs;
  var searchedPrev = Constants.emptyString;
  var searchedNxt = Constants.emptyString;

  searchInit() {
    lastPosition = (-1).obs;
    j = -1;
    searchedPrev = Constants.emptyString;
    searchedNxt = Constants.emptyString;
    filteredPosition.clear();
    searchedText.clear();
  }

  var j = -1;

  scrollUp() {
    if (filteredPosition.isNotEmpty) {
      var visiblePos = findTopFirstVisibleItemPosition();
      LogMessage.d("visiblePos", visiblePos.toString());
      LogMessage.d(
          "visiblePos2", findBottomLastVisibleItemPosition().toString());
      var g = getNextPosition(findTopFirstVisibleItemPosition(),
          findBottomLastVisibleItemPosition(), j);
      if (g != null) j = g;
      LogMessage.d("scrollUp", g.toString());
      if (j >= 0 && g != null) {
        _scrollToPosition(j);
      } else {
        toToast(getTranslated("noResultsFound"));
      }
    } else {
      toToast(getTranslated("noResultsFound"));
    }
  }

  scrollDown() {
    if (filteredPosition.isNotEmpty) {
      var visiblePos = findTopFirstVisibleItemPosition();
      LogMessage.d("visiblePos", visiblePos.toString());
      var g = getPreviousPosition(findTopFirstVisibleItemPosition(),
          findBottomLastVisibleItemPosition(), j);
      if (g != null) j = g;
      LogMessage.d("scrollDown", j.toString());
      if (j >= 0 && g != null) {
        _scrollToPosition(j);
      } else {
        toToast(getTranslated("noResultsFound"));
      }
    } else {
      toToast(getTranslated("noResultsFound"));
    }
  }

  int _currentIndex = 0;
  bool topReached = false;
  bool bottomReached = false;

  void scrollTop() {
    LogMessage.d("scrollTop",
        "filteredPosition : $filteredPosition _currentIndex : $_currentIndex");
    if (filteredPosition.length > _currentIndex && !topReached) {
      bottomReached = false;
      _scrollToPosition(filteredPosition[_currentIndex]);
      if (_currentIndex < filteredPosition.length - 1) {
        _currentIndex++;
      } else {
        topReached = true;
      }
    } else {
      topReached = true;
      toToast(getTranslated("noResultsFound"));
    }
  }

  void scrollBottom() {
    LogMessage.d("scrollBottom",
        "filteredPosition : $filteredPosition _currentIndex : $_currentIndex");
    if (!_currentIndex.isNegative && _currentIndex != 0) {
      _currentIndex--;
    }
    if (filteredPosition.length > _currentIndex &&
        !_currentIndex.isNegative &&
        !bottomReached) {
      topReached = false;
      _scrollToPosition(filteredPosition[_currentIndex]);
      /*if(_currentIndex>1) {
        _currentIndex--;
      }else{
        bottomReached=true;
      }*/
      if (_currentIndex < 1) {
        bottomReached = true;
      }
    } else {
      bottomReached = true;
      toToast(getTranslated("noResultsFound"));
      _currentIndex = 0;
    }
  }

  var color = Colors.transparent.obs;

  _scrollToPosition(int position) {
    // LogMessage.d("position", position.toString());
    if (!position.isNegative) {
      var currentPosition = position;
      // filteredPosition[position]; //(chatList.length - (position));
      LogMessage.d("currentPosition", currentPosition.toString());
      chatList[currentPosition].isSelected(true);
      searchScrollController?.jumpTo(index: currentPosition);
      Future.delayed(const Duration(milliseconds: 800), () {
        currentPosition = (currentPosition);
        chatList[currentPosition].isSelected(false);
        chatList.refresh();
      });
    } else {
      toToast(getTranslated("noResultsFound"));
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
      debugPrint('findBetweenOrBelow : $findBetweenOrAbove');
    }
    debugPrint('filteredPosition : ${filteredPosition.join(',')}');
    return findBetweenOrAbove;
  }

  // final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  int findTopFirstVisibleItemPosition({ItemPositionsListener? listener}) {
    var listen = listener ?? newItemPositionsListener;
    var r = listen?.itemPositions.value
        .where((ItemPosition position) => position.itemLeadingEdge < 1)
        .reduce((ItemPosition min, ItemPosition position) =>
            position.itemLeadingEdge > min.itemLeadingEdge ? position : min)
        .index;
    return r!; //< chatList.length ? r + 1 : r;
  }

  int findBottomLastVisibleItemPosition({ItemPositionsListener? listener}) {
    var listen = listener ?? newItemPositionsListener;
    var r = listen?.itemPositions.value
        .where((ItemPosition position) => position.itemTrailingEdge < 1)
        .reduce((ItemPosition min, ItemPosition position) =>
            position.itemTrailingEdge < min.itemTrailingEdge ? position : min)
        .index;
    return r!; // < chatList.length ? r + 1 : r;
  }

  exportChat() async {
    if (chatList.isNotEmpty) {
      var permission = await AppPermission.getStoragePermission();
      if (permission) {
        Mirrorfly.exportChatConversationToEmail(
          jid: profile.jid.checkNull(),
          flyCallBack: (FlyResponse response) async {
            debugPrint("exportChatConversationToEmail $response");

            if (response.isSuccess && response.hasData) {
              var data = exportModelFromJson(response.data);

              // Check if media attachment URLs exist and are not empty
              if (data.mediaAttachmentsUrl?.isNotEmpty ?? false) {
                try {
                  // Convert media URLs to XFile objects
                  var xFiles = data.mediaAttachmentsUrl!
                      .map((element) => XFile(element))
                      .toList();

                  // Share the files
                  await Share.shareXFiles(xFiles);
                  debugPrint("Files shared successfully.");
                } catch (e) {
                  debugPrint("Error while sharing files: $e");
                }
              } else {
                debugPrint("No media attachments available to share.");
              }
            } else {
              debugPrint(
                  "Failed to export chat conversation: ${response.message}");
            }
          },
        );
      }
    } else {
      toToast(getTranslated("noConversation"));
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
      clearAllChatSelection();
      goToForwardMessage(messageIds);
    }
  }

  void closeKeyBoard() {
    // FocusManager.instance.primaryFocus!.unfocus();
    focusNode.unfocus();
  }

  void startTimer() {
    showOrHideTagListView(false, "chatView");
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
    debugPrint("Cancel Recording called");
    if (_isDisposed) {
      debugPrint("Recording is already cancelled");
      return;
    }
    var filePath = await record.stop();
    File(filePath!).delete();
    _audioTimer?.cancel();
    record.dispose();
    _isDisposed = true;
    _audioTimer = null;
    isAudioRecording(Constants.audioRecordDelete);
    Future.delayed(const Duration(milliseconds: 1500), () {
      isAudioRecording(Constants.audioRecordInitial);
      isUserTyping(messageController.text.trim().isNotEmpty);
    });
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
      // var permission = await AppPermission.getStoragePermission();
      var microPhonePermissionStatus =
          await AppPermission.checkAndRequestPermissions(
              permissions: [Permission.microphone],
              permissionIcon: audioPermission,
              permissionContent: getTranslated("audioPermissionContent"),
              permissionPermanentlyDeniedContent:
                  getTranslated("microPhonePermissionDeniedContent"));
      debugPrint(
          "microPhone Permission Status---> $microPhonePermissionStatus");
      if (microPhonePermissionStatus) {
        isUserTyping(false);
        record = AudioRecorder();
        _isDisposed = false;
        timerInit("00:00");
        isAudioRecording(Constants.audioRecording);
        startTimer();
        await record.start(const RecordConfig(),
            path:
                "$audioSavePath/audio_${DateTime.now().millisecondsSinceEpoch}.m4a");
        Future.delayed(const Duration(seconds: 300), () {
          if (isAudioRecording.value == Constants.audioRecording) {
            stopRecording();
          }
        });
      }
    } else {
      //show busy status popup
      showBusyStatusAlert(startRecording);
    }
  }

  Future<void> stopRecording() async {
    isAudioRecording(Constants.audioRecordDone);
    isUserTyping(messageController.text.trim().isNotEmpty);
    _audioTimer?.cancel();
    _audioTimer = null;
    debugPrint("Audio Recording Stopped");
    await record.stop().then((filePath) async {
      debugPrint("Audio saved path---> $filePath");
      if (MediaUtils.isMediaExists(filePath)) {
        recordedAudioPath = filePath.checkNull();
        debugPrint("Audio recordedAudioPath path---> $recordedAudioPath");
      } else {
        debugPrint("File Not Found For Audio");
      }
      debugPrint(filePath);
    });
  }

  Future<void> deleteRecording() async {
    File(recordedAudioPath).delete();
    isUserTyping(messageController.text.trim().isNotEmpty);
    isAudioRecording(Constants.audioRecordInitial);
    timerInit("00:00");
    record.dispose();
    _isDisposed = true;
  }

  Future<void> setAudioPath() async {
    Directory? directory = Platform.isAndroid
        ? await getExternalStorageDirectory() //FOR ANDROID
        : await getApplicationSupportDirectory(); //FOR iOS
    debugPrint("Audio path directory---> $directory");
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
      toToast(getTranslated("recordedAudioTimeShort"));
    }
    isUserTyping(false);
    isAudioRecording(Constants.audioRecordInitial);
    timerInit("00:00");
    record.dispose();
    _isDisposed = true;
  }

  infoPage() {
    setOnGoingUserGone();
    saveUnsentMessage();
    if (profile.isGroupProfile ?? false) {
      NavUtils.toNamed(Routes.groupInfo, arguments: profile)
          ?.then((value) async {
        if (value != null) {
          messageController.clear();
          profile_(value as ProfileDetails);
          getAvailableFeatures();
          isBlocked(profile.isBlocked);
          if (Platform.isAndroid) {
            unreadMessageTypeMessageId = "M${value.jid}";
          } else if (Platform.isIOS) {
            unreadMessageTypeMessageId =
                "M_${getMobileNumberFromJid(value.jid.checkNull())}";
          }
          debugPrint("value--> ${profile.isGroupProfile}");
          chatList.clear();
          _loadMessages();
          getUnsentMessageOfAJid();
        } else {
          if (await Mirrorfly.hasNextMessages()) {
            _loadNextMessages();
          }
        }
        checkAdminBlocked();
        memberOfGroup();
        setChatStatus();
        setOnGoingUserAvail();
      });
    } else {
      NavUtils.toNamed(Routes.chatInfo,
              arguments: ChatInfoArguments(chatJid: profile.jid.checkNull()))
          ?.then((value) {
        debugPrint("chat info-->$value");
        setOnGoingUserAvail();
      });
    }
  }

  gotoSearch() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _currentIndex = 0;
      topReached = false;
      bottomReached = false;
      lastInputValue = "";
      NavUtils.toNamed(Routes.chatSearch, arguments: arguments);
    });
  }

  sendUserTypingStatus() {
    Mirrorfly.sendTypingStatus(
        toJid: profile.jid.checkNull(), chatType: profile.getChatType());
  }

  sendUserTypingGoneStatus() {
    Mirrorfly.sendTypingGoneStatus(
        toJid: profile.jid.checkNull(), chatType: profile.getChatType());
  }

  var unreadCount = 0.obs;

  void onMessageReceived(ChatMessageModel chatMessageModel) {
    LogMessage.d("chatController", "onMessageReceived");

    if (chatMessageModel.chatUserJid == profile.jid) {
      removeUnreadSeparator();
      final index = chatList.indexWhere(
          (message) => message.messageId == chatMessageModel.messageId);
      debugPrint("message received index $index");
      if (index.isNegative) {
        // chatList.insert(0, chatMessageModel);
        loadLastMessages(chatMessageModel);
        unreadCount.value++;
        //scrollToBottom();
        if (SessionManagement.getCurrentChatJID() != Constants.emptyString) {
          setOnGoingUserAvail();
        }
      }
    }
  }

  Future<void> onMessageDeleted({required String messageId}) async {
    final int indexToBeReplaced =
        chatList.indexWhere((message) => message.messageId == messageId);
    debugPrint(
        "#ChatController onMessageDeleted index to replace $indexToBeReplaced");
    if (!indexToBeReplaced.isNegative) {
      chatList[indexToBeReplaced].isMessageRecalled.value = true;
      chatList.refresh();
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
        // DialogUtils.hideLoading();
        // chatMessageModel.isSelected=chatList[index].isSelected;
        chatList[index] = chatMessageModel;
        // chatList.refresh();
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
        chatList[index].mediaChatMessage?.mediaLocalStoragePath(
            chatMessageModel.mediaChatMessage!.mediaLocalStoragePath.value);
        chatList[index].mediaChatMessage?.mediaDownloadStatus(
            chatMessageModel.mediaChatMessage!.mediaDownloadStatus.value);
        chatList[index].mediaChatMessage?.mediaUploadStatus(
            chatMessageModel.mediaChatMessage!.mediaUploadStatus.value);
        debugPrint(
            "After Media Status Updated ${chatList[index].mediaChatMessage?.mediaLocalStoragePath} ${chatList[index].mediaChatMessage?.mediaDownloadStatus} ${chatList[index].mediaChatMessage?.mediaUploadStatus}");
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
        if (DialogUtils.isDialogOpen()) {
          NavUtils.back();
        }
        _isMemberOfGroup(false);
      } else if (groupJid == profile.jid) {
        setChatStatus();
      }
    }
  }

  void onSuperAdminDeleteGroup(
      {required String groupJid, required String groupName}) {
    LogMessage.d("ChatController",
        "onSuperAdminDeleteGroup groupJid $groupJid, groupName $groupName");
    if (profile.isGroupProfile ?? false) {
      if (groupJid == profile.jid) {
        LogMessage.d(
            "ChatController", "onSuperAdminDeleteGroup deleting group");
        if (Get.isRegistered<DashboardController>()) {
          Get.find<DashboardController>()
              .deleteGroup(groupJid: groupJid, groupName: groupName);
        }
        _isMemberOfGroup(false);
        NavUtils.back();
      } else {
        LogMessage.d("onSuperAdminDeleteGroup",
            "Group has been deleted, current chat controller is not the deleted group");
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
          groupParticipantsName(Constants.emptyString);
          getProfileDetails(jid)
              .then((value) => userPresenceStatus("${value.name} typing..."));
        } else {
          //if(!profile.isGroupProfile!){//commented if due to above if condition works
          userPresenceStatus("typing...");
        }
      } else {
        if (typingList.isNotEmpty && typingList.contains(jid)) {
          typingList.remove(jid);
          userPresenceStatus(Constants.emptyString);
        }
        setChatStatus();
      }
    }
  }

  memberOfGroup() {
    if (profile.isGroupProfile ?? false) {
      Mirrorfly.isMemberOfGroup(
              groupJid: profile.jid.checkNull(),
              userJid: SessionManagement.getUserJID().checkNull())
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
        Mirrorfly.getUserLastSeenTime(
            jid: profile.jid.toString(),
            flyCallBack: (FlyResponse response) {
              debugPrint("date time flutter--->");
              if (response.isSuccess && response.hasData) {
                var lastSeen = convertSecondToLastSeen(response.data);
                groupParticipantsName(Constants.emptyString);
                userPresenceStatus(lastSeen.toString());
              } else {
                groupParticipantsName(Constants.emptyString);
                userPresenceStatus(Constants.emptyString);
              }
            });
      } else {
        groupParticipantsName(Constants.emptyString);
        userPresenceStatus(Constants.emptyString);
      }
    }
    if (!await AppUtils.isNetConnected()) {
      debugPrint("setChatStatus method network not connected");
      userPresenceStatus(Constants.emptyString);
    }
  }

  void filterMentionUsers(String triggerCharacter, String? query, String tag) {
    if (Get.isRegistered<MentionController>(tag: tag)) {
      Get.find<MentionController>(tag: tag)
          .filterMentionUsers(triggerCharacter, query);
    }
  }

  void showOrHideTagListView(bool show, String tag) {
    if (Get.isRegistered<MentionController>(tag: tag)) {
      Get.find<MentionController>(tag: tag).showOrHideTagListView(show);
    }
  }

  void onUserTagClicked(ProfileDetails profile,
      MentionTagTextEditingController controller, String tag) {
    // controller.addMention(id: profile.jid.checkNull().split("@")[0], name: profile.getName());
    var mention = profile.jid.checkNull().split("@")[0];
    controller.addMention(
        label: profile.getName(),
        data: mention,
        stylingWidget: Text(
          '@${profile.getName()}',
          style: const TextStyle(color: Colors.blueAccent),
        ));
    showOrHideTagListView(false, tag);
  }

  var groupParticipantsName = ''.obs;
  var groupMembers = List<ProfileDetails>.empty(growable: true).obs;

  getParticipantsNameAsCsv(String jid) {
    Mirrorfly.getGroupMembersList(
        jid: jid,
        fetchFromServer: false,
        flyCallBack: (FlyResponse response) {
          if (response.isSuccess && response.hasData) {
            var str = <String>[];
            LogMessage.d("getGroupMembersList-->", response.toString());
            groupMembers(memberFromJson(response.data));
            for (var it in groupMembers) {
              if (it.jid.checkNull() !=
                  SessionManagement.getUserJID().checkNull()) {
                str.add(it.getName().checkNull());
              }
            }
            str.sort((a, b) {
              return a.toLowerCase().compareTo(b.toLowerCase());
            });
            groupParticipantsName(str.join(", "));
          }
        });
  }

  String get subtitle => userPresenceStatus.value.isEmpty
      ? /*groupParticipantsName.isNotEmpty
          ? groupParticipantsName.toString()
          :*/
      Constants.emptyString
      : userPresenceStatus.value.toString();

  // final ImagePicker _picker = ImagePicker();

  onCameraClick() async {
    if (!availableFeatures.value.isImageAttachmentAvailable.checkNull() &&
        !availableFeatures.value.isVideoAttachmentAvailable.checkNull()) {
      DialogUtils.showFeatureUnavailable();
      return;
    }
    // if (await AppPermission.askFileCameraAudioPermission()) {
    var cameraPermissionStatus = await AppPermission.checkAndRequestPermissions(
        permissions: [Permission.camera, Permission.microphone],
        permissionIcon: cameraPermission,
        permissionContent: getTranslated("cameraPermissionContent"),
        permissionPermanentlyDeniedContent:
            getTranslated("cameraCapturePermanentlyDeniedContent"));
    debugPrint("Camera Permission Status---> $cameraPermissionStatus");
    if (cameraPermissionStatus) {
      setOnGoingUserGone();
      NavUtils.toNamed(Routes.cameraPick)?.then((photo) {
        photo as XFile?;
        if (photo != null) {
          LogMessage.d("photo", photo.name.toString());
          LogMessage.d(
              "caption text sending-->", messageController.formattedText);
          var file = PickedAssetModel(
              path: photo.path,
              type: !photo.name.endsWith(".mp4") ? "image" : "video",
              file: File(photo.path));
          NavUtils.toNamed(Routes.mediaPreview, arguments: {
            "filePath": [file],
            "userName": profile.name!,
            'profile': profile,
            // 'caption': messageController.formattedText,
            // 'mentionedUsersIds': messageController.getTags,
            "captionMessage": [messageController.formattedText],
            "captionMessageMentions": [messageController.getTags],
            'showAdd': false,
            'from': 'camera_pick',
            'userJid': profile.jid
          })?.then((value) => setOnGoingUserAvail());
        } else {
          setOnGoingUserAvail();
        }
      });
    }
  }

  onAudioClick() async {
    if (!availableFeatures.value.isAudioAttachmentAvailable.checkNull()) {
      DialogUtils.showFeatureUnavailable();
      return;
    }
    var permission = await AppPermission.getStoragePermission();
    if (permission) {
      pickAudio();
    }
  }

  onGalleryClick() async {
    if (!availableFeatures.value.isImageAttachmentAvailable.checkNull() &&
        !availableFeatures.value.isVideoAttachmentAvailable.checkNull()) {
      DialogUtils.showFeatureUnavailable();
      return;
    }
    var permissions = await AppPermission.getGalleryAccessPermissions();
    var permission = await AppPermission.checkAndRequestPermissions(
        permissions: permissions,
        permissionIcon: filePermission,
        permissionContent: getTranslated("filePermissionContent"),
        permissionPermanentlyDeniedContent:
            getTranslated("storagePermissionDeniedContent"));
    if (permission) {
      try {
        setOnGoingUserGone();
        NavUtils.toNamed(Routes.galleryPicker, arguments: {
          "userName": getName(profile),
          'profile': profile,
          'caption': messageController.formattedText.trim(),
          'mentionedUsersIds': messageController.getTags,
          'userJid': profile.jid
        })?.then((value) => setOnGoingUserAvail());
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  onContactClick() async {
    if (!availableFeatures.value.isContactAttachmentAvailable.checkNull()) {
      DialogUtils.showFeatureUnavailable();
      return;
    }
    var permission = await AppPermission.checkAndRequestPermissions(
        permissions: [Permission.contacts],
        permissionIcon: contactPermission,
        permissionContent: getTranslated("contactPermissionContent"),
        permissionPermanentlyDeniedContent:
            getTranslated("contactPermissionDeniedContent"));
    if (permission) {
      setOnGoingUserGone();
      NavUtils.toNamed(Routes.localContact, arguments: {"userJid": profile.jid})
          ?.then((value) => setOnGoingUserAvail());
    }
  }

  onLocationClick() async {
    if (!availableFeatures.value.isLocationAttachmentAvailable.checkNull()) {
      DialogUtils.showFeatureUnavailable();
      return;
    }
    if (await AppUtils.isNetConnected()) {
      var permission = await AppPermission.checkAndRequestPermissions(
          permissions: [Permission.location],
          permissionIcon: locationPinPermission,
          permissionContent: getTranslated("locationPermissionContent"),
          permissionPermanentlyDeniedContent:
              getTranslated("locationPermissionDeniedContent"));
      if (permission) {
        setOnGoingUserGone();
        NavUtils.toNamed(Routes.locationSent)?.then((value) {
          if (value != null) {
            value as LatLng;
            sendLocationMessage(profile, value.latitude, value.longitude);
          }
          setOnGoingUserAvail();
        });
      }
    } else {
      toToast(getTranslated("noInternetConnection"));
    }
  }

  checkAdminBlocked() {
    if (profile.isGroupProfile.checkNull()) {
      if (profile.isAdminBlocked.checkNull()) {
        toToast(getTranslated("groupNoLonger"));
        NavUtils.back();
      }
    } else {
      if (profile.isAdminBlocked.checkNull()) {
        toToast(getTranslated("chatNoLonger"));
        NavUtils.back();
      }
    }
  }

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
        if ((chat.mediaChatMessage?.mediaDownloadStatus.value ==
                    MediaDownloadStatus.mediaDownloaded.value ||
                chat.mediaChatMessage?.mediaUploadStatus.value ==
                    MediaUploadStatus.mediaUploaded.value) &&
            (checkFile(chat.mediaChatMessage!.mediaLocalStoragePath.value
                .checkNull()))) {
          return true;
        }
      } else {
        if (chat.messageType == Constants.mLocation ||
            chat.messageType == Constants.mContact ||
            chat.messageType == Constants.mMeet) {
          return true;
        }
      }
    }
    return false;
  }

  forwardSingleMessage(String messageId) {
    goToForwardMessage([messageId]);
  }

  //Forward Message
  void goToForwardMessage(List<String> messageIds) {
    setOnGoingUserGone();
    NavUtils.toNamed(Routes.forwardChat, arguments: {
      "forward": true,
      "group": false,
      "groupJid": Constants.emptyString,
      "messageIds": messageIds
    })?.then((value) {
      _loadNextMessages(showLoading: false);
      checkAdminBlocked();
      memberOfGroup();
      setChatStatus();
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
  var canEditMessage = false.obs;

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
    canEditMessage(true);

    for (var message in selectedChatList) {
      //Recalled Validation
      if (message.isMessageRecalled.value) {
        containsRecalled(true);
        break;
      }
      //Copy Validation
      if (!canBeCopiedSet &&
          (!message.isTextMessage() &&
              !(message.isMediaMessage() &&
                  message.mediaChatMessage!.mediaCaptionText
                      .checkNull()
                      .isNotEmpty))) {
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
                !checkFile(
                    message.mediaChatMessage!.mediaLocalStoragePath.value)))) {
      canBeForwarded(false);
      canBeForwardedSet = true;
    }
    //Share Validation
    if (!canBeSharedSet &&
        (!message.isMediaMessage() ||
            (message.isMediaMessage() &&
                !MediaUtils.isMediaExists(
                    message.mediaChatMessage!.mediaLocalStoragePath.value)))) {
      canBeShared(false);
      canBeSharedSet = true;
    }
    //Starred Validation
    if (!canBeStarredSet && message.isMessageStarred.value ||
        (message.isMediaMessage() &&
            !checkFile(
                message.mediaChatMessage!.mediaLocalStoragePath.value))) {
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
        canEditMessage(false);
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
    LogMessage.d("action_menu canBeCopied", canBeCopied.toString());
    LogMessage.d("action_menu canBeForwarded", canBeForwarded.toString());
    LogMessage.d("action_menu canBeShared", canBeShared.toString());
    LogMessage.d("action_menu canBeStarred", canBeStarred.toString());
    LogMessage.d("action_menu canBeUnStarred", canBeUnStarred.toString());
    LogMessage.d("action_menu canBeReplied", canBeReplied.toString());
    LogMessage.d("action_menu canShowInfo", canShowInfo.toString());
    LogMessage.d("action_menu canShowReport", canShowReport.toString());
  }

  setMenuItemsValidations(ChatMessageModel message) {
    debugPrint("setMenuItemsValidations");
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
              !checkFile(
                  message.mediaChatMessage!.mediaLocalStoragePath.value))) {
        canShowInfo(false);
      }
      //Report validation
      if (message.isMessageSentByMe) {
        canShowReport(false);
      } else {
        canShowReport(true);
      }
      //Edit Message Validation
      if (message.isMessageSentByMe &&
          !profile.isAdminBlocked.checkNull() &&
          isWithinLast15Minutes(message.messageSentTime) &&
          message.messageStatus.value != 'N' &&
          (profile.isGroupProfile.checkNull()
              ? isMemberOfGroup.checkNull()
              : true) &&
          (message.messageType == Constants.mText ||
              message.messageType == Constants.mAutoText ||
              (message.messageType == Constants.mImage &&
                  message.mediaChatMessage!.mediaCaptionText.isNotEmpty) ||
              (message.messageType == Constants.mVideo &&
                  message.mediaChatMessage!.mediaCaptionText.isNotEmpty))) {
        canEditMessage(true);
      } else {
        canEditMessage(false);
      }
    } else {
      canEditMessage(false);
    }
  }

  //#editMessage
  bool isWithinLast15Minutes(int epochTime) {
    //Sample from iOS - 1711376486924000
    // Get the current time
    var now = DateTime.now();

    // Calculate the time 15 minutes ago
    var fifteenMinutesAgo =
        now.subtract(const Duration(minutes: Constants.editMessageTimeLimit));

    //
    // Convert the epoch time (in microseconds since epoch) to a DateTime
    var dateTimeFromEpoch = DateTime.fromMicrosecondsSinceEpoch(epochTime);

    // Check if the epoch time is after fifteenMinutesAgo
    return dateTimeFromEpoch.isAfter(fifteenMinutesAgo);
  }

  void navigateToMessage(ChatMessageModel chatMessage, {int? index}) {
    var messageID = chatMessage.messageId;
    var chatIndex = index ??
        chatList.indexWhere((element) => element.messageId == messageID);
    if (!chatIndex.isNegative) {
      // newScrollController.scrollTo(index: chatIndex+5, duration: const Duration(milliseconds: 1));
      if (!checkIndexVisibleInViewPort(chatIndex)) {
        newScrollController?.jumpTo(index: chatIndex);
      }
      LogMessage.d("newScrollController", "selected $chatIndex");
      chatList[chatIndex].isSelected(true);
      chatList.refresh();

      Future.delayed(const Duration(seconds: 1), () {
        LogMessage.d("newScrollController", "unselected $chatIndex");
        chatList[chatIndex].isSelected(false);
        chatList.refresh();
      });
    } else {
      getMessageFromServerAndNavigateToMessage(chatMessage, index);
    }
  }

  bool checkIndexVisibleInViewPort(int index) {
    return (findTopFirstVisibleItemPosition(
                listener: newItemPositionsListener) >=
            index &&
        findBottomLastVisibleItemPosition(listener: newItemPositionsListener) <=
            index);
  }

  void getMessageFromServerAndNavigateToMessage(
      ChatMessageModel chatMessage, int? index) {
    Mirrorfly.loadMessages(flyCallback: (FlyResponse response) {
      showLoadingNext(false);
      showLoadingPrevious(false);
      if (response.isSuccess && response.hasData) {
        LogMessage.d("loadMessages", response.data);
        chatList.clear();
        List<ChatMessageModel> chatMessageModel =
            chatMessageModelFromJson(response.data);
        chatList(chatMessageModel.reversed.toList());
        navigateToMessage(chatMessage, index: index);
        chatLoading(false);
      } else {
        chatLoading(false);
      }
    });
  }

  int findLastVisibleItemPositionForChat({ItemPositionsListener? listener}) {
    var listen = listener ?? newItemPositionsListener;
    return listen!.itemPositions.value.first.index - 1;
  }

  void share() {
    var mediaPaths = <XFile>[];
    for (var item in selectedChatList) {
      if (item.isMediaMessage()) {
        if (MediaUtils.isMediaExists(
            item.mediaChatMessage!.mediaLocalStoragePath.value)) {
          mediaPaths.add(XFile(
              item.mediaChatMessage!.mediaLocalStoragePath.value.checkNull()));
          debugPrint(
              "mediaPaths ${item.mediaChatMessage!.mediaLocalStoragePath.value.checkNull()}");
        }
      }
    }
    clearAllChatSelection();
    Share.shareXFiles(mediaPaths);
  }

  var hasPaused = false;

  @override
  void onPaused() {
    LogMessage.d("LifeCycle", "chat onPaused");
    hasPaused = true;
    setOnGoingUserGone();
    saveUnsentMessage();
    sendUserTypingGoneStatus();
  }

  @override
  void onResumed() {
    LogMessage.d("LifeCycle", "chat onResumed");

    ///when notification drawer was dragged then app goes inactive,when closes the drawer its trigger onResume
    ///so that this checking hasPaused added, this will invoke only when app is opened from background state.
    if (hasPaused) {
      hasPaused = false;
      cancelNotification();
      setChatStatus();
      getAvailableFeatures();

      //to avoid calling without initializedMessageList
      if (initializedMessageList) {
        /// we loading next messages instead of load message because the new messages received will be available in load next message
        _loadNextMessages();
      }
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
  }

  void markConversationReadNotifyUI() {
    LogMessage.d("setConversationAsRead", "chat");
    if (Get.isRegistered<MainController>()) {
      Get.find<MainController>()
          .markConversationReadNotifyUI(profile.jid.checkNull());
    }
  }

  @override
  void onDetached() {
    LogMessage.d("LifeCycle", "chat onDetached");
  }

  @override
  void onInactive() {
    LogMessage.d("LifeCycle", "chat onInactive");
    final isAttached = newScrollController?.isAttached ?? false;
    if (isAttached) {
      newScrollController = null;
    }
    newItemPositionsListener = null;
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
        !profile.isGroupProfile.checkNull() &&
        (!profile.isBlockedMe.checkNull() ||
            !profile.isAdminBlocked.checkNull())) {
      debugPrint("userCameOnline : $jid");
      /*Future.delayed(const Duration(milliseconds: 3000), () {
        setChatStatus();
      });*/
      userPresenceStatus(getTranslated("online"));
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

  void onConnected() {
    LogMessage.d("networkConnected", 'true');
    Future.delayed(const Duration(milliseconds: 2000), () {
      setChatStatus();
    });
    if (!chatProfileCalled) {
      getChatProfile();
    }
  }

  void onDisconnected() {
    LogMessage.d('networkDisconnected', 'false');
    typingList.clear();
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

  void onUserAddedToGroup({
    required String groupJid,
  }) {
    if (profile.isGroupProfile.checkNull() && profile.jid == groupJid) {
      memberOfGroup();
    }
  }

  void onNewMemberAddedToGroup(
      {required String groupJid,
      required String newMemberJid,
      required String addedByMemberJid}) {
    if (profile.isGroupProfile.checkNull()) {
      if (profile.jid == groupJid) {
        debugPrint('onNewMemberAddedToGroup $newMemberJid');
        getParticipantsNameAsCsv(groupJid);
        memberOfGroup();
      }
    }
    if (Get.isRegistered<MentionController>(tag: "chatView")) {
      Get.find<MentionController>(tag: "chatView").onNewMemberAddedToGroup(
          groupJid: groupJid,
          newMemberJid: newMemberJid,
          addedByMemberJid: addedByMemberJid);
    }
    if (Get.isRegistered<MentionController>(tag: "editWindow")) {
      Get.find<MentionController>(tag: "editWindow").onNewMemberAddedToGroup(
          groupJid: groupJid,
          newMemberJid: newMemberJid,
          addedByMemberJid: addedByMemberJid);
    }
    if (Get.isRegistered<MentionController>(tag: Routes.galleryPicker)) {
      Get.find<MentionController>(tag: Routes.galleryPicker)
          .onNewMemberAddedToGroup(
              groupJid: groupJid,
              newMemberJid: newMemberJid,
              addedByMemberJid: addedByMemberJid);
    }
  }

  void onMemberRemovedFromGroup(
      {required String groupJid,
      required String removedMemberJid,
      required String removedByMemberJid}) {
    if (profile.isGroupProfile.checkNull()) {
      if (profile.jid == groupJid) {
        debugPrint('onMemberRemovedFromGroup $removedMemberJid');
        getParticipantsNameAsCsv(groupJid);
        if (removedMemberJid == SessionManagement.getUserJID()) {
          //removed me
          onLeftFromGroup(groupJid: groupJid, userJid: removedMemberJid);
        }
      }
    }
    if (Get.isRegistered<MentionController>(tag: "chatView")) {
      Get.find<MentionController>(tag: "chatView").onMemberRemovedFromGroup(
          groupJid: groupJid,
          removedMemberJid: removedMemberJid,
          removedByMemberJid: removedByMemberJid);
    }
    if (Get.isRegistered<MentionController>(tag: "editWindow")) {
      Get.find<MentionController>(tag: "editWindow").onMemberRemovedFromGroup(
          groupJid: groupJid,
          removedMemberJid: removedMemberJid,
          removedByMemberJid: removedByMemberJid);
    }
    if (Get.isRegistered<MentionController>(tag: Routes.galleryPicker)) {
      Get.find<MentionController>(tag: Routes.galleryPicker)
          .onMemberRemovedFromGroup(
              groupJid: groupJid,
              removedMemberJid: removedMemberJid,
              removedByMemberJid: removedByMemberJid);
    }
  }

  Future<void> saveContact() async {
    var phone = profile.mobileNumber.checkNull().isNotEmpty
        ? profile.mobileNumber.checkNull()
        : getMobileNumberFromJid(profile.jid.checkNull());
    var userName = profile.nickName.checkNull().isNotEmpty
        ? profile.nickName.checkNull()
        : profile.name.checkNull();
    if (phone.isNotEmpty) {
      lib_phone_number.init();
      var formatNumberSync = lib_phone_number.formatNumberSync(phone);
      var parse = await lib_phone_number.parse(formatNumberSync);
      debugPrint("parse-----> $parse");
      Mirrorfly.addContact(number: parse["international"], name: userName)
          .then((value) {
        if (value ?? false) {
          toToast(getTranslated("contactSavedSuccess"));
          if (Constants.enableContactSync) {
            syncContacts();
          }
        }
      });
    } else {
      LogMessage.d('mobile number', phone.toString());
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
              isFirstTime: !SessionManagement.isInitialContactSyncDone(),
              flyCallBack: (_) {},
            );
          }
        }
      }
    } else {
      debugPrint("Contact sync permission is not granted");
      if (SessionManagement.isInitialContactSyncDone()) {
        Mirrorfly.revokeContactSync(flyCallBack: (FlyResponse response) {
          onContactSyncComplete(true);
          LogMessage.d("checkContactPermission isSuccess", response.toString());
        });
      }
    }
  }

  void userBlockedMe(String jid) {
    updateProfile(jid);
  }

  void showHideEmoji() {
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

  void onUploadDownloadProgressChanged(
      String messageId, String progressPercentage) {
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
    SessionManagement.setBool(Constants.layoutSwitch,true);
    if((await Mirrorfly.isOnGoingCall()).checkNull()){
      toToast(getTranslated("msgOngoingCallAlert"));
      return;
    }
    if (await AppUtils.isNetConnected()) {
      if (await AppPermission.askAudioCallPermissions()) {
        if (profile.isGroupProfile.checkNull()) {
          if (isMemberOfGroup.checkNull()) {
            NavUtils.toNamed(Routes.groupParticipants, arguments: {
              "groupId": profile.jid,
              "callType": CallType.audio
            });
          }
        } else {
          Mirrorfly.makeVoiceCall(
              toUserJid: profile.jid.checkNull(),
              flyCallBack: (FlyResponse response) {
                if (response.isSuccess) {
                  debugPrint("#Mirrorfly Call userjid ${profile.jid}");
                  setOnGoingUserGone();
                  NavUtils.toNamed(Routes.outGoingCallView, arguments: {
                    "userJid": [profile.jid],
                    "callType": CallType.audio
                  })?.then((value) => setOnGoingUserAvail());
                } else {
                  DialogUtils.showAlert(
                      dialogStyle: AppStyleConfig.dialogStyle,
                      message: getErrorDetails(response),
                      actions: [
                        TextButton(
                            onPressed: () => NavUtils.back(),
                            child: Text(getTranslated("ok").toUpperCase()))
                      ]);
                }
              });
        }
      } else {
        debugPrint("permission not given");
      }
    } else {
      toToast(getTranslated("noInternetConnection"));
    }
  }

  void makeVideoCall() async {
    closeKeyBoard();
    SessionManagement.setBool(Constants.layoutSwitch, true);
    if((await Mirrorfly.isOnGoingCall()).checkNull()){
      toToast(getTranslated("msgOngoingCallAlert"));
      return;
    }
    if (await AppUtils.isNetConnected()) {
      if (await AppPermission.askVideoCallPermissions()) {
        if (profile.isGroupProfile.checkNull()) {
          NavUtils.toNamed(Routes.groupParticipants,
              arguments: {"groupId": profile.jid, "callType": CallType.video});
        } else {
          Mirrorfly.makeVideoCall(
              toUserJid: profile.jid.checkNull(),
              flyCallBack: (FlyResponse response) {
                if (response.isSuccess) {
                  setOnGoingUserGone();
                  NavUtils.toNamed(Routes.outGoingCallView, arguments: {
                    "userJid": [profile.jid],
                    "callType": CallType.video
                  })?.then((value) => setOnGoingUserAvail());
                }
              });
        }
      } else {
        LogMessage.d("askVideoCallPermissions", "false");
      }
    } else {
      toToast(getTranslated("noInternetConnection"));
    }
  }

  void loadNextChatHistory() {
    final itemPositions = newItemPositionsListener?.itemPositions.value;

    if (itemPositions != null && itemPositions.isNotEmpty) {
      final firstVisibleItemIndex = itemPositions.first.index;

      if (Platform.isIOS) {
        ///This is the top constraint changing to bottom constraint and calling nextMessages bcz reversing the list view in display
        if (firstVisibleItemIndex <= 1 &&
            double.parse(
                    itemPositions.first.itemLeadingEdge.toStringAsFixed(1)) <=
                0) {
          // Scrolled to the Bottom
          debugPrint("reached Bottom yes load next messages");
          _loadNextMessages(showLoading: false);

          ///This is the bottom constraint changing to Top constraint and calling prevMessages bcz reversing the list view in display
        } else if (firstVisibleItemIndex + itemPositions.length >=
            chatList.length) {
          // Scrolled to the Top
          _loadPreviousMessages();
          debugPrint("reached Top yes load previous msgs");
        }
      } else if (Platform.isAndroid) {
        if (firstVisibleItemIndex == 0) {
          debugPrint("reached Bottom yes load next messages");
          _loadNextMessages(showLoading: false);
        } else if (firstVisibleItemIndex + itemPositions.length >=
            chatList.length) {
          debugPrint("reached Top yes load previous msgs");
          _loadPreviousMessages();
        }
      }
    }
  }

  void cancelNotification() {
    if (!Constants.isUIKIT) {
      NotificationBuilder.cancelNotifications();
    }
  }

  void setOnGoingUserGone() {
    Mirrorfly.setOnGoingChatUser(jid: Constants.emptyString);
    SessionManagement.setCurrentChatJID(Constants.emptyString);
  }

  void setOnGoingUserAvail() {
    debugPrint("setOnGoingUserAvail");
    Mirrorfly.setOnGoingChatUser(jid: profile.jid.checkNull());
    SessionManagement.setCurrentChatJID(profile.jid.checkNull());
    markConversationReadNotifyUI();
    cancelNotification();
  }

  void onMessageDeleteNotifyUI(
      {required String chatJid, bool changePosition = true}) {
    Get.find<MainController>().onMessageDeleteNotifyUI(
        chatJid: chatJid, changePosition: changePosition);
  }

  void updateLastMessage(dynamic value) {
    clearMessage();
    ChatMessageModel chatMessageModel = sendMessageModelFromJson(value);
    loadLastMessages(chatMessageModel);
    //below method is used when message is not sent and onMessageStatusUpdate listener will not trigger till the message status was updated so notify the ui in dashboard
    Get.find<MainController>().onUpdateLastMessageUI(profile.jid.checkNull());
  }

  void onAvailableFeaturesUpdated(AvailableFeatures features) {
    LogMessage.d("ChatView", "onAvailableFeaturesUpdated ${features.toJson()}");
    updateAvailableFeature(features);
  }

  void updateAvailableFeature(AvailableFeatures features) {
    availableFeatures(features);
    var availableAttachment = <AttachmentIcon>[];
    if (features.isDocumentAttachmentAvailable.checkNull()) {
      availableAttachment.add(AttachmentIcon(Constants.attachmentTypeDocument,
          documentImg, getTranslated("attachment_Document")));
    }
    if (features.isImageAttachmentAvailable.checkNull() ||
        features.isVideoAttachmentAvailable.checkNull()) {
      availableAttachment.add(AttachmentIcon(Constants.attachmentTypeCamera,
          cameraImg, getTranslated("attachment_Camera")));
      availableAttachment.add(AttachmentIcon(Constants.attachmentTypeGallery,
          galleryImg, getTranslated("attachment_Gallery")));
    }
    if (features.isAudioAttachmentAvailable.checkNull()) {
      availableAttachment.add(AttachmentIcon(Constants.attachmentTypeAudio,
          audioImg, getTranslated("attachment_Audio")));
    }
    if (features.isContactAttachmentAvailable.checkNull()) {
      availableAttachment.add(AttachmentIcon(Constants.attachmentTypeContact,
          contactImg, getTranslated("attachment_Contact")));
    }
    if (features.isLocationAttachmentAvailable.checkNull()) {
      availableAttachment.add(AttachmentIcon(Constants.attachmentTypeLocation,
          locationImg, getTranslated("attachment_Location")));
    }
    availableAttachments(availableAttachment);
  }

  var topic = Topics().obs;

  var isChatClosed = false.obs;

  void getTopicDetail() async {
    if (topicId.isNotEmpty) {
      await Mirrorfly.getTopics(
          topicIds: [topicId],
          flyCallBack: (FlyResponse response) {
            if (response.isSuccess && response.hasData) {
              var topics = topicsFromJson(response.data);
              topic(topics.isNotEmpty ? topics[0] : null);
              //"a00251d7-d388-4f47-8672-553f8afc7e11","c640d387-8dfc-4252-b20a-d2901ebe3197","f5dc3456-cd2a-4e64-ad91-79373a867aa3","0075fe28-ec93-45c6-be3a-85004bf860a1","da757122-1a74-40ae-9c7d-0e4c2757e6bd","5d3788c1-78ef-4158-a92b-a48f092da0b9","4d83dfad-79a8-43fd-98b8-7eb8943dc8ca","0b290e7f-b05c-4859-a72d-100c48f73c8d","1ab018d1-1068-4988-8b28-fe1079e07ab2"
              LogMessage.d("getTopics by Id", response);
              LogMessage.d("getTopics [0] meta", "${topics[0].metaData}");
            }
          }).then((value) {}).catchError((onError) {
        LogMessage.d("getTopics error", onError);
      });
    }
  }

  @override
  void onHidden() {
    LogMessage.d('LifeCycle', 'chat onHidden');
  }

  void loadLastMessages(ChatMessageModel chatMessageModel) async {

    _loadNextMessages(showLoading: false);

  }

  Future<void> loadPrevORNextMessagesLoad({bool? isReplyMessage}) async {

      _loadPreviousMessages(showLoading: false);

  }

  void handleUnreadMessageSeparator(
      {bool remove = true, bool removeFromList = false}) {
    var tuple3 = findIndexOfUnreadMessageType();
    var isUnreadSeparatorIsAvailable = tuple3.item1;
    LogMessage.d("isUnreadSeparatorIsAvailable", isUnreadSeparatorIsAvailable);
    var separatorPosition = tuple3.item2;
    debugPrint(
        "handleUnreadMessageSeparator isUnreadSeparatorIsAvailable $isUnreadSeparatorIsAvailable");
    if (isUnreadSeparatorIsAvailable || chatList.isNotEmpty) {
      if (remove) {
        removeUnreadMessageSeparator(separatorPosition,
            removeFromList: removeFromList);
      } else {
        displayUnreadMessageSeparator(separatorPosition);
      }
    }
  }

  void displayUnreadMessageSeparator(int separatorPosition) {
    var shouldNotCount = chatList
        .sublist(0, separatorPosition + 1)
        .where((it) => it.isMessageSentByMe)
        .length;
    LogMessage.d(
        "displayUnreadMessageSeparator", "should not count--->$shouldNotCount");

    var defaultUnreadCountResult = 0 + (separatorPosition);
    var shouldNotCountResult = defaultUnreadCountResult - shouldNotCount;
    LogMessage.d("displayUnreadMessageSeparator",
        "should Not Count Result--->$shouldNotCountResult");

    var noOfItemsAfterUnreadMessageSeparator = shouldNotCountResult != 0
        ? shouldNotCountResult
        : chatList.length - separatorPosition - 1;
    if (noOfItemsAfterUnreadMessageSeparator != 0) {
      unreadCount(noOfItemsAfterUnreadMessageSeparator);
      var unreadMessageDetails = chatList[separatorPosition];
      if (chatList[separatorPosition].messageId == unreadMessageTypeMessageId) {
        unreadMessageDetails.messageTextContent =
            "$noOfItemsAfterUnreadMessageSeparator ${(noOfItemsAfterUnreadMessageSeparator == 1) ? "UNREAD MESSAGE" : "UNREAD MESSAGES"}";
        // chatAdapter.notifyItemChanged(separatorPosition);
      }
    } else {
      handleUnreadMessageSeparator();
    }
  }

  void removeUnreadMessageSeparator(int separatorPosition,
      {bool removeFromList = true}) {
    Mirrorfly.markAsReadDeleteUnreadSeparator(jid: profile.jid.checkNull());
    if (removeFromList && !separatorPosition.isNegative) {
      /// Commented the below as the QA posted Unread separator should display
      /// after the screen is loaded with new message - (FLUTTER-1807)
      /// On Analysing, the next message is called sometimes when the screen is loaded,
      /// So the unread separator is removed.
      /// Now, when opening 2nd time, SDK will remove the unread separator.

      // chatList.removeAt(separatorPosition);
    }
  }

  Tuple3<bool, int, String> findIndexOfUnreadMessageType() {
    LogMessage.d(
        "TAG", "findIndexOfUnreadMessageType $unreadMessageTypeMessageId");
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
      LogMessage.d("TAG", e.toString());
      return const Tuple3(false, 0, Constants.emptyString);
    }
    LogMessage.d("findIndexOfUnreadMessageType",
        "$isUnreadSeparatorIsAvailable, $position, $message");
    return Tuple3(isUnreadSeparatorIsAvailable, position, message);
  }

  int getMessagePosition(String messageId) =>
      chatList.indexWhere((it) => it.messageId == messageId);

  int lastVisiblePosition() {
    final itemPositions = newItemPositionsListener?.itemPositions.value;
    if (itemPositions != null && itemPositions.isNotEmpty) {
      final firstVisibleItemIndex = itemPositions.first.index;
      // LogMessage.d("lastVisiblePosition", "$firstVisibleItemIndex");
      return firstVisibleItemIndex;
    } else {
      // Handle the case when the list is empty
      LogMessage.d("lastVisiblePosition", "List is empty");
      return -1;
    }
  }

  void unReadMessageScrollPosition(int position) {
    try {
      if (chatList.length > position) {
        var sublist = chatList.sublist(position, chatList.length);
        if (sublist.length > 3) {
          scrollToPosition(position + 3);
        } else {
          scrollToPosition(position + 1);
        }
      } else {
        scrollToPosition(position + 1);
      }
    } catch (e) {
      LogMessage.d("TAG", e.toString());
    }
  }

  void scrollToPosition(int position) {
    if (!position.isNegative) {
      if (newScrollController != null && newScrollController!.isAttached) {
        LogMessage.d("newScrollController", "scrollToPosition");
        newScrollController?.scrollTo(
            index: position, duration: const Duration(milliseconds: 100));
      }
    }
  }

  void showError(FlyException? response) {
    if (response != null && response.message != null) {
      var errorMessage = response.message!.contains(" ErrorCode =>")
          ? response.message!.split(" ErrorCode =>")[0]
          : "${response.message!} Reason: ${response.throwable}";
      toToast(errorMessage);
    }
  }

  Future<void> editMessage() async {
    var busyStatus = !profile.isGroupProfile.checkNull()
        ? await Mirrorfly.isBusyStatusEnabled()
        : false;

    if (!busyStatus.checkNull() && !isBlocked.value) {
      showFullWindowDialog();
    } else if (isBlocked.value) {
      showBlockStatusAlert(showFullWindowDialog);
    } else if (busyStatus.checkNull()) {
      showBusyStatusAlert(showFullWindowDialog);
    }
  }

//#editMessage
  showFullWindowDialog() {
    var chatItem = selectedChatList.first;
    clearAllChatSelection();
    // Get.bottomSheet(
    //   EditMessageScreen(chatItem: chatItem, chatController: this),
    //   ignoreSafeArea: false,
    //   enableDrag: false,
    //   isScrollControlled: true, // Important for full screen
    // );

    DialogUtils.bottomSheet(
      EditMessageScreen(chatItem: chatItem, chatController: this),
      ignoreSafeArea: true,
      isScrollControlled: true,
      enableDrag: false,
    );
  }

  Widget emojiLayout(
      {required MentionTagTextEditingController textEditingController,
      required bool sendTypingStatus}) {
    return Obx(() {
      if (showEmoji.value) {
        return EmojiLayout(
            textController:
                textEditingController, //controller.addStatusController,
            onBackspacePressed: () {
              if (sendTypingStatus) {
                isTyping();
              } else {
                editMessageText(textEditingController.text);
              }
              enterEmojiMention(textEditingController: textEditingController);
            },
            onEmojiSelected: (cat, emoji) {
              if (sendTypingStatus) {
                isTyping();
              } else {
                editMessageText(textEditingController.text);
              }
              enterEmojiMention(textEditingController: textEditingController);
            });
      } else {
        return const Offstage();
      }
    });
  }

  void enterEmojiMention(
      {required MentionTagTextEditingController textEditingController}) {
    textEditingController.onChanged(textEditingController.text);
    setUnSentMessageInTextField(textEditingController,
        textEditingController.text, textEditingController.getTags);
  }

  //#editMessage
  void updateSentMessage({required ChatMessageModel chatItem}) {
    if (isWithinLast15Minutes(chatItem.messageSentTime)) {
      if (chatItem.messageType == Constants.mText ||
          chatItem.messageType == Constants.mAutoText) {
        Mirrorfly.editTextMessage(
            editMessageParams: EditMessageParams(
                messageId: chatItem.messageId,
                mentionedUsersIds: editMessageController.getTags,
                editedTextContent: editMessageController.formattedText.trim()),
            flyCallback: (FlyResponse response) {
              debugPrint("Edit Message ==> $response");
              if (response.isSuccess) {
                NavUtils.back();
                ChatMessageModel editMessage =
                    sendMessageModelFromJson(response.data);
                final index = chatList.indexWhere(
                    (message) => message.messageId == editMessage.messageId);
                debugPrint("Edit Message Status Update index of search $index");
                debugPrint("messageID--> $index  ${editMessage.messageId}");
                if (!index.isNegative) {
                  chatList[index] = editMessage;
                }
              }
            });
      } else if (chatItem.messageType == Constants.mImage ||
          chatItem.messageType == Constants.mVideo) {
        Mirrorfly.editMediaCaption(
            editMessageParams: EditMessageParams(
                messageId: chatItem.messageId,
                editedTextContent: editMessageController.formattedText.trim(),
                mentionedUsersIds: editMessageController.getTags),
            flyCallback: (FlyResponse response) {
              debugPrint("Edit Media Caption ==> $response");
              if (response.isSuccess) {
                NavUtils.back();
                ChatMessageModel editMessage =
                    sendMessageModelFromJson(response.data);
                final index = chatList.indexWhere(
                    (message) => message.messageId == editMessage.messageId);
                debugPrint("Edit Message Status Update index of search $index");
                debugPrint("messageID--> $index  ${editMessage.messageId}");
                if (!index.isNegative) {
                  chatList[index] = editMessage;
                }
              }
            });
      }
    } else {
      toToast(getTranslated("unableEditMessage"));
    }
  }

  //#editMessage
  void onMessageEdited(ChatMessageModel editedChatMessage) {
    if (editedChatMessage.chatUserJid == profile.jid) {
      final index = chatList.indexWhere(
          (message) => message.messageId == editedChatMessage.messageId);
      debugPrint("ChatScreen Edit Message Update index of search $index");
      debugPrint("messageID--> $index  ${editedChatMessage.messageId}");
      if (!index.isNegative) {
        debugPrint("messageID--> replacing the value");
        chatList[index] = editedChatMessage;
        // chatList.refresh();
      }
    }
    if (isSelected.value) {
      var selectedIndex = selectedChatList.indexWhere(
          (message) => editedChatMessage.messageId == message.messageId);
      if (!selectedIndex.isNegative) {
        editedChatMessage.isSelected(true);
        selectedChatList[selectedIndex] = editedChatMessage;
        selectedChatList.refresh();
        getMessageActions();
      }
    }
  }

  //show meet bottom sheet
  Future<void> showMeetBottomSheet(
      {MeetBottomSheetStyle? meetBottomSheetStyle,
      bool? isEnableSchedule}) async {
    if (await AppUtils.isNetConnected()) {
      if (isAudioRecording.value == Constants.audioRecording) {
        stopRecording();
      }
      DialogUtils.bottomSheet(
        MeetSheetView(
          title: getTranslated("instantMeet"),
          description: getTranslated("copyTheLink"),
          meetBottomSheetStyle: meetBottomSheetStyle!,
          isEnableSchedule: isEnableSchedule ?? false,
        ),
        ignoreSafeArea: true,
        backgroundColor: Colors.white,
        barrierColor: Colors.black.withOpacity(0.5),
      );
    } else {
      toToast(getTranslated("noInternetConnection"));
    }
  }
}
