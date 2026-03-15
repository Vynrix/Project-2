import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/providers.dart';
import '../../core/prompts/system_prompts.dart';
import '../../core/widgets/glass_card.dart';
import '../../data/local/boxes.dart';

class DailyBriefCard extends ConsumerStatefulWidget {
  const DailyBriefCard({super.key});

  @override
  ConsumerState<DailyBriefCard> createState() => _DailyBriefCardState();
}

class _DailyBriefCardState extends ConsumerState<DailyBriefCard> {
  bool _includeMemory = true;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final settingsRepo = ref.watch(settingsRepoProvider);
    final last = settingsRepo.lastDailyBrief;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.today_rounded, color: cs.primary),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Daily Brief', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              ),
              Switch(
                value: _includeMemory,
                onChanged: (v) => setState(() => _includeMemory = v),
              ),
            ],
          ),
          Text(
            'One tap plan for today (tasks + memory).',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _loading ? null : () => _generateBrief(context),
                  child: Text(_loading ? 'Generating…' : 'Generate'),
                ),
              ),
            ],
          ),
          if (last.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Latest brief:',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              last,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.85), height: 1.25),
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _generateBrief(BuildContext context) async {
    setState(() => _loading = true);

    final settings = ref.read(settingsRepoProvider);
    final client = ref.read(huggingFaceClientProvider);
    final taskRepo = ref.read(taskRepoProvider);
    final memoryRepo = ref.read(memoryRepoProvider);

    final openTasks = taskRepo
        .all()
        .where((t) => (t['done'] as bool? ?? false) == false)
        .map((t) => (t['title'] ?? '').toString())
        .where((t) => t.trim().isNotEmpty)
        .take(12)
        .toList();

    final memorySummary = _includeMemory ? memoryRepo.buildMemorySummary() : '';
    final dateLabel = DateFormat('EEEE, MMM d').format(DateTime.now());

    final prompt = SystemPrompts.dailyBriefPrompt(
      dateLabel: dateLabel,
      openTasks: openTasks,
      memorySummary: memorySummary,
    );

    try {
      final model = settings.hfModel;
      String text;
      try {
        text = await client.generateText(model: model, prompt: prompt);
      } catch (_) {
        text = await client.generateText(model: AppConst.fallbackModel, prompt: prompt);
      }

      await ref.read(settingsBoxProvider).put(Boxes.kLastDailyBrief, text);

      if (!context.mounted) return;
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Daily Brief'),
          content: SingleChildScrollView(child: Text(text)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ],
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Daily Brief failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
