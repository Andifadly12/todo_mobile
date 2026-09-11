import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_client.dart';
import '../domain/notification_repository.dart';

class NotificationState {
  const NotificationState({
    this.items = const [],
    this.busy = false,
    this.error,
  });
  final List<AppNotification> items;
  final bool busy;
  final String? error;
}

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit(this.repository) : super(const NotificationState());
  final NotificationRepository repository;
  Future<void> load() => _run(() async {});
  Future<void> read([String? id]) => _run(() => repository.read(id));
  Future<void> delete(String id) => _run(() => repository.delete(id));
  Future<void> _run(Future<void> Function() action) async {
    if (state.busy) return;
    emit(NotificationState(items: state.items, busy: true));
    try {
      await action();
      final items = await repository.list();
      if (!isClosed) emit(NotificationState(items: items));
    } catch (e) {
      if (!isClosed) {
        emit(
          NotificationState(
            items: state.items,
            error: e is ApiException
                ? e.message
                : 'Notifikasi belum dapat dimuat.',
          ),
        );
      }
    }
  }
}
