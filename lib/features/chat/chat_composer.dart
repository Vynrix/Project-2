import 'package:flutter/material.dart';

class ChatComposer extends StatefulWidget {
  final bool sending;
  final ValueChanged<String> onSend;
  final VoidCallback onClear;

  const ChatComposer({
    super.key,
    required this.sending,
    required this.onSend,
    required this.onClear,
  });

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  final _c = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _c,
            minLines: 1,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Message Vynrix…',
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: widget.sending
              ? null
              : () {
                  final t = _c.text;
                  _c.clear();
                  widget.onSend(t);
                },
          icon: Icon(widget.sending ? Icons.hourglass_top : Icons.send_rounded),
        ),
        IconButton(
          onPressed: widget.sending ? null : widget.onClear,
          icon: const Icon(Icons.delete_sweep_outlined),
        ),
      ],
    );
  }
}
