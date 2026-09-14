import 'package:go_router/go_router.dart';
import '../pages/paged_post_page.dart';
import '../pages/post_detail_page.dart';
import '../data/models/post.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const PagedPostPage(),
    ),
    GoRoute(
      path: '/post/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
        final post = state.extra as Post?;
        return PostDetailPage(postId: id, post: post);
      },
    ),
  ],
);
