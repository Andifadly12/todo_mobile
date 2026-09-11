import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:todo_mobile/core/network/api_client.dart';
import 'package:todo_mobile/features/notifications/data/api_notification_repository.dart';
import 'package:todo_mobile/features/profile/presentation/account_security_page.dart';
import 'package:todo_mobile/features/todos/data/api_todo_repository.dart';
void main(){
 test('Notification list and read actions use backend routes',() async {
 final paths=<String>[];
 final api=ApiClient(baseUrl:'http://localhost',client:MockClient((r) async {
 paths.add('${r.method} ${r.url.path}');
 return http.Response(r.method=='GET'?'[{"id":"n","title":"Reminder","message":"Do it","isRead":false}]':'{}',200);
 }));addTearDown(api.close);final repo=ApiNotificationRepository(api);
 expect((await repo.list()).single.isRead,false);await repo.read('n');await repo.read(null);await repo.delete('n');
 expect(paths,['GET /notifications','PATCH /notifications/n/read','PATCH /notifications/read-all','DELETE /notifications/n']);
 });
 test('Password change sends current and new password and clears session',() async {
 final api=ApiClient(baseUrl:'http://localhost',client:MockClient((r) async {
 expect(r.method,'PATCH');expect(r.url.path,'/profile/password');expect(jsonDecode(r.body),{'currentPassword':'old','newPassword':'newpassword'});return http.Response('{}',200);
 }))..setSession('access','refresh');addTearDown(api.close);
 final cubit=AccountSecurityCubit(api);addTearDown(cubit.close);
 expect(await cubit.submit(false,'old','newpassword'),true);expect(api.refreshToken,isNull);
 });
 test('Todo filters serialize search category priority and false completed',() async {
 final api=ApiClient(baseUrl:'http://localhost',client:MockClient((r) async {
 expect(r.url.queryParameters,{'page':'1','limit':'10','search':'hello world','priority':'HIGH','categoryId':'id','completed':'false'});
 return http.Response('{"data":[],"meta":{"total":0,"totalPages":0}}',200);
 }));addTearDown(api.close);
 await ApiTodoRepository(api).list(page:1,search:'hello world',priority:'HIGH',categoryId:'id',completed:false);
 });
 test('Exception filter envelope preserves conflict message and status',() async {
 final api=ApiClient(baseUrl:'http://localhost',client:MockClient((_) async=>http.Response('{"statusCode":409,"timestamp":"now","path":"/categories","message":"Nama kategori sudah digunakan"}',409)));addTearDown(api.close);
 await expectLater(api.post('categories',{'name':'Work'}),throwsA(isA<ApiException>().having((e)=>e.statusCode,'status',409).having((e)=>e.message,'message','Nama kategori sudah digunakan')));
 });
}
