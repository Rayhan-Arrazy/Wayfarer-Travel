import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();

  Future<void> init() async {
    try {
      if (kIsWeb) return;
      await _flutterTts.setSharedInstance(true);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setPitch(1.0);
    } catch (e) {
      debugPrint('TTS Init error: $e');
    }
  }

  Future<void> speak(String text, String languageCode) async {
    try {
      await _flutterTts.stop();
      await _flutterTts.setLanguage(languageCode);
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('TTS Speak error: $e');
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
