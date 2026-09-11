import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:todo_mobile/core/network/api_client.dart';
import 'package:todo_mobile/features/authentication/data/repositories/api_auth_repository.dart';
import 'package:todo_mobile/features/authentication/domain/exceptions/auth_exception.dart';
import 'package:todo_mobile/features/authentication/domain/repositories/auth_repository.dart';

void main() {
  test('Register sends profile JSON to port 4000', () async {
    final client = ApiClient(
      baseUrl: 'http://localhost:4000/',
      client: MockClient((request) async {
        if (request.url.path == '/auth/login') {
          return http.Response(
            '{"accessToken":"test-token","refreshToken":"test-refresh"}',
            200,
          );
        }
        expect(request.url.toString(), 'http://localhost:4000/auth/register');
        expect(request.method, 'POST');
        expect(jsonDecode(request.body), {
          'email': 'a@example.com',
          'password': 'password123',
          'username': 'andi',
          'umur': 23,
          'role': 'USER',
        });
        return http.Response('{"message":"Akun dibuat"}', 201);
      }),
    );
    addTearDown(client.close);
    expect(
      await ApiAuthRepository(client).submit(
        const AuthRequest(
          action: AuthAction.register,
          email: 'a@example.com',
          password: 'password123',
          username: 'andi',
          age: 23,
        ),
      ),
      'Akun dibuat',
    );
  });

  test('Login sends only credentials and preserves server error', () async {
    final client = ApiClient(
      baseUrl: 'http://localhost:4000',
      client: MockClient((request) async {
        expect(request.url.path, '/auth/login');
        expect(jsonDecode(request.body), {
          'email': 'a@example.com',
          'password': 'wrong',
        });
        return http.Response('{"message":"Email atau password salah"}', 401);
      }),
    );
    addTearDown(client.close);
    await expectLater(
      ApiAuthRepository(client).submit(
        const AuthRequest(
          action: AuthAction.login,
          email: 'a@example.com',
          password: 'wrong',
        ),
      ),
      throwsA(
        isA<AuthException>().having(
          (e) => e.message,
          'message',
          'Email atau password salah',
        ),
      ),
    );
  });

  test('Network failure gives actionable error', () async {
    final client = ApiClient(
      baseUrl: 'http://localhost:4000',
      client: MockClient((_) async {
        throw http.ClientException('offline');
      }),
    );
    addTearDown(client.close);
    await expectLater(
      ApiAuthRepository(client).submit(
        const AuthRequest(action: AuthAction.login, email: 'a@example.com'),
      ),
      throwsA(
        isA<AuthException>().having(
          (e) => e.message,
          'message',
          contains('Tidak dapat terhubung'),
        ),
      ),
    );
  });
}
