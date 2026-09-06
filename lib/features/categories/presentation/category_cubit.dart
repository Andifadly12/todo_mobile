import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_client.dart';
import '../domain/category_repository.dart';

class CategoryState {
  const CategoryState({this.items = const [], this.busy = false, this.error});
  final List<Category> items;
  final bool busy;
  final String? error;
}

class CategoryCubit extends Cubit<CategoryState> {
  CategoryCubit(this.repository) : super(const CategoryState());
  final CategoryRepository repository;
  Future<void> load() async {
    await _run(() async {});
  }

  Future<bool> save({String? id, required String name, String? color}) =>
      _run(() => repository.save(id: id, name: name, color: color));
  Future<bool> delete(String id) => _run(() => repository.delete(id));
  Future<bool> _run(Future<void> Function() action) async {
    if (state.busy) return false;
    emit(CategoryState(items: state.items, busy: true));
    try {
      await action();
      final items = await repository.list();
      if (!isClosed) emit(CategoryState(items: items));
      return true;
    } catch (e) {
      if (!isClosed) {
        emit(
          CategoryState(
            items: state.items,
            error: e is ApiException
                ? e.message
                : 'Kategori belum dapat dimuat. Coba lagi.',
          ),
        );
      }
      return false;
    }
  }
}
