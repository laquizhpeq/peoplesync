import 'package:flutter_test/flutter_test.dart';
import 'package:peoplesync/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';

void main() {
  // Configurar mocks de Firebase Core para pruebas
  setupFirebaseCoreMocks();

  setUpAll(() async {
    // Inicializar Firebase
    await Firebase.initializeApp();
  });

  testWidgets('Login screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verificar que estamos en la pantalla de Login
    // Buscamos widgets que sabemos que están en el LoginScreen
    expect(find.text('Login'), findsWidgets); // Puede estar en AppBar y otros lugares
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.text('Iniciar Sesión'), findsOneWidget);
  });
}
