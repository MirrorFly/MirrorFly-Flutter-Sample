import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:mirrorfly_plugin/logmessage.dart';

import '../common/constants.dart';

class CustomActionBarIcons extends StatefulWidget {
  final double availableWidth;
  final double actionWidth;
  final List<CustomAction> actions;

  const CustomActionBarIcons({
    super.key,
    required this.availableWidth,
    required this.actionWidth,
    required this.actions
  });

  @override
  State<CustomActionBarIcons> createState() => _CustomActionBarIconsState();
}

class _CustomActionBarIconsState extends State<CustomActionBarIcons> with WidgetsBindingObserver {
  // AppLifecycleState? _appLifecycleState;
  final GlobalKey _menuKey = GlobalKey();
  BuildContext? _context;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.inactive:
        if(_context!=null) {
           Navigator.pop(_context!);
        }
        break;
      case AppLifecycleState.resumed:
        _context=null;
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        break;
    }
    /*setState(() {
      _appLifecycleState = state;
      LogMessage.d("_appLifecycleState",_appLifecycleState);
    });*/
  }

  @override
  Widget build(BuildContext context) {
    LogMessage.d("CustomActionBarIcons", "build");
    widget.actions.sort(); // items with ShowAsAction.NEVER are placed at the end

    List<CustomAction> visible = widget.actions
        .where((CustomAction customAction) =>
            customAction.showAsAction == ShowAsAction.always)
        .toList();

    List<CustomAction> overflow = widget.actions
        .where((CustomAction customAction) =>
            customAction.showAsAction == ShowAsAction.never)
        .toList();

    double getOverflowWidth() => overflow.isEmpty ? 0 : widget.actionWidth;

    for (CustomAction customAction in widget.actions) {
      if (customAction.showAsAction == ShowAsAction.ifRoom) {
        if (widget.availableWidth - visible.length * widget.actionWidth - getOverflowWidth() >
            widget.actionWidth) {
          if(customAction.visibleWidget!=null) {
            // there is enough room
            visible.insert(widget.actions.indexOf(customAction),
                customAction); // insert in its given position
          }
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
              .map((CustomAction customAction) => customAction.visibleWidget!),
          if (overflow.isNotEmpty)
            PopupMenuButton(
              key: _menuKey,
              icon: SvgPicture.asset(moreIcon, width: 3.66, height: 16.31),
              onCanceled: (){
                _context = null;
                FocusManager.instance.primaryFocus!.unfocus();
                },
                onOpened: (){
                  LogMessage.d("PopupMenuButton", "onOpened");
                },
              itemBuilder: (BuildContext context) {
                _context = context;
                for (CustomAction customAction in overflow) {
                  LogMessage.d("PopupMenuButton", customAction.keyValue);
                }
                return [
                  for (CustomAction customAction in overflow)
                    PopupMenuItem(
                      value: customAction.keyValue,
                      onTap: customAction.onItemClick,
                      child: customAction.overflowWidget,
                    )
                ];
              }
              /*=> [
                for (CustomAction customAction in overflow)
                  PopupMenuItem(
                    value: customAction.keyValue,
                    onTap: customAction.onItemClick,
                    child: customAction.overflowWidget,
                  )
              ],*/
            )
        ],
      ),
    );
  }
}

class CustomAction implements Comparable<CustomAction> {
  final Widget? visibleWidget;
  final Widget overflowWidget;
  final String keyValue;
  final ShowAsAction showAsAction;
  final VoidCallback onItemClick;
  final RxBool? recreate;

  CustomAction({
    this.visibleWidget,
    required this.overflowWidget,
    required this.showAsAction,
    required this.keyValue,
    required this.onItemClick,
    this.recreate
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
