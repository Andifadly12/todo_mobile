import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/atoms/primary_button.dart';
import '../../../../core/widgets/molecules/labeled_field.dart';
import '../../data/repositories/api_account_repository.dart';
import '../cubit/account_cubit.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key, this.verification = false});
  final bool verification;
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) =>
        AccountCubit(ApiAccountRepository(context.read<ApiClient>())),
    child: _AccountForm(verification: verification),
  );
}

class _AccountForm extends StatefulWidget {
  const _AccountForm({required this.verification});
  final bool verification;
  @override
  State<_AccountForm> createState() => _AccountFormState();
}

class _AccountFormState extends State<_AccountForm> {
  final email = TextEditingController(),
      token = TextEditingController(),
      password = TextEditingController();
  final form = GlobalKey<FormState>();
  bool useToken = false, obscure = true;
  @override
  void dispose() {
    email.dispose();
    token.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<AccountCubit, AccountState>(
    builder: (context, state) => Scaffold(
      appBar: AppBar(
        title: Text(
          widget.verification ? 'Verifikasi email' : 'Pulihkan password',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  useToken
                      ? 'Masukkan token yang kamu terima.'
                      : 'Masukkan email akunmu.',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                if (!useToken)
                  LabeledField(
                    label: 'Email',
                    hint: 'nama@email.com',
                    controller: email,
                    icon: Icons.mail_outline,
                    enabled: !state.busy,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) =>
                        RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                            .hasMatch((v ?? '').trim())
                        ? null
                        : 'Email tidak valid.',
                  ),
                if (useToken)
                  LabeledField(
                    label: 'Token',
                    hint: 'Token pemulihan atau verifikasi',
                    controller: token,
                    icon: Icons.key,
                    enabled: !state.busy,
                    validator: (v) =>
                        (v ?? '').trim().isEmpty ? 'Token wajib diisi.' : null,
                  ),
                if (useToken && !widget.verification)
                  LabeledField(
                    label: 'Password baru',
                    hint: '8–100 karakter',
                    controller: password,
                    icon: Icons.lock_outline,
                    enabled: !state.busy,
                    obscureText: obscure,
                    keyboardType: TextInputType.visiblePassword,
                    suffix: IconButton(
                      tooltip: obscure
                          ? 'Tampilkan password'
                          : 'Sembunyikan password',
                      onPressed: () => setState(() => obscure = !obscure),
                      icon: Icon(
                        obscure ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                    validator: (v) =>
                        (v ?? '').length < 8 || (v ?? '').length > 100
                        ? 'Password harus 8–100 karakter.'
                        : null,
                  ),
                if (state.message != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(state.message!),
                  ),
                PrimaryButton(
                  label: useToken
                      ? (widget.verification
                            ? 'Verifikasi email'
                            : 'Simpan password baru')
                      : 'Minta instruksi',
                  loading: state.busy,
                  onPressed: () {
                    if (!form.currentState!.validate()) return;
                    final action = widget.verification
                        ? (useToken ? 'verify-email' : 'resend-verification')
                        : (useToken ? 'reset-password' : 'forgot-password');
                    context.read<AccountCubit>().submit(
                      action,
                      useToken
                          ? {
                              'token': token.text.trim(),
                              if (!widget.verification)
                                'newPassword': password.text,
                            }
                          : {'email': email.text.trim()},
                    );
                  },
                ),
                TextButton(
                  onPressed: state.busy
                      ? null
                      : () => setState(() => useToken = !useToken),
                  child: Text(
                    useToken ? 'Minta instruksi lagi' : 'Sudah punya token',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
