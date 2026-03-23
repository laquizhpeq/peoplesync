import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:peoplesync/core/di/service_locator.dart';
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  setupServiceLocator();
  runApp(const MyApp());
}
