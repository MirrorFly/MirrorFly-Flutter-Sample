import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../common/constants.dart';
import '../data/permissions.dart';
import '../data/session_management.dart';
import '../extensions/extensions.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_style_config.dart';
import '../common/app_localizations.dart';
import '../common/widgets.dart';
import '../model/chat_message_model.dart';
import '../routes/route_settings.dart';
import 'utils.dart';


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
  AppUtils.launchWeb(Uri(scheme: 'tel', path: phoneNumber));
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
    {
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

  DialogUtils.createDialog(
    Obx(() {
      return Dialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
        child: SizedBox(
          width: NavUtils.width * 0.7,
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
                      NavUtils.back();
                      NavUtils.toNamed(Routes.imageView, arguments: {
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
                            width: NavUtils.width * 0.7,
                            height: 250,
                            clipOval: false,
                            errorWidget: profile.value.isGroupProfile!
                                ? AppUtils.assetIcon(assetName:
                                    groupImg,
                                    height: 250,
                                    width: NavUtils.width * 0.72,
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
                        child: AppUtils.svgIcon(icon:
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
                                  NavUtils.back();
                                  makeVoiceCall(profile,
                                      availableFeatures);
                              },
                              child: AppUtils.svgIcon(icon:
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
                                NavUtils.back();
                                makeVideoCall(profile, availableFeatures);
                              },
                              child: AppUtils.svgIcon(icon:
                                quickVideo,
                                fit: BoxFit.contain,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                    Expanded(
                      child: InkWell(
                        onTap: infoTap,
                        child: AppUtils.svgIcon(icon:
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

showBlockStatusAlert(Function? function,Rx<ProfileDetails> profile, Rx<AvailableFeatures> availableFeatures) {
  DialogUtils.showAlert(dialogStyle: AppStyleConfig.dialogStyle,message: getTranslated("unBlockToSendMsg"), actions: [
    TextButton(style: AppStyleConfig.dialogStyle.buttonStyle,
        onPressed: () {
          NavUtils.back();
        },
        child: Text(getTranslated("cancel").toUpperCase(), )),
    TextButton(style: AppStyleConfig.dialogStyle.buttonStyle,
        onPressed: () async {
          NavUtils.back();
          Mirrorfly.unblockUser(
              userJid: profile.value.jid.checkNull(),
              flyCallBack: (FlyResponse response) {
                if (response.isSuccess) {
                  debugPrint(response.toString());
                  profile.value.isBlocked = false;
                  if (function != null) {
                    function.call(profile,availableFeatures);
                  }
                }
              });
        },
        child: Text(getTranslated("unblock").toUpperCase(), )),
  ]);
}

makeVoiceCall(Rx<ProfileDetails> profile, Rx<AvailableFeatures> availableFeatures) async {
  if(profile.value.isAdminBlocked.checkNull()){
    toToast(getTranslated("adminBlockedUser"));
    return;
  }
  if(profile.value.isBlocked.checkNull()) {
    showBlockStatusAlert(makeVoiceCall, profile,availableFeatures);
    return;
  }
  if (!availableFeatures.value.isOneToOneCallAvailable.checkNull()) {
    DialogUtils.showFeatureUnavailable();
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
    Mirrorfly.makeVoiceCall(toUserJid: profile.value.jid.checkNull(), flyCallBack: (FlyResponse response) {
      if (response.isSuccess) {
        NavUtils.toNamed(Routes.outGoingCallView, arguments: {
          "userJid": [profile.value.jid],
          "callType": CallType.audio
        });
      }
    });
  } else {
    debugPrint("permission not given");
  }
}

makeVideoCall(Rx<ProfileDetails> profile, Rx<AvailableFeatures> availableFeatures) async {
  if(profile.value.isAdminBlocked.checkNull()){
    toToast(getTranslated("adminBlockedUser"));
    return;
  }
  if(profile.value.isBlocked.checkNull()) {
    showBlockStatusAlert(makeVideoCall, profile, availableFeatures);
    return;
  }
  if (!availableFeatures.value.isGroupCallAvailable.checkNull()) {
    DialogUtils.showFeatureUnavailable();
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
  // if (await AppUtils.isNetConnected()) {
    if (await AppPermission.askVideoCallPermissions()) {
      // if ((await Mirrorfly.isOnGoingCall()).checkNull()) {
      //   debugPrint("#Mirrorfly Call You are on another call");
      //   toToast(getTranslated("msgOngoingCallAlert"));
      // } else {
        Mirrorfly.makeVideoCall(toUserJid: profile.value.jid.checkNull(), flyCallBack: (FlyResponse response) {
          if (response.isSuccess) {
            NavUtils.toNamed(Routes.outGoingCallView, arguments: {
              "userJid": [profile.value.jid],
              "callType": CallType.video
            });
          }
        });
      // }
    } else {
      LogMessage.d("askVideoCallPermissions", "false");
    }
  // } else {
  //   toToast(getTranslated("noInternetConnection"));
  // }
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

