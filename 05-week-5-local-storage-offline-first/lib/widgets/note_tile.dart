import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/local/note.dart';

class NoteTile extends StatelessWidget {
  const NoteTile({super.key, required this.note});

  final Note note;

  @override
  Widget build(BuildContext context) {
    final dateStr = note.updatedAt.toLocal().toString().split('.')[0];
    
    return ListTile(
      title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('Diperbarui: $dateStr'),
      trailing: note.dirty
          ? const Icon(Icons.cloud_upload_outlined, color: Colors.orange)
          : const Icon(Icons.cloud_done, color: Colors.green),
      onTap: () {
        if (note.id != null) {
          context.go('/note/${note.id}');
        }
      },
    );
  }
}
