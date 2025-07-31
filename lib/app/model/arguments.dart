
import 'chat_message_model.dart';

class DashboardViewArguments {
  final bool didMissedCallNotificationLaunchApp;

  const DashboardViewArguments(
      {this.didMissedCallNotificationLaunchApp = false});
}

class ChatViewArguments {
  const ChatViewArguments({
    required this.chatJid,
    this.topicId = '',
    this.didNotificationLaunchApp = false,
    this.isUser = false,
    this.messageId,
    // this.isFromStarred = false,
    this.enableCalls = true,
    this.showChatDeliveryIndicator = true,
    this.disableAppBar = false,
    this.chatInfoPageRedirect = false,
    this.enableSwipeToReply = true,
    this.menuActionsEnabled = false,
    this.isAppBarForwardEnabled = true,
    this.isMessageWidgetForwardEnabled = true,
    this.isAppBarReplyEnabled = true,
    this.isAppBarStarEnabled = true,
    this.isAppBarDeleteMessageEnabled = true,
    this.isAppBarCopyMessageEnabled = true,
    this.isAppBarMessageInfoEnabled = true,
    this.isAppBarReportEnabled = true,
    this.isAppBarClearChatEnabled = true,
    this.isAppBarBlockEnabled = true,
    this.isAppBarSearchEnabled = true,
    this.isAppBarEmailEnabled = true,
    this.isAppBarEditMessageEnabled = true,
    this.isAppBarShareEnabled = true,
    this.isVoiceCallEnabled = true,
    this.isVideoCallEnabled = true,
    this.swipeSensitivity = 5,
    this.showTopicName = true,
    this.topicTitleColor,
    this.topicTitleBgColor,
    this.messageTextFieldInputFormatters,
  }) : assert(swipeSensitivity >= 5 && swipeSensitivity <= 20,
            'swipeSensitivity must be between 5 and 20');

  final String chatJid;
  final String topicId;
  final bool isUser;
  // final bool isFromStarred;
  final String? messageId;
  final bool enableCalls;
  final bool showChatDeliveryIndicator;
  final bool didNotificationLaunchApp;
  final bool disableAppBar;
  final bool enableSwipeToReply;
  final bool menuActionsEnabled;
  final bool chatInfoPageRedirect;
  final bool isAppBarForwardEnabled;
  final bool isMessageWidgetForwardEnabled;
  final bool isAppBarReplyEnabled;
  final bool isAppBarStarEnabled;
  final bool isAppBarDeleteMessageEnabled;
  final bool isAppBarCopyMessageEnabled;
  final bool isAppBarMessageInfoEnabled;
  final bool isAppBarReportEnabled;
  final bool isAppBarClearChatEnabled;
  final bool isAppBarBlockEnabled;
  final bool isAppBarSearchEnabled;
  final bool isAppBarEmailEnabled;
  final bool isAppBarEditMessageEnabled;
  final bool isAppBarShareEnabled;
  final bool isVoiceCallEnabled;
  final bool isVideoCallEnabled;

  final int swipeSensitivity;
  final bool showTopicName;
  final Color? topicTitleColor;
  final Color? topicTitleBgColor;

  final List<TextInputFormatter>? messageTextFieldInputFormatters;
}

class ChatSearchViewArguments {
  const ChatSearchViewArguments(
      {required this.chatJid,
      required this.chatList,
      this.showChatDeliveryIndicator = true,
      this.disableAppBar = false});

  final String chatJid;
  final List<ChatMessageModel> chatList;
  final bool showChatDeliveryIndicator;
  final bool disableAppBar;
}

class ContactListArguments {
  const ContactListArguments(
      {this.messageIds = const [],
      this.topicId = "",
      this.callType = "",
      this.forMakeCall = false,
      this.groupJid = "",
      this.forGroup = false});
  final List<String> messageIds;
  final String groupJid;
  final String topicId;
  final String callType;
  final bool forMakeCall;
  final bool forGroup;
}

class ChatInfoArguments {
  final String chatJid;
  final bool disableAppbar;

  const ChatInfoArguments({required this.chatJid, this.disableAppbar = false});
}

class ViewAllMediaArguments {
  final String chatJid;
  const ViewAllMediaArguments({required this.chatJid});
}
