import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:peoplesync/core/config/env_config.dart';
import 'package:peoplesync/core/di/service_locator.dart';
import 'package:peoplesync/core/services/app_feedback_service.dart';
import 'package:peoplesync/core/services/app_logger.dart';
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    AppLogger.error(
      'Flutter framework error capturado',
      scope: 'main',
      error: details.exception,
      stackTrace: details.stack,
    );
    AppFeedbackService.showError(
      'La app encontro un error inesperado. Reinicia la pantalla o vuelve a intentarlo.',
    );
  };

  PlatformDispatcher.instance.onError = (error, stackTrace) {
    AppLogger.error(
      'Error no controlado de plataforma',
      scope: 'main',
      error: error,
      stackTrace: stackTrace,
    );
    AppFeedbackService.showError(
      'Algo fallo en segundo plano. Si se repite, reinicia la app.',
    );
    return true;
  };

  await runZonedGuarded(() async {
    AppLogger.info('Iniciando aplicacion', scope: 'main');
    await dotenv.load(fileName: '.env');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );
    if (EnvConfig.supabaseUrl.isNotEmpty &&
        EnvConfig.supabaseAnonKey.isNotEmpty) {
      await Supabase.initialize(
        url: EnvConfig.supabaseUrl,
        anonKey: EnvConfig.supabaseAnonKey,
      );
      AppLogger.info('Supabase inicializado', scope: 'main');
    } else {
      AppLogger.warning(
        'Supabase no configurado; algunas funciones de imagen pueden fallar',
        scope: 'main',
      );
    }
    setupServiceLocator();
    AppLogger.info('Service locator listo', scope: 'main');
    runApp(const MyApp());
  }, (error, stackTrace) {
    AppLogger.error(
      'Error de zona no controlado durante el arranque',
      scope: 'main',
      error: error,
      stackTrace: stackTrace,
    );
    AppFeedbackService.showError(
      'La app fallo durante el arranque. Cierra y vuelve a abrir.',
    );
  });
}
