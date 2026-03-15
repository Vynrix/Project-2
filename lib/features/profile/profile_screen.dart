import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers.dart';
import '../../core/constants.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late final TextEditingController _model;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsRepoProvider);
    _model = TextEditingController(text: settings.hfModel);
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsRepoProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Profile / Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),

        SwitchListTile(
          title: const Text('Include memory in chat prompts'),
          value: settings.includeMemoryInChat,
          onChanged: (v) async {
            await ref.read(settingsRepoProvider).setIncludeMemoryInChat(v);
            setState(() {});
          },
        ),
        const SizedBox(height: 10),

        TextField(
          controller: _model,
          decoration: const InputDecoration(
            labelText: 'Hugging Face model (ID)',
            hintText: 'mistralai/Mistral-7B-Instruct-v0.2',
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              await ref.read(settingsRepoProvider).setHfModel(_model.text.trim());
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Saved model.')),
              );
              setState(() {});
            },
            child: const Text('Save Model'),
          ),
        ),

        const SizedBox(height: 12),
        Text(
          'Default: ${AppConst.defaultModel}\nFallback: ${AppConst.fallbackModel}',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        ),
        const SizedBox(height: 12),
        Text(
          'HF_TOKEN must be provided via --dart-define.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        ),
      ],
    );
  }
}
  
