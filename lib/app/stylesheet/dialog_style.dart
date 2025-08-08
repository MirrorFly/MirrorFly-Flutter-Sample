part of 'stylesheet.dart';

class DialogStyle {
  final Color backgroundColor;
  final TextStyle titleTextStyle;
  final TextStyle contentTextStyle;
  final ButtonStyle buttonStyle;
  final ShapeBorder shape;
  final Decoration headerContainerDecoration; // for Permission related alerts
  final Color iconColor; // for Permission related alerts

  const DialogStyle(
      {this.shape = const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4))),
      this.backgroundColor = Colors.white,
      this.titleTextStyle = const TextStyle(
          fontWeight: FontWeight.w600, color: Color(0xff181818), fontSize: 14),
      this.contentTextStyle = const TextStyle(
          fontWeight: FontWeight.normal,
          color: Color(0xff767676),
          fontSize: 14),
      this.buttonStyle = const ButtonStyle(),
      this.headerContainerDecoration = const BoxDecoration(
          color: AppColor.primaryColor,
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(4), topLeft: Radius.circular(4))),
      this.iconColor = Colors.white});
}
