import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local_balance_store.dart';
import '../data/minimax_client.dart';
import '../domain/life_dimension.dart';
import '../domain/models.dart';
import '../domain/recommendation_engine.dart';
import '../domain/scoring.dart';
import 'balance_state.dart';

final balanceControllerProvider =
    NotifierProvider<BalanceController, BalanceState>(BalanceController.new);

final localBalanceStoreProvider =
    Provider<LocalBalanceStore>((ref) => LocalBalanceStore());
final minimaxProxyClientProvider =
    Provider<MiniMaxProxyClient>((ref) => MiniMaxProxyClient());

class BalanceController extends Notifier<BalanceState> {
  final _scoringEngine = const BalanceScoringEngine();
  final _recommendationEngine = const RecommendationEngine();

  @override
  BalanceState build() {
    _loadPersistedState();
    return BalanceState.initial();
  }

  Future<void> _loadPersistedState() async {
    final store = ref.read(localBalanceStoreProvider);
    final loaded = await store.load();
    if (loaded != null) {
      state = loaded;
    }
  }

  Future<void> _persist() async {
    await ref.read(localBalanceStoreProvider).save(state);
  }

  void selectDimension(LifeDimensionType dimension) {
    state = state.copyWith(selectedDimension: dimension, lastError: null);
    unawaitedPersist();
  }

  Future<void> saveAssessmentAnswer({
    required LifeDimensionType dimension,
    required int rating,
    required String transcript,
  }) async {
    final answer = AssessmentAnswer(
      dimension: dimension,
      rating: rating,
      transcript: transcript,
      createdAt: DateTime.now(),
    );
    final newScores = _scoringEngine.applyAnswer(
      current: state.dimensions,
      answer: answer,
    );
    final fallbackRecommendations =
        _recommendationEngine.generateFallbackRecommendations(newScores);
    final nextRecommendations = state.hasGeneratedAdvice
        ? state.recommendations
        : fallbackRecommendations;
    final nextActions = state.hasGeneratedAdvice
        ? state.actions
        : _recommendationEngine.generateActionPlan(fallbackRecommendations);
    state = state.copyWith(
      dimensions: newScores,
      answers: [...state.answers, answer],
      recommendations: nextRecommendations,
      actions: nextActions,
      selectedDimension: _nextDimensionAfter(dimension),
      lastError: null,
    );
    await _persist();
  }

  Future<bool> generateAiAdvice() async {
    state = state.copyWith(isGeneratingAdvice: true, lastError: null);
    try {
      final client = ref.read(minimaxProxyClientProvider);
      final recommendations = await client.generateRecommendations(
        scores: state.dimensions,
        answers: state.answers,
      );
      final safeRecommendations = recommendations.isEmpty
          ? _recommendationEngine
              .generateFallbackRecommendations(state.dimensions)
          : recommendations.take(3).toList(growable: false);
      state = state.copyWith(
        recommendations: safeRecommendations,
        actions: _recommendationEngine.generateActionPlan(safeRecommendations),
        isGeneratingAdvice: false,
        lastError: null,
        adviceGeneratedAt: DateTime.now(),
        adviceAnswerCount: state.answers.length,
      );
      await _persist();
      return true;
    } catch (error) {
      final recommendations = _recommendationEngine
          .generateFallbackRecommendations(state.dimensions);
      state = state.copyWith(
        recommendations: recommendations,
        actions: _recommendationEngine.generateActionPlan(recommendations),
        isGeneratingAdvice: false,
        lastError:
            'AI advice unavailable. Showing safe local recommendations instead.',
        adviceGeneratedAt: null,
        adviceAnswerCount: 0,
      );
    }
    await _persist();
    return false;
  }

  void toggleAction(String id) {
    state = state.copyWith(
      actions: state.actions.map((item) {
        if (item.id == id) return item.copyWith(completed: !item.completed);
        return item;
      }).toList(growable: false),
      lastError: null,
    );
    unawaitedPersist();
  }

  Future<void> updateScore(LifeDimensionType dimension, double score) async {
    final existing = state.dimensions[dimension] ??
        LifeDimensionScore(type: dimension, score: score);
    final dimensions = {
      ...state.dimensions,
      dimension: existing.copyWith(score: score),
    };
    state = state.copyWith(
        dimensions: dimensions, selectedDimension: dimension, lastError: null);
    await _persist();
  }

  void unawaitedPersist() {
    _persist();
  }

  LifeDimensionType _nextDimensionAfter(LifeDimensionType dimension) {
    final values = LifeDimensionType.values;
    final currentIndex = values.indexOf(dimension);
    if (currentIndex < 0) return values.first;
    return values[(currentIndex + 1) % values.length];
  }
}
