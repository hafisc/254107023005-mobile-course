import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/comment.dart';
import 'repositories/comment_repository.dart';
import 'providers.dart'; // import dioProvider

final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  return CommentRepository(ref.watch(dioProvider));
});

// Menggunakan FutureProvider.autoDispose.family sebagai implementasi standar 
// untuk operasi GET berparameter (postId) yang akan merubah error secara otomatis menjadi AsyncError
final commentProvider = FutureProvider.autoDispose.family<List<Comment>, int>((ref, postId) async {
  final repository = ref.watch(commentRepositoryProvider);
  return repository.fetchComments(postId);
});
