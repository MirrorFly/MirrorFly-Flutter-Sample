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
    this.isFromStarred = false,
    this.enableAppBar = true,
    this.enableCalls = false,
    this.showChatDeliveryIndicator = true});

  final String chatJid;
  final String topicId;
  final bool isUser;
  final bool isFromStarred;
  final String? messageId;
  final bool enableAppBar;
  final bool enableCalls;
  final bool showChatDeliveryIndicator;
  final bool didNotificationLaunchApp;
}