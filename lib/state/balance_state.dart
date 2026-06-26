import '../domain/life_dimension.dart';
import '../domain/models.dart';
import '../domain/recommendation_engine.dart';

class BalanceState {
  const BalanceState({
    required this.dimensions,
    required this.answers,
    required this.recommendations,
    required this.actions,
    required this.selectedDimension,
    required this.isGeneratingAdvice,
    required this.lastError,
    required this.adviceGeneratedAt,
    required this.adviceAnswerCount,
  });

  final Map<LifeDimensionType, LifeDimensionScore> dimensions;
  final List<AssessmentAnswer> answers;
  final List<Recommendation> recommendations;
  final List<ActionItem> actions;
  final LifeDimensionType selectedDimension;
  final bool isGeneratingAdvice;
  final String? lastError;
  final DateTime? adviceGeneratedAt;
  final int adviceAnswerCount;

  List<AssessmentAnswer> answersFor(LifeDimensionType dimension) {
    return answers
        .where((answer) => answer.dimension == dimension)
        .toList(growable: false);
  }

  AssessmentAnswer? latestAnswerFor(LifeDimensionType dimension) {
    for (final answer in answers.reversed) {
      if (answer.dimension == dimension) return answer;
    }
    return null;
  }

  int get assessedDimensionCount {
    return LifeDimensionType.values
        .where((dimension) => latestAnswerFor(dimension) != null)
        .length;
  }

  bool get hasGeneratedAdvice => adviceGeneratedAt != null;

  bool get adviceIsStale =>
      !hasGeneratedAdvice || adviceAnswerCount != answers.length;

  factory BalanceState.initial() {
    final scores = defaultDimensionScores();
    const recommendationEngine = RecommendationEngine();
    final recommendations =
        recommendationEngine.generateFallbackRecommendations(scores);
    return BalanceState(
      dimensions: scores,
      answers: const [],
      recommendations: recommendations,
      actions: recommendationEngine.generateActionPlan(recommendations),
      selectedDimension: LifeDimensionType.health,
      isGeneratingAdvice: false,
      lastError: null,
      adviceGeneratedAt: null,
      adviceAnswerCount: 0,
    );
  }

  BalanceState copyWith({
    Map<LifeDimensionType, LifeDimensionScore>? dimensions,
    List<AssessmentAnswer>? answers,
    List<Recommendation>? recommendations,
    List<ActionItem>? actions,
    LifeDimensionType? selectedDimension,
    bool? isGeneratingAdvice,
    Object? lastError = _unchanged,
    Object? adviceGeneratedAt = _unchanged,
    int? adviceAnswerCount,
  }) {
    return BalanceState(
      dimensions: dimensions ?? this.dimensions,
      answers: answers ?? this.answers,
      recommendations: recommendations ?? this.recommendations,
      actions: actions ?? this.actions,
      selectedDimension: selectedDimension ?? this.selectedDimension,
      isGeneratingAdvice: isGeneratingAdvice ?? this.isGeneratingAdvice,
      lastError: identical(lastError, _unchanged)
          ? this.lastError
          : lastError as String?,
      adviceGeneratedAt: identical(adviceGeneratedAt, _unchanged)
          ? this.adviceGeneratedAt
          : adviceGeneratedAt as DateTime?,
      adviceAnswerCount: adviceAnswerCount ?? this.adviceAnswerCount,
    );
  }
}

const _unchanged = Object();
