import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../domain/life_dimension.dart';

class DimensionChip extends StatelessWidget {
  const DimensionChip({
    super.key,
    required this.dimension,
    required this.selected,
    required this.onTap,
  });

  final LifeDimensionType dimension;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? MindfulColors.inkBlack : MindfulColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? MindfulColors.inkBlack : MindfulColors.inkBlack.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              dimension.icon,
              size: 18,
              color: selected ? Colors.white : MindfulColors.inkBlack,
            ),
            const SizedBox(width: 8),
            Text(
              dimension.label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: selected ? Colors.white : MindfulColors.inkBlack,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
