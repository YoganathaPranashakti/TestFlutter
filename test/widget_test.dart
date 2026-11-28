import 'package:flutter_test/flutter_test.dart';
import 'package:test_flutter/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TestFlutterApp());
    expect(find.text('Aplikasi Text-to-Speech'), findsOneWidget);
    expect(find.text('Bicarakan'), findsOneWidget);
  });
}