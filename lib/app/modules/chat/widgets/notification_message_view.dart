import 'package:flutter/material.dart';
import '../../../stylesheet/stylesheet.dart';

class NotificationMessageView extends StatelessWidget {
  const NotificationMessageView({Key? key, required this.chatMessage,this.notificationMessageViewStyle = const NotificationMessageViewStyle()})
      : super(key: key);
  final String? chatMessage;
  final NotificationMessageViewStyle notificationMessageViewStyle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
       decoration: notificationMessageViewStyle.decoration,
       /* decoration: const BoxDecoration(
            color: notificationTextBgColor,
            borderRadius: BorderRadius.all(Radius.circular(15))),*/
        child: Text(chatMessage ?? "",
            style: notificationMessageViewStyle.textStyle,
            /*style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: notificationTextColor)*/
        ),
      ),
    );
  }
}