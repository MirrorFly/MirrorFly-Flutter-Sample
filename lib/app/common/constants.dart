import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';


// Icon Package Name

String? iconPackageName; //= 'mirrorfly_uikit_plugin/lib';

//Colors
const Color appBarColor = Color(0xffF2F2F2);
const Color iconColor = Color(0xff181818);
const Color iconBgColor = Color(0xff9D9D9D);
const Color appbarTextColor = Color(0xff181818);
const Color statusBarColor = Color(0xffE5E5E5);
const Color textBlackColor = Color(0xff000000);
const Color textBlack1color = Color(0xff313131);
const Color textHintColor = Color(0xff181818);
const Color textColor = Color(0xff767676);
const Color textColorBlack = Color(0xff333333);
const Color textButtonColor = Color(0xffFFFFFF);
const Color buttonBgColor = Color(0xff3276E2);
const Color chatSentBgColor = Color(0xffe2eafc);
const Color chatReplyContainerColor = Color(0xffD0D8EB);
const Color chatReplySenderColor = Color(0xffEFEFEF);
const Color dividerColor = Color(0XffE2E2E2);
const Color audioColor = Color(0XffB9C1D6);
const Color audioColorDark = Color(0Xff848FAD);
const Color audioBgColor = Color(0Xff848FAD);
const Color bottomSheetColor = Color(0Xff242A3F);
const Color notificationTextColor = Color(0Xff565656);
const Color notificationTextBgColor = Color(0XffDADADA);
const Color chatBorderColor = Color(0XffDDE3E5);
const Color chatTimeColor = Color(0Xff959595);
const Color borderColor = Color(0xffAFB8D0);
const Color playIconColor = Color(0xff7285B5);
const Color progressColor = Color(0xff8C97B3);
const Color durationTextColor = Color(0xff455E93);
const Color chatBgColor = Color(0xffD0D8EB);
const Color previewTextColor = Color(0xff7f7f7f);
const Color callsSubText = Color(0Xff737373);
const Color notificationAlertBg = Color(0xffEFF4FD);

class AppColors{
  static const Color callerBackground = Color(0xff152134);
  static const Color bottomCallOptionBackground = Color(0xff162337);
  static const Color callOptionBackground = Color(0xff10294d);
  static const Color callAgainButtonBackground = Color(0xff009f46);
  static const Color audioCallBackground = Color(0xff0B111C);
  static const Color audioCallerBackground = Color(0xff0D2852);
  static const Color callerTitleBackground = Color(0xff151F32);
  static const Color colorBlackTransparent = Color(0x80000000);
  static const Color callerStatus = Color(0xffDEDEDE);
  static const Color callerName = Color(0xffffffff);
  static const Color endButton = Color(0xffff4d67);
  static const Color audioMutedIconBgColor = Color(0x80000000);
  static const Color checkBoxBorder = Color(0xffbdbdbd);
  static const Color checkBoxChecked = Color(0xff30c076);
  static const Color callBg = Color(0xff0B111C);
  static const Color speakingBg = Color(0xff3abf87);
  static const Color transBlack75 = Color(0xBF000000);
  static const Color participantUnMuteColor = Color(0xffe3e2e2);
}
//call Assets
const String plusIcon = 'assets/calls/plus_icon.svg';
const String audioCallSmallIcon = 'assets/calls/audio_call_small_icon.svg';
const String videoCallSmallIcon = 'assets/calls/video_call_small_icon.svg';
const String callMutedIcon = 'assets/calls/call_muted_icon.svg';
const String callEndButton = 'assets/calls/call_end_button.svg';
const String speakerInactive = 'assets/calls/speaker_inactive.svg';
const String speakerActive = 'assets/calls/speaker_active.svg';
const String speakerBluetooth = 'assets/calls/bluetooth.svg';
const String speakerHeadset = 'assets/calls/head_set.svg';
const String audioCallAgain = 'assets/calls/call_icon.svg';
const String videoCallAgain = 'assets/calls/video_call.svg';
const String callCancel = 'assets/calls/cancel_icon.svg';
const String gridIcon = 'assets/calls/grid_icon.svg';

const String audioCallIcon = 'assets/calls/audiocall.svg';
const String videoCallIcon = 'assets/calls/videocall.svg';

const String videoInactive = 'assets/calls/video_inactive.svg';
const String videoActive = 'assets/calls/video_active.svg';
const String muteActive = 'assets/calls/mute_active.svg';
const String muteInactive = 'assets/calls/mute_inactive.svg';
const String addUserCall = 'assets/calls/ic_add_user.svg';
const String audioMute = 'assets/calls/ic_audio_mute.svg';
const String moreMenu = 'assets/calls/ic_call_more_menu.svg';
const String unpinUser = 'assets/calls/ic_unpin_user.svg';
const String cameraSwitchInactive = 'assets/calls/camera_switch_inactive.svg';
const String cameraSwitchActive = 'assets/calls/camera_switch_active.svg';
const String callOptionsUpArrow = 'assets/calls/call_options_up_arrow.svg';
const String callOptionsBottomBg = 'assets/calls/ic_group_user_info_layout.png';
const String callOptionsToolbarBg = 'assets/calls/ic_call_header_overlay.png';

//Meeting Assets
const String meetSchedule = 'assets/calls/schedule_meet.svg';


//Call Participant assets
const String participantMute = 'assets/calls/participant_mute.svg';
const String participantUnMute = 'assets/calls/participant_unmute.svg';
const String participantVideoEnabled = 'assets/calls/participant_video_enabled.svg';
const String participantVideoDisabled = 'assets/calls/participant_video_disabled.svg';
const String addParticipantsInCall = 'assets/calls/add_user_in_call.svg';


//Assets
const String mirrorflySmall = 'assets/logos/ic_notification_small.png';
const String registerIcon = 'assets/logos/register_logo.svg';
const String statusIcon = 'assets/logos/status.svg';
const String searchIcon = 'assets/logos/magnifying_glass.svg';
const String chatFabIcon = 'assets/logos/chat_fab.svg';
const String moreIcon = 'assets/logos/shape.svg';
const String noContactsIcon = 'assets/logos/no_contacts.png';
const String noChatIcon = 'assets/logos/no_messages.png';
const String noCallImage = 'assets/logos/ic_no_call_history.webp';
const String profileIcon = 'assets/logos/avatar.svg';
const String rightArrowIcon = 'assets/logos/forward_arrow.svg';
const String chatIcon = 'assets/logos/chat.svg';
const String staredMsgIcon = 'assets/logos/stared message.svg';
const String notificationIcon = 'assets/logos/Notifications.svg';
const String notificationPermissionIcon = 'assets/logos/notification_icon.svg';
const String tickRound = 'assets/logos/tick_round.svg';
const String tickRoundBlue = 'assets/logos/tick_round_blue.svg';
const String blockedIcon = 'assets/logos/blocked_contacts.svg';
const String archiveIcon = 'assets/logos/Archive_ic_settings.svg';
const String lockIcon = 'assets/logos/lock.svg';
const String lockOutlineBlack = 'assets/logos/lock_outline_black.svg';
const String delete = 'assets/logos/delete_black.svg';
const String aboutIcon = 'assets/logos/About and Help.svg';
const String connectionIcon = 'assets/logos/antenna.svg';
const String toggleOffIcon = 'assets/logos/toggle OFF.svg';
const String reportIcon = 'assets/logos/stared message-1.svg';
const String logoutIcon = 'assets/logos/logout.svg';
const String pencilEditIcon = 'assets/logos/pencil.svg';
const String tickIcon = 'assets/logos/tick.svg';
const String smileIcon = 'assets/logos/smile.svg';
const String icQrScannerWebLogin = 'assets/logos/ic_qr_scanner_web_login.png';
const String redirectLastMessage = 'assets/logos/ic_redirect_last_message.png';

const String icLogo = 'assets/logos/ic_logo.png';
const String icChrome = 'assets/logos/ic_chrome.png';
const String icEdgeBrowser = 'assets/logos/ic_edge_browser.png';
const String icMozilla = 'assets/logos/ic_mozilla.png';
const String icSafari = 'assets/logos/ic_safari.png';
const String icIe = 'assets/logos/ic_ie.png';
const String icOpera = 'assets/logos/ic_opera.png';
const String icUc = 'assets/logos/ic_uc.png';
const String icDefaultBrowser = 'assets/logos/ic_default_browser.png';
const String eyeOn = 'assets/logos/eye_on.png';
const String eyeOff = 'assets/logos/eye_off.png';

//Dashboard Recent Chats
const String archive = 'assets/logos/archive.svg';
const String unarchive = 'assets/logos/unarchive.svg';
const String mute = 'assets/logos/mute.svg';
const String unMute = 'assets/logos/unmute.svg';
const String pushpin = 'assets/logos/pushpin.svg';
const String pin = 'assets/logos/pin.svg';
const String unpin = 'assets/logos/unpin.svg';

const String audioRecordIcon = 'assets/logos/audio_record_icon.svg';
const String sendIcon = 'assets/logos/send.svg';
const String audioImg = 'assets/logos/headset_img.svg';
const String headsetImg = 'assets/logos/headset_white.svg';
const String documentImg = 'assets/logos/document_icon.svg';
const String cameraImg = 'assets/logos/camera.svg';
const String contactImg = 'assets/logos/contact_icon.svg';
const String galleryImg = 'assets/logos/gallery.svg';
const String locationImg = 'assets/logos/location_icon.svg';
const String rightArrow = 'assets/logos/right_arrow.svg';
const String previewAddImg = 'assets/logos/preview_add.svg';

const String downloading = 'assets/logos/downloading.svg';
const String videoPlay = 'assets/logos/video_play.svg';
const String videoCamera = 'assets/logos/video_camera.svg';
const String audioPlay = 'assets/logos/audio_play.svg';
const String audioMicBg = 'assets/logos/audio_mic.svg';
const String audioMic = 'assets/logos/mic.svg';
const String audioMic1 = 'assets/logos/mic1.svg';
const String musicIcon = 'assets/logos/music_icon.svg';
const String profileImage = 'assets/logos/profile_img.png';

const String linkImage = 'assets/logos/link.svg';
const String txtImage = 'assets/logos/txt.svg';
const String csvImage = 'assets/logos/csv.svg';
const String pdfImage = 'assets/logos/pdf.svg';
const String pptImage = 'assets/logos/ppt.svg';
const String pptxImage = 'assets/logos/pptx.svg';
const String xlsImage = 'assets/logos/xls.svg';
const String xlsxImage = 'assets/logos/xlsx.svg';
const String docImage = 'assets/logos/doc.svg';
const String docxImage = 'assets/logos/docx.svg';
const String apkImage = 'assets/logos/apk.svg';
const String mContactIcon = 'assets/logos/contact_chat.svg';
const String mDocumentIcon = 'assets/logos/document_chat.svg';
const String zipImage = 'assets/logos/zip.svg';
const String rarImage = 'assets/logos/rar.svg';
const String mImageIcon = 'assets/logos/image.svg';
const String mLocationIcon = 'assets/logos/location_chat.svg';
const String mVideoIcon = 'assets/logos/ic_video.svg';
const String mAudioIcon = 'assets/logos/noun_Audio_3408360.svg';
const String mAudioRecordIcon = 'assets/logos/record_reply_preview.svg';
const String audioWhite = 'assets/logos/audio_white.svg';
const String videoWhite = 'assets/logos/video_icon.svg';
const String cornerShadow = 'assets/logos/ic_baloon.png';
const String disabledIcon = 'assets/logos/disabled.png';
const String chatBgIcon = 'assets/logos/chat_bg.png';
const String attachIcon = 'assets/logos/attach.svg';

const String arrowDropDown = 'assets/calls/ic_arrow_down_red.svg';
const String arrowUpIcon = 'assets/calls/ic_arrow_up_green.svg';
const String arrowDownIcon = 'assets/calls/ic_arrow_down_green.svg.svg';

const String phoneCall = 'assets/logos/phonecall.svg';
const String videoCall = 'assets/logos/videocall.svg';
const String call = 'assets/logos/call.svg';

const String quickCall = 'assets/logos/quick_call.svg';
const String quickInfo = 'assets/logos/quick_info.svg';
const String quickMessage = 'assets/logos/quick_message.svg';
const String quickVideo = 'assets/logos/quick_video.svg';

const String replyIcon = 'assets/logos/reply.svg';
const String forwardIcon = 'assets/logos/forward.svg';
const String deleteIcon = 'assets/logos/delete_black.svg';
const String cancelIcon = 'assets/logos/close.svg';
const String favouriteIcon = 'assets/logos/star.svg';
const String unFavouriteIcon = 'assets/logos/unstar.svg';
const String copyIcon = 'assets/logos/copy.svg';
const String infoIcon = 'assets/logos/info.svg';
const String uploadIcon = 'assets/logos/upload.svg';
const String downloadIcon = 'assets/logos/download.svg';
const String playIcon = 'assets/logos/play.svg';
const String pauseIcon = 'assets/logos/pause.svg';
const String shareIcon = 'assets/logos/share.svg';
const String starSmallIcon = 'assets/logos/star_small_icon.svg';

const String seenIcon = 'assets/logos/seen.svg';
const String unSendIcon = 'assets/logos/unsent.svg';
const String deliveredIcon = 'assets/logos/delivered.svg';
const String acknowledgedIcon = 'assets/logos/acknowledged.svg';

//Animation
const String deleteDustbin = 'assets/animation/delete_dustbin.json';
const String audioJson = 'assets/animation/enable_mic.json';
const String audioJson1 = 'assets/animation/enable_mic1.json';

const String profileImg = 'assets/logos/profile_img.png';
const String groupImg = 'assets/logos/ic_grp_bg.png';
const String imageEdit = 'assets/logos/ic_image_edit.svg';
const String edit = 'assets/logos/ic_edit.svg';
const String imageOutline = 'assets/logos/image_outline.svg';
const String addUser = 'assets/logos/add_user.svg';
const String reportUser = 'assets/logos/report_user.svg';
const String reportGroup = 'assets/logos/report_group.svg';
const String leaveGroup = 'assets/logos/leave_group.svg';

const String contactSelectTick = 'assets/logos/contact_select.svg';
const String rightArrowProceed = 'assets/logos/right_arrow_proceed.svg';
const String closeContactIcon = 'assets/logos/close_icon_contact.svg';

const String emailIcon = 'assets/logos/email.svg';
const String phoneIcon = 'assets/logos/phone.svg';
const String deleteBin = 'assets/logos/delete_bin.svg';
const String deleteBinWhite = 'assets/logos/delete_bin_white.svg';
const String warningIcon = 'assets/logos/warning.svg';

const String filePermission = "assets/logos/file_permission.svg";
const String audioPermission = "assets/logos/audio_permission.svg";
const String cameraPermission = "assets/logos/camera_permission.svg";
const String contactPermission = "assets/logos/contact_permission.svg";
const String contactSyncPermission = "assets/logos/contact_media_permission.svg";
const String settingsPermission = "assets/logos/settings_permission.svg";
const String locationPinPermission = "assets/logos/location_pin_permission.svg";
const String recordAudioVideoPermission =
    "assets/logos/record_audio_video_permission.svg";
const String notificationAlertPermission = 'assets/calls/ic_notification_alert.svg';

const String icAdminBlocked = "assets/logos/ic_admin_blocked.svg";
const String icExpand = "assets/logos/ic_expand.svg";
const String icCollapse = "assets/logos/ic_collapse.svg";

const String forwardMedia = "assets/logos/forward_media.svg";
const String arrowDown = "assets/logos/arrow_down.svg";
const String arrowUp = "assets/logos/arrow_up.svg";

const String mediaBg = "assets/logos/ic_baloon.svg";

//contact sync
const String syncIcon = "assets/logos/sync.svg";
const String contactSyncBg = "assets/logos/contact_sync_bg.png";
const String contactBookFill = "assets/logos/contacts_book_fill.svg";
const String emailContactIcon = "assets/logos/emailcontact_icon.svg";

const String icBioBackground = "assets/logos/ic_bio_background.png";
const String icDeleteIcon = "assets/logos/ic_delete_icon.svg";


//About us
const String titleContactMsg = "Mirror Fly is a ready-to-go messaging solution for building enterprise-grade real-time chat IM applications that meet various degrees of requirements like team discussion, data sharing, task delegation and information handling on the go.";
const String titleContactUs = "Contact Us";
const String titleContactMsgTime = "To have a detailed interaction with our experts";
const String titleFaq = "FAQ";
const String titleFaqMsg = "Kindly checkout FAQ section for doubts regarding Mirror fly. We might have already answered your question.";
const String mirrorFly = "Mirror Fly";
const String websiteMirrorFly = "https://www.mirrorfly.com/";
const String notificationNotWorkingURL = "https://app.mirrorfly.com/notifications/";

toToast(String text) {
  if(Platform.isIOS) {
    FocusManager.instance.primaryFocus?.unfocus();
  }
  Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      textColor: Colors.black,
      backgroundColor: Colors.white,
      fontSize: 16.0);
}

class Constants {
  static MetaDataUserList? metaDataUserList = MetaDataUserList(key: "platform", value: ["flutter"]);
  static const bool enableContactSync = false;
  static const bool enableTopic = false;
  static const String topicId = enableTopic ? "5d3788c1-78ef-4158-a92b-a48f092da0b9" : "";//Mirrorfly Topic id
  static const String packageName = "com.contus.flycommons.";
  static const String package = 'com.mirrorfly.uikit_flutter';
  static const String emptyString = "";
  static const String webChatLogin = 'https://webchat-uikit-qa.contus.us/';
  static const maxNameLength = 26;
  static const callNotificationId = 124;

  static const appSession = 'app_session';
  static const changedPinAt = 'pin_changed_at';
  static const alertDate = 'alertDate';
  static const expiryDate = 'expiryDate';
  static const sessionLockTime = 32;//in Seconds
  static const pinExpiry = 31;//in Days
  static const pinAlert = pinExpiry-5;//in Days



  static const mobileImageMaxWidth = 250;
  static const mobileImageMinWidth = 210;
  static const mobileImageMaxHeight = 320;
  static const mobileImageMinHeight = 80;

  //asked permission
  static const locationPermissionAsked = "location_permission_asked_before";
  static const contactPermissionAsked = "contact_permission_asked_before";
  static const contactSavePermissionAsked = "contact_save_permission_asked_before";
  static const storagePermissionAsked = "storage_permission_asked_before";
  static const notificationPermissionAsked = "notification_permission_asked_before";

  static const audioRecordPermissionAsked = "audio_record_permission_asked_before";
  static const cameraPermissionAsked = "camera_permission_asked_before";
  static const readPhoneStatePermissionAsked = "read_phone_state_asked_before";
  static const bluetoothPermissionAsked = "bluetooth_permission_asked_before";

  static const List<int> defaultColorList = [
    0Xff9068BE,
    0XffE62739,
    0Xff845007,
    0Xff3A4660,
    0Xff1D1E22,
    0XffBE7D6A,
    0Xff005995,
    0Xff600473,
    0XffCD5554,
    0Xff00303F,
    0XffBE4F0C,
    0Xff4ABDAC,
    0XffFC4A1A,
    0Xff368CBF,
    0Xff7EBC59,
    0Xff201D3A,
    0Xff269CCC,
    0Xff737272,
    0Xff237107,
    0Xff52028E,
    0XffAF0D74,
    0Xff6CB883,
    0Xff0DAFA4,
    0XffA71515,
    0Xff157FA7,
    0Xff7E52B1,
    0Xff27956A,
    0Xff9A4B70,
    0XffFBBE30,
    0XffED3533,
    0Xff571C8D,
    0Xff54181C,
    0Xff9B6700,
    0Xff6E8E14,
    0Xff0752A1,
    0XffBF6421,
    0Xff00A59C,
    0Xff9F0190,
    0XffAE3A3A,
    0Xff858102,
    0Xff027E02,
    0XffF66E54
  ];

  //Message Types
  static const String mAutoText = "AUTO_TEXT";
  static const String mText = "TEXT";
  static const String mImage = "IMAGE";
  static const String mAudio = "AUDIO";
  static const String mVideo = "VIDEO";
  static const String mContact = "CONTACT";
  static const String mLocation = "LOCATION";
  static const String mDocument = "DOCUMENT";
  static const String mFile = "FILE";
  static const String mNotification = "NOTIFICATION";

  static const String composing = "composing";
  static const String gone = "Gone";

  //Audio Recording Types
  static const String audioRecording = "AUDIO_RECORDING";
  static const String audioRecordDone = "AUDIO_RECORDING_COMPLETED";
  static const String audioRecordDelete = "AUDIO_RECORDING_DELETE";
  static const String audioRecordInitial = "AUDIO_RECORDING_NOT_INITIALIZED";

  static const editMessageTimeLimit = 15; // in Minutes

  static const int minGroupMembers = 2;

  static const String msgTypeText = "text";
  static const String msgTypeNotification = "notification";

  static const String typeSearchRecent = "Chats";
  static const String typeSearchContact = "Contact";
  static const String typeSearchMessage = "Message";

  static const String emailPattern =
  ("^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,3})\$");
  static const String countryCodePattern = r'(^(\+?[0-9]{1,4}\-?)$)';

  static const String bulletPoint = "\u2022 ";

  //Picker Type
  static const String camera = "camera_pick";
  static const String gallery = "gallery_pick";

  //data usage
  static const photo = "Photos";
  static const audio = "Audio";
  static const video = "Videos";
  static const document = "Documents";

  //Attachment Type
  static const String attachmentTypeDocument = "document";
  static const String attachmentTypeCamera = "camera";
  static const String attachmentTypeGallery = "gallery";
  static const String attachmentTypeAudio = "audio";
  static const String attachmentTypeContact = "contact";
  static const String attachmentTypeLocation = "location";

}

