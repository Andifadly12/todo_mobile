class UserProfile {
  const UserProfile({
    required this.username,
    required this.email,
    this.id,
    this.bio = '',
    this.phone = '',
  });
  final String username, email, bio, phone;
  final String? id;
}

abstract interface class ProfileRepository {
  Future<UserProfile> getMe();
  Future<void> save({String? id, required String bio, required String phone});
  Future<void> delete(String id);
}
