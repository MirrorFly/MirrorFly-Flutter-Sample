import 'package:flutter/material.dart';
import 'dart:async';

import 'package:mirrorfly_plugin/mirrorfly.dart';

class AudioLevelAnimation extends StatefulWidget {
  final Color bgColor;
  final double radius;
  final int audioLevel;
  final Color dotsColor;

  const AudioLevelAnimation({
    Key? key,
    required this.bgColor,
    this.radius = 14,
    required this.audioLevel, this.dotsColor = Colors.white,
  }) : super(key: key);

  @override
  AudioLevelAnimationState createState() => AudioLevelAnimationState();
}

class AudioLevelAnimationState extends State<AudioLevelAnimation> {
  bool _isVisible = true;
  int _lastAudioLevel = -1;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _startHideTimer();
  }

  @override
  void didUpdateWidget(covariant AudioLevelAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.audioLevel != _lastAudioLevel) {
      _lastAudioLevel = widget.audioLevel;
      _isVisible = true;
      _startHideTimer();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(milliseconds: 1500), () {
      setState(() {
        _isVisible = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isVisible
        ? CircleAvatar(
            backgroundColor: widget.bgColor,
            radius: widget.radius,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: showAudioLevel(widget.audioLevel),
            ),
          )
        : const SizedBox.shrink();
  }

  List<Widget> showAudioLevel(int audioLevel) {
    switch (audioLevel.getAudioLevel()) {
      case AudioLevel.audioTooLow:
        return createAudioLevelContainers([0.3, 0.3, 0.3]);
      case AudioLevel.audioLow:
        return createAudioLevelContainers([0.3, 0.7, 0.3]);
      case AudioLevel.audioMedium:
        return createAudioLevelContainers([0.5, 0.9, 0.5]);
      case AudioLevel.audioHigh:
        return createAudioLevelContainers([0.7, 0.9, 0.7]);
      case AudioLevel.audioPeak:
        return createAudioLevelContainers([0.9, 0.9, 0.9]);
      default:
        return createAudioLevelContainers([0.3, 0.3, 0.3]);
    }
  }

  List<Widget> createAudioLevelContainers(List<double> heights) {
    return List.generate(heights.length, (index) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: widget.radius * 0.30,
          height: widget.radius * heights[index],
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(widget.radius * 0.4),
          ),
        ),
      );
    });
  }
}
