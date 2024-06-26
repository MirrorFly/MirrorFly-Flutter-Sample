
class DashboardViewArguments{
  final bool didMissedCallNotificationLaunchApp;

  DashboardViewArguments({this.didMissedCallNotificationLaunchApp = false});
}
class ChatViewArguments{
  ChatViewArguments({
    required this.chatJid,
    this.topicId = '',
    this.didNotificationLaunchApp = false,
    this.isUser = false,
    this.messageId,
    // this.isFromStarred = false,
    this.enableCalls = false,
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

class ContactListArguments{
  ContactListArguments(
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
  ChatInfoArguments({required this.chatJid,this.disableAppbar = false});
}

class ViewAllMediaArguments{
  final String chatJid;
  ViewAllMediaArguments({required this.chatJid});
}