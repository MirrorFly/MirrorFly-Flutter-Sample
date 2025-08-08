part of 'stylesheet.dart';

class JoinCallPreviewPageStyle {
  final AppBarTheme appBarTheme;
  final CallLinkErrorViewStyle callLinkErrorViewStyle;
  final Decoration backgroundDecoration;
  final TextStyle callerNameTextStyle;
  final Size profileImageSize;
  final ActionButtonStyle actionButtonsStyle;
  final ButtonStyle joinCallButtonStyle;

  const JoinCallPreviewPageStyle(
      {this.appBarTheme = const AppBarTheme(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        actionsIconTheme: IconThemeData(color: Colors.white),
      ),
      this.callLinkErrorViewStyle = const CallLinkErrorViewStyle(
          callEndedTextStyle: TextStyle(
              fontWeight: FontWeight.w500, color: Colors.white, fontSize: 15),
          callEndedMessageTextStyle: TextStyle(
              fontWeight: FontWeight.w500, color: Colors.white, fontSize: 13)),
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
      this.callerNameTextStyle = const TextStyle(
          fontWeight: FontWeight.w500, color: Colors.white, fontSize: 15),
      this.profileImageSize = const Size(105, 105),
      this.actionButtonsStyle = const ActionButtonStyle(),
      this.joinCallButtonStyle = const ButtonStyle()});
}

class CallLinkErrorViewStyle {
  final Widget? logoWidget;
  final Widget? callIcon;
  final TextStyle callEndedTextStyle;
  final TextStyle callEndedMessageTextStyle;
  final ButtonStyle? returnToChatButtonStyle;

  const CallLinkErrorViewStyle(
      {this.logoWidget,
      this.callIcon,
      this.callEndedTextStyle = const TextStyle(
          fontWeight: FontWeight.w500, color: Colors.white, fontSize: 15),
      this.callEndedMessageTextStyle = const TextStyle(
          fontWeight: FontWeight.w500, color: Colors.white, fontSize: 13),
      this.returnToChatButtonStyle});
}
