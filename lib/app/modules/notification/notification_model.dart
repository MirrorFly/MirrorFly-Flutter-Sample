import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../model/notification_message_model.dart';

class NotificationModel {
  MessagingStyleInformation? messagingStyle;
  List<ChatMessage>? messages;
  int? unReadMessageCount;

  NotificationModel(
      {this.messagingStyle, this.messages, this.unReadMessageCount});
}

extension NotificatioModelMapper on NotificationModel{
  Map<String, Object?> toMap() => <String, Object?>{
    'messagingStyle': messagingStyle?.toMap(),
    'messages': List<dynamic>.from(messages!.map((x) => x.toJson())),
    'unReadMessageCount': unReadMessageCount
  };
}
extension PersonMapper on Person {
  Map<String, Object?> toMap() => <String, Object?>{
    'bot': bot,
    'important': important,
    'key': key,
    'name': name,
    'uri': uri
  }..addAll(_convertIconToMap());

  Map<String, Object> _convertIconToMap() {
    if (icon == null) {
      return <String, Object>{};
    }
    return <String, Object>{
      'icon': icon!.data,
      'iconSource': icon!.source.index,
    };
  }
}


extension MessageMapper on Message {
  Map<String, Object?> toMap() => <String, Object?>{
    'text': text,
    'timestamp': timestamp.millisecondsSinceEpoch,
    'person': person?.toMap(),
    'dataMimeType': dataMimeType,
    'dataUri': dataUri
  };
}

extension MessagingStyleInformationMapper on MessagingStyleInformation {
  Map<String, Object?> toMap() => <String, Object?>{
      'person': person.toMap(),
      'conversationTitle': conversationTitle,
      'groupConversation': groupConversation,
      'messages': messages
          ?.map((m) => m.toMap()) // ignore: always_specify_types
          .toList()
    };
}