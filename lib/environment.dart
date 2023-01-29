import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get chatGPTKey {
    return dotenv.get('OPENAI_API_KEY', fallback: '');
  }
}
