import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../pages/notes_page.dart';
import '../pages/note_detail_page.dart';
import '../pages/settings_page.dart';
import '../pages/posts_page.dart';

final appRouterProvider = Provider((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const NotesPage(),
        routes: [
          GoRoute(
            path: 'note/:id',
            builder: (context, state) {
              final idStr = state.pathParameters['id'];
              return NoteDetailPage(id: int.tryParse(idStr ?? ''));
            },
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsPage(),
          ),
          GoRoute(
            path: 'posts',
            builder: (context, state) => const PostsPage(),
          ),
        ],
      ),
    ],
  );
});
