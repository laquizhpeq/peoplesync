import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String _get(String key) => dotenv.env[key]?.trim() ?? '';

  static String get supabaseUrl => _get('SUPABASE_URL').isNotEmpty
      ? _get('SUPABASE_URL')
      : _get('VITE_SUPABASE_URL');

  static String get supabaseAnonKey => _get('SUPABASE_ANON_KEY').isNotEmpty
      ? _get('SUPABASE_ANON_KEY')
      : _get('VITE_SUPABASE_PUBLISHABLE_KEY');

  static String get supabaseContactPhotosBucket =>
      _get('SUPABASE_CONTACT_PHOTOS_BUCKET');

  static String get supabaseContactPhotosFolder {
    final value = _get('SUPABASE_CONTACT_PHOTOS_FOLDER');
    return value.isEmpty ? 'contacts' : value;
  }

  static String get supabaseProfilePhotosFolder {
    final value = _get('SUPABASE_PROFILE_PHOTOS_FOLDER');
    return value.isEmpty ? 'profiles' : value;
  }

  static String get groqApiKey => _get('GROQ_API_KEY');

  static String get groqModel {
    final value = _get('GROQ_MODEL');
    return value.isEmpty ? 'llama-3.3-70b-versatile' : value;
  }
}
