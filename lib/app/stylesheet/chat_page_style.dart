part of 'stylesheet.dart';

class ChatPageStyle {
  const ChatPageStyle(
      {this.appBarTheme = const AppBarTheme(backgroundColor: Colors.white,shadowColor: Colors.white,surfaceTintColor: Colors.white,
          titleTextStyle: TextStyle(fontWeight: FontWeight.bold,color: Color(0xff181818),fontSize: 20),
  elevation: 0,actionsIconTheme: IconThemeData(color: Color(0xff181818))),
        this.chatUserAppBarStyle = const ChatUserAppBarStyle(),
        this.searchTextFieldStyle = const EditTextFieldStyle(),
        this.messageTypingAreaStyle = const MessageTypingAreaStyle(),
        this.notificationMessageViewStyle = const NotificationMessageViewStyle(),
        this.chatSelectionBgColor = Colors.black12,
        this.senderChatBubbleStyle = const SenderChatBubbleStyle(),
        this.receiverChatBubbleStyle = const ReceiverChatBubbleStyle(),
        this.attachmentViewStyle = const AttachmentViewStyle(),
        this.popupMenuThemeData = const PopupMenuThemeData(
            color: Colors.white,
            surfaceTintColor: Colors.white,
            shadowColor: Colors.white,
            textStyle: TextStyle(fontWeight: FontWeight.w600,color: Color(0xff181818),fontSize: 15),
            shape: RoundedRectangleBorder(side: BorderSide(color: Color(0xffE8E8E8),width: 1)),
            iconColor: Color(0xff181818)
        ),
        this.instantScheduleMeetStyle = const InstantScheduleMeetStyle()
      });
  final AppBarTheme appBarTheme;
  final ChatUserAppBarStyle chatUserAppBarStyle;
  final EditTextFieldStyle searchTextFieldStyle;
  final MessageTypingAreaStyle messageTypingAreaStyle;
  final NotificationMessageViewStyle notificationMessageViewStyle;
  final Color chatSelectionBgColor;
  final SenderChatBubbleStyle senderChatBubbleStyle;
  final ReceiverChatBubbleStyle receiverChatBubbleStyle;
  final AttachmentViewStyle attachmentViewStyle;
  final PopupMenuThemeData popupMenuThemeData;
  final InstantScheduleMeetStyle instantScheduleMeetStyle;
}

class InstantScheduleMeetStyle{
  const InstantScheduleMeetStyle({
    this.meetFabStyle = const FloatingActionButtonThemeData(backgroundColor: AppColor.primaryColor,foregroundColor: Colors.white,elevation: 12,iconSize: 24,shape: CircleBorder()),
    this.meetBottomSheetStyle = const MeetBottomSheetStyle()
  });
  final FloatingActionButtonThemeData meetFabStyle;
  final MeetBottomSheetStyle meetBottomSheetStyle;
}

class AttachmentViewStyle{
  final Color bgColor;
  final ShapeBorder shapeBorder;
  final IconStyle documentStyle;
  final IconStyle cameraStyle;
  final IconStyle galleryStyle;
  final IconStyle audioStyle;
  final IconStyle contactStyle;
  final IconStyle locationStyle;
  final TextStyle textStyle;
  const AttachmentViewStyle({
    this.bgColor = const Color(0xff242A3F),
    this.shapeBorder = const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
    this.documentStyle = const IconStyle(iconColor: Colors.white,bgColor: Color(0xff34B197)),//Document
    this.cameraStyle = const IconStyle(iconColor: Colors.white,bgColor: Color(0xffEF5B5A)),//Camera
    this.galleryStyle = const IconStyle(iconColor: Colors.white,bgColor: Color(0xff3093DF)),//Gallery
    this.audioStyle = const IconStyle(iconColor: Colors.white,bgColor: Color(0xffF37627)),//Audio
    this.contactStyle = const IconStyle(iconColor: Colors.white,bgColor: Color(0xff46BF69)),//Contact
    this.locationStyle = const IconStyle(iconColor: Colors.white,bgColor: Color(0xffB66AE6)),//Location
    this.textStyle = const TextStyle(fontWeight: FontWeight.normal,color: Colors.white,fontSize: 9)
  });
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

class SenderChatBubbleStyle{
   const SenderChatBubbleStyle({
     this.textMessageViewStyle = const TextMessageViewStyle(textStyle: TextStyle(fontWeight: FontWeight.normal, color: Colors.black,fontSize: 14),timeTextStyle: TextStyle(fontWeight: FontWeight.normal, color: Color(0xff455E93),fontSize: 11),callLinkViewStyle: CallLinkViewStyle(decoration: BoxDecoration(
       color: Color(0xffD0D8EB),
     ),textStyle: TextStyle(fontWeight: FontWeight.normal, color: Colors.black,fontSize: 12),iconColor: Color(0xff97A5C7))),
     this.imageMessageViewStyle = const ImageMessageViewStyle(
         captionTextViewStyle: TextMessageViewStyle(textStyle: TextStyle(fontWeight: FontWeight.normal, color: Colors.black,fontSize: 14),timeTextStyle: TextStyle(fontWeight: FontWeight.normal, color: Color(0xff455E93),fontSize: 11),callLinkViewStyle: CallLinkViewStyle(decoration: BoxDecoration(
           color: Color(0xffD0D8EB),
         ),textStyle: TextStyle(fontWeight: FontWeight.normal, color: Colors.black,fontSize: 12),iconColor: Color(0xff97A5C7))),
         timeTextStyle: TextStyle(fontWeight: FontWeight.normal, color: Colors.white,fontSize: 11 ),
       imageBorderRadius: BorderRadius.all(Radius.circular(10)),
       downloadUploadViewStyle: DownloadUploadViewStyle(decoration: BoxDecoration(
         border: Border.fromBorderSide(BorderSide(width: 1.0)),
         borderRadius: BorderRadius.all(Radius.circular(4)),
         color: Colors.black45,
       ),textStyle: TextStyle(fontWeight: FontWeight.w500,color: Colors.white, fontSize: 10),
       progressIndicatorThemeData: ProgressIndicatorThemeData(color: Colors.white,linearTrackColor: Colors.transparent),
       iconStyle: IconStyle(iconColor: Colors.white))
     ),
     this.videoMessageViewStyle = const VideoMessageViewStyle(
         captionTextViewStyle: TextMessageViewStyle(textStyle: TextStyle(fontWeight: FontWeight.normal, color: Colors.black,fontSize: 14),timeTextStyle: TextStyle(fontWeight: FontWeight.normal, color: Color(0xff455E93),fontSize: 11),callLinkViewStyle: CallLinkViewStyle(decoration: BoxDecoration(
           color: Color(0xffD0D8EB),
         ),textStyle: TextStyle(fontWeight: FontWeight.normal, color: Colors.black,fontSize: 12),iconColor: Color(0xff97A5C7))),
         timeTextStyle: TextStyle(fontWeight: FontWeight.normal, color: Colors.white,fontSize: 11 ),
         videoBorderRadius: BorderRadius.all(Radius.circular(10)),
         downloadUploadViewStyle: DownloadUploadViewStyle(decoration: BoxDecoration(
           border: Border.fromBorderSide(BorderSide(width: 1.0)),
           borderRadius: BorderRadius.all(Radius.circular(4)),
           color: Colors.black45,
         ),textStyle: TextStyle(fontWeight: FontWeight.w500,color: Colors.white, fontSize: 10),
             progressIndicatorThemeData: ProgressIndicatorThemeData(color: Colors.white,linearTrackColor: Colors.transparent),
         iconStyle: IconStyle(iconColor: Colors.white))
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
             enabledThumbRadius: (10/2)),
       ),
       timeTextStyle: TextStyle(fontWeight: FontWeight.normal, color: Color(0xff455E93),fontSize: 11),
       downloadUploadViewStyle: DownloadUploadViewStyle(decoration: BoxDecoration(
         border: Border.fromBorderSide(BorderSide(
             color: Color(0xffAFB8D0),
             width: 1.0
         )),
         borderRadius: BorderRadius.all(Radius.circular(3)),
       ),progressIndicatorThemeData: ProgressIndicatorThemeData(color: Color(0xff7285B5),linearTrackColor: Colors.transparent),iconStyle: IconStyle(iconColor: Color(0xff7285B5))),
       iconStyle: IconStyle(bgColor:Color(0xff97A5C7),iconColor: Colors.white)
     ),
     this.docMessageViewStyle = const DocMessageViewStyle(
         decoration: BoxDecoration(
             borderRadius: BorderRadius.only(
                 topLeft: Radius.circular(10), topRight: Radius.circular(10)),
             color: Color(0xffD0D8EB)),
         fileTextStyle: TextMessageViewStyle(textStyle:TextStyle(fontWeight: FontWeight.w300,color: Colors.black,fontSize: 12),highlightColor: Colors.orange,timeTextStyle: TextStyle(fontWeight: FontWeight.normal,color: Color(0xff455E93),fontSize: 11),),
         sizeTextStyle: TextStyle(fontWeight: FontWeight.w300,color: Colors.black,fontSize: 7),
         downloadUploadViewStyle: DownloadUploadViewStyle(decoration: BoxDecoration(
           border: Border.fromBorderSide(BorderSide(
               color: Color(0xffAFB8D0),
               width: 1.0
           )),
           borderRadius: BorderRadius.all(Radius.circular(3)),
         ),progressIndicatorThemeData: ProgressIndicatorThemeData(color: Color(0xff7285B5),linearTrackColor: Colors.transparent),iconStyle: IconStyle(iconColor: Color(0xff7285B5)))
     ),
     this.contactMessageViewStyle = const ContactMessageViewStyle(
   textMessageViewStyle: TextMessageViewStyle(textStyle: TextStyle(fontWeight: FontWeight.normal, color: Colors.black,fontSize: 14),timeTextStyle: TextStyle(fontWeight: FontWeight.normal, color: Color(0xff455E93),fontSize: 11)),
       viewTextStyle: TextStyle(fontWeight: FontWeight.normal, color: Colors.black,fontSize: 12),
       profileImageSize: Size(30, 30),
       dividerColor: Color(0xffD2D8E8)
   ),
     this.locationMessageViewStyle = const LocationMessageViewStyle(timeTextStyle: TextStyle(fontWeight: FontWeight.normal, color: Colors.white,fontSize: 11),locationBorderRadius: BorderRadius.all(Radius.circular(10))),
     this.replyHeaderMessageViewStyle = const ReplyHeaderMessageViewStyle(
       decoration: BoxDecoration(
         borderRadius: BorderRadius.all(Radius.circular(10)),
         color: Color(0xffD0D8EB),),
       titleTextStyle: TextStyle(fontWeight: FontWeight.w600,color: Colors.black,fontSize: 11),
       contentTextStyle: TextStyle(fontWeight: FontWeight.normal,color: Colors.black,fontSize: 13),
         mediaIconStyle: IconStyle(bgColor:Color(0xff7285B5),iconColor: Colors.white),
         borderRadius: BorderRadius.only(topRight: Radius.circular(5), bottomRight: Radius.circular(5))
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
 final LocationMessageViewStyle locationMessageViewStyle;
 final ReplyHeaderMessageViewStyle replyHeaderMessageViewStyle;
 final Decoration decoration;
}

class ReceiverChatBubbleStyle{
  const ReceiverChatBubbleStyle({
    this.participantNameTextStyle = const TextStyle(fontWeight: FontWeight.w600,fontSize: 12),
   this.textMessageViewStyle = const TextMessageViewStyle(textStyle: TextStyle(fontWeight: FontWeight.normal, color: Color(0xff313131),fontSize: 14),timeTextStyle: TextStyle(fontWeight: FontWeight.normal, color: Color(0xff959595),fontSize: 11),callLinkViewStyle: CallLinkViewStyle(decoration: BoxDecoration(
     color: Color(0xffEFEFEF),
   ),textStyle: TextStyle(fontWeight: FontWeight.normal, color: Colors.black,fontSize: 12),iconColor: Colors.grey)),
    this.imageMessageViewStyle = const ImageMessageViewStyle(
        captionTextViewStyle: TextMessageViewStyle(textStyle: TextStyle(fontWeight: FontWeight.normal, color: Colors.black,fontSize: 14),timeTextStyle: TextStyle(fontWeight: FontWeight.normal, color: Color(0xff455E93),fontSize: 11),callLinkViewStyle: CallLinkViewStyle(decoration: BoxDecoration(
          color: Color(0xffEFEFEF),
        ),textStyle: TextStyle(fontWeight: FontWeight.normal, color: Colors.black,fontSize: 12),iconColor: Colors.grey)),
        timeTextStyle: TextStyle(fontWeight: FontWeight.normal, color: Colors.white,fontSize: 11 ),
        imageBorderRadius: BorderRadius.all(Radius.circular(10)),
        downloadUploadViewStyle: DownloadUploadViewStyle(decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          color: Colors.black45,
        ),textStyle: TextStyle(fontWeight: FontWeight.w500,color: Colors.white, fontSize: 10),
            progressIndicatorThemeData: ProgressIndicatorThemeData(color: Colors.white,linearTrackColor: Colors.transparent),iconStyle: IconStyle(iconColor: Colors.white))
    ),
    this.videoMessageViewStyle = const VideoMessageViewStyle(
        captionTextViewStyle: TextMessageViewStyle(textStyle: TextStyle(fontWeight: FontWeight.normal, color: Colors.black,fontSize: 14),timeTextStyle: TextStyle(fontWeight: FontWeight.normal, color: Color(0xff455E93),fontSize: 11),callLinkViewStyle: CallLinkViewStyle(decoration: BoxDecoration(
          color: Color(0xffEFEFEF),
        ),textStyle: TextStyle(fontWeight: FontWeight.normal, color: Colors.black,fontSize: 12),iconColor: Colors.grey)),
        timeTextStyle: TextStyle(fontWeight: FontWeight.normal, color: Colors.white,fontSize: 11 ),
        videoBorderRadius: BorderRadius.all(Radius.circular(10)),
        downloadUploadViewStyle: DownloadUploadViewStyle(decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          color: Colors.black45,
        ),textStyle: TextStyle(fontWeight: FontWeight.w500,color: Colors.white, fontSize: 10),
            progressIndicatorThemeData: ProgressIndicatorThemeData(color: Colors.white,linearTrackColor: Colors.transparent),iconStyle: IconStyle(iconColor: Colors.white))
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
            enabledThumbRadius: (10/2)),
      ),
      timeTextStyle: TextStyle(fontWeight: FontWeight.normal, color: Color(0xff9E9E9E),fontSize: 11),
      downloadUploadViewStyle: DownloadUploadViewStyle(decoration: BoxDecoration(
        border: Border.fromBorderSide(BorderSide(
            color: Color(0xffAFB8D0),
            width: 1.0
        )),
        borderRadius: BorderRadius.all(Radius.circular(3)),
      ),progressIndicatorThemeData: ProgressIndicatorThemeData(color: Color(0xff7285B5),linearTrackColor: Colors.transparent),iconStyle: IconStyle(iconColor: Color(0xff7285B5))),
        iconStyle: IconStyle(bgColor:Color(0xff97A5C7),iconColor: Colors.white)
    ),
    this.docMessageViewStyle = const DocMessageViewStyle(decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10), topRight: Radius.circular(10)),
        color: Color(0xffEFEFEF)),
        fileTextStyle: TextMessageViewStyle(textStyle:TextStyle(fontWeight: FontWeight.w300,color: Color(0xff313131),fontSize: 12),highlightColor: Colors.orange,timeTextStyle: TextStyle(fontWeight: FontWeight.normal,color: Color(0xff9E9E9E),fontSize: 11),),
        sizeTextStyle: TextStyle(fontWeight: FontWeight.w300,color: Color(0xff313131),fontSize: 7),
        downloadUploadViewStyle: DownloadUploadViewStyle(decoration: BoxDecoration(
          border: Border.fromBorderSide(BorderSide(
              color: Color(0xffAFB8D0),
              width: 1.0
          )),
          borderRadius: BorderRadius.all(Radius.circular(3)),
        ),progressIndicatorThemeData: ProgressIndicatorThemeData(color: Color(0xff7285B5),linearTrackColor: Colors.transparent),iconStyle: IconStyle(iconColor: Color(0xff7285B5)))
    ),
    this.contactMessageViewStyle = const ContactMessageViewStyle(
        textMessageViewStyle: TextMessageViewStyle(textStyle: TextStyle(fontWeight: FontWeight.normal, color: Color(0xff313131),fontSize: 14),timeTextStyle: TextStyle(fontWeight: FontWeight.normal, color: Color(0xff9E9E9E),fontSize: 11)),
        viewTextStyle: TextStyle(fontWeight: FontWeight.normal, color: Color(0xff313131),fontSize: 12),
      profileImageSize: Size(30, 30),
      dividerColor: Color(0xffE3E7F1)
    ),
    this.locationMessageViewStyle = const LocationMessageViewStyle(timeTextStyle: TextStyle(fontWeight: FontWeight.normal, color: Colors.white,fontSize: 11),locationBorderRadius: BorderRadius.all(Radius.circular(10))),
    this.replyHeaderMessageViewStyle = const ReplyHeaderMessageViewStyle(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: Color(0xffEFEFEF),),
      titleTextStyle: TextStyle(fontWeight: FontWeight.w600,color: Color(0xff313131),fontSize: 11),
      contentTextStyle: TextStyle(fontWeight: FontWeight.normal,color: Color(0xff313131),fontSize: 13),
        mediaIconStyle: IconStyle(bgColor:Color(0xff7285B5),iconColor: Colors.white),
        borderRadius: BorderRadius.only(topRight: Radius.circular(5), bottomRight: Radius.circular(5))
    ),
   this.decoration = const BoxDecoration(
       borderRadius: BorderRadius.only(
           topLeft: Radius.circular(10), topRight: Radius.circular(10), bottomRight: Radius.circular(10)),
       color: Colors.white,
       border: Border.fromBorderSide(BorderSide(color: Color(0xffE3E7F0)))),
 });
  final TextStyle participantNameTextStyle; // for Group participant name
 final TextMessageViewStyle textMessageViewStyle;
 final ImageMessageViewStyle imageMessageViewStyle;
 final VideoMessageViewStyle videoMessageViewStyle;
 final AudioMessageViewStyle audioMessageViewStyle;
 final DocMessageViewStyle docMessageViewStyle;
 final ContactMessageViewStyle contactMessageViewStyle;
 final LocationMessageViewStyle locationMessageViewStyle;
 final ReplyHeaderMessageViewStyle replyHeaderMessageViewStyle;
 final Decoration decoration;
}


