// Copie este arquivo para app_config.dart e preencha com suas credenciais reais
class AppConfig {
  static const supabaseUrl = 'https://xxxx.supabase.co';
  static const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
  static const n8nWebhookUrl = 'https://seu-n8n.com/webhook/notion-sync';

  static bool get isConfigured =>
      supabaseUrl != 'YOUR_SUPABASE_URL' &&
      supabaseUrl != 'https://xxxx.supabase.co' &&
      supabaseUrl.isNotEmpty;
}
