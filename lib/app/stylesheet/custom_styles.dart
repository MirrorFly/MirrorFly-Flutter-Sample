part of 'stylesheet.dart';

class EditTextFieldStyle{
  const EditTextFieldStyle({this.editTextStyle = const TextStyle(fontWeight: FontWeight.normal,color: Color(0xff181818),fontSize: 14),this.editTextHintStyle = const TextStyle(fontWeight: FontWeight.normal,color: Color(0xff959595),fontSize: 12),this.titleStyle});
  final TextStyle? titleStyle;
  final TextStyle editTextStyle;
  final TextStyle editTextHintStyle;
}

class OTPTextFieldStyle{
  OTPTextFieldStyle(
      {this.textStyle = const TextStyle(fontWeight: FontWeight.w600,color: Color(0xff181818),fontSize: 16),
      this.textFieldAlignment = MainAxisAlignment.center,
      this.spaceBetween = 4,
      this.fieldWidth = 40,
      this.fieldStyle = FieldStyle.box,
      this.outlineBorderRadius = 10,
        OtpFieldStyle? otpFieldStyle}) : otpFieldStyle = otpFieldStyle ?? _defaultOtpFieldStyle;

  final TextStyle textStyle;
  /// Text Field Alignment
  /// default: MainAxisAlignment.spaceBetween [MainAxisAlignment]
  final MainAxisAlignment textFieldAlignment;
  /// space between the text fields
  final double spaceBetween;
  /// Width of the single OTP Field
  final double fieldWidth;
  /// Text Field Style for field shape.
  /// default FieldStyle.underline [FieldStyle]
  final FieldStyle fieldStyle;
  /// The style to use for the text being edited.
  final double outlineBorderRadius;
  /// Text Field Style
  final OtpFieldStyle otpFieldStyle;

  static final OtpFieldStyle _defaultOtpFieldStyle = OtpFieldStyle();
}

class TabItemStyle {
  const TabItemStyle(
      {this.textStyle =
      const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        this.countIndicatorStyle = const CountIndicatorStyle(
            textStyle: TextStyle(
                fontWeight: FontWeight.normal,
                color: Colors.white,
                fontSize: 11))});
  final TextStyle textStyle;
  final CountIndicatorStyle countIndicatorStyle;
}

class CountIndicatorStyle {
  const CountIndicatorStyle(
      {this.textStyle = const TextStyle(
          fontWeight: FontWeight.normal, color: Colors.white, fontSize: 11),
        this.bgColor = const Color(0xff4879F9),
        this.radius = 9});
  final TextStyle textStyle;
  final Color bgColor;

  /// Changes to the [radius] are animated (including changing from an explicit
  /// [radius] to a [minRadius]/[maxRadius] pair or vice versa).
  final double? radius;
}

class ArchivedTileStyle {
  const ArchivedTileStyle(
      {this.textStyle = const TextStyle(
          fontWeight: FontWeight.w600, color: Color(0xff181818), fontSize: 14),
        this.countTextStyle = const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xff4879F9),
            fontSize: 12)});
  final TextStyle textStyle;
  final TextStyle countTextStyle;
}

class RecentChatItemStyle {
  const RecentChatItemStyle(
      {this.profileImageSize = const Size(48, 48),
        this.titleTextStyle = const TextStyle(fontWeight: FontWeight.w600, color: Color(0xff181818),fontSize: 16),
        this.subtitleTextStyle = const TextStyle(fontWeight: FontWeight.normal, color: Color(0xff767676),fontSize: 14),
        this.spanTextColor = Colors.blue,
        this.typingTextStyle = const TextStyle(fontWeight: FontWeight.w600, color: AppColor.primaryColor,fontSize: 14),
        this.timeTextStyle = const TextStyle(fontWeight: FontWeight.normal, color: Color(0xff767676),fontSize: 12),
        this.unreadCountBgColor = const Color(0xff4879F9),
        this.unreadCountTextStyle = const TextStyle(fontWeight: FontWeight.normal,color: Colors.white,fontSize: 8,),
        this.dividerColor = const Color(0XffE2E2E2),
        this.unreadColor = const Color(0xff4879F9),
        this.selectedBgColor = Colors.black12,
        this.unselectedBgColor = Colors.transparent});
  final Size profileImageSize;
  final TextStyle titleTextStyle;
  final TextStyle subtitleTextStyle;
  final Color spanTextColor;
  final TextStyle typingTextStyle;
  final TextStyle timeTextStyle;
  final Color unreadCountBgColor;
  final TextStyle unreadCountTextStyle;
  final Color dividerColor;
  final Color unreadColor;
  final Color selectedBgColor;
  final Color unselectedBgColor;
}

class CallHistoryItemStyle{

  final Size profileImageSize;
  final TextStyle titleTextStyle;
  final TextStyle subtitleTextStyle;
  final TextStyle durationTextStyle;
  final Color iconColor;
  final Color selectedBgColor;
  final Color unselectedBgColor;
  final Color dividerColor;

  const CallHistoryItemStyle({
    this.profileImageSize = const Size(48, 48),
    this.titleTextStyle = const TextStyle(fontWeight: FontWeight.w600, color: Color(0xff181818),fontSize: 14),
    this.subtitleTextStyle = const TextStyle(fontWeight: FontWeight.normal, color: Color(0xff767676),fontSize: 12),
    this.durationTextStyle = const TextStyle(fontWeight: FontWeight.w300, color: Color(0xff767676),fontSize: 12),
    this.iconColor = Colors.grey,
    this.selectedBgColor = Colors.black12,
    this.unselectedBgColor = Colors.transparent,
    this.dividerColor = const Color(0XffE2E2E2),
  });
}

class CreateMeetLinkStyle{
  const CreateMeetLinkStyle({
  this.textStyle = const TextStyle(fontWeight: FontWeight.w600, color: Color(0xff181818),fontSize: 14),
  this.subTitleTextStyle = const TextStyle(fontWeight: FontWeight.normal, color: Color(0xff767676),fontSize: 12),
  this.iconDecoration = const BoxDecoration(color: Color(0xffe3e9f9), shape: BoxShape.circle),
    this.iconColor = const Color(0xff3276e2),
});
  final TextStyle textStyle;
  final TextStyle subTitleTextStyle;
  final Decoration iconDecoration;
  final Color iconColor;

}
class MeetBottomSheetStyle{
  const MeetBottomSheetStyle({
  this.titleStyle = const TextStyle(fontWeight: FontWeight.w600, color: Color(0xff181818), fontSize: 14),
  this.subTitleTextStyle = const TextStyle(fontWeight: FontWeight.normal, color: Color(0xff767676),fontSize: 12),
  this.meetLinkDecoration = const BoxDecoration(color: Color(0xffF2F2F2),borderRadius: BorderRadius.all(Radius.circular(6),)),
    this.copyIconColor = const Color(0xff575757),
    this.meetLinkTextStyle = const TextStyle(fontWeight: FontWeight.normal, color: Color(0xff6580CB), fontSize: 12),
    this.scheduleMeetToggleStyle = const ScheduleMeetToggleStyle(),
    this.joinMeetingButtonStyle = const ButtonStyle(),

});
  final TextStyle titleStyle;
  final TextStyle meetLinkTextStyle;
  final TextStyle subTitleTextStyle;
  final Decoration meetLinkDecoration;
  final Color copyIconColor;
  final ScheduleMeetToggleStyle scheduleMeetToggleStyle;
  final ButtonStyle? joinMeetingButtonStyle;
}

class ScheduleMeetToggleStyle{
  const ScheduleMeetToggleStyle({
    this.textStyle = const TextStyle(fontWeight: FontWeight.w600, color: Color(0xff181818), fontSize: 14),
    this.toggleStyle = const ToggleStyle(
      activeColor: Colors.white,
      inactiveColor: Colors.white,
      activeToggleColor: Colors.blue,
      inactiveToggleColor: Colors.grey,)
});
  final TextStyle textStyle;
  final ToggleStyle toggleStyle;
}

class ToggleStyle{
  const ToggleStyle({this.activeColor = Colors.white,
    this.inactiveColor = Colors.white,
    this.activeToggleColor = Colors.blue,
    this.inactiveToggleColor = Colors.grey,});

  /// The color to use on the toggle of the switch when the given value is true.
  ///
  /// If [inactiveToggleColor] is used and this property is null. the value of
  /// [Colors.white] will be used.
  final Color activeToggleColor;

  /// The color to use on the toggle of the switch when the given value is false.
  ///
  /// If [activeToggleColor] is used and this property is null. the value of
  /// [Colors.white] will be used.
  final Color inactiveToggleColor;
  /// The color to use on the switch when the switch is on.
  ///
  /// Defaults to [Colors.blue].
  final Color activeColor;

  /// The color to use on the switch when the switch is off.
  ///
  /// Defaults to [Colors.grey].
  final Color inactiveColor;

}

class CopyMeetLinkStyle{
  const CopyMeetLinkStyle({
    this.titleTextStyle = const TextStyle(fontWeight: FontWeight.w600, color: Color(0xff181818),fontSize: 14),
    this.linkTextStyle = const TextStyle(fontWeight: FontWeight.w600, color: Color(0xff767676),fontSize: 14),
    this.leadingStyle = const CustomIconStyle(iconDecoration: BoxDecoration(color: Color(0xffe3e9f9), shape: BoxShape.circle), iconColor: Color(0xff3276e2),),
    this.copyIconColor = const Color(0xff575757),
  });
  final TextStyle titleTextStyle;
  final TextStyle linkTextStyle;
  final CustomIconStyle leadingStyle;
  final Color copyIconColor;

}

class CustomIconStyle{
  const CustomIconStyle({
    this.iconDecoration = const BoxDecoration(color: Color(0xffe3e9f9), shape: BoxShape.circle),
    this.iconColor = const Color(0xff3276e2),
  });
  final Decoration iconDecoration;
  final Color iconColor;
}