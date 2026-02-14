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

  // Export data to PDF with modern styling
  Future<File> exportToPdf() async {
    final pdf = pw.Document();
    final cycles = await _db.getActualCycles();
    final stats = await _db.getCycleStatistics();
    final settings = await _db.getSettings();

    // Brand Colors
    const primaryColor = PdfColor.fromInt(0xFFFF7EB3);
    const secondaryColor = PdfColor.fromInt(0xFF8B5CF6);
    const textColor = PdfColor.fromInt(0xFF2D3142);
    const lightTextColor = PdfColor.fromInt(0xFF9EA3B0);
    const bgColor = PdfColor.fromInt(0xFFFDFAFB);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(bottom: 20),
          child: pw.Text(
            'PERIOD TRACKER REPORT',
            style: pw.TextStyle(
              color: PdfColor(primaryColor.red * 0.4, primaryColor.green * 0.4, primaryColor.blue * 0.4),
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 20),
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(color: lightTextColor, fontSize: 10),
          ),
        ),
        build: (context) => [
          // Elegant Header Section
          pw.Container(
            padding: const pw.EdgeInsets.all(30),
            decoration: pw.BoxDecoration(
              color: primaryColor,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(20)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Health Insights',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'Personalized report for ${settings.userName}',
                      style: const pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      app_date_utils.DateUtils.formatDate(DateTime.now()),
                      style: const pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 12,
                      ),
                    ),
                    pw.Text(
                      'v1.0.0',
                      style: pw.TextStyle(
                        color: PdfColor(1, 1, 1, 0.7),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 30),

          // Overview Section
          pw.Text(
            'CYCLE SNAPSHOT',
            style: pw.TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          pw.SizedBox(height: 15),
          pw.Row(
            children: [
              _buildStatCard('Avg Cycle', '${stats['averageCycleLength']} Days', primaryColor),
              pw.SizedBox(width: 15),
              _buildStatCard('Avg Period', '${stats['averagePeriodLength']} Days', secondaryColor),
              pw.SizedBox(width: 15),
              _buildStatCard('Total Cycles', '${stats['totalCycles']}', const PdfColor.fromInt(0xFFFFD166)),
            ],
          ),
          pw.SizedBox(height: 30),

          // Detailed Stats Table
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(15)),
              border: pw.Border.all(color: PdfColors.grey200),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Range Analysis',
                  style: pw.TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Divider(color: PdfColors.grey200, height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Shortest Recorded Cycle', style: const pw.TextStyle(color: lightTextColor)),
                    pw.Text('${stats['shortestCycle']} Days', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Longest Recorded Cycle', style: const pw.TextStyle(color: lightTextColor)),
                    pw.Text('${stats['longestCycle']} Days', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 30),

          // Cycle History Section
          pw.Text(
            'RECENT HISTORY',
            style: pw.TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          pw.SizedBox(height: 15),
          pw.TableHelper.fromTextArray(
            border: null,
            headerStyle: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
            ),
            headerDecoration: pw.BoxDecoration(
              color: primaryColor,
              borderRadius: const pw.BorderRadius.only(
                topLeft: pw.Radius.circular(10),
                topRight: pw.Radius.circular(10),
              ),
            ),
            rowDecoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5)),
            ),
            cellAlignment: pw.Alignment.centerLeft,
            cellStyle: const pw.TextStyle(fontSize: 10, color: textColor),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(1),
            },
            headers: ['START DATE', 'END DATE', 'DURATION'],
            data: cycles.take(15).map((cycle) {
              final duration = cycle.endDate != null
                  ? '${cycle.endDate!.difference(cycle.startDate).inDays + 1} days'
                  : 'Active';
              return [
                app_date_utils.DateUtils.formatDate(cycle.startDate).toUpperCase(),
                cycle.endDate != null
                    ? app_date_utils.DateUtils.formatDate(cycle.endDate!).toUpperCase()
                    : '-',
                duration,
              ];
            }).toList(),
          ),
          
          pw.SizedBox(height: 40),
          pw.Divider(color: PdfColors.grey300),
          pw.SizedBox(height: 10),
          pw.Center(
            child: pw.Text(
              'Generated securely by Period Tracker App on ${app_date_utils.DateUtils.formatDate(DateTime.now())}',
              style: const pw.TextStyle(color: lightTextColor, fontSize: 8),
            ),
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

  pw.Widget _buildStatCard(String label, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(15)),
          border: pw.Border.all(color: PdfColor(color.red, color.green, color.blue, 0.3), width: 1),
        ),
        child: pw.Column(
          children: [
            pw.Text(
              label,
              style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 9),
            ),
            pw.SizedBox(height: 5),
            pw.Text(
              value,
              style: pw.TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
