import 'package:flutter_test/flutter_test.dart';
import 'package:period_tracker/logic/cycle_engine.dart';

void main() {
  group('CycleEngine Tests', () {
    test('calculateNextPeriod should return correct date', () {
      final lastPeriodStart = DateTime(2024, 1, 1);
      const averageCycleLength = 28;
      final expected = DateTime(2024, 1, 29);
      
      final result = CycleEngine.calculateNextPeriod(lastPeriodStart, averageCycleLength);
      
      expect(result, expected);
    });

    test('calculateOvulation should return correct date', () {
      final nextPeriodStart = DateTime(2024, 1, 29);
      const lutealPhaseLength = 14;
      final expected = DateTime(2024, 1, 15);
      
      final result = CycleEngine.calculateOvulation(nextPeriodStart, lutealPhaseLength);
      
      expect(result, expected);
    });

    test('calculateFertileWindow should return correct range', () {
      final ovulationDate = DateTime(2024, 1, 15);
      final expectedStart = DateTime(2024, 1, 10);
      final expectedEnd = DateTime(2024, 1, 16);
      
      final result = CycleEngine.calculateFertileWindow(ovulationDate);
      
      expect(result['start'], expectedStart);
      expect(result['end'], expectedEnd);
    });
  });
}
