import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:todo_mobile/core/network/api_client.dart';
import 'package:todo_mobile/features/profile/data/api_profile_repository.dart';

void main() {
  test('Profile reads nested account and uses bearer token for mutations', () async {
    final paths = <String>[];
    final api = ApiClient(baseUrl: 'http://localhost:4000', client: MockClient((r) async {
      expect(r.headers['Authorization'], 'Bearer test-token');
      paths.add('${r.method} ${r.url.path}');
      if (r.method == 'GET') return http.Response('{"profile":{"username":"andi","email":"a@example.com","profile":{"id":"profile-id","bio":"Hello","phone":null}}}', 200);
      return http.Response('{}', 200);
    }))..accessToken = 'test-token';
    addTearDown(api.close);
    final repository = ApiProfileRepository(api);
    final me = await repository.getMe();
    expect(me.id, 'profile-id');
    expect(me.phone, '');
    await repository.save(id: me.id, bio: 'Updated', phone: '081234');
    await repository.delete(me.id!);
    await repository.save(bio: '', phone: '');
    expect(paths, ['GET /profile/me', 'PATCH /profile/profile-id', 'DELETE /profile/profile-id', 'POST /profile']);
  });
}
