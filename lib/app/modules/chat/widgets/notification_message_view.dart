import 'package:flutter/material.dart';

import '../../../common/constants.dart';

class NotificationMessageView extends StatelessWidget {
  const NotificationMessageView({Key? key, required this.chatMessage})
      : super(key: key);
  final String? chatMessage;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 20),
        decoration: const BoxDecoration(
            color: notificationTextBgColor,
            borderRadius: BorderRadius.all(Radius.circular(15))),
        child: Text(chatMessage ?? "",
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: notificationTextColor)),
      ),
    );
  }
}