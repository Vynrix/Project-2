import '../../core/constants.dart';

class Boxes {
  static const settings = AppConst.settingsBox;
  static const tasks = AppConst.tasksBox;
  static const memory = AppConst.memoryBox;
  static const chatNormal = AppConst.chatNormalBox;
  static const chatAdvisor = AppConst.chatAdvisorBox;

  // Settings keys
  static const kOnboardingDone = 'onboarding_done';
  static const kHfModel = 'hf_model';
  static const kIncludeMemoryInChat = 'include_memory_in_chat';
  static const kLastDailyBrief = 'last_daily_brief';
}
