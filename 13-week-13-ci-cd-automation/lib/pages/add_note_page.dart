import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/providers.dart';
import '../domain/usecases/validate_note_title.dart';

/// Minggu 12: form tambah catatan. Sebelumnya tombol + selalu membuat
/// "Catatan Baru" tanpa input pengguna.
class AddNotePage extends ConsumerStatefulWidget {
  const AddNotePage({super.key});

  static const titleFieldKey = Key('note-title-field');
  static const bodyFieldKey = Key('note-body-field');
  static const saveButtonKey = Key('save-note-button');

  @override
  ConsumerState<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends ConsumerState<AddNotePage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _body = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(notesProvider.notifier)
          .addNote(_title.text.trim(), _body.text.trim());
      if (mounted) context.pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      // Input tidak dibuang agar pengguna bisa langsung mencoba lagi.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan catatan. Coba lagi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Catatan')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              key: AddNotePage.titleFieldKey,
              controller: _title,
              autofocus: true,
              enabled: !_saving,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Judul',
                border: OutlineInputBorder(),
              ),
              validator: validateNoteTitle,
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: AddNotePage.bodyFieldKey,
              controller: _body,
              enabled: !_saving,
              minLines: 3,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Isi (opsional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              key: AddNotePage.saveButtonKey,
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_saving ? 'Menyimpan…' : 'Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
