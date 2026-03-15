import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants.dart';

class HiveInit {
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(AppConst.settingsBox);
    await Hive.openBox(AppConst.tasksBox);
    await Hive.openBox(AppConst.memoryBox);
    await Hive.openBox(AppConst.chatNormalBox);
    await Hive.openBox(AppConst.chatAdvisorBox);
  }
}
