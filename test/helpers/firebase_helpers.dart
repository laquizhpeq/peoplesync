import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void setupFirebaseMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  // Mock Firebase Core
  const coreChannel = MethodChannel('plugins.flutter.io/firebase_core');
  messenger.setMockMethodCallHandler(coreChannel, (call) async {
    if (call.method == 'Firebase#initializeCore') {
      return [
        {
          'name': defaultFirebaseAppName,
          'options': {
            'apiKey': 'test_api_key',
            'appId': 'test_app_id',
            'messagingSenderId': 'test_sender_id',
            'projectId': 'test_project_id',
          },
          'pluginConstants': {},
        },
      ];
    }
    if (call.method == 'Firebase#initializeApp') {
      return {
        'name': call.arguments['appName'],
        'options': call.arguments['options'],
        'pluginConstants': {},
      };
    }
    return null;
  });

  // Mock Firebase Auth
  const authChannel = MethodChannel('plugins.flutter.io/firebase_auth');
  messenger.setMockMethodCallHandler(authChannel, (call) async {
    switch (call.method) {
      case 'Auth#getRedirectResult':
        return null;
      case 'Auth#currentUser':
        return null;
      case 'Auth#addAuthStateListener':
        final handle = call.arguments['handle'];
        final streamChannel = MethodChannel(
          'plugins.flutter.io/firebase_auth_stream_handler/$handle',
        );
        messenger.setMockMethodCallHandler(streamChannel, (_) async => null);
        return {'handle': handle};
      default:
        return null;
    }
  });
}
