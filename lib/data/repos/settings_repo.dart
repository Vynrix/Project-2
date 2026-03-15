import 'package:hive/hive.dart';
import '../../core/constants.dart';
import '../local/boxes.dart';

class SettingsRepo {
  final Box box;
  SettingsRepo(this.box);

  bool get onboardingDone => (box.get(Boxes.kOnboardingDone) as bool?) ?? false;
  Future<void> setOnboardingDone(bool v) => box.put(Boxes.kOnboardingDone, v);

  String get hfModel =>
      (box.get(Boxes.kHfModel) as String?) ?? AppConst.defaultModel;
  Future<void> setHfModel(String v) => box.put(Boxes.kHfModel, v);

  bool get includeMemoryInChat =>
      (box.get(Boxes.kIncludeMemoryInChat) as bool?) ?? true;
  Future<void> setIncludeMemoryInChat(bool v) =>
      box.put(Boxes.kIncludeMemoryInChat, v);

  String get lastDailyBrief =>
      (box.get(Boxes.kLastDailyBrief) as String?) ?? '';
  Future<void> setLastDailyBrief(String v) => box.put(Boxes.kLastDailyBrief, v);
}
