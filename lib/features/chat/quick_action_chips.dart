import 'package:flutter/material.dart';
import '../../core/prompts/system_prompts.dart';

class QuickActionChips extends StatelessWidget {
  final ConversationMode mode;
  final ValueChanged<String> onAction;

  const QuickActionChips({super.key, required this.mode, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final normal = <(String, String)>[
      ('Summarize', 'Summarize our last exchange into 5 bullets + 1 decision.'),
      ('Brainstorm', 'Brainstorm 10 options. Label each by difficulty (Low/Med/High) and impact (Low/Med/High).'),
      ('Next steps', 'Give the next 5 actions. Each action must be < 15 words.'),
    ];

    final advisor = <(String, String)>[
      ('Startup idea', 'Generate 3 startup ideas for me. Include target user, problem, solution, and MVP.'),
      ('Marketing plan', 'Create a 7-day marketing plan with daily actions and expected outcome.'),
      ('Pitch draft', 'Write a short pitch: problem, solution, traction, why now, ask.'),
    ];

    final items = mode == ConversationMode.advisor ? advisor : normal;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items
            .map((it) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(it.$1),
                    onPressed: () => onAction(it.$2),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
