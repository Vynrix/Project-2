import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/glass_card.dart';
import '../tasks/tasks_screen.dart';
import '../chat/chat_screen.dart';
import '../memory/memory_screen.dart';
import '../profile/profile_screen.dart';
import 'daily_brief_card.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeScreen(),
      const TasksScreen(),
      const ChatScreen(),
      const MemoryScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_tab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (v) => setState(() => _tab = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.check_circle_outline), label: 'Tasks'),
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'AI Chat'),
          NavigationDestination(icon: Icon(Icons.bookmark_border), label: 'Memory'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            ShaderMask(
              shaderCallback: (r) => LinearGradient(
                colors: [cs.primary, cs.secondary],
              ).createShader(r),
              child: const Text(
                'Vynrix',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            const Spacer(),
            Icon(Icons.auto_awesome, color: cs.secondary),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Execute the day. One clear step at a time.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
        ),
        const SizedBox(height: 16),

        const DailyBriefCard(),
        const SizedBox(height: 14),

        GlassCard(
          onTap: () => Navigator.of(context).pushNamed('/voice'),
          child: Row(
            children: [
              Icon(Icons.mic_rounded, color: cs.primary),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Voice Assistant', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
              Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.6)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          onTap: () => Navigator.of(context).pushNamed('/advisor'),
          child: Row(
            children: [
              Icon(Icons.rocket_launch_rounded, color: cs.secondary),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Startup Advisor Mode', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
              Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.6)),
            ],
          ),
        ),
      ],
    );
  }
}
