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
        this.typingTextStyle = const TextStyle(fontWeight: FontWeight.w600, color: Color(0xff3276E2),fontSize: 14),
        this.timeTextStyle = const TextStyle(fontWeight: FontWeight.normal, color: Color(0xff767676),fontSize: 12),
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