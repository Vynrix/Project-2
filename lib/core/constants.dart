class AppConst {
  static const String appName = 'Vynrix Assistant';
  static const String settingsBox = 'settings_box';
  static const String tasksBox = 'tasks_box';
  static const String memoryBox = 'memory_box';
  static const String chatNormalBox = 'chat_normal_box';
  static const String chatAdvisorBox = 'chat_advisor_box';

  /// Pass token at runtime:
  /// flutter run --dart-define=HF_TOKEN=xxxxx
  static const String hfTokenKey = 'HF_TOKEN';

  /// Default HF model (you can change later in Profile screen).
  static const String defaultModel = 'mistralai/Mistral-7B-Instruct-v0.2';

  /// A smaller fallback model (still instruct-ish).
  static const String fallbackModel = 'HuggingFaceH4/zephyr-7b-beta';

  static const Duration apiTimeout = Duration(seconds: 45);
}
