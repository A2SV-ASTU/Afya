import 'package:flutter/material.dart';
import 'package:mobile/app/app.dart';
import 'package:mobile/core/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initServiceLocator();
  runApp(const AfyaMindApp());
}
