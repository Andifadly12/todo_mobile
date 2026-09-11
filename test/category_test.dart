import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:todo_mobile/core/network/api_client.dart';
import 'package:todo_mobile/features/categories/data/api_category_repository.dart';
import 'package:todo_mobile/features/categories/presentation/category_cubit.dart';
import 'package:todo_mobile/features/categories/presentation/widgets/category_editor.dart';

void main() {
  test(
    'Category parses array and sends authenticated nullable color',
    () async {
      final api = ApiClient(
        baseUrl: 'http://localhost:4000',
        client: MockClient((r) async {
          expect(r.headers['Authorization'], 'Bearer token');
          if (r.method == 'GET') {
            return http.Response(
              '[{"id":"one","name":"Work","color":null}]',
              200,
            );
          }
          expect(r.method, 'PATCH');
          expect(r.url.path, '/categories/one');
          expect(jsonDecode(r.body), {'name': 'Work', 'color': null});
          return http.Response('{}', 200);
        }),
      )..accessToken = 'token';
      addTearDown(api.close);
      final repo = ApiCategoryRepository(api);
      expect((await repo.list()).single.name, 'Work');
      await repo.save(id: 'one', name: 'Work');
    },
  );
  test(
    'Duplicate failure preserves categories and reports server message',
    () async {
      final api = ApiClient(
        baseUrl: 'http://localhost:4000',
        client: MockClient(
          (r) async => r.method == 'GET'
              ? http.Response('[{"id":"one","name":"Work"}]', 200)
              : http.Response('{"message":"Kategori sudah ada"}', 409),
        ),
      );
      addTearDown(api.close);
      final cubit = CategoryCubit(ApiCategoryRepository(api));
      addTearDown(cubit.close);
      await cubit.load();
      expect(await cubit.save(name: 'Work'), false);
      expect(cubit.state.items.length, 1);
      expect(cubit.state.error, 'Kategori sudah ada');
      expect(cubit.state.busy, false);
    },
  );
  testWidgets('Category form rejects blank name', (tester) async {
    final api = ApiClient(
      baseUrl: 'http://localhost:4000',
      client: MockClient((_) async => http.Response('[]', 200)),
    );
    addTearDown(api.close);
    final cubit = CategoryCubit(ApiCategoryRepository(api));
    addTearDown(cubit.close);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: CategoryEditor(cubit: cubit)),
      ),
    );
    await tester.ensureVisible(find.text('Simpan kategori'));
    await tester.tap(find.text('Simpan kategori'));
    await tester.pumpAndSettle();
    expect(find.text('Nama kategori wajib diisi.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
