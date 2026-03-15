import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
    final settings = ref.read(settingsRepoProvider);
    if (!mounted) return;
    context.go(settings.onboardingDone ? '/' : '/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: Center(
        child: ShaderMask(
          shaderCallback: (r) => LinearGradient(
            colors: [cs.primary, cs.secondary],
          ).createShader(r),
          child: const Text(
            'V Y N R I X',
            style: TextStyle(
              fontSize: 34,
              letterSpacing: 8,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
