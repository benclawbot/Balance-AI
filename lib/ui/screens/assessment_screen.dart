import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../data/voice/voice_service.dart';
import '../../domain/life_dimension.dart';
import '../../state/balance_controller.dart';
import '../../state/balance_state.dart';
import '../components/app_chrome.dart';
import '../components/dimension_chip.dart';

class AssessmentScreen extends ConsumerStatefulWidget {
  const AssessmentScreen({super.key});

  @override
  ConsumerState<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends ConsumerState<AssessmentScreen> {
  late final VoiceService _voiceService;
  final _textController = TextEditingController();
  var _rating = 6.0;
  var _voiceReady = false;
  var _listening = false;
  LifeDimensionType? _syncedDimension;
  String? _syncedAnswerKey;

  @override
  void initState() {
    super.initState();
    _voiceService = DeviceSpeechToTextService();
    _initVoice();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncFieldsAndRebuild(ref.read(balanceControllerProvider));
    });
  }

  Future<void> _initVoice() async {
    final ready = await _voiceService.initialize();
    if (!mounted) return;
    setState(() => _voiceReady = ready);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<BalanceState>(balanceControllerProvider, (_, next) {
      _syncFieldsAndRebuild(next);
    });

    final state = ref.watch(balanceControllerProvider);
    final controller = ref.read(balanceControllerProvider.notifier);
    final selected = state.selectedDimension;
    final score = state.dimensions[selected];
    final history = state.answersFor(selected);
    final latestAnswer = state.latestAnswerFor(selected);

    return Column(
      children: [
        const BalanceTopBar(),
        Expanded(
          child: ScreenScroll(
            children: [
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: LifeDimensionType.values
                    .map(
                      (dimension) => DimensionChip(
                        dimension: dimension,
                        selected: dimension == selected,
                        onTap: () => controller.selectDimension(dimension),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 40),
              Text(
                'Currently Assessing: ${selected.label}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: MindfulColors.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                '${state.assessedDimensionCount}/${LifeDimensionType.values.length} dimensions saved',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: MindfulColors.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 18),
              Text(
                '"${selected.question}"',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 32),
              Center(
                child: _MicButton(
                  enabled: _voiceReady,
                  listening: _listening,
                  onPressed: _toggleListening,
                ),
              ),
              const SizedBox(height: 28),
              TonalCard(
                color: MindfulColors.surfaceContainerLowest,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.edit_note_rounded,
                          color: MindfulColors.clayAccent,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Transcript / Notes',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                history.isEmpty
                                    ? 'No saved updates for ${selected.label} yet'
                                    : '${history.length} saved ${history.length == 1 ? 'update' : 'updates'}'
                                        ' - latest ${_formatSavedAt(latestAnswer!.createdAt)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: MindfulColors.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _textController,
                      minLines: 3,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: _voiceReady
                            ? 'Speak or type what is going on in this dimension...'
                            : 'Voice unavailable. Type your answer here...',
                        filled: true,
                        fillColor: MindfulColors.surfaceContainerLow,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color:
                                MindfulColors.inkBlack.withValues(alpha: 0.12),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: MindfulColors.clayAccent,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Text('1',
                            style: Theme.of(context).textTheme.labelSmall),
                        Expanded(
                          child: Slider(
                            min: 1,
                            max: 10,
                            divisions: 9,
                            value: _rating,
                            label: _rating.round().toString(),
                            onChanged: (value) =>
                                setState(() => _rating = value),
                          ),
                        ),
                        Text('10',
                            style: Theme.of(context).textTheme.labelSmall),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Current estimate: ${score?.score.toStringAsFixed(1) ?? _rating.toStringAsFixed(0)}/10',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: MindfulColors.onSurfaceVariant,
                                ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        FilledButton.icon(
                          onPressed: () async {
                            final savedDimension = selected;
                            await controller.saveAssessmentAnswer(
                              dimension: savedDimension,
                              rating: _rating.round(),
                              transcript: _textController.text,
                            );
                            if (!context.mounted) return;
                            final next = ref
                                .read(balanceControllerProvider)
                                .selectedDimension;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    '${savedDimension.label} saved. Next: ${next.label}.'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: const Text('SAVE & NEXT'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!_voiceReady) ...[
                const SizedBox(height: 12),
                Text(
                  'Voice recognition is optional. The text field and score slider are always available.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: MindfulColors.onSurfaceVariant,
                      ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _syncFieldsAndRebuild(BalanceState state) {
    if (!mounted) return;
    if (_syncFieldsForSelection(state)) {
      setState(() {});
    }
  }

  bool _syncFieldsForSelection(BalanceState state) {
    final selected = state.selectedDimension;
    final latest = state.latestAnswerFor(selected);
    final score = state.dimensions[selected]?.score ?? 6;
    final answerKey = latest == null
        ? 'empty:${score.toStringAsFixed(1)}'
        : '${latest.createdAt.microsecondsSinceEpoch}:${latest.rating}:${latest.transcript.length}';

    if (_syncedDimension == selected && _syncedAnswerKey == answerKey) {
      return false;
    }

    _syncedDimension = selected;
    _syncedAnswerKey = answerKey;
    final nextRating = latest?.rating.toDouble() ?? score.roundToDouble();
    _rating = nextRating.clamp(1.0, 10.0).toDouble();
    _textController.text = latest?.transcript ?? '';
    _textController.selection =
        TextSelection.collapsed(offset: _textController.text.length);
    return true;
  }

  String _formatSavedAt(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '${value.month}/${value.day} $hour:$minute';
  }

  Future<void> _toggleListening() async {
    if (_listening) {
      await _voiceService.stopListening();
      if (mounted) setState(() => _listening = false);
      return;
    }
    setState(() => _listening = true);
    await _voiceService.startListening(
      onResult: (transcript) {
        if (!mounted) return;
        setState(() {
          _textController.text = transcript.text;
          _textController.selection =
              TextSelection.collapsed(offset: _textController.text.length);
          if (transcript.isFinal) _listening = false;
        });
      },
    );
  }
}

class _MicButton extends StatelessWidget {
  const _MicButton({
    required this.enabled,
    required this.listening,
    required this.onPressed,
  });

  final bool enabled;
  final bool listening;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: listening ? MindfulColors.clayAccent : MindfulColors.inkBlack,
        boxShadow: [
          BoxShadow(
            color:
                (listening ? MindfulColors.clayAccent : MindfulColors.inkBlack)
                    .withValues(alpha: 0.22),
            blurRadius: 36,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: IconButton(
        onPressed: enabled ? onPressed : null,
        iconSize: 56,
        color: Colors.white,
        disabledColor: Colors.white.withValues(alpha: 0.5),
        icon: Icon(listening ? Icons.stop_rounded : Icons.mic_rounded),
      ),
    );
  }
}
