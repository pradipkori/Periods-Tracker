import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
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
  
  // Initialize Firebase & AlarmManager only on Mobile
  if (!kIsWeb) {
    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      await AndroidAlarmManager.initialize();
    } catch (e) {
      print('Firebase/AlarmManager init error: $e');
    }
  }
  
  // Initialize timezone
  tz.initializeTimeZones();
  try {
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata')); // Set to Indian timezone
  } catch (e) {
    print('Timezone init error: $e. Falling back to default.');
  }
  
  final container = ProviderContainer();
  final dbService = container.read(dbServiceProvider);
  await dbService.init();

  // CLEANUP: Remove any existing duplicate or overlapping cycles
  try {
    print('🧹 Performing startup data cleanup...');
    await dbService.clearAllDuplicates();
  } catch (e) {
    print('Cleanup error: $e');
  }

  // Initialize notification service
  final notificationService = container.read(notificationServiceProvider);
  await notificationService.init();
  await notificationService.requestPermissions();

  // Initialize push notification service only on Mobile
  if (!kIsWeb) {
    final pushNotificationService = container.read(pushNotificationServiceProvider);
    await pushNotificationService.init();
  }

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
