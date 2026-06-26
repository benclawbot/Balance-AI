import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../domain/life_dimension.dart';

class LifeWheel extends StatelessWidget {
  const LifeWheel({
    super.key,
    required this.scores,
    required this.selectedDimension,
    required this.onDimensionSelected,
  });

  final Map<LifeDimensionType, LifeDimensionScore> scores;
  final LifeDimensionType selectedDimension;
  final ValueChanged<LifeDimensionType> onDimensionSelected;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: GestureDetector(
        onTapUp: (details) {
          final box = context.findRenderObject() as RenderBox?;
          if (box == null) return;
          final local = box.globalToLocal(details.globalPosition);
          final center = box.size.center(Offset.zero);
          final vector = local - center;
          final radians = math.atan2(vector.dy, vector.dx) + math.pi / 2;
          final normalized = radians < 0 ? radians + math.pi * 2 : radians;
          final index =
              (normalized / (math.pi * 2 / LifeDimensionType.values.length))
                      .floor() %
                  LifeDimensionType.values.length;
          onDimensionSelected(LifeDimensionType.values[index]);
        },
        child: CustomPaint(
          painter: LifeWheelPainter(
            scores: scores,
            selectedDimension: selectedDimension,
          ),
        ),
      ),
    );
  }
}

class LifeWheelPainter extends CustomPainter {
  LifeWheelPainter({required this.scores, required this.selectedDimension});

  final Map<LifeDimensionType, LifeDimensionScore> scores;
  final LifeDimensionType selectedDimension;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - 36;
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = MindfulColors.inkBlack.withValues(alpha: 0.1);
    final axisPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = MindfulColors.inkBlack.withValues(alpha: 0.12);
    final selectedColor = _colorForDimension(selectedDimension);
    final selectedPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = selectedColor;

    final step = math.pi * 2 / LifeDimensionType.values.length;
    const gap = 0.018;
    for (var index = 0; index < LifeDimensionType.values.length; index++) {
      final dimension = LifeDimensionType.values[index];
      final angle = _angleForIndex(index);
      final start = angle - step / 2 + gap;
      final sweep = step - gap * 2;
      final value = (scores[dimension]?.score ?? 5).clamp(0, 10) / 10;
      final color = _colorForDimension(dimension);
      canvas.drawPath(
        _sectorPath(center: center, radius: radius, start: start, sweep: sweep),
        Paint()
          ..style = PaintingStyle.fill
          ..color = color.withValues(
              alpha: dimension == selectedDimension ? 0.18 : 0.1),
      );
      canvas.drawPath(
        _sectorPath(
            center: center, radius: radius * value, start: start, sweep: sweep),
        Paint()
          ..style = PaintingStyle.fill
          ..color = color.withValues(
              alpha: dimension == selectedDimension ? 0.82 : 0.68),
      );
    }

    for (var ring = 1; ring <= 5; ring++) {
      canvas.drawCircle(center, radius * ring / 5, ringPaint);
    }

    for (var index = 0; index < LifeDimensionType.values.length; index++) {
      final dimension = LifeDimensionType.values[index];
      final angle = _angleForIndex(index);
      final axisEnd =
          center + Offset(math.cos(angle), math.sin(angle)) * radius;
      canvas.drawLine(center, axisEnd, axisPaint);
      _drawLabel(canvas, size, dimension.label, center, angle, radius + 22,
          dimension == selectedDimension);
    }

    final selectedIndex = LifeDimensionType.values.indexOf(selectedDimension);
    final selectedAngle = _angleForIndex(selectedIndex);
    final arcRect = Rect.fromCircle(center: center, radius: radius + 8);
    canvas.drawArc(
      arcRect,
      selectedAngle - math.pi / 8,
      math.pi / 4,
      false,
      selectedPaint,
    );

    canvas.drawCircle(
      center,
      math.max(38, radius * 0.24),
      Paint()
        ..style = PaintingStyle.fill
        ..color = MindfulColors.surface.withValues(alpha: 0.92),
    );
    canvas.drawCircle(
      center,
      math.max(38, radius * 0.24),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = selectedColor.withValues(alpha: 0.34),
    );

    final scoreText =
        (scores[selectedDimension]?.score ?? 0).toStringAsFixed(1);
    final scorePainter = TextPainter(
      text: TextSpan(
        text: scoreText,
        style: const TextStyle(
          fontFamily: 'Hanken Grotesk',
          fontSize: 42,
          fontWeight: FontWeight.w700,
          color: MindfulColors.inkBlack,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    scorePainter.paint(canvas,
        center - Offset(scorePainter.width / 2, scorePainter.height / 2 + 8));

    final totalPainter = TextPainter(
      text: const TextSpan(
        text: 'SELECTED',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
          color: MindfulColors.onSurfaceVariant,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    totalPainter.paint(canvas, center - Offset(totalPainter.width / 2, -18));
  }

  double _angleForIndex(int index) {
    final step = math.pi * 2 / LifeDimensionType.values.length;
    return -math.pi / 2 + step * index;
  }

  Path _sectorPath({
    required Offset center,
    required double radius,
    required double start,
    required double sweep,
  }) {
    return Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
          Rect.fromCircle(center: center, radius: radius), start, sweep, false)
      ..close();
  }

  Color _colorForDimension(LifeDimensionType dimension) {
    return switch (dimension) {
      LifeDimensionType.health => const Color(0xFF4ADE80),
      LifeDimensionType.career => const Color(0xFF60A5FA),
      LifeDimensionType.finance => const Color(0xFF22C55E),
      LifeDimensionType.social => const Color(0xFFF87171),
      LifeDimensionType.mind => const Color(0xFF38BDF8),
      LifeDimensionType.home => const Color(0xFFFACC15),
      LifeDimensionType.growth => const Color(0xFFFB923C),
      LifeDimensionType.leisure => const Color(0xFFF472B6),
    };
  }

  void _drawLabel(Canvas canvas, Size size, String label, Offset center,
      double angle, double radius, bool selected) {
    final position = center + Offset(math.cos(angle), math.sin(angle)) * radius;
    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: selected ? 12 : 11,
          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          color: selected
              ? MindfulColors.inkBlack
              : MindfulColors.onSurfaceVariant,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 72);
    painter.paint(
        canvas, position - Offset(painter.width / 2, painter.height / 2));
  }

  @override
  bool shouldRepaint(covariant LifeWheelPainter oldDelegate) {
    return oldDelegate.scores != scores ||
        oldDelegate.selectedDimension != selectedDimension;
  }
}
