import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Simple Flutter Test', (WidgetTester tester) async {
    // Este test construye un widget de texto muy simple.
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('Hello'))),
    );

    // Verifica que el texto 'Hello' está en la pantalla.
    // Si este test pasa, significa que tu entorno de testing funciona.
    expect(find.text('Hello'), findsOneWidget);
  });
}
