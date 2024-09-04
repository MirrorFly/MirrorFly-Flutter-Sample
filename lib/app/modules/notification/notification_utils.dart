import '../../common/app_localizations.dart';
import '../../common/constants.dart';
import '../../extensions/extensions.dart';
import '../../model/chat_message_model.dart';

class NotificationUtils{
  static var deletedMessage = getTranslated("deletedMessage");
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
        contentBuilder.write("$audioEmoji ${getTranslated("notificationAudio")}");
        break;
      case Constants.mContact:
        contentBuilder.write("$contactEmoji ${getTranslated("notificationContact")}");
        break;
      case Constants.mDocument:
        contentBuilder.write("$fileEmoji ${getTranslated("notificationFile")}");
        break;
      case Constants.mImage:
        contentBuilder.write("$imageEmoji ${getMentionMediaCaptionTextFormat(message)}");
        break;
      case Constants.mLocation:
        contentBuilder.write("$locationEmoji ${getTranslated("notificationLocation")}");
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
      case Constants.mImage: return getTranslated("notificationImage");
      case Constants.mFile: return getTranslated("notificationFile");
      case Constants.mAudio: return getTranslated("notificationAudio");
      case Constants.mVideo: return getTranslated("notificationVideo");
      case Constants.mDocument: return getTranslated("notificationDocument");
      case Constants.mContact: return getTranslated("notificationContact");
      case Constants.mLocation: return getTranslated("notificationLocation");
      default: return messageType;
    }
  }
}