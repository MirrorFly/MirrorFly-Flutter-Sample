
import 'chat_message_model.dart';

class DashboardViewArguments{
  final bool didMissedCallNotificationLaunchApp;

  const DashboardViewArguments({this.didMissedCallNotificationLaunchApp = false});
}
class ChatViewArguments{
  const ChatViewArguments({
    required this.chatJid,
    this.topicId = '',
    this.didNotificationLaunchApp = false,
    this.isUser = false,
    this.messageId,
    // this.isFromStarred = false,
    this.enableCalls = true,
    this.showChatDeliveryIndicator = true,this.disableAppBar = false});

  final String chatJid;
  final String topicId;
  final bool isUser;
  // final bool isFromStarred;
  final String? messageId;
  final bool enableCalls;
  final bool showChatDeliveryIndicator;
  final bool didNotificationLaunchApp;
  final bool disableAppBar;
}

class ChatSearchViewArguments{
  const ChatSearchViewArguments({
    required this.chatJid,
    required this.chatList,
    this.showChatDeliveryIndicator = true,this.disableAppBar = false});

  final String chatJid;
  final List<ChatMessageModel> chatList;
  final bool showChatDeliveryIndicator;
  final bool disableAppBar;
}

class ContactListArguments{
  const ContactListArguments(
      {this.messageIds = const [], this.topicId = "", this.callType = "", this.forMakeCall = false,this.groupJid = "",this.forGroup = false});
  final List<String> messageIds;
  final String groupJid;
  final String topicId;
  final String callType;
  final bool forMakeCall;
  final bool forGroup;
}

class ChatInfoArguments{
  final String chatJid;
  final bool disableAppbar;
  const ChatInfoArguments({required this.chatJid,this.disableAppbar = false});
}

class ViewAllMediaArguments{
  final String chatJid;
  const ViewAllMediaArguments({required this.chatJid});
}