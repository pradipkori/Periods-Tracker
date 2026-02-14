import 'package:period_tracker/models/cycle_models.dart';
import 'package:period_tracker/services/database_service.dart';
import 'package:period_tracker/utils/constants.dart';

class AnalyticsService {
  final DatabaseService _db;

  AnalyticsService(this._db);

  // Get comprehensive cycle analytics
  Future<Map<String, dynamic>> getCycleAnalytics() async {
    final stats = await _db.getCycleStatistics();
    final cycles = await _db.getActualCycles();

    return {
      ...stats,
      'cycleCount': cycles.length,
      'hasEnoughData': cycles.length >= 3,
    };
  }

  // Get symptom frequency analysis
  Future<Map<String, int>> getSymptomFrequency() async {
    final healthLogs = await _db.getHealthLogsInRange(
      DateTime.now().subtract(const Duration(days: 90)),
      DateTime.now(),
    );

    final frequency = <String, int>{};

    for (final log in healthLogs) {
      for (final symptom in log.symptoms) {
        frequency[symptom] = (frequency[symptom] ?? 0) + 1;
      }
    }

    // Sort by frequency
    final sortedEntries = frequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedEntries);
  }

  // Get mood frequency analysis
  Future<Map<String, int>> getMoodFrequency() async {
    final healthLogs = await _db.getHealthLogsInRange(
      DateTime.now().subtract(const Duration(days: 90)),
      DateTime.now(),
    );

    final frequency = <String, int>{};

    for (final log in healthLogs) {
      for (final mood in log.moods) {
        frequency[mood] = (frequency[mood] ?? 0) + 1;
      }
    }

    // Sort by frequency
    final sortedEntries = frequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedEntries);
  }

  // Get symptoms by cycle phase (Improved)
  Future<Map<String, List<String>>> getSymptomsByPhase() async {
    final cycles = await _db.getActualCycles();
    if (cycles.isEmpty) return {};

    final phaseSymptoms = <String, Map<String, int>>{
      AppConstants.phaseMenstrual: {},
      AppConstants.phaseFollicular: {},
      AppConstants.phaseOvulation: {},
      AppConstants.phaseLuteal: {},
    };

    final settings = await _db.getSettings();
    final lutealLength = settings.lutealPhaseLength;

    for (final cycle in cycles.take(10)) { // Analyze up to last 10 cycles
      final cycleStart = cycle.startDate;
      final cycleEnd = cycle.endDate ?? cycleStart.add(const Duration(days: 28));

      // Get health logs for this cycle
      final logs = await _db.getHealthLogsInRange(cycleStart, cycleEnd);
      
      // Calculate cycle length for this specific cycle or use average
      final nextCycle = cycles.indexOf(cycle) > 0 ? cycles[cycles.indexOf(cycle) - 1] : null;
      final cycleLength = nextCycle != null 
          ? nextCycle.startDate.difference(cycle.startDate).inDays 
          : settings.averageCycleLength;

      final ovulationDay = cycleLength - lutealLength;

      for (final log in logs) {
        final dayInCycle = log.date.difference(cycleStart).inDays + 1;
        String phase;

        if (dayInCycle <= (cycle.endDate != null ? cycle.endDate!.difference(cycle.startDate).inDays + 1 : 5)) {
          phase = AppConstants.phaseMenstrual;
        } else if (dayInCycle < ovulationDay - 2) {
          phase = AppConstants.phaseFollicular;
        } else if (dayInCycle <= ovulationDay + 2) {
          phase = AppConstants.phaseOvulation;
        } else {
          phase = AppConstants.phaseLuteal;
        }

        for (final symptom in log.symptoms) {
          phaseSymptoms[phase]![symptom] = (phaseSymptoms[phase]![symptom] ?? 0) + 1;
        }
      }
    }

    // Convert to top symptoms per phase
    final result = <String, List<String>>{};
    for (final entry in phaseSymptoms.entries) {
      final sortedSymptoms = entry.value.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      result[entry.key] = sortedSymptoms.take(5).map((e) => e.key).toList();
    }

    return result;
  }

  // Get mood correlation with cycle phases
  Future<Map<String, Map<String, int>>> getMoodPhaseCorrelation() async {
    final cycles = await _db.getActualCycles();
    if (cycles.isEmpty) return {};

    final correlations = <String, Map<String, int>>{
      AppConstants.phaseMenstrual: {},
      AppConstants.phaseFollicular: {},
      AppConstants.phaseOvulation: {},
      AppConstants.phaseLuteal: {},
    };

    final settings = await _db.getSettings();
    final lutealLength = settings.lutealPhaseLength;

    for (final cycle in cycles.take(10)) {
      final cycleStart = cycle.startDate;
      final cycleEnd = cycle.endDate ?? cycleStart.add(const Duration(days: 28));
      final logs = await _db.getHealthLogsInRange(cycleStart, cycleEnd);
      
      final nextCycle = cycles.indexOf(cycle) > 0 ? cycles[cycles.indexOf(cycle) - 1] : null;
      final cycleLength = nextCycle != null 
          ? nextCycle.startDate.difference(cycle.startDate).inDays 
          : settings.averageCycleLength;

      final ovulationDay = cycleLength - lutealLength;

      for (final log in logs) {
        final dayInCycle = log.date.difference(cycleStart).inDays + 1;
        String phase;

        if (dayInCycle <= (cycle.endDate != null ? cycle.endDate!.difference(cycle.startDate).inDays + 1 : 5)) {
          phase = AppConstants.phaseMenstrual;
        } else if (dayInCycle < ovulationDay - 2) {
          phase = AppConstants.phaseFollicular;
        } else if (dayInCycle <= ovulationDay + 2) {
          phase = AppConstants.phaseOvulation;
        } else {
          phase = AppConstants.phaseLuteal;
        }

        for (final mood in log.moods) {
          correlations[phase]![mood] = (correlations[phase]![mood] ?? 0) + 1;
        }
      }
    }

    return correlations;
  }

  // Get weight trend data
  Future<List<Map<String, dynamic>>> getWeightTrend({int days = 30}) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));
    final logs = await _db.getHealthLogsInRange(startDate, endDate);

    return logs
        .where((log) => log.weight != null)
        .map((log) => {
              'date': log.date,
              'weight': log.weight,
            })
        .toList();
  }

  // Get temperature trend data
  Future<List<Map<String, dynamic>>> getTemperatureTrend({int days = 30}) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days));
    final logs = await _db.getHealthLogsInRange(startDate, endDate);

    return logs
        .where((log) => log.temperature != null)
        .map((log) => {
              'date': log.date,
              'temperature': log.temperature,
            })
        .toList();
  }

  // Get cycle length trend (for chart)
  Future<List<Map<String, dynamic>>> getCycleLengthTrend() async {
    final cycles = await _db.getActualCycles();
    if (cycles.length < 2) return [];

    final trend = <Map<String, dynamic>>[];

    for (int i = 0; i < cycles.length - 1; i++) {
      final current = cycles[i];
      final next = cycles[i + 1];
      final length = current.startDate.difference(next.startDate).inDays.abs();

      if (length > 0 && length < 60) {
        trend.add({
          'cycleNumber': cycles.length - i,
          'length': length,
          'date': current.startDate,
        });
      }
    }

    return trend.reversed.toList();
  }

  // Get period length trend (for chart)
  Future<List<Map<String, dynamic>>> getPeriodLengthTrend() async {
    final cycles = await _db.getActualCycles();

    final trend = <Map<String, dynamic>>[];

    for (int i = 0; i < cycles.length; i++) {
      final cycle = cycles[i];
      if (cycle.endDate != null) {
        final length = cycle.endDate!.difference(cycle.startDate).inDays + 1;
        if (length > 0 && length < 15) {
          trend.add({
            'cycleNumber': cycles.length - i,
            'length': length,
            'date': cycle.startDate,
          });
        }
      }
    }

    return trend.reversed.toList();
  }

  // Generate personalized insights
  Future<List<String>> generateInsights() async {
    final insights = <String>[];
    final stats = await _db.getCycleStatistics();
    final symptomFreq = await getSymptomFrequency();
    final moodFreq = await getMoodFrequency();

    // Cycle regularity insight
    final avgCycleLength = stats['averageCycleLength'] as int;
    final shortestCycle = stats['shortestCycle'] as int;
    final longestCycle = stats['longestCycle'] as int;

    if (longestCycle > 0 && shortestCycle > 0) {
      final variation = longestCycle - shortestCycle;
      if (variation <= 3) {
        insights.add('✨ Your cycle is very regular! This makes predictions more accurate.');
      } else if (variation <= 7) {
        insights.add('📊 Your cycle shows normal variation. Keep tracking for better insights.');
      } else {
        insights.add('⚠️ Your cycle shows significant variation. Consider consulting a healthcare provider if this persists.');
      }
    }

    // Most common symptom
    if (symptomFreq.isNotEmpty) {
      final topSymptom = symptomFreq.entries.first;
      insights.add('🔍 Your most common symptom is "${topSymptom.key}" (logged ${topSymptom.value} times).');
    }

    // Most common mood
    if (moodFreq.isNotEmpty) {
      final topMood = moodFreq.entries.first;
      insights.add('😊 You most often feel "${topMood.key}" (logged ${topMood.value} times).');
    }

    // Cycle length insight
    if (avgCycleLength < 25) {
      insights.add('⏱️ Your cycle is shorter than average. This is normal for some people.');
    } else if (avgCycleLength > 32) {
      insights.add('⏱️ Your cycle is longer than average. This is normal for some people.');
    } else {
      insights.add('✅ Your average cycle length of $avgCycleLength days is within the normal range.');
    }

    // Period length insight
    final avgPeriodLength = stats['averagePeriodLength'] as int;
    if (avgPeriodLength < 3) {
      insights.add('📅 Your periods are shorter than average.');
    } else if (avgPeriodLength > 7) {
      insights.add('📅 Your periods are longer than average. Monitor for heavy flow.');
    }

    return insights;
  }

  // Get health score (0-100)
  Future<int> getHealthScore() async {
    int score = 50; // Base score

    final stats = await _db.getCycleStatistics();
    final cycles = await _db.getActualCycles();

    // Regularity bonus
    if (cycles.length >= 3) {
      final shortestCycle = stats['shortestCycle'] as int;
      final longestCycle = stats['longestCycle'] as int;
      final variation = longestCycle - shortestCycle;

      if (variation <= 3) {
        score += 20;
      } else if (variation <= 7) {
        score += 10;
      }
    }

    // Tracking consistency bonus
    final recentLogs = await _db.getHealthLogsInRange(
      DateTime.now().subtract(const Duration(days: 30)),
      DateTime.now(),
    );

    if (recentLogs.length >= 20) {
      score += 20;
    } else if (recentLogs.length >= 10) {
      score += 10;
    }

    // Data completeness bonus
    final logsWithSymptoms = recentLogs.where((log) => log.symptoms.isNotEmpty).length;
    if (logsWithSymptoms >= 15) {
      score += 10;
    }

    return score.clamp(0, 100);
  }
}
