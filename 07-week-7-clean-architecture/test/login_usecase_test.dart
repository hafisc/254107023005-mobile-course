import 'package:flutter_test/flutter_test.dart';
import 'package:campus_notify/core/failures/failures.dart';
import 'package:campus_notify/features/auth/domain/entities/auth_session.dart';
import 'package:campus_notify/features/auth/domain/repositories/auth_repository.dart';
import 'package:campus_notify/features/auth/domain/usecases/login_usecase.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.fail = false});
  final bool fail;

  @override
  Future<({AuthSession? session, Failure? failure})> login({
    required String email,
    required String password,
  }) async {
    if (fail) {
      return (
        session: null,
        failure: const NetworkFailure('Invalid credentials (simulasi)'),
      );
    }
    return (
      session: const AuthSession(
        access: 'fake-access-token',
        refresh: 'fake-refresh-token',
      ),
      failure: null,
    );
  }

  @override
  Future<({String? token, Failure? failure})> refresh(String refreshToken) {
    throw UnimplementedError();
  }
}

void main() {
  test('LoginUseCase sukses mengembalikan session', () async {
    final repo = FakeAuthRepository();
    final usecase = LoginUseCase(repo);
    final result = await usecase.call(email: 'test@example.com', password: 'password123');
    
    expect(result.failure, isNull);
    expect(result.session, isNotNull);
    expect(result.session!.access, 'fake-access-token');
  });

  test('LoginUseCase gagal mengembalikan failure tanpa exception', () async {
    final repo = FakeAuthRepository(fail: true);
    final usecase = LoginUseCase(repo);
    final result = await usecase.call(email: 'test@example.com', password: 'wrong');
    
    expect(result.session, isNull);
    expect(result.failure, isA<NetworkFailure>());
    expect(result.failure!.message, 'Invalid credentials (simulasi)');
  });
}
