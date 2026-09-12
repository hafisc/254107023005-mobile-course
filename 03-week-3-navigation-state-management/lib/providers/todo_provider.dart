import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';

// Notifier untuk mengelola daftar Todo
class TodoListNotifier extends Notifier<List<Todo>> {
  @override
  List<Todo> build() {
    return []; // State awal kosong
  }

  void add(String title) {
    // Generate simple id
    final newId = DateTime.now().millisecondsSinceEpoch.toString();
    final newTodo = Todo(id: newId, title: title);
    
    // Immutable update: buat list baru, sebarkan list lama, dan tambah item baru
    state = [...state, newTodo];
  }

  void toggle(String id) {
    // Immutable update: petakan list, jika id cocok, ganti status done-nya
    state = state.map((todo) {
      if (todo.id == id) {
        return todo.copyWith(done: !todo.done);
      }
      return todo;
    }).toList();
  }

  void remove(String id) {
    // Immutable update: saring list sehingga id yang dihapus tidak ikut
    state = state.where((todo) => todo.id != id).toList();
  }
}

// Provider untuk TodoListNotifier
final todoListProvider = NotifierProvider<TodoListNotifier, List<Todo>>(() {
  return TodoListNotifier();
});

// Provider turunan (Refactoring Challenge): hanya menampilkan Todo yang belum selesai
final uncompletedTodoProvider = Provider<List<Todo>>((ref) {
  final todos = ref.watch(todoListProvider);
  return todos.where((todo) => !todo.done).toList();
});
