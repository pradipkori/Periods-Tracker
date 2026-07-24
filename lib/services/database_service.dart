import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:period_tracker/models/cycle_models.dart';
import 'package:flutter/foundation.dart';

class DatabaseService {
  final SupabaseClient supabase = Supabase.instance.client;

  String get _userId {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');
    return user.id;
  }

  Future<void> init() async {
    // Supabase initialization happens in main.dart.
    // Ensure default settings exist for the user (handled by SQL trigger usually, but good to ensure)
    if (supabase.auth.currentUser != null) {
      try {
        await getSettings();
      } catch (e) {
        debugPrint("Error fetching settings on init: $e");
      }
    }
  }

  // ========== Cycle Logs ==========

  Future<List<CycleLog>> getAllCycles() async {
    try {
      final response = await supabase
          .from('cycle_logs')
          .select()
          .eq('user_id', _userId)
          .order('start_date', ascending: false);
      return response.map((e) => CycleLog.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Supabase error: $e");
      return [];
    }
  }

  Future<List<CycleLog>> getActualCycles() async {
    try {
      final response = await supabase
          .from('cycle_logs')
          .select()
          .eq('user_id', _userId)
          .eq('is_predicted', false)
          .order('start_date', ascending: false);
      return response.map((e) => CycleLog.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<CycleLog?> getLatestCycle() async {
    try {
      final response = await supabase
          .from('cycle_logs')
          .select()
          .eq('user_id', _userId)
          .eq('is_predicted', false)
          .order('start_date', ascending: false)
          .limit(1);
      if (response.isEmpty) return null;
      return CycleLog.fromJson(response.first);
    } catch (e) {
      return null;
    }
  }

  Future<CycleLog?> getCycleByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    try {
      final cycles = await getActualCycles();
      for (final cycle in cycles) {
        if (cycle.startDate.isBefore(startOfDay) ||
            cycle.startDate.isAtSameMomentAs(startOfDay)) {
          if (cycle.endDate == null ||
              cycle.endDate!.isAfter(startOfDay) ||
              cycle.endDate!.isAtSameMomentAs(startOfDay)) {
            return cycle;
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> saveCycle(CycleLog log) async {
    try {
      final data = log.toJson();
      data['user_id'] = _userId;
      if (log.id == null) {
        await supabase.from('cycle_logs').insert(data);
      } else {
        await supabase.from('cycle_logs').update(data).eq('id', log.id!).eq('user_id', _userId);
      }
    } catch (e) {
      debugPrint("Save Cycle Error: $e");
    }
  }

  Future<void> deleteCycle(String id) async {
    try {
      await supabase.from('cycle_logs').delete().eq('id', id).eq('user_id', _userId);
    } catch (e) {
      debugPrint("Delete Cycle Error: $e");
    }
  }

  Future<void> deleteAllPredictedCycles() async {
    try {
      await supabase.from('cycle_logs').delete().eq('is_predicted', true).eq('user_id', _userId);
    } catch (e) {
      debugPrint("Delete Predicted Error: $e");
    }
  }

  // ========== Health Logs ==========

  Future<HealthLog?> getHealthLog(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    try {
      final response = await supabase
          .from('health_logs')
          .select()
          .eq('user_id', _userId)
          .eq('date', startOfDay.toUtc().toIso8601String())
          .limit(1);
      if (response.isEmpty) return null;
      return HealthLog.fromJson(response.first);
    } catch (e) {
      return null;
    }
  }

  Future<List<HealthLog>> getHealthLogsInRange(DateTime start, DateTime end) async {
    final startOfDay = DateTime(start.year, start.month, start.day);
    final endOfDay = DateTime(end.year, end.month, end.day, 23, 59, 59);
    try {
      final response = await supabase
          .from('health_logs')
          .select()
          .eq('user_id', _userId)
          .gte('date', startOfDay.toUtc().toIso8601String())
          .lte('date', endOfDay.toUtc().toIso8601String())
          .order('date', ascending: false);
      return response.map((e) => HealthLog.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveHealthLog(HealthLog log) async {
    try {
      log.date = DateTime(log.date.year, log.date.month, log.date.day);
      final data = log.toJson();
      data['user_id'] = _userId;
      
      // Upsert to handle unique constraint on (user_id, date)
      await supabase.from('health_logs').upsert(
        data, 
        onConflict: 'user_id, date'
      );
    } catch (e) {
      debugPrint("Save HealthLog Error: $e");
    }
  }

  Future<void> deleteHealthLog(String id) async {
    try {
      await supabase.from('health_logs').delete().eq('id', id).eq('user_id', _userId);
    } catch (e) {
      debugPrint("Delete HealthLog Error: $e");
    }
  }

  // ========== Settings ==========

  Future<UserSettings> getSettings() async {
    try {
      final response = await supabase
          .from('user_settings')
          .select()
          .eq('user_id', _userId)
          .limit(1);
      if (response.isEmpty) return UserSettings();
      return UserSettings.fromJson(response.first);
    } catch (e) {
      debugPrint("Get Settings Error: $e");
      return UserSettings();
    }
  }

  Future<void> saveSettings(UserSettings settings) async {
    try {
      final data = settings.toJson();
      data['user_id'] = _userId;
      await supabase.from('user_settings').upsert(
        data,
        onConflict: 'user_id'
      );
    } catch (e) {
      debugPrint("Save Settings Error: $e");
    }
  }

  Future<void> updateLastPeriodDate(DateTime date) async {
    final settings = await getSettings();
    settings.lastPeriodDate = date;
    await saveSettings(settings);
  }

  // ========== Reminders ==========

  Future<List<Reminder>> getAllReminders() async {
    try {
      final response = await supabase
          .from('reminders')
          .select()
          .eq('user_id', _userId)
          .order('reminder_date', ascending: true);
      return response.map((e) => Reminder.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Reminder>> getActiveReminders() async {
    try {
      final response = await supabase
          .from('reminders')
          .select()
          .eq('user_id', _userId)
          .eq('is_enabled', true)
          .order('reminder_date', ascending: true);
      return response.map((e) => Reminder.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveReminder(Reminder reminder) async {
    try {
      final data = reminder.toJson();
      data['user_id'] = _userId;
      if (reminder.id == null) {
        await supabase.from('reminders').insert(data);
      } else {
        await supabase.from('reminders').update(data).eq('id', reminder.id!).eq('user_id', _userId);
      }
    } catch (e) {
      debugPrint("Save Reminder Error: $e");
    }
  }

  Future<void> deleteReminder(String id) async {
    try {
      await supabase.from('reminders').delete().eq('id', id).eq('user_id', _userId);
    } catch (e) {
      debugPrint("Delete Reminder Error: $e");
    }
  }

  Future<void> toggleReminder(String id, bool enabled) async {
    try {
      await supabase.from('reminders').update({'is_enabled': enabled}).eq('id', id).eq('user_id', _userId);
    } catch (e) {
      debugPrint("Toggle Reminder Error: $e");
    }
  }

  // ========== Articles ==========

  Future<List<Article>> getAllArticles() async {
    try {
      final response = await supabase
          .from('articles')
          .select()
          .order('created_at', ascending: false);
      return response.map((e) => Article.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Article>> getArticlesByCategory(String category) async {
    try {
      final response = await supabase
          .from('articles')
          .select()
          .eq('category', category)
          .order('created_at', ascending: false);
      return response.map((e) => Article.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveArticle(Article article) async {
    // Articles are usually read-only for standard users in Supabase
    debugPrint("Cannot save article from client (Read Only)");
  }

  Future<void> deleteArticle(String id) async {
    debugPrint("Cannot delete article from client (Read Only)");
  }

  // ========== Pregnancy Data ==========

  Future<List<PregnancyData>> getAllPregnancyData() async {
    try {
      final response = await supabase
          .from('pregnancy_data')
          .select()
          .eq('user_id', _userId)
          .order('date', ascending: false);
      return response.map((e) => PregnancyData.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<PregnancyData?> getPregnancyDataByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    try {
      final response = await supabase
          .from('pregnancy_data')
          .select()
          .eq('user_id', _userId)
          .eq('date', startOfDay.toUtc().toIso8601String())
          .limit(1);
      if (response.isEmpty) return null;
      return PregnancyData.fromJson(response.first);
    } catch (e) {
      return null;
    }
  }

  Future<void> savePregnancyData(PregnancyData data) async {
    try {
      data.date = DateTime(data.date.year, data.date.month, data.date.day);
      final json = data.toJson();
      json['user_id'] = _userId;
      if (data.id == null) {
        await supabase.from('pregnancy_data').insert(json);
      } else {
        await supabase.from('pregnancy_data').update(json).eq('id', data.id!).eq('user_id', _userId);
      }
    } catch (e) {
      debugPrint("Save Pregnancy Error: $e");
    }
  }

  Future<void> deletePregnancyData(String id) async {
    try {
      await supabase.from('pregnancy_data').delete().eq('id', id).eq('user_id', _userId);
    } catch (e) {
      debugPrint("Delete Pregnancy Error: $e");
    }
  }

  // ========== Notifications History ==========

  Future<List<StoredNotification>> getAllNotifications() async {
    try {
      final response = await supabase
          .from('stored_notifications')
          .select()
          .eq('user_id', _userId)
          .order('timestamp', ascending: false);
      return response.map((e) => StoredNotification.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveNotification(StoredNotification notification) async {
    try {
      final data = notification.toJson();
      data['user_id'] = _userId;
      if (notification.id == null) {
        await supabase.from('stored_notifications').insert(data);
      } else {
        await supabase.from('stored_notifications').update(data).eq('id', notification.id!).eq('user_id', _userId);
      }
    } catch (e) {
      debugPrint("Save Notification Error: $e");
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await supabase.from('stored_notifications').update({'is_read': true}).eq('is_read', false).eq('user_id', _userId);
    } catch (e) {
      debugPrint("Mark All Read Error: $e");
    }
  }

  Future<void> clearNotificationHistory() async {
    try {
      await supabase.from('stored_notifications').delete().eq('user_id', _userId);
    } catch (e) {
      debugPrint("Clear Notifications Error: $e");
    }
  }

  Future<int> getUnreadNotificationCount() async {
    try {
      final count = await supabase.from('stored_notifications').select('id').eq('is_read', false).eq('user_id', _userId).count();
      return count.count;
    } catch (e) {
      return 0;
    }
  }

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
      if (cycleLength > 0 && cycleLength < 60) cycleLengths.add(cycleLength);

      if (current.endDate != null) {
        final periodLength = current.endDate!.difference(current.startDate).inDays + 1;
        if (periodLength > 0 && periodLength < 15) periodLengths.add(periodLength);
      }
    }

    return {
      'totalCycles': cycles.length,
      'averageCycleLength': cycleLengths.isEmpty
          ? 28 : (cycleLengths.reduce((a, b) => a + b) / cycleLengths.length).round(),
      'averagePeriodLength': periodLengths.isEmpty
          ? 5 : (periodLengths.reduce((a, b) => a + b) / periodLengths.length).round(),
      'shortestCycle': cycleLengths.isEmpty
          ? 0 : cycleLengths.reduce((a, b) => a < b ? a : b),
      'longestCycle': cycleLengths.isEmpty
          ? 0 : cycleLengths.reduce((a, b) => a > b ? a : b),
    };
  }

  // ========== Data Management ==========

  Future<int> clearAllDuplicates() async {
    // In SQL, we typically handle this with UNIQUE constraints.
    // We already have a UNIQUE(user_id, date) on health_logs.
    // For cycle logs, we'll keep it simple for now since it's hard to port Isar duplicate logic directly.
    return 0;
  }

  Future<void> clearAllData() async {
    try {
      await supabase.from('cycle_logs').delete().eq('user_id', _userId);
      await supabase.from('health_logs').delete().eq('user_id', _userId);
      await supabase.from('reminders').delete().eq('user_id', _userId);
      await supabase.from('pregnancy_data').delete().eq('user_id', _userId);
    } catch (e) {
      debugPrint("Clear Data Error: $e");
    }
  }

  Future<void> clearPredictions() async {
    await deleteAllPredictedCycles();
  }
}