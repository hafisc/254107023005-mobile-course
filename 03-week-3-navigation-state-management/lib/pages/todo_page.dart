import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_tile.dart';

class TodoPage extends ConsumerWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Membaca state list todo untuk di-build ulang jika ada perubahan
    final todos = ref.watch(todoListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar ToDo'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: todos.isEmpty
          ? const Center(
              child: Text(
                'Belum ada tugas. Tambahkan tugas baru!',
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: todos.length,
              itemBuilder: (context, index) {
                return TodoTile(todo: todos[index]);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tugas Baru'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Masukkan nama tugas...',
          ),
          onSubmitted: (value) {
            _addTodo(context, ref, value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              _addTodo(context, ref, controller.text);
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  void _addTodo(BuildContext context, WidgetRef ref, String text) {
    final title = text.trim();
    if (title.isNotEmpty) {
      ref.read(todoListProvider.notifier).add(title);
    }
    Navigator.pop(context);
  }
}
