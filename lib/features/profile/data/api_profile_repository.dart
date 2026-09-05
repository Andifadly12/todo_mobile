import '../../../core/network/api_client.dart';
import '../domain/profile_repository.dart';

class ApiProfileRepository implements ProfileRepository {
  const ApiProfileRepository(this.api);
  final ApiClient api;
  @override
  Future<UserProfile> getMe() async {
    final data = await api.request('GET', 'profile/me');
    final user = data['profile'];
    if (user is! Map<String, dynamic>) {
      throw const ApiException('Format profile tidak sesuai.');
    }
    final profile = user['profile'] as Map<String, dynamic>?;
    return UserProfile(
      username: user['username'] as String? ?? '',
      email: user['email'] as String? ?? '',
      id: profile?['id'] as String?,
      bio: profile?['bio'] as String? ?? '',
      phone: profile?['phone'] as String? ?? '',
    );
  }

  @override
  Future<void> save({
    String? id,
    required String bio,
    required String phone,
  }) async {
    await api.request(
      id == null ? 'POST' : 'PATCH',
      id == null ? 'profile' : 'profile/$id',
      {'bio': bio, 'phone': phone},
    );
  }

  @override
  Future<void> delete(String id) async {
    await api.request('DELETE', 'profile/$id');
  }
}
