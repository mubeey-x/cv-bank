import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  const AppConfig._();
  static String get supabaseUrl => dotenv.env['SUPABASE_URL']!;
  static String get supabasePublishableKey => dotenv.env['SUPABASE_ANON_KEY']!;
}
