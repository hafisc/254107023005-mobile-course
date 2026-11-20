import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/entities/chat_message.dart';
import '../domain/failures/ai_failure.dart';
import '../domain/usecases/send_chat_message_usecase.dart';
import 'chat_controller.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _send() {
    final text = _input.text;
    if (text.trim().isEmpty) return;
    _input.clear();
    ref.read(chatControllerProvider.notifier).send(text);
  }

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(chatControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asisten AI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Hapus percakapan',
            onPressed: chat.isStreaming
                ? null
                : ref.read(chatControllerProvider.notifier).clear,
          ),
        ],
      ),
      body: Column(
        children: [
          const _PrivacyBanner(),
          Expanded(
            child: chat.messages.isEmpty
                ? const _ChatEmpty()
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(12),
                    itemCount: chat.messages.length,
                    itemBuilder: (context, i) => _Bubble(
                      message: chat.messages[chat.messages.length - 1 - i],
                    ),
                  ),
          ),
          if (chat.isStreaming) const LinearProgressIndicator(),
          if (chat.failure != null) _FailurePanel(state: chat),
          _InputBar(
            controller: _input,
            enabled: !chat.isStreaming,
            onSend: _send,
          ),
        ],
      ),
    );
  }
}

class _PrivacyBanner extends StatelessWidget {
  const _PrivacyBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: const Text(
        'NIK, nomor HP, dan email otomatis disamarkan sebelum dikirim ke AI. '
        'Batas $dailyRequestLimit pertanyaan per hari.',
        style: TextStyle(fontSize: 12),
      ),
    );
  }
}

class _ChatEmpty extends StatelessWidget {
  const _ChatEmpty();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Tanyakan sesuatu tentang catatanmu,\n'
          'misalnya "Catatan apa saja yang saya punya?"',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == ChatRole.user;
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: isUser ? scheme.primaryContainer : scheme.secondaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message.text.isEmpty ? '…' : message.text),
            if (message.fromCache)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'dari cache lokal',
                  style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _FailurePanel extends ConsumerWidget {
  const _FailurePanel({required this.state});

  final ChatState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final failure = state.failure!;
    final needsKey =
        failure.type == AiFailureType.missingKey ||
        failure.type == AiFailureType.invalidKey;
    return Card(
      margin: const EdgeInsets.all(8),
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(failure.message),
            if (state.fallbackNotes.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Catatan lokal yang mungkin relevan:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              for (final note in state.fallbackNotes)
                Text('• ${note.title}', maxLines: 1),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (needsKey)
                  TextButton(
                    onPressed: () => context.go('/settings'),
                    child: const Text('Buka Pengaturan'),
                  ),
                if (failure.canFallback && !needsKey)
                  TextButton(
                    onPressed: ref.read(chatControllerProvider.notifier).retry,
                    child: const Text('Coba lagi'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.enabled,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 8, 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                maxLength: maxQuestionLength,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: const InputDecoration(
                  hintText: 'Tulis pertanyaan…',
                  counterText: '',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            IconButton.filled(
              icon: const Icon(Icons.send),
              tooltip: 'Kirim',
              onPressed: enabled ? onSend : null,
            ),
          ],
        ),
      ),
    );
  }
}
