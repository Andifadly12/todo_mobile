import '../../../../core/network/api_client.dart';
import '../../domain/repositories/account_repository.dart';

class ApiAccountRepository implements AccountRepository {
  const ApiAccountRepository(this.api);
  final ApiClient api;
  @override
  Future<String> execute(String action, Map<String, String> fields) async {
    final response = await api.post('auth/$action', fields);
    return response['message'] as String? ?? 'Permintaan berhasil.';
  }
}
