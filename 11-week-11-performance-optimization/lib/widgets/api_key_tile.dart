import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/ai/ai_providers.dart';
import '../domain/usecases/send_chat_message_usecase.dart';

/// Pengaturan API key Groq + info kuota harian.
class ApiKeyTile extends ConsumerWidget {
  const ApiKeyTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasKey = ref.watch(hasApiKeyProvider).value ?? false;
    final used = ref.watch(aiQuotaUsedProvider).value ?? 0;

    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.key),
          title: const Text('API Key Groq'),
          subtitle: Text(
            hasKey ? 'Tersimpan aman (terenkripsi)' : 'Belum diatur',
          ),
          trailing: hasKey
              ? IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Hapus API key',
                  onPressed: () async {
                    await ref.read(apiKeyStoreProvider).delete();
                    ref.invalidate(hasApiKeyProvider);
                  },
                )
              : null,
          onTap: () => _showDialog(context, ref),
        ),
        ListTile(
          leading: const Icon(Icons.speed),
          title: const Text('Kuota AI hari ini'),
          subtitle: Text('$used / $dailyRequestLimit pertanyaan terpakai'),
        ),
      ],
    );
  }

  Future<void> _showDialog(BuildContext context, WidgetRef ref) async {
    final value = await showDialog<String>(
      context: context,
      builder: (_) => const ApiKeyDialog(),
    );
    if (value == null || value.isEmpty) return;
    await ref.read(apiKeyStoreProvider).save(value);
    ref.invalidate(hasApiKeyProvider);
  }
}

/// Dialog memiliki controller-nya sendiri dan membuangnya di [dispose],
/// yaitu setelah animasi tutup selesai. Membuang controller tepat setelah
/// `showDialog` selesai menyebabkan assertion `_dependents.isEmpty`.
class ApiKeyDialog extends StatefulWidget {
  const ApiKeyDialog({super.key});

  @override
  State<ApiKeyDialog> createState() => _ApiKeyDialogState();
}

class _ApiKeyDialogState extends State<ApiKeyDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('API Key Groq'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        obscureText: true,
        autocorrect: false,
        decoration: const InputDecoration(
          hintText: 'Tempel API key dari console.groq.com',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
