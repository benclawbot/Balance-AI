import 'life_dimension.dart';

class AssessmentAnswer {
  const AssessmentAnswer({
    required this.dimension,
    required this.rating,
    required this.transcript,
    required this.createdAt,
  });

  final LifeDimensionType dimension;
  final int rating;
  final String transcript;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'dimension': dimension.slug,
        'rating': rating,
        'transcript': transcript,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AssessmentAnswer.fromJson(Map<String, dynamic> json) {
    return AssessmentAnswer(
      dimension: LifeDimensionTypeX.fromSlug(json['dimension'] as String? ?? 'health'),
      rating: (json['rating'] as num? ?? 5).round(),
      transcript: json['transcript'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class Recommendation {
  const Recommendation({
    required this.dimension,
    required this.score,
    required this.title,
    required this.reason,
    required this.suggestions,
    required this.ctaLabel,
  });

  final LifeDimensionType dimension;
  final int score;
  final String title;
  final String reason;
  final List<String> suggestions;
  final String ctaLabel;

  Map<String, dynamic> toJson() => {
        'dimension': dimension.slug,
        'score': score,
        'title': title,
        'reason': reason,
        'suggestions': suggestions,
        'ctaLabel': ctaLabel,
      };

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      dimension: LifeDimensionTypeX.fromSlug(json['dimension'] as String? ?? 'health'),
      score: (json['score'] as num? ?? 50).round().clamp(0, 100),
      title: json['title'] as String? ?? 'Focus Area',
      reason: json['reason'] as String? ?? '',
      suggestions: (json['suggestions'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .where((item) => item.trim().isNotEmpty)
          .toList(),
      ctaLabel: json['ctaLabel'] as String? ?? 'Start Reset',
    );
  }
}

class ActionItem {
  const ActionItem({
    required this.id,
    required this.title,
    required this.category,
    required this.dimension,
    this.completed = false,
  });

  final String id;
  final String title;
  final String category;
  final LifeDimensionType dimension;
  final bool completed;

  ActionItem copyWith({bool? completed}) {
    return ActionItem(
      id: id,
      title: title,
      category: category,
      dimension: dimension,
      completed: completed ?? this.completed,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'dimension': dimension.slug,
        'completed': completed,
      };

  factory ActionItem.fromJson(Map<String, dynamic> json) {
    return ActionItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? '',
      dimension: LifeDimensionTypeX.fromSlug(json['dimension'] as String? ?? 'health'),
      completed: json['completed'] as bool? ?? false,
    );
  }
}

class TrendPoint {
  const TrendPoint({required this.label, required this.value});
  final String label;
  final double value;
}

class ReportInsight {
  const ReportInsight({
    required this.title,
    required this.body,
    required this.type,
  });

  final String title;
  final String body;
  final InsightType type;
}

enum InsightType { strength, growthArea }
