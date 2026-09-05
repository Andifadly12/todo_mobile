import '../repositories/auth_repository.dart';

class SubmitAuth {
  const SubmitAuth(this.repository);
  final AuthRepository repository;
  Future<String> call(AuthRequest request) => repository.submit(request);
}
