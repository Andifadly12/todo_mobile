import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_client.dart';
import '../domain/ai_repository.dart';

class AskAiState {
  const AskAiState({
    this.loading = false,
    this.answer,
    this.question,
    this.error,
  });
  final bool loading;
  final String? answer, question, error;
}

class AskAiCubit extends Cubit<AskAiState> {
  AskAiCubit(this.repository) : super(const AskAiState());
  final AiRepository repository;
  Future<void> ask(String message) async {
    if (state.loading) return;
    final input = message.trim();
    if (input.isEmpty || input.length > 4000) {
      emit(
        AskAiState(
          answer: state.answer,
          question: state.question,
          error: 'Pertanyaan wajib diisi, maksimal 4.000 karakter.',
        ),
      );
      return;
    }
    final old = state;
    emit(AskAiState(loading: true, answer: old.answer, question: old.question));
    try {
      final answer = await repository.ask(input);
      if (!isClosed) emit(AskAiState(answer: answer, question: input));
    } catch (e) {
      if (!isClosed) {
        emit(
          AskAiState(
            answer: old.answer,
            question: old.question,
            error: e is ApiException
                ? e.message
                : 'AI belum dapat menjawab. Silakan coba lagi.',
          ),
        );
      }
    }
  }
}
