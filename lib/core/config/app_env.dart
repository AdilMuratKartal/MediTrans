/// Zero-secret runtime environment configuration loaded exclusively via `--dart-define`.
/// Never hardcode API keys, URLs, or project identifiers in source code.
class AppEnvConfig {
  final String supabaseUrl;
  final String supabasePublishableKey;
  final String fcmWebVapidKey;

  const AppEnvConfig({
    required this.supabaseUrl,
    required this.supabasePublishableKey,
    required this.fcmWebVapidKey,
  });

  factory AppEnvConfig.fromEnvironment() {
    return const AppEnvConfig(
      supabaseUrl: String.fromEnvironment('SUPABASE_URL', defaultValue: ''),
      supabasePublishableKey: String.fromEnvironment(
        'SUPABASE_PUBLISHABLE_KEY',
        defaultValue: '',
      ),
      fcmWebVapidKey: String.fromEnvironment(
        'FCM_WEB_VAPID_KEY',
        defaultValue: '',
      ),
    );
  }

  bool get hasSupabaseConfig =>
      supabaseUrl.trim().isNotEmpty && supabasePublishableKey.trim().isNotEmpty;

  bool get hasFcmVapidKey => fcmWebVapidKey.trim().isNotEmpty;
}
