import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peoplesync/main.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Mock MethodChannel for Firebase Core
    const MethodChannel channel = MethodChannel(
      'plugins.flutter.io/firebase_core',
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          if (methodCall.method == 'Firebase#initializeCore') {
            return [
              {
                'name': '[DEFAULT]',
                'options': {
                  'apiKey': 'test',
                  'appId': 'test',
                  'messagingSenderId': 'test',
                  'projectId': 'test',
                },
                'pluginConstants': {},
              },
            ];
          }
          if (methodCall.method == 'Firebase#initializeApp') {
            return {
              'name': methodCall.arguments['appName'],
              'options': methodCall.arguments['options'],
              'pluginConstants': {},
            };
          }
          return null;
        });

    await Firebase.initializeApp();
  });

  testWidgets('Login screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verificar que estamos en la pantalla de Login
    expect(find.text('Login'), findsWidgets);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.text('Iniciar Sesión'), findsOneWidget);
  });
}
