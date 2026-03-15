enum ConversationMode { normal, advisor }

class SystemPrompts {
  static String normalSystemPrompt() => '''
You are Vynrix — a calm, precise personal AI assistant inspired by J.A.R.V.I.S.
Rules:
- Be concise and actionable.
- Ask at most one clarifying question if needed.
- Prefer bullet points and steps.
- Never claim you did actions in the real world.
''';

  static String advisorSystemPrompt() => '''
You are Vynrix in Startup Advisor Mode.
You help entrepreneurs with product, marketing, and strategy.
Rules:
- Be concrete: give frameworks, checklists, and next steps.
- Provide 2–3 options with pros/cons.
- End with a short action plan.
''';

  static String dailyBriefSystemPrompt() => '''
You are Vynrix. Create a concise daily plan.
Output format:
1) Top 3 priorities
2) Time blocks (morning/afternoon/evening)
3) Risks & reminders
4) First action (do now)
Keep it under 180 words.
''';

  static String buildPrompt({
    required ConversationMode mode,
    required String userText,
    String? memorySummary,
    List<String>? todayTasks,
  }) {
    final system = mode == ConversationMode.advisor
        ? advisorSystemPrompt()
        : normalSystemPrompt();

    final mem = (memorySummary != null && memorySummary.trim().isNotEmpty)
        ? '\nMemory context (user notes):\n$memorySummary\n'
        : '';

    final tasks = (todayTasks != null && todayTasks.isNotEmpty)
        ? '\nToday tasks:\n- ${todayTasks.join('\n- ')}\n'
        : '';

    return '''
<SYSTEM>
$system
</SYSTEM>
$mem
$tasks
<USER>
$userText
</USER>
<ASSISTANT>
''';
  }

  static String dailyBriefPrompt({
    required String dateLabel,
    required List<String> openTasks,
    required String memorySummary,
  }) {
    return '''
<SYSTEM>
${dailyBriefSystemPrompt()}
</SYSTEM>
<USER>
Today is $dateLabel.

Open tasks:
${openTasks.isEmpty ? "- (none)" : openTasks.map((t) => "- $t").join("\n")}

Memory notes:
${memorySummary.trim().isEmpty ? "(none)" : memorySummary}

Make my Daily Brief now.
</USER>
<ASSISTANT>
''';
  }
}
