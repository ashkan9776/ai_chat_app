class ApiConfig {
  static const String apiUrl = 'https://api.deepseek.com/v1/chat/completions';
  static const String model = 'deepseek-chat';
  
  // تنظیمات مدل
  static const double temperature = 0.7;
  static const int maxTokens = 2048;
  static const double topP = 0.95;
}