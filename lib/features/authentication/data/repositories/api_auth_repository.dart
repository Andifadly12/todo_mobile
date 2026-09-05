import '../../../../core/network/api_client.dart';
import '../../domain/exceptions/auth_exception.dart';
import '../../domain/repositories/auth_repository.dart';

class ApiAuthRepository implements AuthRepository {
  const ApiAuthRepository(this._api);
  final ApiClient _api;

  @override
  Future<String> submit(AuthRequest request) async {
    if (request.action == AuthAction.resetPassword) {
      throw const AuthException(
        'Lupa password belum tersedia. Endpoint reset belum dikonfigurasi.',
      );
    }
    final register = request.action == AuthAction.register;
    try {
      final data = await _api.post(register ? 'auth/register' : 'auth/login', {
        'email': request.email,
        'password': request.password,
        if (register) ...{
          'username': request.username,
          'umur': request.age,
          'role': request.role,
        },
      });
      final message = data['message'];
      return message is String && message.isNotEmpty
          ? message
          : register
          ? 'Registrasi berhasil. Silakan masuk.'
          : 'Login berhasil.';
    } on ApiException catch (error) {
      throw AuthException(error.message);
    }
  }
}
