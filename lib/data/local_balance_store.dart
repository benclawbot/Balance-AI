import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/life_dimension.dart';
import '../domain/models.dart';
import '../state/balance_state.dart';

class LocalBalanceStore {
  static const _key = 'balance_ai_state_v1';

  Future<void> save(BalanceState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_toJson(state)));
  }

  Future<BalanceState?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final dimensions = <LifeDimensionType, LifeDimensionScore>{};
      for (final item in (json['dimensions'] as List<dynamic>? ?? const [])) {
        if (item is Map<String, dynamic>) {
          final score = LifeDimensionScore.fromJson(item);
          dimensions[score.type] = score;
        }
      }
      final mergedDimensions = {
        ...defaultDimensionScores(),
        ...dimensions,
      };
      return BalanceState.initial().copyWith(
        dimensions: mergedDimensions,
        answers: (json['answers'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(AssessmentAnswer.fromJson)
            .toList(),
        recommendations: (json['recommendations'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(Recommendation.fromJson)
            .toList(),
        actions: (json['actions'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(ActionItem.fromJson)
            .toList(),
        selectedDimension: LifeDimensionTypeX.fromSlug(
            json['selectedDimension'] as String? ?? 'health'),
        adviceGeneratedAt:
            DateTime.tryParse(json['adviceGeneratedAt'] as String? ?? ''),
        adviceAnswerCount: (json['adviceAnswerCount'] as num? ?? 0).round(),
      );
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _toJson(BalanceState state) => {
        'dimensions':
            state.dimensions.values.map((item) => item.toJson()).toList(),
        'answers': state.answers.map((item) => item.toJson()).toList(),
        'recommendations':
            state.recommendations.map((item) => item.toJson()).toList(),
        'actions': state.actions.map((item) => item.toJson()).toList(),
        'selectedDimension': state.selectedDimension.slug,
        'adviceGeneratedAt': state.adviceGeneratedAt?.toIso8601String(),
        'adviceAnswerCount': state.adviceAnswerCount,
      };
}
