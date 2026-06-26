package com.balanceai.app

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Optional Android on-device Gemini/AICore voice bridge.
 *
 * This file is intentionally a guarded adapter stub. The production app should
 * wire this into MainActivity.configureFlutterEngine after platform wrappers are
 * generated with `flutter create .`:
 *
 *   GeminiSpeechChannel.register(flutterEngine)
 *
 * The default Flutter app already works without this class through the
 * speech_to_text plugin and text fallback. Implement the ML Kit GenAI speech
 * recognition client here only on Android builds where the required AICore /
 * Gemini Nano runtime is available.
 */
object GeminiSpeechChannel {
    private const val CHANNEL = "balance_ai/gemini_speech"

    fun register(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isAvailable" -> {
                    // Return false until the app integrates ML Kit GenAI Speech Recognition
                    // and verifies device support at runtime.
                    result.success(false)
                }
                "transcribeOnce" -> {
                    result.error(
                        "UNAVAILABLE",
                        "On-device Gemini speech recognition is not configured on this build.",
                        null,
                    )
                }
                "stop" -> result.success(null)
                else -> result.notImplemented()
            }
        }
    }
}
