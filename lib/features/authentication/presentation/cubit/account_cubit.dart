import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_client.dart';
import '../../domain/repositories/account_repository.dart';

class AccountState {
  const AccountState({this.busy = false, this.message, this.success = false});
  final bool busy, success;
  final String? message;
}

class AccountCubit extends Cubit<AccountState> {
  AccountCubit(this.repository) : super(const AccountState());
  final AccountRepository repository;
  Future<void> submit(String action, Map<String, String> fields) async {
    if (state.busy) return;
    emit(const AccountState(busy: true));
    try {
      final message = await repository.execute(action, fields);
      if (!isClosed) emit(AccountState(message: message, success: true));
    } catch (e) {
      if (!isClosed) {
        emit(
          AccountState(
            message: e is ApiException
                ? e.message
                : 'Permintaan gagal. Silakan coba lagi.',
          ),
        );
      }
    }
  }
}
