import 'life_dimension.dart';
import 'models.dart';

class BalanceScoringEngine {
  const BalanceScoringEngine();

  Map<LifeDimensionType, LifeDimensionScore> applyAnswer({
    required Map<LifeDimensionType, LifeDimensionScore> current,
    required AssessmentAnswer answer,
  }) {
    final existing = current[answer.dimension] ??
        LifeDimensionScore(type: answer.dimension, score: answer.rating.toDouble());
    final adjustedScore = _adjustScoreFromTranscript(answer.rating, answer.transcript);
    return {
      ...current,
      answer.dimension: existing.copyWith(
        score: adjustedScore,
        note: answer.transcript.trim().isEmpty ? existing.note : answer.transcript.trim(),
      ),
    };
  }

  double overallScore(Map<LifeDimensionType, LifeDimensionScore> dimensions) {
    if (dimensions.isEmpty) return 0;
    final total = dimensions.values.fold<double>(0, (sum, item) => sum + item.score);
    return double.parse((total / dimensions.length).toStringAsFixed(1));
  }

  int overallPercent(Map<LifeDimensionType, LifeDimensionScore> dimensions) {
    return (overallScore(dimensions) * 10).round().clamp(0, 100);
  }

  List<LifeDimensionScore> priorityDimensions(
    Map<LifeDimensionType, LifeDimensionScore> dimensions, {
    int limit = 3,
  }) {
    final values = dimensions.values.toList()
      ..sort((a, b) {
        final gapCompare = ((b.baseline - b.score) - (a.baseline - a.score)).sign.toInt();
        if (gapCompare != 0) return gapCompare;
        return a.score.compareTo(b.score);
      });
    return values.take(limit).toList(growable: false);
  }

  double completionRatio(List<ActionItem> actions) {
    if (actions.isEmpty) return 0;
    final completed = actions.where((item) => item.completed).length;
    return completed / actions.length;
  }

  double _adjustScoreFromTranscript(int rating, String transcript) {
    var score = rating.toDouble().clamp(1, 10);
    final text = transcript.toLowerCase();
    const negativeSignals = [
      'tired',
      'stress',
      'stressed',
      'anxious',
      'low',
      'overwhelmed',
      'bad',
      'sleep',
      'debt',
      'lonely',
      'isolated',
    ];
    const positiveSignals = [
      'good',
      'clear',
      'strong',
      'stable',
      'happy',
      'energized',
      'connected',
      'progress',
      'balanced',
    ];
    for (final signal in negativeSignals) {
      if (text.contains(signal)) score -= 0.15;
    }
    for (final signal in positiveSignals) {
      if (text.contains(signal)) score += 0.1;
    }
    return double.parse(score.clamp(1, 10).toStringAsFixed(1));
  }
}
