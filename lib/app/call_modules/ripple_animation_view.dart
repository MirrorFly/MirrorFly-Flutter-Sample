import 'dart:math' as math;

import 'package:flutter/material.dart';


class RipplesAnimation extends StatefulWidget {
  const RipplesAnimation({Key? key, this.size = 50.0, this.color = Colors.red,
    required this.onPressed, required this.child,}) : super(key: key);
  final double size;
  final Color color;
  final Widget child;
  final VoidCallback onPressed;
  @override
  RipplesAnimationState createState() => RipplesAnimationState();
}

class RipplesAnimationState extends State<RipplesAnimation> with TickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  Widget _button() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.size),
        child: ScaleTransition(
            scale: Tween(begin: 0.95, end: 1.0).animate(
              CurvedAnimation(
                parent: _controller,
                curve: CurveWave(),
              ),
            ),
            child: widget.child//Icon(Icons.speaker_phone, size: 44,)
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: CustomPaint(
          painter: CirclePainter(
            _controller,
            color: widget.color,
          ),
          child: SizedBox(
            width: widget.size * 4.125,
            height: widget.size * 4.125,
            child: _button(),
          ),
        ),
      );
  }
}

class CurveWave extends Curve {
  @override
  double transform(double t) {
    if (t == 0 || t == 1) {
      return 0.01;
    }
    return math.sin(t * math.pi);
  }
}
class CirclePainter extends CustomPainter {
  CirclePainter(
      this._animation, {
        required this.color,
      }) : super(repaint: _animation);
  final Color color;
  final Animation<double> _animation;
  void circle(Canvas canvas, Rect rect, double value) {
    var strokeColor = Colors.white;
    var dashWidth = 2.0;
    final double opacity = (1.0 - (value / 4.0)).clamp(0.0, 1.0);
    final Color color = strokeColor.withOpacity(opacity);
    final double size = rect.width / 2;
    final double area = size * size;
    final double radius = math.sqrt(area * value / 4);
    final Paint paint = Paint();//..color = _color;
    paint.color = color;
    paint.strokeWidth = 1.0;
    paint.style = PaintingStyle.stroke;
    final dashPath = Path();
    final dashCount = (rect.width/2).round();//(2 * math.pi * radius / (dashWidth + dashSpace)).ceil();
    final center = Offset(rect.width / 2, rect.height / 2);
    for (int i = 0; i < dashCount; i++) {
      final angle = 2 * math.pi * i / dashCount;
      final startX = center.dx + math.cos(angle) * radius;
      final startY = center.dy + math.sin(angle) * radius;
      final endX = center.dx + math.cos(angle + math.pi / 180 * dashWidth) * radius;
      final endY = center.dy + math.sin(angle + math.pi / 180 * dashWidth) * radius;

      dashPath.moveTo(startX, startY);
      dashPath.lineTo(endX, endY);
    }

    canvas.drawPath(dashPath, paint);
  }
  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTRB(0.0, 0.0, size.width,size.height);
    for (int wave = 2; wave >= 0; wave--) {
      circle(canvas, rect, wave + _animation.value);
    }
  }
  @override
  bool shouldRepaint(CirclePainter oldDelegate) => true;
}

class RippleWidget extends StatefulWidget {
  const RippleWidget({super.key,required this.size, required this.rippleColor, this.child,});
  final double size;
  final Color rippleColor;
  final Widget? child;

  @override
  RippleWidgetState createState() => RippleWidgetState();
}

class RippleWidgetState extends State<RippleWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      animationBehavior: AnimationBehavior.preserve,
      vsync: this,
    )..repeat(); // Repeat the animation indefinitely
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: RipplePainter(_controller.value,widget.rippleColor),
                  child: SizedBox(
                    width: widget.size,
                    height: widget.size,
                  ),
                );
              },
            ),
          ),
          Center(child: widget.child,)
        ],
      ),
    );
  }
}

class RipplePainter extends CustomPainter {
  final double progress;
  final Color rippleColor;
  final int rippleCount = 2;

  RipplePainter(this.progress, this.rippleColor);

  @override
  void paint(Canvas canvas, Size size) {
    // final radius = (progress * size.width/2);
    final paint = Paint()
      ..color = rippleColor.withOpacity(1.0 - progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width/2;

    final center = Offset(size.width/2, size.height/2);

    for (int i = 0; i < rippleCount; i++) {
      final rippleProgress = (progress + i / rippleCount) % 1.0;
      final radius = rippleProgress * size.width / 2;
      canvas.drawCircle(center, radius, paint..color = rippleColor.withOpacity(1.0 - rippleProgress));
    }
    // canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}