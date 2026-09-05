import '../../domain/repositories/auth_repository.dart';

/// Presentation demo only. Does not store credentials or contact a server.
class DemoAuthRepository implements AuthRepository {
  @override
  Future<String> submit(AuthRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    return switch (request.action) {
      AuthAction.login =>
        'Demo login berhasil. Integrasi server belum tersedia.',
      AuthAction.register =>
        'Form registrasi valid. Akun belum dibuat karena ini mode demo.',
      AuthAction.resetPassword =>
        'Email valid. Mode demo belum mengirim tautan reset password.',
    };
  }
}
