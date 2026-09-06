import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_client.dart';
import '../../todos/domain/todo_repository.dart';
import '../domain/ai_repository.dart';

class AiState {
  const AiState({this.loading = false, this.draft, this.error});
  final bool loading;
  final Todo? draft;
  final String? error;
}

class AiCubit extends Cubit<AiState> {
  AiCubit(this.repository) : super(const AiState());
  final AiRepository repository;
  Future<void> generate(String text) async {
    if (state.loading) return;
    final input = text.trim();
    if (input.isEmpty || input.length > 1000) {
      emit(const AiState(error: 'Isi rencana antara 1–1.000 karakter.'));
      return;
    }
    emit(const AiState(loading: true));
    try {
      final draft = await repository.parseTodo(input);
      if (!isClosed) emit(AiState(draft: draft));
    } catch (e) {
      if (!isClosed) {
        emit(
          AiState(
            error: e is ApiException
                ? e.message
                : 'AI belum dapat membuat draft. Silakan coba lagi.',
          ),
        );
      }
    }
  }
}
