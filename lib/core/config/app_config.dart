import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  const AppConfig._();

  static String get supabaseUrl => _require('SUPABASE_URL');
  static String get supabasePublishableKey =>
      _require('SUPABASE_PUBLISHABLE_KEY');

  static String _require(String key) {
    final value = dotenv.env[key];
    if (value == null || value.isEmpty) {
      throw StateError(
        'Missing "$key" in .env.\n'
        'Loaded keys: ${dotenv.env.keys.join(', ')}\n'
        'Check the file exists, is listed under flutter: assets: in '
        'pubspec.yaml, and do a full restart rather than a hot reload.',
      );
    }
    return value;
  }
}
