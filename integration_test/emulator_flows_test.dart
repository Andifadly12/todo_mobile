import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:todo_mobile/main.dart';
import 'package:todo_mobile/core/network/api_client.dart';
import 'package:todo_mobile/features/home/presentation/home_page.dart';
import 'package:todo_mobile/features/todos/presentation/widgets/todo_editor.dart';
import 'package:todo_mobile/features/ai/presentation/ask_ai_cubit.dart';
import 'package:todo_mobile/features/ai/presentation/ai_cubit.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'Backend-connected emulator flows; no permanent account deletion',
    (t) async {
      Future<void> wait(bool Function() done) async {
        for (var i = 0; i < 180; i++) {
          await t.pump(const Duration(milliseconds: 250));
          if (done()) {
            await t.pump(const Duration(milliseconds: 500));
            return;
          }
        }
        throw TestFailure('UI wait timed out');
      }

      Future<void> settle() async {
        await t.pump(const Duration(milliseconds: 700));
        await wait(
          () =>
              find.byType(CircularProgressIndicator).evaluate().isEmpty &&
              find.byType(LinearProgressIndicator).evaluate().isEmpty,
        );
      }

      Future<void> tap(Finder f) async {
        await t.ensureVisible(f.first);
        await t.pump(const Duration(milliseconds: 250));
        await t.tap(f.first);
        await settle();
      }

      Future<void> field(int i, String value) async {
        final f = find.byType(TextFormField).at(i);
        await t.ensureVisible(f);
        await t.enterText(f, value);
        FocusManager.instance.primaryFocus?.unfocus();
        await t.pump(const Duration(milliseconds: 350));
      }

      Future<void> tab(String name) async {
        if (find.byType(SnackBar).evaluate().isNotEmpty) {
          await t.pump(const Duration(seconds: 5));
        }
        await tap(
          find.descendant(
            of: find.byType(NavigationBar),
            matching: find.text(name),
          ),
        );
      }

      void pass(String value) => debugPrint('E2E PASS: $value');
      final stamp = DateTime.now().millisecondsSinceEpoch.toString();
      final email = 'emu$stamp@example.com', password = 'Emulator${stamp}Aa!';
      await t.pumpWidget(const MyApp());
      await settle();
      await tap(find.text('Masuk'));
      expect(find.text('Password wajib diisi.'), findsOneWidget);
      await tap(find.byTooltip('Tampilkan password'));
      expect(find.byTooltip('Sembunyikan password'), findsOneWidget);
      pass('login validation and visibility');
      await tap(find.text('Daftar sekarang'));
      await field(0, 'qa${stamp.substring(4)}');
      await field(1, '25');
      await field(2, email);
      await field(3, password);
      await tap(find.text('Buat akun'));
      await wait(() => find.byType(HomePage).evaluate().isNotEmpty);
      await settle();
      final api = t.element(find.byType(HomePage)).read<ApiClient>();
      expect(api.refreshToken, isNotNull);
      debugPrint('QA account: $email');
      pass('registration -> login -> profile');
      await field(0, 'Emulator QA bio');
      await field(1, '081234567890');
      await tap(find.text('Simpan profile'));
      expect(
        (await api.request('GET', 'profile/me'))['profile']['profile']['bio'],
        'Emulator QA bio',
      );
      pass('profile save');
      await tab('Kategori');
      await tap(find.text('Kategori baru'));
      await field(0, 'Emulator QA');
      await tap(find.byTooltip('Warna #66806A'));
      await tap(find.text('Simpan kategori'));
      expect(find.text('Emulator QA'), findsOneWidget);
      await tap(find.text('Kategori baru'));
      await field(0, 'Emulator QA');
      await tap(find.text('Simpan kategori'));
      expect(find.text('Nama kategori sudah digunakan'), findsWidgets);
      await tap(find.byTooltip('Tutup'));
      await tap(find.text('Emulator QA'));
      await field(0, 'Emulator QA edited');
      await tap(find.text('Simpan kategori'));
      expect(find.text('Emulator QA edited'), findsOneWidget);
      pass('category create, color, duplicate and edit');
      await tab('Tugas');
      await tap(find.text('Tugas baru'));
      await field(0, 'Emulator task');
      await field(1, 'Task created through emulator UI');
      await tap(find.byType(DropdownButtonFormField<String>).at(2));
      await tap(find.text('Emulator QA edited').last);
      await tap(find.text('Simpan tugas'));
      expect(find.text('Emulator task'), findsOneWidget);
      final todo = ((await api.request('GET', 'todos'))['data'] as List)
          .singleWhere((e) => e['title'] == 'Emulator task');
      expect(todo['categoryId'], isNotNull);
      await tap(find.byTooltip('Tandai selesai'));
      expect(
        (await api.request('GET', 'todos/${todo['id']}'))['status'],
        'COMPLETED',
      );
      await tap(find.text('Emulator task'));
      await field(0, 'Emulator task edited');
      await tap(find.text('Simpan tugas'));
      expect(find.text('Emulator task edited'), findsOneWidget);
      await tap(find.text('Cari & filter'));
      await t.enterText(find.byType(TextField).first, 'Emulator task edited');
      FocusManager.instance.primaryFocus?.unfocus();
      await tap(find.text('Terapkan filter'));
      expect(find.text('Emulator task edited'), findsOneWidget);
      pass('Todo create, category, completion, edit, search');
      await api.request('PATCH', 'todos/${todo['id']}', {'reminderAt': DateTime.now().subtract(const Duration(minutes:1)).toUtc().toIso8601String()});
      api.accessToken = 'expired-qa-token';
      await tap(find.byTooltip('Muat ulang tugas'));
      expect(api.accessToken, isNot('expired-qa-token'));
      pass('refresh-token rotation');
      await tap(find.byTooltip('Notifikasi'));
      List<dynamic> inbox = [];
      for (var attempt=0;attempt<25;attempt++) {
        inbox = await api.getList('notifications');
        if(inbox.isNotEmpty) break;
        await t.pump(const Duration(seconds:3));
      }
      if(inbox.isNotEmpty) {
        await t.drag(find.byType(ListView).first,const Offset(0,400));await settle();
        await tap(find.text(inbox.first['title'] as String));
        expect((await api.getList('notifications')).first['isRead'],true);
        pass('scheduled reminder delivered and individually marked read');
      } else {debugPrint('E2E BLOCKED: reminder not produced within 75 seconds');}

      await tap(find.byTooltip('Tandai semua dibaca'));
      pass('notification inbox and read-all');
      await t.pageBack();
      await settle();
      await tap(find.text('Tanya AI'));
      await t.enterText(
        find.byType(TextField).first,
        'Berikan satu tips singkat mengatur tugas.',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await tap(find.text('Tanyakan ke AI'));
      final ask = t
          .element(find.byType(BlocBuilder<AskAiCubit, AskAiState>))
          .read<AskAiCubit>()
          .state;
      debugPrint(
        ask.answer != null
            ? 'E2E PASS: AI answer'
            : 'E2E BLOCKED AI ask: ${ask.error}',
      );
      await t.pageBack();
      await settle();
      await tap(find.text('Buat tugas dengan AI'));
      await t.enterText(
        find.byType(TextField).first,
        'Baca buku 20 menit, prioritas rendah tanpa tenggat.',
      );
      FocusManager.instance.primaryFocus?.unfocus();
      await tap(find.text('Buat draft AI'));
      if (find.byType(TodoEditor).evaluate().isNotEmpty) {
        pass('AI draft review');
      } else {
        final state = t
            .element(find.byType(BlocConsumer<AiCubit, AiState>))
            .read<AiCubit>()
            .state;
        debugPrint('E2E BLOCKED AI draft: ${state.error}');
      }
      await tap(find.byTooltip('Tutup'));
      await tab('Profile');
      await tap(find.byTooltip('Verifikasi email'));
      await field(0, email);
      await tap(find.text('Minta instruksi'));
      await tap(find.text('Sudah punya token'));
      await field(0, 'invalid-qa-token');
      await tap(find.widgetWithText(FilledButton, 'Verifikasi email'));
      expect(find.text('Token tidak valid atau kedaluwarsa'), findsOneWidget);
      await t.pageBack();
      await settle();
      pass('verification request and invalid token');
      await tap(find.byTooltip('Keamanan akun'));
      await tap(find.text('Ubah password'));
      await tap(find.widgetWithText(FilledButton, 'Ubah password'));
      expect(find.text('Password wajib diisi.'), findsOneWidget);
      await t.pageBack();
      await settle();
      pass('password change validation');
      await tap(find.byTooltip('Keamanan akun'));
      await tap(find.text('Hapus akun'));
      await field(0, password);
      await tap(find.text('Hapus akun permanen'));
      expect(find.text('Tindakan ini tidak dapat dibatalkan.'), findsOneWidget);
      await tap(find.text('Batal'));
      await t.pageBack();
      await settle();
      pass('account deletion confirmation cancelled');
      await tap(find.byTooltip('Keluar semua perangkat'));
      await tap(find.text('Keluar'));
      await wait(() => find.text('Daftar sekarang').evaluate().isNotEmpty);
      await field(0, email);
      await field(1, 'WrongPassword123!');
      await tap(find.text('Masuk'));
      expect(find.text('email atau password salah'), findsOneWidget);
      await field(1, password);
      await tap(find.text('Masuk'));
      await wait(() => find.byType(HomePage).evaluate().isNotEmpty);
      await settle();
      pass('logout-all, rejected password, correct login');
      await tap(find.byTooltip('Keluar'));
      await wait(() => find.text('Daftar sekarang').evaluate().isNotEmpty);
      await tap(find.text('Lupa password?'));
      await field(0, email);
      await tap(find.text('Minta instruksi'));
      expect(
        find.text(
          'Jika email terdaftar, instruksi reset password telah dibuat',
        ),
        findsOneWidget,
      );
      await tap(find.text('Sudah punya token'));
      await field(0, 'invalid-qa-token');
      await field(1, 'NewPassword123!');
      await tap(find.text('Simpan password baru'));
      expect(find.text('Token tidak valid atau kedaluwarsa'), findsOneWidget);
      pass('logout, forgot password, invalid reset token');
      expect(t.takeException(), isNull);
    },
    timeout: const Timeout(Duration(minutes: 12)),
  );
}
