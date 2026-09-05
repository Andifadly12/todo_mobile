import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/exceptions/auth_exception.dart';
import '../../domain/usecases/submit_auth.dart';

enum AuthStatus { idle, loading, success, failure }

class AuthState {
  const AuthState({
    this.obscurePassword = true,
    this.status = AuthStatus.idle,
    this.message,
  });
  final bool obscurePassword;
  final AuthStatus status;
  final String? message;
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._submit) : super(const AuthState());
  final SubmitAuth _submit;
  void togglePassword() => emit(
    AuthState(
      obscurePassword: !state.obscurePassword,
      status: state.status,
      message: state.message,
    ),
  );
  Future<void> submit(AuthRequest request) async {
    if (state.status == AuthStatus.loading) return;
    emit(
      AuthState(
        obscurePassword: state.obscurePassword,
        status: AuthStatus.loading,
      ),
    );
    try {
      final message = await _submit(request);
      if (!isClosed) {
        emit(
          AuthState(
            obscurePassword: state.obscurePassword,
            status: AuthStatus.success,
            message: message,
          ),
        );
      }
    } catch (error) {
      if (!isClosed) {
        emit(
          AuthState(
            obscurePassword: state.obscurePassword,
            status: AuthStatus.failure,
            message: error is AuthException
                ? error.message
                : 'Terjadi kesalahan. Silakan coba lagi.',
          ),
        );
      }
    }
  }
}
