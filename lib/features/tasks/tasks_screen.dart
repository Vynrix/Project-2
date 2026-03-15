import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/widgets/glass_card.dart';
import 'task_editor_sheet.dart';

final tasksProvider = StateProvider<int>((ref) => 0); // simple rebuild trigger

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(tasksProvider);
    final repo = ref.watch(taskRepoProvider);
    final tasks = repo.all();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            const Text('Tasks', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
            const Spacer(),
            IconButton(
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => const TaskEditorSheet(),
              ),
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (tasks.isEmpty)
          Text('No tasks yet. Add one.', style: TextStyle(color: Colors.white.withValues(alpha: 0.7)))
        else
          ...tasks.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GlassCard(
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => TaskEditorSheet(existing: t),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: (t['done'] as bool?) ?? false,
                        onChanged: (_) async {
                          await repo.toggleDone(t['id'] as String);
                          ref.read(tasksProvider.notifier).state++;
                        },
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (t['title'] ?? '').toString(),
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            if (((t['note'] ?? '') as String).trim().isNotEmpty)
                              Text(
                                (t['note'] ?? '').toString(),
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          await repo.delete(t['id'] as String);
                          ref.read(tasksProvider.notifier).state++;
                        },
                        icon: Icon(Icons.delete_outline, color: Colors.white.withValues(alpha: 0.7)),
                      )
                    ],
                  ),
                ),
              )),
      ],
    );
  }
}
