part of 'stylesheet.dart';

class MessageTypingAreaStyle{
  const MessageTypingAreaStyle({
    this.decoration = const BoxDecoration(
      border: Border.fromBorderSide(BorderSide(color: Color(0xffC1C1C1),)),
      borderRadius: BorderRadius.all(Radius.circular(40)),
      color: Colors.white,
    ),
    this.textFieldStyle = const EditTextFieldStyle(editTextStyle: TextStyle(fontWeight: FontWeight.w600, color: Color(0xff181818),fontSize: 16),editTextHintStyle: TextStyle(fontWeight: FontWeight.w300, color: Color(0xff959595),fontSize: 12)),
    this.mentionTextStyle = const TextStyle(
        color: Colors.blueAccent,
        backgroundColor: Colors.transparent),
    this.dividerColor = const Color(0xff000000),
    this.sentIconColor = const Color(0xff4879F9),
    this.audioRecordIcon = const IconStyle(iconColor: Colors.white,bgColor:AppColor.primaryColor),
    this.rippleColor = const Color(0xff4879F9),
    this.attachmentIconColor = const Color(0xff363636),
    this.emojiIconColor = const Color(0xff363636),
    this.replyHeaderMessageViewStyle = const ReplyHeaderMessageViewStyle(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: Color(0xffD0D8EB),),titleTextStyle: TextStyle(fontWeight: FontWeight.w600,color: Colors.black,fontSize: 11),
        contentTextStyle: TextStyle(fontWeight: FontWeight.normal,color: Colors.black,fontSize: 13),
        mediaIconStyle: IconStyle(bgColor:Color(0xff7285B5),iconColor: Colors.white),
      borderRadius: BorderRadius.only(topRight: Radius.circular(5), bottomRight: Radius.circular(5))
    ),
    this.replyBgColor = const  Color(0xffE2E8F7),
    this.audioRecordingViewStyle = const AudioRecordingViewStyle(durationTextStyle: TextStyle(fontWeight: FontWeight.normal,color: AppColor.primaryColor,fontSize: 12),
    cancelTextStyle: TextStyle(fontWeight: FontWeight.w300,color: Color(0xff363636),fontSize: 12)),
    this.bgColor = Colors.white,
    this.iconEmoji,
    this.iconKeyBoard,
    this.iconAttachment,
    this.iconRecord,
    this.iconSend,
    this.mentionUserStyle = const ContactItemStyle(
        profileImageSize: Size(36, 36),
        titleStyle: TextStyle(fontWeight: FontWeight.w600,color: Color(0xff181818),fontSize: 15),
        dividerColor: Color(0xffEBEBEB)
    ),
    this.mentionUserBgDecoration = const BoxDecoration(
      color: Colors.white,
      border: Border(left: BorderSide(color: Color(0xffC1C1C1)),right: BorderSide(color: Color(0xffC1C1C1)),top: BorderSide(color: Color(0xffC1C1C1)),),
      borderRadius: BorderRadius.only(topLeft: Radius.circular(8),
      topRight: Radius.circular(8)),),
  });
  final EditTextFieldStyle textFieldStyle;
  final Decoration decoration;
  final Color dividerColor;
  final Color sentIconColor;
  final IconStyle audioRecordIcon;
  final Color rippleColor;
  final Color attachmentIconColor;
  final Color emojiIconColor;
  final ReplyHeaderMessageViewStyle replyHeaderMessageViewStyle;
  final Color replyBgColor;
  final AudioRecordingViewStyle audioRecordingViewStyle;
  final Color bgColor;
  final UIKitIcon? iconEmoji;
  final UIKitIcon? iconKeyBoard;
  final UIKitIcon? iconAttachment;
  final UIKitIcon? iconRecord;
  final UIKitIcon? iconSend;
  final ContactItemStyle mentionUserStyle;
  final Decoration mentionUserBgDecoration;
  final TextStyle mentionTextStyle;


}

class AudioRecordingViewStyle{
  const AudioRecordingViewStyle({
    this.durationTextStyle = const TextStyle(fontWeight: FontWeight.normal,color: AppColor.primaryColor,fontSize: 12),
    this.cancelTextStyle = const TextStyle(fontWeight: FontWeight.w300,color: Color(0xff363636),fontSize: 12)
  });
  final TextStyle durationTextStyle;
  final TextStyle cancelTextStyle;
}

class NotificationMessageViewStyle{
  const NotificationMessageViewStyle({this.decoration = const BoxDecoration(
      color: Color(0xffDADADA),
      borderRadius: BorderRadius.all(Radius.circular(15))),
    this.textStyle = const TextStyle(fontWeight: FontWeight.w500, color: Color(0xff565656),fontSize: 13),});
  final Decoration decoration;
  final TextStyle textStyle;
}

class ReplyHeaderMessageViewStyle{
  const ReplyHeaderMessageViewStyle({
    this.decoration = const BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      color: Color(0xffD0D8EB),),
    this.titleTextStyle = const TextStyle(fontWeight: FontWeight.w600,color: Colors.black,fontSize: 11),
    this.contentTextStyle = const TextStyle(fontWeight: FontWeight.normal,color: Colors.black,fontSize: 13),
    this.mediaIconStyle = const IconStyle(bgColor:Color(0xff7285B5),iconColor: Colors.white),
    this.borderRadius = const BorderRadius.only(topRight: Radius.circular(5), bottomRight: Radius.circular(5)),
    this.searchHighLightColor = Colors.orange,
    this.linkColor = const Color(0xff4879F9),
    this.mentionUserColor = const Color(0xff4879F9),
    this.mentionedMeBgColor = const Color(0XffD2E3FC),
  });
  final Decoration decoration;
  final TextStyle titleTextStyle;
  final TextStyle contentTextStyle;
  final IconStyle mediaIconStyle;
  final BorderRadius borderRadius;
  final Color searchHighLightColor;
  final Color linkColor;
  final Color mentionUserColor;
  final Color mentionedMeBgColor;
}

class LocationMessageViewStyle{
  const LocationMessageViewStyle({
    this.timeTextStyle = const TextStyle(fontWeight: FontWeight.normal, color: Colors.white,fontSize: 11),
    this.locationBorderRadius = const BorderRadius.all(Radius.circular(10)),
    this.iconFavourites,
  });
  final TextStyle timeTextStyle;
  final BorderRadiusGeometry locationBorderRadius;
  final UIKitIcon? iconFavourites;
}

class ContactMessageViewStyle{
  const ContactMessageViewStyle({
    this.textMessageViewStyle = const TextMessageViewStyle(textStyle: TextStyle(fontWeight: FontWeight.normal, color: Colors.black,fontSize: 14),timeTextStyle: TextStyle(fontWeight: FontWeight.normal, color: Color(0xff455E93),fontSize: 11)),
    this.viewTextStyle = const TextStyle(fontWeight: FontWeight.normal, color: Colors.black,fontSize: 12),
    this.profileImageSize = const Size(30, 30),
    this.dividerColor = const Color(0xffD2D8E8),
    this.iconFavourites,
  });
  final TextMessageViewStyle textMessageViewStyle;
  final TextStyle viewTextStyle;
  final Size profileImageSize;
  final Color dividerColor;
  final UIKitIcon? iconFavourites;
}

class TextMessageViewStyle{
  const TextMessageViewStyle({this.textStyle = const TextStyle(fontWeight: FontWeight.normal, color: Colors.black,fontSize: 14),
    this.timeTextStyle = const TextStyle(fontWeight: FontWeight.normal, color: Color(0xff455E93),fontSize: 11),
    this.highlightColor = Colors.orange,//while searching a message to highlight the text
    this.urlMessageColor = const Color(0xff4879F9),
    this.mentionUserColor = const Color(0xff4879F9),
    this.mentionedMeBgColor = const Color(0XffD2E3FC),
    this.scheduleTextStyle=const TextStyle(fontSize: 13,color: Color.fromRGBO(0,0,0,1),fontWeight: FontWeight.normal),
    this.callLinkViewStyle = const CallLinkViewStyle(decoration: BoxDecoration(
      color: Color(0xffD0D8EB),
    ),textStyle: TextStyle(fontWeight: FontWeight.normal, color: Colors.black,fontSize: 12),iconColor: Color(0xff97A5C7)),
    this.iconFavourites,
  });
  final TextStyle textStyle;
  final TextStyle timeTextStyle;

  final TextStyle scheduleTextStyle;
  final Color highlightColor;
  final Color urlMessageColor;
  final Color mentionUserColor;
  final Color mentionedMeBgColor;
  final CallLinkViewStyle callLinkViewStyle;
  final UIKitIcon? iconFavourites;
}

class DownloadUploadViewStyle{
  const DownloadUploadViewStyle({
    this.decoration = const BoxDecoration(
      border: Border.fromBorderSide(BorderSide(width: 1.0)),
      borderRadius: BorderRadius.all(Radius.circular(4)),
      color: Colors.black45,
    ),
    this.textStyle = const TextStyle(fontWeight: FontWeight.w500,color: Colors.white, fontSize: 10),
    this.progressIndicatorThemeData = const ProgressIndicatorThemeData(color: Colors.white,linearTrackColor: Colors.transparent),
    this.iconStyle = const IconStyle(iconColor: Colors.white)
  });
  final Decoration decoration;
  final TextStyle textStyle;
  final ProgressIndicatorThemeData progressIndicatorThemeData;
  final IconStyle iconStyle;
}

class DocMessageViewStyle{
  const DocMessageViewStyle({
    this.decoration = const BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        color: Color(0xffD0D8EB)),
    this.fileTextStyle = const TextMessageViewStyle(textStyle:TextStyle(fontWeight: FontWeight.w300,color: Colors.black,fontSize: 12),highlightColor: Colors.orange,timeTextStyle: TextStyle(fontWeight: FontWeight.normal,color: Color(0xff455E93),fontSize: 11)),
    this.sizeTextStyle = const TextStyle(fontWeight: FontWeight.w300,color: Colors.black,fontSize: 7),
    this.downloadUploadViewStyle = const DownloadUploadViewStyle(decoration: BoxDecoration(
      border: Border.fromBorderSide(BorderSide(
          color: Color(0xffAFB8D0),
          width: 1.0
      )),
      borderRadius: BorderRadius.all(Radius.circular(3)),
    ),progressIndicatorThemeData: ProgressIndicatorThemeData(color: Color(0xff7285B5),linearTrackColor: Colors.transparent),iconStyle: IconStyle(iconColor: Color(0xff7285B5))),
    this.iconFavourites,
  });
  final Decoration decoration;
  final TextMessageViewStyle fileTextStyle;
  final TextStyle sizeTextStyle;
  final DownloadUploadViewStyle downloadUploadViewStyle;
  final UIKitIcon? iconFavourites;
}

class VideoMessageViewStyle{
  const VideoMessageViewStyle({
    this.captionTextViewStyle = const TextMessageViewStyle(),
    this.timeTextStyle = const TextStyle(fontWeight: FontWeight.normal, color: Colors.white,fontSize: 11),
    this.videoBorderRadius = const BorderRadius.all(Radius.circular(10)),
    this.downloadUploadViewStyle = const DownloadUploadViewStyle(decoration: BoxDecoration(
      border: Border.fromBorderSide(BorderSide(width: 1.0)),
      borderRadius: BorderRadius.all(Radius.circular(4)),
      color: Colors.black45,
    ),
        textStyle: TextStyle(fontWeight: FontWeight.w500,color: Colors.white, fontSize: 10),
        progressIndicatorThemeData: ProgressIndicatorThemeData(color: Colors.white,linearTrackColor: Colors.transparent),
    iconStyle: IconStyle(iconColor: Colors.white)),
    this.iconFavourites,
  });
  final TextMessageViewStyle captionTextViewStyle;
  final TextStyle timeTextStyle;
  final BorderRadiusGeometry videoBorderRadius;
  final DownloadUploadViewStyle downloadUploadViewStyle;
  final UIKitIcon? iconFavourites;
}
class ImageMessageViewStyle{
  const ImageMessageViewStyle({
    this.captionTextViewStyle = const TextMessageViewStyle(),
    this.timeTextStyle = const TextStyle(fontWeight: FontWeight.normal, color: Colors.white,fontSize: 11),
    this.imageBorderRadius = const BorderRadius.all(Radius.circular(10)),
    this.downloadUploadViewStyle = const DownloadUploadViewStyle(decoration: BoxDecoration(
      border: Border.fromBorderSide(BorderSide(width: 1.0)),
      borderRadius: BorderRadius.all(Radius.circular(4)),
      color: Colors.black45,
    ),
        textStyle: TextStyle(fontWeight: FontWeight.w500,color: Colors.white, fontSize: 10),
        progressIndicatorThemeData: ProgressIndicatorThemeData(color: Colors.white,linearTrackColor: Colors.transparent),
    iconStyle: IconStyle(iconColor: Colors.white)),
    this.iconFavourites,
  });
  final TextMessageViewStyle captionTextViewStyle;
  final TextStyle timeTextStyle;
  final BorderRadiusGeometry imageBorderRadius;
  final DownloadUploadViewStyle downloadUploadViewStyle;
  final UIKitIcon? iconFavourites;
}
class AudioMessageViewStyle{
  const AudioMessageViewStyle({
    this.decoration = const BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        color: Color(0xffD0D8EB)),
    this.durationTextStyle = const TextStyle(fontWeight: FontWeight.w300,color: Color(0xff455E93),fontSize: 8),
    this.sliderThemeData = const SliderThemeData(
      thumbColor: Color(0xff7285B5),
      trackHeight: 2,
      activeTrackColor: Colors.white,
      inactiveTrackColor: Color(0xffAFB8D0),
      // overlayShape: SliderComponentShape.noThumb,
      thumbShape: RoundSliderThumbShape(
          enabledThumbRadius: (10/2)),
    ),
    this.timeTextStyle = const TextStyle(fontWeight: FontWeight.normal, color: Color(0xff455E93),fontSize: 11),
    this.downloadUploadViewStyle = const DownloadUploadViewStyle(decoration: BoxDecoration(
      border: Border.fromBorderSide(BorderSide(
          color: Color(0xffAFB8D0),
          width: 1.0
      )),
      borderRadius: BorderRadius.all(Radius.circular(3)),
    ),progressIndicatorThemeData: ProgressIndicatorThemeData(color: Color(0xff7285B5),linearTrackColor: Colors.transparent),iconStyle: IconStyle(iconColor: Color(0xff7285B5))),
    this.iconStyle = const IconStyle(bgColor:Color(0xff97A5C7),iconColor: Colors.white),
    this.iconFavourites,
  });
  final Decoration decoration;
  final TextStyle durationTextStyle;
  final SliderThemeData sliderThemeData;
  final TextStyle timeTextStyle;
  final DownloadUploadViewStyle downloadUploadViewStyle;
  final IconStyle iconStyle;
  final UIKitIcon? iconFavourites;
}

class CallLinkViewStyle{
  const CallLinkViewStyle({
    this.decoration = const BoxDecoration(
      color: Color(0xffD0D8EB),
    ),
    this.textStyle = const TextStyle(fontWeight: FontWeight.normal, color: Colors.black,fontSize: 12),
    this.iconColor = const Color(0xff97A5C7),
    this.scheduleTileColor=const  Color.fromRGBO(122, 134, 165, 1),
    this.scheduleDateTimeColor=const Color.fromRGBO(60, 81, 139, 1),
    this.scheduleIconColor =const Color.fromRGBO(151, 165, 199, 1),
  });
  final Decoration decoration;
  final TextStyle textStyle;
  final Color iconColor;
  final Color scheduleTileColor;
  final Color scheduleDateTimeColor;
  final Color scheduleIconColor;
}

class IconStyle{
  final Color? bgColor;
  final Color iconColor;
  final Color? borderColor;
  const IconStyle({required this.iconColor,this.bgColor,this.borderColor,});

}
