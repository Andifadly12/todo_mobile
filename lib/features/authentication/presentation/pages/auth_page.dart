import '../../../profile/presentation/profile_page.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/atoms/primary_button.dart';
import '../../../../core/widgets/molecules/labeled_field.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/submit_auth.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/auth_shell.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key, this.action = AuthAction.login});
  final AuthAction action;
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) => AuthCubit(SubmitAuth(context.read<AuthRepository>())),
    child: _AuthForm(action: action),
  );
}

class _AuthForm extends StatefulWidget {
  const _AuthForm({required this.action});
  final AuthAction action;
  @override
  State<_AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<_AuthForm> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _username = TextEditingController();
  final _age = TextEditingController();
  String _role = 'USER';
  bool get _register => widget.action == AuthAction.register;
  bool get _reset => widget.action == AuthAction.resetPassword;

  @override
  void dispose() {
    for (final controller in [_email, _password, _username, _age]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _navigate(AuthAction action) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => AuthPage(action: action)));
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<AuthCubit>().submit(
      AuthRequest(
        action: widget.action,
        email: _email.text.trim(),
        password: _password.text,
        username: _username.text.trim(),
        age: int.tryParse(_age.text),
        role: _role,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<AuthCubit, AuthState>(
    listenWhen: (previous, current) => previous.status != current.status,
    listener: (context, state) {
      if (state.status == AuthStatus.success && !_reset) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => const ProfilePage()),
          (_) => false,
        );
        return;
      }
      if (state.message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message!),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    },
    builder: (context, state) {
      final loading = state.status == AuthStatus.loading;
      return AuthShell(
        child: AutofillGroup(
          child: Form(
            key: _form,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: AppColors.cream,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.spa_outlined,
                        color: AppColors.brown,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'ruang.',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'MULAI DARI DIRIMU',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.4,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 36),
                if (_register || _reset) ...[
                  TextButton.icon(
                    onPressed: loading ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, size: 18),
                    label: const Text('Kembali ke login'),
                  ),
                  const SizedBox(height: 16),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _register
                        ? 'AWAL CERITA BARU'
                        : _reset
                        ? 'KAMI BANTU, YA'
                        : 'SENANG BERTEMU LAGI',
                    style: const TextStyle(
                      fontSize: 10,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brown,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  _register
                      ? 'Buat akunmu.'
                      : _reset
                      ? 'Lupa password?'
                      : 'Selamat datang\nkembali.',
                  style: const TextStyle(
                    fontSize: 36,
                    height: 1.15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _register
                      ? 'Satu langkah kecil untuk hari yang lebih tertata.'
                      : _reset
                      ? 'Masukkan email yang terhubung dengan akunmu.'
                      : 'Masuk dan lanjutkan hal-hal baik yang kamu mulai.',
                  style: const TextStyle(color: AppColors.muted, height: 1.6),
                ),
                const SizedBox(height: 30),
                if (_register) ...[
                  LabeledField(
                    label: 'Username',
                    hint: 'Nama panggilanmu',
                    controller: _username,
                    icon: Icons.person_outline,
                    enabled: !loading,
                    autofillHints: const [AutofillHints.username],
                    validator: (value) => (value ?? '').trim().length < 3
                        ? 'Username minimal 3 karakter.'
                        : (value ?? '').trim().length > 20
                        ? 'Username maksimal 20 karakter.'
                        : null,
                  ),
                  LabeledField(
                    label: 'Umur',
                    hint: 'Masukkan umur',
                    controller: _age,
                    icon: Icons.cake_outlined,
                    keyboardType: TextInputType.number,
                    enabled: !loading,
                    validator: (value) {
                      final age = int.tryParse(value ?? '');
                      return age == null || age < 1 || age > 120
                          ? 'Masukkan umur antara 1–120 tahun.'
                          : null;
                    },
                  ),
                ],
                LabeledField(
                  label: 'Email',
                  hint: 'nama@email.com',
                  controller: _email,
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !loading,
                  autofillHints: const [AutofillHints.email],
                  validator: (value) =>
                      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                          .hasMatch((value ?? '').trim())
                      ? null
                      : 'Masukkan alamat email yang valid.',
                ),
                if (_register) ...[
                  const Text(
                    'Role',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 9),
                  DropdownButtonFormField<String>(
                    initialValue: _role,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    items: const ['USER']
                        .map(
                          (role) =>
                              DropdownMenuItem(value: role, child: Text(role)),
                        )
                        .toList(),
                    onChanged: loading
                        ? null
                        : (value) => setState(() => _role = value!),
                  ),
                  const SizedBox(height: 18),
                ],
                if (!_reset)
                  LabeledField(
                    label: 'Password',
                    hint: _register
                        ? 'Buat password (min. 8 karakter)'
                        : 'Masukkan password',
                    controller: _password,
                    icon: Icons.lock_outline_rounded,
                    keyboardType: TextInputType.visiblePassword,
                    enabled: !loading,
                    autofillHints: [
                      _register
                          ? AutofillHints.newPassword
                          : AutofillHints.password,
                    ],
                    obscureText: state.obscurePassword,
                    suffix: IconButton(
                      onPressed: context.read<AuthCubit>().togglePassword,
                      tooltip: state.obscurePassword
                          ? 'Tampilkan password'
                          : 'Sembunyikan password',
                      icon: Icon(
                        state.obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                    validator: (value) => (value ?? '').isEmpty
                        ? 'Password wajib diisi.'
                        : _register && value!.length < 8
                        ? 'Password minimal 8 karakter.'
                        : null,
                  ),
                if (!_register && !_reset)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: loading
                          ? null
                          : () => _navigate(AuthAction.resetPassword),
                      child: const Text('Lupa password?'),
                    ),
                  ),
                const SizedBox(height: 12),
                PrimaryButton(
                  label: _register
                      ? 'Buat akun'
                      : _reset
                      ? 'Kirim tautan reset'
                      : 'Masuk',
                  onPressed: _submit,
                  loading: loading,
                ),
                const SizedBox(height: 22),
                if (!_reset)
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          _register ? 'Sudah punya akun?' : 'Belum punya akun?',
                          style: const TextStyle(color: AppColors.muted),
                        ),
                        TextButton(
                          onPressed: loading
                              ? null
                              : () {
                                  if (_register) {
                                    Navigator.pop(context);
                                  } else {
                                    _navigate(AuthAction.register);
                                  }
                                },
                          child: Text(
                            _register ? 'Masuk di sini' : 'Daftar sekarang',
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                const Center(
                  child: Text(
                    'LANGKAH KECIL, HARI YANG LEBIH BAIK',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1,
                      color: AppColors.muted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
