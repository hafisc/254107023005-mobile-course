import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/providers.dart';

class PostsPage extends ConsumerWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cachedPostsAsync = ref.watch(postsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cached API Posts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: ref.read(postsProvider.notifier).refresh,
          ),
        ],
      ),
      body: cachedPostsAsync.when(
        data: (posts) {
          if (posts.isEmpty) {
            return const Center(
              child: Text('Tidak ada post di cache. Coba refresh saat online.'),
            );
          }
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return ListTile(
                title: Text(
                  post.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(post.body),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
