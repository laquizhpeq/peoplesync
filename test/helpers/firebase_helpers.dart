import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void setupFirebaseMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const codec = StandardMessageCodec();

  // --- Mock Firebase Core (using Pigeon/BasicMessageChannel) ---
  // This is the modern way to mock Firebase initialization.
  messenger.setMockMessageHandler(
    'dev.flutter.pigeon.firebase_core_platform_interface.FirebaseCoreHostApi.initializeCore',
    (ByteData? message) async {
      final list = <Object?>[
        <String, Object?>{
          'name': defaultFirebaseAppName,
          'options': <String, Object?>{
            'apiKey': 'test_api_key',
            'appId': 'test_app_id',
            'messagingSenderId': 'test_sender_id',
            'projectId': 'test_project_id',
          },
          'isAutomaticDataCollectionEnabled': false,
          'pluginConstants': <String, Object?>{},
        },
      ];
      return codec.encodeMessage(list);
    },
  );

  // --- Mock Firebase Auth (still uses MethodChannel) ---
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
