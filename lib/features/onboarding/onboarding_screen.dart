import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';
import '../../core/widgets/glass_card.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _i = 0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (v) => setState(() => _i = v),
                  children: const [
                    _OnbPage(
                      title: 'Meet Vynrix',
                      body: 'A calm, precise AI assistant for daily execution.',
                    ),
                    _OnbPage(
                      title: 'Voice + Chat',
                      body: 'Push-to-talk voice assistant and focused chat modes.',
                    ),
                    _OnbPage(
                      title: 'Planner + Memory',
                      body: 'Tasks and personal memory to keep your day aligned.',
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: GlassCard(
                      onTap: () async {
                        if (_i < 2) {
                          await _controller.nextPage(
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeOut,
                          );
                          return;
                        }
                        await ref.read(settingsRepoProvider).setOnboardingDone(true);
                        if (!context.mounted) return;
                        context.go('/');
                      },
                      child: Center(
                        child: Text(
                          _i < 2 ? 'Next' : 'Start',
                          style: TextStyle(
                            color: cs.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Tip: Run with --dart-define=HF_TOKEN=YOUR_TOKEN',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnbPage extends StatelessWidget {
  final String title;
  final String body;
  const _OnbPage({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GlassCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (r) => LinearGradient(
              colors: [cs.primary, cs.secondary],
            ).createShader(r),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 15,
              height: 1.35,
            ),
          ),
          const Spacer(),
          Text(
            'Vynrix Assistant V1',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
          )
        ],
      ),
    );
  }
}
