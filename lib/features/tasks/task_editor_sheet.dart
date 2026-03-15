import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import 'tasks_screen.dart';

class TaskEditorSheet extends ConsumerStatefulWidget {
  final Map<String, dynamic>? existing;
  const TaskEditorSheet({super.key, this.existing});

  @override
  ConsumerState<TaskEditorSheet> createState() => _TaskEditorSheetState();
}

class _TaskEditorSheetState extends ConsumerState<TaskEditorSheet> {
  final _title = TextEditingController();
  final _note = TextEditingController();
  bool _done = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _title.text = (e['title'] ?? '').toString();
      _note.text = (e['note'] ?? '').toString();
      _done = (e['done'] as bool?) ?? false;
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
          Text(widget.existing == null ? 'New Task' : 'Edit Task',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
          const SizedBox(height: 10),
          TextField(controller: _note, decoration: const InputDecoration(labelText: 'Note')),
          const SizedBox(height: 10),
          Row(
            children: [
              Checkbox(value: _done, onChanged: (v) => setState(() => _done = v ?? false)),
              const Text('Done')
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                if (_title.text.trim().isEmpty) return;
                final repo = ref.read(taskRepoProvider);
                await repo.upsert(
                  id: widget.existing?['id'] as String?,
                  title: _title.text.trim(),
                  note: _note.text.trim(),
                  dueDate: null,
                  done: _done,
                );
                ref.read(tasksProvider.notifier).state++;
                if (!context.mounted) return;
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          )
        ],
      ),
    );
  }
}
