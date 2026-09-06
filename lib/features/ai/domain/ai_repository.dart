import '../../todos/domain/todo_repository.dart';

abstract interface class AiRepository {
  Future<String> ask(String message);
  Future<Todo> parseTodo(String text);
}
