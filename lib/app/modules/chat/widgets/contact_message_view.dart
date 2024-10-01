import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../extensions/extensions.dart';
import '../../../stylesheet/stylesheet.dart';
import 'package:mirrorfly_plugin/mirrorfly.dart' hide ChatMessageModel, ContactChatMessage;
import 'package:url_launcher/url_launcher.dart';

import '../../../common/app_localizations.dart';
import '../../../common/constants.dart';
import '../../../common/widgets.dart';
import '../../../data/helper.dart';
import '../../../data/session_management.dart';
import '../../../data/utils.dart';
import '../../../model/chat_message_model.dart';
import '../../../routes/route_settings.dart';
import '../../dashboard/widgets.dart';
import 'chat_widgets.dart';

class ContactMessageView extends StatelessWidget {
  const ContactMessageView({Key? key,
    required this.chatMessage,
    this.search = "",
    required this.isSelected,
  this.contactMessageViewStyle = const ContactMessageViewStyle(),
  this.decoration = const BoxDecoration()})
      : super(key: key);
  final ChatMessageModel chatMessage;
  final String search;
  final bool isSelected;
  final ContactMessageViewStyle contactMessageViewStyle;
  final Decoration decoration;

  @override
  Widget build(BuildContext context) {
    var screenWidth = NavUtils.width;
    return SizedBox(
      width: screenWidth * 0.60,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
            child: Row(
              children: [
                AppUtils.assetIcon(assetName:
                  profileImage,
                  width: contactMessageViewStyle.profileImageSize.width,//35,
                  height: contactMessageViewStyle.profileImageSize.height,//35
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                    child: search.isEmpty
                        ? textMessageSpannableText(
                        chatMessage.contactChatMessage!.contactName
                            .checkNull(),contactMessageViewStyle.textMessageViewStyle.textStyle,contactMessageViewStyle.textMessageViewStyle.urlMessageColor,
                        maxLines: 2)
                        : chatSpannedText(
                        chatMessage.contactChatMessage!.contactName,
                        search,
                        contactMessageViewStyle.textMessageViewStyle.textStyle,//const TextStyle(fontSize: 14, color: textHintColor),
                        maxLines: 2,
                        spanColor: contactMessageViewStyle.textMessageViewStyle.highlightColor,
                    urlColor: contactMessageViewStyle.textMessageViewStyle.urlMessageColor) /*,Text(
                  chatMessage.contactChatMessage!.contactName,
                  maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                )*/
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                chatMessage.isMessageStarred.value
                    ? AppUtils.svgIcon(icon:starSmallIcon)
                    : const Offstage(),
                const SizedBox(
                  width: 5,
                ),
                MessageUtils.getMessageIndicatorIcon(
                    chatMessage.messageStatus.value,
                    chatMessage.isMessageSentByMe,
                    chatMessage.messageType,
                    chatMessage.isMessageRecalled.value),
                const SizedBox(
                  width: 4,
                ),
                Text(
                  getChatTime(context, chatMessage.messageSentTime.toInt()),
                  style: contactMessageViewStyle.textMessageViewStyle.timeTextStyle,
                  /*style: TextStyle(
                      fontSize: 11,
                      color: chatMessage.isMessageSentByMe
                          ? durationTextColor
                          : textHintColor),*/
                ),
                const SizedBox(
                  width: 10,
                ),
              ],
            ),
          ),
          AppDivider(color: contactMessageViewStyle.dividerColor,),
          getJidOfContact(chatMessage.contactChatMessage,contactMessageViewStyle.viewTextStyle),
        ],
      ),
    );
  }

  Future<String?> getUserJid(ContactChatMessage contactChatMessage) async {
    for (int i = 0; i < contactChatMessage.contactPhoneNumbers.length; i++) {
      debugPrint(
          "contactChatMessage.isChatAppUser[i]--> ${contactChatMessage.isChatAppUser[i]}");
      if (contactChatMessage.isChatAppUser[i]) {
        return await Mirrorfly.getJidFromPhoneNumber(mobileNumber: contactChatMessage.contactPhoneNumbers[i],
            countryCode: (SessionManagement.getCountryCode() ?? "").replaceAll('+', ''));
      }
    }
    return '';
  }

  Widget getJidOfContact(ContactChatMessage? contactChatMessage,TextStyle? textStyle) {
    // String? userJid;
    if (contactChatMessage == null ||
        contactChatMessage.contactPhoneNumbers.isEmpty) {
      return const Offstage();
    }
    return FutureBuilder(
        future: getUserJid(contactChatMessage),
        builder: (context, snapshot) {
          if (snapshot.hasError || !snapshot.hasData) {
            return const Offstage();
          }
          var userJid = snapshot.data;
          debugPrint("getJidOfContact--> $userJid");
          return InkWell(
            onTap: () {
              (userJid != null && userJid.isNotEmpty)
                  ? sendToChatPage(userJid)
                  : showInvitePopup(contactChatMessage);
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                    child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: (userJid != null && userJid.isNotEmpty)
                              ? Text(getTranslated("message"))
                              : Text(getTranslated("invite")),
                        ))),
              ],
            ),
          );
        });
  }

  sendToChatPage(String userJid) {
    // NavUtils.back();
    LogMessage.d('NavUtils.currentRoute', NavUtils.currentRoute);
    if (NavUtils.currentRoute == Routes.chat) {
      NavUtils.back();
      Future.delayed(const Duration(milliseconds: 500), () {
        NavUtils.toNamed(Routes.chat,
            parameters: {'isFromStarred': 'true', "userJid": userJid});
      });
    } else {
      NavUtils.back();
      sendToChatPage(userJid);
      /*NavUtils.toNamed(Routes.chat,
          parameters: {'isFromStarred': 'true', "userJid": userJid});*/
    }
  }

  showInvitePopup(ContactChatMessage contactChatMessage) {
    DialogUtils.showButtonAlert(actions: [
      ListTile(
        contentPadding: const EdgeInsets.only(left: 10),
        title: Text(getTranslated("inviteFriend"),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ),
      ListTile(
        contentPadding: const EdgeInsets.only(left: 10),
        title: Text(getTranslated("copyLink"),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
        onTap: () {
          Clipboard.setData(ClipboardData(text: getTranslated("applicationLink")));
          NavUtils.back();
          toToast(getTranslated("linkCopied"));
        },
      ),
      ListTile(
        contentPadding: const EdgeInsets.only(left: 10),
        title: Text(getTranslated("sendSMS"),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
        onTap: () {
          NavUtils.back();
          sendSMS(contactChatMessage.contactPhoneNumbers[0]);
        },
      ),
    ]);
  }

  void sendSMS(String contactPhoneNumber) async {
    Uri sms = Uri.parse('sms:$contactPhoneNumber?body=${getTranslated("smsContent")}');
    if (await launchUrl(sms)) {
      //app opened
    } else {
      //app is not opened
    }
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) =>
    '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}