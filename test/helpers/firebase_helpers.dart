import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void setupFirebaseMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const codec = StandardMessageCodec();

  // --- Mock Firebase Core (using Pigeon/BasicMessageChannel) ---
  // This handler has been updated to return data in the List format expected
  // by modern versions of the firebase_core plugin.
  messenger.setMockMessageHandler(
    'dev.flutter.pigeon.firebase_core_platform_interface.FirebaseCoreHostApi.initializeCore',
    (ByteData? message) async {
      // The PigeonFirebaseOptions object serialized as a list.
      final optionsList = <Object?>[
        'test_api_key', // apiKey
        'test_app_id', // appId
        'test_sender_id', // messagingSenderId
        'test_project_id', // projectId
        null, // authDomain
        null, // databaseURL
        null, // storageBucket
        null, // measurementId
        null, // trackingId
        null, // deepLinkURLScheme
        null, // androidClientId
        null, // iosClientId
        null, // iosBundleId
        null, // appGroupId
      ];

      // The PigeonInitializeResponse object serialized as a list.
      final responseList = <Object?>[
        defaultFirebaseAppName, // name
        optionsList, // options
        false, // isAutomaticDataCollectionEnabled
        <String, Object?>{}, // pluginConstants
      ];

      // The return value of initializeCore is a List<PigeonInitializeResponse?>
      final coreResponse = <Object?>[responseList];

      // The pigeon system wraps the result in a list.
      return codec.encodeMessage(<Object?>[coreResponse]);
    },
  );

  // This mock handles the `initializeApp` call, which is separate.
  messenger.setMockMessageHandler(
    'dev.flutter.pigeon.firebase_core_platform_interface.FirebaseCoreHostApi.initializeApp',
    (ByteData? message) async {
      return codec.encodeMessage(<Object?, Object?>{});
    },
  );

  // --- Mock Firebase Auth (still uses MethodChannel) ---
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
