import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../domain/life_dimension.dart';
import '../../domain/models.dart';

class TrendLineChart extends StatelessWidget {
  const TrendLineChart({super.key, required this.points});

  final List<TrendPoint> points;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: CustomPaint(
        painter: TrendLinePainter(points),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 150),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: points
                  .map(
                    (point) => Text(
                      point.label.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class TrendLinePainter extends CustomPainter {
  TrendLinePainter(this.points);

  final List<TrendPoint> points;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final gridPaint = Paint()
      ..color = MindfulColors.inkBlack.withValues(alpha: 0.08)
      ..strokeWidth = 1;
    final linePaint = Paint()
      ..color = MindfulColors.clayAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          MindfulColors.clayAccent.withValues(alpha: 0.18),
          MindfulColors.clayAccent.withValues(alpha: 0.02),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    for (var i = 0; i < 4; i++) {
      final y = 16 + i * (size.height - 48) / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final maxValue = math.max(10, points.map((p) => p.value).reduce(math.max));
    final minValue = math.min(0, points.map((p) => p.value).reduce(math.min));
    Offset pointAt(int index) {
      final x = index * size.width / (points.length - 1);
      final normalized = (points[index].value - minValue) / (maxValue - minValue == 0 ? 1 : maxValue - minValue);
      final y = 16 + (1 - normalized) * (size.height - 56);
      return Offset(x, y);
    }

    final path = Path()..moveTo(pointAt(0).dx, pointAt(0).dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(pointAt(i).dx, pointAt(i).dy);
    }
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height - 28)
      ..lineTo(0, size.height - 28)
      ..close();
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
    for (var i = 0; i < points.length; i++) {
      canvas.drawCircle(pointAt(i), 4, Paint()..color = MindfulColors.inkBlack);
    }
  }

  @override
  bool shouldRepaint(covariant TrendLinePainter oldDelegate) => oldDelegate.points != points;
}

class DimensionBars extends StatelessWidget {
  const DimensionBars({super.key, required this.scores});

  final Map<LifeDimensionType, LifeDimensionScore> scores;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: LifeDimensionType.values.map((dimension) {
        final score = scores[dimension]?.score ?? 0;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              SizedBox(
                width: 72,
                child: Text(dimension.label, style: Theme.of(context).textTheme.labelSmall),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: (score / 10).clamp(0, 1),
                    minHeight: 9,
                    backgroundColor: MindfulColors.surfaceContainerHigh,
                    valueColor: const AlwaysStoppedAnimation(MindfulColors.clayAccent),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(score.toStringAsFixed(1), style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        );
      }).toList(),
    );
  }
}
