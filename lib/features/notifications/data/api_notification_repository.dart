import '../../../core/network/api_client.dart';
import '../domain/notification_repository.dart';

class ApiNotificationRepository implements NotificationRepository {
  const ApiNotificationRepository(this.api);
  final ApiClient api;
  @override
  Future<List<AppNotification>> list() async =>
      (await api.getList('notifications'))
          .map(
            (e) => AppNotification(
              id: e['id'] as String,
              title: e['title'] as String,
              message: e['message'] as String,
              isRead: e['isRead'] as bool,
            ),
          )
          .toList();
  @override
  Future<void> read(String? id) async {
    await api.request(
      'PATCH',
      id == null ? 'notifications/read-all' : 'notifications/$id/read',
    );
  }

  @override
  Future<void> delete(String id) async {
    await api.request('DELETE', 'notifications/$id');
  }
}
