import '../../todos/domain/todo_repository.dart';

abstract interface class AiRepository {
  Future<Todo> parseTodo(String text);
}
