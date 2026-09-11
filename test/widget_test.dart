import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_mobile/main.dart';

void main() {
  testWidgets('Login validates input and toggles password visibility', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.ensureVisible(find.text('Masuk'));
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();
    expect(find.text('Masukkan alamat email yang valid.'), findsOneWidget);
    expect(find.text('Password wajib diisi.'), findsOneWidget);
    final password = find.byType(TextFormField).last;
    expect(
      tester
          .widget<TextField>(
            find.descendant(of: password, matching: find.byType(TextField)),
          )
          .obscureText,
      isTrue,
    );
    await tester.ensureVisible(find.byTooltip('Tampilkan password'));
    await tester.tap(find.byTooltip('Tampilkan password'));
    await tester.pump();
    expect(
      tester
          .widget<TextField>(
            find.descendant(of: password, matching: find.byType(TextField)),
          )
          .obscureText,
      isFalse,
    );
  });

  testWidgets('Registration and password reset are reachable', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.ensureVisible(find.text('Daftar sekarang'));
    await tester.tap(find.text('Daftar sekarang'));
    await tester.pumpAndSettle();
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Umur'), findsOneWidget);
    expect(find.text('Role'), findsOneWidget);
    await tester.ensureVisible(find.text('Kembali ke login'));
    await tester.tap(find.text('Kembali ke login'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Lupa password?'));
    await tester.tap(find.text('Lupa password?'));
    await tester.pumpAndSettle();
    expect(find.text('Minta instruksi'), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
