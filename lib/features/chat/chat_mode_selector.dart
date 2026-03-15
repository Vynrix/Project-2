import 'package:flutter/material.dart';
import '../../core/prompts/system_prompts.dart';

class ChatModeSelector extends StatelessWidget {
  final ConversationMode mode;
  final ValueChanged<ConversationMode> onChanged;

  const ChatModeSelector({super.key, required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ConversationMode>(
      segments: const [
        ButtonSegment(value: ConversationMode.normal, label: Text('Normal')),
        ButtonSegment(value: ConversationMode.advisor, label: Text('Advisor')),
      ],
      selected: {mode},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}
