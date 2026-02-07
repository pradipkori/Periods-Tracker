import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:period_tracker/models/cycle_models.dart';

class DatabaseService {
  late Isar isar;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [
        CycleLogSchema,
        HealthLogSchema,
        UserSettingsSchema,
        ReminderSchema,
        ArticleSchema,
        PregnancyDataSchema,
        StoredNotificationSchema,
      ],
      directory: dir.path,
    );
    
    // Initialize default settings if not exists
    final settingsCount = await isar.userSettings.count();
    if (settingsCount == 0) {
      await isar.writeTxn(() async {
        await isar.userSettings.put(UserSettings());
      });
    }
  }

  // ========== Cycle Logs ==========
  
  Future<List<CycleLog>> getAllCycles() => 
    isar.cycleLogs.where().sortByStartDateDesc().findAll();
  
  Future<List<CycleLog>> getActualCycles() => 
    isar.cycleLogs.filter().isPredictedEqualTo(false).sortByStartDateDesc().findAll();
  
  Future<CycleLog?> getLatestCycle() => 
    isar.cycleLogs.filter().isPredictedEqualTo(false).sortByStartDateDesc().findFirst();
  
  Future<CycleLog?> getCycleByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final cycles = await isar.cycleLogs.filter().isPredictedEqualTo(false).findAll();
    
    for (final cycle in cycles) {
      if (cycle.startDate.isBefore(startOfDay) || cycle.startDate.isAtSameMomentAs(startOfDay)) {
        if (cycle.endDate == null || cycle.endDate!.isAfter(startOfDay) || cycle.endDate!.isAtSameMomentAs(startOfDay)) {
          return cycle;
        }
      }
    }
    return null;
  }
  
  Future<void> saveCycle(CycleLog log) async {
    await isar.writeTxn(() => isar.cycleLogs.put(log));
  }
  
  Future<void> deleteCycle(int id) async {
    await isar.writeTxn(() => isar.cycleLogs.delete(id));
  }
  
  Future<void> deleteAllPredictedCycles() async {
    await isar.writeTxn(() async {
      final predicted = await isar.cycleLogs.filter().isPredictedEqualTo(true).findAll();
      await isar.cycleLogs.deleteAll(predicted.map((c) => c.id).toList());
    });
  }

  // ========== Health Logs ==========
  
  Future<HealthLog?> getHealthLog(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    return isar.healthLogs.filter().dateEqualTo(startOfDay).findFirst();
  }
  
  Future<List<HealthLog>> getHealthLogsInRange(DateTime start, DateTime end) {
    final startOfDay = DateTime(start.year, start.month, start.day);
    final endOfDay = DateTime(end.year, end.month, end.day, 23, 59, 59);
    return isar.healthLogs
      .filter()
      .dateBetween(startOfDay, endOfDay)
      .sortByDateDesc()
      .findAll();
  }

  Future<void> saveHealthLog(HealthLog log) async {
    log.date = DateTime(log.date.year, log.date.month, log.date.day);
    await isar.writeTxn(() => isar.healthLogs.put(log));
  }
  
  Future<void> deleteHealthLog(int id) async {
    await isar.writeTxn(() => isar.healthLogs.delete(id));
  }

  // ========== Settings ==========
  
  Future<UserSettings> getSettings() async {
    return (await isar.userSettings.where().findFirst()) ?? UserSettings();
  }
  
  Future<void> saveSettings(UserSettings settings) async {
    await isar.writeTxn(() => isar.userSettings.put(settings));
  }
  
  Future<void> updateLastPeriodDate(DateTime date) async {
    final settings = await getSettings();
    settings.lastPeriodDate = date;
    await saveSettings(settings);
  }

  // ========== Reminders ==========
  
  Future<List<Reminder>> getAllReminders() => 
    isar.reminders.where().sortByReminderDate().findAll();
  
  Future<List<Reminder>> getActiveReminders() => 
    isar.reminders.filter().isEnabledEqualTo(true).sortByReminderDate().findAll();
  
  Future<void> saveReminder(Reminder reminder) async {
    await isar.writeTxn(() => isar.reminders.put(reminder));
  }
  
  Future<void> deleteReminder(int id) async {
    await isar.writeTxn(() => isar.reminders.delete(id));
  }
  
  Future<void> toggleReminder(int id, bool enabled) async {
    await isar.writeTxn(() async {
      final reminder = await isar.reminders.get(id);
      if (reminder != null) {
        reminder.isEnabled = enabled;
        await isar.reminders.put(reminder);
      }
    });
  }

  // ========== Articles ==========
  
  Future<List<Article>> getAllArticles() => 
    isar.articles.where().sortByCreatedAtDesc().findAll();
  
  Future<List<Article>> getArticlesByCategory(String category) => 
    isar.articles.filter().categoryEqualTo(category).sortByCreatedAtDesc().findAll();
  
  Future<void> saveArticle(Article article) async {
    await isar.writeTxn(() => isar.articles.put(article));
  }
  
  Future<void> deleteArticle(int id) async {
    await isar.writeTxn(() => isar.articles.delete(id));
  }

  // ========== Pregnancy Data ==========
  
  Future<List<PregnancyData>> getAllPregnancyData() => 
    isar.pregnancyDatas.where().sortByDateDesc().findAll();
  
  Future<PregnancyData?> getPregnancyDataByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    return isar.pregnancyDatas.filter().dateEqualTo(startOfDay).findFirst();
  }
  
  Future<void> savePregnancyData(PregnancyData data) async {
    data.date = DateTime(data.date.year, data.date.month, data.date.day);
    await isar.writeTxn(() => isar.pregnancyDatas.put(data));
  }
  
  Future<void> deletePregnancyData(int id) async {
    await isar.writeTxn(() => isar.pregnancyDatas.delete(id));
  }

  // ========== Notifications History ==========

  Future<List<StoredNotification>> getAllNotifications() => 
    isar.storedNotifications.where().sortByTimestampDesc().findAll();

  Future<void> saveNotification(StoredNotification notification) async {
    await isar.writeTxn(() => isar.storedNotifications.put(notification));
  }

  Future<void> markAllAsRead() async {
    await isar.writeTxn(() async {
      final unread = await isar.storedNotifications.filter().isReadEqualTo(false).findAll();
      for (final n in unread) {
        n.isRead = true;
      }
      await isar.storedNotifications.putAll(unread);
    });
  }

  Future<void> clearNotificationHistory() async {
    await isar.writeTxn(() => isar.storedNotifications.clear());
  }

  Future<int> getUnreadNotificationCount() =>
    isar.storedNotifications.filter().isReadEqualTo(false).count();

  // ========== Statistics & Analytics ==========
  
  Future<Map<String, dynamic>> getCycleStatistics() async {
    final cycles = await getActualCycles();
    
    if (cycles.isEmpty) {
      return {
        'totalCycles': 0,
        'averageCycleLength': 28,
        'averagePeriodLength': 5,
        'shortestCycle': 0,
        'longestCycle': 0,
      };
    }

    final cycleLengths = <int>[];
    final periodLengths = <int>[];

    for (int i = 0; i < cycles.length - 1; i++) {
      final current = cycles[i];
      final next = cycles[i + 1];
      
      final cycleLength = current.startDate.difference(next.startDate).inDays.abs();
      if (cycleLength > 0 && cycleLength < 60) {
        cycleLengths.add(cycleLength);
      }
      
      if (current.endDate != null) {
        final periodLength = current.endDate!.difference(current.startDate).inDays + 1;
        if (periodLength > 0 && periodLength < 15) {
          periodLengths.add(periodLength);
        }
      }
    }

    return {
      'totalCycles': cycles.length,
      'averageCycleLength': cycleLengths.isEmpty 
        ? 28 
        : (cycleLengths.reduce((a, b) => a + b) / cycleLengths.length).round(),
      'averagePeriodLength': periodLengths.isEmpty 
        ? 5 
        : (periodLengths.reduce((a, b) => a + b) / periodLengths.length).round(),
      'shortestCycle': cycleLengths.isEmpty ? 0 : cycleLengths.reduce((a, b) => a < b ? a : b),
      'longestCycle': cycleLengths.isEmpty ? 0 : cycleLengths.reduce((a, b) => a > b ? a : b),
    };
  }

  // ========== Data Management ==========
  
  Future<int> clearAllDuplicates() async {
    final allCycles = await isar.cycleLogs.where().sortByStartDateDesc().findAll();
    final toDelete = <int>[];
    
    if (allCycles.isEmpty) return 0;
    
    // 1. Find Actual Duplicates (Same Day Manual Entries)
    final Map<String, int> seenDays = {}; // "YYYY-MM-DD" -> ID
    
    for (final cycle in allCycles) {
      if (cycle.isPredicted) continue;
      
      final key = "${cycle.startDate.year}-${cycle.startDate.month}-${cycle.startDate.day}";
      if (seenDays.containsKey(key)) {
        // Keep the one with the higher ID (more recent)
        final existingId = seenDays[key]!;
        if (cycle.id < existingId) {
          toDelete.add(cycle.id);
        } else {
          toDelete.add(existingId);
          seenDays[key] = cycle.id;
        }
      } else {
        seenDays[key] = cycle.id;
      }
    }
    
    // 2. Remove ANY Predicted cycles that are in the same month as ANY Actual entry
    final actualMonths = allCycles
        .where((c) => !c.isPredicted)
        .map((c) => "${c.startDate.year}-${c.startDate.month}")
        .toSet();

    for (final cycle in allCycles) {
      if (!cycle.isPredicted) continue;
      
      final key = "${cycle.startDate.year}-${cycle.startDate.month}";
      if (actualMonths.contains(key)) {
        toDelete.add(cycle.id);
      }
    }
    
    if (toDelete.isNotEmpty) {
      await isar.writeTxn(() async {
        await isar.cycleLogs.deleteAll(toDelete);
      });
    }
    
    return toDelete.length;
  }

  Future<void> clearAllData() async {
    await isar.writeTxn(() async {
      await isar.cycleLogs.clear();
      await isar.healthLogs.clear();
      await isar.reminders.clear();
      await isar.pregnancyDatas.clear();
      // Keep settings and articles
    });
  }
  
  Future<void> clearPredictions() async {
    await deleteAllPredictedCycles();
  }
}
