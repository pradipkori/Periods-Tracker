import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:period_tracker/models/cycle_models.dart';
import 'package:period_tracker/services/database_service.dart';
import 'package:period_tracker/services/prediction_service.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:isar/isar.dart';

// Top-level callback for AlarmManager (must be top-level for background isolates)
@pragma('vm:entry-point')
Future<void> alarmCallback(int id) async {
  print('🔔 ALARM CALLBACK TRIGGERED for ID: $id');
  
  final notifications = FlutterLocalNotificationsPlugin();
  
  // Re-initialize for the background isolate
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidSettings);
  await notifications.initialize(initSettings);

  if (id == 997) {
    // This is the test notification
    await notifications.show(
      997,
      'AlarmManager Test Success! 🎉',
      'This notification was triggered by AlarmManager at ${DateTime.now()}!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_notifications',
          'Test Notifications',
          channelDescription: 'Test notifications',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'Test Success',
          category: AndroidNotificationCategory.reminder,
          visibility: NotificationVisibility.public,
        ),
      ),
    );
    return;
  }

  // Handle system reminders
  if (id == 1) {
    await notifications.show(
      1,
      'Period Reminder',
      'Your period is expected to start tomorrow. Be prepared!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'period_reminders',
          'Period Reminders',
          channelDescription: 'Notifications for upcoming periods',
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.reminder,
        ),
      ),
    );
    return;
  }

  if (id == 2) {
    await notifications.show(
      2,
      'Ovulation Day',
      'Today is your most fertile day!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'ovulation_reminders',
          'Ovulation Reminders',
          channelDescription: 'Notifications for ovulation',
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.reminder,
        ),
      ),
    );
    return;
  }

  if (id == 3) {
    await notifications.show(
      3,
      'Daily Log Reminder',
      'Don\'t forget to log your symptoms and mood today!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_log_reminders',
          'Daily Log Reminders',
          channelDescription: 'Daily reminders to log health data',
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.reminder,
        ),
      ),
    );
    return;
  }

  // Handle custom reminders (IDs >= 1000)
  if (id >= 1000) {
    try {
      final databaseDir = await getApplicationDocumentsDirectory();
      // Open Isar in the background isolate
      final isar = Isar.getInstance() ?? await Isar.open(
        [
          CycleLogSchema,
          HealthLogSchema,
          UserSettingsSchema,
          ReminderSchema,
          ArticleSchema,
          PregnancyDataSchema,
        ],
        directory: databaseDir.path,
      );

      final reminderId = id - 1000;
      final reminder = await isar.reminders.get(reminderId);

      if (reminder != null && reminder.isEnabled) {
        String message = '⏰ Time for your ${reminder.title}';
        if (reminder.type == 'medication') {
          message = '💊 Hey! It\'s time for your ${reminder.title}. Don\'t forget to take it!';
        } else if (reminder.notes != null && reminder.notes!.isNotEmpty) {
          message = '⏰ ${reminder.notes}';
        }

        await notifications.show(
          id,
          reminder.title,
          message,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'custom_reminders',
              'Custom Reminders',
              channelDescription: 'User-created custom reminders',
              importance: Importance.max,
              priority: Priority.high,
              ticker: 'Reminder',
              category: AndroidNotificationCategory.reminder,
              visibility: NotificationVisibility.public,
            ),
          ),
        );
        print('✅ Reminder notification displayed for $reminderId');
      }
    } catch (e) {
      print('❌ Error in background alarm callback: $e');
    }
  }
}

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final DatabaseService _db;
  final PredictionService _predictionService;

  NotificationService(this._db, this._predictionService);

  // Initialize notification service
  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tap
        // You can add navigation logic here if needed
        print('Notification tapped: ${response.payload}');
      },
    );

    // Create notification channels for Android
    final androidImplementation = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      // Create channels for different notification types
      await androidImplementation.createNotificationChannel(
        const AndroidNotificationChannel(
          'custom_reminders',
          'Custom Reminders',
          description: 'User-created custom reminders',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );
      
      await androidImplementation.createNotificationChannel(
        const AndroidNotificationChannel(
          'test_notifications',
          'Test Notifications',
          description: 'Test notifications',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );
      
      await androidImplementation.createNotificationChannel(
        const AndroidNotificationChannel(
          'period_reminders',
          'Period Reminders',
          description: 'Notifications for upcoming periods',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );
      
      await androidImplementation.createNotificationChannel(
        const AndroidNotificationChannel(
          'ovulation_reminders',
          'Ovulation Reminders',
          description: 'Notifications for ovulation',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );
      
      await androidImplementation.createNotificationChannel(
        const AndroidNotificationChannel(
          'daily_log_reminders',
          'Daily Log Reminders',
          description: 'Daily reminders to log health data',
          importance: Importance.defaultImportance,
          playSound: true,
          enableVibration: true,
        ),
      );
      
      print('Notification channels created successfully');
    }
  }

  // Check if exact alarms permission is granted (Android 12+)
  Future<bool> canScheduleExactAlarms() async {
    final androidImplementation = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      try {
        final canSchedule = await androidImplementation.canScheduleExactNotifications();
        print('Can schedule exact alarms: $canSchedule');
        return canSchedule ?? false;
      } catch (e) {
        print('Error checking exact alarm permission: $e');
        return false;
      }
    }
    
    return true; // iOS doesn't need this permission
  }

  // Request notification permissions
  Future<bool> requestPermissions() async {
    final androidImplementation = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      // Request notification permission
      final granted = await androidImplementation.requestNotificationsPermission();
      print('Notification permission granted: $granted');
      
      // Request exact alarm permission for Android 12+
      try {
        final exactAlarmGranted = await androidImplementation.requestExactAlarmsPermission();
        print('Exact alarm permission request result: $exactAlarmGranted');
      } catch (e) {
        print('Error requesting exact alarm permission: $e');
      }
      
      // Check if we can actually schedule exact alarms
      final canSchedule = await canScheduleExactAlarms();
      if (!canSchedule) {
        print('WARNING: Cannot schedule exact alarms. User needs to grant permission in system settings.');
      }
      
      return granted ?? false;
    }

    final iosImplementation = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    
    if (iosImplementation != null) {
      final granted = await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return false;
  }

  // Open app settings for user to manually enable permissions
  Future<void> openSettings() async {
    await openAppSettings();
  }

  // Check if battery optimization is disabled (important for scheduled notifications)
  Future<bool> isBatteryOptimizationDisabled() async {
    try {
      final status = await Permission.ignoreBatteryOptimizations.status;
      print('Battery optimization status: $status');
      return status.isGranted;
    } catch (e) {
      print('Error checking battery optimization: $e');
      return false;
    }
  }

  // Request to disable battery optimization
  Future<bool> requestDisableBatteryOptimization() async {
    try {
      final status = await Permission.ignoreBatteryOptimizations.request();
      print('Battery optimization request result: $status');
      return status.isGranted;
    } catch (e) {
      print('Error requesting battery optimization: $e');
      return false;
    }
  }

  // Schedule period reminder
  Future<void> schedulePeriodReminder() async {
    final settings = await _db.getSettings();
    if (!settings.notificationsEnabled || !settings.periodReminderEnabled) return;

    final nextPeriod = await _predictionService.predictNextPeriod();
    if (nextPeriod == null) return;

    // Schedule notification 1 day before
    final reminderDate = nextPeriod.subtract(const Duration(days: 1));
    final scheduledDate = DateTime(
      reminderDate.year,
      reminderDate.month,
      reminderDate.day,
      settings.notificationHour,
      settings.notificationMinute,
    );

    if (scheduledDate.isBefore(DateTime.now())) return;

    await _notifications.zonedSchedule(
      1, // Notification ID for period reminder
      'Period Reminder',
      'Your period is expected to start tomorrow. Be prepared!',
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'period_reminders',
          'Period Reminders',
          channelDescription: 'Notifications for upcoming periods',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'Period Reminder',
          category: AndroidNotificationCategory.reminder,
          visibility: NotificationVisibility.public,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    // Also schedule with AlarmManager
    await AndroidAlarmManager.oneShotAt(
      scheduledDate,
      1,
      alarmCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );
  }

  // Schedule ovulation reminder
  Future<void> scheduleOvulationReminder() async {
    final settings = await _db.getSettings();
    if (!settings.notificationsEnabled || !settings.ovulationReminderEnabled) return;

    final ovulationDate = await _predictionService.predictOvulationDate();
    if (ovulationDate == null) return;

    // Schedule notification on ovulation day
    final scheduledDate = DateTime(
      ovulationDate.year,
      ovulationDate.month,
      ovulationDate.day,
      settings.notificationHour,
      settings.notificationMinute,
    );

    if (scheduledDate.isBefore(DateTime.now())) return;

    await _notifications.zonedSchedule(
      2, // Notification ID for ovulation reminder
      'Ovulation Day',
      'Today is your most fertile day!',
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'ovulation_reminders',
          'Ovulation Reminders',
          channelDescription: 'Notifications for ovulation',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'Ovulation Reminder',
          category: AndroidNotificationCategory.reminder,
          visibility: NotificationVisibility.public,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    // Also schedule with AlarmManager
    await AndroidAlarmManager.oneShotAt(
      scheduledDate,
      2,
      alarmCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );
  }

  // Schedule daily log reminder
  Future<void> scheduleDailyLogReminder() async {
    final settings = await _db.getSettings();
    if (!settings.notificationsEnabled || !settings.dailyLogReminderEnabled) return;

    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      settings.notificationHour,
      settings.notificationMinute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      3, // Notification ID for daily log reminder
      'Daily Log Reminder',
      'Don\'t forget to log your symptoms and mood today!',
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_log_reminders',
          'Daily Log Reminders',
          channelDescription: 'Daily reminders to log health data',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'Daily Log Reminder',
          category: AndroidNotificationCategory.reminder,
          visibility: NotificationVisibility.public,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
    );

    // Also schedule with AlarmManager
    await AndroidAlarmManager.periodic(
      const Duration(days: 1),
      3,
      alarmCallback,
      startAt: scheduledDate,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );
  }

  // Schedule custom reminder
  Future<void> scheduleCustomReminder(Reminder reminder) async {
    if (!reminder.isEnabled) {
      print('Reminder ${reminder.id} is disabled, skipping schedule');
      return;
    }

    // Check if notifications are enabled in settings
    final settings = await _db.getSettings();
    if (!settings.notificationsEnabled) {
      print('Notifications are disabled in settings');
      throw Exception('Please enable notifications in settings first');
    }

    // Check if we can schedule exact alarms
    final canSchedule = await canScheduleExactAlarms();
    if (!canSchedule) {
      print('ERROR: Cannot schedule exact alarms - permission not granted');
      throw Exception('Exact alarm permission is required. Please enable "Alarms & reminders" permission in your phone settings for this app.');
    }

    // Get personalized message based on reminder type
    String message = _getPersonalizedMessage(reminder);

    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      reminder.hourOfDay,
      reminder.minute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    print('Scheduling reminder ${reminder.id}: ${reminder.title} for $scheduledDate using AlarmManager');

    try {
      // 1. Still schedule with Local Notifications (for other devices/internal tracking)
      await _notifications.zonedSchedule(
        reminder.id + 1000, 
        reminder.title,
        message,
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'custom_reminders',
            'Custom Reminders',
            channelDescription: 'User-created custom reminders',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'Custom Reminder',
            category: AndroidNotificationCategory.reminder,
            visibility: NotificationVisibility.public,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      // 2. Schedule with AlarmManager (Reliable for Realme/Oppo)
      // Note: periodic with a startAt time
      await AndroidAlarmManager.periodic(
        const Duration(days: 1),
        reminder.id + 1000,
        alarmCallback,
        startAt: scheduledDate,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
      );

      print('Successfully scheduled reminder ${reminder.id} using both methods');
    } catch (e) {
      print('Error scheduling reminder ${reminder.id}: $e');
      rethrow;
    }
  }

  // Get personalized notification message based on reminder type
  String _getPersonalizedMessage(Reminder reminder) {
    switch (reminder.type) {
      case 'medication':
        return '💊 Hey! It\'s time for your ${reminder.title}. Don\'t forget to take it!';
      case 'custom':
        if (reminder.notes != null && reminder.notes!.isNotEmpty) {
          return '⏰ ${reminder.notes}';
        }
        return '⏰ Reminder: ${reminder.title}';
      case 'period':
        return '🌸 ${reminder.title} - Stay prepared!';
      case 'ovulation':
        return '💕 ${reminder.title} - Your fertile window!';
      default:
        return '🔔 ${reminder.title}';
    }
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  // Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    // Also cancel from AlarmManager
    await AndroidAlarmManager.cancel(id);
  }

  // Reschedule all notifications
  Future<void> rescheduleAllNotifications() async {
    await cancelAllNotifications();
    await schedulePeriodReminder();
    await scheduleOvulationReminder();
    await scheduleDailyLogReminder();

    // Reschedule custom reminders
    final reminders = await _db.getActiveReminders();
    for (final reminder in reminders) {
      await scheduleCustomReminder(reminder);
    }
  }
}
