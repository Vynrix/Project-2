import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/splash/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/home/home_screen.dart';
import 'features/chat/chat_screen.dart';
import 'features/voice/voice_assistant_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (c, s) => const MaterialPage(child: SplashScreen()),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (c, s) => const MaterialPage(child: OnboardingScreen()),
      ),
      GoRoute(
        path: '/',
        pageBuilder: (c, s) => const MaterialPage(child: HomeShell()),
      ),
      GoRoute(
        path: '/voice',
        pageBuilder: (c, s) => const MaterialPage(child: VoiceAssistantScreen()),
      ),
      GoRoute(
        path: '/advisor',
        pageBuilder: (c, s) => const MaterialPage(
          child: ChatScreen(initialAdvisorMode: true),
        ),
      ),
    ],
  );
});
