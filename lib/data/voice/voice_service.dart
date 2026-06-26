import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class VoiceTranscript {
  const VoiceTranscript({
    required this.text,
    required this.confidence,
    required this.isFinal,
  });

  final String text;
  final double confidence;
  final bool isFinal;
}

abstract class VoiceService {
  Future<bool> initialize();
  Future<void> startListening({required void Function(VoiceTranscript transcript) onResult});
  Future<void> stopListening();
  bool get isAvailable;
  bool get isListening;
}

class DeviceSpeechToTextService implements VoiceService {
  DeviceSpeechToTextService({SpeechToText? speechToText}) : _speechToText = speechToText ?? SpeechToText();

  final SpeechToText _speechToText;
  bool _available = false;

  @override
  bool get isAvailable => _available;

  @override
  bool get isListening => _speechToText.isListening;

  @override
  Future<bool> initialize() async {
    _available = await _speechToText.initialize();
    return _available;
  }

  @override
  Future<void> startListening({required void Function(VoiceTranscript transcript) onResult}) async {
    if (!_available) {
      final initialized = await initialize();
      if (!initialized) return;
    }
    await _speechToText.listen(
      listenMode: ListenMode.confirmation,
      partialResults: true,
      onResult: (SpeechRecognitionResult result) {
        onResult(
          VoiceTranscript(
            text: result.recognizedWords,
            confidence: result.confidence,
            isFinal: result.finalResult,
          ),
        );
      },
    );
  }

  @override
  Future<void> stopListening() => _speechToText.stop();
}

/// Optional Android-only path for on-device Gemini/AICore speech handling.
///
/// This class intentionally exposes a MethodChannel instead of embedding raw
/// Android implementation details in Dart. Devices without the Android GenAI
/// runtime must fall back to [DeviceSpeechToTextService] or text entry.
class GeminiOnDeviceVoiceService implements VoiceService {
  GeminiOnDeviceVoiceService({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('balance_ai/gemini_speech');

  final MethodChannel _channel;
  bool _available = false;
  bool _listening = false;

  @override
  bool get isAvailable => _available;

  @override
  bool get isListening => _listening;

  @override
  Future<bool> initialize() async {
    try {
      _available = await _channel.invokeMethod<bool>('isAvailable') ?? false;
      return _available;
    } catch (_) {
      _available = false;
      return false;
    }
  }

  @override
  Future<void> startListening({required void Function(VoiceTranscript transcript) onResult}) async {
    if (!_available) {
      final initialized = await initialize();
      if (!initialized) return;
    }
    _listening = true;
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('transcribeOnce');
      if (result != null) {
        onResult(
          VoiceTranscript(
            text: result['text']?.toString() ?? '',
            confidence: (result['confidence'] as num?)?.toDouble() ?? 0,
            isFinal: true,
          ),
        );
      }
    } finally {
      _listening = false;
    }
  }

  @override
  Future<void> stopListening() async {
    _listening = false;
    try {
      await _channel.invokeMethod<void>('stop');
    } catch (_) {
      // No-op fallback. Text input remains available.
    }
  }
}
