import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/widgets/glass_card.dart';
import 'memory_editor_sheet.dart';

final memoryProvider = StateProvider<int>((ref) => 0);

class MemoryScreen extends ConsumerWidget {
  const MemoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(memoryProvider);
    final repo = ref.watch(memoryRepoProvider);
    final items = repo.all();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            const Text('Memory', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
            const Spacer(),
            IconButton(
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => const MemoryEditorSheet(),
              ),
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (items.isEmpty)
          Text('No memory entries yet. Add notes/dates.', style: TextStyle(color: Colors.white.withValues(alpha: 0.7)))
        else
          ...items.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GlassCard(
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => MemoryEditorSheet(existing: m),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bookmark_add_outlined),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text((m['title'] ?? '').toString(),
                                style: const TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 2),
                            Text(
                              (m['content'] ?? '').toString(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          await repo.delete(m['id'] as String);
                          ref.read(memoryProvider.notifier).state++;
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
