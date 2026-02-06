import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:period_tracker/providers/app_providers.dart';
import 'package:period_tracker/theme/app_theme.dart';
import 'package:period_tracker/models/cycle_models.dart';
import 'package:period_tracker/utils/constants.dart';

class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  @override
  Widget build(BuildContext context) {
    final remindersAsync = ref.watch(remindersProvider);
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text("Reminders", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddReminderDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // System Reminders
            settingsAsync.when(
              data: (settings) => _buildSystemReminders(settings),
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),

            // Custom Reminders
            Text(
              "Custom Reminders",
              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            remindersAsync.when(
              data: (reminders) => reminders.isEmpty
                  ? _buildEmptyState()
                  : Column(
                      children: reminders.map((reminder) => _buildReminderCard(reminder)).toList(),
                    ),
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const Text("Error loading reminders"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemReminders(settings) {
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
          Text(
            "System Reminders",
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildSystemReminderToggle(
            "Period Reminder",
            "Get notified 1 day before your period",
            settings.periodReminderEnabled,
            (value) => _toggleSystemReminder('period', value),
          ),
          const Divider(height: 32),
          _buildSystemReminderToggle(
            "Ovulation Reminder",
            "Get notified on your ovulation day",
            settings.ovulationReminderEnabled,
            (value) => _toggleSystemReminder('ovulation', value),
          ),
          const Divider(height: 32),
          _buildSystemReminderToggle(
            "Daily Log Reminder",
            "Daily reminder to log your health data",
            settings.dailyLogReminderEnabled,
            (value) => _toggleSystemReminder('daily', value),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemReminderToggle(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          activeColor: AppTheme.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildReminderCard(Reminder reminder) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getReminderIcon(reminder.type),
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  '${reminder.hourOfDay.toString().padLeft(2, '0')}:${reminder.minute.toString().padLeft(2, '0')}',
                  style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          Switch(
            value: reminder.isEnabled,
            activeColor: AppTheme.primary,
            onChanged: (value) => _toggleReminder(reminder.id, value),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _deleteReminder(reminder.id),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(Icons.notifications_none, size: 64, color: AppTheme.textSecondary),
          const SizedBox(height: 16),
          Text(
            "No custom reminders yet",
            style: GoogleFonts.outfit(fontSize: 16, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            "Tap + to add a reminder",
            style: GoogleFonts.outfit(fontSize: 14, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  IconData _getReminderIcon(String type) {
    switch (type) {
      case AppConstants.notificationTypePeriod:
        return Icons.water_drop;
      case AppConstants.notificationTypeOvulation:
        return Icons.favorite;
      case AppConstants.notificationTypeMedication:
        return Icons.medication;
      default:
        return Icons.notifications;
    }
  }



  Future<void> _toggleSystemReminder(String type, bool value) async {
    final db = ref.read(dbServiceProvider);
    final settings = await db.getSettings();

    switch (type) {
      case 'period':
        settings.periodReminderEnabled = value;
        break;
      case 'ovulation':
        settings.ovulationReminderEnabled = value;
        break;
      case 'daily':
        settings.dailyLogReminderEnabled = value;
        break;
    }

    await db.saveSettings(settings);
    ref.invalidate(settingsProvider);

    // Reschedule notifications
    final notificationService = ref.read(notificationServiceProvider);
    await notificationService.rescheduleAllNotifications();
  }

  Future<void> _toggleReminder(int id, bool value) async {
    final db = ref.read(dbServiceProvider);
    await db.toggleReminder(id, value);
    ref.invalidate(remindersProvider);
  }

  Future<void> _deleteReminder(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Reminder"),
        content: const Text("Are you sure you want to delete this reminder?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final db = ref.read(dbServiceProvider);
      await db.deleteReminder(id);
      ref.invalidate(remindersProvider);
    }
  }

  Future<void> _showAddReminderDialog(BuildContext context) async {
    final TextEditingController titleController = TextEditingController();
    String type = AppConstants.notificationTypeCustom;
    TimeOfDay time = TimeOfDay.now();
    DateTime date = DateTime.now();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Add Reminder"),
        content: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: "Title",
                    hintText: "Enter reminder title",
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: const InputDecoration(labelText: "Type"),
                  items: const [
                    DropdownMenuItem(value: AppConstants.notificationTypeCustom, child: Text("Custom")),
                    DropdownMenuItem(value: AppConstants.notificationTypeMedication, child: Text("Medication")),
                  ],
                  onChanged: (value) => setState(() => type = value!),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text("Time"),
                  subtitle: Text(time.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: time,
                    );
                    if (picked != null) {
                      setState(() => time = picked);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                Navigator.pop(dialogContext, true);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter a title")),
                );
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );

    if (result == true && titleController.text.isNotEmpty) {
      try {
        final reminder = Reminder(
          title: titleController.text,
          type: type,
          reminderDate: date,
          hourOfDay: time.hour,
          minute: time.minute,
        );

        final db = ref.read(dbServiceProvider);
        await db.saveReminder(reminder);
        
        // Schedule the notification
        final notificationService = ref.read(notificationServiceProvider);
        await notificationService.scheduleCustomReminder(reminder);
        
        ref.invalidate(remindersProvider);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Reminder set for ${time.format(context)} daily!"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error adding reminder: $e")),
          );
        }
      }
    }

    titleController.dispose();
  }
}
