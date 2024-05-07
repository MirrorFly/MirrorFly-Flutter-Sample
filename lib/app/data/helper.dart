import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/extensions/extensions.dart';
import 'package:mirror_fly_demo/app/common/main_controller.dart';
import 'package:mirror_fly_demo/app/data/permissions.dart';
import 'package:mirror_fly_demo/main.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';
import 'package:mirror_fly_demo/app/data/session_management.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../common/app_localizations.dart';
import '../common/widgets.dart';
import '../model/chat_message_model.dart';
import '../routes/route_settings.dart';
import 'apputils.dart';

class Helper {
  static void showLoading({String? message, bool dismiss = false}) {
    Get.dialog(
      Dialog(
        child: PopScope(
          canPop: dismiss,
          onPopInvoked: (didPop) {
            if (didPop) {
              return;
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: buttonBgColor,),
                const SizedBox(width: 16),
                Text(message ?? 'Loading...'),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: dismiss,
    );
  }

  static void progressLoading({bool dismiss = false}) {
    Get.dialog(
        AlertDialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          content: PopScope(
              canPop: dismiss,
              onPopInvoked: (didPop) {
                if (didPop) {
                  return;
                }
              },
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
      {String? title, required String message, List<Widget>? actions, Widget? content, bool? barrierDismissible}) {
    Get.dialog(
        AlertDialog(
          backgroundColor: Colors.white,
          title: title != null
              ? Text(
                  title,
                  style: const TextStyle(fontSize: 17),
                )
              : const Offstage(),
          contentPadding: title != null
              ? const EdgeInsets.only(top: 15, right: 25, left: 25, bottom: 0)
              : const EdgeInsets.only(top: 0, right: 25, left: 25, bottom: 5),
          content: PopScope(
              canPop: barrierDismissible ?? true,
              onPopInvoked: (didPop) {
                if (didPop) {
                  return;
                }
                },
            child: content ??
                Text(
                  message,
                  style: const TextStyle(color: textHintColor, fontWeight: FontWeight.normal, fontSize: 18),
                ),
          ),
          contentTextStyle: const TextStyle(color: textHintColor, fontWeight: FontWeight.w500),
          actions: actions,
        ),
        barrierDismissible: barrierDismissible ?? true);
  }

  static void showVerticalButtonAlert(List<Widget> actions) {
    Get.dialog(
      Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: actions,
        ),
      ),
    );
  }

  static void showButtonAlert({required List<Widget> actions}) {
    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: actions,
          ),
        ),
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

  static void showFeatureUnavailable() {
    Helper.showAlert(message: getTranslated("featureNotAvailableForYourPlan"), actions: [
      TextButton(
          onPressed: () {
            Get.back();
          },
          child: Text(getTranslated("ok"))),
    ]);
  }

  static String formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  static String durationToString(Duration duration) {
    debugPrint("duration conversion $duration");
    String hours = (duration.inHours == 00) ? "" : "${duration.inHours.toStringAsFixed(0).padLeft(2, '0')}:"; // Get hours
    int minutes = duration.inMinutes % 60; // Get minutes
    var seconds = ((duration.inSeconds % 60)).toStringAsFixed(0).padLeft(2, '0');
    return '$hours${minutes.toStringAsFixed(0).padLeft(2, '0')}:$seconds';
  }

  static String getMapImageUri(double latitude, double longitude) {
    var googleMapKey = Get.find<MainController>().googleMapKey; //Env.googleMapKey;//Constants.googleMapKey;
    return ("https://maps.googleapis.com/maps/api/staticmap?center=$latitude,$longitude&zoom=13&size=300x200&markers=color:red|$latitude,$longitude&key=$googleMapKey");
  }

  static int getColourCode(String name) {
    if (name == getTranslated("you")) return 0Xff000000;
    var colorsArray = Constants.defaultColorList;
    var hashcode = name.hashCode;
    var rand = hashcode % colorsArray.length;
    return colorsArray[(rand).abs()];
  }

  static Widget forMessageTypeIcon(String? messageType, [bool isAudioRecorded = false]) {
    LogMessage.d("iconfor", messageType.toString());
    switch (messageType?.toUpperCase()) {
      case Constants.mImage:
        return SvgPicture.asset(
          mImageIcon,
          fit: BoxFit.contain,
          colorFilter: const ColorFilter.mode(playIconColor, BlendMode.srcIn),
        );
      case Constants.mAudio:
        return SvgPicture.asset(
          isAudioRecorded ? mAudioRecordIcon : mAudioIcon,
          fit: BoxFit.contain,
          colorFilter: const ColorFilter.mode(playIconColor, BlendMode.srcIn),
        );
      case Constants.mVideo:
        return SvgPicture.asset(
          mVideoIcon,
          fit: BoxFit.contain,
          colorFilter: const ColorFilter.mode(playIconColor, BlendMode.srcIn),
        );
      case Constants.mDocument:
        return SvgPicture.asset(
          mDocumentIcon,
          fit: BoxFit.contain,
          colorFilter: const ColorFilter.mode(playIconColor, BlendMode.srcIn),
        );
      case Constants.mFile:
        return SvgPicture.asset(
          mDocumentIcon,
          fit: BoxFit.contain,
          colorFilter: const ColorFilter.mode(playIconColor, BlendMode.srcIn),
        );
      case Constants.mContact:
        return SvgPicture.asset(
          mContactIcon,
          fit: BoxFit.contain,
          colorFilter: const ColorFilter.mode(playIconColor, BlendMode.srcIn),
        );
      case Constants.mLocation:
        return SvgPicture.asset(
          mLocationIcon,
          fit: BoxFit.contain,
          colorFilter: const ColorFilter.mode(playIconColor, BlendMode.srcIn),
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
Future<bool> getFileSizeInMb(String path, String mediaType) async {
  try {
    var file = File(path);
    int sizeInBytes = await file.length();
    double sizeInMb = sizeInBytes / (1024 * 1024);

    if (mediaType == Constants.mImage && sizeInMb <= Constants.maxImageFileSize) {
      return true;
    } else if (mediaType == Constants.mAudio && sizeInMb <= Constants.maxAudioFileSize) {
      return true;
    } else if (mediaType == Constants.mVideo && sizeInMb <= Constants.maxVideoFileSize) {
      return true;
    } else if (mediaType == Constants.mDocument && sizeInMb <= Constants.maxDocFileSize) {
      return true;
    } else {
      return false;
    }
  }catch(e){
    debugPrint("File Size Calculation Error $e");
    return false;
  }
}

bool checkFileUploadSize(String path, String mediaType) {
  var file = File(path);
  int sizeInBytes = file.lengthSync();
  debugPrint("file size --> $sizeInBytes");
  double sizeInMb = sizeInBytes / (1024 * 1024);
  debugPrint("sizeInBytes $sizeInMb");
  debugPrint("Constants.maxImageFileSize ${Constants.maxImageFileSize}");

  // debugPrint(getFileSizeText(sizeInBytes.toString()));

  if (mediaType == Constants.mImage && sizeInMb <= Constants.maxImageFileSize) {
    return true;
  } else if (mediaType == Constants.mAudio && sizeInMb <= Constants.maxAudioFileSize) {
    return true;
  } else if (mediaType == Constants.mVideo && sizeInMb <= Constants.maxVideoFileSize) {
    return true;
  } else if (mediaType == Constants.mDocument && sizeInMb <= Constants.maxDocFileSize) {
    return true;
  } else {
    return false;
  }
}

String getFileSizeText(String fileSizeInBytes) {
  var fileSizeBuilder = "";
  var fileSize = int.parse(fileSizeInBytes);
  if (fileSize > 1073741824) {
    fileSizeBuilder = (getRoundedFileSize(fileSize / 1073741824)).toString() + (" ") + ("GB");
  } else if (fileSize > 1048576) {
    fileSizeBuilder = (getRoundedFileSize(fileSize / 1048576)).toString() + (" ") + ("MB");
  } else if (fileSize > 1024) {
    fileSizeBuilder = (getRoundedFileSize(fileSize / 1024)).toString() + (" ") + ("KB");
  } else {
    fileSizeBuilder = (fileSizeInBytes).toString() + (" ") + ("bytes");
  }
  return fileSizeBuilder.toString();
}

double getRoundedFileSize(double unscaledValue) {
  //return BigDecimal.valueOf(unscaledValue).setScale(2, RoundingMode.HALF_UP).toDouble()
  return unscaledValue.roundToDouble();
}


String getDateFromTimestamp(int convertedTime, String format) {
  var calendar = DateTime.fromMicrosecondsSinceEpoch(convertedTime);
  return DateFormat(format).format(calendar);
}

Future<ProfileDetails> getProfileDetails(String jid) async {
  var value = await Mirrorfly.getProfileDetails(jid: jid.checkNull());
  // profileDataFromJson(value);
  // debugPrint("getProfileDetails--> $value");
  // var profile = await compute(profiledata, value.toString());
  var profile = ProfileDetails.fromJson(json.decode(value.toString()));
  return profile;
}

Future<ChatMessageModel> getMessageOfId(String mid) async {
  var value = await Mirrorfly.getMessageOfId(messageId: mid.checkNull());
  //LogMessage.d("getMessageOfId", "$value");
  var chatMessage =
      sendMessageModelFromJson(value.toString()); //await compute(sendMessageModelFromJson, value.toString());
  return chatMessage;
}



String returnFormattedCount(int count) {
  return (count > 99) ? "99+" : count.toString();
}

InkWell listItem({Widget? leading, required Widget title, Widget? trailing, required Function() onTap}) {
  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          leading != null ? Padding(padding: const EdgeInsets.only(right: 16.0), child: leading) : const SizedBox(),
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
  var hourTime = manipulateMessageTime(context, DateTime.fromMicrosecondsSinceEpoch(convertedTime));
  var currentYear = DateTime.now().year;
  var calendar = DateTime.fromMicrosecondsSinceEpoch(convertedTime);
  var time = (currentYear == calendar.year)
      ? DateFormat("dd-MMM").format(calendar)
      : DateFormat("yyyy/MM/dd").format(calendar);
  return (equalsWithYesterday(calendar, getTranslated("today")))
      ? hourTime
      : (equalsWithYesterday(calendar, getTranslated("yesterday")))
          ? getTranslated("yesterday").toUpperCase()
          : time;
}

String manipulateMessageTime(BuildContext context, DateTime messageDate) {
  var format = MediaQuery.of(context).alwaysUse24HourFormat ? 24 : 12;
  calendar = messageDate;
  var hours = calendar.hour; //calendar[Calendar.HOUR]
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
  if (day == getTranslated("yesterday")) {
    var messageDate = DateFormat('yyyy/MM/dd').format(srcDate);
    var yesterdayDate = DateFormat('yyyy/MM/dd')
        .format(DateTime.now().subtract(const Duration(days: 1, hours: 0, minutes: 0, seconds: 0, milliseconds: 0)));
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
  if (epochTime == null) return "";
  if (epochTime == 0) return "";
  var convertedTime = epochTime;
  // var convertedTime = Platform.isAndroid ? epochTime : epochTime * 1000; // / 1000;
  // debugPrint("epoch convertedTime---> $convertedTime");
  var hourTime = manipulateMessageTime(context, DateTime.fromMicrosecondsSinceEpoch(convertedTime));
  // calendar = DateTime.fromMicrosecondsSinceEpoch(convertedTime);
  //debugPrint('hourTime $hourTime');
  return hourTime;
}

bool checkFile(String mediaLocalStoragePath) {
  return mediaLocalStoragePath.isNotEmpty && File(mediaLocalStoragePath).existsSync();
}


openDocument(String mediaLocalStoragePath) async {
  // if (await askStoragePermission()) {
  if (AppUtils.isMediaExists(mediaLocalStoragePath)) {
    final result = await OpenFile.open(mediaLocalStoragePath);
    debugPrint(result.message);
    if (result.message.contains("file does not exist")) {
      toToast(getTranslated("unableToOpen"));
    } else if (result.message.contains('No APP found to open this file')) {
      toToast(getTranslated("youMayNotProperApp"));
    }

    /*Mirrorfly.openFile(mediaLocalStoragePath).catchError((onError) {
      final scaffold = ScaffoldMessenger.of(context);
      scaffold.showSnackBar(
        SnackBar(
          content: const Text(
              'No supported application available to open this file format'),
          action: SnackBarAction(
              label: 'Ok', onPressed: scaffold.hideCurrentSnackBar),
        ),
      );
    });*/
  } else {
    toToast(getTranslated("mediaDoesNotExist"));
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
    toToast(getTranslated("noInternetConnection"));
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
  var value = await Mirrorfly.getRecentChatOf(jid: jid);
  LogMessage.d("chat", value.toString());
  if (value.isNotEmpty) {
    var data = recentChatDataFromJson(value);
    return data;
  } else {
    return null;
  }
}

String getName(ProfileDetails item) {
  if (!Constants.enableContactSync) {
    /*return item.name.toString().checkNull().isEmpty
        ? item.nickName.toString()
        : item.name.toString();*/
    return item.name.checkNull().isEmpty
        ? (item.nickName.checkNull().isEmpty ? getMobileNumberFromJid(item.jid.checkNull()) : item.nickName.checkNull())
        : item.name.checkNull();
  } else {
    if (item.jid.checkNull() == SessionManagement.getUserJID()) {
      return getTranslated("you");
    } else if (item.isDeletedContact()) {
      LogMessage.d("getName", 'isDeletedContact ${item.isDeletedContact()}');
      return getTranslated("deletedUser");
    } else if (item.isUnknownContact() || item.nickName.checkNull().isEmpty) {
      LogMessage.d("getName", 'isUnknownContact ${item.isUnknownContact()}');
      return item.mobileNumber.checkNull().isNotEmpty
          ? item.mobileNumber.checkNull()
          : getMobileNumberFromJid(item.jid.checkNull());
    } else {
      LogMessage.d("getName", 'nickName ${item.nickName} name ${item.name}');
      return item.nickName.checkNull().isEmpty
          ? (item.name.checkNull().isEmpty ? getMobileNumberFromJid(item.jid.checkNull()) : item.name.checkNull())
          : item.nickName.checkNull(); //#FLUTTER-1300
    }
  }
}

String getRecentName(RecentChatData item) {
  if (!Constants.enableContactSync) {
    /*return item.name.toString().checkNull().isEmpty
        ? item.nickName.toString()
        : item.name.toString();*/
    return item.profileName.checkNull().isEmpty
        ? item.nickName.checkNull().isNotEmpty
            ? item.nickName.checkNull()
            : getMobileNumberFromJid(item.jid.checkNull())
        : item.profileName.checkNull();
  } else {
    if (item.jid.checkNull() == SessionManagement.getUserJID()) {
      return getTranslated("you");
    } else if (item.isDeletedContact()) {
      LogMessage.d('isDeletedContact', item.isDeletedContact().toString());
      return getTranslated("deletedUser");
    } else if (item.isUnknownContact() || item.nickName.checkNull().isEmpty) {
      LogMessage.d('isUnknownContact', item.jid.toString());
      return getMobileNumberFromJid(item.jid.checkNull());
    } else {
      LogMessage.d('nickName', item.nickName.toString());
      return item.nickName.checkNull();
    }
  }
}

String getMemberName(ProfileDetails item) {
  if (!Constants.enableContactSync) {
    /*return item.name.toString().checkNull().isEmpty
        ? item.nickName.toString()
        : item.name.toString();*/
    return item.name.checkNull().isEmpty
        ? (item.nickName.checkNull().isEmpty ? getMobileNumberFromJid(item.jid.checkNull()) : item.nickName.checkNull())
        : item.name.checkNull();
  } else {
    if (item.jid.checkNull() == SessionManagement.getUserJID()) {
      return getTranslated("you");
    } else if (item.isDeletedContact()) {
      LogMessage.d('isDeletedContact', item.isDeletedContact().toString());
      return getTranslated("deletedUser");
    } else if (item.isUnknownContact() || item.nickName.checkNull().isEmpty) {
      LogMessage.d('isUnknownContact', item.isUnknownContact().toString());
      return item.mobileNumber.checkNull().isNotEmpty
          ? item.mobileNumber.checkNull()
          : getMobileNumberFromJid(item.jid.checkNull());
    } else {
      LogMessage.d('nickName', item.nickName.toString());
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

bool isValidPhoneNumber(String s) {
  if (s.length > 13 || s.length < 6) return false;
  return hasMatch(s, r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$');
}

bool hasMatch(String? value, String pattern) {
  return (value == null) ? false : RegExp(pattern).hasMatch(value);
}

String getMobileNumberFromJid(String jid) {
  var str = jid.split('@');
  return str[0];
}

String convertSecondToLastSeen(String seconds) {
  if (seconds.isNotEmpty) {
    if (seconds == "0") return getTranslated("online");
    LogMessage.d("getUserLastSeenTime", "seconds $seconds");
    // var userLastSeenDate = DateTime.now().subtract(Duration(milliseconds: double.parse(seconds).toInt()));
    DateTime lastSeen = DateTime.fromMillisecondsSinceEpoch(int.parse(seconds), isUtc: false);
    Duration diff = DateTime.now().difference(lastSeen);

    LogMessage.d("getUserLastSeenTime", "diff ${diff.inDays}");
    if (diff.inDays == 0) {
      return getTranslated("lastSeenAt").replaceFirst("%d", DateFormat('hh:mm a').format(lastSeen));
    } else if (diff.inDays == 1) {
      return getTranslated("lastSeenYesterday");
    } else if (diff.inDays > 1 && diff.inDays < 365) {
      var last = DateFormat('dd MMM').format(lastSeen);
      return getTranslated("lastSeenOn").replaceFirst("%d", last);
    } else if (int.parse(DateFormat('yyyy').format(lastSeen)) < int.parse(DateFormat('yyyy').format(DateTime.now()))) {
      return getTranslated("lastSeenOn").replaceFirst("%d",DateFormat('dd/MM/yyyy').format(lastSeen));
    } else {
      return getTranslated("online");
    }
  } else {
    return "";
  }
}

String getDisplayImage(RecentChatData recentChat) {
  var imageUrl = recentChat.profileImage ?? Constants.emptyString;
  if (recentChat.isBlockedMe.checkNull() || recentChat.isAdminBlocked.checkNull()) {
    imageUrl = Constants.emptyString;
    //drawable = CustomDrawable(context).getDefaultDrawable(recentChat)
  } else if (!recentChat.isItSavedContact.checkNull() || recentChat.isDeletedContact()) {
    imageUrl = recentChat.profileImage ?? Constants.emptyString;
    // drawable = CustomDrawable(context).getDefaultDrawable(recentChat)
  }
  return imageUrl;
}

void showQuickProfilePopup(
    {required context,
    required Function() chatTap,
    Function()? callTap,
    Function()? videoTap,
    required Function() infoTap,
    required Rx<ProfileDetails> profile,
    required Rx<AvailableFeatures> availableFeatures}) {
  var isAudioCallAvailable =
      profile.value.isGroupProfile.checkNull() ? false : availableFeatures.value.isOneToOneCallAvailable.checkNull();
  var isVideoCallAvailable =
      profile.value.isGroupProfile.checkNull() ? false : availableFeatures.value.isOneToOneCallAvailable.checkNull();

  Get.dialog(
    Obx(() {
      return Dialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
        child: SizedBox(
          width: Get.width * 0.7,
          height: 300,
          child: Column(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    LogMessage.d('image click', 'true');
                    debugPrint("quick profile click--> ${profile.toJson().toString()}");
                    if (profile.value.image!.isNotEmpty &&
                        !(profile.value.isBlockedMe.checkNull() || profile.value.isAdminBlocked.checkNull()) &&
                        !( //!profile.value.isItSavedContact.checkNull() || //This is commented because Android side received as true and iOS side false
                            profile.value.isDeletedContact())) {
                      Get.back();
                      Get.toNamed(Routes.imageView, arguments: {
                        'imageName': getName(profile.value),
                        'imageUrl': profile.value.image.checkNull()
                      });
                    }
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                          borderRadius:
                              const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                          child: ImageNetwork(
                            url: profile.value.image.toString(),
                            width: MediaQuery.of(context).size.width * 0.7,
                            height: 250,
                            clipOval: false,
                            errorWidget: profile.value.isGroupProfile!
                                ? Image.asset(
                                    groupImg,
                                    height: 250,
                                    width: MediaQuery.of(context).size.width * 0.72,
                                    fit: BoxFit.cover,
                                  )
                                : ProfileTextImage(
                                    text: getName(profile.value),
                                    fontSize: 75,
                                    radius: 0,
                                  ),
                            isGroup: profile.value.isGroupProfile.checkNull(),
                            blocked: profile.value.isBlockedMe.checkNull() || profile.value.isAdminBlocked.checkNull(),
                            unknown: (!profile.value.isItSavedContact.checkNull() || profile.value.isDeletedContact()),
                          )),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
                        child: Text(
                          profile.value.isGroupProfile!
                              ? profile.value.name.checkNull()
                              : !Constants.enableContactSync
                                  ? profile.value.mobileNumber.checkNull()
                                  : profile.value.nickName.checkNull(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 50,
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: chatTap,
                        child: SvgPicture.asset(
                          quickMessage,
                          fit: BoxFit.contain,
                          width: 30,
                          height: 30,
                        ),
                      ),
                    ),
                    isAudioCallAvailable
                        ? Expanded(
                            child: InkWell(
                              onTap: () {
                                Get.back();
                                makeVoiceCall(profile.value.jid.checkNull(), availableFeatures);
                              },
                              child: SvgPicture.asset(
                                quickCall,
                                fit: BoxFit.contain,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                    isVideoCallAvailable
                        ? Expanded(
                            child: InkWell(
                              onTap: () {
                                Get.back();
                                makeVideoCall(profile.value.jid.checkNull(), availableFeatures);
                              },
                              child: SvgPicture.asset(
                                quickVideo,
                                fit: BoxFit.contain,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                    Expanded(
                      child: InkWell(
                        onTap: infoTap,
                        child: SvgPicture.asset(
                          quickInfo,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }),
  );
}

makeVoiceCall(String toUser, Rx<AvailableFeatures> availableFeatures) async {
  if (!availableFeatures.value.isOneToOneCallAvailable.checkNull()) {
    Helper.showFeatureUnavailable();
    return;
  }
  if ((await Mirrorfly.isOnGoingCall()).checkNull()) {
    debugPrint("#Mirrorfly Call You are on another call");
    toToast(getTranslated("msgOngoingCallAlert"));
    return;
  }
  if (!(await AppUtils.isNetConnected())) {
    toToast(getTranslated("noInternetConnection"));
    return;
  }
  if (await AppPermission.askAudioCallPermissions()) {
    Mirrorfly.makeVoiceCall(toUserJid: toUser.checkNull(), flyCallBack: (FlyResponse response) {
      if (response.isSuccess) {
        Get.toNamed(Routes.outGoingCallView, arguments: {
          "userJid": [toUser],
          "callType": CallType.audio
        });
      }
    });
  } else {
    debugPrint("permission not given");
  }
}

makeVideoCall(String toUser, Rx<AvailableFeatures> availableFeatures) async {
  if (await AppUtils.isNetConnected()) {
    if (await AppPermission.askVideoCallPermissions()) {
      if ((await Mirrorfly.isOnGoingCall()).checkNull()) {
        debugPrint("#Mirrorfly Call You are on another call");
        toToast(getTranslated("msgOngoingCallAlert"));
      } else {
        Mirrorfly.makeVideoCall(toUserJid: toUser.checkNull(), flyCallBack: (FlyResponse response) {
          if (response.isSuccess) {
            Get.toNamed(Routes.outGoingCallView, arguments: {
              "userJid": [toUser],
              "callType": CallType.video
            });
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

String getDocAsset(String filename) {
  if (filename.isEmpty || !filename.contains(".")) {
    return "";
  }
  debugPrint("helper document--> ${filename.toLowerCase().substring(filename.lastIndexOf(".") + 1)}");
  switch (filename.toLowerCase().substring(filename.lastIndexOf(".") + 1)) {
    case "csv":
      return csvImage;
    case "pdf":
      return pdfImage;
    case "doc":
      return docImage;
    case "docx":
      return docxImage;
    case "txt":
      return txtImage;
    case "xls":
      return xlsImage;
    case "xlsx":
      return xlsxImage;
    case "ppt":
      return pptImage;
    case "pptx":
      return pptxImage;
    case "zip":
      return zipImage;
    case "rar":
      return rarImage;
    case "apk":
      return apkImage;
    default:
      return "";
  }
}

String getCallLogDateFromTimestamp(int convertedTime, String format) {
  var calendar = DateTime.fromMicrosecondsSinceEpoch(convertedTime);
  if (isToday(convertedTime)) {
    return getTranslated("today");
  } else if (isYesterday(convertedTime)) {
    return getTranslated("yesterday");
  } else {
    return DateFormat(format).format(calendar);
  }
}

bool isToday(int convertedTime) {
  var calendar = DateTime.fromMicrosecondsSinceEpoch(convertedTime);
  final now = DateTime.now();
  return now.day == calendar.day && now.month == calendar.month && now.year == calendar.year;
}

bool isYesterday(int convertedTime) {
  var calendar = DateTime.fromMicrosecondsSinceEpoch(convertedTime);
  final yesterday = DateTime.now().subtract(const Duration(days: 1));
  return yesterday.day == calendar.day && yesterday.month == calendar.month && yesterday.year == calendar.year;
}

String getCallLogDuration(int startTime, int endTime) {
  var millis = endTime - startTime;
  var duration = Duration(microseconds: millis);

  if (startTime == 0 || endTime == 0 || millis == 0) {
    return "";
  } else {
    var seconds = ((duration.inSeconds % 60)).toStringAsFixed(0).padLeft(2, '0');
    return '${(duration.inMinutes).toStringAsFixed(0).padLeft(2, '0')}:$seconds';
  }
}

String getErrorDetails(FlyResponse response) {
  if(Platform.isIOS){
    return '${response.errorMessage}${response.errorDetails != null ? ", ${response.errorDetails}" : ""}';
  }else{
    return response.errorMessage;
  }
}

navigateBack(){
  Navigator.pop(navigatorKey.currentContext!);
}

BuildContext currentContext(){
  return navigatorKey.currentContext!;
}