enum AuthAction { login, register, resetPassword }

class AuthRequest {
  const AuthRequest({
    required this.action,
    required this.email,
    this.password = '',
    this.username = '',
    this.age,
    this.role = 'USER',
  });
  final AuthAction action;
  final String email, password, username, role;
  final int? age;
}

abstract interface class AuthRepository {
  Future<String> submit(AuthRequest request);
}
