import '../../../core/network/api_client.dart';
import '../../todos/domain/todo_repository.dart';
import '../domain/ai_repository.dart';

class ApiAiRepository implements AiRepository {
  const ApiAiRepository(this.api);
  final ApiClient api;
  @override
  Future<String> ask(String message) async {
    final response = await api.post('ai/ask', {'message': message});
    final answer = response['answer'];
    if (answer is! String || answer.trim().isEmpty) {
      throw const ApiException('Jawaban AI tidak valid. Silakan coba lagi.');
    }
    return answer;
  }

  @override
  Future<Todo> parseTodo(String text) async {
    final response = await api.post('ai/parse-todo', {'text': text});
    final data = response['draft'];
    if (data is! Map<String, dynamic> ||
        data['title'] is! String ||
        (data['title'] as String).trim().isEmpty ||
        (data['title'] as String).length > 120 ||
        ![
          'TODO',
          'IN_PROGRESS',
          'COMPLETED',
          'CANCELLED',
        ].contains(data['status']) ||
        !['LOW', 'MEDIUM', 'HIGH'].contains(data['priority']) ||
        (data['description'] != null && data['description'] is! String)) {
      throw const ApiException(
        'Draft AI tidak valid. Silakan coba dengan kalimat lain.',
      );
    }
    DateTime? date(String key) {
      final value = data[key];
      if (value == null) return null;
      final parsed = value is String ? DateTime.tryParse(value) : null;
      if (parsed == null) {
        throw const ApiException(
          'Tanggal dari AI tidak valid. Silakan coba lagi.',
        );
      }
      return parsed.toLocal();
    }

    return Todo(
      id: '',
      title: data['title'] as String,
      description: data['description'] as String? ?? '',
      status: data['status'] as String,
      priority: data['priority'] as String,
      dueAt: date('dueAt'),
      reminderAt: date('reminderAt'),
      completedAt: date('completedAt'),
    );
  }
}
