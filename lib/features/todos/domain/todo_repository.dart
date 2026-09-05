class Todo {
  const Todo({
    required this.id,
    required this.title,
    this.description = '',
    this.status = 'TODO',
    this.priority = 'MEDIUM',
    this.dueAt,
    this.reminderAt,
    this.completedAt,
    this.categoryId,
  });
  final String id, title, description, status, priority;
  final DateTime? dueAt, reminderAt, completedAt;
  final String? categoryId;
}

class TodoPageData {
  const TodoPageData(this.items, this.total, this.hasMore);
  final List<Todo> items;
  final int total;
  final bool hasMore;
}

abstract interface class TodoRepository {
  Future<TodoPageData> list({required int page, String? status});
  Future<Todo> get(String id);
  Future<void> save(Map<String, dynamic> fields, {String? id});
  Future<void> delete(String id);
}
