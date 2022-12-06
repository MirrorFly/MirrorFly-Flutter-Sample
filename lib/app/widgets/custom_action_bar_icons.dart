import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';

import '../common/constants.dart';

class CustomActionBarIcons extends StatelessWidget {
  final double availableWidth;
  final double actionWidth;
  final List<CustomAction> actions;

  const CustomActionBarIcons({
    super.key,
    required this.availableWidth,
    required this.actionWidth,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    actions.sort(); // items with ShowAsAction.NEVER are placed at the end

    List<CustomAction> visible = actions
        .where((CustomAction customAction) =>
            customAction.showAsAction == ShowAsAction.always)
        .toList();

    List<CustomAction> overflow = actions
        .where((CustomAction customAction) =>
            customAction.showAsAction == ShowAsAction.never)
        .toList();

    double getOverflowWidth() => overflow.isEmpty ? 0 : actionWidth;

    for (CustomAction customAction in actions) {
      if (customAction.showAsAction == ShowAsAction.ifRoom) {
        if (availableWidth - visible.length * actionWidth - getOverflowWidth() >
            actionWidth) {
          // there is enough room
          visible.insert(actions.indexOf(customAction),
              customAction); // insert in its given position
        } else {
          // there is not enough room
          if (overflow.isEmpty) {
            CustomAction lastOptionalAction = visible.lastWhere(
                (CustomAction customAction) =>
                    customAction.showAsAction == ShowAsAction.ifRoom);
            visible.remove(
                lastOptionalAction); // remove the last optionally visible action to make space for the overflow icon
            overflow.add(lastOptionalAction);
            overflow.add(customAction);
// else the layout will overflow because there is not enough space for all the visible items and the overflow icon
          } else {
            overflow.add(customAction);
          }
        }
      }
    }

    return KeyboardDismisser(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          ...visible
              .map((CustomAction customAction) => customAction.visibleWidget),
          if (overflow.isNotEmpty)
            PopupMenuButton(
              icon: SvgPicture.asset(moreIcon, width: 3.66, height: 16.31),
              onCanceled: (){ FocusManager.instance.primaryFocus!.unfocus(); },
              itemBuilder: (BuildContext context) => [
                for (CustomAction customAction in overflow)
                  PopupMenuItem(
                    value: customAction.keyValue,
                    onTap: customAction.onItemClick,
                    child: customAction.overflowWidget,
                  )
              ],
            )
        ],
      ),
    );
  }
}

class CustomAction implements Comparable<CustomAction> {
  final Widget visibleWidget;
  final Widget overflowWidget;
  final String keyValue;
  final ShowAsAction showAsAction;
  final VoidCallback onItemClick;

  CustomAction({
    required this.visibleWidget,
    required this.overflowWidget,
    required this.showAsAction,
    required this.keyValue,
    required this.onItemClick,
  });

  @override
  int compareTo(CustomAction other) {
    if (showAsAction == ShowAsAction.never &&
        other.showAsAction == ShowAsAction.never) {
      return 0;
    } else if (showAsAction == ShowAsAction.never) {
      return 1;
    } else if (other.showAsAction == ShowAsAction.never) {
      return -1;
    } else {
      return 0;
    }
  }
}

enum ShowAsAction {
  always,
  ifRoom,
  never,
  gone,
}
