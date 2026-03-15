import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../core/constants.dart';
import '../data/repos/chat_repo.dart';
import '../data/repos/task_repo.dart';
import '../data/repos/memory_repo.dart';
import '../data/repos/settings_repo.dart';
import '../services/huggingface_api_client.dart';
import '../data/local/boxes.dart';
import 'prompts/system_prompts.dart';

final settingsBoxProvider = Provider<Box>((ref) => Hive.box(AppConst.settingsBox));
final tasksBoxProvider = Provider<Box>((ref) => Hive.box(AppConst.tasksBox));
final memoryBoxProvider = Provider<Box>((ref) => Hive.box(AppConst.memoryBox));
final chatNormalBoxProvider = Provider<Box>((ref) => Hive.box(AppConst.chatNormalBox));
final chatAdvisorBoxProvider = Provider<Box>((ref) => Hive.box(AppConst.chatAdvisorBox));

final settingsRepoProvider = Provider<SettingsRepo>((ref) => SettingsRepo(ref.watch(settingsBoxProvider)));
final taskRepoProvider = Provider<TaskRepo>((ref) => TaskRepo(ref.watch(tasksBoxProvider)));
final memoryRepoProvider = Provider<MemoryRepo>((ref) => MemoryRepo(ref.watch(memoryBoxProvider)));

final chatRepoProvider = Provider.family<ChatRepo, ConversationMode>((ref, mode) {
  final box = mode == ConversationMode.advisor
      ? ref.watch(chatAdvisorBoxProvider)
      : ref.watch(chatNormalBoxProvider);
  return ChatRepo(box);
});

final hfTokenProvider = Provider<String>(() {
  // ignore: do_not_use_environment
  const token = String.fromEnvironment(AppConst.hfTokenKey);
  return token;
});

final huggingFaceClientProvider = Provider<HuggingFaceApiClient>((ref) {
  final token = ref.watch(hfTokenProvider);
  if (token.trim().isEmpty) {
    throw Exception('Missing HF_TOKEN. Run with --dart-define=HF_TOKEN=...');
  }
  return HuggingFaceApiClient(token: token);
});
