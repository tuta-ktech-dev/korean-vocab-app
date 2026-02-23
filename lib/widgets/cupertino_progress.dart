import 'package:flutter/cupertino.dart';

class CupertinoProgressBar extends StatelessWidget {
  final double value;
  final Color? color;
  final Color? backgroundColor;
  final double height;
  final BorderRadius? borderRadius;

  const CupertinoProgressBar({
    super.key,
    required this.value,
    this.color,
    this.backgroundColor,
    this.height = 8,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? CupertinoColors.activeBlue;
    final effectiveBgColor = backgroundColor ?? CupertinoColors.systemGrey5;
    final effectiveBorderRadius =
        borderRadius ?? BorderRadius.circular(height / 2);

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: effectiveBgColor,
        borderRadius: effectiveBorderRadius,
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: effectiveColor,
            borderRadius: effectiveBorderRadius,
          ),
        ),
      ),
    );
  }
}

class CupertinoCircularProgress extends StatelessWidget {
  final double value;
  final double strokeWidth;
  final Color? color;
  final Color? backgroundColor;

  const CupertinoCircularProgress({
    super.key,
    required this.value,
    this.strokeWidth = 10.0,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? CupertinoColors.activeGreen;
    final effectiveBgColor = backgroundColor ?? CupertinoColors.systemGrey4;

    return CustomPaint(
      painter: _CupertinoCircularProgressPainter(
        value: value,
        strokeWidth: strokeWidth,
        color: effectiveColor,
        backgroundColor: effectiveBgColor,
      ),
    );
  }
}

class _CupertinoCircularProgressPainter extends CustomPainter {
  final double value;
  final double strokeWidth;
  final Color color;
  final Color backgroundColor;

  _CupertinoCircularProgressPainter({
    required this.value,
    required this.strokeWidth,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);
    const startAngle = -3.14159 / 2; // -90 degrees
    final sweepAngle = 2 * 3.14159 * value;

    canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _CupertinoCircularProgressPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
