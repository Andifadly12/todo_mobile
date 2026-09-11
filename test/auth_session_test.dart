import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:todo_mobile/core/network/api_client.dart';
import 'package:todo_mobile/features/authentication/data/repositories/api_account_repository.dart';
void main() {
 test('Concurrent expired requests rotate refresh token once',() async {
  var refreshes=0;
  final api=ApiClient(baseUrl:'http://localhost:4000',client:MockClient((r) async {
   if(r.url.path=='/auth/refresh') {
    refreshes++;expect(jsonDecode(r.body),{'refreshToken':'old-refresh'});
    await Future<void>.delayed(const Duration(milliseconds:20));
    return http.Response('{"accessToken":"new-access","refreshToken":"new-refresh"}',200);
   }
   return r.headers['Authorization']=='Bearer old-access'?http.Response('{}',401):http.Response('{}',200);
  }))..setSession('old-access','old-refresh');addTearDown(api.close);
  await Future.wait([api.request('GET','profile/me'),api.request('GET','todos')]);
  expect(refreshes,1);expect(api.refreshToken,'new-refresh');expect(api.accessToken,'new-access');
 });
 test('Revoked refresh clears session without retry loop',() async {
  var count=0;
  final api=ApiClient(baseUrl:'http://localhost:4000',client:MockClient((r) async {count++;return http.Response('{}',401);}))..setSession('expired','revoked');addTearDown(api.close);
  await expectLater(api.request('GET','profile/me'),throwsA(isA<ApiException>()));
  expect(count,2);expect(api.accessToken,isNull);expect(api.refreshToken,isNull);
 });
 test('Logout revokes refresh and clears local session',() async {
  final api=ApiClient(baseUrl:'http://localhost:4000',client:MockClient((r) async {
   expect(r.url.path,'/auth/logout');expect(jsonDecode(r.body),{'refreshToken':'refresh'});return http.Response('{}',200);
  }))..setSession('access','refresh');addTearDown(api.close);
  await api.logout();expect(api.accessToken,isNull);expect(api.refreshToken,isNull);
 });
 test('Reset uses newPassword and token',() async {
  final api=ApiClient(baseUrl:'http://localhost:4000',client:MockClient((r) async {
   expect(r.url.path,'/auth/reset-password');expect(jsonDecode(r.body),{'token':'reset','newPassword':'password123'});
   return http.Response('{"message":"Password berhasil direset","resetToken":"private"}',200);
  }));addTearDown(api.close);
  expect(await ApiAccountRepository(api).execute('reset-password',{'token':'reset','newPassword':'password123'}),'Password berhasil direset');
 });
}
