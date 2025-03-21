import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/stylesheet/stylesheet.dart';

import '../../../common/constants.dart';
import '../../../data/utils.dart';

class FloatingFab extends StatefulWidget {
  const FloatingFab(
      {super.key, required this.parentWidgetHeight, required this.parentWidgetWidth, required this.onFabTap, required this.fabTheme});

  final RxDouble parentWidgetHeight;
  final RxDouble parentWidgetWidth;
  final Function() onFabTap;
  final InstantScheduleMeetStyle fabTheme;

  @override
  State<FloatingFab> createState() => _FloatingFabState();
}

class _FloatingFabState extends State<FloatingFab> {
  Rx<Offset> position = const Offset(10, 15).obs;
  Rx<Offset> startPosition = const Offset(0, 0)
      .obs; // Initial position when dragging starts
  RxBool isDragging = false.obs;
  late double screenHeight;
  RxDouble lastFabHeight=0.0.obs;

  late StreamSubscription _heightListener;


  @override
  void initState() {
    super.initState();
   _heightListener = widget.parentWidgetHeight.listen((value) {
      if (value != 0.0 &&( value < position.value.dy||((value-position.value.dy)<50))) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          lastFabHeight(position.value.dy);
          Offset newOffset = Offset(position.value.dx, widget.parentWidgetHeight/2);
          updatePosition(newOffset); // Update the position
        });
      }
      if(lastFabHeight.value != 0.0){
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Offset newOffset = Offset(position.value.dx, lastFabHeight.value);
          updatePosition(newOffset); // Update the position
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _heightListener.cancel();
  }
  @override
  Widget build(BuildContext context) {
        return Obx(() {
          return AnimatedPositioned(
            duration: isDragging.value ? Duration.zero : const Duration(milliseconds: 250),
            right: position.value.dx,
            bottom: position.value.dy,
            child: GestureDetector(
              onPanStart: (details) {
                isDragging(true);
                lastFabHeight(0.0);
                // startPosition = position;
              },
              onPanUpdate: (details) {
                if (!isDragging.value) return;
        
                position(Offset(position.value.dx - details.delta.dx,
                    position.value.dy - details.delta.dy));
              },
              onPanEnd: (details) {
                if (!isDragging.value) return;
                // setState(() {
                isDragging(false);
                // });
                updatePosition(position.value);
              },
              child: buildFab(),
            ));

      }
    );
  }

  void updatePosition(Offset newOffset) {
    double fabWidth = 56.0;
    double fabHeight = 56.0;

    debugPrint("screenWidth ${widget.parentWidgetWidth}");
    debugPrint("screenHeight ${widget.parentWidgetHeight}");

    // Calculate the new position based on drag offset
    double newX = newOffset.dx.clamp(
        0.0, widget.parentWidgetWidth.value - fabWidth);
    double newY = newOffset.dy.clamp(
        0.0, widget.parentWidgetHeight.value - fabHeight - 16);

    // Snap to the closest side (left or right)
    if (newX < widget.parentWidgetWidth.value / 2) {
      newX = 15; // Snap to the left
    } else {
      newX = widget.parentWidgetWidth.value - fabWidth - 15; // Snap to the right
    }

    // Ensure the FAB stays within vertical bounds
    newY = newY.clamp(5, widget.parentWidgetHeight.value - fabHeight - 16);

    // position = Offset(widget.controller.screenWidth.value - newX - fabWidth, widget.controller.screenHeight.value - newY - fabHeight);

    debugPrint("newX $newX");
    debugPrint("newY $newY");
    // Update the position
    position(Offset(newX, newY));
  }

  Widget buildFab() {
    return Theme(
      data: ThemeData(floatingActionButtonTheme: widget.fabTheme.meetFabStyle),
      child: FloatingActionButton(
        onPressed: widget.onFabTap,
        child: widget.fabTheme.iconMeet ?? AppUtils.svgIcon(icon:
          meetSchedule,
          width: widget.fabTheme.meetFabStyle.iconSize,
          colorFilter: ColorFilter.mode(widget.fabTheme.meetFabStyle.foregroundColor ?? Colors.white, BlendMode.srcIn),
        ),
      ),
    );
  }
}
