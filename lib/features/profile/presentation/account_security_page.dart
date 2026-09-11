import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_client.dart';
import '../../../core/widgets/atoms/primary_button.dart';
import '../../authentication/presentation/pages/auth_page.dart';

class AccountSecurityCubit extends Cubit<String?> {
  AccountSecurityCubit(this.api) : super(null);
  final ApiClient api;
  bool busy = false;
  Future<bool> submit(bool deleting, String current, String next) async {
    if (busy) return false;
    busy = true;
    emit('Memproses…');
    try {
      await api.request(
        deleting ? 'DELETE' : 'PATCH',
        deleting ? 'profile/account' : 'profile/password',
        deleting
            ? {'password': current}
            : {'currentPassword': current, 'newPassword': next},
      );
      api.clearSession();
      return true;
    } catch (e) {
      if (!isClosed) {
        emit(e is ApiException ? e.message : 'Permintaan gagal. Coba lagi.');
      }
      return false;
    } finally {
      busy = false;
    }
  }
}

class AccountSecurityPage extends StatelessWidget {
  const AccountSecurityPage({super.key, this.deleting = false});
  final bool deleting;
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) => AccountSecurityCubit(context.read<ApiClient>()),
    child: _Form(deleting: deleting),
  );
}

class _Form extends StatefulWidget {
  const _Form({required this.deleting});
  final bool deleting;
  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  final current = TextEditingController(),
      next = TextEditingController(),
      confirm = TextEditingController();
  final form = GlobalKey<FormState>();
  bool obscure = true;
  @override
  void dispose() {
    current.dispose();
    next.dispose();
    confirm.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<AccountSecurityCubit, String?>(
    builder: (context, message) {
      final cubit = context.read<AccountSecurityCubit>();
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.deleting ? 'Hapus akun' : 'Ubah password'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: form,
            child: Column(
              children: [
                Text(
                  widget.deleting
                      ? 'Akun beserta data terkait akan dihapus permanen. Masukkan password untuk melanjutkan.'
                      : 'Setelah password berubah, kamu perlu login kembali.',
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: current,
                  enabled: !cubit.busy,
                  obscureText: obscure,
                  decoration: InputDecoration(
                    labelText: 'Password saat ini',
                    suffixIcon: IconButton(
                      tooltip: 'Tampilkan/sembunyikan password',
                      onPressed: () => setState(() => obscure = !obscure),
                      icon: Icon(
                        obscure ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                  ),
                  validator: (v) =>
                      (v ?? '').isEmpty ? 'Password wajib diisi.' : null,
                ),
                if (!widget.deleting) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: next,
                    enabled: !cubit.busy,
                    obscureText: obscure,
                    decoration: const InputDecoration(
                      labelText: 'Password baru',
                    ),
                    validator: (v) =>
                        (v ?? '').length < 8 || (v ?? '').length > 100
                        ? 'Password harus 8–100 karakter.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: confirm,
                    enabled: !cubit.busy,
                    obscureText: obscure,
                    decoration: const InputDecoration(
                      labelText: 'Ulangi password baru',
                    ),
                    validator: (v) =>
                        v != next.text ? 'Password tidak sama.' : null,
                  ),
                ],
                const SizedBox(height: 20),
                if (message != null) Text(message),
                PrimaryButton(
                  label: widget.deleting
                      ? 'Hapus akun permanen'
                      : 'Ubah password',
                  loading: cubit.busy,
                  onPressed: () async {
                    if (!form.currentState!.validate()) return;
                    if (widget.deleting) {
                      final yes = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Hapus akun secara permanen?'),
                          content: const Text(
                            'Tindakan ini tidak dapat dibatalkan.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Batal'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Hapus permanen'),
                            ),
                          ],
                        ),
                      );
                      if (yes != true) return;
                    }
                    if (!context.mounted) return;
                    final ok = await cubit.submit(
                      widget.deleting,
                      current.text,
                      next.text,
                    );
                    if (ok && context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute<void>(
                          builder: (_) => const AuthPage(),
                        ),
                        (_) => false,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
