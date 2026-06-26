import 'package:flutter/material.dart';

/// The canonical life dimensions used everywhere in Balance AI.
enum LifeDimensionType {
  health,
  career,
  finance,
  social,
  mind,
  home,
  growth,
  leisure,
}

extension LifeDimensionTypeX on LifeDimensionType {
  String get label => switch (this) {
        LifeDimensionType.health => 'Health',
        LifeDimensionType.career => 'Career',
        LifeDimensionType.finance => 'Finance',
        LifeDimensionType.social => 'Social',
        LifeDimensionType.mind => 'Mind',
        LifeDimensionType.home => 'Home',
        LifeDimensionType.growth => 'Growth',
        LifeDimensionType.leisure => 'Leisure',
      };

  IconData get icon => switch (this) {
        LifeDimensionType.health => Icons.favorite_rounded,
        LifeDimensionType.career => Icons.work_rounded,
        LifeDimensionType.finance => Icons.payments_rounded,
        LifeDimensionType.social => Icons.groups_rounded,
        LifeDimensionType.mind => Icons.self_improvement_rounded,
        LifeDimensionType.home => Icons.home_rounded,
        LifeDimensionType.growth => Icons.school_rounded,
        LifeDimensionType.leisure => Icons.celebration_rounded,
      };

  String get question => switch (this) {
        LifeDimensionType.health =>
          'How satisfied are you with your current health and energy levels?',
        LifeDimensionType.career =>
          'How stable, meaningful, and well-paced does your work feel right now?',
        LifeDimensionType.finance =>
          'How safe and clear do you feel about your current financial situation?',
        LifeDimensionType.social =>
          'How connected and supported do you feel by the people around you?',
        LifeDimensionType.mind =>
          'How clear, calm, and emotionally resilient do you feel today?',
        LifeDimensionType.home =>
          'How well does your home environment support the life you want?',
        LifeDimensionType.growth =>
          'How much progress are you making toward learning and personal growth?',
        LifeDimensionType.leisure =>
          'How much real recovery, joy, and play are you making room for?',
      };

  String get slug => name;

  static LifeDimensionType fromSlug(String value) {
    return LifeDimensionType.values.firstWhere(
      (dimension) => dimension.slug == value,
      orElse: () => LifeDimensionType.health,
    );
  }
}

class LifeDimensionScore {
  const LifeDimensionScore({
    required this.type,
    required this.score,
    this.baseline = 7,
    this.note = '',
  });

  final LifeDimensionType type;
  final double score;
  final double baseline;
  final String note;

  int get scorePercent => (score * 10).round().clamp(0, 100);

  bool get needsAttention => score < baseline - 0.75;

  LifeDimensionScore copyWith({
    LifeDimensionType? type,
    double? score,
    double? baseline,
    String? note,
  }) {
    return LifeDimensionScore(
      type: type ?? this.type,
      score: score ?? this.score,
      baseline: baseline ?? this.baseline,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type.slug,
        'score': score,
        'baseline': baseline,
        'note': note,
      };

  factory LifeDimensionScore.fromJson(Map<String, dynamic> json) {
    return LifeDimensionScore(
      type: LifeDimensionTypeX.fromSlug(json['type'] as String? ?? 'health'),
      score: (json['score'] as num? ?? 6).toDouble(),
      baseline: (json['baseline'] as num? ?? 7).toDouble(),
      note: json['note'] as String? ?? '',
    );
  }
}

Map<LifeDimensionType, LifeDimensionScore> defaultDimensionScores() {
  return {
    LifeDimensionType.health: const LifeDimensionScore(
      type: LifeDimensionType.health,
      score: 6.2,
      baseline: 7.2,
      note: 'Your physical and mental energy levels are workable, but consistency is the main unlock.',
    ),
    LifeDimensionType.career: const LifeDimensionScore(
      type: LifeDimensionType.career,
      score: 7.4,
      baseline: 7.0,
      note: 'Career stability is currently a strength. Protect focus time to keep momentum.',
    ),
    LifeDimensionType.finance: const LifeDimensionScore(
      type: LifeDimensionType.finance,
      score: 5.9,
      baseline: 7.0,
      note: 'Financial stress is beginning to reduce mental bandwidth. Start with visibility, not overhaul.',
    ),
    LifeDimensionType.social: const LifeDimensionScore(
      type: LifeDimensionType.social,
      score: 5.8,
      baseline: 7.0,
      note: 'Meaningful connection is below baseline. Small recurring touchpoints will matter most.',
    ),
    LifeDimensionType.mind: const LifeDimensionScore(
      type: LifeDimensionType.mind,
      score: 6.8,
      baseline: 7.4,
      note: 'Mental clarity is close to baseline, but notifications and switching are draining depth.',
    ),
    LifeDimensionType.home: const LifeDimensionScore(
      type: LifeDimensionType.home,
      score: 7.2,
      baseline: 7.0,
      note: 'Your home environment is broadly supportive. Keep friction low in evening routines.',
    ),
    LifeDimensionType.growth: const LifeDimensionScore(
      type: LifeDimensionType.growth,
      score: 8.8,
      baseline: 7.0,
      note: 'Personal growth is at a high point. Convert learning energy into sustainable habits.',
    ),
    LifeDimensionType.leisure: const LifeDimensionScore(
      type: LifeDimensionType.leisure,
      score: 6.4,
      baseline: 7.0,
      note: 'Recovery is present but inconsistent. Add deliberate fun, not just passive downtime.',
    ),
  };
}
