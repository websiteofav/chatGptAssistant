import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeech {
  static final FlutterTts _flutterTts = FlutterTts();

  static initTTS() {
    _flutterTts.setLanguage('en-US');
    _flutterTts.setPitch(1);
    _flutterTts.setSpeechRate(0.5);
    
  }

  static convertToSpeech(text) async {
    await _flutterTts.awaitSpeakCompletion(true);
    _flutterTts.speak(text);
  }
}
