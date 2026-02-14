import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:period_tracker/providers/app_providers.dart';
import 'package:period_tracker/theme/app_theme.dart';
import 'package:period_tracker/views/onboarding/splash_screen.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:period_tracker/services/push_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  
  // Initialize AlarmManager
  await AndroidAlarmManager.initialize();
  
  // Initialize timezone
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Kolkata')); // Set to Indian timezone
  
  final container = ProviderContainer();
  final dbService = container.read(dbServiceProvider);
  await dbService.init();

  // CLEANUP: Remove any existing duplicate or overlapping cycles
  print('🧹 Performing startup data cleanup...');
  await dbService.clearAllDuplicates();

  // Initialize notification service
  final notificationService = container.read(notificationServiceProvider);
  await notificationService.init();
  await notificationService.requestPermissions();

  // Initialize push notification service
  final pushNotificationService = container.read(pushNotificationServiceProvider);
  await pushNotificationService.init();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const PeriodTrackerApp(),
    ),
  );
}

class PeriodTrackerApp extends ConsumerWidget {
  const PeriodTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Period Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
