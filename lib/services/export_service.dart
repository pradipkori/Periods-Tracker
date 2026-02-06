import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:period_tracker/models/cycle_models.dart';
import 'package:period_tracker/services/database_service.dart';
import 'package:period_tracker/utils/date_utils.dart' as app_date_utils;
import 'package:share_plus/share_plus.dart';
import 'dart:convert';

class ExportService {
  final DatabaseService _db;

  ExportService(this._db);

  // Export data to PDF
  Future<File> exportToPdf() async {
    final pdf = pw.Document();
    final cycles = await _db.getActualCycles();
    final stats = await _db.getCycleStatistics();
    final settings = await _db.getSettings();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          // Header
          pw.Header(
            level: 0,
            child: pw.Text(
              'Period Tracker Report',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),

          // User Info
          pw.Text(
            'User: ${settings.userName}',
            style: pw.TextStyle(fontSize: 14),
          ),
          pw.Text(
            'Report Generated: ${app_date_utils.DateUtils.formatDate(DateTime.now())}',
            style: pw.TextStyle(fontSize: 12),
          ),
          pw.SizedBox(height: 20),

          // Statistics
          pw.Header(level: 1, child: pw.Text('Cycle Statistics')),
          pw.Table.fromTextArray(
            data: [
              ['Metric', 'Value'],
              ['Total Cycles Tracked', '${stats['totalCycles']}'],
              ['Average Cycle Length', '${stats['averageCycleLength']} days'],
              ['Average Period Length', '${stats['averagePeriodLength']} days'],
              ['Shortest Cycle', '${stats['shortestCycle']} days'],
              ['Longest Cycle', '${stats['longestCycle']} days'],
            ],
          ),
          pw.SizedBox(height: 20),

          // Cycle History
          pw.Header(level: 1, child: pw.Text('Cycle History')),
          pw.Table.fromTextArray(
            headers: ['Start Date', 'End Date', 'Duration'],
            data: cycles.take(10).map((cycle) {
              final duration = cycle.endDate != null
                  ? '${cycle.endDate!.difference(cycle.startDate).inDays + 1} days'
                  : 'Ongoing';
              return [
                app_date_utils.DateUtils.formatDate(cycle.startDate),
                cycle.endDate != null
                    ? app_date_utils.DateUtils.formatDate(cycle.endDate!)
                    : '-',
                duration,
              ];
            }).toList(),
          ),
        ],
      ),
    );

    // Save to file
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/period_tracker_report.pdf');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  // Export data to CSV
  Future<File> exportToCsv() async {
    final cycles = await _db.getActualCycles();
    final buffer = StringBuffer();

    // Header
    buffer.writeln('Start Date,End Date,Duration (days),Flow Intensity,Notes');

    // Data rows
    for (final cycle in cycles) {
      final duration = cycle.endDate != null
          ? cycle.endDate!.difference(cycle.startDate).inDays + 1
          : '';
      buffer.writeln(
        '${app_date_utils.DateUtils.formatDate(cycle.startDate)},'
        '${cycle.endDate != null ? app_date_utils.DateUtils.formatDate(cycle.endDate!) : ''},'
        '$duration,'
        '${cycle.flowIntensity ?? ''},'
        '"${cycle.notes?.replaceAll('"', '""') ?? ''}"',
      );
    }

    // Save to file
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/period_tracker_data.csv');
    await file.writeAsString(buffer.toString());

    return file;
  }

  // Export data to JSON (for backup)
  Future<File> exportToJson() async {
    final cycles = await _db.getAllCycles();
    final healthLogs = await _db.getHealthLogsInRange(
      DateTime.now().subtract(const Duration(days: 365)),
      DateTime.now(),
    );
    final settings = await _db.getSettings();
    final reminders = await _db.getAllReminders();

    final data = {
      'exportDate': DateTime.now().toIso8601String(),
      'version': '1.0',
      'settings': {
        'userName': settings.userName,
        'averageCycleLength': settings.averageCycleLength,
        'averagePeriodLength': settings.averagePeriodLength,
        'lutealPhaseLength': settings.lutealPhaseLength,
        'lastPeriodDate': settings.lastPeriodDate?.toIso8601String(),
        'notificationsEnabled': settings.notificationsEnabled,
        'pregnancyMode': settings.pregnancyMode,
      },
      'cycles': cycles.map((c) => {
        'startDate': c.startDate.toIso8601String(),
        'endDate': c.endDate?.toIso8601String(),
        'flowIntensity': c.flowIntensity,
        'flowType': c.flowType,
        'notes': c.notes,
        'symptoms': c.symptoms,
        'moods': c.moods,
        'isPredicted': c.isPredicted,
      }).toList(),
      'healthLogs': healthLogs.map((h) => {
        'date': h.date.toIso8601String(),
        'weight': h.weight,
        'temperature': h.temperature,
        'waterIntake': h.waterIntake,
        'sleepDuration': h.sleepDuration,
        'exerciseDuration': h.exerciseDuration,
        'symptoms': h.symptoms,
        'moods': h.moods,
        'medications': h.medications,
        'hadIntimacy': h.hadIntimacy,
        'protectedIntimacy': h.protectedIntimacy,
        'dischargeType': h.dischargeType,
        'cervicalMucus': h.cervicalMucus,
        'ovulationTestResult': h.ovulationTestResult,
        'pregnancyTestResult': h.pregnancyTestResult,
        'dailyNote': h.dailyNote,
      }).toList(),
      'reminders': reminders.map((r) => {
        'title': r.title,
        'type': r.type,
        'reminderDate': r.reminderDate.toIso8601String(),
        'hourOfDay': r.hourOfDay,
        'minute': r.minute,
        'isEnabled': r.isEnabled,
        'isRepeating': r.isRepeating,
        'notes': r.notes,
      }).toList(),
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(data);

    // Save to file
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/period_tracker_backup.json');
    await file.writeAsString(jsonString);

    return file;
  }

  // Share PDF report
  Future<void> sharePdfReport() async {
    final file = await exportToPdf();
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Period Tracker Report',
      text: 'My period tracking report',
    );
  }

  // Share CSV data
  Future<void> shareCsvData() async {
    final file = await exportToCsv();
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Period Tracker Data',
      text: 'My period tracking data',
    );
  }

  // Share JSON backup
  Future<void> shareJsonBackup() async {
    final file = await exportToJson();
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Period Tracker Backup',
      text: 'My period tracker backup file',
    );
  }

  // Restore from JSON backup
  Future<bool> restoreFromJson(File file) async {
    try {
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // Clear existing data (optional - you might want to ask user first)
      // await _db.clearAllData();

      // Restore settings
      final settingsData = data['settings'] as Map<String, dynamic>;
      final settings = await _db.getSettings();
      settings.userName = settingsData['userName'] as String;
      settings.averageCycleLength = settingsData['averageCycleLength'] as int;
      settings.averagePeriodLength = settingsData['averagePeriodLength'] as int;
      settings.lutealPhaseLength = settingsData['lutealPhaseLength'] as int;
      if (settingsData['lastPeriodDate'] != null) {
        settings.lastPeriodDate = DateTime.parse(settingsData['lastPeriodDate'] as String);
      }
      await _db.saveSettings(settings);

      // Restore cycles
      final cyclesData = data['cycles'] as List<dynamic>;
      for (final cycleData in cyclesData) {
        final cycle = CycleLog(
          startDate: DateTime.parse(cycleData['startDate'] as String),
          endDate: cycleData['endDate'] != null
              ? DateTime.parse(cycleData['endDate'] as String)
              : null,
          flowIntensity: cycleData['flowIntensity'] as int?,
          flowType: cycleData['flowType'] as String?,
          notes: cycleData['notes'] as String?,
          isPredicted: cycleData['isPredicted'] as bool? ?? false,
        );
        cycle.symptoms = List<String>.from(cycleData['symptoms'] ?? []);
        cycle.moods = List<String>.from(cycleData['moods'] ?? []);
        await _db.saveCycle(cycle);
      }

      // Restore health logs
      final healthLogsData = data['healthLogs'] as List<dynamic>;
      for (final logData in healthLogsData) {
        final log = HealthLog(
          date: DateTime.parse(logData['date'] as String),
          weight: logData['weight'] as double?,
          temperature: logData['temperature'] as double?,
          waterIntake: logData['waterIntake'] as int?,
          sleepDuration: logData['sleepDuration'] as int?,
          exerciseDuration: logData['exerciseDuration'] as int?,
          dailyNote: logData['dailyNote'] as String?,
        );
        log.symptoms = List<String>.from(logData['symptoms'] ?? []);
        log.moods = List<String>.from(logData['moods'] ?? []);
        log.medications = List<String>.from(logData['medications'] ?? []);
        log.hadIntimacy = logData['hadIntimacy'] as bool?;
        log.protectedIntimacy = logData['protectedIntimacy'] as bool?;
        log.dischargeType = logData['dischargeType'] as String?;
        log.cervicalMucus = logData['cervicalMucus'] as String?;
        log.ovulationTestResult = logData['ovulationTestResult'] as String?;
        log.pregnancyTestResult = logData['pregnancyTestResult'] as String?;
        await _db.saveHealthLog(log);
      }

      return true;
    } catch (e) {
      print('Error restoring from backup: $e');
      return false;
    }
  }
}
