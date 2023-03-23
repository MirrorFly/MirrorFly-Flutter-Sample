import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieAnimation extends StatefulWidget {
  const LottieAnimation({Key? key, required this.lottieJson, required this.showRepeat, required this.width, required this.height}) : super(key: key);

  final String lottieJson;
  final bool showRepeat;
  final double width;
  final double height;

  @override
  State<LottieAnimation> createState() => _LottieAnimationState();
}

class _LottieAnimationState extends State<LottieAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Lottie.asset(
        widget.lottieJson,
        controller: controller,
        onLoaded: (composition) {
          controller
            ..duration = composition.duration
            ..forward();
          widget.showRepeat ? controller.repeat() : null;
          // debugPrint("Lottie Duration: ${composition.duration}");
        },
        height: widget.height,
        width: widget.width,
      ),
    );
  }
}
