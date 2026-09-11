class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
  });
  final String id, title, message;
  final bool isRead;
}

abstract interface class NotificationRepository {
  Future<List<AppNotification>> list();
  Future<void> read(String? id);
  Future<void> delete(String id);
}
