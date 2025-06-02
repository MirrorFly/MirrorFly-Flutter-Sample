import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mirror_fly_demo/app/stylesheet/stylesheet.dart';

import '../../../common/constants.dart';
import '../../../data/utils.dart';
import '../controllers/chat_controller.dart';

class FloatingFab extends StatefulWidget {
  const FloatingFab(
      {super.key, required this.onFabTap, required this.fabTheme,required this.controller});

  final Function() onFabTap;
  final InstantScheduleMeetStyle fabTheme;
  final ChatController controller;

  @override
  State<FloatingFab> createState() => _FloatingFabState();
}

class _FloatingFabState extends State<FloatingFab> {


  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final double screenHeight = widget.controller.screenHeight.value;
      final double screenWidth = widget.controller.screenWidth.value;
      final Offset position = widget.controller.fabPosition.value;

      if (screenHeight <= 0 || screenWidth <= 0) {
        return const SizedBox.shrink();
      }
      final double safeBottom = screenHeight - widget.controller.fabHeight.value;
      final double clampedY = position.dy.clamp(widget.controller.safeTop.value, safeBottom);
      final double clampedX = position.dx.clamp(widget.controller.margin.value, screenWidth - widget.controller.fabHeight.value - widget.controller.margin.value);
      return (widget.controller.screenHeight.value ==0.0)? const SizedBox():AnimatedPositioned(
        duration: widget.controller.isDraggingFab.value ? Duration.zero : const Duration(milliseconds: 250),
        right: screenWidth - widget.controller.fabHeight.value - clampedX,
        top: clampedY,
        child: GestureDetector(
          onPanStart: (details) => widget.controller.isDraggingFab(true),
          onPanUpdate: (details) {
            if (!widget.controller.isDraggingFab.value) return;
            final newX = (position.dx + details.delta.dx)
                .clamp(widget.controller.margin.value, screenWidth - widget.controller.fabHeight.value - widget.controller.margin.value);
            final newY = (position.dy + details.delta.dy)
                .clamp(widget.controller.safeTop.value, safeBottom);
            widget.controller.fabPosition(Offset(newX, newY));
          },
          onPanEnd: (details) {
            widget.controller.isDraggingFab(false);
            widget.controller.updateFabPosition(widget.controller.fabPosition.value);
          },
          child: buildFab(),
        ),
      );
    });
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
