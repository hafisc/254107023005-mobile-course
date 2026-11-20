import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../pages/chat_page.dart';
import '../pages/notes_page.dart';
import '../pages/note_detail_page.dart';
import '../pages/settings_page.dart';
import '../pages/posts_page.dart';

final appRouterProvider = Provider((ref) {
  final router = GoRouter(
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
          GoRoute(path: 'chat', builder: (context, state) => const ChatPage()),
          GoRoute(
            path: 'posts',
            builder: (context, state) => const PostsPage(),
          ),
        ],
      ),
    ],
  );
  // Minggu 11: ditemukan leak tracker. Tanpa ini GoRouterDelegate dan
  // GoRouteInformationProvider (beserta listener-nya) tidak pernah dibuang.
  ref.onDispose(router.dispose);
  return router;
});
