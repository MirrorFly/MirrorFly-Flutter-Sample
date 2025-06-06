import 'package:flutter/material.dart';
import 'package:mirror_fly_demo/app/modules/chat/widgets/custom_text_view.dart';

import '../../../common/app_localizations.dart';
import '../../../common/constants.dart';
import '../../../data/helper.dart';
import '../../../data/utils.dart';
import '../../../extensions/extensions.dart';
import '../../../model/chat_message_model.dart';
import '../../../routes/route_settings.dart';
import '../../../stylesheet/stylesheet.dart';

class TextMessageView extends StatelessWidget {
  const TextMessageView(
      {Key? key,
      required this.chatMessage,
      this.search = "",
      this.textMessageViewStyle = const TextMessageViewStyle()})
      : super(key: key);
  final ChatMessageModel chatMessage;
  final String search;
  final TextMessageViewStyle textMessageViewStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 9, 5, 2),
          child: Row(
            mainAxisSize: chatMessage.replyParentChatMessage == null
                ? MainAxisSize.min
                : MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flexible(
                  child: GestureDetector(
                onTap: (MessageUtils.getCallLinkFromMessage(
                            chatMessage.messageTextContent.checkNull())
                        .isNotEmpty)
                    ? () async {
                        if (await AppUtils.isNetConnected()) {
                          var link = MessageUtils.getCallLinkFromMessage(
                              chatMessage.messageTextContent.checkNull());
                          if (link.isNotEmpty) {
                            NavUtils.toNamed(Routes.joinCallPreview,
                                arguments: {
                                  "callLinkId": link.replaceAll(
                                      Constants.webChatLogin, "")
                                });
                          }
                        } else {
                          toToast(getTranslated("noInternetConnection"));
                        }
                      }
                    : null,
                child: CustomTextView(
                  key: Key("message_view+${chatMessage.messageId}"),
                  text: chatMessage.messageTextContent.checkNull(),
                  defaultTextStyle: textMessageViewStyle.textStyle,
                  linkColor: textMessageViewStyle.urlMessageColor,
                  mentionUserTextColor: textMessageViewStyle.mentionUserColor,
                  searchQueryTextColor: textMessageViewStyle.highlightColor,
                  searchQueryString: search,
                  mentionUserIds: chatMessage.mentionedUsersIds ?? [],
                  mentionedMeBgColor: textMessageViewStyle.mentionedMeBgColor,
                ),
              )),
              const SizedBox(
                width: 60,
              ),
            ],
          ),
        ),
        if (MessageUtils.getCallLinkFromMessage(
                chatMessage.messageTextContent.checkNull())
            .isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: CallLinkView(
              message: chatMessage.messageTextContent.checkNull(),
              callLinkViewStyle: textMessageViewStyle.callLinkViewStyle,
            ),
          )
        ],
        Padding(
          padding: const EdgeInsets.only(right: 4.0, bottom: 2),
          child: Row(
            mainAxisSize: chatMessage.replyParentChatMessage == null
                ? MainAxisSize.min
                : MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              chatMessage.isMessageStarred.value
                  ? textMessageViewStyle.iconFavourites ??
                      AppUtils.svgIcon(icon: starSmallIcon)
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
                width: 5,
              ),
              if (chatMessage.isMessageEdited.value) ...[
                Text(
                  getTranslated(
                      "edited"), //style: const TextStyle(fontSize: 11)
                  style: textMessageViewStyle.timeTextStyle,
                ),
                const SizedBox(
                  width: 5,
                ),
              ],
              Text(
                getChatTime(context, chatMessage.messageSentTime.toInt()),
                style: textMessageViewStyle.timeTextStyle,
                /*style: TextStyle(
                    fontSize: 11,
                    color: chatMessage.isMessageSentByMe
                        ? durationTextColor
                        : textHintColor),*/
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CallLinkView extends StatelessWidget {
  const CallLinkView(
      {super.key, required this.message, required this.callLinkViewStyle});
  final String message;
  final CallLinkViewStyle callLinkViewStyle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (await AppUtils.isNetConnected()) {
          var link = MessageUtils.getCallLinkFromMessage(message);
          if (link.isNotEmpty) {
            NavUtils.toNamed(Routes.joinCallPreview, arguments: {
              "callLinkId": link.replaceAll(Constants.webChatLogin, "")
            });
          }
        } else {
          toToast(getTranslated("noInternetConnection"));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: callLinkViewStyle.decoration,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            AppUtils.assetIcon(
              assetName: mirrorflySmall,
              width: 24,
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
                child: Text(
              getTranslated("joinVideoCall"),
              style: callLinkViewStyle.textStyle,
            )),
            const SizedBox(
              width: 8,
            ),
            AppUtils.svgIcon(
              icon: videoCamera,
              width: 18,
              colorFilter: ColorFilter.mode(
                  callLinkViewStyle.iconColor, BlendMode.srcIn),
            )
          ],
        ),
      ),
    );
  }
}
