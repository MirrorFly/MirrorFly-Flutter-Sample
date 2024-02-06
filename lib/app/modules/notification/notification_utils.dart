import 'package:mirror_fly_demo/app/common/constants.dart';
import 'package:mirror_fly_demo/app/data/helper.dart';
import 'package:mirror_fly_demo/app/model/chat_message_model.dart';

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
  static String getMessageSummary(ChatMessageModel message){
    if(Constants.mText == message.messageType || Constants.mNotification == message.messageType) {
      if (message.isMessageRecalled.value.checkNull()) {
        return deletedMessage;
      } else {
        var lastMessageMentionContent = message.messageTextContent.checkNull();
        /*if(message.mentionedUsersIds!=null && message.mentionedUsersIds!.isNotEmpty){
          //need to work on mentions
        }*/
        return lastMessageMentionContent;
      }
    }else if(message.isMessageRecalled.value.checkNull()){
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
  static String getMediaMessageContent(ChatMessageModel message){
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
  static String getMentionMediaCaptionTextFormat(ChatMessageModel message){
    var mediaCaption = (message.mediaChatMessage != null && message.mediaChatMessage?.mediaCaptionText !=null && message.mediaChatMessage!.mediaCaptionText.toString().isNotEmpty)
        ? message.mediaChatMessage!.mediaCaptionText.toString() : getMessageTypeText(message.messageType.toString().toUpperCase());
    return mediaCaption;
  }

  static String getMessageTypeText(String messageType){
    switch(messageType){
      case Constants.mImage: return "Image";
      case Constants.mFile: return "File";
      case Constants.mAudio: return "Audio";
      case Constants.mVideo: return "Video";
      case Constants.mDocument: return "Document";
      case Constants.mContact: return "Contact";
      case Constants.mLocation: return "Location";
      default: return messageType;
    }
  }
}