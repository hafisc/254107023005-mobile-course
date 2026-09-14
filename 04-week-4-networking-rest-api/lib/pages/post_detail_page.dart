import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/post.dart';
import '../data/comment_provider.dart';
import '../data/network_errors.dart';

class PostDetailPage extends ConsumerWidget {
  const PostDetailPage({
    super.key,
    required this.postId,
    this.post,
  });

  final int postId;
  final Post? post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Membaca provider khusus komentar berdasarkan parameter postId
    final commentsAsync = ref.watch(commentProvider(postId));

    return Scaffold(
      appBar: AppBar(
        title: Text(post?.title ?? 'Post $postId'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post?.title ?? 'Judul Post',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    post?.body ?? 'Isi konten post akan tampil di sini.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const Divider(height: 32),
                  Text(
                    'Komentar',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          commentsAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
            error: (err, stack) => SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(friendlyErrorMessage(err),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => ref.invalidate(commentProvider(postId)),
                        child: const Text('Coba lagi'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            data: (comments) {
              if (comments.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('Belum ada komentar.'),
                    ),
                  ),
                );
              }
              return SliverList.builder(
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(comment.name,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(comment.body),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
