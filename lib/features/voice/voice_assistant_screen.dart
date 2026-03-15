import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../core/providers.dart';
import '../../core/prompts/system_prompts.dart';
import '../../services/tts_service.dart';

class VoiceAssistantScreen extends ConsumerStatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  ConsumerState<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends ConsumerState<VoiceAssistantScreen> {
  final stt.SpeechToText _stt = stt.SpeechToText();
  final TtsService _tts = TtsService();

  bool _ready = false;
  bool _listening = false;
  bool _thinking = false;
  String _heard = '';
  String _reply = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _tts.init();
    _ready = await _stt.initialize();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Voice Assistant')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              _ready ? 'Press and speak.' : 'Speech recognition unavailable.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
            ),
            const SizedBox(height: 16),

            _panel('Heard', _heard),
            const SizedBox(height: 10),
            _panel('Vynrix', _reply),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(_listening ? Icons.stop_rounded : Icons.mic_rounded),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: _listening ? cs.secondary : cs.primary,
                ),
                onPressed: (!_ready || _thinking) ? null : _toggleListening,
                label: Text(_listening ? 'Stop' : 'Talk'),
              ),
            ),
            const SizedBox(height: 10),
            if (_thinking)
              Text('Thinking…', style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
          ],
        ),
      ),
    );
  }

  Widget _panel(String title, String body) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(body.isEmpty ? '—' : body, style: const TextStyle(height: 1.25)),
        ],
      ),
    );
  }

  Future<void> _toggleListening() async {
    if (_listening) {
      await _stt.stop();
      setState(() => _listening = false);
      if (_heard.trim().isNotEmpty) {
        await _ask(_heard.trim());
      }
      return;
    }

    setState(() {
      _heard = '';
      _reply = '';
      _listening = true;
    });

    await _stt.listen(
      onResult: (r) => setState(() => _heard = r.recognizedWords),
      listenMode: stt.ListenMode.confirmation,
    );
  }

  Future<void> _ask(String text) async {
    setState(() => _thinking = true);

    final settings = ref.read(settingsRepoProvider);
    final memoryRepo = ref.read(memoryRepoProvider);
    final taskRepo = ref.read(taskRepoProvider);
    final client = ref.read(huggingFaceClientProvider);

    final memorySummary =
        settings.includeMemoryInChat ? memoryRepo.buildMemorySummary() : '';

    final todayTasks = taskRepo
        .all()
        .where((t) => (t['done'] as bool? ?? false) == false)
        .map((t) => (t['title'] ?? '').toString())
        .where((t) => t.trim().isNotEmpty)
        .take(10)
        .toList();

    final prompt = SystemPrompts.buildPrompt(
      mode: ConversationMode.normal,
      userText: text,
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

      setState(() => _reply = reply);
      await _tts.speak(reply);
    } catch (e) {
      setState(() => _reply = 'Error: $e');
    } finally {
      if (mounted) setState(() => _thinking = false);
    }
  }
}
