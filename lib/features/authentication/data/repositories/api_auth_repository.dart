import '../../../../core/network/api_client.dart';
import '../../domain/exceptions/auth_exception.dart';
import '../../domain/repositories/auth_repository.dart';

class ApiAuthRepository implements AuthRepository {
  const ApiAuthRepository(this._api);
  final ApiClient _api;

  @override
  Future<String> submit(AuthRequest request) async {
    final register = request.action == AuthAction.register;
    try {
      if (request.action == AuthAction.resetPassword) {
        final result = await _api.post('auth/forgot-password', {
          'email': request.email,
        });
        return result['message'] as String? ??
            'Instruksi reset password telah dibuat.';
      }
      final data = await _api.post(register ? 'auth/register' : 'auth/login', {
        'email': request.email,
        'password': request.password,
        if (register) ...{
          'username': request.username,
          'umur': request.age,
          'role': request.role,
        },
      });
      final session = register
          ? await _api.post('auth/login', {
              'email': request.email,
              'password': request.password,
            })
          : data;
      final token = session['accessToken'];
      if (token is! String || token.isEmpty) {
        throw const AuthException(
          'Token login tidak tersedia. Silakan login kembali.',
        );
      }
      final refresh = session['refreshToken'];
      if (refresh is! String || refresh.isEmpty) {
        throw const AuthException(
          'Refresh token tidak tersedia. Silakan login kembali.',
        );
      }
      _api.setSession(token, refresh);
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
