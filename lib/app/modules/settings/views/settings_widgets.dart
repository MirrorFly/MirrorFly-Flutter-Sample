
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import '../../../stylesheet/stylesheet.dart';

import '../../../common/constants.dart';
import '../../../common/widgets.dart';
import '../../../data/utils.dart';

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
      trailing: AppUtils.svgIcon(icon:
        on ? tickRoundBlue : tickRound,
      ),
      onTap: onTap);
}

class SettingListItem extends StatelessWidget {
  const SettingListItem({super.key, required this.title, this.leading, this.trailing, required this.onTap, required this.listItemStyle});
  final String title;
  final String? leading;
  final String? trailing;
  final Function() onTap;
  final ListItemStyle listItemStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Row(
            children: [
              leading != null ? Padding(
                padding: const EdgeInsets.all(18.0),
                child: SizedBox(
                    width: 24,
                    child: AppUtils.svgIcon(icon:leading!,colorFilter: ColorFilter.mode(listItemStyle.leadingIconColor, BlendMode.srcIn))),
              ) :  const SizedBox(height: 4,),
              Expanded(
                  child: Text(
                    title,
                    style: listItemStyle.titleTextStyle,
                  )),
              trailing != null ? Padding(
                padding: const EdgeInsets.all(18.0),
                child: AppUtils.svgIcon(icon:trailing!,colorFilter: ColorFilter.mode(listItemStyle.trailingIconColor, BlendMode.srcIn)),
              ) : const Offstage(),
            ],
          ),
        ),
        AppDivider(color: listItemStyle.dividerColor,),
      ],
    );
  }
}


Widget chatListItem(
    Widget title, String trailing, Function() onTap) {
  return Column(
    children: [
      InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: title,
                )),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: AppUtils.svgIcon(icon:trailing),
            ),
          ],
        ),
      ),
      const AppDivider(),
    ],
  );
}

