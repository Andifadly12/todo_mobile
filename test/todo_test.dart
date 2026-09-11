import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:todo_mobile/core/network/api_client.dart';
import 'package:todo_mobile/features/todos/data/api_todo_repository.dart';
import 'package:todo_mobile/features/todos/domain/todo_repository.dart';
import 'package:todo_mobile/features/todos/presentation/todo_cubit.dart';
import 'package:todo_mobile/features/todos/presentation/widgets/todo_editor.dart';

class FakeTodos implements TodoRepository {
  bool fail = false;
  @override
  Future<TodoPageData> list({
    required int page,
    String? status,
    String? search,
    String? priority,
    String? categoryId,
    bool? completed,
  }) async =>
      TodoPageData([Todo(id: '$page', title: 'Task $page')], 2, page == 1);
  @override
  Future<void> save(Map<String, dynamic> fields, {String? id}) async {
    if (fail) throw const ApiException('Server unavailable');
  }

  @override
  Future<void> delete(String id) async {}
  @override
  Future<Todo> get(String id) async => Todo(id: id, title: 'Task');
}

void main() {
  test(
    'Todo API sends authenticated filter and nullable date update',
    () async {
      final api = ApiClient(
        baseUrl: 'http://localhost:4000',
        client: MockClient((r) async {
          expect(r.headers['Authorization'], 'Bearer token');
          if (r.method == 'GET') {
            expect(r.url.queryParameters['status'], 'TODO');
            expect(r.url.queryParameters['page'], '2');
            return http.Response(
              '{"data":[{"id":"a","title":"Task","dueAt":null}],"meta":{"total":11,"totalPages":2}}',
              200,
            );
          }
          expect(r.method, 'PATCH');
          expect(r.url.path, '/todos/a');
          expect(jsonDecode(r.body), {'dueAt': null, 'status': 'COMPLETED'});
          return http.Response('{}', 200);
        }),
      )..accessToken = 'token';
      addTearDown(api.close);
      final repository = ApiTodoRepository(api);
      final result = await repository.list(page: 2, status: 'TODO');
      expect(result.total, 11);
      expect(result.hasMore, false);
      expect(result.items.single.dueAt, isNull);
      await repository.save({'dueAt': null, 'status': 'COMPLETED'}, id: 'a');
    },
  );
  test('Cubit appends pages and retains tasks on mutation failure', () async {
    final repo = FakeTodos();
    final cubit = TodoCubit(repo);
    addTearDown(cubit.close);
    await cubit.load();
    await cubit.load(more: true);
    expect(cubit.state.items.map((e) => e.id), ['1', '2']);
    repo.fail = true;
    expect(await cubit.save({'title': 'Fail'}), false);
    expect(cubit.state.items.length, 2);
    expect(cubit.state.error, 'Server unavailable');
    expect(cubit.state.busy, false);
  });
  testWidgets('Todo editor validates empty title', (tester) async {
    final cubit = TodoCubit(FakeTodos());
    addTearDown(cubit.close);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: TodoEditor(cubit: cubit)),
      ),
    );
    await tester.ensureVisible(find.text('Simpan tugas'));
    await tester.tap(find.text('Simpan tugas'));
    await tester.pumpAndSettle();
    expect(find.text('Judul wajib diisi.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
