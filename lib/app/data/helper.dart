import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:flysdk/flysdk.dart';
import 'package:mirror_fly_demo/app/data/session_management.dart';
import 'package:url_launcher/url_launcher.dart';

import 'apputils.dart';

class Helper {
  static void showLoading({String? message, bool dismiss = false}) {
    Get.dialog(
      Dialog(
        child: WillPopScope(
          onWillPop: () async {
            return Future.value(dismiss);
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 16),
                Text(message ?? 'Loading...'),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static void progressLoading({bool dismiss = false}) {
    Get.dialog(
        AlertDialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          content: WillPopScope(
            onWillPop: () async => Future.value(dismiss),
            child: const SizedBox(
              width: 60,
              height: 60,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ),
        barrierDismissible: dismiss,
        barrierColor: Colors.transparent);
  }

  static void showAlert(
      {String? title,
      required String message,
      List<Widget>? actions,
      Widget? content}) {
    Get.dialog(
      AlertDialog(
        title: title != null
            ? Text(
                title,
                style: const TextStyle(fontSize: 17),
              )
            : const SizedBox.shrink(),
        contentPadding: title != null
            ? const EdgeInsets.only(top: 15, right: 25, left: 25, bottom: 0)
            : const EdgeInsets.only(top: 0, right: 25, left: 25, bottom: 5),
        content: content ??
            Text(
              message,
              style: const TextStyle(
                  color: textHintColor, fontWeight: FontWeight.normal),
            ),
        contentTextStyle:
            const TextStyle(color: textHintColor, fontWeight: FontWeight.w500),
        actions: actions,
      ),
    );
  }

  static void showButtonAlert({List<Widget>? actions}) {
    Get.dialog(
      AlertDialog(
        actions: actions,
      ),
    );
  }

//hide loading
  static void hideLoading() {
    if (Get.isDialogOpen!) {
      Get.back(
        canPop: true,
      );
    }
  }

  static String formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  static String durationToString(Duration duration) {
    return (duration.inMilliseconds / 100)
        .toStringAsFixed(2)
        .replaceFirst('.', ':')
        .padLeft(5, '0');
  }

  static String getMapImageUri(double latitude, double longitude) {
    var key = Constants.googleMapKey;
    return ("https://maps.googleapis.com/maps/api/staticmap?center=$latitude,$longitude&zoom=13&size=300x200&markers=color:red|$latitude,$longitude&key=$key");
  }

  static int getColourCode(String name) {
    if (name == Constants.you) return 0Xff000000;
    var colorsArray = Constants.defaultColorList;
    var hashcode = name.hashCode;
    var rand = hashcode % colorsArray.length;
    return colorsArray[(rand).abs()];
  }

  static Widget forMessageTypeIcon(String? messageType,
      [bool isAudioRecorded = false]) {
    mirrorFlyLog("iconfor", messageType.toString());
    switch (messageType?.toUpperCase()) {
      case Constants.mImage:
        return SvgPicture.asset(
          mImageIcon,
          fit: BoxFit.contain,
          color: playIconColor,
        );
      case Constants.mAudio:
        return SvgPicture.asset(
          isAudioRecorded ? mAudioRecordIcon : mAudioIcon,
          fit: BoxFit.contain,
          color: playIconColor,
        );
      case Constants.mVideo:
        return SvgPicture.asset(
          mVideoIcon,
          fit: BoxFit.contain,
          color: playIconColor,
        );
      case Constants.mDocument:
        return SvgPicture.asset(
          mDocumentIcon,
          fit: BoxFit.contain,
          color: playIconColor,
        );
      case Constants.mFile:
        return SvgPicture.asset(
          mDocumentIcon,
          fit: BoxFit.contain,
          color: playIconColor,
        );
      case Constants.mContact:
        return SvgPicture.asset(
          mContactIcon,
          fit: BoxFit.contain,
          color: playIconColor,
        );
      case Constants.mLocation:
        return SvgPicture.asset(
          mLocationIcon,
          fit: BoxFit.contain,
          color: playIconColor,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  static String forMessageTypeString(String? messageType) {
    switch (messageType?.toUpperCase()) {
      case Constants.mImage:
        return "Image";
      case Constants.mAudio:
        return "Audio";
      case Constants.mVideo:
        return "Video";
      case Constants.mDocument:
        return "Document";
      case Constants.mFile:
        return "Document";
      case Constants.mContact:
        return "Contact";
      case Constants.mLocation:
        return "Location";
      default:
        return "";
    }
  }

  static String capitalize(String str) {
    return "${str[0].toUpperCase()}${str.substring(1).toLowerCase()}";
  }
}

bool checkFileUploadSize(String path, String mediaType) {
  var file = File(path);
  int sizeInBytes = file.lengthSync();
  debugPrint("file size --> $sizeInBytes");
  double sizeInMb = sizeInBytes / (1024 * 1024);
  debugPrint("sizeInBytes $sizeInMb");

  // debugPrint(getFileSizeText(sizeInBytes.toString()));

  if (mediaType == Constants.mImage && sizeInMb < 10) {
    return true;
  } else if ((mediaType == Constants.mAudio ||
          mediaType == Constants.mVideo ||
          mediaType == Constants.mDocument) &&
      sizeInMb < 20) {
    return true;
  } else {
    return false;
  }
}

String getFileSizeText(String fileSizeInBytes) {
  var fileSizeBuilder = "";
  var fileSize = int.parse(fileSizeInBytes);
  if (fileSize > 1073741824) {
    fileSizeBuilder =
        (getRoundedFileSize(fileSize / 1073741824)).toString() + (" ") + ("GB");
  } else if (fileSize > 1048576) {
    fileSizeBuilder =
        (getRoundedFileSize(fileSize / 1048576)).toString() + (" ") + ("MB");
  } else if (fileSize > 1024) {
    fileSizeBuilder =
        (getRoundedFileSize(fileSize / 1024)).toString() + (" ") + ("KB");
  } else {
    fileSizeBuilder = (fileSizeInBytes).toString() + (" ") + ("bytes");
  }
  return fileSizeBuilder.toString();
}

double getRoundedFileSize(double unscaledValue) {
  //return BigDecimal.valueOf(unscaledValue).setScale(2, RoundingMode.HALF_UP).toDouble()
  return unscaledValue.roundToDouble();
}

extension FileFormatter on num {
  String readableFileSize({bool base1024 = true}) {
    final base = base1024 ? 1024 : 1000;
    if (this <= 0) return "0";
    final units = ["bytes", "KB", "MB", "GB", "TB"];
    int digitGroups = (log(this) / log(base)).round();
    return "${NumberFormat("#,##0.#").format(this / pow(base, digitGroups))} ${units[digitGroups]}";
  }
}

String getDateFromTimestamp(int convertedTime, String format) {
  var calendar = DateTime.fromMicrosecondsSinceEpoch(convertedTime);
  return DateFormat(format).format(calendar);
}

extension StringParsing on String? {
  //check null
  String checkNull() {
    return this ?? "";
  }

  int checkIndexes(String searchedKey) {
    var i = -1;
    if (i == -1 || i < searchedKey.length) {
      while (this!.contains(searchedKey, i + 1)) {
        i = this!.indexOf(searchedKey, i + 1);

        if (i == 0 ||
            (i > 0 &&
                (RegExp("[^A-Za-z0-9 ]").hasMatch(this!.split("")[i]) ||
                    this!.split("")[i] == " "))) {
          return i;
        }
        i++;
      }
    }
    return -1;
  }

  bool startsWithTextInWords(String text) {
    return !this!.toLowerCase().contains(text.toLowerCase())
        ? false
        : this!.toLowerCase().startsWith(text.toLowerCase());
    //checkIndexes(text)>-1;
    /*return when {
      this.indexOf(text, ignoreCase = true) <= -1 -> false
      else -> return this.checkIndexes(text) > -1
    }*/
  }
}

extension BooleanParsing on bool? {
  //check null
  bool checkNull() {
    return this ?? false;
  }
}

extension MemberParsing on Member {
  bool isDeletedContact() {
    return contactType == "deleted_contact";
  }
  String getUsername() {
    var value = FlyChat.getProfileDetails(jid.checkNull(), false);
    var str = Profile.fromJson(json.decode(value.toString()));
    return getName(str);//str.name.checkNull();
  }

  Future<Profile> getProfileDetails() async {
    var value = await FlyChat.getProfileDetails(jid.checkNull(), false);
    var str = Profile.fromJson(json.decode(value.toString()));
    return str;
  }
  bool isItSavedContact(){
    return contactType == 'live_contact';
  }
  bool isUnknownContact(){
    return !isDeletedContact() && !isItSavedContact() && !isGroupProfile.checkNull();
  }
  bool isEmailContact() => !isGroupProfile.checkNull() && isGroupInOfflineMode.checkNull(); // for email contact isGroupInOfflineMode will be true
}

Future<Profile> getProfileDetails(String jid) async {
  var value = await FlyChat.getProfileDetails(jid.checkNull(), false);
  // profileDataFromJson(value);
  debugPrint("update profile--> $value");
  var profile = await compute(profiledata, value.toString());
  // var str = Profile.fromJson(json.decode(value.toString()));
  return profile;
}

Future<ChatMessageModel> getMessageOfId(String mid) async {
  var value = await FlyChat.getMessageOfId(mid.checkNull());
  debugPrint("message--> $value");
  var chatMessage = await compute(sendMessageModelFromJson, value.toString());
  return chatMessage;
}

extension ProfileParesing on Profile {
  bool isDeletedContact() {
    return contactType == "deleted_contact";
  }

  String getChatType() {
    return (isGroupProfile ?? false)
        ? Constants.typeGroupChat
        : Constants.typeChat;
  }
  bool isItSavedContact(){
    return contactType == 'live_contact';
  }
  bool isUnknownContact(){
    return !isDeletedContact() && !isItSavedContact() && !isGroupProfile.checkNull();
  }
  bool isEmailContact() => !isGroupProfile.checkNull() && isGroupInOfflineMode.checkNull(); // for email contact isGroupInOfflineMode will be true

}

extension ChatmessageParsing on ChatMessageModel {
  bool isMediaDownloaded() {
    return isMediaMessage() &&
        (mediaChatMessage?.mediaDownloadStatus == Constants.mediaDownloaded);
  }

  bool isMediaUploaded() {
    return isMediaMessage() &&
        (mediaChatMessage?.mediaUploadStatus == Constants.mediaUploaded);
  }

  bool isMediaMessage() => (isAudioMessage() ||
      isVideoMessage() ||
      isImageMessage() ||
      isFileMessage());

  bool isTextMessage() => messageType == Constants.mText;

  bool isAudioMessage() => messageType == Constants.mAudio;

  bool isImageMessage() => messageType == Constants.mImage;

  bool isVideoMessage() => messageType == Constants.mVideo;

  bool isFileMessage() => messageType == Constants.mDocument;

  bool isNotificationMessage() =>
      messageType.toUpperCase() == Constants.mNotification;
}

extension RecentChatParsing on RecentChatData {
  String getChatType() {
    return (isGroup.checkNull())
        ? Constants.typeGroupChat
        : (isBroadCast.checkNull())
            ? Constants.typeBroadcastChat
            : Constants.typeChat;
  }
  bool isDeletedContact() {
    return contactType == "deleted_contact";
  }

  bool isItSavedContact(){
    return contactType == 'live_contact';
  }
  bool isUnknownContact(){
    return !isDeletedContact() && !isItSavedContact() && !isGroup.checkNull();
  }
  bool isEmailContact() => !isGroup.checkNull() && isGroupInOfflineMode.checkNull(); // for email contact isGroupInOfflineMode will be true
}

String returnFormattedCount(int count) {
  return (count > 99) ? "99+" : count.toString();
}

InkWell listItem(
    {Widget? leading,
    required Widget title,
    Widget? trailing,
    required Function() onTap}) {
  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          leading != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 16.0), child: leading)
              : const SizedBox(),
          Expanded(
            child: title,
          ),
          trailing ?? const SizedBox()
        ],
      ),
    ),
  );
}

String getRecentChatTime(BuildContext context, int? epochTime) {
  if (epochTime == null) return "";
  if (epochTime == 0) return "";
  var convertedTime = epochTime; // / 1000;
  //messageDate.time = convertedTime
  var hourTime = manipulateMessageTime(
      context, DateTime.fromMicrosecondsSinceEpoch(convertedTime));
  var currentYear = DateTime.now().year;
  var calendar = DateTime.fromMicrosecondsSinceEpoch(convertedTime);
  var time = (currentYear == calendar.year)
      ? DateFormat("dd-MMM").format(calendar)
      : DateFormat("yyyy/MM/dd").format(calendar);
  return (equalsWithYesterday(calendar, Constants.today))
      ? hourTime
      : (equalsWithYesterday(calendar, Constants.yesterday))
          ? Constants.yesterdayUpper
          : time;
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

bool equalsWithYesterday(DateTime srcDate, String day) {
  if (day == Constants.yesterday) {
    var messageDate = DateFormat('yyyy/MM/dd').format(srcDate);
    var yesterdayDate = DateFormat('yyyy/MM/dd').format(DateTime.now().subtract(
        const Duration(
            days: 1, hours: 0, minutes: 0, seconds: 0, milliseconds: 0)));
    return yesterdayDate == messageDate;
  } else {
    return equalsWithToday(srcDate, day);
  }
}

bool equalsWithToday(DateTime srcDate, String day) {
  var today = DateFormat('yyyy/MM/dd').format(DateTime.now());
  var messageDate = DateFormat('yyyy/MM/dd').format(srcDate);
  return messageDate == today;
}

var calendar = DateTime.now();

String getChatTime(BuildContext context, int? epochTime) {
  // debugPrint("epochTime--> $epochTime");
  if (epochTime == null) return "";
  if (epochTime == 0) return "";
  var convertedTime = epochTime;
  // var convertedTime = Platform.isAndroid ? epochTime : epochTime * 1000; // / 1000;
  // debugPrint("epoch convertedTime---> $convertedTime");
  var hourTime = manipulateMessageTime(
      context, DateTime.fromMicrosecondsSinceEpoch(convertedTime));
  calendar = DateTime.fromMicrosecondsSinceEpoch(convertedTime);
  return hourTime;
}

bool checkFile(String mediaLocalStoragePath) {
  return mediaLocalStoragePath.isNotEmpty &&
      File(mediaLocalStoragePath).existsSync();
}

checkIosFile(String mediaLocalStoragePath) async {
  var isExists = await FlyChat.iOSFileExist(mediaLocalStoragePath);
  return isExists;
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

Future<void> launchInBrowser(String url) async {
  if (await AppUtils.isNetConnected()) {
    var webUrl = url.replaceAll("http://", "").replaceAll("https://", "");
    final Uri toLaunch = Uri(scheme: 'https', host: webUrl);
    if (!await launchUrl(
      toLaunch,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  } else {
    toToast(Constants.noInternetConnection);
  }
}

Future<void> makePhoneCall(String phoneNumber) async {
  final Uri launchUri = Uri(
    scheme: 'tel',
    path: phoneNumber,
  );
  // if (await canLaunch(launchUri.toString())) {
  //   await launch(launchUri.toString());
  // } else {
  //   throw 'Could not launch $launchUri';
  // }
  // try {
  //   var cellphone = '7192822224';
  //   await launch('tel://$cellphone');
  //
  // }catch (e){
  //   throw 'Could not launch $e';
  // }
  await launchUrl(launchUri);
}

launchCaller(String phoneNumber) async {
  // var url = "tel:$phoneNumber";
  // if (await canLaunch(url)) {
  //   await launch(url);
  // } else {
  //   throw 'Could not launch $url';
  // }
  canLaunchUrl(Uri(scheme: 'tel', path: phoneNumber)).then((bool result) {
    debugPrint("success");
  });
}

Future<void> launchEmail(String emailID) async {
  // String? encodeQueryParameters(Map<String, String> params) {
  //   return params.entries
  //       .map((MapEntry<String, String> e) =>
  //   '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
  //       .join('&');
  // }

  final Uri emailLaunchUri = Uri(
    scheme: 'mailto',
    path: emailID,
    // query: encodeQueryParameters(<String, String>{
    //   'subject': 'Example Subject & Symbols are allowed!',
    // }),
  );
  await launchUrl(emailLaunchUri);
}

class Triple {
  Triple(this.singleOrgroupJid, this.userId, this.typingStatus);

  String singleOrgroupJid;
  String userId;
  bool typingStatus;
}

Future<RecentChatData?> getRecentChatOfJid(String jid) async {
  var value = await FlyChat.getRecentChatOf(jid);
  mirrorFlyLog("chat", value.toString());
  if (value != null) {
    var data = recentChatDataFromJson(value);
    return data;
  } else {
    return null;
  }
}
String getName(Profile item) {
  if (SessionManagement.isTrailLicence()) {
    /*return item.name.toString().checkNull().isEmpty
        ? item.nickName.toString()
        : item.name.toString();*/
    return item.name.checkNull().isEmpty
        ? (item.nickName.checkNull().isEmpty
            ? item.mobileNumber.checkNull()
            : item.nickName.checkNull())
        : item.name.checkNull();
  } else {
   if(item.jid.checkNull()==SessionManagement.getUserJID()){
     return Constants.you;
   }else if(item.isDeletedContact()){
     mirrorFlyLog('isDeletedContact', item.isDeletedContact().toString());
     return Constants.deletedUser;
   }else if(item.isUnknownContact() || item.nickName.checkNull().isEmpty){
     mirrorFlyLog('isUnknownContact', item.isUnknownContact().toString());
     return item.mobileNumber.checkNull();
   }else{
     mirrorFlyLog('nickName', item.nickName.toString());
     return item.nickName.checkNull();
   }
    /*var status = true;
    if(status) {
      return item.nickName
          .checkNull()
          .isEmpty
          ? (item.name
          .checkNull()
          .isEmpty
          ? item.mobileNumber.checkNull()
          : item.name.checkNull())
          : item.nickName.checkNull();
    }else{
      return item.mobileNumber.checkNull();
    }*/
  }
}

String getRecentName(RecentChatData item) {
  if (SessionManagement.isTrailLicence()) {
    /*return item.name.toString().checkNull().isEmpty
        ? item.nickName.toString()
        : item.name.toString();*/
    return item.profileName.checkNull().isEmpty
        ? item.nickName.checkNull()
        : item.profileName.checkNull();
  } else {
    if(item.jid.checkNull()==SessionManagement.getUserJID()){
      return Constants.you;
    }else if(item.isDeletedContact()){
      mirrorFlyLog('isDeletedContact', item.isDeletedContact().toString());
      return Constants.deletedUser;
    }else if(item.isUnknownContact() || item.nickName.checkNull().isEmpty){
      mirrorFlyLog('isUnknownContact', item.jid.toString());
      return getMobileNumberFromJid(item.jid.checkNull());
    }else{
      mirrorFlyLog('nickName', item.nickName.toString());
      return item.nickName.checkNull();
    }
  }
}

String getMemberName(Member item) {
  if (SessionManagement.isTrailLicence()) {
    /*return item.name.toString().checkNull().isEmpty
        ? item.nickName.toString()
        : item.name.toString();*/
    return item.name.checkNull().isEmpty
        ? (item.nickName.checkNull().isEmpty
        ? item.mobileNumber.checkNull()
        : item.nickName.checkNull())
        : item.name.checkNull();
  } else {
    if(item.jid.checkNull()==SessionManagement.getUserJID()){
      return Constants.you;
    }else if(item.isDeletedContact()){
      mirrorFlyLog('isDeletedContact', item.isDeletedContact().toString());
      return Constants.deletedUser;
    }else if(item.isUnknownContact() || item.nickName.checkNull().isEmpty){
      mirrorFlyLog('isUnknownContact', item.isUnknownContact().toString());
      return item.mobileNumber.checkNull();
    }else{
      mirrorFlyLog('nickName', item.nickName.toString());
      return item.nickName.checkNull();
    }
    /*var status = true;
    if(status) {
      return item.nickName
          .checkNull()
          .isEmpty
          ? (item.name
          .checkNull()
          .isEmpty
          ? item.mobileNumber.checkNull()
          : item.name.checkNull())
          : item.nickName.checkNull();
    }else{
      return item.mobileNumber.checkNull();
    }*/
  }
}
String getMobileNumberFromJid(String jid){
  var str = jid.split('@');
  return str[0];
}

String getDisplayImage(RecentChatData recentChat) {
  var imageUrl = recentChat.profileImage ?? Constants.emptyString;
  if (recentChat.isBlockedMe.checkNull() ||
      recentChat.isAdminBlocked.checkNull()) {
    imageUrl = Constants.emptyString;
    //drawable = CustomDrawable(context).getDefaultDrawable(recentChat)
  } else if (!recentChat.isItSavedContact.checkNull() ||
      recentChat.isDeletedContact()) {
    imageUrl = recentChat.profileImage ?? Constants.emptyString;
    // drawable = CustomDrawable(context).getDefaultDrawable(recentChat)
  }
  return imageUrl;
}