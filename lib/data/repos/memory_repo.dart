import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class MemoryRepo {
  final Box box;
  final _uuid = const Uuid();

  MemoryRepo(this.box);

  List<Map<String, dynamic>> all() {
    final list = <Map<String, dynamic>>[];
    for (final k in box.keys) {
      list.add((box.get(k) as Map).cast<String, dynamic>());
    }
    list.sort((a, b) => (b['createdAt'] as String).compareTo(a['createdAt']));
    return list;
  }

  Future<void> upsert({
    String? id,
    required String title,
    required String content,
    required DateTime? importantDate,
  }) async {
    final now = DateTime.now();
    final memId = id ?? _uuid.v4();
    final createdAt = (id == null)
        ? now
        : DateTime.parse(
            box.get(memId)?['createdAt'] ?? now.toIso8601String(),
          );

    await box.put(memId, {
      'id': memId,
      'title': title,
      'content': content,
      'importantDate': importantDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    });
  }

  Future<void> delete(String id) => box.delete(id);

  /// Very small “memory summary” for prompt injection.
  String buildMemorySummary({int maxItems = 8, int maxChars = 900}) {
    final items = all().take(maxItems).toList();
    final lines = items.map((m) {
      final t = (m['title'] ?? '').toString().trim();
      final c = (m['content'] ?? '').toString().trim();
      final d = (m['importantDate'] ?? '').toString().trim();
      final datePart = d.isEmpty ? '' : ' (date: ${d.split("T").first})';
      final snippet = c.length > 120 ? '${c.substring(0, 120)}…' : c;
      return '- $t$datePart: $snippet';
    }).join('\n');

    if (lines.length <= maxChars) return lines;
    return '${lines.substring(0, maxChars)}…';
  }
}
