import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class TaskRepo {
  final Box box;
  final _uuid = const Uuid();

  TaskRepo(this.box);

  List<Map<String, dynamic>> all() {
    final list = <Map<String, dynamic>>[];
    for (final k in box.keys) {
      list.add((box.get(k) as Map).cast<String, dynamic>());
    }
    list.sort((a, b) => (a['createdAt'] as String).compareTo(b['createdAt']));
    return list;
  }

  Future<void> upsert({
    String? id,
    required String title,
    required String note,
    required DateTime? dueDate,
    required bool done,
  }) async {
    final now = DateTime.now();
    final taskId = id ?? _uuid.v4();
    final createdAt = (id == null) ? now : DateTime.parse(box.get(taskId)?['createdAt'] ?? now.toIso8601String());
    await box.put(taskId, {
      'id': taskId,
      'title': title,
      'note': note,
      'done': done,
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    });
  }

  Future<void> toggleDone(String id) async {
    final m = (box.get(id) as Map).cast<String, dynamic>();
    await box.put(id, {
      ...m,
      'done': !(m['done'] as bool? ?? false),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> delete(String id) => box.delete(id);
}
