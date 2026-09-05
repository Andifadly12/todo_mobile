import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_client.dart';
import '../domain/todo_repository.dart';

class TodoState {
  const TodoState({
    this.items = const [],
    this.busy = false,
    this.status,
    this.page = 1,
    this.total = 0,
    this.hasMore = false,
    this.error,
  });
  final List<Todo> items;
  final bool busy, hasMore;
  final int page, total;
  final String? status, error;
}

class TodoCubit extends Cubit<TodoState> {
  TodoCubit(this.repository) : super(const TodoState());
  final TodoRepository repository;
  Future<void> load({String? status, bool more = false}) async {
    if (state.busy) return;
    final old = state;
    final filter = more ? old.status : status;
    final page = more ? old.page + 1 : 1;
    emit(
      TodoState(
        items: old.items,
        busy: true,
        status: filter,
        page: old.page,
        total: old.total,
        hasMore: old.hasMore,
      ),
    );
    try {
      final result = await repository.list(page: page, status: filter);
      if (!isClosed) {
        emit(
          TodoState(
            items: [if (more) ...old.items, ...result.items],
            status: filter,
            page: page,
            total: result.total,
            hasMore: result.hasMore,
          ),
        );
      }
    } catch (e) {
      if (!isClosed) {
        emit(
          TodoState(
            items: old.items,
            status: old.status,
            page: old.page,
            total: old.total,
            hasMore: old.hasMore,
            error: _message(e),
          ),
        );
      }
    }
  }

  String _message(Object e) => e is ApiException
      ? e.message
      : 'Tugas belum dapat dimuat. Silakan coba lagi.';
  Future<bool> save(Map<String, dynamic> fields, {String? id}) =>
      _mutate(() => repository.save(fields, id: id));
  Future<bool> remove(String id) => _mutate(() => repository.delete(id));
  Future<bool> _mutate(Future<void> Function() action) async {
    if (state.busy) return false;
    final old = state;
    emit(
      TodoState(
        items: old.items,
        busy: true,
        status: old.status,
        total: old.total,
        page: old.page,
        hasMore: old.hasMore,
      ),
    );
    try {
      await action();
      if (isClosed) return true;
      emit(TodoState(items: old.items, status: old.status));
      await load(status: old.status);
      return true;
    } catch (e) {
      if (!isClosed) {
        emit(
          TodoState(
            items: old.items,
            status: old.status,
            total: old.total,
            page: old.page,
            hasMore: old.hasMore,
            error: _message(e),
          ),
        );
      }
      return false;
    }
  }
}
