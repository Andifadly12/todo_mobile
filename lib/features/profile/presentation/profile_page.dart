import '../../authentication/presentation/pages/account_page.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/atoms/primary_button.dart';
import '../../../core/widgets/molecules/labeled_field.dart';
import '../../authentication/presentation/pages/auth_page.dart';
import '../data/api_profile_repository.dart';
import 'profile_cubit.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) =>
        ProfileCubit(ApiProfileRepository(context.read<ApiClient>()))..load(),
    child: const _ProfileView(),
  );
}

class _ProfileView extends StatefulWidget {
  const _ProfileView();
  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  bool signingOut = false;
  Future<void> logout(bool all) async {
    setState(() => signingOut = true);
    try {
      await context.read<ApiClient>().logout(all: all);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const AuthPage()),
        (_) => false,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is ApiException ? e.message : 'Logout gagal. Coba lagi.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => signingOut = false);
    }
  }

  final bio = TextEditingController();
  final phone = TextEditingController();
  @override
  void dispose() {
    bio.dispose();
    phone.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocConsumer<ProfileCubit, ProfileState>(
    listener: (context, state) {
      if (!state.loading && !state.error && state.profile != null) {
        bio.text = state.profile!.bio;
        phone.text = state.profile!.phone;
      }
      if (state.message != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(state.message!)));
      }
    },
    builder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Profile saya'),
        actions: [
          IconButton(
            tooltip: 'Verifikasi email',
            icon: const Icon(Icons.mark_email_read_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const AccountPage(verification: true),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Keluar semua perangkat',
            icon: const Icon(Icons.devices),
            onPressed: signingOut
                ? null
                : () async {
                    final yes = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Keluar dari semua perangkat?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Keluar'),
                          ),
                        ],
                      ),
                    );
                    if (yes == true && mounted) await logout(true);
                  },
          ),
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout),
            onPressed: state.loading || signingOut ? null : () => logout(false),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  const Center(
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: AppColors.cream,
                      child: Icon(
                        Icons.person_outline,
                        size: 52,
                        color: AppColors.brown,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      state.profile?.username ?? 'Profile kamu',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      state.profile?.email ?? '',
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Ceritakan tentang dirimu.',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Lengkapi bio dan nomor teleponmu. Keduanya opsional.',
                  ),
                  const SizedBox(height: 24),
                  if (state.profile == null && state.loading)
                    const Center(child: CircularProgressIndicator()),
                  if (state.error)
                    TextButton.icon(
                      onPressed: state.loading
                          ? null
                          : context.read<ProfileCubit>().load,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba muat ulang'),
                    ),
                  if (state.profile != null) ...[
                    LabeledField(
                      label: 'Bio',
                      hint: 'Sedikit cerita tentang kamu',
                      controller: bio,
                      icon: Icons.edit_note,
                      enabled: !state.loading,
                    ),
                    LabeledField(
                      label: 'Nomor telepon',
                      hint: '08xxxxxxxxxx',
                      controller: phone,
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      enabled: !state.loading,
                    ),
                    PrimaryButton(
                      label: 'Simpan profile',
                      loading: state.loading,
                      onPressed: () => context.read<ProfileCubit>().save(
                        bio.text.trim(),
                        phone.text.trim(),
                      ),
                    ),
                    if (state.profile?.id != null)
                      Center(
                        child: TextButton(
                          onPressed: state.loading
                              ? null
                              : () async {
                                  final cubit = context.read<ProfileCubit>();
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Hapus data profile?'),
                                      content: const Text(
                                        'Bio dan nomor telepon akan dihapus. Akunmu tetap ada.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Batal'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Hapus'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirmed == true && !cubit.isClosed) {
                                    cubit.delete();
                                  }
                                },
                          child: const Text('Hapus data profile'),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
