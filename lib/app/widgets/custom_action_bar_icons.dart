import 'package:flutter/material.dart';

class CustomActionBarIcons extends StatelessWidget {
  final double availableWidth;
  final double actionWidth;
  final List<CustomAction> actions;

  CustomActionBarIcons({
    required this.availableWidth,
    required this.actionWidth,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    actions.sort(); // items with ShowAsAction.NEVER are placed at the end

    List<CustomAction> visible = actions
        .where((CustomAction customAction) => customAction.showAsAction == ShowAsAction.ALWAYS)
        .toList();

    List<CustomAction> overflow = actions
        .where((CustomAction customAction) => customAction.showAsAction == ShowAsAction.NEVER)
        .toList();

    double getOverflowWidth() => overflow.isEmpty ? 0 : actionWidth;

    for (CustomAction customAction in actions) {
      if (customAction.showAsAction == ShowAsAction.IF_ROOM) {
        if (availableWidth - visible.length * actionWidth - getOverflowWidth() > actionWidth) { // there is enough room
          visible.insert(actions.indexOf(customAction), customAction); // insert in its given position
        } else { // there is not enough room
          if (overflow.isEmpty) {
            CustomAction lastOptionalAction = visible.lastWhere((CustomAction customAction) => customAction.showAsAction == ShowAsAction.IF_ROOM);
            if (lastOptionalAction != null) {
              visible.remove(lastOptionalAction); // remove the last optionally visible action to make space for the overflow icon
              overflow.add(lastOptionalAction);
              overflow.add(customAction);
            } // else the layout will overflow because there is not enough space for all the visible items and the overflow icon
          } else {
            overflow.add(customAction);
          }
        }
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        ...visible.map((CustomAction customAction) => customAction.visibleWidget),
        if (overflow.isNotEmpty) PopupMenuButton(
          itemBuilder: (BuildContext context) => [
            for (CustomAction customAction in overflow) PopupMenuItem(
              child: customAction.overflowWidget,
            )
          ],
        )
      ],
    );
  }
}

class CustomAction implements Comparable<CustomAction> {
  final Widget visibleWidget;
  final Widget overflowWidget;
  final ShowAsAction showAsAction;

  CustomAction({
    required this.visibleWidget,
    required this.overflowWidget,
    required this.showAsAction,
  });

  @override
  int compareTo(CustomAction other) {
    if (showAsAction == ShowAsAction.NEVER && other.showAsAction == ShowAsAction.NEVER) {
      return 0;
    } else if (showAsAction == ShowAsAction.NEVER) {
      return 1;
    } else if (other.showAsAction == ShowAsAction.NEVER) {
      return -1;
    } else {
      return 0;
    }
  }
}

enum ShowAsAction {
  ALWAYS,
  IF_ROOM,
  NEVER,
}
