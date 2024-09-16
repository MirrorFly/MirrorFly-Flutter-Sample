import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/app_localizations.dart';
import '../../data/helper.dart';
import '../../extensions/extensions.dart';
import '../../routes/route_settings.dart';
import '../../stylesheet/stylesheet.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';

import '../../common/constants.dart';
import '../../common/widgets.dart';
import '../../data/session_management.dart';
import '../../data/utils.dart';
import '../../model/chat_message_model.dart';

Widget searchHeader(String? type, String count, BuildContext context) {
  return Container(
    width: NavUtils.size.width,
    padding: const EdgeInsets.all(8),
    color: dividerColor,
    child: Text.rich(
        TextSpan(text: type, children: [TextSpan(text: count.isNotEmpty ? " ($count)" : "", style: const TextStyle(fontWeight: FontWeight.bold))])),
  );
}

class RecentChatItem extends StatelessWidget {
  const RecentChatItem(
      {Key? key,
      required this.item,
      required this.onTap,
      this.onLongPress,
      this.onAvatarClick,
      this.onchange,
      this.spanTxt = "",
      this.isSelected = false,
      this.isCheckBoxVisible = false,
      this.isChecked = false,
      this.isForwardMessage = false,
      this.typingUserid = "",
      this.archiveVisible = true,
      this.archiveEnabled = false,
      this.recentChatItemStyle = const RecentChatItemStyle()})
      : super(key: key);
  final RecentChatData item;
  final Function(RecentChatData chatItem) onTap;
  final Function(RecentChatData chatItem)? onLongPress;
  final Function(RecentChatData chatItem)? onAvatarClick;
  final String spanTxt;
  final bool isCheckBoxVisible;
  final bool isChecked;
  final bool isForwardMessage;
  final bool archiveVisible;
  final Function(bool? value)? onchange;
  final bool isSelected;
  final String typingUserid;

  final titleStyle = const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700, fontFamily: 'sf_ui');
  final typingStyle = const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600, fontFamily: 'sf_ui', color: buttonBgColor);
  final bool archiveEnabled;
  final RecentChatItemStyle recentChatItemStyle;

  @override
  Widget build(BuildContext context) {
    LogMessage.d("RecentChatItem", "build ${item.jid}");
    return InkWell(
      onLongPress: ()=> onLongPress != null ?  onLongPress!(item) : null,
      onTap: ()=>onTap(item),
      child: Container(
        key: ValueKey(item.jid),
        color: isSelected ? Colors.black12 : Colors.transparent,
        child: Row(
          children: [
            buildProfileImage(recentChatItemStyle),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [buildRecentChatMessageDetails(), buildRecentChatActions(context)],
                    ),
                    AppDivider(
                      padding: const EdgeInsets.only(top: 8),
                      color: recentChatItemStyle.dividerColor,
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Expanded buildRecentChatMessageDetails() {
    LogMessage.d("RecentChatItem", " buildRecentChatMessageDetails build ${item.jid}");
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          spanTxt.isEmpty
              ? Text(
                  getRecentName(item),
                  style: recentChatItemStyle.titleTextStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : spannableText(
                  getRecentName(item),
                  //item.profileName.checkNull(),
                  spanTxt,
                  recentChatItemStyle.titleTextStyle,recentChatItemStyle.spanTextColor),
          Row(
            children: [
              item.isLastMessageSentByMe.checkNull() && !isForwardMessage && !item.isLastMessageRecalledByUser.checkNull()
                  ? (item.lastMessageType == MessageType.isText && item.lastMessageContent.checkNull().isNotEmpty ||
                              item.lastMessageType != MessageType.isText) &&
                          typingUserid.isEmpty
                      ? buildMessageIndicator()
                      : const Offstage()
                  : const Offstage(),
              isForwardMessage
                  ? item.isGroup!
                      ? buildGroupMembers()
                      : buildProfileStatus()
                  : Expanded(
                      child: typingUserid.isEmpty
                          ? item.lastMessageType != null
                              ? buildLastMessageItem()
                              : const SizedBox(
                                  height: 15,
                                )
                          : buildTypingUser(),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Padding buildRecentChatActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0, left: 8, top: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          buildRecentChatTime(context),
          Visibility(
            visible: isCheckBoxVisible,
            child: Checkbox(
              value: isChecked,
              onChanged: onchange,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [buildPinIconVisibility(), buildMuteIconVisibility(), buildArchivedTextVisibility()],
          )
        ],
      ),
    );
  }

  Visibility buildRecentChatTime(BuildContext context) {
    return Visibility(
      visible: !isCheckBoxVisible,
      child: Text(
        DateTimeUtils.getRecentChatTime(context, item.lastMessageTime),
        textAlign: TextAlign.end,
        style: returnFormattedCount(item.unreadMessageCount!) != "0" ? recentChatItemStyle.timeTextStyle.copyWith(color: recentChatItemStyle.unreadColor) : recentChatItemStyle.timeTextStyle
        /* TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.w600,
            fontFamily: 'sf_ui',
            color: returnFormattedCount(item.unreadMessageCount!) != "0"
                //item.isConversationUnRead!
                ? buttonBgColor
                : textColor)*/,
      ),
    );
  }

  Padding buildMessageIndicator() {
    debugPrint("buildMessageIndicator ${item.nickName}");
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: MessageUtils.getMessageIndicatorIcon(item.lastMessageStatus.checkNull(), item.isLastMessageSentByMe.checkNull(), item.lastMessageType.checkNull(),
          item.isLastMessageRecalledByUser.checkNull()),
    );
  }

  InkWell buildProfileImage(RecentChatItemStyle recentChatItemStyle) {
    return InkWell(
      onTap: ()=> onAvatarClick != null ? onAvatarClick!(item) : null,
      child: Container(
          margin: const EdgeInsets.only(left: 19.0, top: 10, bottom: 10, right: 10),
          child: Stack(
            children: [
              buildProfileImageView(recentChatItemStyle.profileImageSize),
              item.isConversationUnRead! ? buildConvReadIcon(recentChatItemStyle.unreadCountTextStyle,recentChatItemStyle.unreadCountBgColor) : const Offstage(),
              item.isEmailContact().checkNull() ? buildEmailIcon() : const Offstage(),
            ],
          )),
    );
  }

  ImageNetwork buildProfileImageView(Size profileImageSize) {
    return ImageNetwork(
      url: item.profileImage.toString(),
      width: profileImageSize.width,
      height: profileImageSize.height,
      clipOval: true,
      errorWidget: item.isGroup!
          ? ClipOval(
              child: AppUtils.assetIcon(assetName:
                groupImg,
                height: profileImageSize.width,
                width: profileImageSize.height,
                fit: BoxFit.cover,
              ),
            )
          : ProfileTextImage(
        radius: profileImageSize.width/2,
              text: getRecentName(
                  item), /* item.profileName.checkNull().isEmpty
                              ? item.nickName.checkNull()
                              : item.profileName.checkNull(),*/
            ),
      isGroup: item.isGroup.checkNull(),
      blocked: item.isBlockedMe.checkNull() || item.isAdminBlocked.checkNull(),
      unknown: (!item.isItSavedContact.checkNull() || item.isDeletedContact()),
    );
  }

  Positioned buildConvReadIcon(TextStyle textStyle,Color bgColor) {
    return Positioned(
        right: 0,
        child: CircleAvatar(
          backgroundColor: bgColor,
          radius: 9,
          child: Text(
            returnFormattedCount(item.unreadMessageCount!) != "0" ? returnFormattedCount(item.unreadMessageCount!) : "",
            style: textStyle,
            // style: const TextStyle(fontSize: 8, color: Colors.white, fontFamily: 'sf_ui'),
          ),
        ));
  }

  Positioned buildEmailIcon() {
    return Positioned(right: 0, bottom: 0, child: AppUtils.svgIcon(icon:emailContactIcon));
  }

  Visibility buildArchivedTextVisibility() {
    return Visibility(
        visible: item.isChatArchived! && archiveVisible && !isForwardMessage,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.0), border: Border.all(color: buttonBgColor, width: 0.8)),
          child: Text(
            getTranslated("archived"),
            style: const TextStyle(color: buttonBgColor),
          ),
        ) /*AppUtils.svgIcon(icon:
                                      archive,
                                      width: 18,
                                      height: 18,
                                    )*/
        );
  }

  Visibility buildMuteIconVisibility() {
    return Visibility(
        visible: !archiveEnabled && item.isMuted! && !isForwardMessage,
        child: AppUtils.svgIcon(icon:
          mute,
          width: 13,
          height: 13,
        ));
  }

  Visibility buildPinIconVisibility() {
    return Visibility(
        visible: !item.isChatArchived! && item.isChatPinned! && !isForwardMessage,
        child: AppUtils.svgIcon(icon:
          pin,
          width: 18,
          height: 18,
        ));
  }

  Widget buildTypingUser() {
    return typingUserid.checkNull().isEmpty
        ? const SizedBox(
            height: 15,
          )
        : FutureBuilder(
            future: getProfileDetails(typingUserid.checkNull()),
            builder: (context, data) {
              if (data.hasData && data.data != null) {
                return Text(
                  getTypingUser(data.data!, item.isGroup),
                  //"${data.data!.name.checkNull()} typing...",
                  style: typingStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                );
              } else {
                LogMessage.d("hasError", data.error.toString());
                return const SizedBox(
                  height: 15,
                );
              }
            });
  }

  String getTypingUser(ProfileDetails profile, bool? isGroup) {
    if (isGroup.checkNull()) {
      return "${profile.getName().checkNull()} ${getTranslated("typingIndicator")}";
    } else {
      return getTranslated("typingIndicator");
    }
  }

  checkSenderShouldShow(ChatMessageModel chat) {
    if (item.isGroup.checkNull()) {
      if (!chat.isMessageSentByMe.checkNull()) {
        return (chat.messageType != Constants.mNotification || chat.messageTextContent == " added you") ||
            (MessageUtils.forMessageTypeString(chat.messageType, content: chat.messageTextContent.checkNull()).checkNull().isNotEmpty);
      }
    }
    return false;
  }

  FutureBuilder<ChatMessageModel> buildLastMessageItem() {
    // LogMessage.d("buildLastMessageItem: ", item.jid);
    return FutureBuilder(
        key: ValueKey(item.lastMessageId),
        future: getMessageOfId(item.lastMessageId.checkNull()),
        builder: (context, data) {
          // LogMessage.d("getMessageOfId future", "${item.lastMessageId.checkNull()} : ${data.data?.messageId}");
          if (data.hasData && data.data != null && !data.hasError) {
            var chat = data.data!;
            return Row(
              children: [
                checkSenderShouldShow(chat)
                    ? Flexible(
                        child: Text(
                          "${chat.senderUserName.checkNull()}:",
                          style: recentChatItemStyle.subtitleTextStyle,//Theme.of(context).textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    : const SizedBox.shrink(),
                chat.isMessageRecalled.value ? const SizedBox.shrink() : MessageUtils.forMessageTypeIcon(chat.messageType, chat.mediaChatMessage),
                SizedBox(
                  width: chat.isMessageRecalled.value
                      ? 0.0
                      : MessageUtils.forMessageTypeString(chat.messageType, content: chat.messageTextContent.checkNull()) != null
                          ? 3.0
                          : 0.0,
                ),
                Expanded(
                  child: spanTxt.isEmpty
                      ? Text(
                          chat.isMessageRecalled.value
                              ? setRecalledMessageText(chat.isMessageSentByMe)
                              : MessageUtils.forMessageTypeString(chat.messageType, content: chat.mediaChatMessage?.mediaCaptionText.checkNull()) ??
                                  chat.messageTextContent.checkNull(),
                          style: recentChatItemStyle.subtitleTextStyle,//Theme.of(context).textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : spannableText(
                          chat.isMessageRecalled.value
                              ? setRecalledMessageText(chat.isMessageSentByMe)
                              : MessageUtils.forMessageTypeString(chat.messageType.checkNull(), content: chat.mediaChatMessage?.mediaCaptionText.checkNull()) ??
                                  chat.messageTextContent.checkNull(),
                          spanTxt,
                      recentChatItemStyle.subtitleTextStyle,recentChatItemStyle.spanTextColor)//Theme.of(context).textTheme.titleSmall),
                ),
              ],
            );
          }
          return const SizedBox(
            height: 15,
          );
        });
  }

  Expanded buildProfileStatus() {
    return Expanded(
        child: FutureBuilder(
            future: getProfileDetails(item.jid!),
            builder: (context, profileData) {
              if (profileData.hasData) {
                return Text(profileData.data?.status ?? "",style: recentChatItemStyle.subtitleTextStyle,);
              }
              return const Text("");
            }));
  }

  Expanded buildGroupMembers() {
    return Expanded(
      child: FutureBuilder<String>(
          future: getParticipantsNameAsCsv(item.jid!),
          builder: (BuildContext context, data) {
            if (data.hasData) {
              return Text(
                data.data ?? "",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: recentChatItemStyle.subtitleTextStyle,
              );
            }
            return const Text("");
          }),
    );
  }

  Future<String> getParticipantsNameAsCsv(String jid) async {
    var groupParticipantsName = ''.obs;
    await Mirrorfly.getGroupMembersList(
        jid: jid,
        fetchFromServer: false,
        flyCallBack: (FlyResponse response) {
          if (response.isSuccess && response.hasData) {
            var str = <String>[];
            var groupsMembersProfileList = memberFromJson(response.data);
            for (var it in groupsMembersProfileList) {
              if (it.jid.checkNull() != SessionManagement.getUserJID().checkNull()) {
                str.add(it.name.checkNull());
              }
            }
            groupParticipantsName(str.join(","));
          }
          return groupParticipantsName.value;
        });
    return groupParticipantsName.value;
  }

  String setRecalledMessageText(bool isFromSender) {
    return (isFromSender) ? getTranslated("youDeletedThisMessage") : getTranslated("thisMessageWasDeleted");
  }
}

class RecentChatMessageItem extends StatelessWidget {
  const RecentChatMessageItem({super.key, required this.profile, required this.item,required this.onTap,this.searchTxt = "", this.recentChatItemStyle = const RecentChatItemStyle()});
  final ProfileDetails profile;
  final ChatMessageModel item;
  final RecentChatItemStyle recentChatItemStyle;
  final Function() onTap;
  final String searchTxt;

  @override
  Widget build(BuildContext context) {
    var unreadMessageCount = "0";
    return InkWell(
      onTap:()=>onTap,
      child: Row(
        children: [
          Container(
              margin: const EdgeInsets.only(left: 19.0, top: 10, bottom: 10, right: 10),
              child: Stack(
                children: [
                  ImageNetwork(
                    url: profile.image.checkNull(),
                    width: recentChatItemStyle.profileImageSize.width,
                    height: recentChatItemStyle.profileImageSize.height,
                    clipOval: true,
                    errorWidget: ProfileTextImage(
                      text: profile.getName(),
                      radius: recentChatItemStyle.profileImageSize.width/2,
                    ),
                    isGroup: profile.isGroupProfile.checkNull(),
                    blocked: profile.isBlockedMe.checkNull() || profile.isAdminBlocked.checkNull(),
                    unknown: (!profile.isItSavedContact.checkNull() || profile.isDeletedContact()),
                  ),
                  unreadMessageCount.toString() != "0"
                      ? Positioned(
                      right: 0,
                      child: CircleAvatar(
                        radius: 9,
                        backgroundColor: recentChatItemStyle.unreadCountBgColor,
                        child: Text(
                          unreadMessageCount.toString(),
                          style: recentChatItemStyle.unreadCountTextStyle,
                          // style: const TextStyle(fontSize: 9, color: Colors.white, fontFamily: 'sf_ui'),
                        ),
                      ))
                      : const Offstage(),
                ],
              )),
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(profile.getName(), //profile.name.toString(),
                        style: recentChatItemStyle.titleTextStyle,
                        // style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700, fontFamily: 'sf_ui', color: textHintColor),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0, left: 8),
                      child: Text(
                        DateTimeUtils.getRecentChatTime(context, item.messageSentTime.toInt()),
                        textAlign: TextAlign.end,
                          style: unreadMessageCount != "0" ? recentChatItemStyle.timeTextStyle.copyWith(color: recentChatItemStyle.unreadColor) : recentChatItemStyle.timeTextStyle
                        /*style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'sf_ui',
                            color: unreadMessageCount.toString() != "0" ? buttonBgColor : textColor),*/
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    unreadMessageCount.toString() != "0"
                        ? const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: CircleAvatar(
                        radius: 4,
                        backgroundColor: Colors.green,
                      ),
                    )
                        : const Offstage(),
                    Expanded(
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: MessageUtils.getMessageIndicatorIcon(item.messageStatus.value.checkNull(), item.isMessageSentByMe.checkNull(),
                                item.messageType.checkNull(), item.isMessageRecalled.value),
                          ),
                          item.isMessageRecalled.value
                              ? const Offstage()
                              : MessageUtils.forMessageTypeIcon(item.messageType, item.mediaChatMessage),
                          SizedBox(
                            width:
                            MessageUtils.forMessageTypeString(item.messageType, content: item.mediaChatMessage?.mediaCaptionText.checkNull()) !=
                                null
                                ? 3.0
                                : 0.0,
                          ),
                          Expanded(
                            child:
                            MessageUtils.forMessageTypeString(item.messageType, content: item.mediaChatMessage?.mediaCaptionText.checkNull()) ==
                                null
                                ? spannableText(
                              item.messageTextContent.toString(),
                              searchTxt,
                              recentChatItemStyle.subtitleTextStyle,recentChatItemStyle.spanTextColor,
                            )
                                : Text(
                              MessageUtils.forMessageTypeString(item.messageType,
                                  content: item.mediaChatMessage?.mediaCaptionText.checkNull()) ??
                                  item.messageTextContent.toString(),
                              // style: Theme.of(context).textTheme.titleSmall,
                              style: recentChatItemStyle.subtitleTextStyle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                AppDivider(color: recentChatItemStyle.dividerColor,)
              ],
            ),
          )
        ],
      ),
    );
  }
}


Widget spannableText(String text, String spannableText, TextStyle? style,Color? spanTextColor) {
  var startIndex = text.toLowerCase().indexOf(spannableText.toLowerCase());
  var endIndex = startIndex + spannableText.length;
  if (startIndex != -1 && endIndex != -1) {
    var startText = text.substring(0, startIndex);
    var colorText = text.substring(startIndex, endIndex);
    var endText = text.substring(endIndex, text.length);
    //LogMessage.d("startText", startText);
    //LogMessage.d("endText", endText);
    //LogMessage.d("colorText", colorText);
    return Text.rich(
      TextSpan(
          text: startText,
          children: [TextSpan(text: colorText, style: TextStyle(color: spanTextColor)/*const TextStyle(color: Colors.blue)*/), TextSpan(text: endText, style: style)],
          style: style),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  } else {
    return Text(text, style: style, maxLines: 1, overflow: TextOverflow.ellipsis);
  }
}

String spannableTextType(String text) {
  if (RegExp(Constants.emailPattern, multiLine: false).hasMatch(text)) {
    return "email";
  }
  // if (RegExp(Constants.mobilePattern).hasMatch(text) &&
  //     !RegExp(Constants.textPattern).hasMatch(text)) {
  //   return "mobile";
  // }
  if (isValidPhoneNumber(text)) {
    return "mobile";
  }
  if (text.isURL) {
    return "website";
  }
  // if (RegExp(Constants.websitePattern).hasMatch(text)) {
  //   return "website";
  // }
  // if (Uri.parse(text).isAbsolute) {
  /*if (Uri.parse(text).host.isNotEmpty) {
    return "website";
  }*/
  return "text";
}

bool isCountryCode(String text) {
  if (RegExp(Constants.countryCodePattern).hasMatch(text)) {
    return true;
  }
  return false;
}

Widget textMessageSpannableText(String message, TextStyle? textStyle,Color urlColor,{int? maxLines,}) {
  //final GlobalKey textKey = GlobalKey();
  TextStyle? underlineStyle = textStyle?.copyWith(color: urlColor,decoration: TextDecoration.underline,decorationColor: urlColor);//const TextStyle(decoration: TextDecoration.underline, fontSize: 14, color: Colors.blueAccent);
  TextStyle? normalStyle = textStyle;//const TextStyle(fontSize: 14, color: textHintColor);
  var prevValue = "";
  return Text.rich(
    customTextSpan(message, prevValue, normalStyle, underlineStyle),
    maxLines: maxLines,
    overflow: maxLines == null ? null : TextOverflow.ellipsis,
  );
}

TextSpan customTextSpan(String message, String prevValue, TextStyle? normalStyle, TextStyle? underlineStyle) {
  return TextSpan(
    children: message.split(" ").map((e) {
      if (isCountryCode(e)) {
        prevValue = e;
      } else if (prevValue != "" && spannableTextType(e) == "mobile") {
        e = "$prevValue $e";
        prevValue = "";
      }
      return TextSpan(
          text: "$e ",
          style: spannableTextType(e) == "text" ? normalStyle : underlineStyle,
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              onTapForSpanText(e);
            });
    }).toList(),
  );
}

onTapForSpanText(String e) {
  var stringType = spannableTextType(e);
  debugPrint("Text span click");
  if (stringType == "website") {
    if(e.startsWith(Constants.webChatLogin)){
      AppUtils.isNetConnected().then((value){
        if(value) {
          NavUtils.toNamed(Routes.joinCallPreview, arguments: {
            "callLinkId": e.replaceAll(Constants.webChatLogin, "")
          });
        }else{
          toToast(getTranslated("noInternetConnection"));
        }
      });
    }else {
      launchInBrowser(e);
    }
    // return;
  } else if (stringType == "mobile") {
    makePhoneCall(e);
    // launchCaller(e);
    // return;
  } else if (stringType == "email") {
    debugPrint("email click");
    launchEmail(e);
    // return;
  } else {
    debugPrint("no condition match");
  }
  // return;
}

Widget callLogTime(String time, int? callState,TextStyle? textStyle) {
  return Row(
    children: [
      callState == 0
          ? AppUtils.svgIcon(icon: arrowDropDown,
              colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn),
            )
          : callState == 1
              ? AppUtils.svgIcon(icon: arrowUpIcon,
                  colorFilter: const ColorFilter.mode(Colors.green, BlendMode.srcIn),
                )
              : AppUtils.svgIcon(icon: arrowDownIcon,
                  colorFilter: const ColorFilter.mode(Colors.green, BlendMode.srcIn),
                ),
      const SizedBox(
        width: 5,
      ),
      Text(
        time,
        style: textStyle,
        // style: const TextStyle(color: Colors.black),
      ),
    ],
  );
}


