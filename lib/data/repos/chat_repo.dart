import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class ChatRepo {
  final Box box;
  final _uuid = const Uuid();

  ChatRepo(this.box);

  List<Map<String, dynamic>> getMessages() {
    final keys = box.keys.cast<dynamic>().toList();
    keys.sort((a, b) => a.toString().compareTo(b.toString()));
    return keys
        .map((k) => (box.get(k) as Map).cast<String, dynamic>())
        .toList();
  }

  Future<void> addMessage({
    required String role, // 'user' or 'assistant'
    required String text,
    required DateTime createdAt,
  }) async {
    final id = '${createdAt.millisecondsSinceEpoch}_${_uuid.v4()}';
    await box.put(id, {
      'id': id,
      'role': role,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
    });
  }

  Future<void> clear() => box.clear();
}
