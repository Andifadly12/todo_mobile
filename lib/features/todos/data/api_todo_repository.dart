import '../../../core/network/api_client.dart';
import '../domain/todo_repository.dart';

class ApiTodoRepository implements TodoRepository {
  const ApiTodoRepository(this.api);
  final ApiClient api;
  Todo _parse(Map<String, dynamic> json) => Todo(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String? ?? '',
    status: json['status'] as String? ?? 'TODO',
    priority: json['priority'] as String? ?? 'MEDIUM',
    dueAt: DateTime.tryParse(json['dueAt'] as String? ?? '')?.toLocal(),
    reminderAt: DateTime.tryParse(json['reminderAt'] as String? ?? '')
        ?.toLocal(),
    completedAt: DateTime.tryParse(json['completedAt'] as String? ?? '')
        ?.toLocal(),
    categoryId: json['categoryId'] as String?,
  );
  @override
  Future<TodoPageData> list({required int page, String? status}) async {
    final query = Uri(
      queryParameters: {
        'page': '$page',
        'limit': '10',
        'status': ?status,
      },
    ).query;
    final data = await api.request('GET', 'todos?$query');
    final rows = data['data'] as List;
    final meta = data['meta'] as Map<String, dynamic>;
    return TodoPageData(
      rows.map((e) => _parse(e as Map<String, dynamic>)).toList(),
      meta['total'] as int,
      page < (meta['totalPages'] as int),
    );
  }

  @override
  Future<Todo> get(String id) async {
    final data = await api.request('GET', 'todos/$id');
    return _parse(
      (data['data'] ?? data['todo'] ?? data) as Map<String, dynamic>,
    );
  }

  @override
  Future<void> save(Map<String, dynamic> fields, {String? id}) async {
    await api.request(
      id == null ? 'POST' : 'PATCH',
      id == null ? 'todos' : 'todos/$id',
      fields,
    );
  }

  @override
  Future<void> delete(String id) async {
    await api.request('DELETE', 'todos/$id');
  }
}
