import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_client.dart';
import '../domain/profile_repository.dart';

class ProfileState {
  const ProfileState({
    this.profile,
    this.loading = false,
    this.message,
    this.error = false,
  });
  final UserProfile? profile;
  final bool loading, error;
  final String? message;
}

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this.repository) : super(const ProfileState());
  final ProfileRepository repository;
  Future<void> load() => _run(() async {}, null);
  Future<void> save(String bio, String phone) => _run(
    () => repository.save(id: state.profile?.id, bio: bio, phone: phone),
    'Profile berhasil disimpan.',
  );
  Future<void> delete() => _run(() async {
    final id = state.profile?.id;
    if (id != null) await repository.delete(id);
  }, 'Bio dan nomor telepon telah dihapus.');
  Future<void> _run(Future<void> Function() action, String? message) async {
    if (state.loading) return;
    emit(ProfileState(profile: state.profile, loading: true));
    try {
      await action();
      final profile = await repository.getMe();
      if (!isClosed) emit(ProfileState(profile: profile, message: message));
    } catch (error) {
      if (!isClosed) {
        emit(
          ProfileState(
            profile: state.profile,
            error: true,
            message: error is ApiException
                ? error.message
                : 'Tidak dapat memuat profile. Coba lagi.',
          ),
        );
      }
    }
  }
}
