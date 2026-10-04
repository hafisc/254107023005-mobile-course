import '../../../../core/failures/failures.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<({AuthSession? session, Failure? failure})> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!email.contains('@') || password.length < 6) {
      return (session: null, failure: const NetworkFailure('Email atau kata sandi tidak valid'));
    }
    return (
      session: AuthSession(
        access: 'mock-access-for-$email',
        refresh: 'mock-refresh-for-$email',
      ),
      failure: null,
    );
  }

  @override
  Future<({String? token, Failure? failure})> refresh(String refreshToken) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (refreshToken.isEmpty) {
      return (token: null, failure: const NetworkFailure('Refresh token hilang'));
    }
    return (
      token: 'mock-access-renewed-${DateTime.now().millisecondsSinceEpoch}',
      failure: null,
    );
  }
}
