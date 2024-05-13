import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/common/app_localizations.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/extensions/extensions.dart';
import '../../common/constants.dart';
import '../../common/widgets.dart';
import 'package:mirrorfly_plugin/mirrorflychat.dart';

import '../../data/session_management.dart';
import '../../data/utils.dart';
import '../../model/chat_message_model.dart';

Widget searchHeader(String? type, String count, BuildContext context) {
  return Container(
    width: MediaQuery.of(context).size.width,
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
      this.archiveEnabled = false})
      : super(key: key);
  final RecentChatData item;
  final Function() onTap;
  final Function()? onLongPress;
  final Function()? onAvatarClick;
  final String spanTxt;
  final bool isCheckBoxVisible;
  final bool isChecked;
  final bool isForwardMessage;
  final bool archiveVisible;
  final Function(bool? value)? onchange;
  final bool isSelected;
  final String typingUserid;

  final titleStyle = const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700, fontFamily: 'sf_ui', color: textHintColor);
  final typingStyle = const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600, fontFamily: 'sf_ui', color: buttonBgColor);
  final bool archiveEnabled;

  @override
  Widget build(BuildContext context) {
    LogMessage.d("RecentChatItem", "build ${item.jid}");
    return Container(
      key: ValueKey(item.jid),
      color: isSelected ? Colors.black12 : Colors.transparent,
      child: Row(
        children: [
          buildProfileImage(),
          Expanded(
            child: InkWell(
              onLongPress: onLongPress,
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [buildRecentChatMessageDetails(), buildRecentChatActions(context)],
                    ),
                    const AppDivider(
                      padding: EdgeInsets.only(top: 8),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
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
                  style: titleStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : spannableText(
                  getRecentName(item),
                  //item.profileName.checkNull(),
                  spanTxt,
                  titleStyle),
          Row(
            children: [
              item.isLastMessageSentByMe.checkNull() && !isForwardMessage && !item.isLastMessageRecalledByUser.checkNull()
                  ? (item.lastMessageType == MessageType.isText && item.lastMessageContent.checkNull().isNotEmpty ||
                              item.lastMessageType != MessageType.isText) &&
                          typingUserid.isEmpty
                      ? buildMessageIndicator()
                      : const SizedBox()
                  : const SizedBox(),
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
        getRecentChatTime(context, item.lastMessageTime),
        textAlign: TextAlign.end,
        style: TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.w600,
            fontFamily: 'sf_ui',
            color: returnFormattedCount(item.unreadMessageCount!) != "0"
                //item.isConversationUnRead!
                ? buttonBgColor
                : textColor),
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

  InkWell buildProfileImage() {
    return InkWell(
      onTap: onAvatarClick,
      child: Container(
          margin: const EdgeInsets.only(left: 19.0, top: 10, bottom: 10, right: 10),
          child: Stack(
            children: [
              buildProfileImageView(),
              item.isConversationUnRead! ? buildConvReadIcon() : const SizedBox(),
              item.isEmailContact().checkNull() ? buildEmailIcon() : const SizedBox.shrink(),
            ],
          )),
    );
  }

  ImageNetwork buildProfileImageView() {
    return ImageNetwork(
      url: item.profileImage.toString(),
      width: 48,
      height: 48,
      clipOval: true,
      errorWidget: item.isGroup!
          ? ClipOval(
              child: Image.asset(
                groupImg,
                height: 48,
                width: 48,
                fit: BoxFit.cover,
              ),
            )
          : ProfileTextImage(
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

  Positioned buildConvReadIcon() {
    return Positioned(
        right: 0,
        child: CircleAvatar(
          backgroundColor: buttonBgColor,
          radius: 9,
          child: Text(
            returnFormattedCount(item.unreadMessageCount!) != "0" ? returnFormattedCount(item.unreadMessageCount!) : "",
            style: const TextStyle(fontSize: 8, color: Colors.white, fontFamily: 'sf_ui'),
          ),
        ));
  }

  Positioned buildEmailIcon() {
    return Positioned(right: 0, bottom: 0, child: SvgPicture.asset(emailContactIcon));
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
        ) /*SvgPicture.asset(
                                      archive,
                                      width: 18,
                                      height: 18,
                                    )*/
        );
  }

  Visibility buildMuteIconVisibility() {
    return Visibility(
        visible: !archiveEnabled && item.isMuted! && !isForwardMessage,
        child: SvgPicture.asset(
          mute,
          width: 13,
          height: 13,
        ));
  }

  Visibility buildPinIconVisibility() {
    return Visibility(
        visible: !item.isChatArchived! && item.isChatPinned! && !isForwardMessage,
        child: SvgPicture.asset(
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
            (forMessageTypeString(chat.messageType, content: chat.messageTextContent.checkNull()).checkNull().isNotEmpty);
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
                          style: Theme.of(context).textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    : const SizedBox.shrink(),
                chat.isMessageRecalled.value ? const SizedBox.shrink() : forMessageTypeIcon(chat.messageType, chat.mediaChatMessage),
                SizedBox(
                  width: chat.isMessageRecalled.value
                      ? 0.0
                      : forMessageTypeString(chat.messageType, content: chat.messageTextContent.checkNull()) != null
                          ? 3.0
                          : 0.0,
                ),
                Expanded(
                  child: spanTxt.isEmpty
                      ? Text(
                          chat.isMessageRecalled.value
                              ? setRecalledMessageText(chat.isMessageSentByMe)
                              : forMessageTypeString(chat.messageType, content: chat.mediaChatMessage?.mediaCaptionText.checkNull()) ??
                                  chat.messageTextContent.checkNull(),
                          style: Theme.of(context).textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : spannableText(
                          chat.isMessageRecalled.value
                              ? setRecalledMessageText(chat.isMessageSentByMe)
                              : forMessageTypeString(chat.messageType.checkNull(), content: chat.mediaChatMessage?.mediaCaptionText.checkNull()) ??
                                  chat.messageTextContent.checkNull(),
                          spanTxt,
                          Theme.of(context).textTheme.titleSmall),
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
                return Text(profileData.data?.status ?? "");
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

Widget spannableText(String text, String spannableText, TextStyle? style) {
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
          children: [TextSpan(text: colorText, style: const TextStyle(color: Colors.blue)), TextSpan(text: endText, style: style)],
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

Widget textMessageSpannableText(String message, {int? maxLines}) {
  //final GlobalKey textKey = GlobalKey();
  TextStyle underlineStyle = const TextStyle(decoration: TextDecoration.underline, fontSize: 14, color: Colors.blueAccent);
  TextStyle normalStyle = const TextStyle(fontSize: 14, color: textHintColor);
  var prevValue = "";
  return Text.rich(
    customTextSpan(message, prevValue, normalStyle, underlineStyle),
    maxLines: maxLines,
    overflow: maxLines == null ? null : TextOverflow.ellipsis,
  );
}

TextSpan customTextSpan(String message, String prevValue, TextStyle? normalStyle, TextStyle underlineStyle) {
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
    launchInBrowser(e);
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

Widget callLogTime(String time, int? callState) {
  return Row(
    children: [
      callState == 0
          ? SvgPicture.asset(
              "assets/calls/ic_arrow_down_red.svg",
              colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn),
            )
          : callState == 1
              ? SvgPicture.asset(
                  "assets/calls/ic_arrow_up_green.svg",
                  colorFilter: const ColorFilter.mode(Colors.green, BlendMode.srcIn),
                )
              : SvgPicture.asset(
                  "assets/calls/ic_arrow_down_green.svg",
                  colorFilter: const ColorFilter.mode(Colors.green, BlendMode.srcIn),
                ),
      const SizedBox(
        width: 5,
      ),
      Text(
        time,
        style: const TextStyle(color: Colors.black),
      ),
    ],
  );
}


