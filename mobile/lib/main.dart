import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app.dart';
import 'core/di/injection_container.dart';
import 'core/notifications/medication_notification_handler.dart';
import 'core/notifications/notification_service.dart';
import 'core/storage/local_database_service.dart';
import 'features/medication_and_adherence/domain/services/medication_reconciliation_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await configureDependencies();

  final localDatabase = sl<LocalDatabaseService>();
  await localDatabase.initialize();

  runApp(const AfyaMindApp());

  // Non-blocking background initialization after initial UI frame renders
  _initializeBackgroundServices();
}

Future<void> _initializeBackgroundServices() async {
  try {
    final notificationService = sl<NotificationService>();
    final notificationHandler = sl<MedicationNotificationHandler>();

    await notificationService.initialize(
      onResponse: notificationHandler.handleNotificationResponse,
    );

    // Run on-device dose scheduler & missed-dose startup reconciliation
    await sl<MedicationReconciliationService>().reconcile();
  } catch (_) {
    // Avoid crashing background initialization
  }
}
