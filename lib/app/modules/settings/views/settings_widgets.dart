
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_switch/flutter_switch.dart';

import '../../../common/constants.dart';
import '../../../common/widgets.dart';

Widget lockItem(
    {required String title, required String subtitle, required bool on, Widget? trailing, required Function(bool value) onToggle, Function()? onTap}) {
  return ListItem(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w400)),
          const SizedBox(
            height: 4,
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 13, color: textColor),
          ),
        ],
      ),
      trailing: trailing ?? FlutterSwitch(
        width: 40.0,
        height: 20.0,
        valueFontSize: 12.0,
        toggleSize: 12.0,
        activeColor: Colors.white,
        activeToggleColor: Colors.blue,
        inactiveToggleColor: Colors.grey,
        inactiveColor: Colors.white,
        switchBorder: Border.all(
            color: on ? Colors.blue : Colors.grey,
            width: 1),
        value: on,
        onToggle: (value) => onToggle(value),
      ),
      dividerPadding: EdgeInsets.zero,
      onTap: onTap);
}

ListItem notificationItem({required String title,
  required String subtitle,
  bool on = false,
  required Function() onTap}) {
  return ListItem(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w400)),
          const SizedBox(
            height: 4,
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 13, color: textColor),
          ),
        ],
      ),
      dividerPadding: const EdgeInsets.symmetric(horizontal: 16),
      trailing: SvgPicture.asset(
        on ? tickRoundBlue : tickRound,
      ),
      onTap: onTap);
}