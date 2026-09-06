import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:todo_mobile/core/network/api_client.dart';
import 'package:todo_mobile/features/ai/data/api_ai_repository.dart';
import 'package:todo_mobile/features/ai/presentation/ai_cubit.dart';

void main() {
  test('Ask sends message and reads answer with JWT', () async {
    final api = ApiClient(
      baseUrl: 'http://localhost:4000',
      client: MockClient((r) async {
        expect(r.url.path, '/ai/ask');
        expect(r.headers['Authorization'], 'Bearer token');
        expect(jsonDecode(r.body), {'message': 'Bagaimana mulai?'});
        return http.Response('{"answer":"Mulai dari satu tugas kecil."}', 200);
      }),
    )..accessToken = 'token';
    addTearDown(api.close);
    expect(
      await ApiAiRepository(api).ask('Bagaimana mulai?'),
      'Mulai dari satu tugas kecil.',
    );
  });
  test('Ask rejects empty server answer', () async {
    final api = ApiClient(
      baseUrl: 'http://localhost:4000',
      client: MockClient((_) async => http.Response('{"answer":""}', 200)),
    );
    addTearDown(api.close);
    await expectLater(
      ApiAiRepository(api).ask('Halo'),
      throwsA(isA<ApiException>()),
    );
  });

  test('AI sends JWT and maps draft without saving a Todo', () async {
    var requests = 0;
    final api = ApiClient(
      baseUrl: 'http://localhost:4000',
      client: MockClient((r) async {
        requests++;
        expect(r.url.path, '/ai/parse-todo');
        expect(r.method, 'POST');
        expect(r.headers['Authorization'], 'Bearer token');
        expect(jsonDecode(r.body), {'text': 'Baca buku'});
        return http.Response(
          jsonEncode({
            'draft': {
              'title': 'Baca buku',
              'description': null,
              'status': 'TODO',
              'priority': 'LOW',
              'dueAt': null,
              'reminderAt': null,
              'completedAt': null,
            },
          }),
          200,
        );
      }),
    )..accessToken = 'token';
    addTearDown(api.close);
    final cubit = AiCubit(ApiAiRepository(api));
    addTearDown(cubit.close);
    await cubit.generate(' Baca buku ');
    expect(cubit.state.draft!.title, 'Baca buku');
    expect(requests, 1);
  });
  test('Invalid input and malformed draft do not succeed', () async {
    var requests = 0;
    final api = ApiClient(
      baseUrl: 'http://localhost:4000',
      client: MockClient((r) async {
        requests++;
        return http.Response('{"draft":{"title":"Bad"}}', 200);
      }),
    );
    addTearDown(api.close);
    final cubit = AiCubit(ApiAiRepository(api));
    addTearDown(cubit.close);
    await cubit.generate(' ');
    expect(requests, 0);
    expect(cubit.state.error, isNotNull);
    await cubit.generate('Baca');
    expect(cubit.state.draft, isNull);
    expect(cubit.state.error, isNotNull);
    expect(cubit.state.loading, false);
  });
}
