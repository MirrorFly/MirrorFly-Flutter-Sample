part of 'stylesheet.dart';

class ChatPageStyle {
  const ChatPageStyle(
      {this.appBarTheme = const AppBarTheme(backgroundColor: Color(0xffF2F2F2)),
        this.chatUserAppBarStyle = const ChatUserAppBarStyle(),
        this.searchTextFieldStyle = const EditTextFieldStyle()});
  final AppBarTheme appBarTheme;
  final ChatUserAppBarStyle chatUserAppBarStyle;
  final EditTextFieldStyle searchTextFieldStyle;
}

class ChatUserAppBarStyle{
  const ChatUserAppBarStyle({
    this.profileImageSize = const Size(36, 36),
    this.titleTextStyle = const TextStyle(fontWeight: FontWeight.w600, color: Color(0xff181818),fontSize: 16),
    this.subtitleTextStyle = const TextStyle(fontWeight: FontWeight.w300, color: Color(0xff959595),fontSize: 10),
  });
  final Size profileImageSize;
  final TextStyle titleTextStyle;
  final TextStyle subtitleTextStyle;
}

class TextTypingAreaStyle{
  TextTypingAreaStyle({
    this.textFieldStyle = const EditTextFieldStyle(editTextStyle: TextStyle(fontWeight: FontWeight.w600, color: Color(0xff181818),fontSize: 16),editTextHintStyle: TextStyle(fontWeight: FontWeight.w300, color: Color(0xff959595),fontSize: 12)),
    Decoration? decoration,
    this.dividerColor = const Color(0xff000000)}) : decoration = decoration ?? _defaultDecoration;
  final EditTextFieldStyle textFieldStyle;
  final Decoration decoration;
  final Color dividerColor;

  static final Decoration _defaultDecoration = BoxDecoration(
    border: Border.all(color: const Color(0xffC1C1C1),),
    borderRadius: const BorderRadius.all(Radius.circular(40)),
    color: Colors.white,
  );

}

class NotificationMessageViewStyle{
  NotificationMessageViewStyle({this.decoration = const BoxDecoration(
      color: Color(0xff00001F),
      borderRadius: BorderRadius.all(Radius.circular(15))),
    this.textStyle = const TextStyle(fontWeight: FontWeight.w500, color: Color(0xff565656),fontSize: 13),});
  final Decoration decoration;
  final TextStyle textStyle;
}

class ContactMessageViewStyle{
  const ContactMessageViewStyle({
    this.textMessageViewStyle = const TextMessageViewStyle(textStyle: TextStyle(fontWeight: FontWeight.normal, color: Colors.black,fontSize: 14),timeTextStyle: TextStyle(fontWeight: FontWeight.normal, color: Color(0xff455E93),fontSize: 11)),
    this.viewTextStyle = const TextStyle(fontWeight: FontWeight.normal, color: Colors.black,fontSize: 12)
});
  final TextMessageViewStyle textMessageViewStyle;
  final TextStyle viewTextStyle;
}

class TextMessageViewStyle{
  const TextMessageViewStyle({this.textStyle = const TextStyle(fontWeight: FontWeight.normal, color: Colors.black,fontSize: 14),
  this.timeTextStyle = const TextStyle(fontWeight: FontWeight.normal, color: Color(0xff455E93),fontSize: 11),
    this.highlightColor = Colors.orange,//while searching a message to highlight the text
  this.urlMessageColor = Colors.blue});
  final TextStyle textStyle;
  final TextStyle timeTextStyle;
  final Color highlightColor;
  final Color urlMessageColor;
}

class DownloadUploadViewStyle{
  const DownloadUploadViewStyle({
    this.decoration = const BoxDecoration(
      border: Border.fromBorderSide(BorderSide(width: 1.0)),
      borderRadius: BorderRadius.all(Radius.circular(4)),
      color: Colors.black45,
    ),
    this.textStyle = const TextStyle(fontWeight: FontWeight.w500,color: Colors.white, fontSize: 10),
    this.progressIndicatorThemeData = const ProgressIndicatorThemeData(color: Colors.white,linearTrackColor: Colors.transparent)
});
  final Decoration decoration;
  final TextStyle textStyle;
  final ProgressIndicatorThemeData progressIndicatorThemeData;
}

class DocMessageViewStyle{
  const DocMessageViewStyle({
    this.decoration = const BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        color: Color(0xffD0D8EB)),
    this.fileTextStyle = const TextStyle(fontWeight: FontWeight.w300,color: Colors.black,fontSize: 12),
    this.sizeTextStyle = const TextStyle(fontWeight: FontWeight.w300,color: Colors.black,fontSize: 7),
    this.timeTextStyle = const TextStyle(fontWeight: FontWeight.normal,color: Color(0xff455E93),fontSize: 11),
    this.downloadUploadViewStyle = const DownloadUploadViewStyle(decoration: BoxDecoration(
      border: Border.fromBorderSide(BorderSide(
          color: Color(0xffAFB8D0),
          width: 1.0
      )),
      borderRadius: BorderRadius.all(Radius.circular(3)),
    ),progressIndicatorThemeData: ProgressIndicatorThemeData(color: Color(0xff7285B5),linearTrackColor: Colors.transparent))
});
  final Decoration decoration;
  final TextStyle fileTextStyle;
  final TextStyle sizeTextStyle;
  final TextStyle timeTextStyle;
  final DownloadUploadViewStyle downloadUploadViewStyle;
}

class VideoMessageViewStyle{
  const VideoMessageViewStyle({
    this.captionTextViewStyle = const TextMessageViewStyle(),
    this.timeTextStyle = const TextStyle(fontWeight: FontWeight.normal, color: Colors.white,fontSize: 11),
    this.downloadUploadViewStyle = const DownloadUploadViewStyle(decoration: BoxDecoration(
      border: Border.fromBorderSide(BorderSide(width: 1.0)),
      borderRadius: BorderRadius.all(Radius.circular(4)),
      color: Colors.black45,
    ),
        textStyle: TextStyle(fontWeight: FontWeight.w500,color: Colors.white, fontSize: 10),
        progressIndicatorThemeData: ProgressIndicatorThemeData(color: Colors.white,linearTrackColor: Colors.transparent))
  });
  final TextMessageViewStyle captionTextViewStyle;
  final TextStyle timeTextStyle;
  final DownloadUploadViewStyle downloadUploadViewStyle;
}
class ImageMessageViewStyle{
  const ImageMessageViewStyle({
    this.captionTextViewStyle = const TextMessageViewStyle(),
    this.timeTextStyle = const TextStyle(fontWeight: FontWeight.normal, color: Colors.white,fontSize: 11),
    this.downloadUploadViewStyle = const DownloadUploadViewStyle(decoration: BoxDecoration(
      border: Border.fromBorderSide(BorderSide(width: 1.0)),
      borderRadius: BorderRadius.all(Radius.circular(4)),
      color: Colors.black45,
    ),
        textStyle: TextStyle(fontWeight: FontWeight.w500,color: Colors.white, fontSize: 10),
        progressIndicatorThemeData: ProgressIndicatorThemeData(color: Colors.white,linearTrackColor: Colors.transparent))
  });
  final TextMessageViewStyle captionTextViewStyle;
  final TextStyle timeTextStyle;
  final DownloadUploadViewStyle downloadUploadViewStyle;
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
          enabledThumbRadius: 4),
    ),
    this.timeTextStyle = const TextStyle(fontWeight: FontWeight.normal, color: Color(0xff455E93),fontSize: 11),
    this.downloadUploadViewStyle = const DownloadUploadViewStyle(decoration: BoxDecoration(
      border: Border.fromBorderSide(BorderSide(
        color: Color(0xffAFB8D0),
        width: 1.0
      )),
      borderRadius: BorderRadius.all(Radius.circular(3)),
    ),progressIndicatorThemeData: ProgressIndicatorThemeData(color: Color(0xff7285B5),linearTrackColor: Colors.transparent))
});
  final Decoration decoration;
  final TextStyle durationTextStyle;
  final SliderThemeData sliderThemeData;
  final TextStyle timeTextStyle;
  final DownloadUploadViewStyle downloadUploadViewStyle;
}


class SenderChatBubbleStyle{
   SenderChatBubbleStyle({
     this.textMessageViewStyle = const TextMessageViewStyle(textStyle: TextStyle(fontWeight: FontWeight.normal, color: Colors.black,fontSize: 14),timeTextStyle: TextStyle(fontWeight: FontWeight.normal, color: Color(0xff455E93),fontSize: 11)),
     this.imageMessageViewStyle = const ImageMessageViewStyle(
         captionTextViewStyle: TextMessageViewStyle(textStyle: TextStyle(fontWeight: FontWeight.normal, color: Colors.black,fontSize: 14),timeTextStyle: TextStyle(fontWeight: FontWeight.normal, color: Color(0xff455E93),fontSize: 11)),
         timeTextStyle: TextStyle(fontWeight: FontWeight.normal, color: Colors.white,fontSize: 11 ),
       downloadUploadViewStyle: DownloadUploadViewStyle(decoration: BoxDecoration(
         border: Border.fromBorderSide(BorderSide(width: 1.0)),
         borderRadius: BorderRadius.all(Radius.circular(4)),
         color: Colors.black45,
       ),textStyle: TextStyle(fontWeight: FontWeight.w500,color: Colors.white, fontSize: 10),
       progressIndicatorThemeData: ProgressIndicatorThemeData(color: Colors.white,linearTrackColor: Colors.transparent))
     ),
     this.videoMessageViewStyle = const VideoMessageViewStyle(
         captionTextViewStyle: TextMessageViewStyle(textStyle: TextStyle(fontWeight: FontWeight.normal, color: Colors.black,fontSize: 14),timeTextStyle: TextStyle(fontWeight: FontWeight.normal, color: Color(0xff455E93),fontSize: 11)),
         timeTextStyle: TextStyle(fontWeight: FontWeight.normal, color: Colors.white,fontSize: 11 ),
         downloadUploadViewStyle: DownloadUploadViewStyle(decoration: BoxDecoration(
           border: Border.fromBorderSide(BorderSide(width: 1.0)),
           borderRadius: BorderRadius.all(Radius.circular(4)),
           color: Colors.black45,
         ),textStyle: TextStyle(fontWeight: FontWeight.w500,color: Colors.white, fontSize: 10),
             progressIndicatorThemeData: ProgressIndicatorThemeData(color: Colors.white,linearTrackColor: Colors.transparent))
     ),
     this.audioMessageViewStyle = const AudioMessageViewStyle(
       decoration: BoxDecoration(
           borderRadius: BorderRadius.only(
               topLeft: Radius.circular(10), topRight: Radius.circular(10)),
           color: Color(0xffD0D8EB)),
       durationTextStyle: TextStyle(fontWeight: FontWeight.w300,color: Color(0xff455E93),fontSize: 8),
       sliderThemeData: SliderThemeData(
         thumbColor: Color(0xff7285B5),
         trackHeight: 2,
         activeTrackColor: Colors.white,
         inactiveTrackColor: Color(0xffAFB8D0),
         // overlayShape: SliderComponentShape.noThumb,
         thumbShape: RoundSliderThumbShape(
             enabledThumbRadius: 4),
       ),
       timeTextStyle: TextStyle(fontWeight: FontWeight.normal, color: Color(0xff455E93),fontSize: 11),
       downloadUploadViewStyle: DownloadUploadViewStyle(decoration: BoxDecoration(
         border: Border.fromBorderSide(BorderSide(
             color: Color(0xffAFB8D0),
             width: 1.0
         )),
         borderRadius: BorderRadius.all(Radius.circular(3)),
       ),progressIndicatorThemeData: ProgressIndicatorThemeData(color: Color(0xff7285B5),linearTrackColor: Colors.transparent))
     ),
     this.docMessageViewStyle = const DocMessageViewStyle(
         decoration: BoxDecoration(
             borderRadius: BorderRadius.only(
                 topLeft: Radius.circular(10), topRight: Radius.circular(10)),
             color: Color(0xffD0D8EB)),
         fileTextStyle: TextStyle(fontWeight: FontWeight.w300,color: Colors.black,fontSize: 12),
         sizeTextStyle: TextStyle(fontWeight: FontWeight.w300,color: Colors.black,fontSize: 7),
         timeTextStyle: TextStyle(fontWeight: FontWeight.normal,color: Color(0xff455E93),fontSize: 11),
         downloadUploadViewStyle: DownloadUploadViewStyle(decoration: BoxDecoration(
           border: Border.fromBorderSide(BorderSide(
               color: Color(0xffAFB8D0),
               width: 1.0
           )),
           borderRadius: BorderRadius.all(Radius.circular(3)),
         ),progressIndicatorThemeData: ProgressIndicatorThemeData(color: Color(0xff7285B5),linearTrackColor: Colors.transparent))
     ),
     this.contactMessageViewStyle = const ContactMessageViewStyle(
   textMessageViewStyle: TextMessageViewStyle(textStyle: TextStyle(fontWeight: FontWeight.normal, color: Colors.black,fontSize: 14),timeTextStyle: TextStyle(fontWeight: FontWeight.normal, color: Color(0xff455E93),fontSize: 11)),
       viewTextStyle: TextStyle(fontWeight: FontWeight.normal, color: Colors.black,fontSize: 12)
   ),
     this.decoration = const BoxDecoration(
         borderRadius: BorderRadius.only(
             topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10)),
         color: Color(0xffE2E8F7),
         border: Border.fromBorderSide(BorderSide(color: Color(0xffe2eafc)))),
  });
 final TextMessageViewStyle textMessageViewStyle;
 final ImageMessageViewStyle imageMessageViewStyle;
 final VideoMessageViewStyle videoMessageViewStyle;
 final AudioMessageViewStyle audioMessageViewStyle;
 final DocMessageViewStyle docMessageViewStyle;
 final ContactMessageViewStyle contactMessageViewStyle;
 final Decoration decoration;
}

class ReceiverChatBubbleStyle{
  ReceiverChatBubbleStyle({
   this.textMessageViewStyle = const TextMessageViewStyle(textStyle: TextStyle(fontWeight: FontWeight.normal, color: Color(0xff313131),fontSize: 14),timeTextStyle: TextStyle(fontWeight: FontWeight.normal, color: Color(0xff959595),fontSize: 11)),
    this.imageMessageViewStyle = const ImageMessageViewStyle(
        captionTextViewStyle: TextMessageViewStyle(textStyle: TextStyle(fontWeight: FontWeight.normal, color: Colors.black,fontSize: 14),timeTextStyle: TextStyle(fontWeight: FontWeight.normal, color: Color(0xff455E93),fontSize: 11)),
        timeTextStyle: TextStyle(fontWeight: FontWeight.normal, color: Colors.white,fontSize: 11 ),
        downloadUploadViewStyle: DownloadUploadViewStyle(decoration: BoxDecoration(
          border: Border.fromBorderSide(BorderSide(width: 1.0)),
          borderRadius: BorderRadius.all(Radius.circular(4)),
          color: Colors.black45,
        ),textStyle: TextStyle(fontWeight: FontWeight.w500,color: Colors.white, fontSize: 10),
            progressIndicatorThemeData: ProgressIndicatorThemeData(color: Colors.white,linearTrackColor: Colors.transparent))
    ),
    this.videoMessageViewStyle = const VideoMessageViewStyle(
        captionTextViewStyle: TextMessageViewStyle(textStyle: TextStyle(fontWeight: FontWeight.normal, color: Colors.black,fontSize: 14),timeTextStyle: TextStyle(fontWeight: FontWeight.normal, color: Color(0xff455E93),fontSize: 11)),
        timeTextStyle: TextStyle(fontWeight: FontWeight.normal, color: Colors.white,fontSize: 11 ),
        downloadUploadViewStyle: DownloadUploadViewStyle(decoration: BoxDecoration(
          border: Border.fromBorderSide(BorderSide(width: 1.0)),
          borderRadius: BorderRadius.all(Radius.circular(4)),
          color: Colors.black45,
        ),textStyle: TextStyle(fontWeight: FontWeight.w500,color: Colors.white, fontSize: 10),
            progressIndicatorThemeData: ProgressIndicatorThemeData(color: Colors.white,linearTrackColor: Colors.transparent))
    ),
    this.audioMessageViewStyle = const AudioMessageViewStyle(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          color: Color(0xffEFEFEF)),
      durationTextStyle: TextStyle(fontWeight: FontWeight.w300,color: Color(0xff313131),fontSize: 8),
      sliderThemeData: SliderThemeData(
        thumbColor: Color(0xff7285B5),
        trackHeight: 2,
        activeTrackColor: Color(0xff848FAD),
        inactiveTrackColor: Color(0xffB9C1D6),
        // overlayShape: SliderComponentShape.noThumb,
        thumbShape: RoundSliderThumbShape(
            enabledThumbRadius: 4),
      ),
      timeTextStyle: TextStyle(fontWeight: FontWeight.normal, color: Color(0xff9E9E9E),fontSize: 11),
      downloadUploadViewStyle: DownloadUploadViewStyle(decoration: BoxDecoration(
        border: Border.fromBorderSide(BorderSide(
            color: Color(0xffAFB8D0),
            width: 1.0
        )),
        borderRadius: BorderRadius.all(Radius.circular(3)),
      ),progressIndicatorThemeData: ProgressIndicatorThemeData(color: Color(0xff7285B5),linearTrackColor: Colors.transparent))
    ),
    this.docMessageViewStyle = const DocMessageViewStyle(decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        color: Color(0xffEFEFEF)),
        fileTextStyle: TextStyle(fontWeight: FontWeight.w300,color: Color(0xff313131),fontSize: 12),
        sizeTextStyle: TextStyle(fontWeight: FontWeight.w300,color: Color(0xff313131),fontSize: 7),
        timeTextStyle: TextStyle(fontWeight: FontWeight.normal,color: Color(0xff9E9E9E),fontSize: 11),
        downloadUploadViewStyle: DownloadUploadViewStyle(decoration: BoxDecoration(
          border: Border.fromBorderSide(BorderSide(
              color: Color(0xffAFB8D0),
              width: 1.0
          )),
          borderRadius: BorderRadius.all(Radius.circular(3)),
        ),progressIndicatorThemeData: ProgressIndicatorThemeData(color: Color(0xff7285B5),linearTrackColor: Colors.transparent))
    ),
    this.contactMessageViewStyle = const ContactMessageViewStyle(
        textMessageViewStyle: TextMessageViewStyle(textStyle: TextStyle(fontWeight: FontWeight.normal, color: Color(0xff313131),fontSize: 14),timeTextStyle: TextStyle(fontWeight: FontWeight.normal, color: Color(0xff9E9E9E),fontSize: 11)),
        viewTextStyle: TextStyle(fontWeight: FontWeight.normal, color: Color(0xff313131),fontSize: 12)
    ),
   this.decoration = const BoxDecoration(
       borderRadius: BorderRadius.only(
           topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomLeft: Radius.circular(10)),
       color: Colors.white,
       border: Border.fromBorderSide(BorderSide(color: Color(0xffDDE3E5)))),
 });
 final TextMessageViewStyle textMessageViewStyle;
 final ImageMessageViewStyle imageMessageViewStyle;
 final VideoMessageViewStyle videoMessageViewStyle;
 final AudioMessageViewStyle audioMessageViewStyle;
 final DocMessageViewStyle docMessageViewStyle;
 final ContactMessageViewStyle contactMessageViewStyle;
 final Decoration decoration;
}


