/// Pure logic for cycle calculations.
/// This file contains no database or framework dependencies.
class CycleEngine {
  /// Predicts the next period start date.
  static DateTime calculateNextPeriod(DateTime lastPeriodStart, int averageCycleLength) {
    return lastPeriodStart.add(Duration(days: averageCycleLength));
  }

  /// Calculates the ovulation date.
  /// Standardly 14 days before the next expected period.
  static DateTime calculateOvulation(DateTime nextPeriodStart, int lutealPhaseLength) {
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
