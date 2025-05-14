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
  Rx<Offset> position = const Offset(10, 70).obs;
  Rx<Offset> startPosition = const Offset(0, 0)
      .obs; // Initial position when dragging starts
  RxBool isDragging = false.obs;
  late double screenHeight;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
      const double fabHeight = 56.0;
      final double screenHeight = widget.parentWidgetHeight.value;
      final double screenWidth = widget.parentWidgetWidth.value;

      double displayBottom = position.value.dy;
      if(widget.parentWidgetHeight.value !=0.0){
        final double screenMid = screenHeight / 2;

        final double fabScreenBottom = screenHeight - displayBottom - fabHeight;

        // Move up only if FAB is in lower half and keyboard covers it
        if (keyboardHeight > 0 &&
            position.value.dy > screenMid &&
            fabScreenBottom < keyboardHeight + 20) {
          displayBottom = screenHeight - keyboardHeight - 20 - fabHeight;
        }

        // Fix the clamp crash by ensuring maxClamp is >= 0
        double maxClamp = screenHeight - fabHeight;
        maxClamp = maxClamp < 0 ? 0.0 : maxClamp;
        debugPrint("maxClamp : $maxClamp");
        if(maxClamp>=11) {
          displayBottom = displayBottom.clamp(0.0, maxClamp - 10);
        }
      }
      return (widget.parentWidgetHeight.value ==0.0)? const SizedBox():AnimatedPositioned(
        duration: isDragging.value ? Duration.zero : const Duration(milliseconds: 250),
        right: position.value.dx.clamp(0.0, screenWidth - fabHeight),
        bottom: displayBottom,
        child: GestureDetector(
          onPanStart: (details) => isDragging(true),
          onPanUpdate: (details) {
            if (!isDragging.value) return;
            double newX = position.value.dx - details.delta.dx;
            double newY = position.value.dy - details.delta.dy;

            newX = newX.clamp(0.0, screenWidth - fabHeight);
            newY = newY.clamp(0.0, screenHeight - fabHeight);

            position(Offset(newX, newY));
          },
          onPanEnd: (details) {
            isDragging(false);
            updatePosition(position.value);
          },
          child: buildFab(),
        ),
      );
    });
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
