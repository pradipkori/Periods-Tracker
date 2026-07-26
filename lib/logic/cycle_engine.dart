import 'package:period_tracker/models/cycle_models.dart';

/// Pure logic for cycle calculations.
/// This file contains no database or framework dependencies.
class CycleEngine {
  /// Predicts the next period start date.
  static DateTime calculateNextPeriod(DateTime lastPeriodStart, int averageCycleLength) {
    return lastPeriodStart.add(Duration(days: averageCycleLength));
  }

  /// Calculates the ovulation date.
  /// Standardly 14 days before the next expected period, but overridden by biological markers.
  static DateTime calculateOvulation(
      DateTime nextPeriodStart, 
      int lutealPhaseLength,
      {List<HealthLog> recentLogs = const []}) {
    
    if (recentLogs.isNotEmpty) {
      final sortedLogs = List<HealthLog>.from(recentLogs)
        ..sort((a, b) => b.date.compareTo(a.date));

      // 1. Ovulation Test Override (OPK)
      final positiveTest = sortedLogs.where((log) => 
        log.ovulationTestResult?.toLowerCase() == 'positive').toList();
      
      if (positiveTest.isNotEmpty) {
        // Ovulation typically occurs 12-36 hours after a positive OPK
        return positiveTest.first.date.add(const Duration(days: 1));
      }

      // 2. Basal Body Temperature (BBT) Spike Override
      // Look for a temp spike of >= 0.4 over 2-3 days confirming ovulation
      for (int i = 0; i < sortedLogs.length - 2; i++) {
        final currentTemp = sortedLogs[i].temperature;
        final pastTemp = sortedLogs[i+2].temperature;
        
        if (currentTemp != null && pastTemp != null) {
          if (currentTemp - pastTemp >= 0.4) {
            // Spike detected! Ovulation likely happened right before the spike
            return sortedLogs[i+2].date;
          }
        }
      }
    }

    // Default Fallback: Standard calendar math
    return nextPeriodStart.subtract(Duration(days: lutealPhaseLength));
  }

  /// Calculates the fertile window.
  /// Typically 5 days before ovulation, the day of ovulation, and 1 day after.
  static Map<String, DateTime> calculateFertileWindow(DateTime ovulationDate) {
    return {
      'start': ovulationDate.subtract(const Duration(days: 5)),
      'end': ovulationDate.add(const Duration(days: 1)),
    };
  }
}
