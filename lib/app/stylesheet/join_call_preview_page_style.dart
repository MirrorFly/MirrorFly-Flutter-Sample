part of 'stylesheet.dart';

class JoinCallPreviewPageStyle{
  final Decoration backgroundDecoration;
  final TextStyle callerNameTextStyle;
  final Size profileImageSize;
  final ActionButtonStyle actionButtonsStyle;
  final ButtonStyle joinCallButtonStyle;

  const JoinCallPreviewPageStyle({
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
    this.callerNameTextStyle = const TextStyle(fontWeight: FontWeight.w500,color: Colors.white,fontSize: 15),
    this.profileImageSize = const Size(105, 105),
    this.actionButtonsStyle = const ActionButtonStyle(),
    this.joinCallButtonStyle = const ButtonStyle()
  });
}