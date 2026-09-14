import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/comment.dart';

void main() {
  test('Comment.fromJson aman terhadap field yang hilang (AI Challenge)', () {
    // Memberikan JSON kosong (semua field hilang)
    final comment = Comment.fromJson({});
    
    // Verifikasi bahwa properti menggunakan fallback default, tidak melempar error Null
    expect(comment.postId, 0);
    expect(comment.id, 0);
    expect(comment.name, '');
    expect(comment.email, '');
    expect(comment.body, '');
    
    // Memberikan JSON parsial
    final comment2 = Comment.fromJson({'name': 'John', 'id': 5});
    expect(comment2.name, 'John');
    expect(comment2.id, 5);
    expect(comment2.email, ''); // Missing fields should fall back gracefully
  });
}
