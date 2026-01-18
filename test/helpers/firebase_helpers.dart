import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void setupFirebaseMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  // --- Mock Firebase Core ---
  // This is the definitive mock for the legacy MethodChannel used in tests.
  const coreChannel = MethodChannel('plugins.flutter.io/firebase_core');
  messenger.setMockMethodCallHandler(coreChannel, (call) async {
    if (call.method == 'Firebase#initializeCore') {
      // This method expects a List<Map<String, dynamic>>.
      return <Map<String, dynamic>>[
        {
          'name': defaultFirebaseAppName,
          'options': {
            'apiKey': 'test_api_key',
            'appId': 'test_app_id',
            'messagingSenderId': 'test_sender_id',
            'projectId': 'test_project_id',
          },
          'pluginConstants': <String, dynamic>{},
        },
      ];
    }
    if (call.method == 'Firebase#initializeApp') {
      // This method expects a Map<String, dynamic>.
      return <String, dynamic>{
        'name': call.arguments['appName'],
        'options': call.arguments['options'],
        'pluginConstants': {},
      };
    }
    return null;
  });

  // --- Mock Firebase Auth ---
  const authChannel = MethodChannel('plugins.flutter.io/firebase_auth');
  messenger.setMockMethodCallHandler(authChannel, (call) async {
    switch (call.method) {
      case 'Auth#getRedirectResult':
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
