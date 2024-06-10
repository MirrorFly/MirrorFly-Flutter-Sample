part of 'stylesheet.dart';

class OutgoingCallPageStyle{
  final Decoration backgroundDecoration;
  final TextStyle callStatusTextStyle;
  final TextStyle callerNameTextStyle;
  final Size profileImageSize;
  final Color profileRippleColor;
  final ActionButtonStyle actionButtonsStyle;
  final ButtonStyle disconnectButtonStyle;

  const OutgoingCallPageStyle({
    this.backgroundDecoration = const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        transform: GradientRotation(180),
        colors: [
          Color(0xff152134),
          Color(0xff0D2852),
          Color(0xff152134),
        ],
      ),
    ),
    this.callStatusTextStyle = const TextStyle(fontWeight: FontWeight.w300,color: Color(0xffDEDEDE),fontSize: 14),
    this.callerNameTextStyle = const TextStyle(fontWeight: FontWeight.w500,color: Colors.white,fontSize: 18),
    this.profileImageSize = const Size(105, 105),
    this.profileRippleColor = Colors.red,
    this.actionButtonsStyle = const ActionButtonStyle(),
    this.disconnectButtonStyle = const ButtonStyle()
  });
}

class ActionButtonStyle{
  final Color inactiveBgColor;
  final Color activeBgColor;
  final Color inactiveIconColor;
  final Color activeIconColor;
  final ShapeBorder shape;

  const ActionButtonStyle({
    this.inactiveBgColor = const Color(0xff3D3D43),
    this.activeBgColor = Colors.white,
    this.inactiveIconColor = Colors.white,
    this.activeIconColor = Colors.black,
    this.shape = const CircleBorder()});
}