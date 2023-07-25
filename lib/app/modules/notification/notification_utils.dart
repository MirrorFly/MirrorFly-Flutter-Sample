import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/model/notification_message_model.dart';

class NotificationUtils{
  static var deletedMessage = 'This message was deleted';
  static var imageEmoji = "📷";
  static var videoEmoji = "📽️";
  static var contactEmoji = "👤";
  static var audioEmoji = "🎵";
  static var fileEmoji = "📄";
  static var locationEmoji = "📌";

  /*
  * Returns the message summary
  * @param message Instance on ChatMessage in NotificationMessageModel
  * @return String Summary of the message
  * */
  static String getMessageSummary(ChatMessage message){
    if(Constants.mText == message.messageType || Constants.mNotification == message.messageType) {
      if (message.isMessageRecalled.checkNull()) {
        return deletedMessage;
      } else {
        var lastMessageMentionContent = message.messageTextContent ?? '';
        if(message.mentionedUsersIds!=null && message.mentionedUsersIds!.isNotEmpty){
          //need to work on mentions
        }
        return lastMessageMentionContent;
      }
    }else if(message.isMessageRecalled.checkNull()){
      return deletedMessage;
    }else{
      return getMediaMessageContent(message);
    }
  }

  /*
  * Returns the media message Content
  * @param message Instance of ChatMessage in NotificationMessageModel
  * @return String media message content
  * */
  static String getMediaMessageContent(ChatMessage message){
    var contentBuilder = StringBuffer();
    switch(message.messageType){
      case Constants.mAudio:
        contentBuilder.write("$audioEmoji Audio");
        break;
      case Constants.mContact:
        contentBuilder.write("$contactEmoji Contact");
        break;
      case Constants.mDocument:
        contentBuilder.write("$fileEmoji File");
        break;
      case Constants.mImage:
        contentBuilder.write("$imageEmoji ${getMentionMediaCaptionTextFormat(message)}");
        break;
      case Constants.mLocation:
        contentBuilder.write("$locationEmoji Location");
        break;
      case Constants.mVideo:
        contentBuilder.write("$videoEmoji ${getMentionMediaCaptionTextFormat(message)}");
        break;
    }
    return contentBuilder.toString();
  }

  /*
  * Returns the image or video media message caption
  * @param message Instance of ChatMessage in NotificationMessageModel
  * @return String image or video media message caption
  * */
  static String getMentionMediaCaptionTextFormat(ChatMessage message){
    var mediaCaption = (message.mediaChatMessage != null && message.mediaChatMessage?.mediaCaptionText !=null && message.mediaChatMessage!.mediaCaptionText.toString().isNotEmpty)
        ? message.mediaChatMessage!.mediaCaptionText!.toString() : message.messageType.toString().toUpperCase();
    return mediaCaption;
  }
}