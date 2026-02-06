import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:period_tracker/models/cycle_models.dart';
import 'package:period_tracker/providers/app_providers.dart';
import 'package:period_tracker/theme/app_theme.dart';
import 'package:period_tracker/utils/constants.dart';

class PeriodLoggingScreen extends ConsumerStatefulWidget {
  final DateTime? initialDate;
  const PeriodLoggingScreen({super.key, this.initialDate});

  @override
  ConsumerState<PeriodLoggingScreen> createState() => _PeriodLoggingScreenState();
}

class _PeriodLoggingScreenState extends ConsumerState<PeriodLoggingScreen> {
  late DateTime _startDate;
  DateTime? _endDate;
  int _flowIntensity = 3;
  String _flowType = 'Medium';
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text("Log Period", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Period Start Date", Icons.calendar_today),
            const SizedBox(height: 12),
            _buildDateSelector(
              _startDate,
              (date) => setState(() => _startDate = date),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader("Period End Date (Optional)", Icons.calendar_today),
            const SizedBox(height: 12),
            _buildDateSelector(
              _endDate ?? _startDate,
              (date) => setState(() => _endDate = date),
              allowClear: true,
            ),
            const SizedBox(height: 24),
            _buildSectionHeader("Flow Intensity", Icons.water_drop),
            const SizedBox(height: 12),
            _buildFlowSelector(),
            const SizedBox(height: 24),
            _buildSectionHeader("Notes (Optional)", Icons.note),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Add any notes about your period...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 40),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
        ),
      ],
    );
  }

  Widget _buildDateSelector(DateTime date, Function(DateTime) onDateChanged, {bool allowClear = false}) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) {
          onDateChanged(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${date.day}/${date.month}/${date.year}",
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const Icon(Icons.calendar_today, color: AppTheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildFlowSelector() {
    return Column(
      children: [
        Slider(
          value: _flowIntensity.toDouble(),
          min: 1,
          max: 5,
          divisions: 4,
          activeColor: AppTheme.primary,
          label: AppConstants.flowTypes[_flowIntensity - 1],
          onChanged: (value) {
            setState(() {
              _flowIntensity = value.toInt();
              _flowType = AppConstants.flowTypes[_flowIntensity - 1];
            });
          },
        ),
        Text(
          _flowType,
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _savePeriod,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 5,
          shadowColor: AppTheme.primary.withOpacity(0.4),
        ),
        child: Text("SAVE PERIOD", style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Future<void> _savePeriod() async {
    final db = ref.read(dbServiceProvider);

    // STEP 1: Delete ALL periods (predicted AND actual) for this month
    // AND delete ALL predicted cycles to ensure a fresh timeline
    final allCycles = await db.getAllCycles();
    final loggedMonth = _startDate.month;
    final loggedYear = _startDate.year;

    for (final cycle in allCycles) {
      if ((cycle.startDate.month == loggedMonth && cycle.startDate.year == loggedYear) || 
          cycle.isPredicted) {
        await db.deleteCycle(cycle.id);
        print('🗑️ Deleted ${cycle.isPredicted ? "prediction" : "old manual entry"} for ${cycle.startDate}');
      }
    }

    // STEP 2: Save the user's actual period
    final cycle = CycleLog(
      startDate: _startDate,
      endDate: _endDate,
      flowIntensity: _flowIntensity,
      flowType: _flowType,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    await db.saveCycle(cycle);
    await db.updateLastPeriodDate(_startDate);

    // STEP 3: Clear and re-generate predictions
    final predictionService = ref.read(predictionServiceProvider);
    await predictionService.generatePredictions();

    // STEP 4: Refresh Home Screen providers immediately
    ref.invalidate(settingsProvider);
    ref.invalidate(currentCycleDayProvider);
    ref.invalidate(currentPhaseProvider);
    ref.invalidate(daysUntilPeriodProvider);
    ref.invalidate(phaseInsightProvider);
    ref.invalidate(homeStatusProvider);
    // Also invalidate cycles for the calendar
    ref.invalidate(actualCyclesProvider);
    ref.invalidate(cyclesProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Period logged successfully!')),
      );
      Navigator.pop(context);
    }
  }
}
