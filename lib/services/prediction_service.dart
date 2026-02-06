import 'package:period_tracker/logic/cycle_engine.dart';
import 'package:period_tracker/models/cycle_models.dart';
import 'package:period_tracker/services/database_service.dart';
import 'package:period_tracker/utils/constants.dart';
import 'package:period_tracker/utils/insights_data.dart';

class PredictionService {
  final DatabaseService _db;

  PredictionService(this._db);

  // Calculate next period date based on cycle history
  Future<DateTime?> predictNextPeriod() async {
    final cycles = await _db.getActualCycles();
    final settings = await _db.getSettings();

    if (cycles.isEmpty) {
      if (settings.lastPeriodDate != null) {
        final cycleLength = await getEffectiveCycleLength();
        final result = CycleEngine.calculateNextPeriod(
          settings.lastPeriodDate!,
          cycleLength,
        );
        print('DEBUG: No cycles, using settings date with effective length: $cycleLength -> Next: $result');
        return result;
      }
      return null;
    }

    final latestCycle = cycles.firstWhere(
      (c) => !c.startDate.isAfter(DateTime.now()),
      orElse: () => cycles.first,
    );
    
    final cycleLength = await getEffectiveCycleLength();
    final result = CycleEngine.calculateNextPeriod(latestCycle.startDate, cycleLength);
    print('DEBUG: Latest actual cycle: ${latestCycle.startDate}. Effective cycle length: $cycleLength. Predicted next period: $result');
    return result;
  }

  // Source of truth for cycle length used in predictions
  Future<int> getEffectiveCycleLength() async {
    final cycles = await _db.getActualCycles();
    final settings = await _db.getSettings();

    // If there is very little data (less than 3 cycles), 
    // the user's manual settings are usually more reliable than a single interval.
    if (cycles.length < 3) {
      return settings.averageCycleLength;
    }

    final stats = await _db.getCycleStatistics();
    int calculatedAvg = stats['averageCycleLength'] as int;

    // Safety check: ensure cycleLength is realistic (21-45 days)
    // If not, fall back to user settings or standard 28
    if (calculatedAvg < 21 || calculatedAvg > 45) {
      return settings.averageCycleLength > 0 ? settings.averageCycleLength : 28;
    }

    return calculatedAvg;
  }

  // Calculate ovulation date
  Future<DateTime?> predictOvulationDate() async {
    final nextPeriod = await predictNextPeriod();
    if (nextPeriod == null) return null;

    final settings = await _db.getSettings();
    final result = CycleEngine.calculateOvulation(nextPeriod, settings.lutealPhaseLength);
    print('DEBUG: Next period: $nextPeriod. Luteal phase: ${settings.lutealPhaseLength}. Predicted ovulation: $result');
    return result;
  }

  // Calculate fertile window
  Future<Map<String, DateTime?>> predictFertileWindow() async {
    final ovulationDate = await predictOvulationDate();
    if (ovulationDate == null) {
      return {'start': null, 'end': null};
    }

    final window = CycleEngine.calculateFertileWindow(ovulationDate);
    print('DEBUG: Ovulation: $ovulationDate. Fertile window: ${window['start']} to ${window['end']}');
    return {
      'start': window['start'],
      'end': window['end'],
    };
  }

  // Determine current cycle phase
  Future<String> getCurrentCyclePhase() async {
    final cycles = await _db.getActualCycles();
    if (cycles.isEmpty) return AppConstants.phaseFollicular;

    final now = DateTime.now();
    // Find the latest cycle that has already started
    final currentCycle = cycles.firstWhere(
      (c) => !c.startDate.isAfter(now),
      orElse: () => cycles.first,
    );

    // If the "latest" cycle is still in the future, we are in the follicular phase of the "previous" logic
    if (currentCycle.startDate.isAfter(now)) {
      return AppConstants.phaseFollicular;
    }

    // Check if currently on period
    if (currentCycle.endDate == null || now.isBefore(currentCycle.endDate!) || 
        (now.day == currentCycle.endDate!.day && now.month == currentCycle.endDate!.month)) {
      if (now.difference(currentCycle.startDate).inDays < 10) { // Safety: period usually < 10 days
         return AppConstants.phaseMenstrual;
      }
    }

    final settings = await _db.getSettings();
    final cycleLength = await getEffectiveCycleLength();
    final cycleDay = now.difference(currentCycle.startDate).inDays + 1;
    final ovulationDay = cycleLength - settings.lutealPhaseLength;

    if (cycleDay < ovulationDay - 2) {
      return AppConstants.phaseFollicular;
    } else if (cycleDay >= ovulationDay - 2 && cycleDay <= ovulationDay + 2) {
      return AppConstants.phaseOvulation;
    } else {
      return AppConstants.phaseLuteal;
    }
  }

  // Get current cycle day
  Future<int?> getCurrentCycleDay() async {
    final cycles = await _db.getActualCycles();
    if (cycles.isEmpty) return null;

    final now = DateTime.now();
    // Find the latest cycle that has already started
    final currentCycle = cycles.firstWhere(
      (c) => !c.startDate.isAfter(now),
      orElse: () => cycles.first,
    );

    final diff = now.difference(currentCycle.startDate).inDays + 1;
    // If it's a future cycle, return 0 or null to indicate "not started"
    return diff > 0 ? diff : null;
  }

  // Calculate days until next period
  Future<int?> getDaysUntilNextPeriod() async {
    final nextPeriod = await predictNextPeriod();
    if (nextPeriod == null) return null;

    final now = DateTime.now();
    final diff = nextPeriod.difference(now).inDays;
    
    // If next period is today or in the past (but no new cycle logged), return 0
    return diff > 0 ? diff : 0;
  }

  // Get dynamic status message for Home Screen
  Future<String> getHomeStatusMessage() async {
    final phase = await getCurrentCyclePhase();
    final day = await getCurrentCycleDay();
    
    if (day == null) return "Ready";

    if (phase == AppConstants.phaseMenstrual) {
      return "Period\nDay $day";
    }

    final ovulationDate = await predictOvulationDate();
    final fertileWindow = await predictFertileWindow();
    final now = DateTime.now();

    if (ovulationDate != null) {
      final today = DateTime(now.year, now.month, now.day);
      final ovulationDay = DateTime(ovulationDate.year, ovulationDate.month, ovulationDate.day);
      
      if (today.isBefore(ovulationDay)) {
        final daysUntilOvulation = ovulationDay.difference(today).inDays;
        return "Ovulation in\n$daysUntilOvulation days";
      } else if (today.isAtSameMomentAs(ovulationDay)) {
        return "Ovulation\nDay";
      }
    }

    if (fertileWindow['end'] != null) {
      final end = fertileWindow['end']!;
      if (!now.isAfter(end)) {
        return "Fertile\nWindow";
      }
    }

    final daysUntilPeriod = await getDaysUntilNextPeriod();
    if (daysUntilPeriod != null && daysUntilPeriod > 0) {
      return "Period in\n$daysUntilPeriod days";
    }

    return "Cycle\nDay $day";
  }

  // Calculate pregnancy probability for a given date
  Future<String> getPregnancyProbability(DateTime date) async {
    final fertileWindow = await predictFertileWindow();
    final start = fertileWindow['start'];
    final end = fertileWindow['end'];

    if (start == null || end == null) return 'low';

    final ovulationDate = await predictOvulationDate();
    if (ovulationDate == null) return 'low';

    if (date.isBefore(start) || date.isAfter(end)) {
      return 'low';
    }

    // Days relative to ovulation
    final daysToOvulation = date.difference(ovulationDate).inDays.abs();

    if (daysToOvulation == 0) {
      return 'very_high';
    } else if (daysToOvulation <= 1) {
      return 'high';
    } else if (daysToOvulation <= 3) {
      return 'medium';
    } else {
      return 'low';
    }
  }

  // Check if a date is in fertile window
  Future<bool> isInFertileWindow(DateTime date) async {
    final fertileWindow = await predictFertileWindow();
    final start = fertileWindow['start'];
    final end = fertileWindow['end'];

    if (start == null || end == null) return false;

    final dateOnly = DateTime(date.year, date.month, date.day);
    final startOnly = DateTime(start.year, start.month, start.day);
    final endOnly = DateTime(end.year, end.month, end.day);

    return (dateOnly.isAfter(startOnly) || dateOnly.isAtSameMomentAs(startOnly)) &&
           (dateOnly.isBefore(endOnly) || dateOnly.isAtSameMomentAs(endOnly));
  }

  // Check if a date is a period day
  Future<bool> isPeriodDay(DateTime date) async {
    final cycle = await _db.getCycleByDate(date);
    return cycle != null && !cycle.isPredicted;
  }

  // Check if a date is a predicted period day
  Future<bool> isPredictedPeriodDay(DateTime date) async {
    final cycle = await _db.getCycleByDate(date);
    return cycle != null && cycle.isPredicted;
  }

  // Generate predictions for next N cycles
  Future<void> generatePredictions({int numberOfCycles = 3}) async {
    // Clear existing predictions
    await _db.clearPredictions();

    final cycles = await _db.getActualCycles();
    final settings = await _db.getSettings();
    
    final avgCycleLength = await getEffectiveCycleLength();
    int avgPeriodLength = settings.averagePeriodLength;
    
    if (cycles.length >= 2) {
      final stats = await _db.getCycleStatistics();
      avgPeriodLength = stats['averagePeriodLength'] as int;
    }

    final initialPrediction = await predictNextPeriod();
    if (initialPrediction == null) return;

    DateTime nextPeriodStart = initialPrediction;

    for (int i = 0; i < numberOfCycles; i++) {
      final periodEnd = nextPeriodStart.add(Duration(days: avgPeriodLength - 1));

      final predictedCycle = CycleLog(
        startDate: nextPeriodStart,
        endDate: periodEnd,
        isPredicted: true,
      );

      await _db.saveCycle(predictedCycle);

      // Calculate next cycle start using CycleEngine
      nextPeriodStart = CycleEngine.calculateNextPeriod(nextPeriodStart, avgCycleLength);
    }
  }

  // Check cycle regularity
  Future<Map<String, dynamic>> checkCycleRegularity() async {
    final cycles = await _db.getActualCycles();

    if (cycles.length < 3) {
      return {
        'isRegular': true,
        'message': 'Not enough data to determine regularity',
        'variation': 0,
      };
    }

    final cycleLengths = <int>[];
    for (int i = 0; i < cycles.length - 1; i++) {
      final current = cycles[i];
      final next = cycles[i + 1];
      final length = current.startDate.difference(next.startDate).inDays.abs();
      if (length > 0 && length < 60) {
        cycleLengths.add(length);
      }
    }

    if (cycleLengths.isEmpty) {
      return {
        'isRegular': true,
        'message': 'Not enough valid cycles',
        'variation': 0,
      };
    }

    final avg = cycleLengths.reduce((a, b) => a + b) / cycleLengths.length;
    final maxVariation = cycleLengths.map((l) => (l - avg).abs()).reduce((a, b) => a > b ? a : b);

    final isRegular = maxVariation <= AppConstants.regularCycleVariation;

    return {
      'isRegular': isRegular,
      'message': isRegular
          ? 'Your cycle is regular'
          : 'Your cycle shows some irregularity',
      'variation': maxVariation.round(),
    };
  }

  // Get personalized insight based on cycle phase
  Future<String> getPhaseInsight() async {
    final phase = await getCurrentCyclePhase();
    final day = await getCurrentCycleDay() ?? 1;

    return InsightsData.getInsight(phase, day);
  }

  // Calculate due date for pregnancy
  DateTime calculateDueDate(DateTime conceptionDate) {
    return conceptionDate.add(const Duration(days: AppConstants.pregnancyDays));
  }

  // Calculate pregnancy week
  int calculatePregnancyWeek(DateTime conceptionDate) {
    final now = DateTime.now();
    final days = now.difference(conceptionDate).inDays;
    return (days / 7).floor();
  }
}
