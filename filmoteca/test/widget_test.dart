import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:filmoteca/app/app_shell.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(FilmotecaApp(loggedName: '', initialLang: 'id-ID'));

    expect(find.byType(Scaffold), findsWidgets);
  });
}
