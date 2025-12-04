import 'package:flutter_dotenv/flutter_dotenv.dart';

// Central Supabase configuration used by the app.
// Prefers compile-time `--dart-define` values, falls back to `flutter_dotenv`.

String get supabaseUrl {
	const fromDefine = String.fromEnvironment('SUPABASE_URL');
	if (fromDefine.isNotEmpty) return fromDefine;
	return dotenv.env['SUPABASE_URL'] ?? 'https://your-project-id.supabase.co';
}

String get supabaseAnonKey {
	const fromDefine = String.fromEnvironment('SUPABASE_ANON_KEY');
	if (fromDefine.isNotEmpty) return fromDefine;
	return dotenv.env['SUPABASE_ANON_KEY'] ?? dotenv.env['SUPABASE_KEY'] ?? 'your_supabase_anon_key_here';
}
