import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peoplesync/app.dart';
import 'package:peoplesync/core/constants/app_strings.dart';

import 'helpers/firebase_helpers.dart';

void main() {
  // Configura las simulaciones de Firebase antes de los tests
  setupFirebaseMocks();

  setUpAll(() async {
    // Inicializa la app de Firebase simulada
    await Firebase.initializeApp();
  });

  testWidgets('Login screen smoke test', (WidgetTester tester) async {
    // Construye la app y refresca la UI
    await tester.pumpWidget(const MyApp());

    // Espera a que se resuelvan los futures y se construya la UI
    await tester.pumpAndSettle();

    // Verifica que el título de la página es 'Login'
    expect(find.text(AppStrings.login), findsOneWidget);

    // Verifica que los campos de texto están presentes
    expect(find.text(AppStrings.email), findsOneWidget);
    expect(find.text(AppStrings.password), findsOneWidget);

    // Verifica que el botón de inicio de sesión está presente
    expect(find.text(AppStrings.signIn), findsOneWidget);
  });
}
