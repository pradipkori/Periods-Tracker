import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:period_tracker/models/cycle_models.dart';
import 'package:period_tracker/services/database_service.dart';
import 'package:period_tracker/services/prediction_service.dart';
import 'package:period_tracker/services/push_notification_service.dart';
import 'package:period_tracker/services/notification_service.dart';
import 'package:period_tracker/services/analytics_service.dart';
import 'package:period_tracker/services/export_service.dart';

// ========== Service Providers ==========

// Database Service
final dbServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

// Prediction Service
final predictionServiceProvider = Provider<PredictionService>((ref) {
  final db = ref.watch(dbServiceProvider);
  return PredictionService(db);
});

// Notification Service
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final db = ref.watch(dbServiceProvider);
  final prediction = ref.watch(predictionServiceProvider);
  return NotificationService(db, prediction);
});

// Analytics Service
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  final db = ref.watch(dbServiceProvider);
  return AnalyticsService(db);
});

// Export Service
final exportServiceProvider = Provider<ExportService>((ref) {
  final db = ref.watch(dbServiceProvider);
  return ExportService(db);
});

// Push Notification Service
final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  final db = ref.watch(dbServiceProvider);
  return PushNotificationService(db);
});

// ========== Data Providers ==========

// User Settings
final settingsProvider = FutureProvider<UserSettings>((ref) async {
  final db = ref.watch(dbServiceProvider);
  return db.getSettings();
});

// All Cycles
final cyclesProvider = FutureProvider<List<CycleLog>>((ref) async {
  final db = ref.watch(dbServiceProvider);
  return await db.getAllCycles();
});

// Actual Cycles (non-predicted)
final actualCyclesProvider = FutureProvider<List<CycleLog>>((ref) async {
  final db = ref.watch(dbServiceProvider);
  return await db.getActualCycles();
});

// Latest Cycle
final latestCycleProvider = FutureProvider<CycleLog?>((ref) async {
  final db = ref.watch(dbServiceProvider);
  return await db.getLatestCycle();
});

// Cycle Statistics
final cycleStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final db = ref.watch(dbServiceProvider);
  return await db.getCycleStatistics();
});

// ========== Prediction Providers ==========

// Next Period Date
final nextPeriodProvider = FutureProvider<DateTime?>((ref) async {
  final prediction = ref.watch(predictionServiceProvider);
  return await prediction.predictNextPeriod();
});

// Ovulation Date
final ovulationDateProvider = FutureProvider<DateTime?>((ref) async {
  final prediction = ref.watch(predictionServiceProvider);
  return await prediction.predictOvulationDate();
});

// Fertile Window
final fertileWindowProvider = FutureProvider<Map<String, DateTime?>>((ref) async {
  final prediction = ref.watch(predictionServiceProvider);
  return await prediction.predictFertileWindow();
});

// Current Cycle Phase
final currentPhaseProvider = FutureProvider<String>((ref) async {
  final prediction = ref.watch(predictionServiceProvider);
  return await prediction.getCurrentCyclePhase();
});

// Current Cycle Day
final currentCycleDayProvider = FutureProvider<int?>((ref) async {
  final prediction = ref.watch(predictionServiceProvider);
  return await prediction.getCurrentCycleDay();
});

// Days Until Next Period
final daysUntilPeriodProvider = FutureProvider<int?>((ref) async {
  final prediction = ref.watch(predictionServiceProvider);
  return await prediction.getDaysUntilNextPeriod();
});

// Phase Insight
final phaseInsightProvider = FutureProvider<String>((ref) async {
  final prediction = ref.watch(predictionServiceProvider);
  return await prediction.getPhaseInsight();
});

// Home Status Message
final homeStatusProvider = FutureProvider<String>((ref) async {
  final prediction = ref.watch(predictionServiceProvider);
  return await prediction.getHomeStatusMessage();
});

// ========== Analytics Providers ==========

// Symptom Frequency
final symptomFrequencyProvider = FutureProvider<Map<String, int>>((ref) async {
  final analytics = ref.watch(analyticsServiceProvider);
  return await analytics.getSymptomFrequency();
});

// Mood Frequency
final moodFrequencyProvider = FutureProvider<Map<String, int>>((ref) async {
  final analytics = ref.watch(analyticsServiceProvider);
  return await analytics.getMoodFrequency();
});

// Personalized Insights
final insightsProvider = FutureProvider<List<String>>((ref) async {
  final analytics = ref.watch(analyticsServiceProvider);
  return await analytics.generateInsights();
});

// Health Score
final healthScoreProvider = FutureProvider<int>((ref) async {
  final analytics = ref.watch(analyticsServiceProvider);
  return await analytics.getHealthScore();
});

// Cycle Length Trend
final cycleLengthTrendProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final analytics = ref.watch(analyticsServiceProvider);
  return await analytics.getCycleLengthTrend();
});

// Period Length Trend
final periodLengthTrendProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final analytics = ref.watch(analyticsServiceProvider);
  return await analytics.getPeriodLengthTrend();
});

// Symptoms By Phase
final symptomsByPhaseProvider = FutureProvider<Map<String, List<String>>>((ref) async {
  final analytics = ref.watch(analyticsServiceProvider);
  return await analytics.getSymptomsByPhase();
});

// Mood Phase Correlation
final moodPhaseCorrelationProvider = FutureProvider<Map<String, Map<String, int>>>((ref) async {
  final analytics = ref.watch(analyticsServiceProvider);
  return await analytics.getMoodPhaseCorrelation();
});

// ========== Health Log Provider for Specific Date ==========

final healthLogProvider = FutureProvider.family<HealthLog?, DateTime>((ref, date) async {
  final db = ref.watch(dbServiceProvider);
  return await db.getHealthLog(date);
});

// ========== State Providers ==========

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// ========== Reminders Provider ==========

final remindersProvider = FutureProvider<List<Reminder>>((ref) async {
  final db = ref.watch(dbServiceProvider);
  return await db.getAllReminders();
});

// ========== Articles Provider ==========

final articlesProvider = FutureProvider<List<Article>>((ref) async {
  final db = ref.watch(dbServiceProvider);
  return await db.getAllArticles();
});
