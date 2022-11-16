import 'chatMessageModel.dart';

abstract class GroupedMedia{
  var id;
}
class MessageItem implements GroupedMedia {
  final ChatMessageModel chatMessage;
  Map? linkMap = {};
  @override var id = -double.infinity+0;
  MessageItem(this.chatMessage, [this.linkMap]);
}
class Header implements GroupedMedia {
  final String titleName;
  @override
  var id = -double.infinity+1;
  Header(this.titleName);
}