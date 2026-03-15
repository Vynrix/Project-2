import 'package:flutter/material.dart';
import '../../core/widgets/glass_card.dart';

class ChatMessageBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  const ChatMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final role = (message['role'] ?? '').toString();
    final text = (message['text'] ?? '').toString();
    final isUser = role == 'user';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: GlassCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUser ? 'You' : 'Vynrix',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: isUser
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(text, style: const TextStyle(height: 1.25)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
