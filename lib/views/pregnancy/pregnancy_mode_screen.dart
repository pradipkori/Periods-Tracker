import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:period_tracker/providers/app_providers.dart';
import 'package:period_tracker/theme/app_theme.dart';
import 'package:period_tracker/utils/date_utils.dart' as app_date_utils;

class PregnancyModeScreen extends ConsumerWidget {
  const PregnancyModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text("Pregnancy Mode", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: settingsAsync.when(
        data: (settings) {
          if (!settings.pregnancyMode || settings.conceptionDate == null) {
            return _buildEnablePregnancyMode(context, ref);
          }

          final week = _calculatePregnancyWeek(settings.conceptionDate!);
          final dueDate = settings.dueDate ?? _calculateDueDate(settings.conceptionDate!);
          final daysRemaining = dueDate.difference(DateTime.now()).inDays;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPregnancyHeader(week, daysRemaining),
                const SizedBox(height: 24),
                _buildWeekInfo(week),
                const SizedBox(height: 24),
                _buildDueDateCard(dueDate),
                const SizedBox(height: 24),
                _buildQuickStats(settings),
                const SizedBox(height: 24),
                _buildDisableButton(context, ref),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text("Error loading pregnancy data")),
      ),
    );
  }

  Widget _buildEnablePregnancyMode(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.pregnant_woman, size: 100, color: AppTheme.primary),
          const SizedBox(height: 24),
          Text(
            "Enable Pregnancy Mode",
            style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            "Track your pregnancy journey with personalized insights and information.",
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showEnableDialog(context, ref),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text("ENABLE PREGNANCY MODE", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPregnancyHeader(int week, int daysRemaining) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Week $week",
            style: GoogleFonts.outfit(fontSize: 48, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "$daysRemaining days until due date",
            style: GoogleFonts.outfit(fontSize: 16, color: Colors.white.withOpacity(0.9)),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekInfo(int week) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text(
                "This Week",
                style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _getWeeklyInfo(week),
            style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildDueDateCard(DateTime dueDate) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, color: AppTheme.accent, size: 32),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Due Date",
                style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textSecondary),
              ),
              Text(
                app_date_utils.DateUtils.formatDate(dueDate),
                style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quick Stats",
          style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _statCard("Trimester", _getTrimester(_calculatePregnancyWeek(settings.conceptionDate!)), Icons.timeline),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard("Weeks", "${_calculatePregnancyWeek(settings.conceptionDate!)}", Icons.calendar_month),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primary),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(label, style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildDisableButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => _disablePregnancyMode(context, ref),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          side: const BorderSide(color: Colors.red),
        ),
        child: Text("DISABLE PREGNANCY MODE", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
      ),
    );
  }

  Future<void> _showEnableDialog(BuildContext context, WidgetRef ref) async {
    DateTime conceptionDate = DateTime.now();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enable Pregnancy Mode"),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("When did you conceive or when was your last period?"),
              const SizedBox(height: 16),
              ListTile(
                title: const Text("Conception Date"),
                subtitle: Text(app_date_utils.DateUtils.formatDate(conceptionDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: conceptionDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 280)),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => conceptionDate = picked);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final db = ref.read(dbServiceProvider);
              final settings = await db.getSettings();
              settings.pregnancyMode = true;
              settings.conceptionDate = conceptionDate;
              settings.dueDate = _calculateDueDate(conceptionDate);
              await db.saveSettings(settings);
              ref.invalidate(settingsProvider);
              Navigator.pop(context);
            },
            child: const Text("Enable"),
          ),
        ],
      ),
    );
  }

  Future<void> _disablePregnancyMode(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Disable Pregnancy Mode"),
        content: const Text("Are you sure you want to disable pregnancy mode?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Disable", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final db = ref.read(dbServiceProvider);
      final settings = await db.getSettings();
      settings.pregnancyMode = false;
      settings.conceptionDate = null;
      settings.dueDate = null;
      await db.saveSettings(settings);
      ref.invalidate(settingsProvider);
    }
  }

  int _calculatePregnancyWeek(DateTime conceptionDate) {
    final days = DateTime.now().difference(conceptionDate).inDays;
    return (days / 7).floor();
  }

  DateTime _calculateDueDate(DateTime conceptionDate) {
    return conceptionDate.add(const Duration(days: 280));
  }

  String _getTrimester(int week) {
    if (week <= 13) return "First";
    if (week <= 27) return "Second";
    return "Third";
  }

  String _getWeeklyInfo(int week) {
    if (week <= 4) {
      return "Your baby is just beginning to develop. The embryo is about the size of a poppy seed.";
    } else if (week <= 8) {
      return "Your baby's heart is beating and major organs are forming. About the size of a raspberry.";
    } else if (week <= 13) {
      return "Your baby is now a fetus! Fingers and toes are forming. About the size of a lime.";
    } else if (week <= 20) {
      return "You might feel your baby move! They're about the size of a banana.";
    } else if (week <= 27) {
      return "Your baby can hear sounds and is developing sleep patterns. About the size of a cauliflower.";
    } else if (week <= 36) {
      return "Your baby is gaining weight and preparing for birth. About the size of a pineapple.";
    } else {
      return "Your baby is full term and ready to meet you! About the size of a watermelon.";
    }
  }
}
