import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/prompts/system_prompts.dart';
import '../../core/widgets/glass_card.dart';
import 'chat_mode_selector.dart';
import 'chat_message_bubble.dart';
import 'chat_composer.dart';
import 'quick_action_chips.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final bool initialAdvisorMode;
  const ChatScreen({super.key, this.initialAdvisorMode = false});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  late ConversationMode _mode;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialAdvisorMode ? ConversationMode.advisor : ConversationMode.normal;
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(chatRepoProvider(_mode));
    final settings = ref.watch(settingsRepoProvider);

    final messages = repo.getMessages();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
          child: Row(
            children: [
              const Text('AI Chat', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              const Spacer(),
              ChatModeSelector(
                mode: _mode,
                onChanged: (m) => setState(() => _mode = m),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GlassCard(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.memory_rounded, color: Theme.of(context).colorScheme.secondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    settings.includeMemoryInChat
                        ? 'Memory context: ON'
                        : 'Memory context: OFF',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                  ),
                ),
              ],
            ),
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            itemCount: messages.length,
            itemBuilder: (_, i) => ChatMessageBubble(message: messages[i]),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
          child: QuickActionChips(
            mode: _mode,
            onAction: (template) => _send(template),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: ChatComposer(
            sending: _sending,
            onSend: (text) => _send(text),
            onClear: () async {
              await repo.clear();
              setState(() {});
            },
          ),
        ),
      ],
    );
  }

  Future<void> _send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    setState(() => _sending = true);

    final settings = ref.read(settingsRepoProvider);
    final memoryRepo = ref.read(memoryRepoProvider);
    final taskRepo = ref.read(taskRepoProvider);
    final chatRepo = ref.read(chatRepoProvider(_mode));
    final client = ref.read(huggingFaceClientProvider);

    final includeMem = settings.includeMemoryInChat;
    final memorySummary = includeMem ? memoryRepo.buildMemorySummary() : '';

    final todayTasks = taskRepo
        .all()
        .where((t) => (t['done'] as bool? ?? false) == false)
        .map((t) => (t['title'] ?? '').toString())
        .where((t) => t.trim().isNotEmpty)
        .take(10)
        .toList();

    await chatRepo.addMessage(role: 'user', text: trimmed, createdAt: DateTime.now());
    setState(() {});

    final prompt = SystemPrompts.buildPrompt(
      mode: _mode,
      userText: trimmed,
      memorySummary: memorySummary,
      todayTasks: todayTasks,
    );

    try {
      final model = settings.hfModel;
      String reply;
      try {
        reply = await client.generateText(model: model, prompt: prompt);
      } catch (_) {
        reply = await client.generateText(model: AppConst.fallbackModel, prompt: prompt);
      }

      await chatRepo.addMessage(role: 'assistant', text: reply, createdAt: DateTime.now());
      setState(() {});
    } catch (e) {
      await chatRepo.addMessage(
        role: 'assistant',
        text: 'Error: $e',
        createdAt: DateTime.now(),
      );
      setState(() {});
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }
}
