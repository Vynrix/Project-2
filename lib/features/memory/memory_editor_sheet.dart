import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import 'memory_screen.dart';

class MemoryEditorSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic>? existing;
  const MemoryEditorSheet({super.key, this.existing});

  @override
  ConsumerState<MemoryEditorSheet> createState() => _MemoryEditorSheetState();
}

class _MemoryEditorSheetState extends ConsumerState<MemoryEditorSheet> {
  final _title = TextEditingController();
  final _content = TextEditingController();

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _title.text = (e['title'] ?? '').toString();
      _content.text = (e['content'] ?? '').toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + pad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.existing == null ? 'New Memory' : 'Edit Memory',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
          const SizedBox(height: 10),
          TextField(
            controller: _content,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'Content'),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                if (_title.text.trim().isEmpty) return;
                final repo = ref.read(memoryRepoProvider);
                await repo.upsert(
                  id: widget.existing?['id'] as String?,
                  title: _title.text.trim(),
                  content: _content.text.trim(),
                  importantDate: null,
                );
                ref.read(memoryProvider.notifier).state++;
                if (!context.mounted) return;
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}
